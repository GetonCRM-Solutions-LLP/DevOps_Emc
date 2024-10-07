import { LightningElement, track, api } from "lwc";
import getAllReimbursements from "@salesforce/apex/DriverDashboardLWCController.getAllReimbursements";
import getDriverDetails from '@salesforce/apex/DriverDashboardLWCController.getDriverDetailsClone';
import {
    toastEvents
} from 'c/utils';
import { validateDate } from "c/commonLib";
export default class ManagerDriverProfile extends LightningElement {
  @track isTrip = true;
  @track isAttendance = false;
  @api contactId;
  @api accountId;
  @api redirectDashboard;
  @api role;
  tripView = false;
  archive = false;
  ytdList;
  excelYtdList;
  mileageList;
  _contactId;
  _accountId;
  startDt;
  endDt;
  biweekId;
  userTriplogId;
  contactInformation;
  userEmail;
  userName;
  firstName;
  dateOfExpiration;

  handleToast() {
    let toast = { type: 'error', message: 'No mileage' }
    toastEvents(this, toast);
  }

  handleToastEvent(event){
    toastEvents(this, event.detail);
  }

  revertToReimbursement() {
    this.isAttendance = false;
    this.isTrip = true;
    this.tripView = false;
  }

  proxyToObject(e) {
    return JSON.parse(e);
  }



  showSpinner(event) {
    console.log("navigate spin")
    this.dispatchEvent(
        new CustomEvent("profile", {
                detail: event.detail
        })
    );
  }

  myTripDetail(event) {
    this.biweek = event.detail.boolean;
    console.log("biweek", this.biweek)
    if (event.detail.boolean !== undefined) {
        if (event.detail.boolean === false) {
            this.monthOfTrip = event.detail.month;
            this.yearOfTrip = event.detail.year;
            this.tripView = true;
        } else {
            let listVal = event.detail.trip;
            this.startDt = listVal.startDate;
            this.endDt = listVal.endDate;
            this.biweekId = listVal.id;
            this.tripView = true;
        }
    }
  }


  revertHandler(){
    let backTo = (this.redirectDashboard) ? 'Dashboard' : '';
    this.dispatchEvent(
        new CustomEvent("back", {
            detail: backTo
        })
    );
  }

  connectedCallback() {
    var currentDay = new Date(),
      currentYear = "",
      selectedYear = "";
    this.currentDate = validateDate(new Date());
    //this.currentDate = 'null';
    console.log("contactId", this.contactId)
    this._contactId = this.contactId;
    this._accountId = this.accountId;
    this.isHomePage = false;
    if (currentDay.getMonth() === 0) {
      currentYear = currentDay.getFullYear() - 1;
      selectedYear = currentYear.toString();
    } else {
      currentYear = currentDay.getFullYear();
      selectedYear = currentYear.toString();
    }

  
    getAllReimbursements({
      year: selectedYear,
      contactId: this._contactId,
      accountId: this._accountId
    })
      .then((result) => {
        let reimbursementList = this.proxyToObject(result[0]);
        this.mileageList = reimbursementList;
        this.excelYtdList = this.proxyToObject(result[1]);
        this.ytdList = this.proxyToObject(result[1]);
        if (this.ytdList) {
          this.ytdList.varibleAmountCalc = this.ytdList.varibleAmountCalc
            ? this.ytdList.varibleAmountCalc.replace(/\$/g, "")
            : this.ytdList.varibleAmountCalc;
          this.ytdList.totalReim = this.ytdList.totalReim
            ? this.ytdList.totalReim.replace(/\$/g, "")
            : this.ytdList.totalReim;
          this.ytdList.totalMonthlyFixedCalc = this.ytdList
            .totalMonthlyFixedCalc
            ? this.ytdList.totalMonthlyFixedCalc.replace(/\$/g, "")
            : this.ytdList.totalMonthlyFixedCalc;
          this.ytdList.totalAVGCalc = this.ytdList.totalAVGCalc
            ? this.ytdList.totalAVGCalc.replace(/\$/g, "")
            : this.ytdList.totalAVGCalc;
        }
        console.log("getAllReimbursement", result);
        getDriverDetails({
          contactId: this._contactId
        })
          .then((data) => {
            if (data) {
              let contactList = this.proxyToObject(data);
              this.contactInformation = data;
              console.log("contact--->", this.contactInformation);
              this.userTriplogId = contactList[0].Triplog_UserID__c;
              this.userEmail = contactList[0].External_Email__c;
              this.userName = contactList[0].Name;
              this.firstName = contactList[0].FirstName;
              this.dateOfExpiration = contactList[0].Expiration_Date__c;
              console.log("Name", this.userName, this.userEmail);
              // this.driverNotification(contactList[0].Notification_Message__c, contactList[0].Notification_Date__c, contactList[0].Insurance_Upload_Date__c);
            }
          })
          .catch((error) => {
            console.log("getDriverDetails error", error.message);
          });
      })
      .catch((error) => {
        console.log("getAllReimbursements error", error);
      });
  }
}