import { LightningElement, api } from 'lwc';
import { events } from 'c/utils';
import driverDetails from '@salesforce/apex/NewAccountDriverController.getContactDetail';
import redirectionURL from '@salesforce/apex/NewAccountDriverController.loginRedirection';
import updateContactDetail from '@salesforce/apex/NewAccountDriverController.updateContactDetail';
export default class MBurseWelcomeAccount extends LightningElement {
    host;
    protocol;
    pathname;
    search;
    showWelcomeVideo = false;
    renderInitialized = false;
    isIntialize = false;
    showBtn = true;
    renderBtnText = 'Go to step 1';
    @api customSetting;
    @api contactId;
    @api dayLeft;

    @api setStatus(){
        this.template.querySelector('c-m-burse-step').getPacketStatus();
        this.refreshView('Pending');
    }

    @api getStatus(){
        this.template.querySelector('c-m-burse-step').getPacketComplete();
        this.refreshView();
    }

    proxyToObject(e) {
        return JSON.parse(e)
    }
    
    redirectToInsurance(){
        if(this.renderBtnText !== 'Go to dashboard'){
            events(this,'Next Welcome Insurance');
        }else{
            this.takeMeToDashboard();
        }
    }

    redirectToStep(event) {
        this.showWelcomeVideo = false;
        driverDetails({
            contactId: this.contactId
        })
        .then((data) => {
            let dataList;
            if (data) {
                dataList = this.proxyToObject(data);
                dataList[0].planPreviewOnBoarding = event.detail
                updateContactDetail({
                    contactData: JSON.stringify(dataList),
                    driverPacket: true
                }).then().catch(error=>{
                    console.log("error updateContactDetail", JSON.parse(JSON.stringify(error)))
                })
            }
        }).catch((error) => {
                console.log("error driverDetails", JSON.parse(JSON.stringify(error)))
        })
    }

    enable(){
        window.history.pushState(null, null, window.location.href);
        window.onpopstate = function () {
            window.history.go(1);
        };
        sessionStorage.removeItem('envelopeId');
        location.reload()
    }

    takeMeToDashboard() {
        if(sessionStorage.getItem("envelopeId") !== null){
            let contact;
            driverDetails({contactId: this.contactId})
            .then((data) => {
            if (data) {
                contact = this.proxyToObject(data);
                if(this.dayLeft === true){
                    this.redirect()
                }else{
                    if(contact[0].driverPacketStatus === 'Uploaded'){
                        this.redirect();
                    }else{
                        this.dispatchEvent(
                            new CustomEvent("toast", {
                            detail: {message: 'You have not signed your driver packet within the required 30 days and can only log in once signing your packet.', type: 'info'}
                            })
                        );

                        setTimeout(this.enable, 6000)
                    }
                }
            }
            })
            .catch((error)=>{
                // If the promise rejects, we enter this code block
                console.log(error);
            })
        }else{
            this.redirect()
        }
    }

    redirect(){
        window.history.pushState(null, null, window.location.href);
        window.onpopstate = function () {
            window.history.go(1);
        };
        redirectionURL({
            contactId: this.contactId
        })
        .then((result) => {
            let url = window.location.origin + result;
            window.open(url, '_self');
        })
        .catch((error) => {
            // If the promise rejects, we enter this code block
            console.log(error);
        })
    }


    refreshView(m){
        driverDetails({
            contactId: this.contactId
        })
        .then((data) => {
            let dataList, view = m;
            if (data) {
                dataList = this.proxyToObject(data);
                if(view){
                    this.renderBtnText = (!dataList[0].watchMeetingOnBoarding) ? 'Go to step 1' : (dataList[0].insuranceStatus !== 'Uploaded') ? 'Go to step 2' : (!dataList[0].mlogApp) ? 'Go to step 4' : 'Go to dashboard';
                }else{
                    this.renderBtnText = (!dataList[0].watchMeetingOnBoarding) ? 'Go to step 1' : (dataList[0].insuranceStatus !== 'Uploaded') ? 'Go to step 2' : (dataList[0].driverPacketStatus !== 'Uploaded')
                    ? 'Go to step 3' : (!dataList[0].mlogApp) ? 'Go to step 4' : 'Go to dashboard'
                    this.showBtn = true
                }
            
            }
        }).catch((error) => {
                console.log("error driverDetails", JSON.parse(JSON.stringify(error)))
        })
    }

    renderView(m){
        driverDetails({
            contactId: this.contactId
        })
        .then((data) => {
            let dataList, view = m;
            if (data) {
                dataList = this.proxyToObject(data);
                if(view){
                    this.renderBtnText = (!dataList[0].watchMeetingOnBoarding) ? 'Go to step 1' : (dataList[0].insuranceStatus !== 'Uploaded') ? 'Go to step 2' : (!dataList[0].mlogApp) ? 'Go to step 4' : this.renderBtnText
                }else{
                    this.renderBtnText = (!dataList[0].watchMeetingOnBoarding) ? 'Go to step 1' : (dataList[0].insuranceStatus !== 'Uploaded') ? 'Go to step 2' : (dataList[0].driverPacketStatus !== 'Uploaded')
                    ? 'Go to step 3' : (!dataList[0].mlogApp) ? 'Go to step 4' : 'Go to dashboard'
                }
            
            }
        }).catch((error) => {
                console.log("error driverDetails", JSON.parse(JSON.stringify(error)))
        })
    }


   

    renderedCallback(){
        if (this.renderInitialized) {
              return;
        }
        this.renderInitialized = true;
        driverDetails({
            contactId: this.contactId
        })
        .then((data) => {
            let dataList;
            if (data) {
                dataList = this.proxyToObject(data);
                this.planPreviewOnBoarding = dataList[0].planPreviewOnBoarding;
                if(dataList[0].planPreviewOnBoarding){
                    this.showWelcomeVideo = false;
                }else{
                    this.showWelcomeVideo = true;
                }
                this.renderBtnText = (!dataList[0].watchMeetingOnBoarding) ? 'Go to step 1' : (dataList[0].insuranceStatus !== 'Uploaded') ? 'Go to step 2' : (dataList[0].driverPacketStatus !== 'Uploaded')
                ? 'Go to step 3' : (!dataList[0].mlogApp) ? 'Go to step 4' : 'Go to dashboard'
            }
        }).catch((error) => {
                console.log("error driverDetails", JSON.parse(JSON.stringify(error)))
        })
    }

}