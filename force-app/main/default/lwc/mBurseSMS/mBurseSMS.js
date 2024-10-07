/* eslint-disable getter-return */
/* eslint-disable consistent-return */
import {
    LightningElement,
    api,
    track
} from 'lwc';
import sendMessageToContact from '@salesforce/apex/TrueDialogSendMessageAPI.sendMessageToContact';
import getAllMessageByContact from '@salesforce/apex/TrueDialogSendMessageAPI.getAllMessageByContact';
import sendImage from '@salesforce/apex/TrueDialogSendMessageAPI.sendImage';
import {
    loadStyle,
    loadScript
} from 'lightning/platformResourceLoader';
import myLib from '@salesforce/resourceUrl/J_emc';
import naoTipCSS from '@salesforce/resourceUrl/naoTooltipCSS';
import naoTipJS from '@salesforce/resourceUrl/naoTooltipJS';
import {
    formatList
} from 'c/commonLib';
import EMC_CSS from '@salesforce/resourceUrl/EmcCSS';
import {
    toastEvents, modalEvents
  } from 'c/utils';

export default class MBurseSMS extends LightningElement {
    /* Flag for contact name */
    @api driverName;

    /*Flag for id of driver*/
    @api driverId;

    /* Flag to store messages */
    @track messageRecords = [];

    /*Flag to for filter */
    @track filterMessage = [];

    @track progress = 1000;
    /*Static resource for avatar image */
    avatar = EMC_CSS + '/emc-design/assets/images/File.png';

    //Flag to call render function once
    renderInitialized = false;

    imageUploaded = false;

    messageLoading = false;

    insertedText = false;

    contactPicture;

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

    get nameOfDriver() {
        return (this.driverName != null || this.driverName !== undefined) ? this.driverName : ''
    }

    get classForFile() {
        return (this.imageUploaded) ? 'chat__file-image chat_background' : 'chat__file-image'
    }

    get textStyle() {
        return (this.imageUploaded) ? 'slds-col slds-size_1-of-1 slds-medium-size_6-of-12 slds-large-size_6-of-12 slds-p-right_medium' : 'slds-col slds-size_1-of-1 slds-medium-size_6-of-12 slds-large-size_9-of-12 slds-p-right_medium'
    }

    get imageHolderStyle() {
        return (this.imageUploaded) ? 'slds-col slds-size_1-of-1 slds-medium-size_6-of-12 slds-large-size_4-of-12 slds-p-right_xxx-small' : 'slds-col slds-size_1-of-1 slds-medium-size_6-of-12 slds-large-size_1-of-12 slds-p-right_xxx-small'
    }

    /*Filter data based on date  such as show latest messages as today and rest as yesterday or month name (July 2022 )*/
    filterRecord = () => {
        let _self = this
        if (_self.messageRecords.length > 0) {
            let i = 0,
                messageLen = _self.messageRecords.length;
            for (i = 0; i < messageLen; i++) {
                let date = _self.messageRecords[i].CreatedDate.split("T");
                _self.messageRecords[i].messageId = _self.messageRecords[i].Id;
                _self.messageRecords[i].Date = date[0];
                _self.messageRecords[i].parseValue = Date.parse(_self.messageRecords[i].CreatedDate)
            }
            _self.filterMessage = formatList(_self.messageRecords)
        }
    }

    /* Event to close modal*/
    handleClose() {
        clearInterval(this._interval);
        this.dispatchEvent(
            new CustomEvent("close", {
                detail: "endchat"
            })
        );
    }

    onCreateSMS() {
        let areaPos = this.template.querySelector('.message-input').value;
        if (areaPos.length > 0) {
            this.insertedText = true;
            this.messageLoading = true;
            this.template.querySelector('.send_chat_button').style.pointerEvents = 'auto';
            this.template.querySelector('.send-message').classList.remove('send-icon');
            this.template.querySelector('.send-message').classList.add('send-icon_allowed');
        } else {
            this.messageLoading = false;
            this.insertedText = false;
            this.template.querySelector('.send_chat_button').style.pointerEvents = 'none';
            this.template.querySelector('.send-message').classList.remove('send-icon_allowed');
            this.template.querySelector('.send-message').classList.add('send-icon');
        }
    }

