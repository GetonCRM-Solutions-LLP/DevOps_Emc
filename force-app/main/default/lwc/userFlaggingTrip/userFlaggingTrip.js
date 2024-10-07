/* eslint-disable @lwc/lwc/no-api-reassignments */
/* eslint-disable no-restricted-globals */
/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable vars-on-top */
import { LightningElement,api,track } from 'lwc';
import resourceImage from '@salesforce/resourceUrl/mBurseCss';
import MassSyncTripsForBiweek from "@salesforce/apex/ManagerDashboardController.MassSyncTripsForBiweek";
import GetTripCalloutForCommuteMileage from '@salesforce/apex/GetTripCalloutforCommute.GetTripCalloutForCommuteMileage';
import {
    toastEvents, syncEvents
} from 'c/utils';
import approveMileages from "@salesforce/apex/ManagerDashboardController.approveMileages";
import DeleteMileages from "@salesforce/apex/ManagerDashboardController.DeleteMileages";
export default class UserFlaggingTrip extends LightningElement {
    @api contactList;
    @api accountId;
    @api contactId;
    @api headerName;
    @api emailaddress;
    @api isAccountBiweek;
    @api redirectDashboard;
    @api role;
    @api element;
    @api allReimbursementList = [];
    @api commuteList = []; 
    isRecord = false;
    sortable = true;
    modalOpen = false;
    endProcess = false;
    spinner = false;
    _flag = false;
    isFalse = false;
    isSearchEnable = true;
    unapprovereimbursements = [];
    headerModalText = '';
    modalClass = '';
    _value = "";
    headerClass = '';
    subheaderClass = '';
    modalContent = '';
    styleHeader = '';
    styleClosebtn = '';
    noMessage = 'There is no data available';
    classToTable = 'fixed-container';
    originalSelectList = [];
    selectList = [{
        "id": 1,
        "label": "This Page",
        "value": "This Page"
    }, {
        "id": 2,
        "label": "All Pages",
        "value": "All Pages"
    }, {
        "id": 3,
        "label": "None",
        "value": "None"
    }
    ]
    @track modelList = [];
    searchmodelList = [];
    originalModelList;
    modalKeyFields;
    modalListColumn;
    @track flagMileage = [];
    isSubmitVisible = false;
    isScrollable = false;
    isSort = true;
    isCheckbox = true;
    unapproveTripColumn = [{
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
        arrDown: false,
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
    },  {
        id: 5,
        name: "Mileage",
        colName: "mileage",
        colType: "Decimal",
        arrUp: false,
        arrDown: false
    },
    {
        id: 6,
        name: "Amount",
        colName: "variableamount",
        colType: "Decimal",
        arrUp: false,
        arrDown: false
    }]
    unapproveTripKeyFields =   ["tripdate", "originname", "destinationname", "submitteddate", "mileage", "variableamount"]
    searchIcon = resourceImage + '/mburse/assets/mBurse-Icons/Vector.png';
    checkMark = resourceImage + '/mburse/assets/mBurse-Icons/check.png';
    loader = resourceImage + '/mburse/assets/mBurse-Icons/mburse-sync-loading.gif';
    proxyToObject(e) {
        return JSON.parse(e)
    }

