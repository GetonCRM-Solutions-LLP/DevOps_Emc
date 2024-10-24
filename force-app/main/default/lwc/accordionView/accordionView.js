/* eslint-disable no-useless-escape */
/*
 * @Author: GetonCRM Solutions Pvt Ltd - Megha Sachania 
 * @Date: 2024-10-18 16:56:27 
 * @Modification logs
 * ========================================================================================================================
 * @Last Modified by: Megha Sachania
 * @Last Modified time: 2024-10-22 17:33:11
 * @Description: Reimbursement View & Archive View Accordion
 */

import { LightningElement, api, track } from "lwc";
import { createExportDetailList } from 'c/commonLib';
import { events, toastEvents } from 'c/utils';
import biweeklyMileage from "@salesforce/apex/DriverDashboardLWCController.biweeklyMileage";
import getAllMileages from '@salesforce/apex/DriverDashboardLWCController.getAllMileages';
import getAllReimbursements from "@salesforce/apex/DriverDashboardLWCController.getAllReimbursements";
import getBiweekMileages from '@salesforce/apex/DriverDashboardLWCController.getBiweekMileages';
import getMileages from '@salesforce/apex/DriverDashboardLWCController.getMileages';
import getMileagesBasedTandAtt from "@salesforce/apex/DriverDashboardLWCController.getMileagesBasedTandAtt";
import getMileagesData from '@salesforce/apex/DriverDashboardLWCController.getMileagesData';
import mBurseCss from '@salesforce/resourceUrl/LwcDesignImage';
import resourceImage from '@salesforce/resourceUrl/mBurseCss';
import timeAttendance from "@salesforce/apex/DriverDashboardLWCController.TimeAttendance";
export default class AccordionView extends LightningElement {
  @api accordionData;
  @api activationDate;
  @api contactId;
  @api accountId;
  @api contactInfo;
  @api isTandA;
  @api hrClass;
  @api isDownloadAll;
  @api isIrs;
  @api showArrowIcon;
  @track accordionList = [];
  @track listVisible = false;
  systemLoader = `${mBurseCss}/Resources/PNG/Green/6.png`;
  loadingGif = `${resourceImage}/mburse/assets/mBurse-Icons/Bar-style.gif`;
  defaultYear = '';
  isReimbursementView = false;
  isScrollable = false;
  listOfRecord = false;
  daysAfterActivation;
  noMessage = 'No data available';
  isRowDn = true;
  sortable =  false;
  name;
  accordionKeyFields;
  accordionListColumn;
  paginated = false;
  keyFields;
  isPayperiod = false;
  column;
  rKeyFields;
  rColumn;
  downloadIcon = `${resourceImage}/mburse/assets/mBurse-Icons/download-all.png`;
  
