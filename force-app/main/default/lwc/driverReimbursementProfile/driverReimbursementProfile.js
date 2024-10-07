/* eslint-disable @lwc/lwc/no-api-reassignments */
import { LightningElement, api, wire } from "lwc";
import carImage from "@salesforce/resourceUrl/EmcCSS";
import resourceImage from "@salesforce/resourceUrl/mBurseCss";
import getMileages from "@salesforce/apex/DriverDashboardLWCController.getMileages";
import sendDrivingStateEmail from "@salesforce/apex/DriverDashboardLWCController.sendDrivingStateEmail";
import getGasPriceandRate from "@salesforce/apex/DriverDashboardLWCController.getGasPriceandRate";
import getAllReimbursements from "@salesforce/apex/DriverDashboardLWCController.getAllReimbursements";
import getReimbursementData from "@salesforce/apex/DriverDashboardLWCController.getReimbursementData";
import getFuelVariableRate from "@salesforce/apex/DriverDashboardLWCController.getFuelVariableRate";
import getPacketandMeeting from "@salesforce/apex/DriverDashboardLWCController.getPacketandMeeting";
import getDrivingState from "@salesforce/apex/DriverDashboardLWCController.getDrivingState";
import getDrivingStates from '@salesforce/apex/DriverDashboardLWCController.getDrivingStates';
import updateStateList from "@salesforce/apex/DriverDashboardLWCController.updateStateList";
import canadaStates from '@salesforce/label/c.canada_driving_states';
import usaDrivingStates from '@salesforce/label/c.usa_driving_states';
import { refreshApex } from '@salesforce/apex';
import UpdateReimbursementStatus from "@salesforce/apex/DriverDashboardLWCController.UpdateReimbursementStatus";
import TripCallout from "@salesforce/apex/DriverDashboardLWCController.TripCallout";
import { events, openEvents, toastEvents, toggleEvents } from "c/utils";
export default class DriverReimbursementProfile extends LightningElement {
  @api driverDetails;
  @api activationDate;
  @api roleUser = '';
  contactName = '';
  @api isArchive;
  profileCarImage = carImage + "/emc-design/assets/images/2022-envision-mov-avenir-trim.png";
  milesIcon = resourceImage + "/mburse/assets/mBurse-Icons/Middle-block/1.png";
  moneyIcon = resourceImage + "/mburse/assets/mBurse-Icons/Middle-block/2.png";
  variableRateIcon =
    resourceImage + "/mburse/assets/mBurse-Icons/Middle-block/3.png";
  fuelIcon = resourceImage + "/mburse/assets/mBurse-Icons/Middle-block/4.png";
  searchIcon = resourceImage + "/mburse/assets/mBurse-Icons/Vector.png";
  loader = resourceImage + '/mburse/assets/mBurse-Icons/mburse-sync-loading.gif';
  loader2 = resourceImage + '/mburse/assets/mBurse-Icons/Bar-style.gif';
  wiredReimList;
  videoPlanUrl = 'https://hubs.ly/Q02qn4TG0';
  headerText = "";
  daysAfterActivation;
  modalLength = false;
  isSelectedState = false;
  ytd = false;
  spinner = false;
  biweekYtd = false;
  multipleMap = false;
  checkAll = false;
  isChecked = false;
  isLastChecked = false;
  isActiveSync = true;
  isDrivingState = false;
  isDrivingSt = false;
  _value = "";
  loaderPlaceholder = '';
  loaderIcon = '';
  isSearchEnable = true;
  typeMap = 'USA';
  monthText = "";
  canadaStatesList = '';
  usaDrivingStates = '';
  usStatesList = '';
  mapCountry = '';
  headerName = '';
  lastMonth = "";
  drivingTitle = "";
  thisMonth = "";
  thismonthAbbr = "";
  lastmonthAbbr = "";
  vehicleType = "";
  isIRS = false;
  isNotIRS = false;
  isSync =  false;
  year = "";
  address = "";
  insuranceRate = "";
  maintenance = "";
  variablefuelprice = "";
  states = "";
  tires = "";
  miles = "";
  license = "";
  taxes = "";
  depreciation = "";
  totalCost = "";
  businessUse = "";
  totalMonthlyAmount = "";
  fixedCostAdjustment = "";
  totalMonthlyFixedCost = "";
  percent = "";
  vehicleImage;
  accordionList;
  hrBorder;
  titleOfAccordion = "2022 Reimbursement Data";
  messageForNextBatch = "";
  isSortable = false;
  isScrollable = true;
  isValid = false;
  isFalse = false;
  isTrue = true;
  isIcon = false;
  myPlanInfo = false;
  myTA = false;
  lengthOfContact = false;
  packetStatus1 = false;
  packetStatus2 = false;
  packetStatus3 = false;
  packetStatus4 = false;
  meetingStatus1 = false;
  meetingStatus2 = false;
  meetingStatus3 = false;
  colname="name";
  coltype="String";
  sortorder="desc";
  attachmentInsurance;
  templateName = "";
  lastMonthMiles = "";
  thisMonthMiles = "";
  halfFixedAmount = "";
  fixedAmount = "";
  variableRate = "";
  monthfuelPrice = "";
  lastMonthMileageRate = "";
  lastMilesZero = "";
  thisMilesZero = "";
  halfFixedZero = "";
  fixedAmountZero = "";
  fuelPriceZero = "";
  mileageRateZero = "";
  thisFuelPrice =  0;
  reimIdThisMonth = '';
  reimIdLastMonth = '';
  maintainsAndTyresThisMonth = '';
  maintainsAndTyresLastMonth = '';
  mpgThisMonth = '';
  mpgLastMonth = '';
  validStateList = [];
  addedDrivingState = [];
  listOfAddedState = [];
  lastModelList;
  originalModelList;
  modalKeyFields;
  modalListColumn;
  lastMonthColumn = [
    {
      id: 1,
      name: "Trip date",
      colName: "tripdate",
      colType: "Date",
      arrUp: true,
      arrDown: false
    },
    {
      id: 2,
      name: "Origin",
      colName: "originname",
      colType: "String",
      arrUp: false,
      arrDown: false
    },
    {
      id: 3,
      name: "Destination",
      colName: "destinationname",
      colType: "String",
      arrUp: false,
      arrDown: false
    },
    {
      id: 4,
      name: "Submitted",
      colName: "submitteddate",
      colType: "Date",
      arrUp: false,
      arrDown: false
    },
    {
      id: 5,
      name: "Approved",
      colName: "approveddate",
      colType: "Date",
      arrUp: false,
      arrDown: false
    },
    {
      id: 6,
      name: "Mileage",
      colName: "mileage",
      colType: "Decimal",
      arrUp: false,
      arrDown: false
    },
    {
      id: 7,
      name: "Variable Amount",
      colName: "variableamount",
      colType: "Decimal",
      arrUp: false,
      arrDown: false
    }
  ];
  lastMonthKeyFields = [
    "tripdate",
    "originname",
    "destinationname",
    "submitteddate",
    "approveddate",
    "mileage",
    "variableamount"
  ];
  thisMonthColumn = [
    {
      id: 1,
      name: "Trip date",
      colName: "tripdate",
      colType: "Date",
      arrUp: true,
      arrDown: false
    },
    {
      id: 2,
      name: "Origin",
      colName: "originname",
      colType: "String",
      arrUp: false,
      arrDown: false
    },
    {
      id: 3,
      name: "Destination",
      colName: "destinationname",
      colType: "String",
      arrUp: false,
      arrDown: false
    },
    {
      id: 4,
      name: "Mileage",
      colName: "mileage",
      colType: "Decimal",
      arrUp: false,
      arrDown: false
    }
  ];
  thisMonthKeyFields = ["tripdate", "originname", "destinationname", "mileage"];
  gasPriceColumn = [
    {
      id: 1,
      name: "",
      colName: "ReimMonth",
      colType: "String",
      arrUp: false,
      arrDown: false
    },
    {
      id: 2,
      name: "Gas Prices",
      colName: "fuelPrice",
      colType: "Decimal",
      arrUp: false,
      arrDown: false
    },
    {
      id: 3,
      name: "Mileage Rate",
      colName: "VariableRate",
      colType: "Decimal",
      arrUp: false,
      arrDown: false
    }
  ];
  gasPriceKeyFields = ["ReimMonth", "fuelPrice", "VariableRate"];

