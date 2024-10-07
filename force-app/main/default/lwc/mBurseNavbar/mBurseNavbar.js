import { LightningElement, api } from 'lwc';
import emcCss from '@salesforce/resourceUrl/EmcCSS';
export default class MBurseNavbar extends LightningElement {
    @api links;
    @api margin;
    companyLogoUrl = emcCss + '/emc-design/assets/images/logo/mBurse-logo.png';
    @api addUrl(){
        this.template.querySelector('.navbar__brand').href = "";
    }
    get headerStyle() {
        return `margin-bottom:${this.margin}`;
    }

    refreshPage(){
        window.location.reload();
    }
}