  proxyToObject(e) {
    return JSON.parse(e);
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

  sortByMonthDesc(data, colName) {
    const months = [
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
    data.sort((af, bf) => {
      return months.indexOf(bf[colName]) - months.indexOf(af[colName]);
    });
    return data;
  }

  sortByDateDesc(data, colName) {
    data.sort((af, bf) => {
      af = af[colName] ? new Date(af[colName].toLowerCase()) : "";
      bf = bf[colName] ? new Date(bf[colName].toLowerCase()) : "";
      return af > bf ? -1 : 1;
    });
    return data;
  }

  currentMonth(){
    const date = new Date(), day = date.getDate(), first = 1, fourth = 4,
    formatter = new Intl.DateTimeFormat("default", {
        month: "short"
    }),
    month = formatter.format(
        new Date(date.getFullYear(), date.getMonth())
    );

    if(day >= first && day < fourth ){
        return month;
    }
  }

  nextMonth(){
    const date = new Date(), day = date.getMonth(), dateInitial = new Date(this.activationDate),
    formatter = new Intl.DateTimeFormat("default", {
        month: "short"
    }), 
    month = (dateInitial.getMonth() === day) ? formatter.format(new Date(date.getFullYear(), date.getMonth() + 1)) : formatter.format(new Date(date.getFullYear(), date.getMonth()));
   return month;
  }

  getMonthLong(){
    const date = new Date(), formatter = new Intl.DateTimeFormat("default", {
        month: "long"
     }),
     month = formatter.format(
       new Date(date.getFullYear(), date.getMonth())
    );

    return month
  }

  isToday(){
      const date = new Date(), day = date.getDate(), first = 1, fourth = 4,
      formatter = new Intl.DateTimeFormat("default", {
          month: "long"
        }), prevMonth = formatter.format(
          new Date(date.getFullYear(), date.getMonth() - 1)
      );

      if(day >= first && day < fourth ){
          return prevMonth;
      }
      return 'none'
  }

  buildModel(element, keyFields) {
    let model = [];
    Object.keys(element).forEach((key) => {
      if (keyFields.includes(key) !== false) {
        let singleValue = this.createSingleValue(element, key);
        model.push(singleValue);
      }
    });
    return model;
  }

  dynamicBinding(data, keyFields) {
    data.forEach((element) => {
      let model = this.buildModel(element, keyFields);
      this.assignId(element);
      element.keyFields = this.mapOrder(model, keyFields, "key");
    });
  }

  createSingleValue(element, key) {
    let singleValue = {};
    if (this.contactInfo.Reimbursement_Frequency__c === 'Bi-Weekly Reimbursement' && this.contactInfo.Reimbursement_Type__c === 'Mileage Rate') {
      singleValue.id = element.biweekId;
      singleValue.eDate = element.endDate;
      singleValue.sDate = element.startDate;
    }
    singleValue.key = key;
    singleValue.value = (element[key] === "null" || element[key] === null) ? "" : this.formatValue(key, element[key]);
    singleValue.icon = (!this.isTandA && (key === "month" || key === "startDate"));
    singleValue.bold = (key === "totalReimbursements" || key === "totalReim");
    singleValue.twoDecimal = (key === "mileage" || key === "totalMileage");
    singleValue.isDate = (key === "startDate" || key === "endDate" || key === "approvalDate") && (element[key] !== null);
    singleValue.isfourDecimalCurrency = (key === 'variableRate' || key === 'VariableRate') && (element[key] !== null);
    singleValue.istwoDecimalCurrency = this.isTwoDecimalCurrency(key, element[key]);
    singleValue.hasLeadingZero = this.hasLeadingZero(key, element[key], singleValue.value);
    this.updateFuelVariableRate(singleValue, key, element);
    return singleValue;
  }

  formatValue(key, value) {
    return (key === "variableRate" || key === "varibleAmount" || key === 'fixed1' || key === 'fixed2' ||
      key === 'fixed3' || key === 'totalFixedAmount' || key === "totalReimbursements") ? value.replace(/\$/g, "").replace(/\s/g, "") : value;
  }

  isTwoDecimalCurrency(key, value) {
    return (key === "fuel" || key === "fixedAmount" || key === "fixed1" || key === "fixed2" || key === "fixed3" ||
      key === "totalReimbursements" || key === "varibleAmount" || key === "totalReim" || key === "variable") && value !== "null" && value !== null;
  }

  hasLeadingZero(key, value, formattedValue) {
    return ((key === "fuel" || key === "fixedAmount" || key === "totalReimbursements" || key === "variableRate" ||
      key === "varibleAmount" || key === "totalReim" || key === "variable" || key === "mileage" || key === "totalMileage" ||
      key === "fixed1" || key === "fixed2" || key === "fixed3") && value !== "null" && value !== null &&
      formattedValue !== '0.00' && formattedValue !== '0.0000' && /^0+/.test(formattedValue)) ? formattedValue.replace(/^0+/, '') : null;
  }

  updateFuelVariableRate(singleValue, key, element) {
    if (key === 'fuel' || key === 'variableRate') {
      if (parseInt(this.defaultYear) === (new Date()).getFullYear()) {
        const nextUpdate = this.currentMonth() ? 'Updated ' + this.currentMonth() + '. 4' : false;
        if (nextUpdate && element['month'] === this.isToday()) {
          singleValue.istwoDecimalCurrency = false;
          singleValue.isfourDecimalCurrency = false;
          singleValue.value = nextUpdate;
        } else if (this.daysAfterActivation) {
          const nextUpdateDay = this.nextMonth() ? 'Updated ' + this.nextMonth() + '. 4' : false;
          if (nextUpdateDay && element['month'] === this.getMonthLong()) {
            singleValue.istwoDecimalCurrency = false;
            singleValue.isfourDecimalCurrency = false;
            singleValue.value = nextUpdateDay;
          }
        }
      }
    }
  }

  assignId(element) {
    if (!this.isTandA) {
      if (this.contactInfo.Reimbursement_Frequency__c === 'Bi-Weekly Reimbursement' && this.contactInfo.Reimbursement_Type__c === 'Mileage Rate') {
        element.id = element.biweekId;
      } else {
        element.id = element.employeeReimbursementId;
      }
    }
  }

  filter(data, keyId) {
    return data.find(el => el.id === keyId);
  }

  getBiweekReimbursement(viewList, yearTo) {
    if (viewList) {
      this.prepareReimbursementView();
    }

    if (this.keyFields && this.column) {
      biweeklyMileage({
        conId: this.contactId,
        year: yearTo,
      })
        .then((result) => {
          this.processResult(result);
          this.setupAccordion();
        })
        .catch((error) => {
          console.error("getBiweekReimbursement error", error);
        });
    }
  }

  prepareReimbursementView() {
    this.isReimbursementView = true;
    this.rKeyFields = [
      "startDate",
      "endDate",
      "mileage",
      "variableRate",
      "variable",
      "totalReim",
    ];
    this.rColumn = [
      { id: 1, name: "Start Date", colName: "startDate" },
      { id: 2, name: "End Date", colName: "endDate" },
      { id: 3, name: "Mileage", colName: "mileage" },
      { id: 4, name: "Mi Rate", colName: "variableRate" },
      { id: 5, name: "Variable", colName: "variable" },
      { id: 6, name: "Total", colName: "totalReim" },
    ];
    this.keyFields = this.rKeyFields;
    this.column = this.rColumn;
  }

  processResult(result) {
    let resultBiweek = this.proxyToObject(result);
    this.accordionList = this.sortByDateDesc(resultBiweek, "startDate");
    this.isDownloadAll = this.accordionList.length > 0;
    this.accordionListColumn = this.column;
    this.accordionKeyFields = this.keyFields;
    this.dynamicBinding(this.accordionList, this.accordionKeyFields);
    this.listOfRecord = this.accordionList.length > 0;
  }

  setupAccordion() {
    const accordionItems = this.template.querySelectorAll(".accordion-item");
    accordionItems.forEach((el) =>
      el.addEventListener("click", () => {
        if (el.classList.contains("active")) {
          if (this.showArrowIcon) {
            el.classList.remove("active");
            this.isDownloadAll = false;
            this.hrClass = false;
            this.listVisible = false;
          }
        } else {
          accordionItems.forEach((el2) => {
            if (this.showArrowIcon) {
              el2.classList.remove("active");
              this.isDownloadAll = false;
              this.hrClass = false;
              this.listVisible = false;
            }
          });
          el.classList.add("active");
          this.isDownloadAll = true;
          this.hrClass = true;
        }
      })
    );
    this.dispatchEvent(
      new CustomEvent("show", { detail: "isHide" })
    );
  }

  setupView(viewList, yearTo) {
    this.defaultYear = yearTo;
    this.isReimbursementView = true;
    const configurations = this.getViewConfiguration(viewList);
    if (configurations) {
      this.keyFields = configurations.keyFields;
      this.column = configurations.column;
    } else {
      this.isReimbursementView = false;
    }
  }

  setupAttendanceView() {
    this.isReimbursementView = true;
    this.rKeyFields = ["startDate", "endDate", "totaldrivingTime", "totalStayTime", "totalTime", "approvalDate", "totalMileage"];
    this.rColumn = [
      { id: 1, name: "Start Date", colName: "startDate" },
      { id: 2, name: "End Date", colName: "endDate" },
      { id: 3, name: "Drive Time", colName: "totaldrivingTime" },
      { id: 4, name: "Stay Time", colName: "totalStayTime" },
      { id: 5, name: "Total Time", colName: "totalTime" },
      { id: 6, name: "Approval Date", colName: "approvalDate" },
      { id: 7, name: "Mileage", colName: "totalMileage" }
    ];
    this.keyFields = this.rKeyFields;
    this.column = this.rColumn;
  }

  getViewConfiguration(viewList) {
    const biWeeklyConfig = {
      keyFields: [
        "month", "fuel", "mileage", "variableRate", "varibleAmount",
        "fixed1", "fixed2", "fixed3", "totalReimbursements"
      ],
      column: [
        { id: 1, name: "Month", colName: "month" },
        { id: 2, name: "Fuel", colName: "fuel" },
        { id: 3, name: "Mileage", colName: "mileage" },
        { id: 4, name: "Mi Rate", colName: "variableRate" },
        { id: 5, name: "Variable", colName: "varibleAmount" },
        { id: 6, name: "Fixed 1", colName: "fixed1" },
        { id: 7, name: "Fixed 2", colName: "fixed2" },
        { id: 8, name: "Fixed 3", colName: "fixed3" },
        { id: 9, name: "Total", colName: "totalReimbursements" }
      ]
    };

    const monthlyFavrConfig = {
      keyFields: [
        "month", "fuel", "mileage", "variableRate", "varibleAmount",
        "fixedAmount", "totalReimbursements"
      ],
      column: [
        { id: 1, name: "Month", colName: "month" },
        { id: 2, name: "Fuel", colName: "fuel" },
        { id: 3, name: "Mileage", colName: "mileage" },
        { id: 4, name: "Mi Rate", colName: "variableRate" },
        { id: 5, name: "Variable", colName: "varibleAmount" },
        { id: 6, name: "Fixed", colName: "fixedAmount" },
        { id: 7, name: "Total", colName: "totalReimbursements" }
      ]
    };

    const monthlyFavrIrsConfig = {
      keyFields: [
        "month", "mileage", "variableRate", "totalReimbursements"
      ],
      column: [
        { id: 1, name: "Month", colName: "month" },
        { id: 2, name: "Mileage", colName: "mileage" },
        { id: 3, name: "Mi Rate", colName: "variableRate" },
        { id: 4, name: "Total", colName: "totalReimbursements" }
      ]
    };

    const monthlyMileageConfig = {
      keyFields: [
        "month", "mileage", "variableRate", "varibleAmount", "totalReimbursements"
      ],
      column: [
        { id: 1, name: "Month", colName: "month" },
        { id: 2, name: "Mileage", colName: "mileage" },
        { id: 3, name: "Mi Rate", colName: "variableRate" },
        { id: 4, name: "Variable", colName: "varibleAmount" },
        { id: 5, name: "Total", colName: "totalReimbursements" }
      ]
    };

    if (viewList.Reimbursement_Frequency__c === 'Bi-Weekly Reimbursement' && viewList.Reimbursement_Type__c === 'FAVR') {
      return biWeeklyConfig;
    } else if (viewList.Reimbursement_Frequency__c === 'Monthly Reimbursement' && viewList.Reimbursement_Type__c === 'FAVR') {
      return this.isIrs ? monthlyFavrIrsConfig : monthlyFavrConfig;
    } else if (viewList.Reimbursement_Frequency__c === 'Monthly Reimbursement' && viewList.Reimbursement_Type__c === 'Mileage Rate') {
      return monthlyMileageConfig;
    } else {
      return null;
    }
  }

  async fetchReimbursements(yearTo) {
    return getAllReimbursements({
      year: yearTo,
      contactId: this.contactId,
      accountId: this.accountId
    });
  }

  processReimbursements(result) {
    const reimbursementList = this.proxyToObject(result[0]);
    this.accordionList = this.sortByMonthDesc(reimbursementList, "month");
    this.isDownloadAll = this.accordionList.length > 0;
    this.accordionListColumn = this.column;
    this.accordionKeyFields = this.keyFields;
    this.dynamicBinding(this.accordionList, this.accordionKeyFields);
    this.listOfRecord = this.accordionList.length > 0;
  }

  processAttendanceResult(result) {
    let resultTA = this.proxyToObject(result);
    this.accordionList = this.sortByDateDesc(resultTA, "startDate");
    this.isDownloadAll = this.accordionList.length > 0;
    this.accordionListColumn = this.column;
    this.accordionKeyFields = this.keyFields;
    this.dynamicBinding(this.accordionList, this.accordionKeyFields);
    this.listOfRecord = this.accordionList.length > 0;
  }

  async getReimbursementFromApex(viewList, yearTo) {
    if (viewList) {
      this.setupView(viewList, yearTo);
    }
    if (this.keyFields && this.column) {
      try {
        const result = await this.fetchReimbursements(yearTo);
        if (result) {
          this.processReimbursements(result);
          this.setupAccordion();
          this.dispatchEvent(new CustomEvent("show", { detail: "isHide" }));
        } else {
          console.error("getAllReimbursements error", result);
        }
      } catch (error) {
        console.error("getReimbursementFromApex error", error);
      }
    }
  }

  getBiweekReim(viewList, yearTo) {
    if (viewList) {
      this.prepareReimbursementView();
    }

    if (this.keyFields && this.column) {
      biweeklyMileage({
        conId: this.contactId,
        year: yearTo,
      })
        .then((result) => {
          this.processResult(result);
        })
        .catch((error) => {
          console.error("getBiweekReimbursement error", error);
        });
    }
  }

 async getReimbursement(viewList, yearTo) {
    if (viewList) {
      this.setupView(viewList, yearTo);
    }
    if (this.keyFields && this.column) {
      try {
        const result = await this.fetchReimbursements(yearTo);
        if (result) {
          this.processReimbursements(result);
          this.dispatchEvent(new CustomEvent("show", { detail: "isHide" }));
        } else {
          console.error("getAllReimbursements error", result);
        }
      } catch (error) {
        console.error("getReimbursementFromApex error", error);
      }
    }
  }

  getTimeAndAttendance(viewList, yearTo) {
    if (viewList) {
      this.setupAttendanceView();
    }
    if (this.keyFields && this.column) {
      timeAttendance({ conId: this.contactId, year: yearTo })
        .then((result) => {
          this.processAttendanceResult(result);
          this.setupAccordion();
          this.dispatchEvent(new CustomEvent("show", { detail: "isHide" }));
        })
        .catch((error) => {
          console.error("getTA error", error);
        });
    }
  }

  getTAndA(viewList, yearTo) {
    if (viewList) {
      this.setupAttendanceView();
    }
    if (this.keyFields && this.column) {
      timeAttendance({ conId: this.contactId, year: yearTo })
        .then((result) => {
          this.processAttendanceResult(result);
          this.dispatchEvent(new CustomEvent("show", { detail: "isHide" }));
        })
        .catch((error) => {
          console.error("getTA error", error);
        });
    }
  }

  fetchReimbursement(event) {
      if (!this.showArrowIcon) return;
      this.accordionList = [];
      this.listOfRecord = this.accordionList.length > 0;
      const lastYear = event ? event.currentTarget.dataset.year : "";
      if(this.isTandA){
        this.getTAndA(this.contactInfo, lastYear);
      }else {
        const { Reimbursement_Frequency__c, Reimbursement_Type__c } = this.contactInfo;
        if (Reimbursement_Frequency__c === 'Bi-Weekly Reimbursement' && Reimbursement_Type__c === 'Mileage Rate') {
          this.getBiweekReim(this.contactInfo, lastYear);
        } else {
          this.getReimbursement(this.contactInfo, lastYear);
        }
      }
  }

  daysBetweenActivation(dateInitial, dateFinal){
    return dateInitial.getMonth() === dateFinal.getMonth() && 
    dateInitial.getFullYear() === dateFinal.getFullYear();
 }

  escapeSpecialChars(str){
    return str
    .replace(/\\'/g, "\'")
    .replace(/\\&#39;/g, "\'")
    .replace(/(&quot\;)/g,"\"");
}

  connectedCallback() {
    this.name = this.contactInfo;
    const currDate = new Date();
    this.daysAfterActivation = this.daysBetweenActivation(new Date(this.activationDate), new Date(currDate.getFullYear(), currDate.getMonth(), 4));
    if (this.accordionData?.[0]?.yearName) {
      if (this.isTandA) {
        this.getTimeAndAttendance(this.contactInfo, this.accordionData[0].yearName);
      }else{
        const { Reimbursement_Frequency__c, Reimbursement_Type__c } = this.contactInfo;
        this.isPayperiod = Reimbursement_Frequency__c === 'Bi-Weekly Reimbursement' && Reimbursement_Type__c === 'Mileage Rate';
        if (this.isPayperiod) {
          this.getBiweekReimbursement(this.contactInfo, this.accordionData[0].yearName);
        } else {
          this.getReimbursementFromApex(this.contactInfo, this.accordionData[0].yearName);
        }
      }
    }
  }

  compareArray(a, b) {
    const dateA = a.startDate ? new Date(a.startDate.toLowerCase()) : '';
    const dateB = b.startDate ? new Date(b.startDate.toLowerCase()) : '';
    return dateA - dateB;
  }

  excelToExport(data, file, sheet){
    this.template.querySelector('c-export-excel').download(data, file, sheet);
  }

  exportTAData(dataList, sheetName) {
    const excelFileName = `${this.contactInfo.Name}'s Detail Report`;
    let headers, keys;
    
    if (!this.isIrs) {
      headers = ["Email", "Tracking method", "Day Of Week", "Trip Date", "Start Time", "End Time", "Origin Name", "Origin Address", "Destination Name", "Destination Address", "Mileage", "Status", "Date Submitted", "Date Processed", "Processed By", "Tags", "Notes", "Maint/Tires", "Fuel Rate", "Mi Rate", "Drive Time", "Stay Time", "Total Time", "Amount"];
      keys = ["emailaddress", "tracingstyle", "dayofweek", "tripdate", "starttime", "endtime", "originname", "origin", "destinationname", "destination", "mileage", "status", "submitteddate", "approveddate", "approvalName", "tag", "notes", "maintTyre", "fuelVariableRate", "variablerate", "drivingtime", "staytime", "totaltime", "variableamount"];
    } else {
      headers = ["Email", "Tracking method", "Day Of Week", "Trip Date", "Start Time", "End Time", "Origin Name", "Origin Address", "Destination Name", "Destination Address", "Mileage", "Status", "Date Submitted", "Date Processed", "Processed By", "Tags", "Notes", "Mi Rate", "Drive Time", "Stay Time", "Total Time", "Amount"];
      keys = ["emailaddress", "tracingstyle", "dayofweek", "tripdate", "starttime", "endtime", "originname", "origin", "destinationname", "destination", "mileage", "status", "submitteddate", "approveddate", "approvalName", "tag", "notes", "variablerate", "drivingtime", "staytime", "totaltime", "variableamount"];
    }
  
    const exportDetailList = createExportDetailList(dataList, headers, keys);
    this.excelToExport(exportDetailList, excelFileName, sheetName);
  }

  exportData(dataList, sheetName) {
    const excelFileName = `${this.contactInfo.Name}'s Detail Report`;
    let headers, keys;
    
    if (!this.isIrs) {
      headers = ["Email", "Month", "Tracking method", "Day Of Week", "Trip Date", "Start Time", "End Time", "Origin Name", "Origin Address", "Destination Name", "Destination Address", "Mileage", "Status", "Date Submitted", "Date Processed", "Processed By", "Tags", "Notes", "Maint/Tires", "Fuel Rate", "Mi Rate", "Amount"];
      keys = ["email", "reimMonth", "tracingStyle", "dayOfWeek", "tripDate", "starttime", "endtime", "originName", "origin", "destinationName", "destination", "mileage", "tripStatus", "submitteddate", "approvedDate", "approvalName", "tag", "notes", "maintTyre", "fuelVaraibleRate", "varaibleRate", "varaibleAmount"];
    } else {
      headers = ["Email", "Month", "Tracking method", "Day Of Week", "Trip Date", "Start Time", "End Time", "Origin Name", "Origin Address", "Destination Name", "Destination Address", "Mileage", "Status", "Date Submitted", "Date Processed", "Processed By", "Tags", "Notes", "Mi Rate",  "Amount"];
      keys = ["email", "reimMonth", "tracingStyle", "dayOfWeek", "tripDate", "starttime", "endtime", "originName", "origin", "destinationName", "destination", "mileage", "tripStatus", "submitteddate", "approvedDate", "approvalName", "tag", "notes", "varaibleRate", "varaibleAmount"];
    }
  
    const exportDetailList = createExportDetailList(dataList, headers, keys);
    this.excelToExport(exportDetailList, excelFileName, sheetName);
  }

  exportBiweekData(biweekList, sheetName) {
    const excelFileName = `${this.contactInfo.Name}'s Detail Report`;
    let headers, keys;
    biweekList.forEach((item)=>{
      item.drivingtime = this.timeConversion(item.drivingtime);
      item.staytime = this.timeConversion(item.staytime);
      item.totaltime =this.timeConversion(item.totaltime);
    })
    if (!this.isIrs) {
      headers = ["Email", "Tracking method", "Day Of Week", "Trip Date", "Start Time", "End Time", "Origin Name", "Origin Address", "Destination Name", "Destination Address", "Mileage", "Status", "Date Submitted", "Date Processed", "Processed By", "Tags", "Notes", "Maint/Tires", "Fuel Rate", "Mi Rate", "Drive Time", "Stay Time", "Total Time", "Trip Type", "Amount", "Fixed Amount"];
      keys = ["emailaddress", "tracingstyle", "dayofweek", "tripdate", "starttime", "endtime", "originname", "origin", "destinationname", "destination", "mileage", "status", "submitteddate", "approveddate", "approvalName", "tag", "notes", "maintTyre", "fuelVariableRate", "variablerate", "drivingtime", "staytime", "totaltime","tripActivity", "variableamount", "halfFixedAmount"];
    } else {
      headers = ["Email", "Tracking method", "Day Of Week", "Trip Date", "Start Time", "End Time", "Origin Name", "Origin Address", "Destination Name", "Destination Address", "Mileage", "Status", "Date Submitted", "Date Processed", "Processed By", "Tags", "Notes", "Mi Rate", "Drive Time", "Stay Time", "Total Time", "Trip Type", "Amount"];
      keys = ["emailaddress", "tracingstyle", "dayofweek", "tripdate", "starttime", "endtime", "originname", "origin", "destinationname", "destination", "mileage", "status", "submitteddate", "approveddate", "approvalName", "tag", "notes", "variablerate", "drivingtime", "staytime", "totaltime","tripActivity", "variableamount"]
    }
  
    const exportDetailList = createExportDetailList(biweekList, headers, keys);
    this.excelToExport(exportDetailList, excelFileName, sheetName);
  }

  downloadAllTrips(event) {
    event.stopPropagation();
  
    if (this.isTandA) {
      this.processTandA();
    } else if (this.contactInfo.Reimbursement_Frequency__c === 'Bi-Weekly Reimbursement' &&
               this.contactInfo.Reimbursement_Type__c === 'Mileage Rate') {
      this.processBiweeklyMileage();
    } else {
      this.processDefault();
    }
  }
  
  processTandA() {
    const downloadList = [...this.accordionList].sort(this.compareArray);
    const { startDate: stDate } = downloadList[0];
    const { endDate: enDate } = downloadList[downloadList.length - 1];
  
    getAllMileages({ startdate: stDate, enddate: enDate, contactId: this.contactId })
      .then(result => {
        if (result && result !== '') {
          const detailList = this.proxyToObject(this.escapeSpecialChars(result[0]));
          if (detailList.length > 0) {
            this.exportTAData(detailList, 'Detail Report');
          } else {
            toastEvents(this, 'No mileage');
          }
        } else {
          console.error("Error", result);
        }
      })
      .catch(error => console.error("error", error));
  }
  
  processBiweeklyMileage() {
    const downloadList = [...this.accordionList].sort(this.compareArray);
    const { startDate: stDate } = downloadList[0];
    const { endDate: enDate } = downloadList[downloadList.length - 1];
  
    getAllMileages({ startdate: stDate, enddate: enDate, contactId: this.contactId })
      .then(result => {
        if (result && result !== '') {
          const biDetailList = this.proxyToObject(this.escapeSpecialChars(result[0]));
          if (biDetailList.length > 0) {
            this.exportBiweekData(biDetailList, 'Detail Report');
          } else {
            toastEvents(this, 'No mileage');
          }
        } else {
          console.error("Error", result);
        }
      })
      .catch(error => console.error("error", error));
  }
  
  processDefault() {
    getMileagesData({ year: parseInt(this.defaultYear), contactId: this.contactId })
      .then(result => {
        if (result && result !== '') {
          const biweekList = this.proxyToObject(result);
          if (biweekList.length > 0) {
            this.exportData(biweekList, 'Detail Report');
          } else {
            toastEvents(this, 'No mileage');
          }
        } else {
          console.error("Error", result);
        }
      })
      .catch(error => console.error("error", error));
  }

  getTrips(event) {
    const isBiWeeklyMileage = this.contactInfo.Reimbursement_Frequency__c === 'Bi-Weekly Reimbursement' && this.contactInfo.Reimbursement_Type__c === 'Mileage Rate';

    const tripInfo = isBiWeeklyMileage 
    ? { boolean: true, trip: event.detail }
    : { boolean: false, month: event.detail, year: this.defaultYear };

    events(this, tripInfo);
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
    return  ymm.toString() + ydd.toString() + yy.toString() + hh.toString() + min.toString() + sec.toString();
  }

  timeConversion(number) {
    var time;
    var hours = Math.floor(number / 60);
    var min = number % 60;
    hours = hours < 10 ? "0" + hours : hours;
    min = min < 10 ? "0" + min : min;
    time = hours + ':' + min;
    //var time = (hours < 12) ? (hours-12 + ':' + min +' PM') : (hours + ':' + min +' AM');
    return time;
  }

  downloadTrips(event){
    let biweekId, month, message, stDate, enDate;
    let element = this.filter(this.accordionList, event.detail);
    if(this.isTandA){
        stDate = element.startDate;
        enDate = element.endDate;
        getMileagesBasedTandAtt({
          startdate: stDate,
          enddate: enDate,
          contactId: this.contactId
        }).then(result=>{
          if (result !== '') {
            let escapeChar = this.escapeSpecialChars(result);
            let detailedList = JSON.parse(escapeChar);
            if(detailedList.length > 0){
              let excelTA = [];
              let excelFileName = this.contactInfo.Name + '\'s Time And Attendance Report ' + this.dateTime(new Date());
              let excelSheetName = 'T and A Report';
              if(!this.isIrs){
                let headers = ["Email", "Tracking method", "Day Of Week", "Trip Date", "Start Time", "End Time", "Origin Name", "Origin Address", "Destination Name", "Destination Address", "Mileage", "Status", "Date Submitted", "Date Processed", "Processed By", "Tags", "Notes", "Maint/Tires", "Fuel Rate", "Mi Rate", "Drive Time", "Stay Time", "Total Time", "Amount"],
                    keys = ["emailaddress", "tracingstyle", "dayofweek", "tripdate", "starttime", "endtime", "originname", "origin", "destinationname", "destination", "mileage", "status", "submitteddate", "approveddate", "approvalName", "tag", "notes", "maintTyre", "fuelVariableRate", "variablerate", "drivingtime", "staytime", "totaltime", "variableamount"]
                excelTA = createExportDetailList(detailedList, headers, keys);
              }else{
                let headers = ["Email", "Tracking method", "Day Of Week", "Trip Date", "Start Time", "End Time", "Origin Name", "Origin Address", "Destination Name", "Destination Address", "Mileage", "Status", "Date Submitted", "Date Processed", "Processed By", "Tags", "Notes", "Mi Rate", "Drive Time", "Stay Time", "Total Time", "Amount"],
                keys = ["emailaddress", "tracingstyle", "dayofweek", "tripdate", "starttime", "endtime", "originname", "origin", "destinationname", "destination", "mileage", "status", "submitteddate", "approveddate", "approvalName", "tag", "notes", "variablerate", "drivingtime", "staytime", "totaltime", "variableamount"]
                excelTA = createExportDetailList(detailedList, headers, keys);
              }
             
              this.excelToExport(excelTA, excelFileName, excelSheetName);
            }else{
              toastEvents(this, 'No mileage')
            }
          }else{
            toastEvents(this, 'No mileage')
          }
        })
    }else{
      if(this.contactInfo.Reimbursement_Frequency__c === 'Bi-Weekly Reimbursement' && this.contactInfo.Reimbursement_Type__c === 'Mileage Rate'){
        biweekId = element.biweekId
        getBiweekMileages({
            biweekId: biweekId
        }).then(result => {
          let escapeChar = this.escapeSpecialChars(result[0]);
          let biweekList = JSON.parse(escapeChar);
          if(biweekList.length > 0){
            let excelReimbursement = [];
            let excelFileName = this.contactInfo.Name + '\'s Mileage Report ' + this.dateTime(new Date());
            let excelSheetName = 'Mileage Report';
            if(!this.isIrs){
              biweekList.forEach((item)=>{
                item.drivingtime = this.timeConversion(item.drivingtime);
                item.staytime = this.timeConversion(item.staytime);
                item.totaltime =this.timeConversion(item.totaltime);
              })
              let headers = ["Email", "Tracking method", "Day Of Week", "Trip Date", "Start Time", "End Time", "Origin Name", "Origin Address", "Destination Name", "Destination Address", "Mileage", "Status", "Date Submitted", "Date Processed", "Processed By", "Tags", "Notes", "Maint/Tires", "Fuel Rate", "Mi Rate", "Drive Time", "Stay Time", "Total Time", "Trip Type", "Amount", "Fixed Amount"],
              keys = ["emailaddress", "tracingstyle", "dayofweek", "tripdate", "starttime", "endtime", "originname", "origin", "destinationname", "destination", "mileage", "status", "submitteddate", "approveddate", "approvalName", "tag", "notes", "maintTyre", "fuelVariableRate", "variablerate", "drivingtime", "staytime", "totaltime","tripActivity", "variableamount", "halfFixedAmount"]
              excelReimbursement = createExportDetailList(biweekList, headers, keys);
            }else{
              biweekList.forEach((item)=>{
                item.drivingtime = this.timeConversion(item.drivingtime);
                item.staytime = this.timeConversion(item.staytime);
                item.totaltime =this.timeConversion(item.totaltime);
              })
              let headers = ["Email", "Tracking method", "Day Of Week", "Trip Date", "Start Time", "End Time", "Origin Name", "Origin Address", "Destination Name", "Destination Address", "Mileage", "Status", "Date Submitted", "Date Processed", "Processed By", "Tags", "Notes", "Mi Rate", "Drive Time", "Stay Time", "Total Time", "Trip Type", "Amount"],
              keys = ["emailaddress", "tracingstyle", "dayofweek", "tripdate", "starttime", "endtime", "originname", "origin", "destinationname", "destination", "mileage", "status", "submitteddate", "approveddate", "approvalName", "tag", "notes", "variablerate", "drivingtime", "staytime", "totaltime","tripActivity", "variableamount"]
              excelReimbursement = createExportDetailList(biweekList, headers, keys);
            }
           
            this.excelToExport(excelReimbursement, excelFileName, excelSheetName);
          }else{
            toastEvents(this, 'No mileage')
          }

        }).catch(error => {
          if (Array.isArray(error.body)) {
            message = error.body.map((e) => e.message).join(", ");
          } else if (typeof error.body.message === "string") {
            message = error.body.message;
          }

          console.log("Error getBiweekMileages", message)
        })
      }
     else{
        month = element.month;
        getMileages({
          clickedMonth: month,
          year: this.defaultYear,
          contactId: this.contactId
        }).then(result=>{
          let escapeChar = this.escapeSpecialChars(result[0]);
          let mileageList = JSON.parse(escapeChar);
          if(mileageList.length > 0){
            let excelMileage = [];
            let excelFileName = this.contactInfo.Name + '\'s Mileage Report ' + this.dateTime(new Date());
            let excelSheetName = 'Mileage Report';
            if(!this.isIrs){
              let headers = ["Email", "Tracking method", "Day Of Week", "Trip Date", "Start Time", "End Time", "Origin Name", "Origin Address", "Destination Name", "Destination Address", "Mileage", "Status", "Date Submitted", "Date Processed", "Processed By", "Tags", "Notes", "Maint/Tires", "Fuel Rate", "Mi Rate", "Amount"],
              keys = ["emailaddress", "tracingstyle", "dayofweek", "tripdate", "starttime", "endtime", "originname", "origin", "destinationname", "destination", "mileage", "status", "submitteddate", "approveddate", "approvalName", "tag", "notes", "maintTyre", "fuelVariableRate", "variablerate", "variableamount"]
              excelMileage = createExportDetailList(mileageList, headers, keys);
              
            }else{
              let headers = ["Email", "Tracking method", "Day Of Week", "Trip Date", "Start Time", "End Time", "Origin Name", "Origin Address", "Destination Name", "Destination Address", "Mileage", "Status", "Date Submitted", "Date Processed", "Processed By", "Tags", "Notes", "Mi Rate", "Amount"],
              keys = ["emailaddress", "tracingstyle", "dayofweek", "tripdate", "starttime", "endtime", "originname", "origin", "destinationname", "destination", "mileage", "status", "submitteddate", "approveddate", "approvalName", "tag", "notes", "variablerate", "variableamount"]
              excelMileage = createExportDetailList(mileageList, headers, keys);
            }
           
            this.excelToExport(excelMileage, excelFileName, excelSheetName);
          }else{
            toastEvents(this, 'No mileage')
          }
        }).catch(error => {
          if (Array.isArray(error.body)) {
            message = error.body.map((e) => e.message).join(", ");
          } else if (typeof error.body.message === "string") {
            message = error.body.message;
          }

        })
      }
    }
  }

  insideClick(event){
    event.stopPropagation();
  }

}