  gasPriceIRSColumn = [
    {
      id: 1,
      name: "",
      colName: "ReimMonth",
      colType: "String",
      arrUp: false,
      arrDown: false
    },
    {
      id: 2,
      name: "Mileage Rate",
      colName: "VariableRate",
      colType: "Decimal",
      arrUp: false,
      arrDown: false
    }
  ];
  gasPriceIRSKeyFields = ["ReimMonth", "VariableRate"];
  biweekKeyFields = [
    "month",
    "variableRate",
    "mileage",
    "varibleAmount",
    "fixed1",
    "fixed2",
    "fixed3",
    "totalReimbursements",
    "avgToDate"
  ];
  biweekColumn = [
    {
      id: 1,
      name: "",
      colName: "month"
    },
    {
      id: 2,
      name: "Mi Rate",
      colName: "variableRate"
    },
    {
      id: 3,
      name: "Mileage",
      colName: "mileage"
    },
    {
      id: 4,
      name: "Variable",
      colName: "varibleAmount"
    },
    {
      id: 5,
      name: "Fixed 1",
      colName: "fixed1"
    },
    {
      id: 6,
      name: "Fixed 2",
      colName: "fixed2"
    },
    {
      id: 7,
      name: "Fixed 3",
      colName: "fixed3"
    },
    {
      id: 8,
      name: "Total",
      colName: "totalReimbursements"
    },
    {
      id: 9,
      name: "Avg to Date",
      colName: "avgToDate"
    }
  ];

  monthKeyFields = [
    "month",
    "fuel",
    "mileage",
    "variableRate",
    "varibleAmount",
    "fixedAmount",
    "totalReimbursements",
    "avgToDate"
  ];

  monthColumn = [
    {
      id: 1,
      name: "",
      colName: "month"
    },
    {
      id: 2,
      name: "Fuel",
      colName: "fuel"
    },
    {
      id: 3,
      name: "Mileage",
      colName: "mileage"
    },
    {
      id: 4,
      name: "Mi Rate",
      colName: "variableRate"
    },
    {
      id: 5,
      name: "Variable",
      colName: "varibleAmount"
    },
    {
      id: 6,
      name: "Fixed",
      colName: "fixedAmount"
    },
    {
      id: 7,
      name: "Total",
      colName: "totalReimbursements"
    },
    {
      id: 8,
      name: "Avg to Date",
      colName: "avgToDate"
    }
  ];
  paginatedModal = false;
  biweekly = false;
  @api contactId;
  @api accountId;
  @api timeAttendance;
  @api myTrip;
  @api reimbursementYtd;
  @api excelYtd;

  @api styleElement(value) {
    if (value === "sidebar close") {
      // this.template.querySelector('.map-state').classList.add('slds-p-left_x-large');
      this.template
        .querySelector(".map-state")
        .classList.add("slds-p-left_large");
      this.template.querySelector(".choropleth").style.left = "40%";
    } else {
      this.template
        .querySelector(".map-state")
        .classList.remove("slds-p-left_large");
      this.template.querySelector(".choropleth").style.left = "35%";
    }
  }

  proxyToObject(e) {
    return JSON.parse(e);
  }

  @wire(getReimbursementData, {
    contactId: "$contactId"
  })
  reimbursementData(wireResult) {
    const { data, error } = wireResult;
    this.wiredReimList = wireResult;
    if (data) {
      let reimbursementData = this.proxyToObject(data);
      this.lastMilesZero =
        reimbursementData.lastmonthmiles !== "0.00" &&
        /^0+/.test(reimbursementData.lastmonthmiles) === true
          ? reimbursementData.lastmonthmiles.replace(/^0+/, "")
          : null;
      this.thisMilesZero =
        reimbursementData.currentmonthmiles !== "0.00" &&
        /^0+/.test(reimbursementData.currentmonthmiles) === true
          ? reimbursementData.currentmonthmiles.replace(/^0+/, "")
          : null;
      this.halfFixedZero =
        reimbursementData.halfFixedAmount !== "0.00" &&
        /^0+/.test(reimbursementData.halfFixedAmount) === true
          ? reimbursementData.halfFixedAmount.replace(/^0+/, "$")
          : null;
      this.fixedAmountZero =
        reimbursementData.fixedAmount !== "0.00" &&
        /^0+/.test(reimbursementData.fixedAmount) === true
          ? reimbursementData.fixedAmount.replace(/^0+/, "$")
          : null;
      this.fuelPriceZero =
        reimbursementData.lastmonthfuelprice !== "0.00" &&
        /^0+/.test(reimbursementData.lastmonthfuelprice) === true
          ? reimbursementData.lastmonthfuelprice.replace(/^0+/, "$")
          : null;
      this.mileageRateZero =
        reimbursementData.lastmonthmileagerate !== "0.00" &&
        /^0+/.test(reimbursementData.lastmonthmileagerate) === true
          ? reimbursementData.lastmonthmileagerate.replace(/^0+/, "$")
          : null;
      this.lastMonthMiles = reimbursementData.lastmonthmiles
        ? reimbursementData.lastmonthmiles
        : 0;
      this.thisMonthMiles = reimbursementData.currentmonthmiles
        ? reimbursementData.currentmonthmiles
        : 0;
      this.halfFixedAmount = reimbursementData.halfFixedAmount
        ? reimbursementData.halfFixedAmount
        : 0;
      this.fixedAmount = reimbursementData.fixedAmount
        ? reimbursementData.fixedAmount
        : 0;
      this.monthfuelPrice = reimbursementData.lastmonthfuelprice
        ? reimbursementData.lastmonthfuelprice
        : 0;
      this.lastMonthMileageRate = reimbursementData.lastmonthmileagerate
        ? reimbursementData.lastmonthmileagerate
        : 0;
        this.thisFuelPrice = (reimbursementData.thismonthfuelprice) ? reimbursementData.thismonthfuelprice : 0;
        this.reimIdThisMonth = reimbursementData.reimIdThisMonth;
        this.reimIdLastMonth = reimbursementData.reimIdLastMonth;
        this.mpgThisMonth = (reimbursementData.mpgThisMonth) ? reimbursementData.mpgThisMonth : '';
        this.mpgLastMonth = (reimbursementData.mpgThisMonth) ? reimbursementData.mpgLastMonth : '';
        this.maintainsAndTyresThisMonth = (reimbursementData.maintainsAndTyresThisMonth) ? reimbursementData.maintainsAndTyresThisMonth : '';
        this.maintainsAndTyresLastMonth = (reimbursementData.maintainsAndTyresLastMonth) ? reimbursementData.maintainsAndTyresLastMonth : '';
        if(this.daysAfterActivation){
            if((this.monthfuelPrice === 0 || this.lastMonthMileageRate === 0) || (this.monthfuelPrice === "0" || this.lastMonthMileageRate === "0.0000")){
              const nextUpdateDay = (this.nextMonth()) ? 'Updated ' + this.nextMonth() + '. 4' : false;
              if(nextUpdateDay){
                  this.messageForNextBatch = nextUpdateDay;
              }
            }
        }else{
            this.messageForNextBatch = (this.currentMonth()) ? 'Updated ' + this.currentMonth() + '. 4' : false;
        }
        
    } else if (error) {
      console.log("getReimbursementData error", error);
    }
  }

