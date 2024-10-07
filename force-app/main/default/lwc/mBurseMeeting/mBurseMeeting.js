import { LightningElement,api } from 'lwc';
import redirectionURL from '@salesforce/apex/NewAccountDriverController.loginRedirection';
import contactInfo from  '@salesforce/apex/NewAccountDriverController.getContactDetail';
export default class MBurseMeeting extends LightningElement {
    renderInitialized = false;
    promiseError = false;
    allowRedirect = false;
    driverInfo;
    @api dayLeft;
    @api contactId;
     // Watch driver meeting
     @api meeting;
     // Schedule driver meeting 
     @api schedule;
     // Type of account (New or Existing)
     @api accountType;

     get textForHeader(){
        return (this.accountType === 'New Account') ? "Step 5 - Schedule Your Driver Meeting" : "Step 5 - Watch Your Driver Meeting"
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
            if(this.dayLeft === true){
                this.allowRedirect = true;
            }else{
                if(contact[0].driverPacketStatus === 'Uploaded' && contact[0].insuranceStatus === 'Uploaded'){
                    this.allowRedirect = true;
                }else{
                    this.allowRedirect = false;
                }
            }
          }
        })
        .catch((error)=>{
            // If the promise rejects, we enter this code block
            console.log(error);
        })
    }

    redirectToDashboard() {
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
        this.renderButton();
    }
}