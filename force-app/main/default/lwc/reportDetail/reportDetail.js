import { LightningElement, api, wire } from 'lwc';
import resourceImage from '@salesforce/resourceUrl/mBurseCss';
import getDriverManagerDropdownList from '@salesforce/apex/ReportDetailsController.getDriverManagerList';
import getReportDetails from '@salesforce/apex/ReportDetailsController.getReportDetail';
import getManagerDriverDetails from '@salesforce/apex/ReportDetailsController.getAllManagers';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import updateEditableField from "@salesforce/apex/ReportDetailsController.updateEditableField";
import checkBiweeklyPayPeriod from "@salesforce/apex/TripDetailsforSightScienceController.checkBiweeklyPayPeriod";

import getAllReportSoql from '@salesforce/apex/ReportDetailsController.getAllReportSoql';
import postTotalReimbursementForAllUser from '@salesforce/apex/ReportDetailsController.postTotalReimbursementForAllUser';
import biweekpayperiod from '@salesforce/apex/ReportListController.payPeriodDateList';
import NewEnglandGypsum from '@salesforce/label/c.NewEnglandGypsum';
import varReimC from '@salesforce/label/c.VarReim_Concur';
import SPBS_Account from '@salesforce/label/c.SPBS_Account';
import SALESFORCE_LIMIT_MSG from '@salesforce/label/c.Info_message_for_salesforce_limit';
import TripDetailReportSightScience from '@salesforce/label/c.TripDetailReportSightScience';
import concurIcon from '@salesforce/resourceUrl/concurIcon';
import postExpenseReimbursement from '@salesforce/apex/ManagerDashboardController.postExpenseReimbursement';
import LockUnlockIcons from '@salesforce/resourceUrl/LockAccountIcons';
import gerAccountStatus from '@salesforce/apex/ReportDetailsController.gerAccountStatus';

import WORK_BOOK from "@salesforce/resourceUrl/xlsx";
export default class ReportDetail extends LightningElement {
  istrue = false;
  sortable = true;
  recordDisplay = true;
  classToTable = 'slds-table--header-fixed_container p-top-v1';
  isScrollable = true;
  paginatedModal = true;
  // @api modelList;
  @api reportId;
  @api monthList;
  isSort = true;
  searchIcon = resourceImage + '/mburse/assets/mBurse-Icons/Vector.png';

  ishow = false;
  header = [];
  detail = [];
  modaldata;
  DriverManager;
  reportData;
  value = '';
  picklist = [];
  reportName = '';
  displayReportName = '';
  detaildata = [];
  originalData = [];
  headerdata = [];
  keyArray = [];
  filterdata = [];
  headerfields;
  formattedArray = [];
  finaldata = [];
  searchdata = [];
  updateddata;
  loaddata = [];
  loadDataNew = [];
  filterdatanew = [];
  exceldata = [];
  searchkey = '';
  from_Date = '';
  to_Date = '';
  isSelectedDate = true;
  monthlyDropdown = false;
  weeklyDropdown = false;
  dateRange = false;
  monthoption = [];
  librariesLoaded = false;
  manager = '';
  selectedmonth = '';
  reportsoql = '';
  _accid;
  _adminid;
  reportType;
  DriverManagerList = [];
  detailsoql;
  anual_tax = false;
  showbuttons = false;
  concurbtn = false;
  Weekoptions = [];
  selectedweek;
  placeholder = '';
  editableView = true;
  editable_feilds;
  updatebtn = false;
  updatedList = [];
  editablefield = '';
  limitOfrecord = 0;
  dateArray = [];
  numberArray = [];
  remId;
  isSearchEnable = true;
  sortOrder = '';
  columnName = '';
  columnType = '';
  withoutupdatedate;
  showEmailbtn = false;
  stringifydata;
  isSearch = false;
  keyName;
  keyValue;
  totalsum;
  filterdataSearch = [];
  finaldataSearch = [];
  tempAllData = [];
  editedCount = 0;
  cfHeaderlist = [];
  cfHeaderfields = [];
  cfReportdatefields = [];
  cfReportdatetimefields = [];
  isLockUnlockIcon = false;
  isLockIcon = false;
  lockIconUrl;
  unLockIconUrl;
  taxLiabilityReportType;
  dateFormat = 'mm/dd/yy';

  renderedCallback() {
    if (this.librariesLoaded) return;
    this.librariesLoaded = true;
    //to load static resource for xlsx file
    Promise.all([loadScript(this, WORK_BOOK)])
      .then(() => {
        console.log("success");
      })
      .catch(error => {
        console.log("failure");
      });
  }

  // Variable for get selected month
  get lastmonth() {
    var makeDate = new Date();
    console.log("getdate", makeDate.getDate());
    // if (makeDate.getDate() > 25) {
      let newDate = new Date(makeDate.getFullYear(), makeDate.getMonth(), 0);
      let lastmonth = newDate.toLocaleString('default', { month: 'long' });
      console.log('Current Month : ' + lastmonth);
      return lastmonth;
    // } else {
    //   makeDate.setMonth(makeDate.getMonth());
    //   let lastmonth = makeDate.toLocaleString('default', { month: 'long' });
    //   console.log('Current Month : ' + lastmonth);
    //   return lastmonth;
    // }
  }
  // Added by Raj

  getUrlParamValue(url, key) {
    return new URL(url).searchParams.get(key);
  }
  getBiweekLIst() {
    biweekpayperiod({ accId: this._accid })
      .then(result => {
        var payarray = new Array();
        payarray = result.split(",");
        let finaldata = JSON.parse(JSON.stringify(payarray));
        console.log("finaldata", JSON.stringify(finaldata));
        finaldata.forEach(element => {
          let list = element.split(' to ')[0];
          let list1 = element.split(' to ')[1];
          let finallist = (list.split('-')[1] + '/' + list.split('-')[2] + '/' + list.split('-')[0].substring(2, 4)) + ' - ' + (list1.split('-')[1] + '/' + list1.split('-')[2] + '/' + list1.split('-')[0].substring(2, 4));
          this.Weekoptions.push({ label: finallist, value: finallist });
        })
        this.Weekoptions = JSON.parse(JSON.stringify(this.Weekoptions))
      })
      .catch(error => {
        console.log("biweek error", error)
      })
  }

  dateConversionToTime(obj){
      let date = new Date(obj);
      return date.toLocaleTimeString("en-US", {
          timeZone: "America/Panama",
          hour: "2-digit",
          minute: "2-digit",
        });
  }

