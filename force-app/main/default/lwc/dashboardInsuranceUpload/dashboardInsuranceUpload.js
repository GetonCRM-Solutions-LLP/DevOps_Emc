import {
    LightningElement,
    api
} from 'lwc';
import mBurseCss from '@salesforce/resourceUrl/EmcCSS';
import resourceImage from '@salesforce/resourceUrl/mBurseCss';
import readFromFileInchunk from '@salesforce/apex/NewAccountDriverController.readFromFileInchunk';
import sendInsuranceEmail from '@salesforce/apex/NewAccountDriverController.sendInsuranceEmail';
import updateContactInsuranceField from '@salesforce/apex/NewAccountDriverController.updateContactInsuranceField';
import updateContactDetail from '@salesforce/apex/NewAccountDriverController.updateContactDetail';
import {
    events,
    backEvents
} from 'c/utils';
export default class DashboardInsuranceUpload extends LightningElement {
/* eslint-disable @lwc/lwc/no-api-reassignments */
    /* Flag to show upload */
    @api isUploadShow;

    /*Id of contact*/
    @api contactId;

    /*Id of Account*/
    @api accountId;

    /* Id of attachment (insurance) */
    @api attachmentid;

    /* Id of contact name */
    @api contactName;

    /* Id of contact email */
    @api contactEmail;

    /* Flag for if user comes after 30 days*/
    @api dayLeft;

    /* Wrapper details of contact */
    driverDetails;

    /* Stores File Name */
    fileName;

    /* Stores file size */
    fSize;

    /* flag for error */ 
    errorUploading;

    /* Flag for result */
    fileResult;

    /* other fields */
    choosefile;
    fileList = {};
    chooseFileName = '';
    chunkSize = 950000; //Maximum Javascript Remoting message size is 1,000,000 
    attachment;
    attachmentName;
    fileSize;
    positionIndex;
    doneUploading;
    driverObject;
    isError = false;
    isVisible = false;
    
    /* Hide / Show Spinner */
    isSpinner = false;

    /* checks if file is uploaded successfully */
    isUploaded = false;

    /*flag for rendered callback*/
    renderInitialized = false;

    /*static resource file */
    uploaded = mBurseCss + '/emc-design/assets/images/file-uploaded.png';
    fileUpload = resourceImage + '/mburse/assets/mBurse-Icons/file-upload.png';
    fileSuccess = resourceImage + '/mburse/assets/mBurse-Icons/file-success.png';
    thanksUploading = resourceImage + '/mburse/assets/mBurse-Icons/thanks.png';
    /*getter setter method for insurance minimums */
    @api 
    get client(){
        return this.driverObject;
    }
    set client(value){
        if(value){
            let tempObject =  this.proxyToObject(value)
            this.driverDetails = value;
            this.driverObject = tempObject[0];
        }
    }

    /* Styling for error messages */
    toggleBoxError() {
        this.isError = true;
        this.isVisible = false;
        this.template.querySelector('.box').classList.add('has-advanced-upload-error');
        this.template.querySelector('.box').classList.remove('has-advanced-upload');
        let pathname = window.location.pathname;
        if(pathname !== "/app/driverProfileDashboard"){
            this.template.querySelector('.back_to_previous').style.top = "488px";
        }
        this.template.querySelector('.file-message').classList.add('pd-10');
        this.template.querySelector('.file-message').classList.remove('pd-3');
    }

     /* Styling for default file upload UI */
    toggleBox() {
        this.isError = false;
        this.isVisible = true;
        let pathname = window.location.pathname;
        if(pathname !== "/app/driverProfileDashboard"){
            this.template.querySelector('.back_to_previous').style.top = "455px";
        }
        this.template.querySelector('.box').classList.remove('has-advanced-upload-error');
        this.template.querySelector('.box').classList.add('has-advanced-upload');
        this.template.querySelector('.file-message').classList.remove('pd-10');
        this.template.querySelector('.file-message').classList.add('pd-3');
    }

