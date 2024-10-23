/* eslint-disable no-undef */
/* eslint-disable no-restricted-globals */
import { LightningElement, api, track } from 'lwc';
import updateBiWeekData  from '@salesforce/apex/ConfirmTripTimeERMIController.updateBiWeekData'
import deleteTripsForErmi from '@salesforce/apex/ConfirmTripTimeERMIController.deleteTripsForErmi'
import syncTripsForErmi from '@salesforce/apex/ConfirmTripTimeERMIController.syncTripsForErmi'
import reimMileages from '@salesforce/apex/ConfirmTripTimeERMIController.reimMileages';
export default class WeeklyTimesheet extends LightningElement {
    @api mileageList;
    @api userRole;
    @api userProfile;
    @api accountId;
    @api contactId;
    @api columns;
    @api rows;
    @api driverType;
    @api payPeriod;
    @api showteam;
    @api admindriver;
    @api driverName;
    @api biweekId;
    @track biweekList = [];
    excelList = [];
    isTimesheet = true;
    downloadBtn = false;
    submitRequestBtn = true;
    submitRequestSyncBtn = true;
    headerTitle = 'Weekly Time Sheet';
    confirmMessage = 'This week’s hours/mileage is correct'
    errorMessage = 'There are errors with my time/mileage'
    message = 'weekly time and attendance'
    proxyToObject(e){
        return JSON.parse(e);
    }

    parseError(data) {
        return JSON.parse(JSON.stringify(data));
    }

    getElement(a, index){
        return a[index]
    }

    confirmToggle(event){
        if(this.mileageList){
            let element = this.getElement(this.biweekList, 0);
            element.confirmCheck = event.target.checked;
            element.errorCheck = false;
            this.template.querySelector('.error-check').checked = false;
            this.submitRequestBtn = (element.confirmCheck === true) ? false : true;
        }
    }

    errorToggle(event){
        if(this.mileageList){
            let element = this.getElement(this.biweekList, 0);
            element.errorCheck = event.target.checked;
            element.confirmCheck = false;
            this.template.querySelector('.confirm-check').checked = false;
            this.submitRequestBtn = (element.errorCheck === true) ? false : true;
        }
    }

    completeToggle(event){
        this.submitRequestSyncBtn = (event.target.checked) ? false : true;
    }

    showSpinner() {
        this.dispatchEvent(
          new CustomEvent("show", {
            detail: ''
          })
        );
      }
    
    hideSpinner() {
        this.dispatchEvent(
          new CustomEvent("hide", {
            detail: ''
          })
        );
    }

    submitRequest(){
        var requestInfo = [], driverDash;
        this.showSpinner();
        let element = this.getElement(this.biweekList, 0);
        driverDash = "/app/driverProfileDashboard?accid="+this.accountId+"&id="+this.contactId;
        element.countErrorCheck =  (element.errorCheck === true) ? ((element.countErrorCheck) + 1) : element.countErrorCheck;
        this.biweekList.forEach(function(md){
            var m = {}
            m.biWeekId = md.biWeekId;
            m.confirmCheck = md.confirmCheck;
            m.errorCheck = md.errorCheck;
            m.countErrorCheck = md.countErrorCheck;
            m.driverEmail = md.driverEmail;
            m.driverName = md.driverName;
            m.biWeekPayperiod = md.biWeekPayperiod;
            m.mileage = md.mileage;
            m.driveTime = md.driveTime;
            m.stayTime = md.stayTime;
            m.totalTime = md.totalTime;
            m.driverType = md.driverType;
            requestInfo.push(m);
        })

        updateBiWeekData({
            biweekData: JSON.stringify(requestInfo)
        }).then((data) => {
            if(data === 'Success'){
                this.hideSpinner();
                if (requestInfo[0].errorCheck === true && requestInfo[0].countErrorCheck < 4) {
                    this.isTimesheet = false;
               } else {
                    if(requestInfo[0].errorCheck === true && requestInfo[0].countErrorCheck === 4){
                        const infoEvent = new CustomEvent("info", {
                            detail: { message: "A support team member will contact you M-F between 7:00 am - 6:00 pm MST.", type: "info"}
                          });
                        this.dispatchEvent(infoEvent);
                        this.template.querySelector('.transition').style.pointerEvents = "none";
                        setTimeout(function() {
                            if(this.userRole === 'Admin/Driver') {
                                location.assign(driverDash);
                            }else if(this.userRole === "Manager/Driver"){
                                location.assign(driverDash);
                            }else{
                                location.assign(driverDash);
                            }
                        }, 3000)
                    }else{
                        location.assign(driverDash);
                    }
                }
            }
        }).catch(err=> {
            this.hideSpinner();
            console.log(this.parseError(err));
        })
    }