  daysBetweenActivation(dateInitial, dateFinal){
    console.log(dateInitial, dateFinal)
    let  initialMonth = dateInitial.getMonth();
    let  initialYear = dateInitial.getFullYear();
    let  currentMonth = dateFinal.getMonth();
    let  currentYear = dateFinal.getFullYear();
    if(initialMonth === currentMonth && initialYear === currentYear){
      return true
    }else{
      return false
    }
  }


  handleMyTrip() {
    let currDate = new Date();
    let currentYear = currDate.getFullYear();
    let yearList = new Array();
    yearList.push(currentYear);
    this.myPlanInfo = false;
    this.myTrip = true;
    this.timeAttendance = false;
    let toogleText = this.timeAttendance ? "timeAttendance" : "MyTrip";
    this.accordionList = this.dynamicBinding(yearList);
    toggleEvents(this, toogleText)
    // this.accordionList.forEach(element => {
    //     element.accordionTitle = element.yearName +' Reimbursement Data';
    //     element.classType = 'accordion-item active';
    // });
  }

  handleTimeAttendance() {
    let currDate = new Date();
    let currentYear = currDate.getFullYear();
    let yearList = new Array();
    yearList.push(currentYear);
    this.myPlanInfo = false;
    this.myTrip = false;
    this.timeAttendance = true;
    let toogleText = this.timeAttendance ? "timeAttendance" : "MyTrip";
    this.accordionList = this.dynamicBinding(yearList);
    toggleEvents(this, toogleText)
    // this.accordionList.forEach(element => {
    //     element.accordionTitle = element.yearName +' Reimbursement Data (T & A)';
    //     element.classType = 'accordion-item active';
    //   });
  }

  
  handleClearInput(){
    this._value = "";
    this.isSearchEnable = this._value === "" ? true : false;
    this.template
    .querySelector("c-user-data-table")
    .searchByKey(this._value);
}

  handlePlanInfo() {
    this.myPlanInfo = true;
    this.myTrip = false;
    this.timeAttendance = false;
  }

  archiveReimbursement() {
    let flow = this.timeAttendance ? "timeAttendance" : "MyTrip";
    this.dispatchEvent(
      new CustomEvent("show", {
        detail: "isShow"
      })
    );
    events(this, flow);
  }

  fromAccordion(event) {
    openEvents(this, event.detail);
  }

  renderedCallback() {
    const buttonItem = this.template.querySelectorAll(".btn-toggle");

    buttonItem.forEach((el) =>
      el.addEventListener("click", () => {
        buttonItem.forEach((el2) => el2.classList.remove("is-active"));
        el.classList.add("is-active");
      })
    );

    if (this.myTA) {
      // console.log(this.myTrip, this.myTA);
      if (!this.myTrip) {
        if(!this.myPlanInfo){
          this.template.querySelector(".my-ta").classList.add("is-active");
          this.template.querySelector(".my-plan").classList.remove("is-active");
          this.template.querySelector(".my-trip").classList.remove("is-active");
        }else{
          this.template.querySelector(".my-ta").classList.remove("is-active");
          this.template.querySelector(".my-plan").classList.add("is-active");
          this.template.querySelector(".my-trip").classList.remove("is-active");
        }
      } else {
        this.template.querySelector(".my-ta").classList.remove("is-active");
        this.template.querySelector(".my-plan").classList.remove("is-active");
        this.template.querySelector(".my-trip").classList.add("is-active");
      }
    }
  }

  mapOrder(array, order, key) {
    array.sort(function (a, b) {
      var A = a[key],
        B = b[key];
      if (order.indexOf(A) > order.indexOf(B)) {
        return 1;
      }
      return -1;
    });

    return array;
  }

  getMonthFromString(mon){
    var d = Date.parse(mon + "1, 2012");
    if(!isNaN(d)){
       return new Date(d).getMonth() + 1;
    }
    return -1;
  }

  nextMonth(){
    const date = new Date(), dateInitial = new Date(this.activationDate);
    var day = date.getMonth();
    const formatter = new Intl.DateTimeFormat("default", {
        month: "short"
      });
    let  initialMonth = dateInitial.getMonth(), month;
    if(initialMonth === day){
      month = formatter.format(
        new Date(date.getFullYear(), date.getMonth() + 1)
      );
    }else{
      month = formatter.format(
        new Date(date.getFullYear(), date.getMonth())
      );
    }
    

   return month;
  }

  currentMonth(){
    const date = new Date();
    var day = date.getDate();
    const formatter = new Intl.DateTimeFormat("default", {
        month: "short"
      });
    let month = formatter.format(
        new Date(date.getFullYear(), date.getMonth())
    );

    if(day >= 1 && day < 4 ){
        return month;
    }
  }

  isToday(){
      const date = new Date();
      var day = date.getDate();
      const formatter = new Intl.DateTimeFormat("default", {
          month: "long"
        });
      let prevMonth = formatter.format(
          new Date(date.getFullYear(), date.getMonth() - 1)
      );

      if(day >= 1 && day < 4 ){
          return prevMonth;
      }
      return 'none'
  }

  isTodayBefore(){
    const date = new Date();
    var day = date.getDate();
    const formatter = new Intl.DateTimeFormat("default", {
        month: "long"
      });
    let prevMonth = formatter.format(
        new Date(date.getFullYear(), date.getMonth() - 1)
    );

   
    return prevMonth
  }

