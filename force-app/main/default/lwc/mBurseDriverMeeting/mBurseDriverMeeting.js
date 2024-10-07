import { LightningElement } from 'lwc';

export default class MBurseDriverMeeting extends LightningElement {
    iframeObj;
    vfHost;
    connectedCallback() {
        let url = window.location.origin;
        let urlHost = url + '/apex/resourceVideoFrame';
        this.vfHost = urlHost;
    }
}