    onKeyPress(event) {
        console.log("keyCode-----", event.keyCode)
        let textPos = this.template.querySelector('.message-input').value;
        this.template.querySelector('.message-input').value.trimEnd();
        if (event.keyCode === 13 || (event.keyCode === 32 && textPos.length === 0)) {
            event.preventDefault();
        }
        // if(this.imageUploaded){
        //     event.preventDefault();
        //     event.stopPropagation();
        // }
    }

    removeSelection() {
        let _self = this;
        _self.template.querySelector('.chat__file-image').src = "";
        _self.imageUploaded = false;
        //  _self.insertedText = false;
        _self.template.querySelector('.file-input').value = "";
        _self.template.querySelector('.send_chat_button').style.pointerEvents = 'none';
        _self.template.querySelector('.send-message').classList.remove('send-icon_allowed');
        _self.template.querySelector('.send-message').classList.add('send-icon');
        let toHeight = _self.template.querySelector('.doc-container').offsetHeight;
        if (toHeight != null || toHeight !== undefined) {
            _self.template.querySelector('.messageArea').style.maxHeight = (toHeight - 237) + 'px' /*180*/
        } else {
            _self.template.querySelector('.messageArea').style.maxHeight = 377 + 'px';
        }
    }

    handleDropFile(event) {
        event.preventDefault();
    }

    handleDragStart(event) {
        event.preventDefault();
    }

    /* Event to send message */
    onSendMessage(event) {
        let _self = this;
        if (_self.imageUploaded === false && _self.insertedText) {
            let caretPos = _self.template.querySelector('.message-input').value;
            this.messageLoading = false;
            this.template.querySelector('.send_chat_button').style.pointerEvents = 'none';
            this.template.querySelector('.send-message').classList.remove('send-icon_allowed');
            this.template.querySelector('.send-message').classList.add('send-icon');
            if (caretPos === "") {
                event.preventDefault();
            } else {
                sendMessageToContact({
                    contactId: _self.driverId,
                    message: caretPos
                }).then((result) => {
                    _self.stopAnimation();
                    _self.insertedText = false;
                    let message = "Message has been sent successfully.";
                    let toastSuccess = { type: "success", message: message };
                    toastEvents(this, toastSuccess);
                    console.log("result from sendMessageToContact", result)
                }).catch(error => {
                    let message = "Some error when sending message.";
                    let toastError = { type: "error", message: message };
                    toastEvents(this, toastError);
                    console.log("error from sendMessageToContact", error)
                })
                _self.template.querySelector('.message-input').value = "";
                event.preventDefault();
            }
        }
        else {
            let textValue = _self.template.querySelector('.message-input').value;
            _self.uploadFileInChunk(textValue);
            _self.template.querySelector('.message-input').value = ""
            let toHeight = _self.template.querySelector('.doc-container').offsetHeight;
            if (toHeight != null || toHeight !== undefined) {
                _self.template.querySelector('.messageArea').style.maxHeight = (toHeight - 180) + 'px'
            } else {
                _self.template.querySelector('.messageArea').style.maxHeight = 377 + 'px';
            }
        }

      
    }

    proxyToList(data) {
        return JSON.parse(data);
    }

    readURL(input, element) {
        var readerList;
        if (input.target.files && input.target.files[0]) {
            readerList = new FileReader();
            readerList.onload = function (e) {
                element.src = e.target.result
            }
            readerList.readAsDataURL(input.target.files[0]);
        }
    }

    toggleError(errorMsg) {
        this.dispatchEvent(new CustomEvent('fileerror', {
            detail: errorMsg
        }))
    }