  dynamicModalBinding(data, keyFields) {
    data.forEach((element) => {
      let model = [];
      for (const key in element) {
        if (Object.prototype.hasOwnProperty.call(element, key)) {
          let singleValue = {};
          if (keyFields.includes(key) !== false) {
            singleValue.key = key;
            singleValue.value =
              element[key] === "null" || element[key] === null
                ? ""
                : key === "variableRate" ||
                  key === "varibleAmount" ||
                  key === "fixed1" ||
                  key === "fixed2" ||
                  key === "fixed3" ||
                  key === "totalFixedAmount" ||
                  key === "totalReimbursements"
                ? element[key].replace(/\$/g, "").replace(/\s/g, "")
                : element[key];
            // singleValue.isCurrency = (key === 'variableamount' || key === 'VariableRate' || key === 'variableRate'  || key === 'varibleAmount' || key === 'fixed1' || key === 'fixed2' || key === 'fixed3' || key === 'totalFixedAmount') ? true : false;
            singleValue.truncate =
              key === "originname" || key === "destinationname" ? true : false;
            singleValue.bold =
              key === "month" || key === "ReimMonth" ? true : false;
            singleValue.tooltip =
              key === "originname" || key === "destinationname" ? true : false;
            singleValue.tooltipText =
              key === "originname"
                ? element.origin != null
                  ? element.origin
                  : "This trip was manually entered without an address."
                : element.destination != null
                ? element.destination
                : "This trip was manually entered without an address.";
            singleValue.twoDecimal = key === "mileage" ? true : false;
            singleValue.istwoDecimalCurrency =
              key === "fuel" ||
              key === "fixedAmount" ||
              key === "avgToDate" ||
              key === "totalReimbursements" ||
              key === "varibleAmount" ||
              key === "fuelPrice" ||
              key === "variableamount" ||
              key === "fixed1" ||
              key === "fixed2" ||
              key === "fixed3" ||
              key === "totalFixedAmount" ||
              key === "totalReim" ||
              key === "variable"
                ? (element[key] === "null" || element[key] === null || element[key] === "") ? false : true
                : false;
            singleValue.isfourDecimalCurrency =
              key === "variableRate" || key === "VariableRate" ? true : false;
            singleValue.hasLeadingZero =
              (key === "fuel" ||
                key === "fixedAmount" ||
                key === "totalReimbursements" ||
                key === "variableRate" ||
                key === "varibleAmount" ||
                key === "fuelPrice" ||
                key === "variableamount" ||
                key === "VariableRate" ||
                key === "totalFixedAmount" ||
                key === "totalReim" ||
                key === "variable" ||
                key === "mileage" ||
                key === "fixed1" ||
                key === "fixed2" ||
                key === "fixed3") &&
              (element[key] !== "null" || element[key] !== null) &&
              singleValue.value !== "0.00" &&
              singleValue.value !== "0.0000" &&
              /^0+/.test(singleValue.value) === true
                ? singleValue.value.replace(/^0+/, "")
                : null;
            element[key] = (element[key] === "null" || element[key] === null) ? "" : (key === "variableRate" || key === "varibleAmount" || key === 'fixed1' || key === 'fixed2' || 
                key === 'fixed3' || 
                key === 'totalFixedAmount' || key === "totalReimbursements") ? element[key].replace(/\$/g, "").replace(/\s/g, "") : element[key];
             /* Display 10/4 Update or 1/4 Update based on month from 1st until 3rd of month until mileage and gas prices are available */
             if(key === 'fuelPrice' || key === 'VariableRate'){
              const monthValue =  (element['ReimMonth'] === "null" || element['ReimMonth'] === null || element['ReimMonth'] === "") ? -1 : this.getMonthFromString(element['ReimMonth']);
              const nextUpdate = (monthValue !== -1) ? (monthValue === 12) ? '1/4 Update' : (monthValue + 1) + '/4 Update' : ''
              if(element['ReimMonth'] === this.isToday()){
                  singleValue.istwoDecimalCurrency = false
                  singleValue.isfourDecimalCurrency = false
                  singleValue.value = nextUpdate
              }else{
                if(this.daysAfterActivation){
                  if((element[key] === 0 || element[key] === "0.00" || element[key] === "0.0000")){
                    const nextUpdateDay = (this.nextMonth()) ? 'Updated ' + this.nextMonth() + '. 4' : false;
                    if(element['ReimMonth'] === this.isTodayBefore()){
                      singleValue.istwoDecimalCurrency = false
                      singleValue.isfourDecimalCurrency = false
                      singleValue.value = nextUpdateDay
                    }
                  }
                }
              }
            }
            model.push(singleValue);
          }
        }
      }
      element.rejectedClass = element.status === "Rejected" ? "rejected" : "";
      element.isYtd = (this.templateName === 'Biweek' || this.templateName === 'Monthly') ? true : false;
      element.isYtdBiweek = (this.templateName === 'Biweek') ? true : false;
      element.keyFields = this.mapOrder(model, keyFields, "key");
    });
  }

  dynamicBinding(data) {
    let dataBind = [];
    let count = 1;
    data.forEach((element) => {
      let singleValue = {};
      singleValue.Id = count++;
      singleValue.yearName = element;
      singleValue.accordionTitle = this.myTrip
        ? element + " Reimbursement Data"
        : element + " Reimbursement Data (T & A)";
      singleValue.classType = "accordion-item active";
      this.hrBorder = true;
      //   singleValue.accTextClass = 'paragraph accordion-block';
      dataBind.push(singleValue);
    });

    return dataBind;
  }

  getPacketStatus() {
    this.packetStatus1 =
      this.packetStatus === "Sent to Driver" ||
      this.packetStatus === "Driver Signed" ||
      this.packetStatus === "Admin Signed" ||
      this.packetStatus === "Completed"
        ? true
        : false;
    this.packetStatus2 =
      this.packetStatus === "Driver Signed" ||
      this.packetStatus === "Admin Signed" ||
      this.packetStatus === "Completed"
        ? true
        : false;
    this.packetStatus3 =
      this.packetStatus === "Admin Signed" || this.packetStatus === "Completed"
        ? true
        : false;
    this.packetStatus4 = this.packetStatus === "Completed" ? true : false;
  }

  getMeetingStatus() {
    this.meetingStatus1 =
      this.meetingStatus === "Sent" ||
      this.meetingStatus === "Scheduled" ||
      this.meetingStatus === "Attended"
        ? true
        : false;
    this.meetingStatus2 =
      this.meetingStatus === "Scheduled" || this.meetingStatus === "Attended"
        ? true
        : false;
    this.meetingStatus3 = this.meetingStatus === "Attended" ? true : false;
  }

  onToast(event) {
    let toast = { type: 'error', message: event.detail }
    toastEvents(this, toast);
  }

  getSpinner(event) {
    this.dispatchEvent(
      new CustomEvent("show", {
        detail: event.detail
      })
    );
  }

  handleMap(event){
    this.checkAll = event.target.checked;
    this.typeMap = (!this.checkAll) ? 'USA' : 'CANADA'
    let state = (!this.checkAll) ? this.drivingState_US : this.drivingState_canada
    this.states = (state !== undefined) ? state.join(', ') : '';
    this.template.querySelector('c-choropleth-map').type = this.typeMap;
    this.template.querySelector('c-choropleth-map').reloadChart()
 }

  getLastMonthMileage() {
    // this.viewAllNotification = false;
    this.paginatedModal = true;
    this.isSync = false;
    this.isScrollable = true;
    this.isSortable = true;
    this.download = true;
    this.variable = true;
    this.ytd = false;
    this.biweekYtd = false;
    getMileages({
      clickedMonth: this.lastMonth,
      year: (this.lastMonth === 'December') ? this.year - 1 : this.year,
      contactId: this.contactId
    })
      .then((data) => {
        let resultData = data[0].replace(/\\/g, "");
        this.headerName = 'Last month';
        this.headerText = this.lastMonth;
       // this.monthText =  '(' + this.lastMonth + ')';
        this.lastModelList = JSON.parse(resultData);
        this.modalLength = this.lastModelList.length > 0 ? true : false;
        this.originalModelList = JSON.parse(resultData);
        this.colname = "tripdate";
        this.coltype = "Date";
        this.modalListColumn = this.lastMonthColumn;
        this.modalKeyFields = this.lastMonthKeyFields;
        console.log("My getMileages list->", resultData);
        this.dynamicModalBinding(this.lastModelList, this.modalKeyFields);
        this.template.querySelector("c-user-profile-modal").show();
      })
      .catch((error) => {
        console.log({
          error
        });
      });
  }

