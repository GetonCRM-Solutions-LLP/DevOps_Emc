import { LightningElement, api } from 'lwc';
import EMC_CSS from '@salesforce/resourceUrl/EmcCSS';
import sendMlogWelcomeEmail from '@salesforce/apex/ResourceController.sendMlogWelcomeEmail';
export default class MBurseInsights extends LightningElement {
    // List of custom settings
    @api linkList

    // Get ID of the account
    @api accountid

    //Get ID of the contact
    @api contactId

    // Store contact information
    @api client;

    // Url for plan parameter document download
    @api docUrl;

    // Url to iframe
    frameUrl='';

    //Modal header
    header = '';

    // width of video
    videoWidth = "100%";

    // height of video
    videoHeight = "448px";

    //Flag to hide show html content
    showInsight = false;

    //Flag to hide show html content
    watchMeeting = false;

    // Flag to hide show html content
    isInsurance = false;

    // Static resource for download icon 
    downloadIconUrl = EMC_CSS + '/emc-design/assets/images/download-icon-white-24.jpg';

    //Loading Icon
    loadingIcon = EMC_CSS + '/emc-design/assets/images/Email-Gif-1.gif';

    sending = false;

    carousel = false;

    carouselLists = [{
        "id": "1",
        "name": "Select the mLog icon on your phone to open the app to track mileage each day automatically"
      }, {
        "id": "2",
        "name": "Review your trips daily if possible, weekly at a minimum"
      }, {
        "id": "3",
        "name": "Reclassify trips as business, personal, or delete trips you don't want to share"
    }];
    // Function to close modal
    closePopup(){
        this.template.querySelector('.modal').style.display = 'none';
        this.template.querySelector('.modalBackdrops').style.display = 'none';
        this.dispatchEvent(
            new CustomEvent("complete", {
                detail: "close-video"
            })
        );
    }

    emailSent(){
        var emailOfContact
        if(this.client.contactEmail !== '' && this.client.contactEmail != null && this.client.contactEmail !== undefined){
            emailOfContact = this.client.contactEmail;
            this.sending = true;
            sendMlogWelcomeEmail({
                accountID: this.accountid,
                empEmail: emailOfContact
            })
            .then((result) => {
                if (result === "\"OK\"") {
                    this.sending = false;
                    this.dispatchEvent(
                        new CustomEvent("sent", {
                            detail: "email"
                        })
                    );
                }else{
                    this.sending = false;
                    this.dispatchEvent(
                        new CustomEvent("senterror", {
                            detail: 'Error While Sending Email'
                        })
                    );
                }
                console.log(result);
            })
        }else{
            this.sending = false;
            this.dispatchEvent(
                new CustomEvent("senterror", {
                    detail: 'Please provide your email address'
                })
            );
        }
       
    }
    
    popOut(){
        this.carousel = true;
    }

    handlePopover(){
        this.carousel = false;
    }

    // Function to call when component is created
    connectedCallback() {
        let hashVal = window.location.hash;   /* ---- Get hash value from url --- */
        this.isInsurance = (hashVal === '#G2') ? true : false; /* ---- Hide content based on hash value --- */
        this.showInsight = (hashVal === '#G4') ? true : false;  /* ---- Hide content based on hash value --- */
        this.watchMeeting = (hashVal === '#G5' && this.showInsight === false) ? true : false;  /* ---- Hide component based on hash value --- */
        this.header =  (hashVal === '#G1') ? 'Your Plan Preview' : (hashVal === '#G2') ? 'Your Plan Parameters' : (hashVal === '#G3') ? 'mLog App Overview' : (hashVal === '#G4') ? 'Get the mLog app' : 'Your Company Plan'
        this.frameUrl = (hashVal === '#G1') ? this.linkList.Welcome_Link__c : (hashVal === '#G2') ? this.linkList.Insurance_Link__c : (hashVal === '#G3') ? this.linkList.mLog_Preview_Company_Provided_Link__c : (hashVal === '#G5') ? this.client.scheduleLink : ""
    }


}