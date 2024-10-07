import { LightningElement, api } from 'lwc';

export default class PreviewFileModal extends LightningElement {
    showFrame = false;
    showModal = false;
    modalText = "";    

    //content class of resources
    contentText = ""
    modalContainer = ""
    videoPlayUrl = ""
    // width of video
    videoWidth = "100%";

    // height of video
    videoHeight = "332px";

    constructor() {
      super();
      this.handleKeyDown = this.handleKeyDown.bind(this);
    }

    @api show() {
      this.showModal = true;
    }

    @api showVideo(title, url){
      this.contentText = "slds-modal__content transparent_content";
      this.modalContainer = "slds-modal__container";
      this.template.querySelector('.parent').classList.remove('index');
      this.template.querySelector('.parent').classList.add('add-index');
      this.showFrame = true;
      this.videoPlayUrl = url;
      this.modalText = title;
      if (this.template.querySelector('c-user-profile-modal')) {
        this.template.querySelector('c-user-profile-modal').show();
      }
    }

    exitFullscreen() {
      if(this.template.querySelector('.parent')){
        this.template.querySelector('.parent').classList.remove('overlay-slide-down');
        this.template.querySelector('.parent').classList.add('overlay-slide-up');
      }
      this.showModal = false;
      this.showFrame = false;
    }

    closePopup(){
      if(this.template.querySelector('.parent')){
        this.template.querySelector('.parent').classList.remove('add-index');
        this.template.querySelector('.parent').classList.add('index');
      }
      this.showFrame = false;
    }

    // Esc key pressed
    handleKeyDown = (event) =>{
      if (event.keyCode === 27) {
        if(!this.showFrame)
            this.exitFullscreen();
        else
          this.closePopup();
      }
   }

   connectedCallback(){
    window.addEventListener('keydown', this.handleKeyDown);
   }
}