  getThisMonthMileage() {
    // this.viewAllNotification = false;
    this.paginatedModal = true;
    this.isSync = false;
    this.isScrollable = true;
    this.isSortable = true;
    this.download = true;
    this.ytd = false;
    this.biweekYtd = false;
    this.variable = false;
    getMileages({
      clickedMonth: this.thisMonth,
      year: this.year,
      contactId: this.contactId
    })
      .then((data) => {
        let resultData = data[0].replace(/\\/g, "");
        this.headerName = 'This month';
        this.headerText = this.thisMonth;
        //this.monthText = "(" + this.thisMonth + ")";
        this.lastModelList = JSON.parse(resultData);
        this.modalLength = this.lastModelList.length > 0 ? true : false;
        this.originalModelList = JSON.parse(resultData);
        this.colname = "tripdate";
        this.coltype = "Date";
        this.modalListColumn = this.thisMonthColumn;
        this.modalKeyFields = this.thisMonthKeyFields;
        console.log("My getMileages list->", resultData);
        this.dynamicModalBinding(this.lastModelList, this.modalKeyFields);
        this.template.querySelector("c-user-profile-modal").show();
      })
      .catch((error) => {
        console.log({
          error
        });
      });
  }

  getGasPrice() {
    this.templateName = "Gas Price";
    // this.viewAllNotification = false;
    this.ytd = false;
    this.biweekYtd = false;
    this.isSync = false;
    this.paginatedModal = false;
    this.isScrollable = false;
    this.isSortable = false;
    this.modalStyle =
      "slds-modal slds-modal_x-small slds-is-fixed slds-fade-in-open animate__animated animate__fadeInTopLeft animate__faster";
    getGasPriceandRate({
      contactId: this.contactId
    }).then((data) => {
      let gasPriceList = this.proxyToObject(data);
      this.headerText = "";
      this.monthText = "";
      this.lastModelList = this.sortByMonthDesc(gasPriceList, "ReimMonth");
      this.originalModelList = gasPriceList;
      this.modalListColumn = (!this.isIRS) ? this.gasPriceColumn : this.gasPriceIRSColumn;
      this.modalKeyFields = (!this.isIRS) ? this.gasPriceKeyFields : this.gasPriceIRSKeyFields;
      this.dynamicModalBinding(this.lastModelList, this.modalKeyFields);
      this.template.querySelector("c-user-profile-modal").show();
      console.log("gasPrice ----", gasPriceList);
    });
  }

  getDrivingStatesList(){
    getDrivingStates()
    .then(response => {
        let stateList = JSON.parse(response);
        if(stateList && stateList.length){
            console.log("State---", response)
            this.validStateList = stateList;
        }
    })
    .catch(err => {
        console.log(err)
    });
  }

  getSelectedStates(event){
    if(event.detail){
        var addedState
        let drivingstates = JSON.parse(event?.detail)
        this.drivingTitle = (drivingstates?.message?.length > 0) ? drivingstates?.message?.join(', ') : '';
        this.isSelectedState = (drivingstates?.message?.length > 0) ? true : false;
        this.addedDrivingState = (this.drivingTitle != '') ? this.drivingTitle.split(', ') : [];
        addedState = this.addedDrivingState.filter(state => !this.usStatesList.includes(state));
        this.listOfAddedState = addedState;
    }
  }

  getListOfDrivingStates(){
    this.canadaStatesList = canadaStates;
    this.usaDrivingStates = usaDrivingStates;
    getDrivingState({
        contactId: this.contactId
    }).then((result) =>{
        if(result){
            //console.log("Driving state", result)
            let drivingState = this.proxyToObject(result);
            if(drivingState.length > 0){
                if(drivingState[0].Driving_States__c !== undefined){
                    let canadaState = this.canadaStatesList.split(',');
                    let usAState = this.usaDrivingStates.split(',');
                    let states = drivingState[0].Driving_States__c.split(';');
                    this.usStatesList = drivingState[0].Driving_States__c;
                    let usState = (states !== undefined) ? states : []
                    let candaState = (canadaState !== undefined) ? canadaState : []
                    this.drivingState_US = usState.filter(item => !candaState.includes(item));
                    this.drivingState_canada = usState.filter(item => candaState.includes(item));
                    let C = canadaState.some(elem => states.includes(elem));
                    let U = usAState.some(elem => states.includes(elem));
                    setTimeout(()=>{
                        this.states = (this.typeMap === 'CANADA') ? this.drivingState_canada.join(', ') : this.drivingState_US.join(', ')
                        this.multipleMap = (C === true && U === true) ? true : false;
                        this.checkAll = (this.typeMap === 'CANADA') ? true : false;
                    }, 2000)
                   
                }
            }
          
            //console.log("Driving state", result, this.typeMap)
        }
    })
}

  getBiweekReimbursement() {
    this.templateName = "Biweek";
    // this.viewAllNotification = false;
    //this.ytd = true;
    this.biweekYtd = true;
    this.paginatedModal = false;
    this.isSync = false;
    this.isScrollable = false;
    this.isSortable = false;
    this.modalStyle =
      "slds-modal slds-modal_large slds-is-fixed slds-fade-in-open animate__animated animate__fadeInTopLeft animate__faster";
    getAllReimbursements({
      year: this.year,
      contactId: this.contactId,
      accountId: this.accountId
    }).then((data) => {
			 console.log("getAllReimbursements biweek----", data);
      let biweekReimbursementList = this.proxyToObject(data[0]);
      this.ytd = biweekReimbursementList.length > 0 ? true : false;
      this.headerText = "";
      this.monthText = "";
      this.lastModelList = this.sortByMonthDesc(
        biweekReimbursementList,
        "month"
      );
      this.originalModelList = biweekReimbursementList;
      this.modalListColumn = this.biweekColumn;
      this.modalKeyFields = this.biweekKeyFields;
      this.dynamicModalBinding(this.lastModelList, this.modalKeyFields);
      this.template.querySelector("c-user-profile-modal").show();
     
    }).catch((error) => {
        console.log(JSON.stringify(error), error);
    });
  }

  getMonthReimbursement() {
    this.templateName = "Monthly";
    //  this.viewAllNotification = false;
    //this.ytd = true;
    this.biweekYtd = false;
    this.isSync = false;
    this.paginatedModal = false;
    this.isScrollable = false;
    this.isSortable = false;
    this.modalStyle =
      "slds-modal slds-modal_large slds-is-fixed slds-fade-in-open animate__animated animate__fadeInTopLeft animate__faster";
    getAllReimbursements({
      year: this.year,
      contactId: this.contactId,
      accountId: this.accountId
    }).then((data) => {
      let biweekReimbursementList = this.proxyToObject(data[0]);
      this.ytd = biweekReimbursementList.length > 0 ? true : false;
      this.headerText = "";
      this.monthText = "";
      this.lastModelList = this.sortByMonthDesc(
        biweekReimbursementList,
        "month"
      );
      this.originalModelList = biweekReimbursementList;
      this.modalListColumn = this.monthColumn;
      this.modalKeyFields = this.monthKeyFields;
      this.dynamicModalBinding(this.lastModelList, this.modalKeyFields);
      this.template.querySelector("c-user-profile-modal").show();
      console.log("getAllReimbursements ----", data);
    });
  }

  excelToExport(data, file, sheet) {
    this.template.querySelector("c-export-excel").download(data, file, sheet);
  }

  dateTime(date) {
    var yd, ydd, ymm, yy, hh, min, sec;
    yd = date;
    ydd = yd.getDate();
    ymm = yd.getMonth() + 1;
    yy = yd.getFullYear();
    hh = yd.getHours();
    min = yd.getMinutes();
    sec = yd.getSeconds();
    ydd = ydd < 10 ? "0" + ydd : ydd;
    ymm = ymm < 10 ? "0" + ymm : ymm;
    // console.log(ymm + ydd);
    // console.log(yy.toString(), hh.toString(), min.toString(), sec.toString());
    return (
      ymm.toString() +
      ydd.toString() +
      yy.toString() +
      hh.toString() +
      min.toString() +
      sec.toString()
    );
  }

