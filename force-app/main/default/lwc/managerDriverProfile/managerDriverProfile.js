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
  activationDate;
  tripView = false;
  archive = false;
  ytdList;
  excelYtdList;
  mileageList;
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
    const toast = { message: 'No mileage', type: 'error' }
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

  proxyToObject(el) {
    this.evt = el;
    return JSON.parse(this.evt);
  }



  showSpinner(event) {
    this.dispatchEvent(
        new CustomEvent("profile", {
                detail: event.detail
        })
    );
  }

  myTripDetail(event) {
    this.biweek = event.detail.boolean;
    if (event.detail.boolean) {
        if (event.detail.boolean === false) {
            this.monthOfTrip = event.detail.month;
            this.yearOfTrip = event.detail.year;
            this.tripView = true;
        } else {
            const listVal = event.detail.trip;
            this.startDt = listVal.startDate;
            this.endDt = listVal.endDate;
            this.biweekId = listVal.id;
            this.tripView = true;
        }
    }
  }


  revertHandler(){
    const backTo = (this.redirectDashboard) ? 'Dashboard' : '';
    this.dispatchEvent(
        new CustomEvent("back", {
            detail: backTo
        })
    );
  }

  connectedCallback() {
    const currentDay = new Date(), first = 1, index = 0;
    let currentYear = "", selectedYear = "";
    this.currentDate = validateDate(new Date());
    this.isHomePage = false;
    if (currentDay.getMonth() === index) {
      currentYear = currentDay.getFullYear() - first;
      selectedYear = currentYear.toString();
    } else {
      currentYear = currentDay.getFullYear();
      selectedYear = currentYear.toString();
    }

  
    getAllReimbursements({
      accountId: this.accountId,
      contactId: this.contactId,
      year: selectedYear
    })
      .then((result) => {
        const reimbursementList = this.proxyToObject(result[index]);
        this.mileageList = reimbursementList;
        this.excelYtdList = this.proxyToObject(result[first]);
        this.ytdList = this.proxyToObject(result[first]);
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
        getDriverDetails({
          contactId: this.contactId
        })
          .then((data) => {
            if (data) {
              const contactList = this.proxyToObject(data);
              this.contactInformation = data;
              this.userTriplogId = contactList[index].Triplog_UserID__c;
              this.userEmail = contactList[index].External_Email__c;
              this.userName = contactList[index].Name;
              this.firstName = contactList[index].FirstName;
              this.dateOfExpiration = contactList[index].Expiration_Date__c;
              this.activationDate = contactList[index].Activation_Date__c;
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