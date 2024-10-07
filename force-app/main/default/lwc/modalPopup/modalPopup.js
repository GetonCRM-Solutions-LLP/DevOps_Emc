import {
    LightningElement,
    api,
    track
} from 'lwc';
import deleteMileages from '@salesforce/apex/GetDriverData.deleteMileages'
import approveMileages from '@salesforce/apex/GetDriverData.approveMileages';

export default class ModalPopup extends LightningElement {
    @api modalHeader;
    @api modalContent;
    @api approvedTripList;
    @api isChecked = false;
    @api isUnapprove = false;
    @api ModalClassList() {
        let sectionElement = this.template.querySelector("section");
        return sectionElement;
    }
    @api ModalBackdrop() {
        let modalbackdrop = this.template.querySelector("div.modalBackdrops");
        return modalbackdrop;
    }
    @track sendEmailValue = false;

    // Yes Button Click Event
    handleEmailSend() {
        if (this.isChecked != null) {
            this.sendEmailValue = (this.isUnapprove === false) ? true : false;
            this.SendEmailCheck();
            //window.location.reload();
        }else{
            this.handleDeleteTrip();
        }
        this.template.querySelector("section").classList.add("slds-hide");
        this.template
            .querySelector("div.modalBackdrops")
            .classList.add("slds-hide");
    }

    // No Button Click Event
    handleNoEmailSend() {
        if (this.isChecked != null) {
            this.sendEmailValue = false;
            this.SendEmailCheck();
            //window.location.reload();
        }
        this.template.querySelector("section").classList.add("slds-hide");
        this.template
            .querySelector("div.modalBackdrops")
            .classList.add("slds-hide");
        //window.location.reload();
    }

    // Will Send Email To List Of Users For Approve / Reject
    SendEmailCheck() {
        this.approveTrip = this.approvedTripList;
        this.selectedCheck = this.isChecked;

        approveMileages({
                checked: this.selectedCheck,
                emailaddress: this.approveTrip,
                sendEmail: this.sendEmailValue,
                unapprove: this.isUnapprove
            })
            .then((result) => {
                if(result){
                    const emailSend = new CustomEvent("handlesendemailevent", {
                        detail: result
                    });
              
                    this.dispatchEvent(emailSend);
                }
            })
            .catch((error) => {
                console.log(error)
            })
    }

    // Close 'X' Event
    handleCancel() {
        const resetEvent = new CustomEvent("handleresetevent", {
            detail: 'Reset'
        });
        this.dispatchEvent(resetEvent);
        this.template.querySelector("section").classList.add("slds-hide");
        this.template
            .querySelector("div.modalBackdrops")
            .classList.add("slds-hide");
     
    }

    // delete trip event
    handleDeleteTrip(){
        this.approveTrip = this.approvedTripList;
        deleteMileages({
            emailaddress: this.approveTrip
        })
        .then((result) => {
            if(result){
                const deleteTrip = new CustomEvent("handledeletetripevent", {
                    detail: result
                });
          
                this.dispatchEvent(deleteTrip);
            }
        })
        .catch((error) => {
            console.log(error)
        })
    }
   
}