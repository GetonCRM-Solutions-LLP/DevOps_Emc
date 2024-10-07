import { LightningElement,api } from 'lwc';
import redirectionURL  from '@salesforce/apex/NewAccountDriverController.loginRedirectionADMD';
import driverDetails from '@salesforce/apex/NewAccountDriverController.getContactDetail';
import emcCss from '@salesforce/resourceUrl/EmcCSS';
export default class DashboardUploadInsurance extends LightningElement {
   @api role;
   @api manRole;
   @api pLMarketing;
   @api insuranceVideo;
   insuranceExpired = false;
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
    uploadVal = false;
    nextDeclationUpload = false;
    isDriver = false;
    isDriverManager = false;
    isAdminDriver = false;
    isManagerDriver = false;
    plAccount = false;
    renderUrl = false;
    companyLogoUrl = emcCss + '/emc-design/assets/images/logo/mBurse-logo.png';
    isHomePage = false;
  
    /* Get url parameters */
    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }

    proxyToObject(e) {
        return JSON.parse(e)
    }

 
    /* hide show links based on roles */
    renderLink(){
      this.isDriverManager = (this.role === 'Driver/Manager' || this.manRole === 'Driver/Manager') ? true : false;
      this.isAdminDriver = (this.role === 'Driver/Admin' && this.managerId === null && this.manRole !== 'Driver/Manager') ? true : false;
      this.isManagerDriver = (this.role === 'Driver/Admin' && this.managerId !== null && this.manRole !== 'Driver/Manager') ? true : false;
      this.isDriver = (this.role === 'Driver') ? true : false;
    }

    handleLogout(){
      // eslint-disable-next-line no-restricted-globals
      location.href = '/app/secur/logout.jsp';
    }

    /* Function to call apex method */
    callApex() {
        driverDetails({
            contactId: this.contactId
          })
          .then((data) => {
            var driverDetailList, Today, expirationDate;
            if (data) {
              console.log("getContactDetail",data);
              this.information = data;
              driverDetailList = this.proxyToObject(data);
              this.attachmentid = driverDetailList[0].insuranceId;
              this.contactName = driverDetailList[0].contactFirstName;
              this.contactEmail = driverDetailList[0].contactEmail;
              Today = (new Date()).setHours(0,0,0,0);
              expirationDate = driverDetailList[0].insuranceExpirationDate;
               //(new Date(expirationDate) <= Today ? true : false)
              this.insuranceExpired = (expirationDate == null) ? false : ((new Date(expirationDate)).setHours(0,0,0,0) <= Today ? true : false);
              console.log("insurance expiration", this.insuranceExpired, expirationDate, typeof expirationDate)
              this.mBurseCheck = driverDetailList[0].mburseDashboard;
              if (this.mBurseCheck === false) {
                if (this.role === 'Driver') {
                    if (this.attachmentid == null) {
                      this.showDashBoard = false;
                    } else {
                      this.showDashBoard = true;
                    }
                }else{
                  this.showDashBoard = true;
                }
              } else {
                this.showDashBoard = true;
              }
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

      /* navigate to dashboard portal */
      navigateToDashboard(){
        redirectionURL({contactId: this.contactId, adminTab: false})
        .then((result) => {
          console.log("Result", result)
            let url = window.location.origin + result;
            window.open(url, '_self');
        })
      }

      backToInsurance(){
          this.nextDeclationUpload = false;
          this.uploadVal = false;
      }

      /* replace string in url */
      replaceString(str, replace, v, replaceChar){
        return str.replace(`${replace}=${v}&`, replaceChar);
      }

      refreshPage(){
        window.location.reload();
      }

      connectedCallback() {
        const idParamValue = this.getUrlParamValue(window.location.href, 'id');
        const aidParamValue = this.getUrlParamValue(window.location.href, 'accid');
        // const managerID = this.getUrlParamValue(window.location.href, 'managerid');
        // const manID = this.getUrlParamValue(window.location.href, 'manid');
        // const team = this.getUrlParamValue(window.location.href, 'showteam');
        this.isHomePage = true;
        this.contactId = idParamValue;
        this.accountId = aidParamValue;
        // this.managerId = managerID;
        // this.manId = manID;
        // this.showTeam = team;
        // this.plAccount = (this.accountId === this.pLMarketing) ? true : false;
        this.callApex();

        //this.renderLink();
        console.log(this.role , this.manRole)
        // if(this.role === 'Driver/Admin' && this.managerId != null && this.manRole === ''){
        //   this.dashboardUrl = '/app/admindriverdashboard' + this.replaceString(window.location.search, 'managerid', this.managerId,'');
        // } else 
        /* (this.role === 'Driver/Manager' || this.role === 'Manager') && (this.manRole === 'Manager' || this.manRole === 'Driver/Manager')*/
        /** Communication Link 
         *  Visible to pl marketing account
        */
        // if (this.managerId != null || this.manId != null) { 
        //   if (this.plAccount) {
        //     this.renderUrl = true;
        //   } else {
        //     this.renderUrl = false;
        //   }
        // }else{
        //   if(this.role === 'Driver/Manager' || this.role === 'Manager'){
        //     this.renderUrl = false;
        //   }else{
        //     this.renderUrl = true;
        //   }
        // }

        // if(this.role === 'Driver/Admin' && this.managerId != null){
        //   /* When Login as manger from roster page */
        //   this.dashboardUrl = '/app/managerdashboardfromadmindriver' + window.location.search;
        // }else if((this.role === 'Driver/Admin' || this.role === 'Admin' ) && this.manId != null && this.manRole === 'Driver/Manager'){
        //    /* When Login as driver/manger from roster page */
        //   this.dashboardUrl = '/app/drivermanagerdriverdetails?accid=' + this.accountId + '&id=' + this.manId + '&manid=' + this.contactId + '&showteam=' +  this.showTeam + '&loginAS=true';
        // }else if(this.role === 'Driver/Manager' && this.manId != null && this.manRole !== 'Driver/Manager'){
        //   this.dashboardUrl = '/app/drivermanagerdashboard' + this.replaceString(window.location.search, 'manid', this.manId,'');
        // }else{
        //   this.dashboardUrl = ((this.role === 'Driver' ) ? '/app/driverDashboardClone' : (this.role === 'Driver/Admin' && this.managerId === null ) ? '/app/admindriverdashboard' : '/app/drivermanagerdashboard') + window.location.search;
        // }
        // /* Url for Upload Insurance Button */
        // this.uploadUrl = '/app/uploadInsurance' + window.location.search;
        //   /* Url for Upload Insurance Button */
        // this.mileageUrl = '/app/MileageDashboard' + window.location.search;
        // if(this.manId != null){
        //   this.communicateUrl = '/app/ManageNotification' + this.replaceString(window.location.search,'manid',this.manId,`managerid=${this.manId}&`);
        // }else{
        //   this.communicateUrl = '/app/ManageNotification' + window.location.search;
        // }
        // this.myDetailUrl = '/app/driveradminmanagermydetail' + window.location.search;
        // this.rosterUrl = '/app/roster' + window.location.search;
        // this.reportUrl = '/app/reportlist' + window.location.search;
      }
      renderedCallback(){
        //this.template.querySelector('c-m-burse-navbar').addUrl();
      }
}