import { LightningElement,api} from 'lwc';

export default class MBurseSupport extends LightningElement {
    iframeObj;
    vfHost;
    @api renderChat() {
        let url = window.location.origin;
        let urlHost = url + '/app/mBurseChat';
        this.vfHost = urlHost;
        this.iframeObj = this.template.querySelector(".vfFrame").contentWindow;
        this.iframeObj.postMessage('message', window.location.origin);
    }
}