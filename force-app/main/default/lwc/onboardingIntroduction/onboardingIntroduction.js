/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, api } from 'lwc';

export default class OnboardingIntroduction extends LightningElement {
    @api customSetting
    contentText = "slds-modal__content overflow-inherit transparent_content";
    resourceText = "Welcome!";
    welcomeVideoUrl = "";
    isShowAgain = false;
    // width of video
    videoWidth = "100%";

    // height of video
    videoHeight = "332px";


    connectedCallback(){
        let data = this.customSetting;
        this.welcomeVideoUrl = data.Welcome_Link_Admin__c;
        setTimeout(()=>{
            if (this.template.querySelector('c-user-profile-modal')) {
                this.template.querySelector('c-user-profile-modal').show();
            }
        }, 1000)
    }

    welcomeChange(event){
        this.isShowAgain = event.target.checked;
    }

    handleGetStarted(){
        this.dispatchEvent(
            new CustomEvent("redirect", {
                detail: this.isShowAgain
            })
        );
    }
}