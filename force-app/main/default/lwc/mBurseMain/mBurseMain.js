import {
  LightningElement,
  api,
  track
} from 'lwc';
import updateContactDetail from '@salesforce/apex/NewAccountDriverController.updateContactDetail';
import redirectionURL from '@salesforce/apex/NewAccountDriverController.loginRedirection';
import driverDetails from '@salesforce/apex/NewAccountDriverController.getContactDetail';
export default class MBurseMain extends LightningElement {
  nextInsurance = false;
  nextDeclationUpload = false;
  nextDriverPacket = false;
  nextmLogPreview = false;
  nextmLogDownload = false;
  nextBurseMeeting = false;
  // nextBurseFinal = false;
  welcomePage = true;
  isInsurance = true;
  isDeclaration = false;
  skipUpload = false;
  uploadVal = true;
  renderInitialized = false;
  contactId;
  accountId;
  contactName;
  contactFirstName;
  contactEmail;
  mobilePhone;
  attachmentid;
  @track information;
  registerMeeting;
  accountType;
  meetingType;
  cellphoneType;
  _handler;
  @api settings;
  getUrlParamValue(url, key) {
    return new URL(url).searchParams.get(key);
  }

  proxyToObject(e) {
    return JSON.parse(e)
  }

  renderView(array) {
    let listForInfo, m, cList;
    // listForInfo = (event.detail);
    listForInfo = array
    cList = this.proxyToObject(listForInfo);
    m = cList[0];
    const parameter = this.getUrlParamValue(window.location.href, 'event');
    //this.welcomePage = ((m.driverPacketStatus === null && m.insuranceStatus === null) || (m.driverPacketStatus === 'Skip' && m.insuranceStatus === 'Skip') || (m.driverPacketStatus === null  && m.insuranceStatus === 'Skip') || (m.driverPacketStatus === 'Uploaded' && m.insuranceStatus === 'Skip' )) ? true : false;
    this.nextInsurance = (m.watchMeetingOnBoarding) ? ((m.driverPacketStatus === null && m.insuranceStatus === null) || (m.driverPacketStatus !== 'Uploaded' && (m.insuranceStatus === null || m.insuranceStatus === 'Skip')) || (m.driverPacketStatus === null && (m.insuranceStatus === null || m.insuranceStatus === 'Skip')) || (m.driverPacketStatus === 'Uploaded' && (m.insuranceStatus === null || m.insuranceStatus === 'Skip'))) ? true : false : true;
    this.isInsurance = (!m.watchMeetingOnBoarding) ? true : false;
    this.isDeclaration = (!this.isInsurance) ? true : false;
    if(sessionStorage.getItem("envelopeId") !== null && parameter !== 'cancel'){
      this.nextDriverPacket = false
      this.nextmLogPreview = (m.watchMeetingOnBoarding && m.insuranceStatus === 'Uploaded' && m.mlogApp === false) ? true : false;
    }else{
      this.nextDriverPacket = (m.watchMeetingOnBoarding && m.insuranceStatus === 'Uploaded' && m.driverPacketStatus !== 'Uploaded') ? true : false;
      this.nextmLogPreview = (m.watchMeetingOnBoarding && m.insuranceStatus === 'Uploaded' && m.driverPacketStatus === 'Uploaded' && m.mlogApp === false) ? true : false;
    }
    this.nextBurseMeeting = (m.insuranceStatus === 'Uploaded' && m.driverPacketStatus === 'Uploaded' && m.mlogApp === true) ? true : false;
    console.log("renderview", this.isInsurance, this.nextInsurance)
  }

  CheckStatusPacket(){
    if(sessionStorage.getItem("envelopeId") !== null){
      if(this.template.querySelector('c-m-burse-welcome-account')){
        this.template.querySelector('c-m-burse-welcome-account').setStatus();
      }
     
      driverDetails({
        contactId: this.contactId
      })
      .then((data) => {
        var driverDetailList, object;
        if (data) {
          driverDetailList = this.proxyToObject(data);
          object = driverDetailList[0];
          //if(object.driverPacketStatus === 'Sent' || object.driverPacketStatus === 'Resent' || object.driverPacketStatus === 'Resent Again'){
            if(object.driverPacketStatus !== 'Uploaded'){
                  console.log("driver", driverDetailList[0].driverPacketStatus )
                  this.CheckStatusPacket();
            }else{
              sessionStorage.removeItem("envelopeId");
              this.template.querySelector('c-m-burse-welcome-account').getStatus();
            }
          //}
        }
      })
      .catch((error) => {
        console.log('Error', error)
      })
    }
  
  }

