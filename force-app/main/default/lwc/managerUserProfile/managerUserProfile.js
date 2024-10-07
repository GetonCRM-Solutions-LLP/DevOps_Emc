/* eslint-disable @lwc/lwc/no-api-reassignments */
/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable no-useless-escape */
import complRptDownloadtData from "@salesforce/apex/ManagerDashboardController.complRptDownloadtData";
import getAllDriversLastMonthUnapprovedReimbursementsclone from "@salesforce/apex/ManagerDashboardController.getAllDriversLastMonthUnapprovedReimbursementsclone";
import highRiskDriversDetails from "@salesforce/apex/ManagerDashboardController.highRiskDriversDetails";
import insuranceReport from "@salesforce/apex/ManagerDashboardController.insuranceReport";
import managerContactData from "@salesforce/apex/ManagerDashboardController.managerContactData";
import myTeamDetails from "@salesforce/apex/ManagerDashboardController.myTeamDetails";
import onboardRptDownloadtData from '@salesforce/apex/ManagerDashboardController.onboardRptDownloadtData';
import onboardingStatus from "@salesforce/apex/ManagerDashboardController.onboardingStatus";
import { toDate } from 'c/commonLib';
import { LightningElement, api, wire } from "lwc";
export default class ManagerUserProfile extends LightningElement {
  @api contactId;
  @api accountId;
  @api accName;
  @api isNotify;
  @api valid;
  @api notifyMessageList;
  @api notifyMessage;
  @api role;
  checkAll = false;
  canadaToggle = false;
  driverUnapproveList;
  typeMap = 'USA';
  driverVisibleList;
  driverRiskList;
  driverMileageList;
  driverTeamVisibleList;
  highRiskMileageDriverList;
  highMileageDriverList;
  complianceList;
  insuranceList;
  @api get locationList(){
    return this._locationList;
  }

  set locationList(value) {
    this._locationList = value;
  }

  americanUser;
  canadianUser;
  headerText = '';
  monthText = '';
  vhHeight = (3 / 5 * 100) + '%';
  margin = [0,0,0,0];
  top = 0;
  bottom = 0;
  myTeamList;
  paginatedModal = false;
  navigation = false;
  isFalse = false;
  isTrue = false;
  driverIsUnapprove = false;
  driverIsMyteam = false;
  driverIsHighMileage = false;
  driverIsHighRisk = false;
  isLocation = false;
  
  /*Get parameters from URL*/
  getUrlParamValue(url, key) {
    return new URL(url).searchParams.get(key);
  }

  @wire(onboardingStatus, {
    managerId: "$contactId",
    accountId: "$accountId",
    role: "$role"
  })
  status({ data, error }) {
    if (data) {
      let result = JSON.parse(data);
      if(typeof result === "object"){
        let isEmptyCompliance = Object.keys(result).length;
        this.complianceList = (isEmptyCompliance > 0) ? data : null;
      }
      console.log("compliance status", data);
    } else {
      console.log("complianceStatus", error);
    }
  }

  @wire(insuranceReport, {
    managerId: "$contactId",
    accountId: "$accountId",
    role:"$role"
  })
  insurance({ data, error }) {
    if (data) {
      let result = JSON.parse(data);
      if(typeof result === "object"){
        let isEmptyInsurance = Object.keys(result).length;
        this.insuranceList = (isEmptyInsurance > 0) ? data : null;
      }
      console.log("insuranceList status", JSON.stringify(JSON.parse(this.insuranceList)))
    } else {
      console.log("insuranceList", error);
    }
  }

  @wire(managerContactData, {
    managerId: "$contactId",
    accountId: "$accountId",
    role: "$role"
  })
  managerContactData({ data, error }) {
    if (data) {
      let dataList = this.proxyToObject(data);
      dataList.forEach((el) => {
        el.lat = el.Address__r
          ? el.Address__r.Location_Lat_Long__Latitude__s
          : 0;
        el.lon = el.Address__r
          ? el.Address__r.Location_Lat_Long__Longitude__s
          : 0;
        el.amount =  (el.Fixed_Amount__c) ? '$' + el.Fixed_Amount__c :  '$0.00' ;
        el.address =
          el.MailingCity + ", " + el.MailingState + " " + el.MailingPostalCode;
      });
      this.locationList = dataList;
      this.isLocation = this.locationList.length > 0 ? true : false;
      this.canadianUser = dataList.filter(function(item) {
        return item.Map_Country__c !== null && item.Map_Country__c === 'CANADA';
      });
      this.americanUser = dataList.filter(function(item) {
        return item.Map_Country__c !== 'CANADA';
      });

      this.locationList = (this.canadianUser.length > 0) ? this.americanUser : dataList;
      this.isLocation = this.locationList.length > 0 ? true : false;
      this.canadaToggle = (this.canadianUser.length > 0) ? true : false;
      console.log("Canada drivers###" , this.canadianUser);
      console.log("US drivers###" , this.americanUser);
      console.log("locationList---", this.locationList);
    } else {
      console.log("locationList", error);
    }
  }

