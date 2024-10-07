import {
    LightningElement,
    api
} from 'lwc';
import deleteTrips from '@salesforce/apex/GetDriverData.deleteTrips';
import MassSyncTrips from '@salesforce/apex/GetDriverData.MassSyncTrips';
import massUpdateActivityEmail from '@salesforce/apex/GetDriverData.massUpdateActivityEmail';
/* Import common js file */
import {
    dateTypeFormat,
    yearMonthDate
} from 'c/commonLib';
export default class SyncModal extends LightningElement {
    waiting = false;
    chkValue = false;
    syStDate;
    syEnDate;
    selectedMonth;
    seletedTripType;
    @api plAccount;
    @api tripTypeList;
    /* Get account Id */
    @api accId;
    /* Get Sync Type */
    @api syncType;
    /* Get Modal Class */
    @api modalClassName() {
        var sectionElement = this.template.querySelector("section");
        return sectionElement;
    }

    /* Get Modal Backdrop Class */
    @api modalBackdropClass() {
        var backdrop = this.template.querySelector("div.Backdrops");
        return backdrop;
    }

    /* options to bind with lightning comboBox */
    get options() {
        var optionList;
        var currentDate = new Date();
        var previousDate = new Date(currentDate.getFullYear(), currentDate.getMonth() - 1, 1);
        var lastSyncMonth = dateTypeFormat(previousDate);
        var currentSyncMonth = dateTypeFormat(currentDate);
        optionList = [{
            label: lastSyncMonth,
            value: lastSyncMonth
        }, {
            label: currentSyncMonth,
            value: currentSyncMonth
        }];
        return optionList;
    }

    get tripActivity() {
        var listOfActivity;
        listOfActivity = [{
            label: 'Business',
            value: 'Business'
        }, {
            label: 'Commute',
            value: 'Commute'
        }];
        return listOfActivity;
    }

    get status() {
        var statusList;
        statusList = [{
                label: "Un Submitted",
                value: "U"
            },
            {
                label: "Submitted",
                value: "S"
            }
        ]
        return statusList;
    }
    // Close 'X' Event
    handleCancel() {
        this.template.querySelector("section").classList.add("slds-hide");
        this.template
            .querySelector("div.Backdrops")
            .classList.add("slds-hide");

    }

    // On Trip Select Change Event

    changeOfTrip(event){
        this.template.querySelector('.slds-button_brand').disabled = (event.detail.value != undefined) ? false : true;
        this.tripValue = event.detail.value;
        this.seletedTripType = this.tripValue;
    }
    // Select Button Click Event
    handleChange(event) {
        if (event.detail.value != undefined) { // && this.stValue != undefined
            this.template.querySelector('.slds-button_brand').disabled = false;
        } else {
            this.template.querySelector('.slds-button_brand').disabled = true;
        }
        this.value = event.detail.value;
        this.selectedMonth = this.value;
        var today = new Date();
        var cDate = dateTypeFormat(today);
        if (cDate === this.value) {
            var now = new Date(today.getFullYear(), today.getMonth(), 1);
            var last = new Date(today.getFullYear(), today.getMonth() + 1, 0);
            this.syStDate = yearMonthDate(now);
            this.syEnDate = yearMonthDate(last);
        } else {
            var previousNow = new Date(today.getFullYear(), today.getMonth() - 1, 1);
            var previousLast = new Date(today.getFullYear(), today.getMonth(), 0);
            this.syStDate = yearMonthDate(previousNow);
            this.syEnDate = yearMonthDate(previousLast);
        }
    }

    // On Trip Status Change
    handleStatusChange(event) {
        this.stValue = event.detail.value;
        if (event.detail.value != undefined && this.selectedMonth != undefined) {
            this.template.querySelector('.slds-button_brand').disabled = false;
        } else {
            this.template.querySelector('.slds-button_brand').disabled = true;
        }
    }
    // handleCheckboxChange(event) {
    //     this.chkValue = event.detail.checked;
    // }