  downloadUserTrips() {
    if (this.headerName === "This month") {
      let mileage = [];
      // let clickedPeriod = "Pay Period " + this.startDate + " - " + this.endDate;
      let fileName = this.contactName +  '\'s ' + this.thisMonth + ' Mileage Report ' + this.dateTime(new Date());
      let sheetName = (this.thisMonth) ? this.thisMonth + ' Month Mileage Report' : 'This Month Mileage Report';
      mileage.push([
        "Contact Email",
        "Trip Date",
        "Start Time",
        "End Time",
        "Trip Origin",
        "Trip Destination",
        "Mileage",
        "Status"
      ]);
      this.lastModelList.forEach((item) => {
        mileage.push([
          item.emailaddress,
          item.tripdate,
          item.starttime,
          item.endtime,
          item.originname,
          item.destinationname,
          item.mileage,
          item.status
        ]);
      });
      this.excelToExport(mileage, fileName, sheetName);
    } else {
      let mileage = [];
      // let clickedPeriod = "Pay Period " + this.startDate + " - " + this.endDate;
      let fileName = this.contactName + '\'s ' + this.lastMonth + ' Mileage Report ' + this.dateTime(new Date());
      let sheetName = (this.lastMonth) ? this.lastMonth + ' Month Mileage Report' : 'Last Month Mileage Report';
      if(this.isNotIRS){
        mileage.push([
          "Contact Email",
          "Tracking Style",
          "Day Of Week",
          "Trip Date",
          "Start Time",
          "End Time",
          "Trip Origin",
          "Trip Destination",
          "Mileage",
          "Status",
          "Date Submitted",
          "Date Approved",
          "Maint/Tires",
          "Fuel Rate",
          "Variable Rate",
          "Amount",
          "Notes",
          "Tags"
        ]);
        this.lastModelList.forEach((item) => {
          mileage.push([
            item.emailaddress,
            item.tracingstyle,
            item.dayofweek,
            item.tripdate,
            item.starttime,
            item.endtime,
            item.originname,
            item.destinationname,
            item.mileage,
            item.status,
            item.submitteddate,
            item.approveddate,
            item.maintTyre,
            item.fuelVariableRate,
            item.variablerate,
            item.variableamount,
            item.notes,
            item.tag
          ]);
        });
      }else{
        mileage.push([
          "Contact Email",
          "Tracking Style",
          "Day Of Week",
          "Trip Date",
          "Start Time",
          "End Time",
          "Trip Origin",
          "Trip Destination",
          "Mileage",
          "Status",
          "Date Submitted",
          "Date Approved",
          "Variable Rate",
          "Amount",
          "Notes",
          "Tags"
        ]);
        this.lastModelList.forEach((item) => {
          mileage.push([
            item.emailaddress,
            item.tracingstyle,
            item.dayofweek,
            item.tripdate,
            item.starttime,
            item.endtime,
            item.originname,
            item.destinationname,
            item.mileage,
            item.status,
            item.submitteddate,
            item.approveddate,
            item.variablerate,
            item.variableamount,
            item.notes,
            item.tag
          ]);
        });
      }
     
      this.excelToExport(mileage, fileName, sheetName);
    }
  }

  downloadAllRecord() {
    if (this.templateName === "Gas Price") {
      let downloadList = [];
      // let clickedPeriod = "Pay Period " + this.startDate + " - " + this.endDate;
      let fileName =
        this.contactName + "'s Mileage & Gas Price Report " + this.dateTime(new Date());
      let sheetName = "Mileage Report";
      if(this.isNotIRS){
        downloadList.push(["Month", "Gas Prices", "Mileage Rate"]);
        this.lastModelList.forEach((item) => {
          downloadList.push([item.ReimMonth, item.fuelPrice, item.VariableRate]);
        });
      }else{
        downloadList.push(["Month", "Mileage Rate"]);
        this.lastModelList.forEach((item) => {
          downloadList.push([item.ReimMonth, item.VariableRate]);
        });
      }
      this.excelToExport(downloadList, fileName, sheetName);
    } else if (this.templateName === "Monthly") {
      let downloadList = [];
      // let clickedPeriod = "Pay Period " + this.startDate + " - " + this.endDate;
      let fileName =
        this.contactName + "'s Mileage Report " + this.dateTime(new Date());
      let sheetName = "Mileage Report";
      if(this.isNotIRS){
        downloadList.push([
          "Month",
          "Fuel",
          "Mileage",
          "Mi Rate",
          "Variable",
          "Fixed",
          "Total",
          "Average To Date"
        ]);
        this.lastModelList.forEach((item) => {
          downloadList.push([
            item.month,
            item.fuel,
            item.mileage,
            item.variableRate,
            item.varibleAmount,
            item.fixedAmount,
            item.totalReimbursements,
            item.avgToDate
          ]);
        });
        downloadList.push([
          "YTD",
          "",
          this.excelYtd.mileageCalc,
          "",
          this.excelYtd.varibleAmountCalc,
          this.excelYtd.totalMonthlyFixedCalc,
          this.excelYtd.totalReim,
          this.excelYtd.totalAVGCalc
        ]);
      }else{
        downloadList.push([
          "Month",
          "Mileage",
          "Mi Rate",
          "Variable",
          "Fixed",
          "Total",
          "Average To Date"
        ]);
        this.lastModelList.forEach((item) => {
          downloadList.push([
            item.month,
            item.mileage,
            item.variableRate,
            item.varibleAmount,
            item.fixedAmount,
            item.totalReimbursements,
            item.avgToDate
          ]);
        });
        downloadList.push([
          "YTD",
          this.excelYtd.mileageCalc,
          "",
          this.excelYtd.varibleAmountCalc,
          this.excelYtd.totalMonthlyFixedCalc,
          this.excelYtd.totalReim,
          this.excelYtd.totalAVGCalc
        ]);
      }
    
      this.excelToExport(downloadList, fileName, sheetName);
    } else {
      let downloadList = [];
      // let clickedPeriod = "Pay Period " + this.startDate + " - " + this.endDate;
      let fileName =
        this.contactName + "'s Mileage Report " + this.dateTime(new Date());
      let sheetName = "Mileage Report";
      downloadList.push([
        "Month",
        "Mi Rate",
        "Mileage",
        "Variable",
        "Fixed 1",
        "Fixed 2",
        "Fixed 3",
        "Total",
        "Average To Date"
      ]);
      this.lastModelList.forEach((item) => {
        downloadList.push([
          item.month,
          item.variableRate,
          item.mileage,
          item.varibleAmount,
          item.fixed1 ? item.fixed1 : "",
          item.fixed2 ? item.fixed2 : "",
          item.fixed3 ? item.fixed3 : "",
          item.totalReimbursements,
          item.avgToDate
        ]);
      });
      downloadList.push([
        "YTD",
        "",
        this.excelYtd.mileageCalc,
        this.excelYtd.varibleAmountCalc,
        this.excelYtd.fixed1Calc,
        this.excelYtd.fixed2Calc,
        this.excelYtd.fixed3Calc,
        this.excelYtd.totalReim,
        this.excelYtd.totalAVGCalc
      ]);
      this.excelToExport(downloadList, fileName, sheetName);
    }
  }

  handleChange(event) {
    this._value = event.target.value;
    this.isSearchEnable = this._value === "" ? true : false;
    this.template
      .querySelector("c-user-data-table")
      .searchByKey(this._value, this.lastModelList);
  }

