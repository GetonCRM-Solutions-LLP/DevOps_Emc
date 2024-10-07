import { LightningElement,api } from 'lwc';

export default class TextareaInputComponent extends LightningElement {
    @api inputContent;
    renderedCallback() {
        this.template.querySelector('.slds-textarea').disabled = true;
    }
}