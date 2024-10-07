import { LightningElement,api,track } from 'lwc';

export default class Toast extends LightningElement {
    @track title;
    @track message;
    @track variant;
    @api
    showToast(title, message, variant, autoClose = false, autoCloseTime = 5000) {
        this.title = title;
        this.message = message;
        this.variant = variant;
        const toastModel = this.template.querySelector('[data-id="toastModel"]');
        toastModel.className = 'slds-show';
        
        if(autoClose) {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                toastModel.className = 'slds-hide';
            }, autoCloseTime);
        }
    }

    closeModel() {
        const toastModel = this.template.querySelector('[data-id="toastModel"]');
        toastModel.className = 'slds-hide';
    }

    get mainDivClass() { 
        return 'slds-notify slds-notify_toast slds-theme_'+this.variant;
      }

    get messageDivClass() { 
        return 'slds-icon_container slds-icon-utility-'+this.variant+' slds-icon-utility-success slds-m-right_small slds-no-flex slds-align-top';
    }
    get iconName() {
        return 'utility:'+this.variant;
    }
}