  sortByMonthAsc(data, colName) {
    let months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    data.sort((a, b) => {
      return months.indexOf(a[colName]) - months.indexOf(b[colName]);
    });
    return data;
  }


  sortByMonthDesc(data, colName) {
    let months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    data.sort((a, b) => {
      return months.indexOf(b[colName]) - months.indexOf(a[colName]);
    });
    return data;
  }

  getMonthName(monthIndex) {
    let daymonth = new Array();
    daymonth[0] = "January";
    daymonth[1] = "February";
    daymonth[2] = "March";
    daymonth[3] = "April";
    daymonth[4] = "May";
    daymonth[5] = "June";
    daymonth[6] = "July";
    daymonth[7] = "August";
    daymonth[8] = "September";
    daymonth[9] = "October";
    daymonth[10] = "November";
    daymonth[11] = "December";
    return daymonth[monthIndex];
  }

  driverDetailsList(data) {
    let contactList = this.proxyToObject(data);
    // console.log("contact", contactList);
    this.lengthOfContact = contactList.length > 0 ? true : false;
    this.myTA = contactList[0].Time_Attandance__c ? true : false;
    this.biweekly =
      contactList[0].Reimbursement_Frequency__c === "Bi-Weekly Reimbursement"
        ? true
        : false;
    this.contact = contactList[0];
    this.contactName = contactList[0].Name;
    this.mapCountry = (contactList[0].Map_Country__c !== undefined) ? contactList[0].Map_Country__c : 'USA';
    this.typeMap = this.mapCountry;
    this.attachmentInsurance =
      contactList[0].Insurance_Attachment_Id__c != null
        ? contactList[0].Insurance_Attachment_Id__c
        : null;
    this.vehicleImage = contactList[0].Car_Image__c;
    this.vehicleType = contactList[0].Vehicle_Type__c;
    this.isIRS = (contactList[0].Vehicle_Type__c) ? (contactList[0].Vehicle_Type__c).includes("IRS Mileage Rate") : false;
    this.isNotIRS = (!this.isIRS) ? true : false; // If isIRS = false then this will be true
    this.insuranceRate =
      contactList[0].Insurance_Rate__c === null ||
      contactList[0].Insurance_Rate__c === undefined
        ? 0
        : contactList[0].Insurance_Rate__c;
    this.maintenance =
      contactList[0].Maintenance__c === null ||
      contactList[0].Maintenance__c === undefined
        ? 0
        : contactList[0].Maintenance__c;
    this.tires =
      contactList[0].Tires__c === null || contactList[0].Tires__c === undefined
        ? 0
        : contactList[0].Tires__c;
    this.license =
      contactList[0].License_Ragistration__c === null ||
      contactList[0].License_Ragistration__c === undefined
        ? 0
        : contactList[0].License_Ragistration__c;
    this.taxes =
      contactList[0].Taxes__c === null || contactList[0].Taxes__c === undefined
        ? 0
        : contactList[0].Taxes__c;
    this.depreciation =
      contactList[0].Depreciation__c === null ||
      contactList[0].Depreciation__c === undefined
        ? 0
        : contactList[0].Depreciation__c;
    this.totalCost = contactList[0].Total_Monthly_Costs__c;
    this.percent = contactList[0].Business_Use__c;
    this.businessUse =
      contactList[0].Total_Monthly_Costs__c *
      (contactList[0].Business_Use__c / 100);
    this.totalMonthlyAmount = this.businessUse / 12;
    this.fixedCostAdjustment =
      contactList[0].Fixed_Cost_Adjustment__c === null ||
      contactList[0].Fixed_Cost_Adjustment__c === undefined ||
      contactList[0].Fixed_Cost_Adjustment__c === ""
        ? null
        : contactList[0].Fixed_Cost_Adjustment__c;
    this.totalMonthlyFixedCost =
      contactList[0].Fixed_Cost_Adjustment__c === null ||
      contactList[0].Fixed_Cost_Adjustment__c === undefined ||
      contactList[0].Fixed_Cost_Adjustment__c === ""
        ? null
        : this.fixedCostAdjustment + this.totalMonthlyAmount;
        this.address = (contactList[0].MailingCity !== undefined ? contactList[0].MailingCity + ', ' : '') + (contactList[0].MailingState !== undefined ? contactList[0].MailingState : '') +' '+ (contactList[0].MailingPostalCode !== undefined ? contactList[0].MailingPostalCode : '');

        getFuelVariableRate({
          contactId: this.contactId
        }).then((data) => {
          console.log("getFuelVariableRate---", data);
          if (data) {
            let gasrate = JSON.parse(data);
            console.log("getFuelVariableRate 2---", gasrate);
            if (gasrate != null && gasrate !== "") {
              if (gasrate[0] !== undefined) {
                if (gasrate[0].Fuel_Price__c == null) {
                  this.variablefuelprice = JSON.stringify(gasrate);
                } else {
                  this.variablefuelprice = null;
                }
              } else {
                this.variablefuelprice = gasrate;
              }
            } else {
              this.variablefuelprice = null;
            }

            this.miles =
            this.variablefuelprice != null
              ? parseFloat(this.variablefuelprice) + this.maintenance + this.tires
              : this.maintenance + this.tires;
                if(this.daysAfterActivation){
                  if(this.variablefuelprice === 0  || this.variablefuelprice === null || this.variablefuelprice === "0.0000"){
                    const nextUpdateDay = (this.nextMonth()) ? 'Updated ' + this.nextMonth() + '. 4' : false;
                    if(nextUpdateDay){
                        this.variablefuelprice = nextUpdateDay;
                    }
                  }
                }else{
                  this.variablefuelprice = (this.currentMonth()) ? 'Updated ' + this.currentMonth() + '. 4' : this.variablefuelprice;
                }
            console.log("Miles", this.miles, this.variablefuelprice, this.maintenance, this.tires)
          }else{
            this.miles = this.maintenance + this.tires;
          }
        }).catch((error)=>{
          this.miles = this.maintenance + this.tires;
          console.log("getFuelVariableRate--", JSON.stringify(error))
        });
  }

  revertHandler(){
    this.dispatchEvent(
      new CustomEvent("back", {
          detail: ''
      })
   );
  }

  closeModalPopup(){
    this.isChecked = false;
    this.isLastChecked = false;
    this.isActiveSync = true;
  }

  syncProcess(){
      this.ytd = false;
      this.biweekYtd = false;
      this.paginatedModal = false;
      this.isScrollable = false;
      this.isSortable = false;
      this.isSync = true;
      this.headerText = 'Update Your Mileage';
      console.log("Inside sync")
      setTimeout(()=>{
          this.template.querySelector('c-user-profile-modal').show();
      }, 10)
  }

  addDrivingState() {
    this.isDrivingSt = true;
    this.drivingTitle = this.states;
    this.template.querySelector('c-choropleth-map').action = 'add';
    let stateList = this.validStateList;
    let canadaState = this.canadaStatesList.split(',');
    let usAState = this.usaDrivingStates.split(',');
    let drivingState_US = stateList.filter(item => usAState.includes(item));
    let drivingState_canada = stateList.filter(item => canadaState.includes(item));
    this.template.querySelector('c-choropleth-map').getMap(JSON.stringify(drivingState_US), drivingState_canada, this.drivingState_US, this.drivingState_canada);
 }