    // On Select Trip Change event
    async selectTrip() {
        console.log(this.seletedTripType);
        if (this.seletedTripType != undefined) {
            this.waiting = true;
            try {
                let changeTripResult = await massUpdateActivityEmail({
                    newActivity: this.seletedTripType,
                    jsondata: this.tripTypeList
                });
                console.log("return result", changeTripResult);
                if (changeTripResult) {
                    const massChangeEvent = new CustomEvent("handlemasschangetriptype", {
                        detail: changeTripResult
                    });
                    this.dispatchEvent(massChangeEvent);
                    setTimeout(() => {
                        this.waiting = false;
                        this.handleCancel();
                    }, 4000);
                }
            } catch (error) {
                console.log(error);
            }
        }
        console.log("trips", JSON.parse(this.tripTypeList));
    }
    // On Select Click Event
    async handleSelect() {
        if (this.selectedMonth != undefined) { // this.stValue != undefined &&
            this.waiting = true;
            try {
                if(this.accId === this.plAccount){
                    let deleteResult = await deleteTrips({
                        accountId: this.accId,
                        month: this.selectedMonth
                    });
                    console.log("M1", deleteResult);
                    if (deleteResult) {
                        let massResult = await MassSyncTrips({
                            accountId: this.accId,
                            startDate: this.syStDate,
                            endDate: this.syEnDate,
                            month: this.selectedMonth,
                            tripStatus: 'U',
                            activityStatus: 'Business'
                        });
                        console.log("M2", massResult);
                        if (massResult) {
                            let finalMassResult = await MassSyncTrips({
                                accountId: this.accId,
                                startDate: this.syStDate,
                                endDate: this.syEnDate,
                                month: this.selectedMonth,
                                tripStatus: 'S',
                                activityStatus: 'Business'
                            });
                            console.log("Mass Result", finalMassResult);
                            if(finalMassResult){
                                let massResult2 = await MassSyncTrips({
                                    accountId: this.accId,
                                    startDate: this.syStDate,
                                    endDate: this.syEnDate,
                                    month: this.selectedMonth,
                                    tripStatus: 'U',
                                    activityStatus: 'Commute'
                                });
                                if (massResult2) {
                                    let finalMassResult2 = await MassSyncTrips({
                                        accountId: this.accId,
                                        startDate: this.syStDate,
                                        endDate: this.syEnDate,
                                        month: this.selectedMonth,
                                        tripStatus: 'S',
                                        activityStatus: 'Commute'
                                    });
                                    if(finalMassResult2){
                                        const resultEvent = new CustomEvent("handlesyncevent", {
                                            detail: finalMassResult2
                                        });
                                        this.dispatchEvent(resultEvent);
                                        setTimeout(() => {
                                            this.waiting = false;
                                            this.handleCancel();
                                        }, 4000);
                                    }
                                }
                            }
                        }
                    }
                }else{
                    let deleteResult = await deleteTrips({
                        accountId: this.accId,
                        month: this.selectedMonth
                    });
                    console.log("M1", deleteResult);
                    if (deleteResult) {
                        let massResult = await MassSyncTrips({
                            accountId: this.accId,
                            startDate: this.syStDate,
                            endDate: this.syEnDate,
                            month: this.selectedMonth,
                            tripStatus: 'U',
                            activityStatus: 'Business'
                        });
                        console.log("M2", massResult);
                        if (massResult) {
                            let finalMassResult = await MassSyncTrips({
                                accountId: this.accId,
                                startDate: this.syStDate,
                                endDate: this.syEnDate,
                                month: this.selectedMonth,
                                tripStatus: 'S',
                                activityStatus: 'Business'
                            });
                            console.log("Mass Result", finalMassResult);
                            if(finalMassResult){
                                const resultEvent = new CustomEvent("handlesyncevent", {
                                    detail: finalMassResult
                                });
                                this.dispatchEvent(resultEvent);
                                setTimeout(() => {
                                    this.waiting = false;
                                    this.handleCancel();
                                }, 4000);
                            }
                        }
                    }
                }
               
            } catch (error) {
                console.log(error);
            }
        }

    }

}