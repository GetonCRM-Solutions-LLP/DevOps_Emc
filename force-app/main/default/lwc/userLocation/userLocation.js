import { LightningElement, api, wire } from 'lwc';
import MEChannel from "@salesforce/messageChannel/ManualEntry__c";
import { publish, MessageContext } from 'lightning/messageService';
import { getLocations } from 'c/apexUtils'
import {
    toastEvents,modalEvents
} from 'c/utils';

export default class UserLocation extends LightningElement {
    @api contactId;
    @api userTriplogId;
    @api accountId;
    @api mapCountry;
    myLocation = false;
    addLocation = false;
    addSingleLocation = false;
    manualMileageList;
    locationsList;
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

    @wire(MessageContext)
    messageContext;

    @api
    async generateView(){
        // let btnItem = this.template.querySelectorAll(".btn-toggle");
        // btnItem.forEach((el) => {
        //  el.classList.remove("is-active");
        // });
        this.locationsList = await getLocations(this.contactId);
        // this.template.querySelector('.my-trip').classList.add("is-active");
        this.addLocation = false;
        this.addSingleLocation = false;
        this.myLocation = true;
    }

    // renderedCallback() {
    //     const buttonItem = this.template.querySelectorAll(".btn-toggle");
    //     buttonItem.forEach((el) =>
    //       el.addEventListener("click", () => {
    //         buttonItem.forEach((el2) => el2.classList.remove("is-active"));
    //         el.classList.add("is-active");
    //       })
    //     );
    // }

    handleAddLocation() {
        this.myLocation = false;
        this.addLocation = true;
        this.addSingleLocation = false;
    }

    handleSingleLocation(){
        this.addSingleLocation = true;
        let detail = {
            contactId: this.contactId,
            dataField: "loc-add"
        };
        detail.locationToUpdate = {
            name: '',
            address: '',
            state: '',
            city: '',
            zipCode: '',
            street: '',
            phone: '',
            latitude: '',
            longitude: '',
            range: '',
            activity: 'Business'
        };
        detail.tripId = "newOne"
        publish(this.messageContext, MEChannel, detail);
    }

    handleToast(event) {
        this.dispatchEvent(
            new CustomEvent("toastmessage", {
                detail: event.detail
            })
        );
    }

    showSpinner() {
        toastEvents(this, 'Please wait while your location being uploaded.');
    }

    hideSpinner() {
        toastEvents(this, 'Hide');
    }

    handleCloseModal(event) {
        this.addSingleLocation = false;
    }

    handleShowLocations(event) {
        this.myLocation = false;
        this.addSingleLocation = false;
        this.addLocation = false;
        this.generateView();
    }

    showSpinner(event){
        toastEvents(this, event.detail);
    }

    showModal(event){
        modalEvents(this, event.detail);
    }

    showListModal(event){
        this.dispatchEvent(
            new CustomEvent("listmodal", {
              detail: event.detail
            })
          );
    }

    showErrorToast(event){
        this.dispatchEvent(
            new CustomEvent("error", {
                detail: event.detail
            })
        );
    }
    async connectedCallback(){
        this.locationsList = await getLocations(this.contactId);
        console.log('location list', this.locationsList);
        this.myLocation = true;
    }
}