    fileReaderUpload(baseTarget) {
        var fileSize, choosenfileType = '',
            photofile, reader, fileExt, i = 0,
            exactSize, fIndex, subString;
        this.choosefile = baseTarget;
        if (this.choosefile) {
            console.log("File----", this.choosefile.files[0])
            fileSize = this.choosefile.files[0].size;
            photofile = baseTarget.files[0];
            choosenfileType = photofile.type;
            this.fileList = photofile;
            this.chooseFileName = photofile.name;
            fIndex = this.chooseFileName.lastIndexOf(".");
            subString = this.chooseFileName.substring(fIndex, this.chooseFileName.length);
            if (subString === '.jpg' || subString === '.png' || subString === '.jpeg') {
                if (this.choosefile) {
                    if (this.choosefile.files[0].size > 0 && this.choosefile.files[0].size < 300000) {
                        this.choosefile = baseTarget;
                        this.imageUploaded = true;
                        this.template.querySelector('.send_chat_button').style.pointerEvents = 'auto';
                        this.template.querySelector('.send-message').classList.remove('send-icon');
                        this.template.querySelector('.send-message').classList.add('send-icon_allowed');
                    } else {
                        if (this.imageUploaded) {
                            this.template.querySelector('.send_chat_button').style.pointerEvents = 'none';
                            this.template.querySelector('.send-message').classList.remove('send-icon_allowed');
                            this.template.querySelector('.send-message').classList.add('send-icon');
                        }
                        this.imageUploaded = false;
                        this.toggleError('Base 64 Encoded file is too large.  Maximum size is 300 KB.');
                        // this.errorUploading = 'Base 64 Encoded file is too large.  Maximum size is 4 MB .';
                        console.error('Base 64 Encoded file is too large.  Maximum size is 300 KB .');
                    }
                } else {
                    if (this.imageUploaded) {
                        this.template.querySelector('.send_chat_button').style.pointerEvents = 'none';
                        this.template.querySelector('.send-message').classList.remove('send-icon_allowed');
                        this.template.querySelector('.send-message').classList.add('send-icon');
                    }
                    this.imageUploaded = false;
                    this.toggleError('There was an error uploading the file. Please try again.');
                    console.error('There was an error uploading the file. Please try again');
                }
            } else {
                if (this.imageUploaded) {
                    this.template.querySelector('.send_chat_button').style.pointerEvents = 'none';
                    this.template.querySelector('.send-message').classList.remove('send-icon_allowed');
                    this.template.querySelector('.send-message').classList.add('send-icon');
                }
                this.imageUploaded = false;
                this.toggleError('Please upload correct File. File extension should be .png, .jpg or .jpeg.');
                console.error('Please upload correct File. File extension should be .png, .jpg or .jpeg');
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

    uploadAttachment(textValue) {
        var attachmentBody = "";
        if (this.fileSize <= this.positionIndex + this.chunkSize) {
            attachmentBody = this.attachment.substring(this.positionIndex);
            this.doneUploading = true;
        } else {
            attachmentBody = this.attachment.substring(this.positionIndex, this.positionIndex + this.chunkSize);
        }
        sendImage({
                contactId: this.driverId,
                attachmentBody: attachmentBody,
                attachmentName: this.attachmentName,
                message: (textValue === '') ? null : textValue
            })
            .then((result) => {
                this.messageLoading = false;
                this.insertedText = false;
                if (result === 'success') {
                    let message = "Message with document has been sent successfully.";
                    let toastSuccess = { type: "success", message: message };
                    toastEvents(this, toastSuccess);
                    console.log('After save image to org : ' + result);
                } else {
                    this.positionIndex += this.chunkSize;
                    let message = "Some error while sending message with document.";
                    let toastError = { type: "error", message: message };
                    toastEvents(this, toastError);
                  //  this.uploadAttachment(textValue);
                  this.toggleError('There was an error uploading the file.  Please try again.');
                }
            })
            .catch((error) => {
                let message = "Some error while sending message with document.";
                let toastError = { type: "error", message: message };
                toastEvents(this, toastError);
                console.log(error);
            });
    }

    uploadFileInChunk(textValue) {
        var file = this.fileList;
        var maxStringSize = 6000000; //Maximum String size is 6,000,000 characters
        var maxFileSize = 300000; //After Base64 Encoding, this is the max file size
        if (file !== undefined) {
            this.messageLoading = true;
            this.template.querySelector('.chat__file-image').src = "";
            this.imageUploaded = false;
            this.template.querySelector('.send_chat_button').style.pointerEvents = 'none';
            this.template.querySelector('.send-message').classList.remove('send-icon_allowed');
            this.template.querySelector('.send-message').classList.add('send-icon');
            if (file.size <= maxFileSize) {
                this.attachmentName = this.chooseFileName;
                this.fileReader = new FileReader();
                this.fileReader.onerror = function () {
                    this.toggleError('There was an error reading the file.  Please try again.');
                }
                this.fileReader.onabort = function () {
                    console.log("Reading aborted!");
                    this.toggleError('There was an error reading the file.  Please try again.');
                }
                this.fileReader.onloadend = ((e) => {
                    e.preventDefault();
                    this.attachment = window.btoa(this.fileReader.result);
                    this.positionIndex = 0;
                    this.fileSize = this.attachment.length;
                    this.doneUploading = false;
                    if (this.fileSize < maxStringSize) {
                        this.uploadAttachment(textValue)
                    } else {
                        this.toggleError('Base 64 Encoded file is too large.  Maximum size is ' + maxStringSize + ' your file is ' + this.fileSize + '.');
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

    inputChange(event) {
        //   if(!this.insertedText){
        let _selfTarget = this;
        let fileImage = _selfTarget.template.querySelector('.chat__file-image');
        this.messageLoading = false;
        this.fileReaderUpload(event.target);
        // console.log("clientHeight",_selfTarget.template.querySelector('.stateBody').clientHeight)
        // console.log("scrollHeight",_selfTarget.template.querySelector('.stateBody').scrollHeight)
        // console.log("Height",_selfTarget.template.querySelector('.inputWrapper').getBoundingClientRect().height)
        // let main = _selfTarget.template.querySelector('.stateBody').clientHeight;
        // let target = _selfTarget.template.querySelector('.messageArea').offsetHeight;
        // let toTarget = _selfTarget.template.querySelector('.inputWrapper').offsetHeight;
       // this.template.querySelector('.messageArea').style.maxHeight = ((main - target) + toTarget) + 'px';
        console.log("File reading done")
        if (_selfTarget.imageUploaded) {
            _selfTarget.readURL(event, fileImage);
        } else {
            fileImage.src = ""
            event.target.value = '';
        }
        //   }else{
        //      event.target.value = '';
        //      this.toggleError("Please clear your input!");
        //   }
    }

    showSpin() {
        this.messageLoading = true;
    }

    stopAnimation() {
        this.messageLoading = false;
    }

    initializeTooltip() {
        /* Initialise all the tooltips using the wrapper class */
        // eslint-disable-next-line no-undef
        $(this.template.querySelector('.naoTooltip-wrap')).naoTooltip();

        /* Or initialise customising the speed (by default is 400) */
        // eslint-disable-next-line no-undef
        $(this.template.querySelector('.naoTooltip-wrap')).naoTooltip({
            speed: 200
        });
    }


    renderedCallback() {
        console.log("inside callback")
        if (this.renderInitialized) {
            return;
        }
        this.renderInitialized = true;
        Promise.all([
                loadScript(this, myLib)
            ])
            .then(() => {
                Promise.all([
                        loadStyle(this, naoTipCSS),
                        loadScript(this, naoTipJS)
                    ])
                    .then(() => {
                        console.log('loaded');
                        this.initializeTooltip();
                    })
                    .catch(error => {
                        console.log("Script", error)
                    });
            }).catch(error => {
                console.log("Script", error)
            });
        let toHeight = this.template.querySelector('.doc-container').offsetHeight;
        if (toHeight != null || toHeight !== undefined) {
            this.template.querySelector('.messageArea').style.maxHeight = (toHeight - 237) + 'px'
        } else {
            this.template.querySelector('.messageArea').style.maxHeight = 377 + 'px';
        }
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        window.addEventListener('resize', this._handler = (event) => this.onResize(event, this.template.querySelector('.doc-container'), this.template.querySelector('.messageArea')));
    }

    onResize(event, element, target) {
        console.log("inside resize")
        let Height = element.offsetHeight;
        if (Height != null || Height !== undefined) {
            console.log("inside resize height", Height)
            target.style.maxHeight = (Height - 237) + 'px'
        } else {
            target.style.maxHeight = 377 + 'px';
        }
    }

    connectedCallback() {
        let _self = this;
        // getContactPicture({
        //     contactId: _self.driverId
        // }).then((result)=>{
        //     let image = _self.proxyToList(result);
        //     var document = (image[0].Contact_Picture__c != null )? new DOMParser().parseFromString(image[0].Contact_Picture__c, "text/html") : image[0].Contact_Picture__c;
        //     console.log(document.body.childNodes[0].childNodes[0].src)
        // })
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this._interval = setInterval(() => {
        this.progress = this.progress + 1000;
            getAllMessageByContact({
                contactId: _self.driverId,
            }).then((result) => {
                if (result) {
                    if ((_self.proxyToList(result)).length > 0) {
                        _self.messageRecords = _self.proxyToList(result)
                        console.log(JSON.stringify(_self.messageRecords));
                        _self.filterRecord();
                    }
                }
            }).catch(error => {
                console.log("error from getAllMessageByContact", error)
            })
           if (this.progress === 1260000) {
               clearInterval(this._interval);
           }
         }, this.progress);
    }
}