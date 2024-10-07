import { LightningElement, api } from 'lwc';
import getMileages  from '@salesforce/apex/DriverDashboardLWCController.getMileages';
import resourceImage from '@salesforce/resourceUrl/mBurseCss';
import getBiweekMileages  from '@salesforce/apex/DriverDashboardLWCController.getBiweekMileages';
import {
    events
} from 'c/utils';
export default class PreviewTrips extends LightningElement {
    @api contactId;
    @api tripMonth;
    @api tripYear;
    @api biweekValue;
    @api biweekId;
    @api startDate;
    @api endDate;
    @api contactInfo;
    sortable = true;
    isSearchEnable = true;
    recordDisplay = false;
    classToTable = 'fixed-container';
    noMessage = 'There is no data available';
    modelList;
    originalModelList;
    modalKeyFields;
    modalListColumn;
    isScrollable;
    isSort = true;
    _value = ""
    monthColumn = [{
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
        },
        {
            id: 5,
            name: "Status",
            colName: "status",
            colType: "String",
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
            name: "Amount",
            colName: "variableamount",
            colType: "Decimal",
            arrUp: false,
            arrDown: false
        }
    ];
    monthKeyFields = ["tripdate", "originname", "destinationname", "submitteddate", "status", "mileage", "variableamount"]
    searchIcon = resourceImage + '/mburse/assets/mBurse-Icons/Vector.png';
    flagIcon = resourceImage + '/mburse/assets/mBurse-Icons/Tooltip/flag.png';
    unapproveIcon = resourceImage + '/mburse/assets/mBurse-Icons/Tooltip/unapprove.png';
    approveIcon = resourceImage + '/mburse/assets/mBurse-Icons/Tooltip/approve.png';

    proxyToObject(e) {
        return JSON.parse(e)
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

    handleClearInput(){
        this._value = "";
        this.isSearchEnable = this._value === "" ? true : false;
        this.template
        .querySelector("c-user-preview-table")
        .searchByKey(this._value);
    }

    backToDashboard(){
        events(this, '')
    }

    handleChange(event) {
		this._value = event.target.value;
        this.isSearchEnable = this._value === "" ? true : false;
        this.template.querySelector('c-user-preview-table').searchByKey(this._value, this.modelList)
	}

    excelToExport(data, file, sheet){
        this.template.querySelector('c-export-excel').download(data, file, sheet);
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

    downloadAllTrips(){
        if(!this.biweekValue){
            let excelMileage = [];
            let excelFileName = this.contactInfo + '\'s ' + this.tripMonth + ' Mileage Report ' + this.dateTime(new Date());
            let excelSheetName = 'Mileage Report';
            excelMileage.push(["Contact Email", "Tracking Style", "Day Of Week", "Trip Date", "Start Time", "End Time", "Trip Origin", "Trip Destination", "Mileage", "Status", "Date Submitted", "Date Approved", "Maint/Tires", "Fuel Rate", "Variable Rate", "Amount", "Drive Time", "Stay Time", "Total Time", "Notes", "Tags"])
            this.modelList.forEach((item)=>{
                item.drivingtime = this.timeConversion(item.drivingtime);
                item.staytime = this.timeConversion(item.staytime);
                item.totaltime =this.timeConversion(item.totaltime);
            excelMileage.push([item.emailaddress, item.tracingstyle, item.dayofweek, item.tripdate, item.starttime, item.endtime, item.originname, item.destinationname, item.mileage, item.status, item.submitteddate, item.approveddate, item.maintTyre, item.fuelVariableRate, item.variablerate, item.variableamount, item.drivingtime, item.staytime, item.totaltime, item.notes, item.tag])
            })
            this.excelToExport(excelMileage, excelFileName, excelSheetName);
        }else{
            let mileage = [];
            // let clickedPeriod = "Pay Period " + this.startDate + " - " + this.endDate;
            let fileName = this.contactInfo + '\'s Mileage Report ' + this.dateTime(new Date());
            let sheetName = 'Mileage Report';
            mileage.push(["Contact Email", "Tracking Style", "Day Of Week", "Trip Date", "Start Time", "End Time", "Trip Origin", "Trip Destination", "Mileage", "Status", "Date Submitted", "Date Approved", "Maint/Tires", "Fuel Rate", "Variable Rate", "Amount", "Trip Type", "Drive Time", "Stay Time", "Total Time", "Notes", "Tags"])
            this.modelList.forEach((item)=>{
                item.drivingtime = this.timeConversion(item.drivingtime);
                item.staytime = this.timeConversion(item.staytime);
                item.totaltime =this.timeConversion(item.totaltime);
                mileage.push([item.emailaddress, item.tracingstyle, item.dayofweek, item.tripdate, item.starttime, item.endtime, item.originname, item.destinationname, item.mileage, item.status, item.submitteddate, item.approveddate, item.maintTyre, item.fuelVariableRate, item.variablerate, item.variableamount, item.tripActivity, item.drivingtime, item.staytime, item.totaltime, item.notes, item.tag])
            })
            this.excelToExport(mileage, fileName, sheetName);
        }
        console.log(this.tripMonth, this.startDate, this.endDate);
    }

    
    connectedCallback(){
        this.isScrollable = true;
        this.paginatedModal = true;
        console.log("biweek --", this.biweekValue)
        if(!this.biweekValue){
          //  this.tripHeader = this.tripMonth;
            getMileages({
                clickedMonth: this.tripMonth,
                year: this.tripYear,
                contactId: this.contactId
            }).then(data => {
                let resultData = data[0].replace(/\\/g, '');
                this.modelList = this.proxyToObject(resultData);
                this.classToTable = this.modelList.length > 5 ? 'fixed-container' : 'fixed-container'
                this.originalModelList = this.proxyToObject(resultData);
                this.modalListColumn = this.monthColumn;
                this.modalKeyFields = this.monthKeyFields;
                this.recordDisplay = (this.modelList.length > 0) ? true : false;
                this.dynamicBinding(this.modelList, this.modalKeyFields)
                console.log("Driver getMileages", data)
            })
            .catch((error)=>{
                    console.log("getMileages error", error)
            })
        }else{
           // this.tripHeader = 'Pay Period'
            getBiweekMileages({
                biweekId: this.biweekId
            }).then(data => {
                let resultData = data[0].replace(/\\/g, '');
                this.modelList = this.proxyToObject(resultData);
                this.classToTable = this.modelList.length > 5 ? 'fixed-container' : 'fixed-container'
                this.originalModelList = this.proxyToObject(resultData);
                this.modalListColumn = this.monthColumn;
                this.modalKeyFields = this.monthKeyFields;
                this.recordDisplay = (this.modelList.length > 0) ? true : false;
                this.dynamicBinding(this.modelList, this.modalKeyFields)
                console.log("Driver getBiweekMileages", data)
            })
            .catch((error)=>{
                    console.log("getBiweekMileages error", error)
            })
        }
     
    }
}