  commonFilter(data, object, _self){
    var report, reportname, numericheadertoapifields = new Map(), apifieldstoheader = new Map(), datetimefields = new Map(), booleanfields = new Map(), datefields = new Map(), datetotimefields = new Map(), twodecimalfields = new Map(), fourdecimalfields = new Map(), numericheaderarray = [], reportdatetimetotimefields = [], reportbooleanfields = [], reporttwodecimalfields = [], reportfourdecimalfields = [];
    report = object
    if(report){
      let sql = report.Report_Soql__c.split('from');
      reportname = report.Name;
      console.log('reportname : ' + reportname);
      if(sql){
        let fields = sql[0].split('select')[1].trim().split(',');
        console.log("Fields at commonFIlter : "+ JSON.stringify(fields));
        // Set this.detail & this.detailsoql
        this.detail = fields;
        this.detailsoql = fields;
        // Added by Raj
        if(fields){
            // if (report.Report_Header__c != undefined) {
            //     if (report.Report_Header__c.includes(',')) {
            //         this.cfHeaderlist = report.Report_Header__c.split(',');
            //     }
            //     else {
            //         this.cfHeaderlist.push(report.Report_Header__c);
            //     }
            // }
            // // Set this.headerdata
            // this.headerdata = JSON.parse(JSON.stringify(this.cfHeaderlist));
            // // Added by Raj

            if (report.Boolean_Field__c != undefined) {
              if (report.Boolean_Field__c.includes(',')) {
                  reportbooleanfields = report.Boolean_Field__c.split(',');
              }
              else {
                  reportbooleanfields.push(report.Boolean_Field__c.trim());
              }
            }

            // if (report.Numeric_Fields__c != undefined) {
            //   if (report.Numeric_Fields__c.includes(',')) {
            //       this.cfHeaderfields = report.Numeric_Fields__c.split(',');
            //   }
            //   else {
            //       this.cfHeaderfields.push(report.Numeric_Fields__c.trim());
            //   }
            // }

            if (report.Two_Decimal_Places__c != undefined) {
              if (report.Two_Decimal_Places__c.includes(',')) {
                  reporttwodecimalfields = report.Two_Decimal_Places__c.split(',');
              }
              else {
                  reporttwodecimalfields.push(report.Two_Decimal_Places__c.trim());
              }
            }

            if (report.Four_Decimal_Places__c != undefined) {
              if (report.Four_Decimal_Places__c.includes(',')) {
                  reportfourdecimalfields = report.Four_Decimal_Places__c.split(',');
              }
              else {
                  reportfourdecimalfields.push(report.Four_Decimal_Places__c.trim());
              }
            }

            // if (report.Date_Time_Fields__c != undefined) {
            //   if (report.Date_Time_Fields__c.includes(',')) {
            //       this.cfReportdatetimefields = report.Date_Time_Fields__c.split(',');
            //   }
            //   else {
            //       this.cfReportdatetimefields.push(report.Date_Time_Fields__c.trim());
            //   }
            // }

            // if (report.Date_Fields__c != undefined) {
            //   if (report.Date_Fields__c.includes(',')) {
            //       this.cfReportdatefields = report.Date_Fields__c.split(',');
            //   }
            //   else {
            //       this.cfReportdatefields.push(report.Date_Fields__c.trim());
            //   }
            // }

            if (report.Date_Time_To_Time__c != undefined) {
              if (report.Date_Time_To_Time__c.includes(',')) {
                  reportdatetimetotimefields = report.Date_Time_To_Time__c.split(',');
              }
              else {
                  reportdatetimetotimefields.push(report.Date_Time_To_Time__c);
              }
            }

            for(var j = 0;j<fields.length;j++)
            {
                if(fields[j].includes('.'))
                {
                    if(reportname == 'Monthly Review' && fields[j].split('.').length > 2) {
                      console.log("In mName");
                      apifieldstoheader.set('mName', this.cfHeaderlist[j]);
                    } else {
                      apifieldstoheader.set(fields[j].split('.')[1], this.cfHeaderlist[j]);
                    }
                }
                else
                {
                    apifieldstoheader.set(fields[j], this.cfHeaderlist[j]);
                }
            }
            // Set this.headerfields
            this.headerfields = apifieldstoheader;
            // Added by Raj

           // numericheadertoapifields = new Map();
            for (var j = 0; j < this.cfHeaderfields.length; j++) {
                if (apifieldstoheader.has(this.cfHeaderfields[j])) {
                    numericheadertoapifields.set(this.cfHeaderfields[j], apifieldstoheader.get(this.cfHeaderfields[j]));
                }
            }

           // datetimefields = new Map();
            for (var j = 0; j < this.cfReportdatetimefields.length; j++) {
                if (apifieldstoheader.has(this.cfReportdatetimefields[j])) {
                    datetimefields.set(this.cfReportdatetimefields[j], apifieldstoheader.get(this.cfReportdatetimefields[j]));
                }
            }

            //booleanfields = new Map();
            for (var j = 0; j < reportbooleanfields.length; j++) {
                if (apifieldstoheader.has(reportbooleanfields[j])) {
                    booleanfields.set(reportbooleanfields[j], apifieldstoheader.get(reportbooleanfields[j]));
                }
            }

           // datefields = new Map();
            for (var j = 0; j < this.cfReportdatefields.length; j++) {
                if (apifieldstoheader.has(this.cfReportdatefields[j])) {
                    datefields.set(this.cfReportdatefields[j], apifieldstoheader.get(this.cfReportdatefields[j]));
                }
            }

           // datetotimefields = new Map();
            for (var j = 0; j < reportdatetimetotimefields.length; j++) {
                if (apifieldstoheader.has(reportdatetimetotimefields[j])) {
                    datetotimefields.set(reportdatetimetotimefields[j], apifieldstoheader.get(reportdatetimetotimefields[j]));
                }
            }

           // twodecimalfields = new Map();
            for (var j = 0; j < reporttwodecimalfields.length; j++) {
                if (apifieldstoheader.has(reporttwodecimalfields[j])) {
                    twodecimalfields.set(reporttwodecimalfields[j], apifieldstoheader.get(reporttwodecimalfields[j]));
                }
            }

            for (var j = 0; j < reportfourdecimalfields.length; j++) {
              if (apifieldstoheader.has(reportfourdecimalfields[j])) {
                  fourdecimalfields.set(reportfourdecimalfields[j], apifieldstoheader.get(reportfourdecimalfields[j]));
              }
            }

            // creation of array
            var map3 = new Map(), 
            valueofkey = [];
            let isConcurBtn = false;
            if(this.concurbtn == true) {
              isConcurBtn = true;
            }
            for(var i = 0;i<data.length;i++)
            {
                Object.keys(data[i]).forEach(function(key){
                    console.log("Report name : " + reportname);
                    console.log("key : " + key);
                    if(reportname == 'Monthly Review' && key == 'Contact_Id__r') {
                      console.log('data : ' + JSON.stringify(data));
                      console.log("In MR" + JSON.stringify(data[i][key]));
                      valueofkey.push(apifieldstoheader.get('Employee_ID__c'),data[i][key]?.Employee_ID__c);
                      valueofkey.push(apifieldstoheader.get('Name'),data[i][key]?.Name);
                      valueofkey.push(apifieldstoheader.get('External_Email__c'),data[i][key]?.External_Email__c);
                      valueofkey.push(apifieldstoheader.get('mName'),data[i][key]?.Manager__r?.Name);
                    } else {
                      if(key != "attributes")
                        {
                            if(typeof data[i][key]=="object")
                            {
                                _self.consolidatejson(data[i][key],i, apifieldstoheader, datefields, datetimefields, datetotimefields, valueofkey, _self);
                            }
                            // Set Id field
                            else if (key == 'Id') {
                              valueofkey.push('Id', data[i][key]);
                            }
                            // Added by Raj
                            else
                            {
                                if(apifieldstoheader.has(key))
                                {
                                    if(datetotimefields.has(key)){
                                        let timevalues = _self.dateConversionToTime(new Date(data[i][key]));
                                        valueofkey.push(apifieldstoheader.get(key),timevalues);
                                    }
                                    else if(datetimefields.has(key))
                                    {
                                        let datevalues= data[i][key].split('T')[0].split('-');
    
                                        valueofkey.push(apifieldstoheader.get(key),datevalues[1]+"/"+datevalues[2]+"/"+datevalues[0]);
                                    }
                                    else if(datefields.has(key))
                                    {
                                        let datevalues= data[i][key].split('-');
                                        valueofkey.push(apifieldstoheader.get(key),datevalues[1]+"/"+datevalues[2]+"/"+datevalues[0]);
                                    }
                                    else if(booleanfields.has(key))
                                    {
                                        let booleanValues = (data[i][key] === true) ? 'Yes' : 'No';
                                        valueofkey.push(apifieldstoheader.get(key),booleanValues);
                                    }
                                    else if(twodecimalfields.has(key))
                                    {
                                        let twodecimalValues = data[i][key].toFixed(2);
                                        valueofkey.push(apifieldstoheader.get(key),twodecimalValues);
                                    }
                                    else if(fourdecimalfields.has(key))
                                    {
                                        let fourdecimalValues = data[i][key].toFixed(4);
                                        valueofkey.push(apifieldstoheader.get(key),fourdecimalValues);
                                    }
                                    else if(numericheadertoapifields.has(key))
                                    {
                                        let numericValues;
                                        if(data[i][key] % 1 !== 0) {
                                          numericValues = data[i][key].toFixed(2);
                                        } else {
                                          numericValues = data[i][key];
                                        }
                                        valueofkey.push(apifieldstoheader.get(key),numericValues);
                                    }
                                    else
                                    {
                                        valueofkey.push(apifieldstoheader.get(key),data[i][key]);
                                    }
                                }
                            }
                        }
                        if(isConcurBtn == true) {
                          valueofkey.push("Concur",concurIcon + '#Concur');
                        }
                    }
                });
                map3.set(i,valueofkey);
                valueofkey = [];
            }

            var finnalArr = [];
            map3.forEach(function(item, key) {
              let arrayvalues = map3.get(key);
              let finnalData = {};
                let ind = -1;
                    arrayvalues.forEach(function(element,index) {
                    if(index>ind){
                        let keyData=item[index];
                        if (keyData === 'Variable Reimbursement') {
                                // finnalData[keyData.replace(/\s/g, "")] = '$' + arrayvalues[index + 1]
                                finnalData[keyData] = '$' + arrayvalues[index + 1]
                        }else{
                          // finnalData[keyData.replace(/\s/g, "")] = arrayvalues[index+1]
                          finnalData[keyData] = arrayvalues[index+1]
                        }
                        for(i = 0 ; i < numericheaderarray.length; i++){
                            if(keyData != 'Variable Rate'){
                                // finnalData[keyData.replace(/\s/g, "")]=(arrayvalues[index+1]).toLocaleString();
                                finnalData[keyData]=(arrayvalues[index+1]).toLocaleString();
                          }
                        }

                        ind = index+1;
                        }
                    });
                    finnalArr.push(finnalData);
            });
        }
      }
    }

    return finnalArr
  }


