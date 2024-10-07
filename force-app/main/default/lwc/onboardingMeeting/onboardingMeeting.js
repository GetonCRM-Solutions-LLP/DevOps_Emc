import { LightningElement, api } from 'lwc';
import { backEvents } from "c/utils";
import contactInfo from  '@salesforce/apex/NewAccountDriverController.getContactDetail';
export default class OnboardingMeeting extends LightningElement {
    renderInitialized = false;
    promiseError = false;
    allowRedirect = false;
    watchedMeeting = false;
    showBtn = false;
    accountBtn = false;
    driverInfo;
    welcomeVideoUrl = "https://hubs.ly/Q018WdQw0";
    videoWidth = 396;
    videoHeight = 223;
    renderText = "Go to step 2";
    @api customSetting;
    @api dayLeft;
    @api contactId;
     // Watch driver meeting
     @api meeting;
     // Schedule driver meeting 
     @api schedule;
     // Type of account (New or Existing)
     @api accountType;
     checked = false;
     checkedskip = false;

     get textForHeader(){
        return (this.accountType === 'New Account') ? "Schedule Your Driver Meeting" : "Watch Your Driver Meeting"
     }

     get description(){
        return (this.accountType === 'New Account') ? "Complete the form below." : "Take a moment to watch your driver meeting below."
     }

     get frameUrl(){
        return (this.accountType === 'New Account') ? this.schedule : this.meeting;
     }

     proxyToObject(e) {
        return JSON.parse(e)
      }
      
    renderButton(){
        let contact;
        console.log("days", this.dayLeft)
        contactInfo({contactId: this.contactId})
        .then((data) => {
          if (data) {
            this.driverInfo = data;
            contact = this.proxyToObject(data);
            console.log("list##", data)
            this.accountBtn = (contact[0].mburseDashboardOnBoarding && !contact[0].watchMeetingOnBoarding) ? true : false;
            this.renderText = (contact[0].watchMeetingOnBoarding) ? 'Go to step 2' : (contact[0].mburseDashboardOnBoarding && !contact[0].watchMeetingOnBoarding) ? ' Go to mDash' : this.renderText
          }
        })
        .catch((error)=>{
            // If the promise rejects, we enter this code block
            console.log(error);
        })
    }


    backToPrevious() {
        backEvents(this, "Next Preview Page");
    }

    handleNextMeeting(event) {
        if(this.checked == false){
            this.checked = true;
        }else{
            this.checked = false;
        }
        this.showBtn = (!this.checked) ? false : true;
        // this.template.querySelector('.skip-check').checked = false;
        this.checkedskip = false;
        this.watchedMeeting = this.checked
    }
   
    handleSkipMeeting(event) {
        if(this.checkedskip == false){
            this.checkedskip = true;
        }else{
            this.checkedskip = false;
        }
        this.showBtn = (!this.checkedskip) ? false : true;
        this.checked = false;
        // this.template.querySelector('.complete-check').checked = false;
    }

    nextStep(){
        const e = new CustomEvent('next', {detail: this.watchedMeeting});
        this.dispatchEvent(e);
    }

    renderedCallback() {
        if (this.renderInitialized) {
            return;
        }
        this.renderInitialized = true;
        this.renderButton();
    }

    connectedCallback() {
        console.log("callback called", this.customSetting)
        // let data = this.customSetting;
        // this.welcomeVideoUrl = data.Welcome_Link__c;
    }
}