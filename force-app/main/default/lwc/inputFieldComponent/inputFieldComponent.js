import { LightningElement,api } from 'lwc';

export default class InputFieldComponent extends LightningElement {
    @api inputValue;
    // @api getInput(input){
    //     this.inputValue = input;
    // }
    renderedCallback() {
        this.template.querySelector('.slds-input').disabled = true;
        if(this.inputValue===undefined){
            this.inputValue = '';
        }
    }

}