    submitRequestSync(){
        var  stDate , endDate, splitList, search;
        this.showSpinner();
        let element = this.getElement(this.biweekList, 0);
        let params = new URL(document.location).searchParams;
        search = params.get("sync");
        splitList =   element.biWeekPayperiod.split(" to ");
        stDate = splitList[0];
        endDate = splitList[1];
        deleteTripsForErmi({
            contactId: this.contactId,
            startdate: stDate,
            enddate: endDate
        }).then((result) => {
            if(result === 'success'){
                syncTripsForErmi({
                    contactId: this.contactId,
                    startdate: stDate,
                    enddate: endDate
                }).then((data) => {
                    if(data === 'sucess'){
                       window.location.href =  "/app/driverDashboardWeekly" + (location.search).replace(`&sync=${search}`, '') +"&sync="+element.countErrorCheck;
                    }
                }).catch(()=>{
                    this.hideSpinner();
                })
            }
        }).catch(()=> {
            this.hideSpinner();
        })
    }

    excelToExport(data, file, sheet) {
        this.template.querySelector("c-export-excel").download(data, file, sheet);
    }
    
    downloadAllTrips() {
        let mileage = [];
        let fileName = this.driverName + '\'s Detail Report';
        let sheetName = "Weekly Report";
        let excelList = this.excelList;
        mileage.push(["Email", "Tracking method", "Day Of Week", "Trip Date", "Start Time", "End Time", "Origin Name", "Origin Address", "Destination Name", "Destination Address", "Mileage", "Status", "Date Submitted", "Date Processed", "Processed By", "Tags", "Notes", "Maint/Tires", "Fuel Rate", "Mi Rate", "Drive Time", "Stay Time", "Total Time", "Trip Type", "Amount"]);
        excelList.forEach((item) => {
          mileage.push([
            item.emailaddress, item.tracingstyle, item.dayofweek, item.tripdate, item.starttime, item.endtime, item.originname, item.origin, item.destinationname, item.destination, item.mileage, item.status, item.submitteddate, item.approveddate, item.approvalName, item.tag, item.notes, item.maintTyre, item.fuelVariableRate, item.variablerate, item.drivingtime, item.staytime, item.totaltime, item.tripActivity, item.variableamount
          ]);
        });
        this.excelToExport(mileage, fileName, sheetName);
    }


    async connectedCallback(){
        if(this.mileageList){
            this.biweekList = this.proxyToObject(this.mileageList);
            this.headerTitle = (this.driverType) ? (this.driverType !== 'Driver - Salary') ? 'Weekly Time Sheet' : 'Weekly Mileage Approval' : this.headerTitle;
            this.confirmMessage = (this.driverType) ? (this.driverType !== 'Driver - Salary') ? 'This week’s hours/mileage is correct' : 'This week’s mileage is correct' : this.confirmMessage;
            this.errorMessage = (this.driverType) ? (this.driverType !== 'Driver - Salary') ? 'There are errors with my time/mileage' : 'There are errors on my mileage'  : this.errorMessage;
            this.message = (this.driverType) ? (this.driverType !== 'Driver - Salary') ? 'weekly time and attendance' : 'weekly mileage' : this.message;
            if (this.driverType !== 'Driver - Salary') {
                if (this.biweekList[0] !== undefined &&  this.biweekList[0].countErrorCheck === 3) { // 2
                    this.errorMessage =  "There are still errors on my Weekly Time Sheet Contact Support"
                }
            }
            else {
                if (this.biweekList[0] !== undefined &&  this.biweekList[0].countErrorCheck === 3) {//2
                    this.errorMessage = "There are still errors with my mileage Contact Support"
                }
            }
        }

        await reimMileages({
            biweekReim: this.biweekId
        }).then((result) => {
            if(result){
                this.excelList = this.proxyToObject(result);
                this.downloadBtn = (this.biweekId !== undefined || this.biweekId !== "") && (this.excelList.length > 0) ? true : false;
            }
        }).catch(err=> {
            console.log(this.parseError(err));
        })
    }

}