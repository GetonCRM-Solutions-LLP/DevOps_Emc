import { LightningElement, api} from 'lwc';
import sendWelcomeEmail from '@salesforce/apex/NewAccountDriverController.sendWelcomeEmail';
export default class MBursePlanInfo extends LightningElement {
    @api linkList;
    sending = false;
    eventShow(){
        this.dispatchEvent(
            new CustomEvent("spinner", {
                detail: "spinner"
            })
        );
    }
    showToast(event) {
        this.dispatchEvent(
        new CustomEvent("toast", {
            detail: event.detail
        })
        );
    }
    logout(){
        sessionStorage.removeItem("envelopeId");
    }
    emailSent(event){
        var emailOfContact
        console.log(event.detail.contactEmail, event.detail.accountId)
        if(event.detail.contactEmail !== '' && event.detail.contactEmail != null && event.detail.contactEmail !== undefined){
            emailOfContact = event.detail.contactEmail;
            this.sending = true;
            sendWelcomeEmail({
                accountID: event.detail.accountId,
                empEmail: emailOfContact
            })
            .then((result) => {
                if (result === "\"OK\"") {
                    this.sending = false;
                    this.dispatchEvent(
                        new CustomEvent("sent", {
                            detail: event.detail
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
}