import { LightningElement } from 'lwc';
import { events } from 'c/utils';
export default class MBurseWelcomeNewAccount extends LightningElement {
    host;
    protocol;
    pathname;
    search;
    redirectToInsurance(){
        events(this,'Next Welcome Insurance');
        this.host = window.location.host;
        this.protocol = window.location.protocol;
        this.pathname = window.location.pathname;
        this.search = window.location.search;
        window.location.href = this.protocol + '//' + this.host + this.pathname + this.search + '#Welcome'
    }
}