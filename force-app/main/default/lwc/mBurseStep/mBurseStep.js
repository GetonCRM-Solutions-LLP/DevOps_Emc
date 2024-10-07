import { LightningElement,api,track } from 'lwc';
import  emcUrl from '@salesforce/resourceUrl/mBurseCss';
import  svgFile from '@salesforce/resourceUrl/SvgFiles';
import driverDetails from  '@salesforce/apex/NewAccountDriverController.getContactDetail';
export default class MBurseStep extends LightningElement {
    step1Url = svgFile + '/onBoarding/SVG/1.svg';
    step2Url = svgFile + '/onBoarding/SVG/2.svg';
    step3Url = svgFile + '/onBoarding/SVG/3.svg';
    step4Url = svgFile + '/onBoarding/SVG/4.svg';
    step5Url = emcUrl + '/mburse/assets/onBoarding/5.png';
    number1 = emcUrl + '/mburse/assets/Numbers/1.png';
    number2 = emcUrl + '/mburse/assets/Numbers/2.png';
    number3 = emcUrl + '/mburse/assets/Numbers/3.png';
    number4 = emcUrl + '/mburse/assets/Numbers/4.png';
    number5 = emcUrl + '/mburse/assets/Numbers/5.png';
    checkmark = emcUrl + '/mburse/assets/check-yellow.png'
    contactId;
    accountType = false;
    phone = false;
    @api isInsuranceDone;
    @api isAppDone;
    @api isDriverPacketDone;
     isSchedule = false;
     isRegister = false;
    @track isPacketDone = false;
    @track completeProcess = true;
    @api account;
    @api cellphone;
    @api getPacketStatus(){
        this.completeProcess = false;
        this.isPacketDone = true;
    }
    @api getPacketComplete(){
        this.isPacketDone = true;
        this.completeProcess = true;
        console.log("Packet called--", this.isPacketDone)
    }
    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }
    proxyToObject(e) {
        return JSON.parse(e)
    }
   
    connectedCallback(){
        const idParamValue = this.getUrlParamValue(window.location.href, 'id');
        const aidParamValue = this.getUrlParamValue(window.location.href, 'accid');
        this.contactId = idParamValue;
        this.accountId = aidParamValue;
        driverDetails({contactId: this.contactId})
        .then((data) => {
                var driverDetailList;
                if (data) {
                    driverDetailList = this.proxyToObject(data);
                    this.accountType = (driverDetailList[0].accountStatus === 'New Account') ? true : false;
                    this.phone = (driverDetailList[0].cellPhone === 'Company Provide') ? true : false;
                    // eslint-disable-next-line @lwc/lwc/no-api-reassignments
                    this.isInsuranceDone = (driverDetailList[0].insuranceStatus === 'Uploaded') ? true  : false;
                    // eslint-disable-next-line @lwc/lwc/no-api-reassignments
                    this.isAppDone = driverDetailList[0].mlogApp;
                    this.isDriverPacketDone = (driverDetailList[0].driverPacketStatus === 'Uploaded' || driverDetailList[0].driverPacketStatus === 'Sent') ? true  :  false;
                    this.isPacketDone = this.isDriverPacketDone;
                    this.completeProcess = (driverDetailList[0].driverPacketStatus === 'Uploaded') ? true : false;
                    this.isSchedule = (driverDetailList[0].driverMeeting === 'Scheduled') ? true : false;
                    this.isRegister = (driverDetailList[0].watchMeetingOnBoarding) ? true : false;
                }
         })
        .catch((error) => {
            console.log('Error', error.message)
        })
    }
}