    /* Function to read the file */
    fileReader(baseTarget) {
        var fileSize, choosenfileType = '',
            photofile, reader, fileExt, i = 0,
            exactSize, fIndex, subString;
            this.choosefile = baseTarget;
            if(this.choosefile){
                    console.log(this.choosefile.files)
                    fileSize = this.choosefile.files[0].size;
                    photofile = baseTarget.files[0];
                    choosenfileType = photofile.type;
                    this.fileList = photofile;
                    this.chooseFileName = photofile.name;
                    fIndex = this.chooseFileName.lastIndexOf(".");
                    subString = this.chooseFileName.substring(fIndex, this.chooseFileName.length);
                    if (subString === '.pdf') {
                        if(this.choosefile){
                            if (this.choosefile.files[0].size > 0 && this.choosefile.files[0].size < 4350000) {
                                this.choosefile = baseTarget;
                                this.toggleBox();
                                this.errorUploading = '';
                            } else {
                                this.toggleBoxError();
                                this.errorUploading = 'Base 64 Encoded file is too large.  Maximum size is 4 MB .';
                                console.error('Base 64 Encoded file is too large.  Maximum size is 4 MB .');
                            }
                        }else{
                            this.toggleBoxError();
                            this.errorUploading = 'There was an error uploading the file. Please try again'
                            console.error('There was an error uploading the file. Please try again');
                        }
                    } else {
                        this.toggleBoxError();
                        this.errorUploading = 'Please upload correct File. File extension should be .pdf'
                    }
            
                    reader = new FileReader();
                    reader.onload = function () {
                        this.fileResult = reader.result;
                    };
                    reader.readAsDataURL(photofile);
                    fileExt = new Array('Bytes', 'KB', 'MB', 'GB');
                    while (fileSize > 900) {
                        fileSize /= 1024;
                        i++;
                    }
                    exactSize = (Math.round(fileSize * 100) / 100) + ' ' + fileExt[i];
                    this.fileName = this.chooseFileName;
                    this.fSize = exactSize;
                    console.log("File Size-----", fileSize);
                    console.log("choosenfileType------", choosenfileType);
                    console.log("chooseFileName-------", this.chooseFileName);
            }
    }

    /* Function on file change */
    fileChanged(event) {
        console.log('File change')
        this.fileReader(event.target)
    }

    /* convert string to array */
    proxyToObject(e) {
        return JSON.parse(e)
    }

    /* Function on file upload */
    uploadAttachment(fileId) {
        var attachmentBody = "";
        this.isSpinner = true;
        if (this.fileSize <= this.positionIndex + this.chunkSize) {
            attachmentBody = this.attachment.substring(this.positionIndex);
            this.doneUploading = true;
        } else {
            attachmentBody = this.attachment.substring(this.positionIndex, this.positionIndex + this.chunkSize);
        }
        console.log(this.attachmentid, this.contactEmail, this.contactName)
        readFromFileInchunk({
                attachmentBody: attachmentBody,
                attachmentName: this.attachmentName,
                attachmentId: fileId,
                contactId: this.contactId,
                accountId: this.accountId,
                contactattachementid: this.attachmentid
            })
            .then((file) => {
                if (this.doneUploading === true) {
                    var contact;
                    updateContactInsuranceField({
                        contactId: this.contactId,
                        insuranceID: file
                    }).then(() => {
                        if(this.driverDetails){
                            contact = this.proxyToObject(this.driverDetails);
                            contact[0].insuranceStatus = "Uploaded";
                            updateContactDetail({
                                contactData: JSON.stringify(contact),
                                driverPacket : false
                            })
                        }
                         // eslint-disable-next-line @lwc/lwc/no-api-reassignments
                         this.isSpinner = false;
                         this.isUploaded = true;
                         this.isUploadShow = false;
                    }).catch((error)=>{
                         // eslint-disable-next-line @lwc/lwc/no-api-reassignments
                         this.isSpinner = false;
                        console.log("updateContactInsuranceField##", error.message);
                    })
                 
                    /*Send Email for upload insurance */
                    sendInsuranceEmail({
                            id: this.contactId,
                            name: this.contactName,
                            email: this.contactEmail
                    })
                   
                } else {
                    this.isSpinner = false;
                    this.positionIndex += this.chunkSize;
                    this.uploadAttachment(file);
                }
            })
            .catch((error) => {
                // If the promise rejects, we enter this code block
                console.log(error);
            });
    }

