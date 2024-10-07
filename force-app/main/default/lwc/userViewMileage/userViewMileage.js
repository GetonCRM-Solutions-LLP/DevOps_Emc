/* eslint-disable no-useless-escape */
/* eslint-disable no-restricted-globals */
import { LightningElement, api, track } from 'lwc';
import resourceImage from '@salesforce/resourceUrl/mBurseCss';
import {toDate} from 'c/commonLib';
export default class UserViewMileage extends LightningElement {
    @api contactList;
    @api contactInfo;
    @api accountId;
    @api contactId;
    @api showTeam;
    @api tripColumn;
    @api tripKeyFields;
    @api accountYear;
    @api monthYear;
    @api filter;
    @api role;
    sortable = true;
    isFalse = false;
    isRecord = false;
    monthYearList;
    classToTable = 'fixed-container';
    noMessage = 'There is no data available';
    searchIcon = resourceImage + '/mburse/assets/mBurse-Icons/Vector.png';
    teamList = [{
        "id": 1,
        "label": "My Team",
        "value": "My Team"
    }, {
        "id": 2,
        "label": "Company",
        "value": "Company"
    }
    ]
    
    @track modelList = [];
    searchmodelList = [];
    originalModelList;
    modalKeyFields;
    modalListColumn;
    _value = "";
    isScrollable = false;
    isSearchEnable = true;
    isSort = true;
    isCheckbox = true;
    // tripColumn = [{
    //     id: 1,
    //     name: "Name",
    //     colName: "name",
    //     colType: "String",
    //     arrUp: false,
    //     arrDown: false
    // },
    // {
    //     id: 2,
    //     name: "Activation Date",
    //     colName: "activationDate",
    //     colType: "Date",
    //     arrUp: false,
    //     arrDown: false,
    // }, {
    //     id: 3,
    //     name: "Fixed Amount",
    //     colName: "fixedamount",
    //     colType: "Decimal",
    //     arrUp: false,
    //     arrDown: false,
    // }
    // ];
    // tripKeyFields = ["name", "activationDate", "fixedamount"]

    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }

    proxyToObject(e) {
        return JSON.parse(e)
    }
    
    sort(employees, colName) {
        employees.sort((a, b) => {
          let fa =
              a[colName] == null || a[colName] === ""
                ? ""
                : a[colName].toLowerCase(),
            fb =
              b[colName] == null || b[colName] === ""
                ? ""
                : b[colName].toLowerCase();
    
          if (fa < fb) {
            return -1;
          }
          if (fa > fb) {
            return 1;
          }
          return 0;
        });
    
        return employees;
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

    dynamicBinding(data, keyFields) {
        data.forEach(element => {
            let model = [];
            for (const key in element) {
                if (Object.prototype.hasOwnProperty.call(element, key)) {
                    let singleValue = {}
                    if (keyFields.includes(key) !== false) {
                        console.log("key--", key, element)
                        singleValue.key = key;
                        singleValue.value = (element[key] === "null" || element[key] === null) ? "" : element[key];
                        singleValue.uId = (element.contactid) ? element.contactid : element.id;
                        singleValue.isDate = (key === "activationDate" && element[key] !== null) ? true : false;
                        singleValue.isLink = (key === 'name') ? true : false;
                        singleValue.twoDecimal = (key === "mileage" || key === "rejectedMileges" || key === "totalMileages" || key === "approvedMileages" || key === "totalHighRiskMileages" || key === "highRiskTotalRejected" || key === "highRiskTotalApproved") ? true : false;
                        singleValue.istwoDecimalCurrency = (key === 'fixedamount') ? (element[key] === "null" || element[key] === null) ? false : true  : false;
                        // singleValue.hasLeadingZero = ((
                        // key === "fixedamount") && ((element[key] !== "null" || element[key] !== null))) ? singleValue.value : null;
                        model.push(singleValue);
                    }
                }
            }
           if(element.contactid === undefined){
            element.contactid = element.id
           }
            element.keyFields = this.mapOrder(model, keyFields, 'key');
        });
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

    downloadForHighRisk(){
        let mileage = [];
        let fileName = this.contactInfo + '\'s High Risk Trips ' + this.dateTime(new Date())
        let sheetName = 'Mileage Report';
        let excelList = this.sort(this.modelList, "name");
        mileage.push(["Month", "Name", "Status","Approved Mileage", "Submited Mileage", "Rejected Mileage", "Mileage Approved By", "Managers Name", "Managers Email"])
        excelList.forEach((item)=>{
            mileage.push([item.month, item.name.replace(/\\'/g, "\'"), item.status, item.highRiskTotalApproved, item.totalHighRiskMileages, item.highRiskTotalRejected, item.mileageApproval, item.managerName, item.managerEmail])
        })
        this.excelToExport(mileage, fileName, sheetName);
    }

    downloadForHighMileage(){
        let mileage = [];
        let fileName = this.contactInfo + '\'s High Mileage Trips ' + this.dateTime(new Date())
        let sheetName = 'Mileage Report';
        let excelList = this.sort(this.modelList, "name");
        mileage.push(["Month", "Name", "Status","Approved Mileage", "Submited Mileage", "Rejected Mileage", "Mileage Approved By", "Managers Name", "Managers Email"])
        excelList.forEach((item)=>{
            mileage.push([item.month, item.name.replace(/\\'/g, "\'"), item.status, item.approvedMileages, item.totalMileages, item.rejectedMileages, item.mileageApproval, item.managerName, item.managerEmail])
        })
        this.excelToExport(mileage, fileName, sheetName);
    }

    downloadForMileageSummary(){
        let mileage = [];
        let fileName = this.contactInfo + '\'s Mileage Summary Report ' + this.dateTime(new Date())
        let sheetName = 'Mileage Report';
        let excelList = this.sort(this.modelList, "name");
        mileage.push(["Month", "Name", "Status","Approved Mileage", "Submited Mileage", "Rejected Mileage", "Mileage Approved By", "Managers Name", "Managers Email"])
        excelList.forEach((item)=>{
            mileage.push([item.month, item.name.replace(/\\'/g, "\'"), item.status, item.approvedMileages, item.totalMileages, item.rejectedMileages, item.mileageApproval, item.managerName, item.managerEmail])
        })
        this.excelToExport(mileage, fileName, sheetName);
    }

    downloadForTeam(){
        let mileage = [];
        let fileName = this.contactInfo + '\'s My Team Mileage ' + this.dateTime(new Date())
        let sheetName = 'Mileage Report';
        let excelList = this.sort(this.modelList, "name");
        mileage.push(["Name", "Email", "Activation Date", "Fixed Amount"])
        excelList.forEach((item)=>{
            mileage.push([item.name.replace(/\\'/g, "\'"), item.email, (item.activationDate !== null) ? toDate(item.activationDate) : item.activationDate, (item.fixedamount !== null) ? '$' + item.fixedamount : item.fixedamount])
        })
        this.excelToExport(mileage, fileName, sheetName);
    }
    
    downloadAllTrips(){
        if(this.filter === 'High Risk'){
            this.downloadForHighRisk();
        }else if(this.filter === 'High Mileage'){
            this.downloadForHighMileage();
        }else if(this.filter === 'My Team'){
            this.downloadForTeam();
        }else{
            this.downloadForMileageSummary();
        }
        console.log("Filter", this.filter)
    }

    handleChange(event) {
        this._value = event.target.value;
        this.isSearchEnable = this._value === "" ? true : false;
        this.template.querySelector('c-user-preview-table').searchByKey(this._value)
    }

    handleClearInput(){
        this._value = "";
        this.isSearchEnable = this._value === "" ? true : false;
        this.template
        .querySelector("c-user-preview-table")
        .searchByKey(this._value);
    }

    revertHandler(){
        this.dispatchEvent(
          new CustomEvent("back", {
              detail: ''
          })
       );
    }

    redirectModal(event) {
        const redirectEvent = new CustomEvent('preview', { detail: event.detail });
        this.dispatchEvent(redirectEvent);
    }

    handleTeamChange(event) {
        let teamInput = event.detail.value;
        if (teamInput) {
            if (teamInput === 'My Team') {
                let urlRedirect = location.origin + location.pathname + "?accid=" + this.getUrlParamValue(window.location.href, 'accid') + "&id=" + this.getUrlParamValue(window.location.href, 'id') + "&showteam=false" + location.hash;
                location.assign(urlRedirect);
            } else {
               let urlRedirect = location.origin + location.pathname + "?accid=" + this.getUrlParamValue(window.location.href, 'accid') + "&id=" + this.getUrlParamValue(window.location.href, 'id') + "&showteam=true" + location.hash;
               location.assign(urlRedirect); 
            }
        }
    }

    handleMonthChange(event){
        console.log("event.detail", event.detail.value)
        const monthEvent = new CustomEvent('monthyearchange', { detail: event.detail.value });
        this.dispatchEvent(monthEvent);
    }

    renderedCallback() {
        let showTeamValue = this.getUrlParamValue(window.location.href, 'showteam');
        if(this.showTeam){
           if(showTeamValue === "false"){
               if(this.template.querySelector('c-dropdown-select')){
                   this.template.querySelector('c-dropdown-select').selectedValue = 'My Team';
                   this.template.querySelector('c-dropdown-select').toggleSelected('My Team');
               }
           }else{
               if(this.template.querySelector('c-dropdown-select')){
                   this.template.querySelector('c-dropdown-select').selectedValue = 'Company';
                   this.template.querySelector('c-dropdown-select').toggleSelected('Company');
               }
           }
        }
      }

    connectedCallback(){
        console.log("show team", this.showTeam, this.accountYear)
        this.isScrollable = true;
        this.paginatedModal = true;
        this.isCheckbox = true;
        this.modalListColumn = [];
        this.modalKeyFields = [];
        if(this.accountYear){
            this.monthYearList = this.proxyToObject(this.accountYear);
        }
        if (this.contactList) {
            this.modelList = this.proxyToObject(this.contactList);
            this.originalModelList = this.proxyToObject(this.contactList);
            this.classToTable = this.modelList.length > 5 ? 'fixed-container' : 'fixed-container overflow-none'
            this.modalListColumn = this.tripColumn;
            this.modalKeyFields = this.tripKeyFields;
            this.dynamicBinding(this.modelList, this.modalKeyFields)
            this.isRecord = this.modelList.length > 0 ? true : false;
        }
    }
}