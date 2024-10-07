import { LightningElement,api } from 'lwc';
import updateContactDetail from '@salesforce/apex/NewAccountDriverController.updateContactDetail';
import redirectionURL from '@salesforce/apex/NewAccountDriverController.loginRedirection';
import contactInfo from '@salesforce/apex/NewAccountDriverController.getContactDetail';
import {
    backEvents, events
} from 'c/utils';
export default class OnboardingPlanPreview extends LightningElement {
    videoWidth = 396;
    videoHeight = 223;
    welcomeVideoUrl;
    buttonRender = '';
    nextShow = false;
    nextPreview = false;
    isPlay = false;
    renderInitialized = false;
    promiseError = false;
    driverDetails;
    renderTour = false;
    renderMeeting = false;
    renderAccount = false;
    @api dayLeft;
    @api contactId;
    @api welcomeInsurance;
    @api customSetting;
    @api accountType;

    backToPrevious(){
        backEvents(this, 'Next Welcome Page');
    }

    nextTour(){
        console.log("Redirect mDash Tour")
        events(this,'');
    }

    nextMeeting(){
        events(this,'Redirect to Meeting');
    }

    proxyToObject(e) {
        return JSON.parse(e)
    }

    toggleHide() {
        var list, contactList
        contactInfo({
                contactId: this.contactId
            })
            .then((data) => {
                console.log("detail data", data)
                if (data) {
                    this.driverDetails = data;
                    list = this.driverDetails;
                    contactList = this.proxyToObject(list);
                    console.log(contactList[0].watchMeetingOnBoarding , contactList[0].mburseDashboardOnBoarding)
                    this.renderMeeting = (!contactList[0].watchMeetingOnBoarding && contactList[0].mburseDashboardOnBoarding) ? true : false
                    this.renderAccount = (contactList[0].watchMeetingOnBoarding && contactList[0].mburseDashboardOnBoarding) ? true : false
                    this.buttonRender = this.accountType === "New Account" ? "Register for your manager meeting" : "Watch your manager training";
                }
            })
            .catch((error) => {
                console.log(error);
            })
    }

    loggedInToAccount(){
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

    removePreview(){
        var list, contactList
        if (this.driverDetails) {
            list = this.driverDetails;
            contactList = this.proxyToObject(list);
            contactList[0].planPreviewOnBoarding = true;
            console.log( JSON.stringify(contactList))
            updateContactDetail({
                contactData: JSON.stringify(contactList),
                driverPacket: true
            }).then(() => {
                if(contactList[0].mburseDashboardOnBoarding && !contactList[0].watchMeetingOnBoarding){
                    events(this,'Redirect to Meeting');
                }else if(contactList[0].watchMeetingOnBoarding && contactList[0].mburseDashboardOnBoarding){
                    this.loggedInToAccount();
                }else{
                    events(this,'');
                }
               
            }).catch(error=>{
                console.log("error", error)
            })
        }
    }

    renderedCallback(){
        this.toggleHide();
    }


    connectedCallback() {
        console.log("callback called", this.customSetting)
        let data = this.customSetting;
        this.welcomeVideoUrl = data.Welcome_Link__c;
    }
}