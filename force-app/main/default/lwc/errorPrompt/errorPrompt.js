import { LightningElement, api} from 'lwc';

export default class ErrorPrompt extends LightningElement {
    @api promptHeader;
    @api promptMessage;
    @api PromptClassList() {
        let sectionElement = this.template.querySelector("section");
        return sectionElement;
    }
    @api PromptBackdrop() {
        let promptBackdrop = this.template.querySelector("div.promptBackdrops");
        return promptBackdrop;
    }
    handleClose(){
        this.template.querySelector("section").classList.add("slds-hide");
        this.template
            .querySelector("div.promptBackdrops")
            .classList.add("slds-hide");
    }
}