    uploadFileInChunk() {
        var file = this.fileList;
        var maxStringSize = 6000000; //Maximum String size is 6,000,000 characters
        var maxFileSize = 4350000; //After Base64 Encoding, this is the max file size
        if (file !== undefined) {
            if (file.size <= maxFileSize) {
                this.attachmentName = this.chooseFileName;
                this.fileReader = new FileReader();
                this.fileReader.onerror = function () {
                    this.toggleBoxError();
                    this.errorUploading = 'There was an error reading the file.  Please try again.';
                }
                this.fileReader.onabort = function () {
                    console.log("Reading aborted!");
                    this.toggleBoxError();
                    this.errorUploading = 'There was an error reading the file.  Please try again.';
                }
                this.fileReader.onloadend = ((e) => {
                    e.preventDefault();
                    this.attachment = window.btoa(this.fileReader.result);
                    this.positionIndex = 0;
                    this.fileSize = this.attachment.length;
                    this.doneUploading = false;
                    if (this.fileSize < maxStringSize) {
                        this.uploadAttachment(null)
                    } else {
                        this.toggleBoxError();
                        this.errorUploading = 'Base 64 Encoded file is too large.  Maximum size is ' + maxStringSize + ' your file is ' + this.fileSize + '.';
                    }
                })
                this.fileReader.readAsBinaryString(file);
                // eslint-disable-next-line @lwc/lwc/no-async-operation
            } else {
                console.log()
            }
        } else {
            console.log();
        }
    }

    /* on done click */
    nextDoneUpload() {
        events(this, '');
    }

    /* on back click */
    backToPrevious() {
        backEvents(this, 'Next Declaration Upload');
    }

    renderedCallback() {
        if (this.renderInitialized) {
            return;
          }
        this.renderInitialized = true;
        let pathname = window.location.pathname;
        if(this.template.querySelector('.back_to_previous')){
            if(pathname !== "/app/driverProfileDashboard")
                this.template.querySelector('.back_to_previous').style.top = "433px";
            else
                this.template.querySelector('.back_to_previous').style.marginTop = "19px";
        }
        if(this.template.querySelector('.transition')){
            if(pathname !== "/app/driverProfileDashboard")
                this.template.querySelector('.transition').style.paddingTop = "80px"
        }
        if (this.template.querySelector('form') != null) {
            this.template.querySelector('form').addEventListener(
                'submit',
                this._handler = (event) => this.handleFormSubmit(event)
            );
        }
    }

    /* Drag and drop function */
    handleDropFile(event) {
        // prevent default action (open as link for some elements)
        var files;
        console.log('Drop File--', event)
        console.log("files--", event.dataTransfer.files)
        event.preventDefault();
        event.stopPropagation();
        files = event.dataTransfer.files;
        if (files.length === 1) {
            this.template.querySelector('.box').classList.remove('is-dragover');
            this.fileReader(event.dataTransfer)
        } else {
            if (files.length > 1) {
                this.template.querySelector('.box').classList.remove('is-dragover');
                this.fileName = '';
                this.fSize = '';
                this.toggleBoxError();
                this.errorUploading = 'Please select only one file';
            }
        }
    }

    onDrag(event) {
        event.dataTransfer.dropEffect = 'copy';
        event.preventDefault();
        this.template.querySelector('.box').classList.add('is-dragover');
    }

    onDragLeave(event) {
        event.preventDefault();
        this.template.querySelector('.box').classList.remove('is-dragover');
    }

    handleFormSubmit(event) {
        event.preventDefault();
    }
}