  proxyToObject(e) {
    return JSON.parse(e);
  }

  getElement(data, id) {
    var object = {};
    for (let i = 0; i < data.length; i++) {
      if (data[i].contactid === id) {
        object = data[i];
      }
    }
    return object;
  }

  handleMap(event){
    this.checkAll = event.target.checked;
    this.typeMap = (!this.checkAll) ? 'USA' : 'CANADA'
    console.log(this.typeMap, event.target.checked)
    this.locationList = (!this.checkAll) ? this.americanUser : this.canadianUser
    this.template.querySelector('c-point-chloropleth').locate =  this.locationList;
    this.template.querySelector('c-point-chloropleth').type = this.typeMap;
    this.template.querySelector('c-point-chloropleth').reloadChart()
  }


  getLocation(){
   // var tablediv = this.template.querySelector("parent");
    this.navigation = true;
    this.margin = undefined;
    this.top = 10;
    this.bottom = 15;
    this.vhHeight = (3 / 7 * 100) + '%';
    this.paginatedModal = true;
    this.headerText = 'My Team Locations';
  
    // if (this.template.querySelector('c-user-profile-modal')) {
    //       this.template.querySelector('c-user-profile-modal').show();
    //       //if (tablediv.webkitRequestFullscreen) {
    //         //tablediv.webkitRequestFullscreen();
    //     //}
    // }
  }

  exitFullscreen(){
    this.template.querySelector('.parent').classList.remove('overlay-slide-down');
    this.template.querySelector('.parent').classList.add('overlay-slide-up');
    this.paginatedModal = false;
    this.navigation = false;
    this.vhHeight = (3 / 5 * 100) + '%';
    this.margin = [0,0,0,0];
    this.top = 0;
    this.bottom = 0;
  }

  getElementById(data, id) {
    var object = {};
    for (let i = 0; i < data.length; i++) {
      if (data[i].id === id) {
        object = data[i];
      }
    }
    return object;
  }

  handleKeyDown = (event) =>{
    if (event.keyCode === 27) {
       // console.log('Esc key pressed.');
        if(this.paginatedModal){
          this.exitFullscreen();
        }  
    }
   // console.log("keyboard###", event)
  }

  constructor() {
    super();
    this.handleKeyDown = this.handleKeyDown.bind(this);
  }

  modifyView(data){
    for(var i = 0; i < data.length; i++){
      if(data[i].totalMileages > '0.00'){
        data[i].isMileage = true
      }else{
        data[i].isMileage = false
      }
    }

    return data
  }
  