  connectedCallback() {
    this.dispatchEvent(
      new CustomEvent("show", { detail: '' })
    );
    console.log("this.reportId", this.reportId)
    this._accid = this.getUrlParamValue(location.href, 'accid')
    this._adminid = this.getUrlParamValue(location.href, 'id')
    this.getBiweekLIst();
    if (this.reportId != 'TAX123' && this.reportId != 'ANNUAL_TAX') {
      this.lockIconUrl = LockUnlockIcons + '/ReportLock/Lock-01.svg#Layer_1';
      this.unLockIconUrl = LockUnlockIcons + '/ReportLock/Lock-02-01.svg#Layer_1';
      this.getreport();
    } else {
      if(this.reportId == 'TAX123') {
        this.taxLiabilityReportType = 'Tax';
      } else {
        this.taxLiabilityReportType = 'Annual';
      }
      this.anual_tax = true;
      this.dispatchEvent(
        new CustomEvent("hide", { detail: '' })
      );
    }
  }

  handleenter() {
    if (this.Weekoptions.length > 6) {
      if (this.template.querySelector(`c-dropdown-select[data-id="bi_week"]`)) {
        console.log("hiii", this.template.querySelector(`c-dropdown-select[data-id="bi_week"]`))
        this.template.querySelector(`c-dropdown-select[data-id="bi_week"]`).toggleStyle(true);
      }
    }
  }
  removeDuplicateValue(myArray) {
    var newArray = [];
    myArray.forEach((value) => {
      var exists = false;
      newArray.forEach((val2) => {
        if (value === val2) {
          exists = true;
        }
      })

      if (exists === false && value !== "") {
        newArray.push(value);
      }
    })
  }

  review(a) {
    if (a) {
      let monthA = a,
        array = [];
      for (let i = 0; i < monthA.length; i++) {
        let obj = {};
        obj.id = i + 1;
        obj.label = monthA[i];
        obj.value = monthA[i];
        array.push(obj);
      }

      return JSON.stringify(array);
    }
    return a;
  }

  nestedJsonRead(data, i) {
    Object.keys(data).forEach(key => {
      if (key != "attributes") {
        if (typeof data[key] == "object") {
          this.nestedJsonRead(data[key], i);
        } else {
          if (this.headerfields.has(key)) {
            this.keyArray.push(i, this.headerfields.get(key), data[key]);
          }
        }
      }
    })
  }

  consolidatejson(getdata, i, apifieldstoheader, datefields, datetimefields, datetotimefields, valueofkey, _self) {
    Object.keys(getdata).forEach(function (key) {
      if (key != "attributes") {
        if (typeof getdata[key] == "object") {
          _self.consolidatejson(getdata[key], i, apifieldstoheader, datefields, datetimefields, datetotimefields, valueofkey, _self);
        }
        else {
          if (apifieldstoheader.has(key)) {
            if (datetotimefields.has(key)) {
              let timevalues = _self.dateConversionToTime(new Date(getdataofmanager[i][key]));
              valueofkey.push(apifieldstoheader.get(key), timevalues);
            }
            else if (datetimefields.has(key)) {
              let datevalues = getdata[key].split('T')[0].split('-');

              valueofkey.push(apifieldstoheader.get(key), datevalues[1] + "/" + datevalues[2] + "/" + datevalues[0]);
            }
            else if (datefields.has(key)) {
              let datevalues = getdata[key].split('-');
              valueofkey.push(apifieldstoheader.get(key), datevalues[1] + "/" + datevalues[2] + "/" + datevalues[0]);
            }
            else {
              valueofkey.push(apifieldstoheader.get(key), getdata[key]);
            }
          }
        }
      }
    });
  }

