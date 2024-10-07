import { LightningElement, api } from 'lwc';
import contactInfo from  '@salesforce/apex/NewAccountDriverController.getContactDetail';
import updateContactDetail from '@salesforce/apex/NewAccountDriverController.updateContactDetail';
import { events,backEvents } from 'c/utils';
export default class MBurseMlog extends LightningElement {
    render;
    arrayList;
    privacyPledgeUrl;
    videoWidth = 396;
    videoHeight = 223;
    mLogVideoUrl;
    isShow = false;
    renderInitialized = false;
    promiseError = false;
    @api contactId;
    @api cellType;
    @api customSetting;
    proxyToObject(e) {
        return JSON.parse(e)
    }
    renderStyle(){
        if(this.template.querySelector('.video-container') !== undefined || this.template.querySelector('.video-container') !== null){
            if(this.cellType === 'Company Provide') {
                this.template.querySelector('.video-container').classList.add('pd-top-2');
            }else{
                this.template.querySelector('.video-container').classList.add('pd-top');
            }
        }
    }
    toggleHide(){
        var list;
        contactInfo({contactId: this.contactId})
        .then((data) => {
          if (data) {
            this.promiseError = false;
            list = this.proxyToObject(data);
            this.arrayList = list;
           // status = list[0].driverPacketStatus;
           this.isShow = true;
            //this.isShow = (status === 'Uploaded') ? false : true;
            // this.renderStyle()
          }
        })
        .catch((error)=>{
            // If the promise rejects, we enter this code block
            console.log(error); 
        })
    }
    mLogDownload(){
        var list;
        contactInfo({contactId: this.contactId})
        .then((data) => {
          if (data) {
            this.promiseError = false;
            list = this.proxyToObject(data);
            let u;
            u = list;
            u[0].mlogApp = true;
            updateContactDetail({contactData: JSON.stringify(u),driverPacket : true})
            events(this, 'Next Download mLog');
          }
        })
        .catch((error)=>{
            // If the promise rejects, we enter this code block
            this.errorMessage = 'Disconnected! Please check your connection and log in';
            this.promiseError = true;
            console.log(error); 
        })
    }
    backToPage(){
        backEvents(this, 'Next Driver Packet');
    }

    renderedCallback(){
        if (this.renderInitialized) {
            return;
        }
        this.renderInitialized = true;
        this.toggleHide();
        this.render = (this.cellType === 'Company Provide') ? true : false;
    }
    connectedCallback() {
        let data = this.customSetting;
        this.privacyPledgeUrl = data.Privacy_Pledge_Link__c;
        this.mLogVideoUrl = (this.cellType === 'Employee Provide') ? data.mLog_Preview_Employee_Provided_Link__c : data.mLog_Preview_Company_Provided_Link__c;
    }
}