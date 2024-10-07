/* eslint-disable @lwc/lwc/no-api-reassignments */
/* eslint-disable no-useless-escape */
import { LightningElement, api, track } from "lwc";
import resourceImage from '@salesforce/resourceUrl/mBurseCss';
import mBurseCss from '@salesforce/resourceUrl/LwcDesignImage';
import getAllReimbursements from "@salesforce/apex/DriverDashboardLWCController.getAllReimbursements";
import getMileages  from '@salesforce/apex/DriverDashboardLWCController.getMileages';
import getMileagesData from '@salesforce/apex/DriverDashboardLWCController.getMileagesData';
import getBiweekMileages  from '@salesforce/apex/DriverDashboardLWCController.getBiweekMileages';
import getAllMileages  from '@salesforce/apex/DriverDashboardLWCController.getAllMileages';
import biweeklyMileage from "@salesforce/apex/DriverDashboardLWCController.biweeklyMileage";
import TimeAttendance from "@salesforce/apex/DriverDashboardLWCController.TimeAttendance";
import getMileagesBasedTandAtt from "@salesforce/apex/DriverDashboardLWCController.getMileagesBasedTandAtt";
import {
  events, toastEvents
} from 'c/utils';
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
  systemLoader = mBurseCss + '/Resources/PNG/Green/6.png';
  loadingGif = resourceImage + '/mburse/assets/mBurse-Icons/Bar-style.gif';
  defaultYear = '';
  isReimbursementView = false;
  isScrollable = false;
  listOfRecord = false;
  daysAfterActivation;
  noMessage = 'No data available';
 @track listVisible = false;
  isRowDn = true;
  sortable =  false;
  name;
  @track accordionList = [];
  accordionKeyFields;
  accordionListColumn;
  paginated = false;
  keyFields;
  isPayperiod = false;
  column;
  _RkeyFields;
  _Rcolumn;
  downloadIcon = resourceImage + '/mburse/assets/mBurse-Icons/download-all.png';
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

  sortByDateDesc(data, colName) {
    data.sort((a, b) => {
      a = a[colName] ? new Date(a[colName].toLowerCase()) : "";
      b = b[colName] ? new Date(b[colName].toLowerCase()) : "";
      return a > b ? -1 : 1;
    });
    return data;
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

  getMonthLong(){
    const date = new Date();
    const formatter = new Intl.DateTimeFormat("default", {
        month: "long"
      });
    let month = formatter.format(
        new Date(date.getFullYear(), date.getMonth())
    );

    return month
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

  dynamicBinding(data, keyFields) {
    data.forEach((element) => {
      let model = [];
      Object.keys(element).forEach(key => {
        // let key = entry[0];
        // let value = entry[1];
        let singleValue = {};
        if (keyFields.includes(key) !== false) {
          if (this.contactInfo.Reimbursement_Frequency__c === 'Bi-Weekly Reimbursement' && this.contactInfo.Reimbursement_Type__c === 'Mileage Rate') {
            singleValue.id = element.biweekId;
            singleValue.eDate = element.endDate;
            singleValue.sDate = element.startDate;
          }
          singleValue.key = key;
          singleValue.value = (element[key] === "null" || element[key] === null) ? "" : (key === "variableRate" || key === "varibleAmount" || key === 'fixed1' || key === 'fixed2' ||
            key === 'fixed3' ||
            key === 'totalFixedAmount' || key === "totalReimbursements") ? element[key].replace(/\$/g, "").replace(/\s/g, "") : element[key];
          singleValue.icon = (!this.isTandA) ? (key === "month" || key === "startDate") ? true : false : false;
          singleValue.bold = (key === "totalReimbursements" || key === "totalReim") ? true : false;
          singleValue.twoDecimal = (key === "mileage" || key === "totalMileage") ? true : false;
          singleValue.isDate = (key === "startDate" || key === "endDate" || key === "approvalDate") && (element[key] !== null) ? true : false;
          singleValue.isfourDecimalCurrency = (key === 'variableRate' || key === 'VariableRate')  && (element[key] !== null) ? true : false;
          singleValue.istwoDecimalCurrency = (key === "fuel" ||
            key === "fixedAmount" ||
            key === "fixed1" ||
            key === "fixed2" ||
            key === "fixed3" ||
            key === "totalReimbursements" ||
            key === "varibleAmount" ||
            key === "totalReim" ||
            key === "variable") ? (element[key] === "null" || element[key] === null) ? false : true : false;
          singleValue.hasLeadingZero = ((key === "fuel" ||
            key === "fixedAmount" ||
            key === "totalReimbursements" ||
            key === "variableRate" ||
            key === "varibleAmount" ||
            key === "totalReim" ||
            key === "variable" || key === "mileage" || key === "totalMileage" ||
            key === "fixed1" || key === "fixed2" ||
            key === "fixed3") && ((element[key] !== "null" || element[key] !== null) && (singleValue.value !== '0.00') && (singleValue.value !== '0.0000')) && (/^0+/).test(singleValue.value) === true) ? (singleValue.value).replace(/^0+/, '') : null;
            if(key === 'fuel' || key === 'variableRate'){
              if(parseInt(this.defaultYear) === (new Date()).getFullYear()){
                const nextUpdate = (this.currentMonth()) ? 'Updated ' + this.currentMonth() + '. 4' : false;
                console.log("inside activation--", this.daysAfterActivation, nextUpdate)
                if(nextUpdate){
                      if(element['month'] === this.isToday()){
                          singleValue.istwoDecimalCurrency = false
                          singleValue.isfourDecimalCurrency = false
                          singleValue.value = nextUpdate
                      } 
                }else{
                  if(this.daysAfterActivation){
                      const nextUpdateDay = (this.nextMonth()) ? 'Updated ' + this.nextMonth() + '. 4' : false;
                      if(nextUpdateDay){
                        if(element['month'] === this.getMonthLong()){
                          console.log("month--", this.getMonthLong())
                          singleValue.istwoDecimalCurrency = false
                          singleValue.isfourDecimalCurrency = false
                          singleValue.value = nextUpdateDay
                        }
                      }
                  }
                }
              }
            }
          model.push(singleValue);
        }
        //use key and value here
      });
      if (!this.isTandA) {
        if (this.contactInfo.Reimbursement_Frequency__c === 'Bi-Weekly Reimbursement' && this.contactInfo.Reimbursement_Type__c === 'Mileage Rate') {
          element.id = element.biweekId;
        } else {
          element.id = element.employeeReimbursementId;
        }
      }

      element.keyFields = this.mapOrder(model, keyFields, "key");
    });
  }

  filter(data, keyId){
    let object
    data.forEach(e => {
        if(e.id === keyId){
          object = e
        }
      })
      return object
  }

  getBiweekReimbursement(viewList, yearTo) {
    if (viewList) {
      this.isReimbursementView = true;
      // this.dispatchEvent(
      //   new CustomEvent("show", {
      //     detail: "isShow"
      //   })
      // );
      this._RkeyFields = [
        "startDate",
        "endDate",
        "mileage",
        "variableRate",
        "variable",
        "totalReim"
      ];
      this._Rcolumn = [
        {
          id: 1,
          name: "Start Date",
          colName: "startDate"
        },
        {
          id: 2,
          name: "End Date",
          colName: "endDate"
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
          colName: "variable"
        },
        {
          id: 6,
          name: "Total",
          colName: "totalReim"
        }
      ];

      this.keyFields = this._RkeyFields;
      this.column = this._Rcolumn;
    }
    if (this.keyFields !== undefined && this.column !== undefined) {
      biweeklyMileage({
        conId: this.contactId,
        year: yearTo
      })
        .then((result) => {
          let resultBiweek = this.proxyToObject(result);
          this.accordionList = this.sortByDateDesc(resultBiweek, "startDate");
        //  this.listVisible = this.accordionList.length > 0 ? true : false;
          this.isDownloadAll = this.accordionList.length > 0 ? true : false;
          this.accordionListColumn = this.column;
          this.accordionKeyFields = this.keyFields;
          this.dynamicBinding(this.accordionList, this.accordionKeyFields);
          this.listOfRecord = this.accordionList.length > 0 ? true : false;
          const accordionItem =
          this.template.querySelectorAll(".accordion-item");
          accordionItem.forEach((el) =>
            el.addEventListener("click", () => {
              if (el.classList.contains("active")) {
                if(this.showArrowIcon){
                  el.classList.remove("active");
                  this.isDownloadAll = false;
                  this.hrClass = false;
                }
              } else {
                accordionItem.forEach((el2) =>  {
                  if(this.showArrowIcon){
                    el2.classList.remove("active");
                    this.isDownloadAll = false;
                    this.hrClass = false;
                  }
                });
                el.classList.add("active");
                this.isDownloadAll = true;
                this.hrClass = true;
              }
            })
          );
          console.log("getBiweekReimbursement ----", result);
          this.dispatchEvent(
            new CustomEvent("show", {
              detail: "isHide"
            })
          );
        })
        .catch((error) => {
          console.log("getBiweekReimbursement error", error);
        });
    }
  }

  async getReimbursementFromApex(viewList, yearTo) {
    if (viewList) {
      // this.dispatchEvent(
      //   new CustomEvent("show", {
      //     detail: "isShow"
      //   })
      // );
      this.defaultYear = yearTo;
      this.isReimbursementView = true;
      if (viewList.Reimbursement_Frequency__c === 'Bi-Weekly Reimbursement' && viewList.Reimbursement_Type__c === 'FAVR') {
        /* Bi-weekly fixed and Monthly variable */  // This is for Bi_Week_Fixed_Amount__c
        this._RkeyFields = [
          "month",
          "fuel",
          "mileage",
          "variableRate",
          "varibleAmount",
          "fixed1",
          "fixed2",
          "fixed3",
          "totalReimbursements"
        ];
        this._Rcolumn = [
          {
            id: 1,
            name: "Month",
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
            name: "Fixed 1",
            colName: "fixed1"
          },
          {
            id: 7,
            name: "Fixed 2",
            colName: "fixed2"
          },
          {
            id: 8,
            name: "Fixed 3",
            colName: "fixed3"
          },
          {
            id: 9,
            name: "Total",
            colName: "totalReimbursements"
          }
        ];

        this.keyFields = this._RkeyFields;
        this.column = this._Rcolumn;
      } else if (viewList.Reimbursement_Frequency__c === 'Monthly Reimbursement' && viewList.Reimbursement_Type__c === 'FAVR' ) { //This is for Monthly_Reimbursement__c
        /* Monthly fixed and variable */
        if(!this.isIrs){
          this._RkeyFields = [
            "month",
            "fuel",
            "mileage",
            "variableRate",
            "varibleAmount",
            "fixedAmount",
            "totalReimbursements"
          ];
          this._Rcolumn = [
            {
              id: 1,
              name: "Month",
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
            }
          ];
        }else{
          this._RkeyFields = [
            "month",
            "mileage",
            "variableRate",
            "totalReimbursements"
          ];
          this._Rcolumn = [
            {
              id: 1,
              name: "Month",
              colName: "month"
            },
            {
              id: 2,
              name: "Mileage",
              colName: "mileage"
            },
            {
              id: 3,
              name: "Mi Rate",
              colName: "variableRate"
            },
            {
              id: 4,
              name: "Total",
              colName: "totalReimbursements"
            }
          ];
        }
       

        this.keyFields = this._RkeyFields;
        this.column = this._Rcolumn;
      } else if (viewList.Reimbursement_Frequency__c === 'Monthly Reimbursement' && viewList.Reimbursement_Type__c === 'Mileage Rate' ) {
        /* Monthly mileage rate */
        this._RkeyFields = [
          "month",
          "mileage",
          "variableRate",
          "varibleAmount",
          "totalReimbursements"
        ];
        this._Rcolumn = [
          {
            id: 1,
            name: "Month",
            colName: "month"
          },
          {
            id: 2,
            name: "Mileage",
            colName: "mileage"
          },
          {
            id: 3,
            name: "Mi Rate",
            colName: "variableRate"
          },
          {
            id: 4,
            name: "Variable",
            colName: "varibleAmount"
          },
          {
            id: 5,
            name: "Total",
            colName: "totalReimbursements"
          }
        ];

        this.keyFields = this._RkeyFields;
        this.column = this._Rcolumn;
      }else{
        this.isReimbursementView = false;
        console.log("inside list")
      }
    }

    if (this.keyFields !== undefined && this.column !== undefined) {
      return new Promise(async (resolve, reject) =>{
        var result = await getAllReimbursements({
          year: yearTo,
          contactId: this.contactId,
          accountId: this.accountId
        });
        resolve(result)
				console.log("REsult", result)
        if(result){
          let reimbursementList = this.proxyToObject(result[0]);
          this.accordionList = this.sortByMonthDesc(reimbursementList, "month");
          this.isDownloadAll = this.accordionList.length > 0 ? true : false;
          this.accordionListColumn = this.column;
          this.accordionKeyFields = this.keyFields;
          this.dynamicBinding(this.accordionList, this.accordionKeyFields);
          this.listOfRecord = this.accordionList.length > 0 ? true : false;
          const accordionItem =
            this.template.querySelectorAll(".accordion-item");
            accordionItem.forEach((el) =>
              el.addEventListener("click", () => {
                if (el.classList.contains("active")) {
                  if(this.showArrowIcon){
                    el.classList.remove("active");
                    this.hrClass = false;
                    this.isDownloadAll = false;
                    this.listVisible = false;
                  }
            
                } else {
                  accordionItem.forEach((el2) =>  {
                    if(this.showArrowIcon){
                      el2.classList.remove("active");
                      this.hrClass = false;
                      this.isDownloadAll = false;
                      this.listVisible = false;
                    }
                  });
                  el.classList.add("active");
                  this.hrClass = true;
                  this.isDownloadAll = true;
                }
              })
            );
          console.log("getAllReimbursements ----", result, this.hrClass);
          this.dispatchEvent(
            new CustomEvent("show", {
              detail: "isHide"
            })
          );
        }else{
          console.log("getAllReimbursements error", error);
        }
      })
      
    }
  }

  getBiweekReim(viewList, yearTo) {
    this.defaultYear = yearTo;
    this.isReimbursementView = true;
    // this.dispatchEvent(
    //   new CustomEvent("show", {
    //     detail: "isShow"
    //   })
    // );
    if (viewList) {
      this._RkeyFields = [
        "startDate",
        "endDate",
        "mileage",
        "variableRate",
        "variable",
        "totalReim"
      ];
      this._Rcolumn = [
        {
          id: 1,
          name: "Start Date",
          colName: "startDate"
        },
        {
          id: 2,
          name: "End Date",
          colName: "endDate"
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
          colName: "variable"
        },
        {
          id: 6,
          name: "Total",
          colName: "totalReim"
        }
      ];

      this.keyFields = this._RkeyFields;
      this.column = this._Rcolumn;
    }
    if (this.keyFields !== undefined && this.column !== undefined) {
      biweeklyMileage({
        conId: this.contactId,
        year: yearTo
      })
        .then((result) => {
          let resultBiweek = this.proxyToObject(result);
          this.accordionList = this.sortByDateDesc(resultBiweek, "startDate");
          //this.listVisible = this.accordionList.length > 0 ? true : false;
          this.isDownloadAll = this.accordionList.length > 0 ? true : false;
          this.accordionListColumn = this.column;
          this.accordionKeyFields = this.keyFields;
          this.dynamicBinding(this.accordionList, this.accordionKeyFields);
          this.listOfRecord = this.accordionList.length > 0 ? true : false;
          this.dispatchEvent(
            new CustomEvent("show", {
              detail: "isHide"
            })
          );
          console.log("getBiweekReimbursement ----", result);
        })
        .catch((error) => {
          console.log("getBiweekReimbursement error", error);
        });
    }
  }

 async getReimbursement(viewList, yearTo) {
    this.defaultYear = yearTo;
    // this.dispatchEvent(
    //   new CustomEvent("show", {
    //     detail: "isShow"
    //   })
    // );
    if (viewList) {
      this.isReimbursementView = true;
      if (viewList.Reimbursement_Frequency__c === 'Bi-Weekly Reimbursement' && viewList.Reimbursement_Type__c === 'FAVR') {
        /* Bi-weekly fixed and Monthly variable */
        this._RkeyFields = [
          "month",
          "fuel",
          "mileage",
          "variableRate",
          "varibleAmount",
          "fixed1",
          "fixed2",
          "fixed3",
          "totalReimbursements"
        ];
        this._Rcolumn = [
          {
            id: 1,
            name: "Month",
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
            name: "Fixed 1",
            colName: "fixed1"
          },
          {
            id: 7,
            name: "Fixed 2",
            colName: "fixed2"
          },
          {
            id: 8,
            name: "Fixed 3",
            colName: "fixed3"
          },
          {
            id: 9,
            name: "Total",
            colName: "totalReimbursements"
          }
        ];

        this.keyFields = this._RkeyFields;
        this.column = this._Rcolumn;
      } else if (viewList.Reimbursement_Frequency__c === 'Monthly Reimbursement' && viewList.Reimbursement_Type__c === 'FAVR') {
        /* Monthly fixed and variable */
        if(!this.isIrs){
          this._RkeyFields = [
            "month",
            "fuel",
            "mileage",
            "variableRate",
            "varibleAmount",
            "fixedAmount",
            "totalReimbursements"
          ];
          this._Rcolumn = [
            {
              id: 1,
              name: "Month",
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
            }
          ];
        }else{
          this._RkeyFields = [
            "month",
            "mileage",
            "variableRate",
            "totalReimbursements"
          ];
          this._Rcolumn = [
            {
              id: 1,
              name: "Month",
              colName: "month"
            },
            {
              id: 2,
              name: "Mileage",
              colName: "mileage"
            },
            {
              id: 3,
              name: "Mi Rate",
              colName: "variableRate"
            },
            {
              id: 4,
              name: "Total",
              colName: "totalReimbursements"
            }
          ];
        }
       

        this.keyFields = this._RkeyFields;
        this.column = this._Rcolumn;
      } else if(viewList.Reimbursement_Frequency__c === 'Monthly Reimbursement' && viewList.Reimbursement_Type__c === 'Mileage Rate'){
        /* Monthly mileage rate */
        this._RkeyFields = [
          "month",
          "mileage",
          "variableRate",
          "varibleAmount",
          "totalReimbursements"
        ];
        this._Rcolumn = [
          {
            id: 1,
            name: "Month",
            colName: "month"
          },
          {
            id: 2,
            name: "Mileage",
            colName: "mileage"
          },
          {
            id: 3,
            name: "Mi Rate",
            colName: "variableRate"
          },
          {
            id: 4,
            name: "Variable",
            colName: "varibleAmount"
          },
          {
            id: 5,
            name: "Total",
            colName: "totalReimbursements"
          }
        ];

        this.keyFields = this._RkeyFields;
        this.column = this._Rcolumn;
      }else{
        this.isReimbursementView = false;
      }
    }

    if (this.keyFields !== undefined && this.column !== undefined) {
      return new Promise(async (resolve, reject) =>{
      var result = await getAllReimbursements({
        year: yearTo,
        contactId: this.contactId,
        accountId: this.accountId
      })
      resolve(result)
			console.log("REsult", result)
      if(result){
          let reimbursementList = this.proxyToObject(result[0]);
          this.accordionList = this.sortByMonthDesc(reimbursementList, "month");
          this.isDownloadAll = this.accordionList.length > 0 ? true : false;
          this.accordionListColumn = this.column;
          this.accordionKeyFields = this.keyFields;
          console.log("Default--", this.defaultYear)
          this.dynamicBinding(this.accordionList, this.accordionKeyFields);
          this.listOfRecord = this.accordionList.length > 0 ? true : false;
          this.dispatchEvent(
            new CustomEvent("show", {
              detail: "isHide"
            })
          );
          console.log("getAllReimbursements ----", result);
        }else {
          console.log("getAllReimbursements error", error);
        }
      });
    }
  }

  getTAndA(viewList, yearTo){
    this.defaultYear = yearTo;
    this.isReimbursementView = true;
    // this.dispatchEvent(
    //   new CustomEvent("show", {
    //     detail: "isShow"
    //   })
    // );
    if (viewList) {
      this._RkeyFields = [
        "startDate",
        "endDate",
        "totaldrivingTime",
        "totalStayTime",
        "totalTime",
        "approvalDate",
        "totalMileage"
      ];
      this._Rcolumn = [
        {
          id: 1,
          name: "Start Date",
          colName: "startDate"
        },
        {
          id: 2,
          name: "End Date",
          colName: "endDate"
        },
        {
          id: 3,
          name: "Drive Time",
          colName: "totaldrivingTime"
        },
        {
          id: 4,
          name: "Stay Time",
          colName: "totalStayTime"
        },
        {
          id: 5,
          name: "Total Time",
          colName: "totalTime"
        },
        {
          id: 6,
          name: "Approval Date",
          colName: "approvalDate"
        },{
          id: 7,
          name: "Mileage",
          colName: "totalMileage"
        }
      ];

      this.keyFields = this._RkeyFields;
      this.column = this._Rcolumn;
    }
    if (this.keyFields !== undefined && this.column !== undefined) {
      TimeAttendance({
        conId: this.contactId,
        year: yearTo
      })
        .then((result) => {
          console.log("getTA ----", result);
          let resultTA= this.proxyToObject(result);
          this.accordionList = this.sortByDateDesc(resultTA, "startDate");
          this.isDownloadAll = this.accordionList.length > 0 ? true : false;
          this.accordionListColumn = this.column;
          this.accordionKeyFields = this.keyFields;
          this.dynamicBinding(this.accordionList, this.accordionKeyFields);
          this.listOfRecord = this.accordionList.length > 0 ? true : false;
          this.dispatchEvent(
            new CustomEvent("show", {
              detail: "isHide"
            })
          );
        })
        .catch((error) => {
          console.log("getTA error", error);
        });
    }
  }

  getTimeAndAttendance(viewList, yearTo) {
    if (viewList) {
      this.isReimbursementView = true;
      // this.dispatchEvent(
      //   new CustomEvent("show", {
      //     detail: "isShow"
      //   })
      // );
      this._RkeyFields = [
        "startDate",
        "endDate",
        "totaldrivingTime",
        "totalStayTime",
        "totalTime",
        "approvalDate",
        "totalMileage"
      ];
      this._Rcolumn = [
        {
          id: 1,
          name: "Start Date",
          colName: "startDate"
        },
        {
          id: 2,
          name: "End Date",
          colName: "endDate"
        },
        {
          id: 3,
          name: "Drive Time",
          colName: "totaldrivingTime"
        },
        {
          id: 4,
          name: "Stay Time",
          colName: "totalStayTime"
        },
        {
          id: 5,
          name: "Total Time",
          colName: "totalTime"
        },
        {
          id: 6,
          name: "Approval Date",
          colName: "approvalDate"
        },
        {
          id: 7,
          name: "Mileage",
          colName: "totalMileage"
        }
      ];

      this.keyFields = this._RkeyFields;
      this.column = this._Rcolumn;
    }
    if (this.keyFields !== undefined && this.column !== undefined) {
      TimeAttendance({
        conId: this.contactId,
        year: yearTo
      })
        .then((result) => {
          console.log("getTA ----", result);
          let resultTA= this.proxyToObject(result);
          this.accordionList = this.sortByDateDesc(resultTA, "startDate");
          this.isDownloadAll = this.accordionList.length > 0 ? true : false;
          this.accordionListColumn = this.column;
          this.accordionKeyFields = this.keyFields;
          this.dynamicBinding(this.accordionList, this.accordionKeyFields);
          this.listOfRecord = this.accordionList.length > 0 ? true : false;
         const accordionItem =
            this.template.querySelectorAll(".accordion-item");
          accordionItem.forEach((el) =>
            el.addEventListener("click", () => {
              if (el.classList.contains("active")) {
                if(this.showArrowIcon){
                  el.classList.remove("active");
                  this.hrClass = false;
                  this.isDownloadAll = false;
                  this.listVisible = false;
                }
              } else {
                accordionItem.forEach((el2) =>  {
                  if(this.showArrowIcon){
                    el2.classList.remove("active");
                    this.hrClass = false;
                    this.isDownloadAll = false;
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
            new CustomEvent("show", {
              detail: "isHide"
            })
          );
        })
        .catch((error) => {
          console.log("getTA error", error);
        });
    }
  }

  fetchReimbursement(event) {
    console.log("this.showArrowIcon", this.showArrowIcon)
    if(this.showArrowIcon){
      this.accordionList = [];
      this.listOfRecord = this.accordionList.length > 0 ? true : false;
      let lastYear = event ? event.currentTarget.dataset.year : "";
      if(this.isTandA){
        this.getTAndA(
          this.contactInfo,
          lastYear
        );
      }else{
          if (this.contactInfo.Reimbursement_Frequency__c === 'Bi-Weekly Reimbursement' && this.contactInfo.Reimbursement_Type__c === 'Mileage Rate') {
            this.getBiweekReim(this.contactInfo, lastYear);
          } else {
            this.getReimbursement(this.contactInfo, lastYear);
          }
      }
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

  escapeSpecialChars(str){
    return str
    .replace(/\\'/g, "\'")
    .replace(/\\&#39;/g, "\'")
    .replace(/(&quot\;)/g,"\"");
}

  connectedCallback() {
    this.name = this.contactInfo;
    let currDate = new Date();
    console.log("Date---",this.activationDate)
    this.daysAfterActivation = this.daysBetweenActivation(new Date(this.activationDate), new Date(currDate.getFullYear(), currDate.getMonth(), 4));
    if(this.isTandA){
      if(this.accordionData){
        if(this.accordionData[0].yearName){
          this.getTimeAndAttendance(
            this.contactInfo,
            this.accordionData[0].yearName
          );
        }
      }
    }else{
      if (this.contactInfo.Reimbursement_Frequency__c === 'Bi-Weekly Reimbursement' && this.contactInfo.Reimbursement_Type__c === 'Mileage Rate') { // !this.contactInfo.Biweek_Reimbursement__c
          this.isPayperiod = (this.contactInfo.Reimbursement_Frequency__c === 'Bi-Weekly Reimbursement' && this.contactInfo.Reimbursement_Type__c === 'Mileage Rate') ? true : false //this.contactInfo.Biweek_Reimbursement__c;
          console.log("inside biweek done")
        if(this.accordionData){
          if(this.accordionData[0].yearName){
            this.getBiweekReimbursement(
              this.contactInfo,
              this.accordionData[0].yearName
            );
          }
        }
      } else {
        console.log("inside biweek")
        if(this.accordionData){
          if(this.accordionData[0].yearName){
            this.getReimbursementFromApex(
              this.contactInfo,
              this.accordionData[0].yearName
            );
          }
        }
      }
    }
  }

  compareArray(a, b) {
      var dateA = (a.startDate == null) ? '' : new Date(a.startDate.toLowerCase()),
          dateB = (b.startDate == null) ? '' : new Date(b.startDate.toLowerCase())
      if (dateA < dateB) {
          return -1;
      }
      if (dateA > dateB) {
          return 1;
      }
      return 0;
  }

  excelToExport(data, file, sheet){
    this.template.querySelector('c-export-excel').download(data, file, sheet);
  }

  downloadAllTrips(event){
    event.stopPropagation();
    if(this.isTandA){
      let exportDetailList = [];
      const downloadList = [...this.accordionList]; // does not mutuate original array
      downloadList.sort(this.compareArray);
      let lengthOfReimb = downloadList.length;
      let stDate = downloadList[0].startDate;
      let enDate = downloadList[lengthOfReimb - 1].endDate;
      getAllMileages({
        startdate: stDate,
        enddate: enDate,
        contactId: this.contactId
      }).then(result => {
        console.log(result);
        if (result != null) {
          if (result !== '') {
              let escapeChar = this.escapeSpecialChars(result[0]);
              let detailList = this.proxyToObject(escapeChar);
              if(detailList.length > 0){
                  let excelFileName = this.contactInfo.Name + '\'s Detail Report';
                  let excelSheetName = 'Detail Report';
                  if(!this.isIrs){
                    exportDetailList.push(["Contact Email", "Tracking Style", "Day Of Week", "Trip Date", "Start Time", "End Time", "Trip Origin", "Trip Destination",  "Status", "Date Submitted", "Date Approved", "Maint/Tires", "Fuel Rate", "Mileage", "Mi Rate", "Amount", "Drive Time", "Stay Time", "Total Time", "Notes", "Tags"]);
                    detailList.forEach(function (item) {
                      exportDetailList.push([item.emailaddress, item.tracingstyle, item.dayofweek, item.tripdate, item.starttime, item.endtime, item.originname, item.destinationname, item.status, item.submitteddate, item.approveddate, item.maintTyre, item.fuelVariableRate, item.mileage, item.variablerate, item.variableamount, item.drivingtime, item.staytime, item.totaltime, item.notes, item.tag]);
                    });
                  }else{
                    exportDetailList.push(["Contact Email", "Tracking Style", "Day Of Week", "Trip Date", "Start Time", "End Time", "Trip Origin", "Trip Destination",  "Status", "Date Submitted", "Date Approved", "Mileage", "Mi Rate", "Amount", "Drive Time", "Stay Time", "Total Time", "Notes", "Tags"]);
                    detailList.forEach(function (item) {
                      exportDetailList.push([item.emailaddress, item.tracingstyle, item.dayofweek, item.tripdate, item.starttime, item.endtime, item.originname, item.destinationname, item.status, item.submitteddate, item.approveddate, item.mileage, item.variablerate, item.variableamount, item.drivingtime, item.staytime, item.totaltime, item.notes, item.tag]);
                    });
                  }
                this.excelToExport(exportDetailList, excelFileName, excelSheetName)
              }else{
                toastEvents(this, 'No mileage')
              }
          }
          else {
            console.log("Error", result)
          }
      }
      }).catch(error=>{
        console.log("error", error)
      })
    }else{
      if(this.contactInfo.Reimbursement_Frequency__c === 'Bi-Weekly Reimbursement' && this.contactInfo.Reimbursement_Type__c === 'Mileage Rate'){
        let exportReimDetailList = [];
        const downloadList = [...this.accordionList]; // does not mutuate original array
        downloadList.sort(this.compareArray);
        let lengthOfReimb = downloadList.length;
        let stDate = downloadList[0].startDate;
        let enDate = downloadList[lengthOfReimb - 1].endDate;
        getAllMileages({
          startdate: stDate,
          enddate: enDate,
          contactId: this.contactId
        }).then(result => {
          console.log(result);
          if (result != null) {
            if (result !== '') {
                let escapeChar = this.escapeSpecialChars(result[0]);
                let biDetailList = this.proxyToObject(escapeChar);
                if(biDetailList.length > 0){
                    let excelFileName = this.contactInfo.Name + '\'s Detail Report';
                    let excelSheetName = 'Detail Report';
                    if(!this.isIrs){
                      exportReimDetailList.push(["Contact Email", "Tracking Style", "Day Of Week", "Trip Date", "Start Time", "End Time", "Trip Origin", "Trip Destination", "Status", "Date Submitted", "Date Approved", "Maint/Tires", "Fuel Rate", "Mileage", "Mi Rate", "Amount", "Fixed Amount", "Trip Type", "Drive Time", "Stay Time", "Total Time", "Notes", "Tags"]);
                      biDetailList.forEach(function (item) {
                          exportReimDetailList.push([item.emailaddress, item.tracingstyle, item.dayofweek, item.tripdate, item.starttime, item.endtime, item.originname, item.destinationname, item.status, item.submitteddate, item.approveddate, item.maintTyre, item.fuelVariableRate,  item.mileage, item.variablerate, item.variableamount, item.halfFixedAmount, item.tripActivity, item.drivingtime, item.staytime, item.totaltime, item.notes, item.tag]);
                      });
                    }else{
                      exportReimDetailList.push(["Contact Email", "Tracking Style", "Day Of Week", "Trip Date", "Start Time", "End Time", "Trip Origin", "Trip Destination", "Status", "Date Submitted", "Date Approved", "Mileage", "Mi Rate", "Amount", "Fixed Amount", "Trip Type", "Drive Time", "Stay Time", "Total Time", "Notes", "Tags"]);
                      biDetailList.forEach(function (item) {
                          exportReimDetailList.push([item.emailaddress, item.tracingstyle, item.dayofweek, item.tripdate, item.starttime, item.endtime, item.originname, item.destinationname, item.status, item.submitteddate, item.approveddate, item.mileage, item.variablerate, item.variableamount, item.halfFixedAmount, item.tripActivity, item.drivingtime, item.staytime, item.totaltime, item.notes, item.tag]);
                      });
                    }
                   
                  this.excelToExport(exportReimDetailList, excelFileName, excelSheetName)
                }else{
                  toastEvents(this, 'No mileage')
                }
            }
            else {
              console.log("Error", result)
            }
        }
        }).catch(error=>{
          console.log("error", error)
        })
      }else{
        let exportBiweekList = [];
        getMileagesData({
          // eslint-disable-next-line radix
          year: parseInt(this.defaultYear),
          contactId: this.contactId
        }).then(result => {
          console.log("result", result)
          if (result != null) {
            if (result !== '') {
                let biweekList = this.proxyToObject(result);
                if(biweekList.length > 0){
                  let fileName = this.contactInfo.Name + '\'s Detail Report';
                  let sheetName = 'Detail Report';
                  if(!this.isIrs){
                    exportBiweekList.push(["Contact Email", "Month", "Tracking Style", "Day Of Week", "Trip Date", "Start Time", "End Time", "Trip Origin", "Trip Destination", "Status", "Date Submitted", "Date Approved", "Maint/Tires", "Fuel Rate", "Mileage", "Mi Rate", "Amount", "Notes", "Tags"]);
                    biweekList.forEach(function (item) {
                      exportBiweekList.push([item.email, item.reimMonth, item.tracingStyle, item.dayOfWeek, item.tripDate, item.starttime, item.endtime, item.originName, item.destinationName, item.tripStatus, item.submitteddate, item.approvedDate, item.maintTyre, item.fuelVaraibleRate,  item.mileage, item.varaibleRate, item.varaibleAmount, item.notes, item.tag]);
                    });
                  }else{
                    exportBiweekList.push(["Contact Email", "Month", "Tracking Style", "Day Of Week", "Trip Date", "Start Time", "End Time", "Trip Origin", "Trip Destination", "Status", "Date Submitted", "Date Approved", "Mileage", "Mi Rate", "Amount", "Notes", "Tags"]);
                    biweekList.forEach(function (item) {
                      exportBiweekList.push([item.email, item.reimMonth, item.tracingStyle, item.dayOfWeek, item.tripDate, item.starttime, item.endtime, item.originName, item.destinationName, item.tripStatus, item.submitteddate, item.approvedDate,  item.mileage, item.varaibleRate, item.varaibleAmount, item.notes, item.tag]);
                    });
                  }
                 
                  this.excelToExport(exportBiweekList, fileName, sheetName)
                }else{
                  toastEvents(this, 'No mileage')
                }
            }
            else {
              console.log("Error", result)
            }
        }
        }).catch(error=>{
          console.log("error", error)
        })
      }
    }
  }

  getTrips(event) {
    if (this.contactInfo.Reimbursement_Frequency__c === 'Bi-Weekly Reimbursement' && this.contactInfo.Reimbursement_Type__c === 'Mileage Rate') {
      let tripList = {
        boolean : true,
        trip: event.detail
      }
      //console.log('from table---', JSON.stringify(event.detail), this.contactInfo.Biweek_Reimbursement__c)
      events(this, tripList)
    }else{
      let tripDetail = {
        boolean: false,
        month: event.detail,
        year: this.defaultYear
      }
      //console.log('from table---', event.detail, this.defaultYear, tripDetail)
      events(this, tripDetail)
    }
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
    console.log(event.detail)
    let _biweekId, _month, message, stDate, enDate;
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
            console.log("getMileagesTA excel----", result);
            if(detailedList.length > 0){
              let excelTA = [];
              let excelFileName = this.contactInfo.Name + '\'s Time And Attendance Report ' + this.dateTime(new Date());
              let excelSheetName = 'T and A Report';
              if(!this.isIrs){
                excelTA.push(["Contact Email", "Tracking Style", "Day Of Week", "Trip Date", "Start Time", "End Time", "Trip Origin", "Trip Destination", "Status", "Date Submitted", "Date Approved", "Maint/Tires", "Fuel Rate", "Mileage", "Mi Rate", "Amount", "Drive Time", "Stay Time", "Total Time", "Notes", "Tags"])
                detailedList.forEach((item)=>{
                  excelTA.push([item.emailaddress, item.tracingstyle, item.dayofweek, item.tripdate, item.starttime, item.endtime, item.originname, item.destinationname, item.status, item.submitteddate, item.approveddate, item.maintTyre, item.fuelVariableRate, item.mileage, item.variablerate, item.variableamount, item.drivingtime, item.staytime, item.totaltime, item.notes, item.tag])
                })
              }else{
                excelTA.push(["Contact Email", "Tracking Style", "Day Of Week", "Trip Date", "Start Time", "End Time", "Trip Origin", "Trip Destination", "Status", "Date Submitted", "Date Approved",  "Mileage", "Mi Rate", "Amount", "Drive Time", "Stay Time", "Total Time", "Notes", "Tags"])
                detailedList.forEach((item)=>{
                  excelTA.push([item.emailaddress, item.tracingstyle, item.dayofweek, item.tripdate, item.starttime, item.endtime, item.originname, item.destinationname, item.status, item.submitteddate, item.approveddate, item.mileage, item.variablerate, item.variableamount, item.drivingtime, item.staytime, item.totaltime, item.notes, item.tag])
                })
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
        _biweekId = element.biweekId
        getBiweekMileages({
            biweekId: _biweekId
        }).then(result => {
          let escapeChar = this.escapeSpecialChars(result[0]);
          let biweekList = JSON.parse(escapeChar);
          if(biweekList.length > 0){
            let excelReimbursement = [];
            let excelFileName = this.contactInfo.Name + '\'s Mileage Report ' + this.dateTime(new Date());
            let excelSheetName = 'Mileage Report';
            if(!this.isIrs){
              excelReimbursement.push(["Contact Email", "Tracking Style", "Day Of Week", "Trip Date", "Start Time", "End Time", "Trip Origin", "Trip Destination", "Status", "Date Submitted", "Date Approved", "Maint/Tires", "Fuel Rate", "Mileage", "Mi Rate", "Amount", "Trip Type", "Drive Time", "Stay Time", "Total Time", "Notes", "Tags"])
              biweekList.forEach((item)=>{
                item.drivingtime = this.timeConversion(item.drivingtime);
                item.staytime = this.timeConversion(item.staytime);
                item.totaltime =this.timeConversion(item.totaltime);
                excelReimbursement.push([item.emailaddress, item.tracingstyle, item.dayofweek, item.tripdate, item.starttime, item.endtime, item.originname, item.destinationname, item.status, item.submitteddate, item.approveddate, item.maintTyre, item.fuelVariableRate, item.mileage, item.variablerate, item.variableamount, item.tripActivity, item.drivingtime, item.staytime, item.totaltime, item.notes, item.tag])
              })
            }else{
              excelReimbursement.push(["Contact Email", "Tracking Style", "Day Of Week", "Trip Date", "Start Time", "End Time", "Trip Origin", "Trip Destination", "Status", "Date Submitted", "Date Approved", "Mileage", "Mi Rate", "Amount", "Trip Type", "Drive Time", "Stay Time", "Total Time", "Notes", "Tags"])
              biweekList.forEach((item)=>{
                item.drivingtime = this.timeConversion(item.drivingtime);
                item.staytime = this.timeConversion(item.staytime);
                item.totaltime =this.timeConversion(item.totaltime);
                excelReimbursement.push([item.emailaddress, item.tracingstyle, item.dayofweek, item.tripdate, item.starttime, item.endtime, item.originname, item.destinationname,  item.status, item.submitteddate, item.approveddate, item.mileage, item.variablerate, item.variableamount, item.tripActivity, item.drivingtime, item.staytime, item.totaltime, item.notes, item.tag])
              })
            }
           
            this.excelToExport(excelReimbursement, excelFileName, excelSheetName);
          }else{
            toastEvents(this, 'No mileage')
          }

          console.log("getBiweekMileages excel----", result);
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
        _month = element.month;
        getMileages({
          clickedMonth: _month,
          year: this.defaultYear,
          contactId: this.contactId
        }).then(result=>{
          console.log("getMileages excel----", result);
          let escapeChar = this.escapeSpecialChars(result[0]);
          let mileageList = JSON.parse(escapeChar);
          console.log("mileageList excel----", result);
          if(mileageList.length > 0){
            let excelMileage = [];
            let excelFileName = this.contactInfo.Name + '\'s Mileage Report ' + this.dateTime(new Date());
            let excelSheetName = 'Mileage Report';
            if(!this.isIrs){
              excelMileage.push(["Contact Email", "Tracking Style", "Day Of Week", "Trip Date", "Start Time", "End Time", "Total Time", "Trip Origin", "Trip Destination", "Status", "Date Submitted", "Date Approved", "Maint/Tires", "Fuel Rate", "Mileage", "Mi Rate", "Amount",  "Notes", "Tags"])
              mileageList.forEach((item)=>{
                excelMileage.push([item.emailaddress, item.tracingstyle, item.dayofweek, item.tripdate, item.starttime, item.endtime, item.totaltime, item.originname, item.destinationname, item.status, item.submitteddate, item.approveddate, item.maintTyre, item.fuelVariableRate, item.mileage, item.variablerate, item.variableamount, item.notes, item.tag])
              })
            }else{
              excelMileage.push(["Contact Email", "Tracking Style", "Day Of Week", "Trip Date", "Start Time", "End Time", "Total Time", "Trip Origin", "Trip Destination",  "Status", "Date Submitted", "Date Approved", "Mileage", "Mi Rate", "Amount", "Notes", "Tags"])
              mileageList.forEach((item)=>{
                excelMileage.push([item.emailaddress, item.tracingstyle, item.dayofweek, item.tripdate, item.starttime, item.endtime, item.totaltime, item.originname, item.destinationname, item.status, item.submitteddate, item.approveddate, item.mileage, item.variablerate, item.variableamount, item.notes, item.tag])
              })
            }
           
            this.excelToExport(excelMileage, excelFileName, excelSheetName);
          }else{
            toastEvents(this, 'No mileage')
          }
          console.log("getMileages excel----", result);
        }).catch(error => {
          if (Array.isArray(error.body)) {
            message = error.body.map((e) => e.message).join(", ");
          } else if (typeof error.body.message === "string") {
            message = error.body.message;
          }

          console.log("Error getMileages", message)
        })
      }
    }
    console.log("element----", JSON.stringify(element))
  }

  insideClick(event){
    event.stopPropagation();
  }

}