  callApex() {
    driverDetails({
        contactId: this.contactId
      })
      .then((data) => {
        var driverDetailList;
        if (data) {
          this.information = data;
          driverDetailList = this.proxyToObject(data);
          console.log("driver", driverDetailList)
          this.registerMeeting = driverDetailList[0].scheduleLink;
          this.scheduleMeeting = driverDetailList[0].scheduleLink;
          this.attachmentid = driverDetailList[0].insuranceId;
          this.contactName = driverDetailList[0].contactName;
          this.contactFirstName = (driverDetailList[0].contactFirstName === null || driverDetailList[0].contactFirstName === undefined) ? driverDetailList[0].contactName : driverDetailList[0].contactFirstName;
          this.contactEmail = driverDetailList[0].contactEmail;
          this.mobilePhone = driverDetailList[0].mobilePhone;
          this.accountType = driverDetailList[0].accountStatus;
          this.meetingType = driverDetailList[0].driverMeeting;
          this.cellphoneType = driverDetailList[0].cellPhone;
          this.leftDays = driverDetailList[0].checkActivationDate;
          // eslint-disable-next-line @lwc/lwc/no-async-operation
          setTimeout(() => {
            this.dispatchEvent(
              new CustomEvent("show", {
                detail: "spinner"
              })
            );
          }, 100);
          //console.log('Listening from wire handler', data)
        }
      })
      .catch((error) => {
        console.log('Error', error)
      })
  }

  connectedCallback() {
    const idParamValue = this.getUrlParamValue(window.location.href, 'id');
    const aidParamValue = this.getUrlParamValue(window.location.href, 'accid');
    const parameter = this.getUrlParamValue(window.location.href, 'event');
    this.contactId = idParamValue;
    this.accountId = aidParamValue;
    let embeddedStatus = sessionStorage.getItem("envelopeId")
    if(embeddedStatus !== null && window.performance.getEntriesByType("navigation")[0].type === 'navigate'){
      if(parameter === 'cancel'){
        location.href = "/app/secur/logout.jsp";
      }else{
        this.CheckStatusPacket();
      }
    }
    console.log("envelopeId---", sessionStorage.getItem("envelopeId"));
   // this.callApex();
  }

  navigateToInsurance() {
    //this.callApex();
    let listForInfo , list;
    listForInfo = this.information;
    list = this.proxyToObject(listForInfo);
    console.log("inside insurance", list[0].watchMeetingOnBoarding)
    this.welcomePage = false;
    // this.nextInsurance = true;
    // this.isInsurance = (!list[0].watchMeetingOnBoarding) ? true : false;
   // this.isDeclaration = (!this.isInsurance) ? true : false;
  // if(!this.isInsurance){
     this.renderView(listForInfo);
  // }
    //this.nextInsurance = true;
  }

  navigateToDeclaration() {
    this.nextInsurance = false;
    this.nextDeclationUpload = true;
    this.skipUpload = false;
    this.uploadVal = true;
  }


  nextView(e){
    var value
    let m = this.information;
    value = this.proxyToObject(m)
    console.log("###", value)
    this.nextInsurance = false;
    this.isInsurance = false;
    this.isDeclaration = false;
    this.nextDeclationUpload = false;
    value[0].watchMeetingOnBoarding = (e.detail === true) ? true : false;
    updateContactDetail({
        contactData: JSON.stringify(value),
        driverPacket: false
    }).then(() => {
      if ((value[0].insuranceStatus === 'Uploaded')) {
        if ((value[0].driverPacketStatus === 'Uploaded')) {
          if (value[0].mlogApp) {
            this.takeMeToDashboard();
          } else {
            this.nextmLogPreview = true;
          }
        } else {
          this.nextDriverPacket = true;
        }
      } else {
        console.log("inside---");
        this.nextInsurance = true;
        this.isInsurance = false;
        this.isDeclaration = true;
        this.nextDeclationUpload = false;
      }
    })
   
  }

  navigateToDriverPacket(event) {
    this.nextDeclationUpload = false;
    if (event.detail === 'Next Driver Packet') {
      this.nextDriverPacket = true;
    } else if (event.detail === 'Next mLog Preview') {
      this.nextmLogPreview = true;
    } else if (event.detail === 'Next mburse meeting') {
      this.takeMeToDashboard();
    }
  }

  navigateTomLog(event) {
    this.nextDriverPacket = false;
    if (event.detail === 'Next mburse meeting') {
      this.nextBurseMeeting = true;
    } else {
      this.nextmLogPreview = true;
    }
  }

  navigateTomLogDownload() {
    this.nextmLogPreview = false;
    this.nextmLogDownload = true;
  }

  navigateToFinal() {
    this.nextmLogDownload = false;
    // this.nextBurseFinal = true;
  }

  navigateToMeeting() {
    this.nextmLogPreview = false;
    this.nextmLogDownload = false;
    this.nextDriverPacket = false;
    this.nextDeclationUpload = false;
    this.nextBurseMeeting = true;
  }

