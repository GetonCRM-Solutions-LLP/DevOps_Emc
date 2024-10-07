/* eslint-disable @lwc/lwc/no-api-reassignments */
import {
    LightningElement,
    api
} from 'lwc';
import mBurseCss from '@salesforce/resourceUrl/EmcCSS';
import resourceImage from '@salesforce/resourceUrl/mBurseCss';
import readFromFileInchunk from '@salesforce/apex/NewAccountDriverController.readFromFileInchunk';
import contactInfo from '@salesforce/apex/NewAccountDriverController.getContactDetail';
import sendInsuranceEmail from '@salesforce/apex/NewAccountDriverController.sendInsuranceEmail';
import redirectionURL from '@salesforce/apex/NewAccountDriverController.loginRedirection';
import updateContactDetail from '@salesforce/apex/NewAccountDriverController.updateContactDetail';
import updateContactInsuranceField from '@salesforce/apex/NewAccountDriverController.updateContactInsuranceField';

import {
    events,
    skipEvents,
    backEvents
} from 'c/utils';
export default class MBurseUploadDeclaration extends LightningElement {
    @api isUploadShow;
    @api isUploadSkip;
    @api contactId;
    @api accountId;
    @api attachmentid;
    @api contactName;
    @api contactEmail;
    @api dayLeft;
    @api accountType;
    @api driverMeeting;
    // Watch driver meeting
    @api meeting;
    // Schedule driver meeting 
    @api schedule;
    driverDetails;
    renderText;
    host;
    protocol;
    pathname;
    search;
    fileName;
    fSize;
    errorUploading;
    fileResult;
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
    dPacket = false;
    packet = false;
    nextShow = false;
    nextPacketShow = false;
    isError = false;
    isVisible = false;
    isSpinner = false;
    isUploaded = false;
    renderInitialized = false;
    promiseError = false;
    showWatchBtn = false;
    afterRegister = false;
    allowRedirect = false;
    uploaded = mBurseCss + '/emc-design/assets/images/file-uploaded.png';
    fileUpload = resourceImage + '/mburse/assets/mBurse-Icons/file-upload.png';
    fileSuccess = resourceImage + '/mburse/assets/mBurse-Icons/file-success.png';
    thanksUploading = resourceImage + '/mburse/assets/mBurse-Icons/thanks.png';
    @api
    get client() {
        return this.driverObject;
    }
    set client(value) {
        let tempObject = this.proxyToObject(value)
        this.driverObject = tempObject[0];
    }
    toggleBoxError() {
        this.isError = true;
        this.isVisible = false;
        this.template.querySelector('.box').classList.add('has-advanced-upload-error');
        this.template.querySelector('.box').classList.remove('has-advanced-upload');
        this.template.querySelector('.file-message').classList.add('pd-10');
        this.template.querySelector('.file-message').classList.remove('pd-3');
    }
    toggleBox() {
        this.isError = false;
        this.isVisible = true;
        this.template.querySelector('.box').classList.remove('has-advanced-upload-error');
        this.template.querySelector('.box').classList.add('has-advanced-upload');
        this.template.querySelector('.file-message').classList.remove('pd-10');
        this.template.querySelector('.file-message').classList.add('pd-3');
    }
    fileReader(baseTarget) {
        var fileSize, choosenfileType = '',
            photofile, reader, fileExt, i = 0,
            exactSize, fIndex, subString;
        this.choosefile = baseTarget;
        if (this.choosefile) {
            fileSize = this.choosefile.files[0].size;
            photofile = baseTarget.files[0];
            choosenfileType = photofile.type;
            this.fileList = photofile;
            this.chooseFileName = photofile.name;
            fIndex = this.chooseFileName.lastIndexOf(".");
            subString = this.chooseFileName.substring(fIndex, this.chooseFileName.length);
            if (subString === '.pdf' || subString === '.PDF') {
                if (this.choosefile) {
                    if (this.choosefile.files[0].size > 0 && this.choosefile.files[0].size < 4350000) {
                        this.choosefile = baseTarget;
                        this.toggleBox();
                        this.errorUploading = '';
                    } else {
                        this.toggleBoxError();
                        this.errorUploading = 'Base 64 Encoded file is too large.  Maximum size is 4 MB .';
                        console.error('Base 64 Encoded file is too large.  Maximum size is 4 MB .');
                    }
                } else {
                    this.toggleBoxError();
                    this.errorUploading = 'There was an error uploading the file. Please try again'
                    console.error('There was an error uploading the file. Please try again');
                }
            } else {
                this.toggleBoxError();
                this.errorUploading = 'Please upload correct File. File extension should be .pdf/.PDF'
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

    fileChanged(event) {
        console.log('File change')
        this.fileReader(event.target)
    }
    proxyToObject(e) {
        return JSON.parse(e)
    }
    uploadAttachment(fileId) {
        var attachmentBody = "";
        this.isSpinner = true;
        if (this.fileSize <= this.positionIndex + this.chunkSize) {
            attachmentBody = this.attachment.substring(this.positionIndex);
            this.doneUploading = true;
        } else {
            attachmentBody = this.attachment.substring(this.positionIndex, this.positionIndex + this.chunkSize);
        }
        console.log(this.attachmentid, this.contactEmail, this.contactName, attachmentBody)
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

    backToPage() {
        this.template.querySelector('.has-advanced-upload').classList.remove('is-dragover');
        this.isVisible = false;
        this.errorUploading = '';
        this.fileName = '';
        this.fSize = '';
        this.isError = false;
    }

    nextDriverPacket() {
        events(this, 'Next Driver Packet');
    }

    nextmLog() {
        let contactData, drList;
        drList = this.driverDetails;
        contactData = this.proxyToObject(drList);
        if ((contactData[0].driverPacketStatus === 'Uploaded' && contactData[0].insuranceStatus === 'Skip')) {
            events(this, 'Next mLog Preview');
        }
    }

    nextDoneUpload() {
        let obj, contactObject;
        contactObject = this.driverDetails;
        obj = this.proxyToObject(contactObject);
        if ((obj[0].driverPacketStatus === 'Uploaded')) {
            if((obj[0].mlogApp === true)){
                if(obj[0].driverMeeting !== 'Scheduled' || obj[0].driverMeeting !== 'Attended'){
                    events(this, 'Next mburse meeting');
                }else{
                    this.redirectToDashboard()
                }
            }else{
                events(this, 'Next mLog Preview');
            }
        } else {
            events(this, 'Next Driver Packet');
        }
    }

    backToPrevious() {
        backEvents(this, 'Next Declaration Upload');
    }

    toggleHide() {
        var list, status;
        contactInfo({
                contactId: this.contactId
            })
            .then((data) => {
                if (data) {
                    this.promiseError = false;
                    this.driverDetails = data;
                    list = this.proxyToObject(data);
                    status = list[0].insuranceStatus;
                    this.nextPacketShow = (status === 'Uploaded' && list[0].driverPacketStatus !== 'Uploaded') ? true : false;
                    if (this.dayLeft === true) {
                        this.allowRedirect = true;
                        this.nextShow = (status === 'Uploaded') ? true : false;
                    } else {
                        this.allowRedirect =  (status === 'Uploaded') ? true : false;
                        this.nextShow = true;
                    }
                    this.dPacket = list[0].mlogApp;
                    this.packet = list[0].driverPacketStatus !== 'Uploaded' ? false : true;
                }
            })
            .catch((error) => {
                // If the promise rejects, we enter this code block
                console.log(error);
            })
    }

    skipToPage() {
        var contactData, beforeUpdate, toUpdate, tempList;
        if (this.driverDetails) {
            this.promiseError = false;
            tempList = this.driverDetails;
            contactData = this.proxyToObject(tempList);
            beforeUpdate = contactData[0].insuranceStatus;
            toUpdate = "Skip";
            if (beforeUpdate !== toUpdate) {
                contactData[0].insuranceStatus = "Skip";
                updateContactDetail({
                        contactData: JSON.stringify(contactData),
                        driverPacket: false
                    })
                    .then(() => {
                        this.toggleHide();
                    })
                    .catch((error) => {
                        // If the promise rejects, we enter this code block
                        this.errorMessage = 'Disconnected! Please check your connection and log in';
                        this.promiseError = true;
                        console.log(error);
                    })
            }
        }
        skipEvents(this, 'Next Declaration Upload');
    }

    redirectToDashboard() {
        events(this, 'Next mburse meeting');
        // var list, d;
        // contactInfo({
        //         contactId: this.contactId
        //     })
        //     .then((data) => {
        //         if (data) {
        //             list = this.proxyToObject(data);
        //             this.arrayList = list;
        //             d = this.arrayList;
        //             d[0].checkDriverMeeting = true;
        //             updateContactDetail({
        //                 contactData: JSON.stringify(d),
        //                 driverPacket: true
        //             })
        //             events(this, 'Next mburse meeting');
        //         }
        //     })
        //     .catch((error) => {
        //         // If the promise rejects, we enter this code block
        //         console.log(error);
        //     })
    }

    takeMeToDashboard() {
        redirectionURL({
                contactId: this.contactId
            })
            .then((result) => {
                let url = window.location.origin + result;
                window.open(url, '_self');
            })
            .catch((error) => {
                // If the promise rejects, we enter this code block
                console.log(error);
            })
    }

    renderedCallback() {
        if (this.renderInitialized) {
            return;
        }
        this.renderInitialized = true;
        this.renderText = (this.accountType === 'New Account') ? 'Register for your driver meeting' : 'Watch your driver meeting';
        this.showWatchBtn = (this.accountType === 'New Account') ? false : true;
        this.afterRegister = (this.accountType === 'New Account' && this.driverMeeting === 'Scheduled') ? true : false;
        this.toggleHide();
        if (this.template.querySelector('form') != null) {
            this.template.querySelector('form').addEventListener(
                'submit',
                this._handler = (event) => this.handleFormSubmit(event)
            );
        }
    }

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