    sort(employees, colName){
        employees.sort((a, b) => {
            let fa = (a[colName] == null) ? '' : new Date(a[colName].toLowerCase()),
                fb = (b[colName] == null) ? '' : new Date(b[colName].toLowerCase());
            if (fa < fb) {
                return -1;
            }
            if (fa > fb) {
                return 1;
            }
            return 0;
        });

        return employees
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
            element.isDisabled = (element.driverid === this.contactId) ? true : false;
            if(element.isDisabled){
                element.titleText = 'You can’t self approve mileage.'
            }
            for (const key in element) {
                if (Object.prototype.hasOwnProperty.call(element, key)) {
                    let singleValue = {}
                    if (keyFields.includes(key) !== false) {
                        singleValue.key = key;
                        singleValue.value = (key === 'status' || key === 'originname' || key === 'destinationname') ? (element[key] === null || element[key] === undefined || element[key] === "") ? "—" : element[key] : element[key];
                        singleValue.truncate = (key === 'originname' || key === 'destinationname') ? true : false;
                        singleValue.tooltip = (key === 'originname' || key === 'destinationname') ? true : false;
                        singleValue.tooltipText = (key === 'originname') ? (element.origin != null ? element.origin : 'This trip was manually entered without an address.') : (key === 'destinationname') ? (element.destination != null ? element.destination : 'This trip was manually entered without an address.') : (element.status === 'Rejected') ? (element.approvalName !== null && element.approvalName === 'Tom Honkus') ? 'Your mileage was automatically flagged by the system on ' + element.approveddate :  ((element.approvalName !== null ? element.approvalName : '') + ' flagged on ' + element.approveddate) : (element.status === 'Approved') ? (element.approvalName !== null && element.approvalName === 'Tom Honkus') ? 'Your mileage was automatically approved by the system on ' + element.approveddate : ((element.approvalName !== null ? element.approvalName : '') + ' approved on ' + element.approveddate) : 'Unapproved';
                        singleValue.twoDecimal = (key === "mileage") ? true : false;
                        singleValue.istwoDecimalCurrency = (key === 'variableamount') ? true : false;
                        model.push(singleValue);
                    }
                }
            }
            element.showCheckbox = (element.mileage > '0.00' && (element.status === 'Not Approved Yet' || element.status === ''))? true : false;
            element.keyFields = this.mapOrder(model, keyFields, 'key');
        });
    }

    handleChange(event){
        var pageItem = { "id": 1, "label": "This Page", "value": "This Page" }
        this._value = event.target.value;
        this.isSearchEnable = this._value === "" ? true : false;
        this.isRecord = this._value === "" ? true : false;
        this.template.querySelector('c-user-preview-table').searchByKey(this._value)
        if (this.selectList.length < 2) {
            this.selectList.splice(0, 0, pageItem)
        }
    }


    handleSearchEvent(event) {
        this.searchmodelList = JSON.parse(event.detail);
        if (this.searchmodelList.search === false) {
            this.searchmodelList.content = [];
        }
        //console.log("event-->", JSON.parse(event.detail), JSON.parse(event.detail).length);
    }

    handlePageChange(event) {
        var listElement = [], pageItem = { "id": 1, "label": "This Page", "value": "This Page" }
        listElement = this.selectList;
        let userInput = event.detail.value;
        let boolean = (userInput === 'All Pages') ? true : (userInput === 'None') ? false : false;
        if (userInput === 'This Page') {
            this.flagPerPage();
            this.modelList = this.template.querySelector('c-user-preview-table').returnList();
        } else {
            if (userInput === 'All Pages') {
                this.selectList = listElement.filter(function (a) {
                    return a.value !== "This Page"
                });
            } else {
                let isValid = this.selectList.some(list => list.value === pageItem.value)
                if (this.selectList.length === 2 && !this.searchmodelList.search) {
                    if (!isValid)
                        this.selectList.splice(0, 0, pageItem)
                }
            }
            this.flagAllHandler(boolean);
            this.modelList = this.template.querySelector('c-user-preview-table').returnList();
        }
        //console.log("Select--->", JSON.stringify(event.detail))
    }

    resetList(reimList) {
        this.modelList = reimList;
        this.dynamicBinding(this.modelList, this.modalKeyFields);
        if (this.modelList) {
          this.isSubmitVisible = false;
         // this.modelList = this.sort(this.modelList, "name");
          this.template
            .querySelector("c-user-preview-table")
            .refreshTable(this.modelList);
            this.template.querySelector('c-user-preview-table').defaultSort('tripdate', 'Date', 'desc')
        }
    }

    renderList(event) {
        var arrayElement = [], originalItem = [], item = { "id": 2, "label": "All Pages", "value": "All Pages" }
        arrayElement = this.selectList;
        originalItem = this.selectList;
        if (event.detail < 2) {
            this.selectList = arrayElement.filter(function (a) {
                return a.value !== "All Pages"
            });
        } else if (this.searchmodelList.search === true) {
            this.selectList = arrayElement.filter(function (a) {
                return a.value !== "All Pages"
            });
        } else {
            if (this.selectList.length <= 2) {
                this.selectList.splice(1, 0, item)
            } else {
                this.selectList = originalItem
            }
        }
    }

    flagPerPage() {
        var data = [], count = 0;
        this._flag = true;
        console.log(this.searchmodelList.search, this.searchmodelList)
        data = this.template.querySelector('c-user-preview-table').returnPageList();
        for (let i = 0; i < data.length; i++) {
            if(data[i].driverid !== this.contactId){
                if (data[i].mileage > '0.00') {
                    data[i].isChecked = this._flag;
                }
            }
        }
        this.template.querySelector('c-user-preview-table').resetPageView(data, 'id');
        this.template.querySelector('c-user-preview-table').defaultSort('tripdate', 'Date', 'desc');

        for (let i = 0; i < data.length; i++) {
            if(data[i].driverid !== this.contactId){
                if (data[i].isChecked) {
                    count++;
                }
            }
        }
        this.isSubmitVisible = (count > 0) ? true : false;
    }

    checkUncheckRow(id, value, table) {
        var _tbody = table
        //console.log("inside check", _tbody)
        for (let i = 0; i < _tbody.length; i++) {
            console.log("List of rows-----", _tbody[i].id, id, _tbody[i]);
            _tbody[i].isChecked = (_tbody[i].id === id) ? value : _tbody[i].isChecked;
            if( _tbody[i].isChecked === false  &&  _tbody[i].isSelected === false) {
                _tbody[i].isUnapprove = true;
            }else{
                _tbody[i].isUnapprove = false;
            }
        }
        this.template.querySelector('c-user-preview-table').resetView(_tbody, 'id')
        //this.template.querySelector('c-user-preview-table').defaultSort('tripdate', 'Date', 'desc');
        //console.log("Gotooo---",  this.template.querySelector('c-user-preview-table').returnList())
        return true;
    }

    rowHandler(event) {
        var checkbox, target, count = 0, boolean, model, len, content;
        checkbox = event.detail.isChecked;
        target = event.detail.targetId;
        this.modelList = this.template.querySelector('c-user-preview-table').returnList();
        console.log("Model", this.modelList)
       // content = this.modelList;
       content = (this.searchmodelList.content) ? (this.searchmodelList.content.length > 0) ? this.searchmodelList.content : this.modelList : this.modelList;
        boolean = this.checkUncheckRow(target, checkbox, content);
        model = content;
        len = content.length;
        for (let i = 0; i < len; i++) {
            if (model[i].mileage > '0.00') {
                if (boolean) {
                    if (model[i].isChecked) {
                            count++;
                            //    this.flagMileage.push(model[i]);
                    }
                }
            }
        }
        this.isSubmitVisible = (count > 0) ? true : false;
    //     if (count > 0) {
    //    //     this.flagMileage = this.removeDuplicateValue(this.flagMileage);
    //         if (checkbox === false) {
    //             this.flagMileage.forEach((el) => {
    //                 if (el === target) {
    //                     let index = this.flagMileage.map((a) => {
    //                         return a
    //                     }).indexOf(target);
    //                    // console.log("index", el, target);
    //                     this.flagMileage.splice(index, 1);
    //                 }
    //             });
    //         }
    //     } else {
    //         this.flagMileage = [];
    //     }
    }

    revertHandler(){
        let backTo = (this.redirectDashboard) ? 'Dashboard' : '';
        this.dispatchEvent(
            new CustomEvent("back", {
                detail: backTo
            })
        );
    }

    flagAllHandler(flagValue) {
        var data = [], count = 0;
        this._flag = flagValue;
        this.modelList = this.template.querySelector('c-user-preview-table').returnList();
        // console.log(this.searchmodelList.search, flagValue)
        if (this.searchmodelList.search && flagValue === false) {
            data = this.searchmodelList.content;
        } else {
            data = this.modelList;
        }
        //console.log("approveAll---", data)
        this.flagMileage = [];
        this.template.querySelector('c-user-preview-table').checkUncheckAll(this._flag);
        for (let i = 0; i < data.length; i++) {
            if(data[i].driverid != this.contactId){
                data[i].isChecked = this._flag;
            }
        }
        this.template.querySelector('c-user-preview-table').resetView(data,  'id');
      //  this.template.querySelector('c-user-preview-table').defaultSort('tripdate', 'Date', 'desc');

        for (let i = 0; i < data.length; i++) {
            if(data[i].driverid != this.contactId){
                if (data[i].isChecked) {
                    count++;
                }
            }
        }
        this.isSubmitVisible = (count > 0) ? true : false;
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

    timeConversion(number) {
        var time;
        if(number<0){
            time = number;
        }else{
            var hours = Math.floor(number / 60);
            var min = number % 60;
            hours = hours < 10 ? "0" + hours : hours;
            min = min < 10 ? "0" + min : min;
            time = hours + ':' + min;
        }
      
        //var time = (hours < 12) ? (hours-12 + ':' + min +' PM') : (hours + ':' + min +' AM');
        return time;
    }

    excelToExport(data, file, sheet){
        this.template.querySelector('c-export-excel').download(data, file, sheet);
    }
    
    downloadAllTrips(){
            let mileage = [];
            let fileName = this.headerName + '\'s Mileage ' + this.dateTime(new Date());
            let sheetName = 'Mileage Report';
            let excelList = this.sort(this.modelList, "tripdate");
            mileage.push(["Contact Email", "Tracking method", "Day Of Week", "Trip Date", "Start Time", "End Time", "Trip Origin", "Trip Destination", "Mileage", "Status", "Date Submitted", "Maint/Tires", "Fuel Rate", "Variable Rate", "Amount", "Drive Time", "Stay Time", "Total Time", "Notes", "Tags"])
            excelList.forEach((item)=>{
                item.drivingtime = this.timeConversion(item.drivingtime);
                item.staytime = this.timeConversion(item.staytime);
                item.totaltime = this.timeConversion(item.totaltime);
                mileage.push([item.emailaddress, item.tracingstyle, item.dayofweek, item.tripdate, item.starttime, item.endtime, item.originname, item.destinationname, item.mileage, item.status, item.submitteddate, item.maintTyre, item.fuelVariableRate, item.variablerate, (parseInt(item.variableamount, 10)).toFixed(2), item.drivingtime, item.staytime, item.totaltime, item.notes, item.tag])
            })
            this.excelToExport(mileage, fileName, sheetName);
    }

    syncCallout(obj, index, array){
        GetTripCalloutForCommuteMileage({
            empReID: obj.reimbursementId,
            contactEmail: obj.contactEmail,
            contactid: obj.contactId,
            priMin: obj.startdate,
            priMax: obj.enddate,
            fuel: obj.fuel,
            mpg: obj.mpg,
            maintenansAndTires: obj.maintaincetyre,
            apiToken: obj.accountapi,
            tripStatus: 'U',
            putCall: false,
            activityStatus: 'Business',
            checkByWeek: obj.biWeekValue,
            biWeekReimId: null
        }).then((result)=>{
            console.log("GetTripCalloutForCommuteMileage--", result)
            if(index === (array - 1)){
               // if(methodStatus === 'Completed'){
                   // let toast = { type: "success", message: 'Mileage is being synced.' };
                    syncEvents(this, '')
                    setTimeout(()=>{
                        this.spinner = false;
                    }, 2000)
                   // toastEvents(this, toast);
               // }
            }
//return (index === (array - 1)) ? 'Completed' : 'Pending'

        }).catch((error)=>{
            console.log('Error', error)
        })
    }

    syncMileage(){
        let calloutInfo = this.proxyToObject(this.commuteList);
        this.spinner = true;
       /* this.dispatchEvent(
            new CustomEvent("show", {
                detail: "spinner"
            })
        );*/
       if(this.isAccountBiweek) {
            DeleteMileages({
                reimbursements: JSON.stringify(this.allReimbursementList)
            }).then(()=>{
                if(calloutInfo.length > 0){
                    for(var i = 0 ; i < calloutInfo.length; i++){
                        console.log("Inside Sync Callout", i)
                        this.syncCallout(calloutInfo[i], i, calloutInfo.length);
                        //methodStatus = (i === (calloutInfo.length - 1)) ? 'Completed' : 'Pending'
                    }
                }
            }).catch((error) => {
                this.spinner = false;
                let toast = { type: "error", message: 'Error while deleting mileages.' };
                toastEvents(this, toast);
                console.log('Error', error);
            })   
        }else{
            DeleteMileages({
                reimbursements: JSON.stringify(this.allReimbursementList)
            }).then(()=>{
                if(calloutInfo.length > 0){
                    for(var i = 0 ; i < calloutInfo.length; i++){
                        console.log("Inside Sync Callout", i)
                        this.syncCallout(calloutInfo[i], i, calloutInfo.length);
                        //methodStatus = (i === (calloutInfo.length - 1)) ? 'Completed' : 'Pending'
                    }
                }
            }).catch((error) => {
                this.spinner = false;
                let toast = { type: "error", message: 'Error while deleting mileages.' };
                toastEvents(this, toast);
                console.log('Error', error);
            })   
        }
    }

    flaggingProcess(){
        var approveTrip, flagTrip, unapproveTrip, arrayElement, toast, message
        arrayElement = this.modelList;
        this.dispatchEvent(
            new CustomEvent("show", {
                detail: "spinner"
            })
        );
        console.log("array--", arrayElement)
        approveTrip = arrayElement.filter(function (a) {
            return a.isSelected === true
        });

        flagTrip = arrayElement.filter(function (a) {
            return a.isChecked === true
        });

        unapproveTrip = arrayElement.filter(function(a){
            return a.isUnapprove === true
        })

        approveMileages({
            checked: JSON.stringify(flagTrip),
            selected: JSON.stringify(approveTrip),
            unapprove: JSON.stringify(unapproveTrip),
            name: this.headerName,
            emailaddress: this.emailaddress
        })
        .then((result) => {
            if(result != null){
                if(result === 'success'){
                    message = 'Mileage has been flagged';
                    this.dispatchEvent(
                        new CustomEvent("hide", {
                            detail: "spinner"
                        })
                    );
                    this.dispatchEvent(
                        new CustomEvent("flagcomplete", {
                            detail: this.element
                        })
                    );
                    toast = { type: 'success', message: message }
                    toastEvents(this, toast);
                }else{
                    message = 'A system error has occurred'
                    this.dispatchEvent(
                        new CustomEvent("hide", {
                            detail: "spinner"
                        })
                    );
                    toast = { type: 'error', message: message }
                    toastEvents(this, toast);
                }
                console.log("List after flag", result);
            }else{
                message = 'A system error has occurred'
                this.dispatchEvent(
                    new CustomEvent("hide", {
                        detail: "spinner"
                    })
                );
                toast = { type: 'error', message: message }
                toastEvents(this, toast);
                console.log("List ---", result)
            }
        }).catch((error)=>{
            this.dispatchEvent(
                new CustomEvent("hide", {
                    detail: "spinner"
                })
            );
            if (error.body !== undefined) {
                if (Array.isArray(error.body)) {
                    message = error.body.map((e) => e.message).join(", ");
                } else if (typeof error.body.message === "string") {
                    message = error.body.message;
                }
                toast = { type: 'error', message: message }
                toastEvents(this, toast);
            }
            console.log("Error--", error)
        })
        
        console.log("Approve", approveTrip);
        console.log("Flag", flagTrip);
        console.log("unapprove", unapproveTrip);
    }

    handleClearInput(){
        this._value = "";
        this.isSearchEnable = this._value === "" ? true : false;
        this.template
        .querySelector("c-user-preview-table")
        .searchByKey(this._value);
    }

    cancelFlagging(){
        if (this.template.querySelector("c-user-profile-modal")) {
          this.template.querySelector("c-user-profile-modal").hide();
        }
        this.resetList(this.originalModelList)
    }
    
    
    handleFlagging(){
        if (this.template.querySelector("c-user-profile-modal")) {
          this.template.querySelector("c-user-profile-modal").hide();
        }
        this.flaggingProcess();
    }

    submitHandler(){
        let data = this.modelList, lockdatecount = 0;
        for (let i = 0; i < data.length; i++) {
          if (data[i].isChecked) {
            if (data[i].lockdate !== "") {
                if(data[i].lockdate != null){
                    lockdatecount++;
                }
            }
          }
        }
        
        console.log("lockdate--", lockdatecount, this.emailaddress)
        if (lockdatecount > 0) {
            let lockDate = this.modelList[0].lockdate;
            let currentDateLocked = new Date(lockDate);
            console.log("date", lockDate, currentDateLocked)
           // let lockedMonth = currentDateLocked.toLocaleString('default', { month: 'long' });
            this.islockdate = true;
            this.headerModalText = "Mileage Lock Date";
            this.modalClass = "slds-modal modal_info slds-fade-in-open";
            this.headerClass = "slds-modal__header";
            this.subheaderClass = "slds-p-top_large header-v1";
            this.modalContent = "slds-modal__content";
            this.styleHeader = "slds-modal__container slds-m-top_medium";
            this.styleClosebtn = "close-notify";
            this.contentMessage =
                "This mileage is being processed after the report was closed. Any changes will be applied to the next reimbursement period.";
                if (this.template.querySelector("c-user-profile-modal")) {
                    this.template.querySelector("c-user-profile-modal").show();
                }
        } else {
            this.flaggingProcess();
        }
    }

    connectedCallback(){
        this.isScrollable = true;
        this.paginatedModal = true;
        this.isCheckbox = true;
        this.modelList = [];
        console.log("Contact ---", this.contactList)
        console.log("Version---", this.element)
        if (this.contactList) {
            this.modelList = this.proxyToObject(this.contactList);
            console.log('inside modal list',JSON.stringify(this.modelList));
            this.originalModelList = this.proxyToObject(this.contactList);
            this.classToTable = this.modelList.length > 5 ? 'fixed-container' : 'fixed-container overflow-none'
            this.modalListColumn = this.unapproveTripColumn;
            this.modalKeyFields = this.unapproveTripKeyFields;
            this.dynamicBinding(this.modelList, this.modalKeyFields)
            this.isRecord = this.modelList.length > 0 ? true : false;
        }
    }
}