  connectedCallback() {
    const showIsTeam = this.getUrlParamValue(window.location.href, "showteam");
    let team = showIsTeam === "false" ? false : true;
    window.addEventListener('keydown', this.handleKeyDown);
    console.log("Unread", this.valid)
    getAllDriversLastMonthUnapprovedReimbursementsclone({
      accountId: this.accountId,
      contactId: this.contactId,
      showTeam: team,
      role: this.role
    })
      .then((data) => {
        let result = data.replace(/\\'/g, "'");
        this.driverUnapproveList = this.proxyToObject(result);
        this.driverIsUnapprove =
          this.driverUnapproveList.length > 0 ? true : false;
        console.log("driver--", JSON.stringify(this.driverUnapproveList));
        if (this.driverUnapproveList) {
          this.driverUnapproveList = this.modifyView(this.driverUnapproveList);
          this.driverVisibleList =
            this.driverUnapproveList.length > 7
              ? this.driverUnapproveList.slice(0, 7)
              : this.driverUnapproveList;
        }

        console.log("driver---", this.driverUnapproveList);
      })
      .catch((error) => {
        console.log(
          "getAllDriversLastMonthUnapprovedReimbursementsclone error",
          error
        );
      });

    myTeamDetails({
      managerId: this.contactId,
      accountId: this.accountId,
      showteam: team,
      role: this.role
    })
      .then((data) => {
        let result = data.replace(/\\'/g, "'");
        this.myTeamList = this.proxyToObject(result);
        this.driverIsMyteam = this.myTeamList.length > 0 ? true : false;
        if (this.myTeamList) {
          this.driverTeamVisibleList =
            this.myTeamList.length > 14
              ? this.myTeamList.slice(0, 14)
              : this.myTeamList;
        }
        console.log("myTeamDetails List---", data);
      })
      .catch((error) => {
        console.log("myTeamDetails error", error);
      });

      highRiskDriversDetails({
       managerId: this.contactId,
       accountId: this.accountId,
       highMileage: true,
       showTeam: team,
       role: this.role
      })
      .then((data) => {
        if(data !== 'No Trips Found More than 250 miles for this contact'){
          let result = data.replace(/\\'/g, "'");
          this.highMileageDriverList = this.proxyToObject(result);
          this.driverIsHighMileage =
            this.highMileageDriverList.length > 0 ? true : false;
            if (this.highMileageDriverList) {
              this.driverMileageList =
                this.highMileageDriverList.length > 7
                  ? this.highMileageDriverList.slice(0, 7)
                  : this.highMileageDriverList;
            }  
        }

        console.log("highMileageDriversDetails List---", data, team);
       
      })
      .catch((error) => {
        console.log("highMileageDriversDetails error", error);
      });

      highRiskDriversDetails({
        managerId: this.contactId,
        accountId: this.accountId,
        highMileage: false,
        showTeam: team,
        role: this.role
      })
      .then((data) => {
        if(data !== 'No Trips Found More than 250 miles for this contact'){
          let result = data.replace(/\\'/g, "'");
          this.highRiskMileageDriverList = this.proxyToObject(result);
          this.driverIsHighRisk =
            this.highRiskMileageDriverList.length > 0 ? true : false;
            if (this.highRiskMileageDriverList) {
              this.driverRiskList =
                this.highRiskMileageDriverList.length > 14
                  ? this.highRiskMileageDriverList.slice(0, 14)
                  : this.highRiskMileageDriverList;
            }
        }
        console.log("highRiskDriversDetails List---", data);
      })
      .catch((error) => {
        console.log("highRiskDriversDetails error", error);
      });
  }

  navigateToMileage() {
    this.dispatchEvent(
      new CustomEvent("mileage", {
        detail: JSON.stringify(this.driverUnapproveList)
      })
    );
  }

  navigateToTeam() {
    this.dispatchEvent(
      new CustomEvent("team", {
        detail: JSON.stringify(this.myTeamList)
      })
    );
  }

  navigateToFlag(event) {
    let target = event.currentTarget.dataset.id;
    let element = this.getElement(this.driverUnapproveList, target);
    const linkEvent = new CustomEvent("access", {
      detail: { message: JSON.stringify(element), target: 'dashboard'}
    });
    this.dispatchEvent(linkEvent);
  }

  navigateToUser(event) {
    let target = event.currentTarget.dataset.id;
    let element = this.getElementById(this.myTeamList, target);
    const linkEvent = new CustomEvent("userview", {
      detail: { message : JSON.stringify(element), target: 'dashboard' }
    });
    this.dispatchEvent(linkEvent);
  }

  navigateToRisk(event){
    let target = event.currentTarget.dataset.id;
    let element = this.getElementById(this.highRiskMileageDriverList, target);
    const mEvent = new CustomEvent("highriskaccess", {
      detail: JSON.stringify(element)
    });
    this.dispatchEvent(mEvent);
    console.log(event.currentTarget.dataset.id, element)
  }

  navigateToHigh(event){
    let target = event.currentTarget.dataset.id;
    let element = this.getElementById(this.highMileageDriverList, target);
    const mEvent = new CustomEvent("highaccess", {
      detail: JSON.stringify(element)
    });
    this.dispatchEvent(mEvent);
  }

  navigateToHighRiskMileage() {
    this.dispatchEvent(
      new CustomEvent("highrisk", {
        detail: ""
      })
    );
  }

  navigateToHighMileage() {
    this.dispatchEvent(
      new CustomEvent("highmileage", {
        detail: ""
      })
    );
  }

  showAll(){
    this.dispatchEvent(
        new CustomEvent("modal", {
          detail: ''
        })
      );
  }

  dateTime(date){
    var yd, ydd,ymm, yy, hh, min ,sec;
    yd = date
    ydd = yd.getDate();
    ymm = yd.getMonth() + 1;
    yy = yd.getFullYear();
    hh = yd.getHours();
    min = yd.getMinutes();
    sec = yd.getSeconds();
    ydd = (ydd < 10) ? ('0' + ydd) : ydd;
    ymm = (ymm < 10) ? ('0' + ymm) : ymm;
    console.log(ymm + ydd);
    console.log(yy.toString(), hh.toString(), min.toString(), sec.toString());
    return  ymm.toString() + ydd.toString() + yy.toString() + hh.toString() + min.toString() + sec.toString();
 }

  excelToExport(data, file, sheet){
    this.template.querySelector('c-export-excel').download(data, file, sheet);
  }

  getComplianceReport(){
    let mileage = [];
    let fileName = (this.accName == '' ? '' : this.accName + ' ') + 'Compliance Status Report ' + this.dateTime(new Date())
    let sheetName = 'Compliance Report';
    complRptDownloadtData({
      managerId: this.contactId,
      accountId: this.accountId,
      role: this.role
    }).then((data) => {
        if (data) {
          let excelList = JSON.parse(data);
          mileage.push(["Name", "Email","Compliance Status", "Active Driver"])
          excelList.forEach((item)=>{
              mileage.push([item.Name.replace(/\\'/g, "\'"), item.Email, item.monthly_compliance_status__c, item.isActive__c])
          })
          let sortedMileages = this.sortInsuranceComplianceSheet(mileage, 'compliance');
          this.excelToExport(sortedMileages, fileName, sheetName);
        }
      })
      .catch((error) => {
        console.log("complaince report error", JSON.stringify(error));
      });
  
  }

  getOnboardingReport(){
    let mileage = [];
    let fileName = (this.accName == '' ? '' : this.accName + ' ') + 'Onboarding Status Report ' + this.dateTime(new Date())
    let sheetName = 'Onboarding Status Report';
    onboardRptDownloadtData({
      managerId: this.contactId,
      accountId: this.accountId,
      role: this.role
    }).then((data) => {
        if (data) {
          console.log("Onboarding --->", data);
          let excelList = JSON.parse(data);
          mileage.push(["Name", "Email","Completed Onboarding", "Insurance", "Driver Signed",	"Admin Signed",	"Watched Driver Meeting",	"Activation Date",	"Active Driver"])
          excelList.forEach((item)=>{
              mileage.push([item.Name.replace(/\\'/g, "\'"), item.Email, item.Onboarding_Status__c, item.Insurance__c, item.Hello_Sign_Status__c, item.Hello_Sign_Admin_Status__c, (item.Schedule_Driver_Meeting__c) ? 'Yes' : 'No', (item.Activation_Date__c !== undefined) ? toDate(item.Activation_Date__c) : "" , item.isActive__c])
          })
          let sortedMileages = this.sortOnboardingSheet(mileage);
          this.excelToExport(sortedMileages, fileName, sheetName);
        }
      })
      .catch((error) => {
        console.log("complaince report error", JSON.stringify(error));
      });
  }

  sortOnboardingSheet(data) {
    let sortedData = data.slice(1);
    const insuranceStatus = {
      "Expired": 1,
      "Insurance Card": 2,
      "Missing Insurance Dec Page": 3,
      "Missing Umbrella Policy": 4,
      "No Expiration Date": 5,
      "Not Meeting Plan Minimum": 6,
      "Not Submitted": 7,
      "Under Review": 8,
      "Yes": 9
    };
    const onboardingStatus = {
      "No": 1,
      "Yes": 2
    };
    const signStatus = {
      "awaiting_signature": 1,
      "signed": 2
    }

    sortedData.sort((a, b) => {
      if(a[2] === b[2]) {
        if(a[3] == null && b[3] == null) {
          return a[0].localeCompare(b[0]);
        } else if(a[3] == null) {
          return 1;
        } else if(b[3] == null) {
          return -1;
        } else {
          if(a[3] === b[3]) {
            if(a[4] == null && b[4] == null) {
              return a[0].localeCompare(b[0]);
            } else if(a[4] == null) {
              return 1;
            } else if(b[4] == null) {
              return -1;
            } else {
              if(a[4] === b[4]) {
                if(a[5] == null && b[5] == null) {
                  return a[0].localeCompare(b[0]);
                } else if(a[5] == null) {
                  return 1;
                } else if(b[5] == null) {
                  return -1;
                } else {
                  if(a[5] === b[5]) {
                    return a[0].localeCompare(b[0]);
                  } else {
                    return signStatus[a[5]] - signStatus[b[5]];
                  }
                }
              } else {
                return signStatus[a[4]] - signStatus[b[4]];
              }
            }
          } else {
            return insuranceStatus[a[3]] - insuranceStatus[b[3]];
          }
        }
      } else {
        return onboardingStatus[a[2]] - onboardingStatus[b[2]];
      }
    });

    sortedData.unshift(data[0]);
    return sortedData;
  }

  getInsuranceReport(){
    let insuranceList = [];
    let fileName = (this.accName == '' ? '' : this.accName + ' ') + 'Insurance Status Report ' + this.dateTime(new Date())
    let sheetName = 'Insurance Report';
    onboardRptDownloadtData({
      managerId: this.contactId,
      accountId: this.accountId,
      role: this.role
    }).then((data) => {
        if (data) {
          let excelList = JSON.parse(data);
          insuranceList.push(["Name", "Email","Insurance Status", "Expires"])
          excelList.forEach((item)=>{
            insuranceList.push([item.Name.replace(/\\'/g, "\'"), item.Email, item.Insurance__c, (item.Expiration_Date__c !== undefined) ? toDate(item.Expiration_Date__c) : item.Expiration_Date__c])
          })
          let sortedInsuranceList = this.sortInsuranceComplianceSheet(insuranceList, 'insurance');
          this.excelToExport(sortedInsuranceList, fileName, sheetName);
        }
      })
      .catch((error) => {
        console.log("complaince report error", JSON.stringify(error));
      });
  }

  sortInsuranceComplianceSheet(data, reportType) {
    let sortedData = data.slice(1);
    const insuranceStatus = {
      "Expired": 1,
      "Insurance Card": 2,
      "Missing Insurance Dec Page": 3,
      "Missing Umbrella Policy": 4,
      "No Expiration Date": 5,
      "Not Meeting Plan Minimum": 6,
      "Not Submitted": 7,
      "Under Review": 8,
      "Yes": 9
    };
    const compliancestatus = {
      "Expired Insurance": 1,
      "No – Insurance Card": 2,
      "No - Insurance Dec Page": 3,
      "No – Insurance Not Meeting Minimum": 4,
      "No - Insurance Not Provided": 5,
      "No - Mileage": 6,
      "No - Mileage & Insurance": 7,
      "No - Mileage & Vehicle Age": 8,
      "No - Mileage & Vehicle Value": 9,
      "No - Missing Coverage Dates": 10,
      "No - Umbrella Policy": 11,
      "No – Vehicle Age": 12,
      "No – Vehicle Value": 13,
      "Pending" : 14,
      "Yes": 15
    };
    const statusOrder = (reportType == 'insurance' ? insuranceStatus : compliancestatus);

    sortedData.sort((a, b) => {
      if (a[2] == null && b[2] == null) {
        return a[0].localeCompare(b[0]);
      } else if (a[2] == null) {
        return 1;
      } else if (b[2] == null) {
        return -1;
      } else {
        return a[2] === b[2] ? a[0].localeCompare(b[0]) : statusOrder[a[2]] - statusOrder[b[2]];
      }
    });

    sortedData.unshift(data[0]);
    return sortedData;
  }

  handleClose(event) {
    var eId = event.currentTarget.dataset.id;
    this.dispatchEvent(
        new CustomEvent("close", {
          detail: eId
        })
      );
  }

  // renderedCallback(){
  //   console.log("from---", this.keyCode, this._keyCode)
  //   if(this._keyCode !== undefined){
  //     if (this._keyCode === 27) {
  //       // console.log('Esc key pressed.');
  //        if(this.paginatedModal === true){
  //          this.exitFullscreen();
  //        }  
  //    }
  //   }
    
  // }
}