  dynamicBinding(data, keyFields) {
    console.log("keyFields", JSON.stringify(keyFields));
    console.log("data##", JSON.stringify(data));

    data.forEach(element => {
      let model = [];
      keyFields.forEach(key => {
        let singleValue = {};
        singleValue.key = key;
        this.header.forEach(element1 => {
          if (element1.colName == key) {
            singleValue.keyType = element1.colType;
            if (element1.colType == 'Integer') {
              const val = element[key] == undefined ? null : element[key];
              if (val == null) {
                singleValue.value = val;
              } else {
                singleValue.value = this.formatNumberWithCommas(val);
              }
            } else {
              singleValue.value = element[key] == undefined ? null : element[key];
            }
          }
        })
        if (this.editablefield) {
          if (this.editablefield.includes(key + '-')) {
            singleValue.proratedInput = true;
            singleValue.inputClass = 'proratedInput';
          } else {
            singleValue.proratedInput = false;
          }
        } else {
          singleValue.proratedInput = false;
        }
        singleValue.id = element['Id'];
        if(this.concurbtn == true && key == 'Concur') {
          singleValue.onlyIcon = true;
          singleValue.multipleIcon = false;
          singleValue.isConcurField = true;
          singleValue.iconUrl = element[key];
        }
        model.push(singleValue);
      })
      element.keyFields = this.mapOrder(model, keyFields, 'key');
    });
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

  handleDriverChange(event) {
    console.log("event.detail.value", event.detail.value)
    if (event.detail.value == undefined) {
      this.manager = '';
    } else {
      this.manager = event.detail.value;
    }
  }
  handleChangebysearch(event) {
    console.log("event.key", event.key)
    this.updatebtn = false;
    this.isSearch = true;
    this.searchkey = event.target.value;
    this.isSearchEnable = this.searchkey == "" ? true : false;
    if (this.template.querySelector('c-user-preview-table')) {
      this.template.querySelector('c-user-preview-table').searchByKey(this.searchkey);
    }
    if (this.updatebtn == true) {
      if (event.key == 'Backspace') {
        if (this.searchkey == "") {
          if (this.filterdataSearch.length > 0) {
            this.dynamicBinding(this.filterdataSearch, this.headerdata)
            this.template.querySelector('c-user-preview-table').refreshTable(this.filterdataSearch);
            this.exceldata = this.createExcelData(this.filterdataSearch,this.header);
          } else {
            this.dynamicBinding(this.finaldataSearch, this.headerdata)
            this.template.querySelector('c-user-preview-table').refreshTable(this.finaldataSearch);
            this.exceldata = this.createExcelData(this.finaldataSearch,this.header);
          }
        }
      }
    }

  }
  handleClearInput(event) {
    this.searchkey = "";
    this.isSearch = false;
    this.isSearchEnable = this.searchkey == "" ? true : false;
    // this.template.querySelector("c-user-preview-table").searchByKey(this.searchkey);
    if (this.updatebtn == true) {
      if (this.filterdataSearch.length > 0) {
        this.dynamicBinding(this.filterdataSearch, this.headerdata)
        this.template.querySelector('c-user-preview-table').refreshTable(this.filterdataSearch);
        this.exceldata = this.createExcelData(this.filterdataSearch,this.header);
      } else {
        this.dynamicBinding(this.finaldataSearch, this.headerdata)
        this.template.querySelector('c-user-preview-table').refreshTable(this.finaldataSearch);
        this.exceldata = this.createExcelData(this.finaldataSearch,this.header);
      }
    } else {
      this.finaldata = this.tempAllData;
      console.log("finaldata at clear search : " + JSON.stringify(this.finaldata));
      this.dynamicBinding(this.finaldata, this.headerdata)
      this.template.querySelector('c-user-preview-table').refreshTable(this.finaldata);
      this.template.querySelector("c-user-preview-table").searchByKey(this.searchkey);
    }

  }
  handleClose() {
    this.dispatchEvent(
      new CustomEvent("closemodal", {})
    );
  }
  handlemonthchange(event) {
    this.selectedmonth = event.detail.value;
  }
  handleweekchange(event) {
    this.selectedweek = event.detail.value;
    this.template.querySelector(`c-dropdown-select[data-id="bi_week"]`).toggleStyle(false);
  }

  handleCopy() {
    const parent = this.template.querySelector('c-user-preview-table');
    let target = parent.children[1].offsetParent;
    if (target !== null || target !== undefined) {
      let targetchildren = target.children[2];
      if (targetchildren !== null || targetchildren !== undefined) {
        let child1 = targetchildren.children[0];
        console.log("table", child1);
        this.dispatchEvent(
          new CustomEvent("copy", {
            detail: child1
          })
        );
      }
    }
  }
  handlePrint() {
    // const parent = this.template.querySelector('c-user-preview-table');
    // let target = parent.children[0].offsetParent;
    // if(target  !== null || target !== undefined){
    //     let targetchildren = target.children[1];
    //     if(targetchildren  !== null || targetchildren !== undefined){
    //         let child1 = targetchildren.offsetParent
    //         if(child1  !== null || child1 !== undefined){
    //             let child2 = child1.offsetParent
    //             if(child2 !== null || child2 !== undefined){
    //               let table = child2.children[2];

    //               this.dispatchEvent(
    //                 new CustomEvent("print", {
    //                   detail:table
    //                 })
    //               );
    //             }
    //         }    
    //     }
    // }    
    const parent = this.template.querySelector('c-user-preview-table');
    let target = parent.children[1].offsetParent;
    if (target !== null || target !== undefined) {
      let targetchildren = target.children[2];
      if (targetchildren !== null || targetchildren !== undefined) {
        let child1 = targetchildren.children[0]
        console.log("table", child1)
        this.dispatchEvent(
          new CustomEvent("print", {
            detail: child1
          })
        );
      }
    }
  }
  handleCreateExcel() {
    let exceldata = [];
    if (this.reportName == 'Onboarding Status Report' || this.reportName == 'Employee Roster Report') {
      this.exceldata.sort((a, b) => {
        const dateA = a["Activation Date"] ? new Date(a["Activation Date"]) : null;
        const dateB = b["Activation Date"] ? new Date(b["Activation Date"]) : null;

        // Handle null values
        if (dateA === null && dateB === null) {
          return 0; // Both dates are null, consider them equal
        }
        if (dateA === null) {
          return 1; // Null comes after non-null dates
        }
        if (dateB === null) {
          return -1; // Null comes after non-null dates
        }

        return dateB - dateA;
      });
    }
    this.exceldata.forEach(element => {
      let model = [];
      this.headerdata.forEach(key => {
        if(key != 'Concur') {
          let keyvalue;
          if (element[key] == undefined) {
            keyvalue = null;
          } else {
            keyvalue = element[key];
          }
          model.push({ [key]: keyvalue });
        }
      });
      exceldata.push(Object.assign({}, ...model));

    });
    exceldata = JSON.parse(JSON.stringify(exceldata));
    console.log("exceldata", JSON.stringify(exceldata));
    if (exceldata.length > 0) {
      let tempheader = [];
      let tempworkSheetNameList = [];
      let tempxlsData = [];
      let name = '';
      const sheetnamedate = new Date();

      let month = sheetnamedate.getMonth() + 1;
      let today = sheetnamedate.getDate();
      let toyear = sheetnamedate.getFullYear();
      let hours = sheetnamedate.getHours();
      let minutes = sheetnamedate.getMinutes();
      let second = sheetnamedate.getSeconds();

      let convertingdate = month + '' + today + '' + toyear + '' + hours + '' + minutes + '' + second;

      //push data , custom header , filename and worksheetname for detail xlsx file
      tempheader.push(this.headerdata);
      let tempHeader = tempheader[0];
      if(tempHeader.includes("Concur")) {
        tempHeader.pop();
      }
      // if(this.reportName == "Final Variable Report for Terminated Drivers" || this.reportName == "Commuter and Actual Mileage Report"){
      if (this.reportName.length > 30) {
        tempworkSheetNameList.push(convertingdate);
      } else {
        tempworkSheetNameList.push(this.reportName);
      }

      tempxlsData.push(exceldata);
      name = this.reportName + ' ' + convertingdate + '.xlsx';

      //Download Summary report(xlsx file)
      if (tempxlsData.length > 0) {
        console.log("in if")
        this.callcreatexlsxMethod(tempheader, name, tempworkSheetNameList, tempxlsData);
      }
    }
  }
  handleCreateCSV() {
    let name = '';
    var makeDate = new Date();
    var month = makeDate.getMonth() + 1;
    var today = makeDate.getDate();
    var toyear = makeDate.getFullYear();
    var hours = makeDate.getHours();
    var minutes = makeDate.getMinutes();
    var second = makeDate.getSeconds();

    var finaldate = (month < 10 ? '0' + month : month) + today + toyear + hours + minutes + second;
    name = this.reportName + ' ' + finaldate;
    let exceldata = [];
    this.exceldata.forEach(element => {
      let model = [];
      this.headerdata.forEach(key => {
        if(key != 'Concur') {
          model.push({ [key]: element[key] });
        }
      });
      exceldata.push(Object.assign({}, ...model));

    });

    exceldata = JSON.parse(JSON.stringify(exceldata))
    if (this.reportName == 'Onboarding Status Report' || this.reportName == 'Employee Roster Report') {
      exceldata.sort((a, b) => {
        const dateA = a["Activation Date"] ? new Date(a["Activation Date"]) : null;
        const dateB = b["Activation Date"] ? new Date(b["Activation Date"]) : null;

        // Handle null values
        if (dateA === null && dateB === null) {
          return 0; // Both dates are null, consider them equal
        }
        if (dateA === null) {
          return 1; // Null comes after non-null dates
        }
        if (dateB === null) {
          return -1; // Null comes after non-null dates
        }

        return dateB - dateA;
      });
    }
    if (exceldata) {

      let rowEnd = '\n';
      let csvString = '';
      let regExp = /^[0-9/]*$/gm;
      let regExpForTime = /^[0-9:\sAM|PM]*$/gm
      let decimalExp = /^(\d*\.)?\d+$/gm
      // this set elminates the duplicates if have any duplicate keys
      let rowData = new Set();
      let csvdata = exceldata;
      csvdata.forEach(function (record) {
        Object.keys(record).forEach(function (key) {
          rowData.add(key);
        });
      });
      rowData = Array.from(rowData);

      csvString += rowData.join(',');
      csvString += rowEnd;

      var i = 0;
      for (let i = 0; i < csvdata.length; i++) {
        let colVal = 0;
        // validating keys in data
        for (let key in rowData) {
          if (rowData.hasOwnProperty(key)) {
            let rowKey = rowData[key];
            if (colVal > 0) {
              csvString += ',';
            }
            // If the column is undefined, it as blank in the CSV file.
            let value = csvdata[i][rowKey] === undefined ? '' : csvdata[i][rowKey];
            if (value != null || value != '') {
              if (value.match) {
                if (value.match(regExp) || value.match(regExpForTime) || value.match(decimalExp)) {
                  csvString += '="' + value + '"';
                } else {
                  csvString += '"' + value + '"';
                }
              } else {
                csvString += '"' + value + '"';
              }
            } else {
              csvString += '"' + value + '"';
            }
          }
          colVal++;
        }
        csvString += rowEnd;
        console.log("csvString", csvString)
      }
      /* Updated change on 27-09-2021 */
      var universalBOM = "\uFEFF";
      var a = window.document.createElement('a');
      a.setAttribute('href', 'data:text/csv; charset=utf-8,' + encodeURIComponent(universalBOM + csvString));
      a.setAttribute('target', '_self');
      a.setAttribute('download', name + '.csv')
      window.document.body.appendChild(a);
      a.click();
      // exportCSVFile(this.headerdata, this.exceldata, name)
    }
  }
  callcreatexlsxMethod(headerList, filename, worksheetNameList, sheetData) {
    const XLSX = window.XLSX;
    let xlsData = sheetData;
    let xlsHeader = headerList;
    let ws_name = worksheetNameList;
    console.log("ws_name", JSON.parse(JSON.stringify(ws_name)))
    let createXLSLFormatObj = Array(xlsData.length).fill([]);
    //let xlsRowsKeys = [];
    /* form header list */
    xlsHeader.forEach((item, index) => createXLSLFormatObj[index] = [item])

    /* form data key list */
    xlsData.forEach((item, selectedRowIndex) => {
      let xlsRowKey = Object.keys(item[0]);

      item.forEach((value, index) => {
        var innerRowData = [];
        xlsRowKey.forEach(item => {
          console.log("valur of key", value[item])
          innerRowData.push(value[item]);
        })

        createXLSLFormatObj[selectedRowIndex].push(innerRowData);
      })
    });

    /* creating new Excel */
    var wb = XLSX.utils.book_new();
    console.log("wb", wb)
    /* creating new worksheet */
    var ws = Array(createXLSLFormatObj.length).fill([]);
    console.log("ws", ws.length)
    for (let i = 0; i < ws.length; i++) {
      /* converting data to excel format and puhing to worksheet */
      let data = XLSX.utils.aoa_to_sheet(createXLSLFormatObj[i]);
      ws[i] = [...ws[i], data];
      console.log("ws[i]", ws_name[i])

      console.log("data", data)
      /* Add worksheet to Excel */
      try {
        XLSX.utils.book_append_sheet(wb, ws[i][0], ws_name[i]);
      } catch (error) {
        console.error("An error occurred:", JSON.parse(JSON.stringify(error)));
        // Handle the error gracefully, e.g., by displaying an error message to the user
      }
    }
    console.log("filename")
    /* Write Excel and Download */
    XLSX.writeFile(wb, filename);
    console.log("filename")

  }

  monthToNumber(monthName) {
    console.log("monthName", monthName)
    // Convert the month name to lowercase to make it case-insensitive
    const lowerCaseMonth = monthName.toLowerCase();

    switch (lowerCaseMonth) {
      case 'january':
        return '01';
      case 'february':
        return '02';
      case 'march':
        return '03';
      case 'april':
        return '04';
      case 'may':
        return '05';
      case 'june':
        return '06';
      case 'july':
        return '07';
      case 'august':
        return '08';
      case 'september':
        return '09';
      case 'october':
        return '10';
      case 'november':
        return '11';
      case 'december':
        return '12';

    }
  }

  createExcelData(data, headerDetail) {
    const processedData = data.map(item => {
      // Iterate through keys of each object
      Object.keys(item).forEach(key => {
        // Find corresponding headerData for the key
        const headerItem = headerDetail.find(header => header.colName === key);
        if (headerItem) {
          // Convert the value to float if it's an integer
          if (headerItem.colType === "Integer") {
            // item[key] = item[key].replace(/,/g, '');
            // console.log("item[key] after replace : " + item[key]);
            item[key] = item[key].toString().replace(/,/g, '');
            item[key] = parseFloat(item[key]);
          }
        }
      });
      return item;
    });
    return processedData;
  }

  handleDateChange(event) {
    let convertedDate = event.detail;
    console.log("convertedDate : " + convertedDate);
    let dateType = event.target.dataset.key;
    console.log('dateType : ' + dateType);
    let formattedDate;
    if(convertedDate) {
      var dateParts = convertedDate.split('/');
      var month = dateParts[0];
      var day = dateParts[1];
      var year = dateParts[2].slice(-2);
      formattedDate =  month + '/' + day + '/' + year;
    } else {
      formattedDate = '';
    }

    if(dateType == "fromDate") {
      this.from_Date = formattedDate;
    } else if(dateType == 'toDate') {
      this.to_Date = formattedDate;
    }
  }

  handleApply() {
    this.dispatchEvent(
      new CustomEvent("show", { detail: '' })
    );
    console.log("this.monthList", JSON.stringify(this.monthList))
    let months;
    if (this.selectedmonth) {
      this.monthList.forEach(month => {
        if (this.selectedmonth == month.label) {
          months = month.value;
        }
      })
    } else {
      const currentDate = new Date();
      months = this.monthToNumber(this.lastmonth) + '-' + currentDate.getFullYear();
      console.log("this.lastmonth", months)
    }


    let managerId;
    this.DriverManagerList.forEach(row => {
      if (row.Name == this.manager) {
        managerId = row.Id;
      }
    })
    if (this.selectedweek) {
      //2023-03-24
      let sdate = this.selectedweek.split('-')[0];
      let edate = this.selectedweek.split('-')[1];

      this.from_Date = sdate.split('/')[0] + '/' + sdate.split('/')[1] + '/20' + sdate.split('/')[2];
      this.to_Date = edate.split('/')[0] + '/' + edate.split('/')[1] + '/20' + edate.split('/')[2];
    } else {
      if (this.from_Date) {
        this.from_Date = this.from_Date;
        this.to_Date = this.to_Date;
      }
    }
    if (this.from_Date == undefined) {
      this.from_Date = null;
      this.to_Date = null;
    }

    console.log('this.reportsoql : ' + this.reportsoql);
    this.reportsoql = this.reportsoql.replaceAll(/\\/g, '');
    const replacedString = this.reportsoql.replace(/\\\\/g, '');
    this.reportsoql = replacedString;
    getAllReportSoql({
      reportSoql: this.reportsoql,
      reporttype: this.reportType,
      selectedManager: managerId,
      tripStartDate: this.from_Date,
      tripEndDate: this.to_Date,
      contactid: this._adminid,
      accountid: this._accid,
      reportid: this.reportId,
      driverormanager: this.DriverManager,
      monthVal: months,
      checkLimit: this.limitOfrecord
    })
      .then((result) => {
        this.updatedList = [];
        this.searchdata = [];
        this.filterdata = JSON.parse(result);
        console.log("length1", JSON.stringify(this.filterdata));
        if (this.filterdata.length > 0) {
          this.showbuttons = true;
          this.recordDisplay = true;

          // Use commonFIlter to set data dynamically
          let formatted;
          try {
            formatted = this.commonFilter(this.filterdata, this.reportData, this);
            console.log("this.filterdata", JSON.stringify(formatted))
          }catch(e) {
             console.log("Error formatting", e.message)
          }
          // Added by Raj

          this.searchdata = JSON.parse(JSON.stringify(formatted));
          this.exceldata = this.createExcelData(formatted, this.header);
          this.tempAllData = this.searchdata;
          console.log("this.searchdata", JSON.stringify(this.searchdata));
          this.dynamicBinding(this.searchdata, this.headerdata)
          // this.filterdatanew = this.searchdata;
          // this.filterdataSearch = this.searchdata;
          setTimeout(() => {
            this.dispatchEvent(
              new CustomEvent("hide", { detail: '' })
            );
          }, 2000);

          this.template.querySelector('c-user-preview-table').tableListRefresh(this.searchdata);

          this.editedCount = 0;
          let search = this.template.querySelector('.filter-input');
          console.log('Search : ' + search?.value);
          if(search && search.value) {
            this.template.querySelector('c-user-preview-table').searchByKey(search.value);
            this.filterdataSearch = this.searchdata;
            console.log('Filtered Search Data in Apply : ' + JSON.stringify(this.filterdataSearch));
            this.exceldata = this.createExcelData(this.filterdataSearch,this.header);
          }

          if (this.limitOfrecord > 0) {
            let originalString = SALESFORCE_LIMIT_MSG;
            this.dispatchEvent(
              new CustomEvent("toastmessage", {
                detail: {
                  errormsg: "info",
                  message: originalString.replace("2000", this.limitOfrecord)
                }
              })
            )
          }
        } else {
          this.showbuttons = false;
          // this.recordDisplay = false;
          this.searchdata = [];
          setTimeout(() => {
            this.dispatchEvent(
              new CustomEvent("hide", { detail: '' })
            );
          }, 2000);
          this.template.querySelector('c-user-preview-table').tableListRefresh(this.searchdata);

        }
      })
      .catch(error => {
        console.log("failure", error);
        this.showbuttons = false;
        // this.recordDisplay = false;
        this.searchdata = [];
        setTimeout(() => {
          this.dispatchEvent(
            new CustomEvent("hide", { detail: '' })
          );
        }, 2000);
        this.template.querySelector('c-user-preview-table').tableListRefresh(this.searchdata);
        this.dispatchEvent(
          new CustomEvent("toastmessage", {
            detail: {
              errormsg: "error",
              message: "System Error: A team member has been notified to identify and address the issue within a working day.If it is urgent, please contact support for a solution."
            }
          })
        )
      });
  }
  handleConcur() {
    this.dispatchEvent(
      new CustomEvent("show", { detail: '' })
    );
    postTotalReimbursementForAllUser({ accId: this._accid })
      .then((result) => {

        this.dispatchEvent(
          new CustomEvent("hide", { detail: '' })
        );
      })
      .catch(error => {
        console.log("failure", error);
        this.dispatchEvent(
          new CustomEvent("hide", { detail: '' })
        );
      });
  }

  handleIndividualConcur(event) {
    this.dispatchEvent(
      new CustomEvent("show", { detail: '' })
    );
    let recordKey = event.detail.key;
    let recordId = event.detail.id;
    let record, email, totalReimbursement, month;
    if(this.searchdata.length > 0) {
      record = this.searchdata.find(entry => entry.Id === recordId);
      email = record["E-mail"];
      totalReimbursement = record["Total Reimbursement"];
      month = record["Month"];
    } else {
      record = this.finaldata.find(entry => entry.Id === recordId);
      email = record["E-mail"];
      totalReimbursement = record["Total Reimbursement"];
      month = record["Month"];
    }
    console.log("Concur : " + email + totalReimbursement + ',' + month);
    postExpenseReimbursement({
      accountId: this._accid,
      empReMonth: month,
      contactEmail: email,
      totalReimburement: totalReimbursement
    })
      .then(result => {
          console.log("Result from Individual Concur Sync : " + result);
          setTimeout(() => {
            this.dispatchEvent(
              new CustomEvent("hide", { detail: '' })
            );
          }, 2000);
          if(result == 'OK') {
            this.dispatchEvent(
              new CustomEvent("toastmessage", {
                detail: {
                  errormsg: "success",
                  message: "Expense is successfully send to triplog"
                }
              })
            )
          } else {
            this.dispatchEvent(
              new CustomEvent("toastmessage", {
                detail: {
                  errormsg: "error",
                  message: result
                }
              })
            )
          }
      })
      .catch(error => {
          console.log("Error in Individual Concur Sync : " + JSON.stringify(error));
          setTimeout(() => {
            this.dispatchEvent(
              new CustomEvent("hide", { detail: '' })
            );
          }, 2000);
          this.dispatchEvent(
            new CustomEvent("toastmessage", {
              detail: {
                errormsg: "error",
                message: "Fail to send Expense to triplog."
              }
            })
          )
      });
  }

  handleSendEmail() {
    checkBiweeklyPayPeriod({ startDT: this.from_Date, endDt: this.to_Date, ConId: this._adminid })
      .then((result) => {

      })
      .catch(error => {
        console.log("failure", error);
      });
  }
  showupdatebtn() {
    this.updatebtn = true;
  }
  sortList(event) {
    this.editedCount++;
    console.log("this.editedCount", this.editedCount)
    if (this.editedCount == 1) {
      let sortedData = JSON.parse(event.detail)
      if (this.searchdata.length > 0) {
        this.filterdatanew = sortedData;
        this.filterdataSearch = sortedData;
      } else {
        this.loaddata = sortedData;
        this.finaldataSearch = sortedData;
      }
      console.log("Data sorted", event.detail);
    }
  }
  handleUpdateList(event) {

    this.updatebtn = true;
    this.stringifydata = event.detail.list;
    let updData = JSON.parse(event.detail.list);
    console.log("Before Update updData", JSON.stringify(updData));
    this.remId = event.detail.id;
    updData.forEach(row => {
      if (this.remId == row.Id) {
        this.editable_feilds.forEach(index => {
          let str1 = index.split('-')[1];
          let key = index.split('-')[0];
          if (row.hasOwnProperty(key)) {
            const woCmVal = row[key].replace(/,/g, '');
            console.log('woCmVal : ' + woCmVal);
            const value1 = parseFloat(woCmVal) || 0; // Convert to float, default to 0 if not a valid number
            const value2 = parseFloat(row['Variable Amount']) || 0;
            this.totalsum = value1 + value2;
            row['Total Reimbursement'] = this.totalsum.toLocaleString();
						this.keyName = key;
            this.keyValue = row[key];
            let finalJson = [];
            finalJson.push({ Id: row.Id, [str1]: this.keyValue })
            this.updatedList.push(finalJson)
          }
        })
      }
    })
    console.log("After Update updData", JSON.stringify(updData));
    if (this.searchdata.length > 0) {
      this.searchdata = updData;
      this.finaldata = updData;
      console.log("Before Assign searchdata : " + JSON.stringify(this.searchdata));
      if (this.isSearch == true) {
        this.filterdataSearch = updData;
        this.filterdataSearch.forEach(row => {
          if (this.remId == row.Id) {
            if (row.hasOwnProperty(this.keyName)) {
              row[this.keyName] = this.formatNumberWithCommas(this.keyValue);
              row['Total Reimbursement'] = this.totalsum.toLocaleString();
            }
          }
        })
      }
    } else {
      this.finaldata = updData;
      console.log("Before Assign finaldata : " + JSON.stringify(this.finaldata));
      if (this.isSearch == true) {
        this.finaldataSearch = updData;
        this.finaldataSearch.forEach(row => {
          if (this.remId == row.Id) {
            if (row.hasOwnProperty(this.keyName)) {
              row[this.keyName] = this.formatNumberWithCommas(this.keyValue);
              row['Total Reimbursement'] = this.totalsum.toLocaleString();
            }
          }
        })
      }
    }
  }
  handleupdate() {
    this.dispatchEvent(
      new CustomEvent("show", { detail: '' })
    );
    const mergedArray = [].concat(...this.updatedList);
    const mergedObjects = {};
    // Loop through the inputArray
    for (const obj of mergedArray) {
      const id = obj.Id;
      if (!mergedObjects[id]) {
        // If the ID doesn't exist in mergedObjects, create a new object
        mergedObjects[id] = { Id: id };
      }
      // Merge the properties from the current object into the merged object
      Object.assign(mergedObjects[id], obj);
    }
    // Convert the mergedObjects object back into an array
    const deduplicatedArray = Object.values(mergedObjects);
    console.log('Duplicate Array : ' + JSON.stringify(deduplicatedArray));


    updateEditableField({ data: JSON.stringify(deduplicatedArray), idOfRecord: this.remId })
      .then((result) => {
        this.dispatchEvent(
          new CustomEvent("hide", { detail: '' })
        );
        this.dispatchEvent(
          new CustomEvent("toastmessage", {
            detail: {
              errormsg: "success",
              message: "Data Update Successfully"
            }
          })
        )
        this.updatebtn = false;
        if (this.isSearch == true) {
          if (this.searchdata.length > 0) {
            this.dynamicBinding(this.filterdataSearch, this.headerdata)
            // this.filterdataSearch = this.filterdataSearch.sort((a, b) => b - a);
            /* Fixed decimal issue in Fixed Amount field */
            for (let record of this.filterdataSearch) {
              for (let keyField of record.keyFields) {
                if (keyField.key === "Fixed" && keyField.value !== null && keyField.value.endsWith(".")) {
                  keyField.value = keyField.value.slice(0, -1);
                }
              }
            }
            /* Added by Raj */
            this.template.querySelector('c-user-preview-table').refreshTable(this.filterdataSearch);
            this.filterdataSearch.forEach(updateRecord => {
              let index = this.tempAllData.findIndex(record => record.Id === updateRecord.Id);
              if (index !== -1) {
                this.tempAllData[index] = updateRecord;
              }
            });
            this.exceldata = this.createExcelData(this.filterdataSearch,this.header);
            this.filterdatanew = this.filterdataSearch;
          } else {
            this.dynamicBinding(this.finaldataSearch, this.headerdata)
            // this.finaldataSearch = this.finaldataSearch.sort((a, b) => b - a);
            /* Fixed decimal issue in Fixed Amount field */
            for (let record of this.finaldataSearch) {
              for (let keyField of record.keyFields) {
                if (keyField.key === "Fixed" && keyField.value !== null && keyField.value.endsWith(".")) {
                  keyField.value = keyField.value.slice(0, -1);
                }
              }
            }
            /* Added by Raj */
            this.template.querySelector('c-user-preview-table').refreshTable(this.finaldataSearch);
            console.log("this.finaldataSearch in update function : " + JSON.stringify(this.finaldataSearch));
            this.finaldataSearch.forEach(updateRecord => {
              let index = this.tempAllData.findIndex(record => record.Id === updateRecord.Id);
              if (index !== -1) {
                this.tempAllData[index] = updateRecord;
              }
            });
            this.exceldata = this.createExcelData(this.finaldataSearch,this.header);
            this.loaddata = this.finaldataSearch;
          }
          this.isSearchEnable = this.searchkey == "" ? true : false;
          if (this.template.querySelector('c-user-preview-table')) {
            this.template.querySelector('c-user-preview-table').searchByKey(this.searchkey);
          }
        } else {
          if (this.searchdata.length > 0) {
            this.dynamicBinding(this.searchdata, this.headerdata);
            /* Fixed decimal issue in Fixed Amount field */
            for (let record of this.searchdata) {
              for (let keyField of record.keyFields) {
                if (keyField.key === "Fixed" && keyField.value !== null && keyField.value.endsWith(".")) {
                  keyField.value = keyField.value.slice(0, -1);
                }
              }
            }
            /* Added by Raj */
            this.template.querySelector('c-user-preview-table').refreshTable(this.searchdata);
            this.exceldata = this.createExcelData(this.searchdata,this.header);
            this.filterdatanew = this.searchdata;
          } else {
            this.dynamicBinding(this.finaldata, this.headerdata)
            /* Fixed decimal issue in Fixed Amount field */
            for (let record of this.finaldata) {
              for (let keyField of record.keyFields) {
                if (keyField.key === "Fixed" && keyField.value !== null && keyField.value.endsWith(".")) {
                  keyField.value = keyField.value.slice(0, -1);
                }
              }
            }
            /* Added by Raj */
            this.template.querySelector('c-user-preview-table').refreshTable(this.finaldata);
            this.exceldata = this.createExcelData(this.finaldata,this.header);
            this.loaddata = this.finaldata;
          }
        }



      })
      .catch(error => {
        console.log("failure", error);
        this.dispatchEvent(
          new CustomEvent("hide", { detail: '' })
        );
        this.dispatchEvent(
          new CustomEvent("toastmessage", {
            detail: {
              errormsg: "error",
              message: "Something went wrong."
            }
          })
        )
      });
    this.updatebtn = false;
  }
  handleCancel() {
    this.updatebtn = false;
    this.updatedList = [];
    let canceldata;
    if (this.isSearch == true) {
      if (this.searchdata.length > 0) {
        this.filterdatanew.forEach((filterDataItem) => {
          filterDataItem.keyFields.forEach((tempKeyItem) => {
            console.log("keyFieldKey", tempKeyItem.key + '----' + this.keyName + '---' + tempKeyItem.value)
            if (this.keyName === tempKeyItem.key) {
              filterDataItem[this.keyName] = tempKeyItem.value;
            }
          });
        });
      } else {
        this.loaddata.forEach((filterDataItem) => {
          filterDataItem.keyFields.forEach((tempKeyItem) => {
            console.log("keyFieldKey", tempKeyItem.key + '----' + this.keyName + '---' + tempKeyItem.value)
            if (this.keyName === tempKeyItem.key) {
              filterDataItem[this.keyName] = tempKeyItem.value;
            }
          });
        });
      }
    }
    if (this.searchdata.length > 0) {
      canceldata = this.filterdatanew;
    } else {
      canceldata = this.loaddata;
    }
    console.log("canceldata", JSON.stringify(canceldata))
    // canceldata = canceldata.sort((a, b) => b - a);
    // this.dynamicBinding(canceldata , this.headerdata)

    this.template.querySelector('c-user-preview-table').refreshTable(canceldata);

    this.isSearchEnable = this.searchkey == "" ? true : false;
    if (this.template.querySelector('c-user-preview-table')) {
      this.template.querySelector('c-user-preview-table').searchByKey(this.searchkey);
    }

    if (this.searchdata.length > 0) {
      this.searchdata = canceldata;
      this.exceldata = canceldata;
    } else {
      this.finaldata = canceldata;
      this.exceldata = canceldata;
    }
  }

  handleShowLockUnlock(event) {
    const dataField = event.target.dataset.id;
    console.log('dataField -- ' + dataField);
    let header;
    if(dataField == 'lock') {
      header = 'Your Report Is Currently Locked';
    } else if(dataField == 'unlock') {
      header = 'Your Report Is Currently Unlocked';
    }
    let detail = {
      dataField,
      header
    };
    this.template.querySelector('c-lock-unlock-popup').initializeModal(detail);
  }

  handleLockIconChange() {
    this.isLockIcon = !this.isLockIcon;
  }

  showToast(event) {
    this.dispatchEvent(
      new CustomEvent("toastmessage", {
        detail: event.detail
      })
    )
  }

  handleShowSpiner() {
    this.dispatchEvent(
      new CustomEvent("show", { detail: '' })
    );
  }

  handleHideSpiner() {
    this.dispatchEvent(
      new CustomEvent("hide", { detail: '' })
    );
  }

  getreport() {
    getReportDetails({ reportid: this.reportId })
      .then(result => {
        let jsondata = result.replace(/\'/g, "\\'");
        let resultdata = JSON.parse(jsondata);
        console.log("resultData : " + JSON.stringify(resultdata));
        if (resultdata.isConcur__c  == true && (NewEnglandGypsum.includes(this._accid) || SPBS_Account == this._accid)) {
          this.concurbtn = true;
        }
        if (resultdata.isConcur__c  == true && (NewEnglandGypsum.includes(this._accid) || SPBS_Account == this._accid) && resultdata.Name == 'Variable Reimbursement Report') {
          this.concurbtn = false;
        }
        if(resultdata.isConcur__c  == true && varReimC.includes(this._accid) && resultdata.Name != 'Monthly Fixed and Variable Report' && resultdata.Name == 'Variable Reimbursement Report') {
          this.concurbtn = true;
        }
        if (resultdata.isLockReport__c == true) {
          this.isLockUnlockIcon = true;
          gerAccountStatus({ accId : this._accid })
          .then(result => {
              if(result == 'Locked') {
                this.isLockIcon = true;
              } else {
                this.isLockIcon = false;
              }
          })
          .catch(error => {
              console.log('Error in gerAccountStatus : ' + JSON.stringify(error));
          });
        }
        this.reportData = resultdata;
        console.log("resultdata", jsondata)
        this.reportType = resultdata.Report_Type__c;
        // Set this.reportsoql
        this.reportsoql = resultdata.Report_Soql__c;
        // Added by Raj

        let showfilter = resultdata.Filter_By__c == undefined ? '' : resultdata.Filter_By__c
        this.reportName = resultdata.Name;
        this.displayReportName = resultdata.Name.endsWith(" Report") ? resultdata.Name.slice(0, -7) : resultdata.Name;

        this.limitOfrecord = resultdata.Limit__c == undefined ? 0 : resultdata.Limit__c;

        if (resultdata.Editable_Fields__c != undefined) {
          this.editablefield = resultdata.Editable_Fields__c
          var editarry = new Array();
          editarry = this.editablefield.split(",");
          this.editable_feilds = JSON.parse(JSON.stringify(editarry));
        }
        if (showfilter.length > 0) {
          if (showfilter.includes('Monthly')) {
            this.monthlyDropdown = true;
            this.weeklyDropdown = false;
            this.dateRange = false;
          } else if (showfilter.includes('Biweek Reimbursement')) {
            this.weeklyDropdown = true;
            this.dateRange = false;
            this.monthlyDropdown = false;

          } else if (showfilter == 'Dates') {
            var currentDate = new Date();
            let startDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1);
            let enddate = new Date(currentDate.getFullYear(), currentDate.getMonth(), 0);
            let convertdate, convertmonth, convertYear, getyear, endconvertdate, endconvertmonth;
            if(startDate.getMonth() === 0) {
              convertmonth = '12';
            }
            else if (startDate.getMonth() < 9) {
              convertmonth = '0' + startDate.getMonth();
            } else {
              convertmonth = startDate.getMonth();
            }
            if (startDate.getDate() < 9) {
              convertdate = '0' + startDate.getDate();
            } else {
              convertdate = startDate.getDate();
            }
            getyear = startDate.getYear().toString();
            if(startDate.getMonth() === 0) {
              convertYear = getyear.substring(1) - 1;
            } else {
              convertYear = getyear.substring(1);
            }
            this.from_Date = convertmonth + '/' + convertdate + '/' + convertYear;
            if (enddate.getMonth() < 9) {
              endconvertmonth = '0' + (enddate.getMonth() + 1);
            } else {
              endconvertmonth = enddate.getMonth() + 1;
            }
            if (enddate.getDate() < 9) {
              endconvertdate = '0' + enddate.getDate();
            } else {
              endconvertdate = enddate.getDate();
            }
            this.to_Date = endconvertmonth + '/' + endconvertdate + '/' + convertYear;
            this.dateRange = true;
            this.monthlyDropdown = false;
            this.weeklyDropdown = false;
          }
        }

        if (resultdata.Use_Manager_List__c == true) {
          this.DriverManager = 'Manager';
        } else {
          this.DriverManager = 'Driver';
        }
        this.placeholder = 'Select ' + this.DriverManager;

        // Take commonFilter Code for early usage basis
        let sql = this.reportData.Report_Soql__c.split('from');
        let fields = sql[0].split('select')[1].trim().split(',');
        this.detail = fields;
        if (this.reportData.Report_Header__c != undefined) {
          if (this.reportData.Report_Header__c.includes(',')) {
              this.cfHeaderlist = this.reportData.Report_Header__c.split(',');
          }
          else {
              this.cfHeaderlist.push(this.reportData.Report_Header__c);
          }
        }
        if(this.concurbtn === true) {
              this.cfHeaderlist.push("Concur");
        }
        // Set this.headerdata
        this.headerdata = JSON.parse(JSON.stringify(this.cfHeaderlist));

        if (this.reportData.Numeric_Fields__c != undefined) {
          if (this.reportData.Numeric_Fields__c.includes(',')) {
            this.cfHeaderfields = this.reportData.Numeric_Fields__c.split(',');
          }
          else {
            this.cfHeaderfields.push(this.reportData.Numeric_Fields__c.trim());
          }
        }
        if (this.reportData.Date_Time_Fields__c != undefined) {
          if (this.reportData.Date_Time_Fields__c.includes(',')) {
            this.cfReportdatetimefields = this.reportData.Date_Time_Fields__c.split(',');
          }
          else {
            this.cfReportdatetimefields.push(this.reportData.Date_Time_Fields__c.trim());
          }
        }
        if (this.reportData.Date_Fields__c != undefined) {
          if (this.reportData.Date_Fields__c.includes(',')) {
            this.cfReportdatefields = this.reportData.Date_Fields__c.split(',');
          }
          else {
            this.cfReportdatefields.push(this.reportData.Date_Fields__c.trim());
          }
        }
        // Set this.header, columnType, columnName and sortOder
        var headingData = [];
        for(let i = 0; i < this.cfHeaderlist.length; i++) {
          let colType = 'String';
          if(this.cfHeaderfields.includes(this.detail[i])) {
            colType = 'Integer';
          } else if (this.cfReportdatefields.includes(this.detail[i]) || this.cfReportdatetimefields.includes(this.detail[i])) {
            colType = 'Date';
          }
          if(i == 0) {
            if(this.headerdata.includes('Activation Date')) {
              this.columnName = "Activation Date";
              this.columnType = 'Date';
              this.sortOrder = 'asc';
            } else if(this.reportName == 'Monthly Review') {
              this.columnName = "Manager Name";
              this.columnType = 'String';
              this.sortOrder = 'desc';
            } else {
              this.columnName = this.headerdata[i];
              this.columnType = colType;
              this.sortOrder = 'desc';
            }
            headingData.push({ id: i, name: this.cfHeaderlist[i], colName: this.cfHeaderlist[i], colType: colType, arrUp: true, arrDown: false, isConcur: false });
          } else if(this.cfHeaderlist[i] == "Concur") {
            headingData.push({ id: i, name: '', colName: this.cfHeaderlist[i], colType: '', arrUp: false, arrDown: false, isConcur: true });
          } else {
            headingData.push({ id: i, name: this.cfHeaderlist[i], colName: this.cfHeaderlist[i], colType: colType, arrUp: false, arrDown: false, isConcur: false });
          }
        }
        this.header = JSON.parse(JSON.stringify(headingData));
        console.log("this.header", JSON.stringify(this.header));
        // Added by Raj

        getManagerDriverDetails({ accountId: this._accid, role: this.DriverManager })
          .then(result => {
            this.DriverManagerList = JSON.parse(result);
            if (this.DriverManagerList.length > 2) {
              this.DriverManagerList.forEach(index => {
                this.picklist.push({ label: index.Name, value: index.Id })
              })
              this.picklist = JSON.parse(JSON.stringify(this.picklist))
            }

          })
          .catch(error => {
            console.log("error", error)
          })

        getDriverManagerDropdownList({ accountId: this._accid, contactId: this._adminid, reportId: this.reportId, checkLimit: this.limitOfrecord })
          .then(result => {
            let data = JSON.parse(result);
            if (this.DriverManager == 'Manager') {
              this.detaildata = JSON.parse(JSON.parse(data[1]));
              this.originalData = JSON.parse(JSON.parse(data[1]));
            } else {
              this.detaildata = JSON.parse(JSON.parse(data[0]));
              this.originalData = JSON.parse(JSON.parse(data[0]));
            }
            console.log('detailData : ' + JSON.stringify(this.detaildata));

            if (this.detaildata.length > 0) {
              this.showbuttons = true;
              if (this.reportId == TripDetailReportSightScience) {
                this.showEmailbtn = true;
              }

              this.recordDisplay = true;

              // Use commonFIlter for dynamic purpose
              let formatted;
              if(this.originalData){
                try{
                  formatted = this.commonFilter(this.originalData, this.reportData, this);
                  console.log("this.originalData", JSON.stringify(formatted))
                 }catch(e){
                   console.log("Error formatting", e.message)
                 }
              }
              // Added by Megha

              this.finaldata = JSON.parse(JSON.stringify(formatted));
              console.log("final data : ", JSON.stringify(this.finaldata));
              this.exceldata = this.createExcelData(formatted, this.header);
              console.log('At getReport exceldata : ' + JSON.stringify(this.exceldata));
              this.finaldata = this.finaldata.sort((a, b) => b - a);
              this.tempAllData = this.finaldata;
              this.dynamicBinding(this.finaldata, this.headerdata);
              console.log("After binding finaldata : ", JSON.stringify(this.finaldata));
              this.ishow = true;

              this.dispatchEvent(
                new CustomEvent("hide", { detail: '' })
              );

            } else {
              this.showbuttons = false;
              this.ishow = true;
              this.recordDisplay = false;
              this.dispatchEvent(
                new CustomEvent("hide", { detail: '' })
              );
            }
          })
          .catch(error => {
            console.log("error in dropdown list", JSON.parse(JSON.stringify(error)));
            // Show Toast while error
            this.showbuttons = false;
            this.ishow = true;
            // this.recordDisplay = false;
            this.finaldata = [];
            setTimeout(() => {
              this.dispatchEvent(
                new CustomEvent("hide", { detail: '' })
              );
            }, 2000);
            this.dispatchEvent(
              new CustomEvent("toastmessage", {
                detail: {
                  errormsg: "error",
                  message: "System Error: A team member has been notified to identify and address the issue within a working day.If it is urgent, please contact support for a solution."
                }
              })
            )
            // Added by Raj
          })
      })
      .catch(error => {
        console.log("error in report list", JSON.parse(JSON.stringify(error)));
        // Show Toast while error
        this.showbuttons = false;
        this.ishow = true;
        // this.recordDisplay = false;
        this.finaldata = [];
        setTimeout(() => {
          this.dispatchEvent(
            new CustomEvent("hide", { detail: '' })
          );
        }, 2000);
        this.dispatchEvent(
          new CustomEvent("toastmessage", {
            detail: {
              errormsg: "error",
              message: "System Error: A team member has been notified to identify and address the issue within a working day.If it is urgent, please contact support for a solution."
            }
          })
        )
        // Added by Raj
      })
  }
  formatNumberWithCommas(number) {
    //return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    return number.toString().replace(/\B(?<!\.\d*)(?=(\d{3})+(?!\d))/g, ","); // added by megha
  }
}

// 0033r000042KVO6AAO