  skipToDriverPacket() {
    this.skipUpload = true;
    this.uploadVal = false;
    this.welcomePage = false;
    this.nextDriverPacket = false;
    this.nextmLogPreview = false;
    this.nextmLogDownload = false;
    this.nextBurseMeeting = false;
    // this.nextBurseFinal = false;
    this.nextInsurance = false;
    this.nextDeclationUpload = true;
  }

  skipTomLogPreview() {
    this.welcomePage = false;
    this.nextDriverPacket = false;
    this.nextmLogPreview = true;
    this.nextmLogDownload = false;
    this.nextBurseMeeting = false;
    // this.nextBurseFinal = false;
    this.nextInsurance = false;
    this.nextDeclationUpload = false;
    this.skipUpload = false;
    this.uploadVal = true;
  }

  backToDriverPacket() {
    let status;
    this.welcomePage = false;
    this.nextmLogPreview = false;
    this.nextmLogDownload = false;
    this.nextBurseMeeting = false;
    // this.nextBurseFinal = false;
    this.nextInsurance = false;
    this.nextDeclationUpload = false;
    driverDetails({
        contactId: this.contactId
      })
      .then((data) => {
        let dataList;
        if (data) {
          dataList = this.proxyToObject(data);
          status = dataList[0].driverPacketStatus;
          if (status === 'Uploaded') {
            if(dataList[0].insuranceStatus !== 'Uploaded' || !dataList[0].watchMeetingOnBoarding ){
              this.nextDriverPacket = false;
              this.nextInsurance = true;
              this.isInsurance = (!dataList[0].watchMeetingOnBoarding) ? true : false;
            }else{
              this.welcomePage = true;
            }
          } else {
            this.nextInsurance = false;
            this.isInsurance = false;
            this.nextDriverPacket = true;
          }
        }
      })
  }

  backToInsurance() {
    this.welcomePage = false;
    this.nextDriverPacket = false;
    this.nextmLogPreview = false;
    this.nextmLogDownload = false;
    this.nextBurseMeeting = false;
    // this.nextBurseFinal = false;
    this.nextInsurance = true;
    this.isInsurance = false;
    this.isDeclaration = true;
    this.nextDeclationUpload = false;
    this.skipUpload = false;
    this.uploadVal = false;
  }

  backToWelcome() {
    this.welcomePage = true;
    this.nextDriverPacket = false;
    this.nextmLogPreview = false;
    this.nextmLogDownload = false;
    this.nextBurseMeeting = false;
    // this.nextBurseFinal = false;
    this.nextInsurance = false;
    this.isDeclaration = false;
    this.nextDeclationUpload = false;
    this.skipUpload = false;
    this.uploadVal = false;
  }

  backTomLog() {
    this.welcomePage = false;
    this.nextDriverPacket = false;
    this.nextmLogPreview = true;
    this.nextmLogDownload = false;
    this.nextBurseMeeting = false;
    // this.nextBurseFinal = false;
    this.isInsurance = false;
    this.nextInsurance = false;
    this.nextDeclationUpload = false;
  }

  backToDeclaration() {
    let status;
    this.welcomePage = false;
    this.nextDriverPacket = false;
    this.nextmLogPreview = false;
    this.nextmLogDownload = false;
    this.nextBurseMeeting = false;
    // this.nextBurseFinal = false;
    // this.isInsurance = false;
    //this.nextInsurance = false;
    //this.skipUpload = true;
    this.uploadVal = false;
    this.packetSent = false;
    let embeddedStatus = sessionStorage.getItem("envelopeId")
    if(embeddedStatus !== null){
        this.CheckStatusPacket();
    }
    driverDetails({
        contactId: this.contactId
      })
      .then((data) => {
        var detailList;
        if (data) {
          detailList = this.proxyToObject(data);
          status = detailList[0].insuranceStatus;
          if (status === 'Uploaded') {
            this.nextDeclationUpload = false;
            this.isDeclaration = false;
            this.nextDeclationUpload = false;
            this.skipUpload = false;
            this.uploadVal = false;
            this.welcomePage = (detailList[0].watchMeetingOnBoarding) ? true : false;
            this.nextInsurance = (!detailList[0].watchMeetingOnBoarding) ? true : false;
            this.isInsurance = (!detailList[0].watchMeetingOnBoarding) ? true : false;
          } else {
            this.nextInsurance = false;
            this.isInsurance = false;
            this.skipUpload = true;
            this.nextDeclationUpload = true;
          }
        }
      })
  }

  takeMeToDashboard() {
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

  renderedCallback() {
    // if (this.renderInitialized) {
    //   return;
    // }
    // this.renderInitialized = true;
    this.callApex();
  }

  showToast(event) {
    this.dispatchEvent(
      new CustomEvent("toast", {
        detail: event.detail
      })
    );
  }

  handleLink(event) {
    console.log("inside handle click")
    this.dispatchEvent(
      new CustomEvent("sentemail", {
        detail: event.detail
      })
    );
  }

}