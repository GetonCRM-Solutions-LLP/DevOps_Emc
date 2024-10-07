import { LightningElement, api } from 'lwc';

export default class OnboardingPlanInfo extends LightningElement {
    @api linkList;
		@api userRole;
    eventShow(){
        this.dispatchEvent(
            new CustomEvent("spinner", {
                detail: "spinner"
            })
        );
    }

    connectedCallback(){
        console.log("linked list", this.linkList)
    }
}