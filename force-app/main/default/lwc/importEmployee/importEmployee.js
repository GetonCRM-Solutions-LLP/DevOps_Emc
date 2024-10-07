import { LightningElement, track, api  } from 'lwc';
import readFromFile from '@salesforce/apex/RosterController.readFromFile';
import Sample_csv_url from '@salesforce/label/c.Sample_csv_url';
import IMPORT_ICON from '@salesforce/resourceUrl/importIcon'; 
import CheckStatus from '@salesforce/apex/RosterController.CheckStatus';
import SHEETJS_ZIP from '@salesforce/resourceUrl/sheetjs';
import { loadScript } from 'lightning/platformResourceLoader';
import { toastEvents } from 'c/utils';
export default class ImportEmployee extends LightningElement {
    @track fileData;
    @api isSpinner = false;
    @track customButtonClass = 'custom-button';
    isFileSelected = false;
    @api importIconUrl = `${IMPORT_ICON}#importIcon`;
    @api accId;
    @api conId;
    fileName = '';
    fileSize = '';
    loadingMessage = 'Please wait while your users is uploaded.';
    isNotCustomSettingMessage = true;
    @api sample_csv_url = Sample_csv_url;
    employeeList
    @api carouselContent = [{
        "id": "1",
        "name": "Complete all required fields. You can edit any of the fields after the users have been created"
    }, {
        "id": "2",
        "name": "Make sure to use the correct date format. For example, if the driver activation date is March 2, 2023, it should be entered as 03-02-2023 (MM-DD-YYYY)"
    },{
        "id": "3",
        "name": "Double-check your data and formatting before uploading"
    },{
        "id": "4",
        "name": "Uploads are limited to 50 new users or less. If importing more than 50 new users repeat the upload process or contact your Success Manager"
    }];
    @api styleOfCarousel = 'slds-popover slds-nubbin_left-top  slds-popover_large slds-popover-import';
    @api styleBody = 'slds-popover__body border';
    @api styleFooter = 'slds-popover__footer border-footer slds-hide';
    @api styleHeader = 'slds-popover__header bg-dark-blue p_all';
    @api title = 'Pro Tips';
    @api intervalID;
    ready = false;

    constructor() {
        super();
        /* Loeading static resouce xlsx JS  */
        loadScript(this, SHEETJS_ZIP + '/xlsx.full.min.js')
            .then(() => {
                if (!window.XLSX) {
                    throw new Error('Error loading SheetJS library (XLSX undefined)');
                }
                this.ready = true;
            })
            .catch(error => {
               console.error("Error Loading SheetJS");
            });

    }

    connectedCallback() {
        this.carouselContent = JSON.stringify(this.carouselContent);
    }
    handleChooseFile(event) {
        this.customButtonClass = 'custom-button-clicked';
        const fileInput = this.template.querySelector('.file-input');
        fileInput.click();
    }

    handleDragOver(event) {
        event.preventDefault();
    }

    handleFileSelect(event) {
        const file = event.target.files[0];
        this.importEmployee(file);
    };

    handleFileDrop(event) {
        event.preventDefault();
        const file = event.dataTransfer.files[0];
        this.importEmployee(file);
    }

    importEmployee(file) {
        let acceptedFiles = ['xls', 'xlsx', 'csv'];
        let fileExt = file.name.split('.').pop();
        if(file && acceptedFiles.includes(fileExt) && this.ready) {
            this.fileName = file?.name;
            Promise.resolve(file)
            .then(file => {
                return this.readAsBinaryString(file);
            })
            .then( blob => {
                let workbook = window.XLSX.read(blob, { type: 'binary', cellDates: true, dateNF: 'mm/dd/yyyy' });

                if (!acceptedFiles.includes(fileExt)) {
                    if (!workbook || !workbook.Workbook) { throw new Error("Cannot read Excel File (incorrect file format?)"); }
                    if (workbook.SheetNames.length < 1) { throw new Error("Excel file does not contain any sheets"); }
                }
                let objData = [];

                /* convert worksheet to json */
                workbook.SheetNames.forEach(function (name) {
                    name = XLSX.utils.sheet_to_json(workbook.Sheets[name], {defval:""});
                    objData.push(name);
                });
                objData[0] = objData[0].map(obj => {
                    const newObj = {};
                    for (const key in obj) {
                        const newKey = key.replace(/[^\w\s]/gi, '').replace(/\s+/g, ''); // Remove spaces from the key
                        newObj[newKey] = obj[key];
                    }
                    return newObj;
                });
                this.isFileSelected = true;
                this.employeeList = objData[0];
            })
            .catch(err => {
                console.error(this.proxyToObj(err));
            })
        } else {
            let toastError = {type : 'error', message : 'Please Choose Proper File Format.'};
            toastEvents(this,toastError);
        }
    }

    handleUploadFile() {
        this.isSpinner = true;
        this.isFileSelected = false;
        if(this.employeeList.length > 0) {
            console.log("In logic");
            let empJSON = this.employeeList;
            readFromFile({file: JSON.stringify(empJSON), accountId : this.accId, adminId: this.conId})
            .then(response => {
                console.log("response", response);
                let toastMessage = '';
                if(response == "success") {
                    this.clearFile();
                    toastMessage = {type : "success", message : "Successfully Imported data."}
                    toastEvents(this, toastMessage);
                } else {
                    this.clearFile();
                    toastMessage = {type : "error", message : "Something went wrong"}
                    toastEvents(this, toastMessage);
                }
            })
            .catch(err => {
                // clearInterval(this.intervalID);
                console.log(err);
                this.clearFile();
                let toastMessage = '';
                toastMessage = {type : "error", message : "Something went wrong"}
                toastEvents(this, toastMessage);
            })
        } else {
            console.log('In empty');
            this.clearFile();
            let toastMessage = '';
            toastMessage = {type : "error", message : "Please add atleast one user information in the file."}
            toastEvents(this, toastMessage);
        }
    }

    checkBatchStatus(batchId){
        CheckStatus({batchId: batchId})
        .then(responce => {
            let res = JSON.parse(responce); //Message
            console.log("RES", JSON.stringify(res));
            
            let toastMessage = '';
            if(res?.Message == "Failed") {
                this.clearFile();
                toastMessage = {type : "error", message : "Something went wrong"}
                toastEvents(this, toastMessage);
            }

            if(res?.Message == "Completed" && res?.enablePollar == false) {
                this.clearFile();
                toastMessage = {type : "success", message : "Successfully Imported data."}
                toastEvents(this, toastMessage);
            }
        })
        .catch(err => {
            this.clearFile();
            console.log("ERROR", this.proxyToObj(err));
        })
    }


    clearFile() {
        this.employeeList = [];
        this.fileName = '';
        this.fileSize = '';
        this.isSpinner = false;
        clearInterval(this.intervalID);
        if(this.template.querySelector('.file-input')) {
            this.template.querySelector('.file-input').value = null;
        }
    }


    handleIcon(event) {
        this.toggleSlider("block");
    }

    toggleSlider(state){
        let slider = this.template.querySelector('.help-text');
        if(slider){
            slider.style.display = state;
        }
    }

    handleSliderClose(event){
        this.toggleSlider("none");
    }

    proxyToObj(data) {
        return JSON.parse(JSON.stringify(data));
    }

    readAsBinaryString(file) {
        return new Promise(function(resolve, reject){
            var reader = new FileReader();
            reader.onload = function() {            
                resolve(reader.result);
            }
            reader.onerror = function() {
                reject(reader.error);
            }
            reader.onabort = function() {
                reject(new Error('Upload aborted.'));
            }
            reader.readAsBinaryString(file);
        });
    }
}