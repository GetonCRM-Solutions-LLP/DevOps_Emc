import { LightningElement, wire, api } from 'lwc';
import updateLockDate from '@salesforce/apex/WrapperUtils.updateLockDate';
import ReportUnlock from '@salesforce/apex/WrapperUtils.ReportUnlock';

export default class LockUnlockPopup extends LightningElement {

    @api accountId;
    @api contactId;
    isFalse = true;
    modalclass = "slds-modal slds-fade-in-open ";
    headerclass = "slds-modal__header header-preview hedear-style_class header_style";
    subheaderClass = "slds-modal__title slds-hyphenate hedear-style_class ";
    modalcontentstyle = "slds-modal__content slds-p-left_medium slds-p-right_medium slds-p-bottom_medium slds-p-top_small content_div_scroll";
    styleheader = "slds-modal__container container_style";
    closebtnclass = "close-notify";
    headerName;
    accountLockContent;
    isLock;

    @api
    initializeModal(detail) {
        console.log('detail in popup : ' + JSON.stringify(detail));
        let dataField = detail.dataField;
        if(dataField == 'lock') {
            this.isLock = true;
        } else if(dataField == 'unlock') {
            this.isLock = false;
        }
        this.headerName = detail.header;
        this.accountLockContent = 'Select the button to make changes to this reimbursement periods report';
        if (this.template.querySelector('c-user-profile-modal')) {
            this.template.querySelector('c-user-profile-modal[data-id="account"]').show();
        }
    }

    handleMainEvent() {
        this.dispatchEvent(
            new CustomEvent("showspin", {})
        );
        if(this.isLock == true) {
            ReportUnlock({ accId: this.accountId })
            .then(result => {
                if(result == 'Success') {
                    this.template.querySelector('c-user-profile-modal[data-id="account"]').hide();
                    this.dispatchEvent(
                        new CustomEvent("changeicon", {}),
                    );
                    this.dispatchEvent(
                        new CustomEvent("hidespin", {}),
                    );
                    this.dispatchEvent(
                        new CustomEvent("toast", {
                            detail: {
                              errormsg: "success",
                              message: "Account is unlocked successfully."
                            }
                        })
                    );
                } else {
                    this.template.querySelector('c-user-profile-modal[data-id="account"]').hide();
                    this.dispatchEvent(
                        new CustomEvent("hidespin", {})
                    );
                    new CustomEvent("toast", {
                        detail: {
                          errormsg: "error",
                          message: "Something wrong in unlocking account."
                        }
                    })
                }
            })
            .catch(error => {
                console.log('error in updateLockDate : ' + JSON.stringify(error));
                this.template.querySelector('c-user-profile-modal[data-id="account"]').hide();
                this.dispatchEvent(
                    new CustomEvent("hidespin", {})
                );
                new CustomEvent("toast", {
                    detail: {
                      errormsg: "error",
                      message: "Something wrong in unlocking account."
                    }
                })
            });
        } else {
            updateLockDate({
            accountId: this.accountId,
            contactID: this.contactId
            })
            .then(result => {
                this.template.querySelector('c-user-profile-modal[data-id="account"]').hide();
                this.dispatchEvent(
                    new CustomEvent("download", {})
                );
                this.dispatchEvent(
                    new CustomEvent("changeicon", {})
                );
                this.dispatchEvent(
                    new CustomEvent("hidespin", {})
                );
                this.dispatchEvent(
                    new CustomEvent("toast", {
                      detail: {
                        errormsg: "success",
                        message: "Account is locked successfully."
                      }
                    })
                )
            })
            .catch(error => {
                console.log('error in updateLockDate : ' + JSON.stringify(error));
                this.template.querySelector('c-user-profile-modal[data-id="account"]').hide();
                this.dispatchEvent(
                    new CustomEvent("hidespin", {})
                );
                new CustomEvent("toast", {
                    detail: {
                      errormsg: "error",
                      message: "Something wrong in locking account."
                    }
                  })
            });
        }
    }
}