/* eslint-disable vars-on-top */
import { LightningElement, api, track } from 'lwc';
import resourceImage from '@salesforce/resourceUrl/mBurseCss';
export default class ViewDetailUser extends LightningElement {
    @api contactList;
    @api userName;
    @api role;
    @api accountId;
    @api contactId;
    @api tripColumn;
    @api tripKeyFields;
    @api month;
    @api selectedMonth;
    @api redirectDashboard;
    sortable = true;
    isFalse = false;
    isRecord = false;
    classToTable = 'fixed-container';
    noMessage = 'There is no data available';
    searchIcon = resourceImage + '/mburse/assets/mBurse-Icons/Vector.png';
    flagIcon = resourceImage + '/mburse/assets/mBurse-Icons/Tooltip/flag.png';
    unapproveIcon = resourceImage + '/mburse/assets/mBurse-Icons/Tooltip/unapprove.png';
    approveIcon = resourceImage + '/mburse/assets/mBurse-Icons/Tooltip/approve.png';
    @track modelList = [];
    searchmodelList = [];
    monthList = [];
    originalModelList;
    modalKeyFields;
    modalListColumn;
    _value = "";
    isScrollable = false;
    isSearchEnable = true;
    isSort = true;

    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }

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


    dynamicBinding(data, keyFields) {
        data.forEach(element => {
            let model = [];
            for (const key in element) {
                if (Object.prototype.hasOwnProperty.call(element, key)) {
                    let singleValue = {}
                    if (keyFields.includes(key) !== false) {
                        singleValue.key = key;
                        singleValue.value = (key === 'status' || key === 'originname' || key === 'destinationname') ? (element[key] === null || element[key] === undefined || element[key] === "") ? "—" : element[key] : element[key];
                        singleValue.truncate = (key === 'originname' || key === 'destinationname') ? true : false;
                        singleValue.tooltip = (key === 'status' || key === 'originname' || key === 'destinationname') ? true : false;
                        singleValue.tooltipText = (key === 'originname') ? (element.origin != null ? element.origin : 'This trip was manually entered without an address.') : (key === 'destinationname') ? (element.destination != null ? element.destination : 'This trip was manually entered without an address.') : (element.status === 'Rejected') ? (element.approvalName !== null && element.approvalName === 'Tom Honkus') ? 'Your mileage was automatically flagged by the system on ' + element.approveddate :  ((element.approvalName !== null ? element.approvalName : '') + ' flagged on ' + element.approveddate) : (element.status === 'Approved') ? (element.approvalName !== null && element.approvalName === 'Tom Honkus') ? 'Your mileage was automatically approved by the system on ' + element.approveddate : ((element.approvalName !== null ? element.approvalName : '') + ' approved on ' + element.approveddate) : 'Unapproved';
                        singleValue.tIcon = (key === 'status') ? true : false;
                        singleValue.tooltipIcon = (element.status === 'Rejected') ?  this.flagIcon  : (element.status === 'Approved') ?   this.approveIcon : null;
                        singleValue.twoDecimal = (key === "mileage" )? true : false;
                        singleValue.istwoDecimalCurrency = (key === 'variableamount') ? true : false;
                        singleValue.isfourDecimalCurrency = (key === 'variableRate' || key === 'VariableRate') ? true : false;
                        singleValue.hasLeadingZero = ((key === "fuel" ||
                        key === "fixedAmount" ||
                        key === "totalReimbursements" ||
                        key === "varibleAmount" ||
                        key === "fuelPrice" ||
                        key === 'variableamount' ||
                        key === 'totalFixedAmount' ||
                        key === "totalReim" ||
                        key === "variable" || key === "mileage" ||
                        key === "fixed1" || key === "fixed2" ||
                        key === "fixed3") && ((element[key] !== "null" || element[key] !== null) && (singleValue.value !== '0.00') && (singleValue.value !== '0.0000')) && (/^0+/).test(singleValue.value) === true) ? (singleValue.value).replace(/^0+/, '') : null;
                        model.push(singleValue);
                    }
                }
            }
            element.rejectedClass = (element.status === 'Rejected') ? 'rejected' : '';
            element.keyFields = this.mapOrder(model, keyFields, 'key');
        });
    }

    excelToExport(data, file, sheet){
        this.template.querySelector('c-export-excel').download(data, file, sheet);
    }
    
    downloadAllTrips(){
            let mileage = [];
            let fileName = this.userName + '\'s Mileage ' + this.dateTime(new Date());
            let sheetName = 'Mileage Report';
            let excelList = this.sort(this.modelList, "tripdate");
            mileage.push(["Contact Email", "Tracking Method", "Day Of Week", "Trip Date", "Start Time", "End Time", "Trip Origin", "Trip Destination", "Mileage", "Status", "Date Submitted", "Maint/Tires", "Fuel Rate", "Variable Rate", "Amount", "Drive Time", "Stay Time", "Total Time", "Notes", "Tags"])
            excelList.forEach((item)=>{
                item.drivingtime = this.timeConversion(item.drivingtime);
                item.staytime = this.timeConversion(item.staytime);
                item.totaltime = this.timeConversion(item.totaltime);
                mileage.push([item.emailaddress, item.tracingstyle, item.dayofweek, item.tripdate, item.starttime, item.endtime, item.originname, item.destinationname, item.mileage, item.status, item.submitteddate, item.maintTyre, item.fuelVariableRate, item.variablerate, (parseInt(item.variableamount, 10)).toFixed(2), item.drivingtime, item.staytime, item.totaltime, item.notes, item.tag])
            })
            this.excelToExport(mileage, fileName, sheetName);
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

    handleMonthChange(event){
        const monthEvent = new CustomEvent('monthchange', { detail: event.detail.value });
        this.dispatchEvent(monthEvent);
    }

    revertHandler(){
        let backTo = (this.redirectDashboard) ? 'Dashboard' : '';
        this.dispatchEvent(
            new CustomEvent("back", {
                detail: backTo
            })
        );
    }

    connectedCallback(){
        this.isScrollable = true;
        this.paginatedModal = true;
        this.modalListColumn = [];
        this.modalKeyFields = [];
        if(this.month){
            this.monthList = this.proxyToObject(this.month);
        }
        if (this.contactList) {
            this.modelList = this.proxyToObject(this.contactList);
            this.originalModelList = this.proxyToObject(this.contactList);
            this.classToTable = this.modelList.length > 5 ? 'fixed-container' : 'fixed-container overflow-none'
            this.modalListColumn = this.tripColumn;
            this.modalKeyFields = this.tripKeyFields;
            this.dynamicBinding(this.modelList, this.modalKeyFields);
            this.isRecord = this.modelList.length > 0 ? true : false;
        }
    }
}