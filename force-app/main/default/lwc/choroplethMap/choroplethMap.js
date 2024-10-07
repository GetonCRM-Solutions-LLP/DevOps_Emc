import { LightningElement, api } from 'lwc';
import getDrivingState  from '@salesforce/apex/DriverDashboardLWCController.getDrivingState';
export default class ChoroplethMap extends LightningElement {
	// vfHost = 'https://mburse--partialdev--c.sandbox.vf.force.com/apex/choroplethChart';
    // origin = 'https://mburse--partialdev--c.sandbox.vf.force.com'
    vfHost;
    origin;
    iframeObj;
    contactList;
    receivedMessage;
    renderInitialized = false;
    @api contactId;
    @api background;
    @api borderColor;
    @api height;
    @api width;
    @api type;
    @api action = '';
    @api canada;


    @api reloadChart(){
        this.initializeChart()
    }

    @api getMap(usData, canadianData, selectedUS, selectedCanada){
        let url = location.origin;
        let urlHost = url + '/app/choroplethChart';
        this.vfHost = urlHost;
        this.origin = url;
        let obj = {modal : usData, background: this.background, border: this.borderColor, height: this.height, width: this.width, mapType: this.type, arrayList: canadianData, actionType: this.action, us: selectedUS, canada: selectedCanada}
        let messagePost = JSON.stringify(obj)
        if(this.template.querySelector('.vf-iframe').contentWindow){
            this.template.querySelector('.vf-iframe').contentWindow.postMessage(messagePost, this.origin)
        }
    }

    initializeChart() {
        // eslint-disable-next-line no-restricted-globals
        let url = location.origin;
        let urlHost = url + '/app/choroplethChart';
        this.vfHost = urlHost;
        this.origin = url;
        let canadaState = this.canada.split(',');
        getDrivingState({
            contactId: this.contactId
        }).then((result) =>{
            if(result){
                this.contactList = result;
                let obj = {modal : this.contactList, background: this.background, border: this.borderColor, height: this.height, width: this.width, mapType: this.type, arrayList: canadaState, actionType: this.action}
                let messagePost = JSON.stringify(obj)
                if(this.template.querySelector('.vf-iframe').contentWindow){
                    this.template.querySelector('.vf-iframe').contentWindow.postMessage(messagePost, this.origin)
                }
            }
        })
    }

    handleResponse(message){
        // check the origin match for both source and target
        if (message.origin === this.origin) {
            this.receivedMessage = JSON.stringify(message.data);
            this.dispatchEvent(
                new CustomEvent("stateclick", {
                  detail:  this.receivedMessage
                })
            );
            console.log("receive--", this.receivedMessage);
        }
    }

    // @wire(getDriverDetails, {
    //     contactId:'$contactId'
    // })driverDetailInfo({data,error}) {
    //     if (data) {
    //         this.contactList = data;
    //     }else if(error){
    //         console.log("getDriverDetails error", error)
    //     }
    // }

    renderedCallback() {
        if (this.renderInitialized) {
            return;
        }
        this.renderInitialized = true;
    }

    connectedCallback(){
        window.addEventListener( "message", this.handleResponse.bind(this), false )
    }
}