  syncMileage(){
      console.log('isChecked', this.isLastChecked, this.isChecked)
      if(this.isChecked){
        this.template.querySelector('c-user-profile-modal').hide();
        this.loaderIcon = this.loader;
        this.loaderPlaceholder = 'The mileage is syncing, it could take up to a minute.'
        this.spinner = true;
        UpdateReimbursementStatus({
          empReID: this.reimIdThisMonth
        })
        .then(result=>{
          console.log("Result", result)
          if(result){
            TripCallout({
              driverId: this.contactId,
              month: this.thisMonth,
              year: this.year,
              fuel: this.thisFuelPrice,
              maintTyre: this.maintainsAndTyresThisMonth,
              empReID:  this.reimIdThisMonth,
              mpg: this.mpgThisMonth,
              status: 'U'
            })
            .then((res)=>{
              this.template.querySelector('c-user-profile-modal').hide();
              this.spinner = false;
              this.isChecked = false;
              this.isLastChecked = false;
              this.isActiveSync = true;
              let toast = { type: 'success', message: 'Mileage is being synced.' }
              this.dispatchEvent(
                new CustomEvent("message", {
                    detail: toast
                })
              );
              console.log("Tripcallout--", res)
              return refreshApex(this.wiredReimList);
            })
            .catch((err)=>{
              this.template.querySelector('c-user-profile-modal').hide();
              this.spinner = false;
              this.isChecked = false;
              this.isLastChecked = false;
              this.isActiveSync = true;
              console.log("Error---", err.message)
            })
          }
        })
        .catch((error)=>{
          this.template.querySelector('c-user-profile-modal').hide();
          this.spinner = false;
          this.isChecked = false;
          this.isLastChecked = false;
          this.isActiveSync = true;
          console.log("Error---", error.message)
        })
      }
      else{
          if(this.isLastChecked){
                  this.template.querySelector('c-user-profile-modal').hide();
                  this.loaderIcon = this.loader;
                  this.loaderPlaceholder = 'The mileage is syncing, it could take up to a minute.'
                  this.spinner = true;
                  UpdateReimbursementStatus({
                    empReID: this.reimIdLastMonth
                  })
                  .then(result=>{
                    console.log("Result", result)
                    if(result){
                      TripCallout({
                        driverId: this.contactId,
                        month: this.lastMonth,
                        year: (this.lastMonth === 'December') ? this.year - 1 : this.year,
                        fuel: this.monthfuelPrice,
                        maintTyre: this.maintainsAndTyresLastMonth,
                        empReID:  this.reimIdLastMonth,
                        mpg: this.mpgLastMonth,
                        status: 'U'
                      })
                      .then(()=>{
                          this.template.querySelector('c-user-profile-modal').hide();
                          this.spinner = false;
                          let toast = { type: 'success', message: 'Mileage is being synced.' }
                          this.dispatchEvent(
                            new CustomEvent("message", {
                                detail: toast
                            })
                          );
                          refreshApex(this.wiredReimList);
                      })
                      .catch((err)=>{
                          this.template.querySelector('c-user-profile-modal').hide();
                          this.spinner = false;
                        console.log("Error---", err.message)
                      })
                    }
                  })
                  .catch((error)=>{
                      this.template.querySelector('c-user-profile-modal').hide();
                      this.spinner = false;
                    console.log("Error---", error.message)
                  })
          }
      }
  }

  checkboxLastMonthHandler(event) {
      event.stopPropagation();
      let checked = event.target.checked;
      this.isLastChecked = checked;
      this.isChecked = false;
      this.isActiveSync = (this.isLastChecked) ? false : true;
      console.log("Sync for---", checked)
  }

  checkboxThisMonthHandler(event) {
      event.stopPropagation();
      let checked = event.target.checked;
      this.isChecked = checked;
      this.isLastChecked = false;
      this.isActiveSync = (this.isChecked) ? false : true;
      console.log("Sync for---", checked)
  }

  addState(){
    var drivingList;
    const concatState = (this.multipleMap) ? (this.typeMap === 'CANADA') ? this.addedDrivingState.concat(this.drivingState_US) : this.addedDrivingState.concat(this.drivingState_canada) : this.addedDrivingState;
    this.addedDrivingState = concatState;
    console.log("Driving State##", this.addedDrivingState, JSON.stringify(this.addedDrivingState));
    this.loaderIcon = this.loader2;
    this.loaderPlaceholder = 'Updating driving state, it could take up to a minute.';
    this.spinner = true;
    if(this.addedDrivingState.length > 0){
        let drivingStateAdded = this.addedDrivingState.join(';');
        drivingList = this.listOfAddedState.join(';');
        updateStateList({
            contactId: this.contactId,
            listOfStates: drivingStateAdded
        })
        .then(data => {
            if(data){
              if(this.roleUser != 'Admin'){
                console.log("Inside Email Fire##", this.roleUser);
                sendDrivingStateEmail({id: this.contactId, drivingStates: drivingList})
                .then((res)=>{console.log("Result--", res);})
                .catch((err)=>{console.log("Err from email--", err)});
              }
              this.removeState();
              this.getListOfDrivingStates();
                setTimeout(()=>{
                    this.spinner = false;
                    let toast = { type: 'success', message: 'Driving State Added Successfully.' }
                    toastEvents(this, toast);
                }, 2000)
          }
        }).catch((error)=>{
            console.log('Dr--', error);
        })
    }
  }

  removeState(){
      this.isDrivingSt = false;
      this.isSelectedState = false;
      this.drivingTitle = '';
      this.template.querySelector('c-choropleth-map').action = '';
      this.template.querySelector('c-choropleth-map').reloadChart();
  }

  connectedCallback() {
    // console.log("console-->", this.myTrip, this.timeAttendance);
    let currDate = new Date();
    let currentYear = currDate.getFullYear();
    let yearList = new Array();
    yearList.push(currentYear);
    this.accordionList = this.dynamicBinding(yearList);
    let currentDate = new Date();
    let monthNo = currentDate.getMonth();
    let previousMonthNo = currentDate.getMonth() - 1;
    this.year = currentDate.getFullYear();
    this.thisMonth = this.getMonthName(monthNo);
    this.daysAfterActivation = this.daysBetweenActivation(new Date(this.activationDate), new Date(currDate.getFullYear(), currDate.getMonth(), 4));
    this.lastMonth =
      previousMonthNo >= 0
        ? this.getMonthName(previousMonthNo)
        : this.getMonthName(11);
    this.thismonthAbbr = (this.thisMonth) ? (this.thisMonth).substring(0, 3) : '';
    this.lastmonthAbbr = (this.lastMonth) ? (this.lastMonth).substring(0, 3) : '';
    this.getListOfDrivingStates();
    this.getDrivingStatesList();

    getPacketandMeeting({
      contactId: this.contactId
    })
      .then((data) => {
        let result = data[0].replace(/\\/g, "");
        let packetMeeting = this.proxyToObject(result);
        this.packetStatus = packetMeeting[0].Packet__c;
        this.meetingStatus = packetMeeting[0].Meeting__c;
        this.getPacketStatus();
        this.getMeetingStatus();
        // console.log("getPacketandMeeting", JSON.parse(data), data);
      })
      .catch((error) => {
        console.log("getPacketandMeeting error", error);
      });

    // console.log("drivers--", this.driverDetails);
    if (this.driverDetails) {
      this.driverDetailsList(this.driverDetails);
      if(this.isIRS){
        const vehicle = this.vehicleType
        let subStrIRS = vehicle.substring(0, 5);
        let splitter = vehicle.split(subStrIRS);
        this.vehicleType = (splitter.length > 0) ? splitter[1] : this.vehicleType;
      }
    }
  }
}