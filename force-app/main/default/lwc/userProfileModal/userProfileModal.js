import { LightningElement,api } from 'lwc';
const CSS_CLASS = 'modal-hidden';
export default class UserProfileModal extends LightningElement {
    _modalId;
    _headerPrivate;
    hasHeaderString = false;
    showModal = false;
    @api showFooter = false;
    @api showBtn = false;
    @api headerClass;
    @api modalClass;
    @api modalContentStyle;
    @api closeBtnClass;
    @api subheaderClass;
    @api styleHeader;
    @api columns;
    @api content;
    @api month;
    @api mDashboarding;
    @api isDisabledBG = false;
    get modalId() {
        return this._modalId;
    }
    set modalId(value) {
       this._modalId = value;
       this.setAttribute('modal-id',value);
    }

    get modalContentId(){
        return `modal-content-id-${this.modalId}`;
    }

    get modalHeadingId(){
        return `modal-heading-id-${this.modalId}`;
    }

    constructor() {
        super();
        this.handleKeyDown = this.handleKeyDown.bind(this);
    }
    
    @api 
    get header() {
        return this._headerPrivate;
    }
    set header(value) {
        this.hasHeaderString = value !== '';
        this._headerPrivate = value;
    }
    
    @api show() {
        this.showModal = true;
    }

    @api hide() {
        this.showModal = false;
    }

    handleKeyDown = (event) =>{
        if (event.keyCode === 27) {
           console.log('Esc key pressed from modal.');
            const closedialog = new CustomEvent('closedialogesc');
            this.dispatchEvent(closedialog);
            this.hide()
        }
    }
    
    handleDialogClose() {
        //Let parent know that dialog is closed (mainly by that cross button) so it can set proper variables if needed
        const closedialog = new CustomEvent('closedialog');
        this.dispatchEvent(closedialog);
        this.hide();
    }

    handleSlotTaglineChange() {
        // Only needed in "show" state. If hiding, we're removing from DOM anyway
        if (this.showModal === false) {
            return;
        }
        const taglineEl = this.template.querySelector('p');
        taglineEl.classList.remove(CSS_CLASS);
    }

    handleSlotFooterChange() {
        // Only needed in "show" state. If hiding, we're removing from DOM anyway
        if (this.showModal === false) {
            return;
        }
        const footerEl = this.template.querySelector('footer');
        footerEl.classList.remove(CSS_CLASS);
    }

    handleDownload(){
        const exceldownload = new CustomEvent('exceldownload');
        this.dispatchEvent(exceldownload);
    }

    downloadTrips(){
        console.log('Trip')
        const download = new CustomEvent('download');
        this.dispatchEvent(download);
    }

    handleClose(event) {
        var eId = event.target.dataset.id;
        this.template.querySelector(`.notify-text[data-id="${eId}"]`).classList.add('slds-hide');
    }

    connectedCallback(){
        window.addEventListener('keydown', this.handleKeyDown);
    }
}