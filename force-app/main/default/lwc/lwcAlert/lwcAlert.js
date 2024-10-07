import { LightningElement,api,track } from 'lwc';

export default class LwcAlert extends LightningElement {
    @api alertMessage;
    @api showAlert = false ;

    handleClose(){
        this.showAlert = false;
    }
  
}