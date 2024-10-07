import { LightningElement, api } from 'lwc';
import driverDetails from '@salesforce/apex/NewAccountDriverController.getContactDetail';
export default class UserUploadInsurance extends LightningElement {
    @api insuranceVideo;
    @api videoStyle;
    @api contentStyle;
    contactId;
    accountId;
    managerId;
    showTeam;
    contactName;
    contactEmail;
    attachmentid;
    mBurseCheck;
    information;
    dashboardUrl;
    uploadUrl;
    mileageUrl;
    communicateUrl;
    myDetailUrl;
    rosterUrl;
    reportUrl;
    showDashBoard = false;
    insuranceExpired = false;
    uploadVal = false;
    nextDeclationUpload = false;
    isDriver = false;
    isDriverManager = false;
    isAdminDriver = false;
    isManagerDriver = false;
    plAccount = false;
    renderUrl = false;

    /* Get url parameters */
    getUrlParamValue(url, key) {
            return new URL(url).searchParams.get(key);
    }

    proxyToObject(e) {
        return JSON.parse(e)
    }

  /* Function to call apex method */
  callApex() {
    driverDetails({
        contactId: this.contactId
      })
      .then((data) => {
        var driverDetailList, expirationDate, Today;
        if (data) {
          console.log("getContactDetail",data);
          this.information = data;
          driverDetailList = this.proxyToObject(data);
          this.attachmentid = driverDetailList[0].insuranceId;
          this.contactName = driverDetailList[0].contactFirstName;
          this.contactEmail = driverDetailList[0].contactEmail;
          this.mBurseCheck = driverDetailList[0].mburseDashboard;
          Today = (new Date()).setHours(0,0,0,0);
          expirationDate = driverDetailList[0].insuranceExpirationDate;
           //(new Date(expirationDate) <= Today ? true : false)
          this.insuranceExpired = (expirationDate == null) ? false : ((new Date(expirationDate)).setHours(0,0,0,0) <= Today ? true : false);
          // if (this.mBurseCheck === false) {
          //   if (this.role === 'Driver') {
          //       if (this.attachmentid == null) {
          //         this.showDashBoard = false;
          //       } else {
          //         this.showDashBoard = true;
          //       }
          //   }else{
          //     this.showDashBoard = true;
          //   }
          // } else {
          //   this.showDashBoard = true;
          // }
        }
      })
      .catch((error) => {
        console.log('Error', error)
      })
  }

  /* redirect to upload insurance */
  navigateToDeclaration(){
      this.nextDeclationUpload = true;
      this.uploadVal = true;
  }

  backToInsurance(){
      this.nextDeclationUpload = false;
      this.uploadVal = false;
  }

  /* replace string in url */
  replaceString(str, replace, v, replaceChar){
    return str.replace(`${replace}=${v}&`, replaceChar);
  }

  navigateToDashboard(){
    this.dispatchEvent(
          new CustomEvent("revert", {
            detail: "insurance"
          })
        );
  }

  connectedCallback(){
    const idParamValue = this.getUrlParamValue(window.location.href, 'id');
    const aidParamValue = this.getUrlParamValue(window.location.href, 'accid');
    this.contactId = idParamValue;
    this.accountId = aidParamValue;
    this.callApex();
  }
}