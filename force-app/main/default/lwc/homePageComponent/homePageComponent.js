import {
    LightningElement,
    track,
    api,
    wire
} from 'lwc';
import getMilegesData from '@salesforce/apex/GetDriverData.getMilegesData';
import getMilegesDataSize from '@salesforce/apex/GetDriverData.getMilegesDataSize';
import getInsuranceStatus from '@salesforce/apex/GetDriverData.getInsuranceStatus';
export default class HomePageComponent extends LightningElement {
    ready = false;
    rowLimit;
    @api vfurl;
    @track dataSize;
    @track driverId;
    @api accountId;
    @api adminId;
    @api Id;
    @api showTeam;
    @api ProfileId;
    @api loginId;
    @api managerid;
    @api plMarketing;
    @api admindriver
    @track dashboardurl;
    @track isAlertEnabled = false;
    @track alertMessage;
    @track mileageurl;
    @track driverurl;
    @track reporturl;
    @track notificationUrl;
    @track myDetailurl;
    @track myDetailInsuranceurl;
    @api searchList = [];
    @track drivername;
    @track loadingSpinner = false;
    @track isSelectedChecked = false;
    @track optionSelected = false;
    @track isActive = false;
    isRisk = false;
    @track fromlocation;
    @track tolocation;
    @track field;
    @track idfield;
    @track object;
    @track getstartDate;
    @track getendDate;
    @track startMileage;
    @track endMileage;
    @track trip_status;
    @track track_method;
    @track activity;
    @track tags;
    @track notes = '';
    @track key;
    @track searchkeyvalue;
    @track wherefieldvalue;
    @track accfield;
    @track emailaddressvalue;
    @track approveRejectData;
    @track modalHeader;
    @track modalContent;
    @api filterStartDate;
    @api filterEndDate;
    @api idOfDriver;
    @api StartDate;
    @api EndDate;
    @api OriginName;
    @api DestinationName;
    @api ActiveDriver;
    @api StartMileage;
    @api EndMileage;
    @api TripStatus;
    @api TrackingMethod;
    @api Tag;
    @api Notes;
    @api Activity;
    typeOfTripList = '';
    drivermanagerLoggedIn = false;
    adminLoggedIn = false;
    admindriverLoggedIn = false;
    showSync = false;
    showTripChange = false;
    showUrl = false;
    managerLoggedIn = false;
    unapproveCheck = false;
    isSyncType = true;
    isInsurance = false;
    // mileageRecordSize(accId, drId, StDate, EnDate, OrName,
    //     DestName, ActDriver,
    //     StMileage,
    //     EnMileage,
    //     TStatus,
    //     TrackMethod,
    //     tags) {
    //     getMilegesDataSize({
    //         accountId: accId,
    //         idOfDriver: drId, 
    //         StartDate: StDate, 
    //         EndDate: EnDate, 
    //         OriginName: OrName,
    //         DestinationName: DestName,
    //         ActiveDriver: ActDriver,
    //         StartMileage: StMileage,
    //         EndMileage: EnMileage,
    //         TripStatus: TStatus,
    //         TrackingMethod: TrackMethod,
    //         Tag: tags
    //         })
    //         .then((data) => {
    //             console.log("from mileageRecordSize",data);
    //             this.dataSize = parseInt(data);
    //         })
    //         .catch((error) => {
    //             console.log(error);
    //         });
    // }
    // Get fields for ValidateDataList component
    handleClickEvent(event) {
        // eslint-disable-next-line no-console
        this.driverId = event.detail;
        //this.driverId = (this.driverId === 'All Drivers') ? null : this.driverId;
        this.idfield = 'Id';
        this.field = 'Trip_Origin__c';
        this.object = 'Employee_Mileage__c';
        this.searchkeyvalue = 'Trip_Origin__c';
        this.key = 'Destination_Name__c';
        this.wherefieldvalue = 'EmployeeReimbursement__r.Contact_Id__c';
        this.accfield = 'EmployeeReimbursement__r.Contact_Id__r.AccountId';

    }
    // To clear component data
    handleClearEvent(event) {
        event.preventDefault();
        this.template.querySelector('.driverList').clearAll();
        this.template.querySelector('.fromLocationList').clearAll();
        this.template.querySelector('.toLocationList').clearAll();
        this.template.querySelector('.tagList').clearAll();
        this.template.querySelector('.statusList').clearAll();
        this.template.querySelector('.tracingList').clearAll();
				this.template.querySelector('.activityList').clearAll();
        this.template.querySelector('.lwcstartenddatecomponent').clearAll();
        this.template.querySelector('c-l-w-c-mileages-component').clearAll();
        this.driverId = undefined;
        this.getstartDate = undefined;
        this.getendDate = undefined;
        this.fromlocation = undefined;
        this.tolocation = undefined;
        this.startMileage = undefined;
        this.endMileage = undefined;
        this.trip_status = undefined;
        this.track_method = undefined;
        this.tags = undefined;
        this.activity = undefined;
    }
    // Hide show advance search 
    handleButtonClick() {
        this.template.querySelector('.box-container')
            .classList.toggle('slds-hide');
        this.template.querySelector('.nav_bar_wrap')
            .classList.toggle('ml-84');
    }
    // Cancel Button Click Event
    handleCancelEvent() {
        this.template.querySelector('.box-container')
            .classList.add('slds-hide');
        this.template.querySelector('.nav_bar_wrap')
            .classList.add('ml-84');
    }

    // To Get Selected Start Date
    handleStartDateClickEvent(event) {
        this.getstartDate = event.detail;

    }

    // To Get Selected End Date
    handleEndDateClickEvent(event) {
        this.getendDate = event.detail;
    }


    // To Get Selected From Location
    handleFromLocation(event) {
        if (event.detail === 'All Locations') {
            this.fromlocation = null;
        } else {
            this.fromlocation = event.detail;
        }
    }

    // To Get Selected To Location
    handleToLocation(event) {
        if (event.detail === 'All Locations') {
            this.tolocation = null;
        } else {
            this.tolocation = event.detail;
        }
    }

    // To Get Selected Mileage
    handleMileageChangeEvent(event) {
        this.startMileage = event.detail;
    }

    // To Get Selected Mileage
    handleMileageChangeEnd(event) {
        this.endMileage = event.detail;
    }

    // To Get Selected Trip Status
    handleTripStatus(event) {
				console.log(event.detail);
        //this.trip_status = event.detail;
         if (event.detail === 'All Status' || event.detail === "") {
            this.trip_status = null;
         } else {
             this.trip_status = event.detail;
        }
    }

    // To Get Selected Track Method
    handleTrackMethod(event) {
        this.track_method = event.detail;
        // if (event.detail === 'All Tracking Methods') {
        //     this.track_method = null;
        // } else {
        //     this.track_method = event.detail;
        // }

    }

    handleActivity(event){
        this.activity = event.detail;
        // console.log(this.activity);
    }
    // To Get Selected Track Method
    handleTagSelect(event) {
        this.tags = event.detail;
        // if (event.detail === 'All Tags') {
        //     this.tags = null;
        // } else {
        //     this.tags = event.detail;
        // }

    }
    // To Get Active Driver True/false
    handleActiveDriver(event) {
        this.isActive = event.target.checked;
        this.template.querySelector('c-validate-data-list-component').getActiveDriver(this.isActive);
        this.template.querySelector('c-multiple-dropdown-component').getActiveDriver(this.isActive);
    }

    //High risk trips
    handleHighRiskTrip(event){
        this.isRisk = event.target.checked;
    }

    // Get Data based on advance search filter

    async handleSearchEvent(isSend, rowLt, rowSet) {
        try {
            if ((this.driverId != undefined|| this.getstartDate != undefined || this.getendDate != undefined || this.fromlocation != undefined || this.tolocation != undefined ||
                this.tolocation != undefined || this.startMileage != undefined || this.endMileage != undefined || this.trip_status != undefined ||
                this.track_method != undefined || this.tags != undefined || this.activity != undefined) || this.isRisk === true) {
                var rowLimit, rowOffSet = 0;
                if (rowLt != undefined || rowLt != null) {
                    rowLimit = rowLt;
                } else {
                    rowLimit = this.template.querySelector('c-data-table-component').getRowLimit();
                }
                if (rowSet != undefined || rowSet != null) {
                    //console.log("if inside rowset", rowSet)
                    rowOffSet = rowSet;
                }
               // console.log("mileage rowLimit", rowLimit);
               // console.log("mileage rowOffSet", rowOffSet);
                //var getTable = this.template.querySelector('c-data-table-component').getTableElement();
                this.loadingSpinner = true;
                //getTable.style.opacity = "0.15";
                this.searchFlag = true;
                this.StartDate = this.getstartDate;
                this.EndDate = this.getendDate;
                this.OriginName = this.fromlocation;
                this.DestinationName = this.tolocation;
                this.ActiveDriver = this.isActive;
                this.StartMileage = this.startMileage;
                this.EndMileage = this.endMileage;
                this.TripStatus = this.trip_status;
                this.TrackingMethod = this.track_method;
                this.Activity = this.activity;
                this.Tag = this.tags;

                // Get total number of trips on advance search
                //console.log(this.StartMileage, this.EndMileage)
                let mileageSizeResult = await getMilegesDataSize({
                    accountId: this.accountId,
                    AdminId: this.Id,
                    idOfDriver: this.driverId,
                    StartDate: this.StartDate,
                    EndDate: this.EndDate,
                    OriginName: this.OriginName,
                    DestinationName: this.DestinationName,
                    ActiveDriver: this.ActiveDriver,
                    StartMileage: this.StartMileage,
                    EndMileage: this.EndMileage,
                    TripStatus: this.TripStatus,
                    TrackingMethod: this.TrackingMethod,
                    Tag: this.tags,
                    Notes: null,
                    Activity: this.Activity,
                    highrisk: this.isRisk
                });
                if (mileageSizeResult != undefined) {
                    this.dataSize = parseInt(mileageSizeResult);
                    let mileageList = await getMilegesData({
                        accountId: this.accountId,
                        AdminId: this.Id,
                        idOfDriver: this.driverId,
                        StartDate: this.StartDate,
                        EndDate: this.EndDate,
                        OriginName: this.OriginName,
                        DestinationName: this.DestinationName,
                        ActiveDriver: this.ActiveDriver,
                        StartMileage: this.StartMileage,
                        EndMileage: this.EndMileage,
                        TripStatus: this.TripStatus,
                        TrackingMethod: this.TrackingMethod,
                        Tag: this.tags,
                        Notes: null,
                        Activity: this.Activity,
                        limitSize: rowLimit,
                        offset: rowOffSet,
                        highrisk: this.isRisk
                    });
                   this.loadingSpinner = false;
                   console.log("getMilegesData", mileageList);
                   // getTable.style.opacity = "1";
                    this.searchList = mileageList;
                    this.template.querySelector('c-data-table-component').getSearchData(this.searchList, isSend, this.dataSize, rowLimit);
                  
                }
            } else {
                var alert = this.template.querySelector('c-lwc-alert');
                alert.showAlert = true;
                this.isAlertEnabled = true;
                this.alertMessage = "Select atleast one filter to search.";
                setTimeout(() => {
                    alert.showAlert = false;
                    this.isAlertEnabled = false;
                }, 5000);
            }

        } catch (error) {
						this.loadingSpinner = false;
            console.log("Error while advance search ", error);
        }


    }

    // Quick Search Button Click Event
    handleQuickSearchEvent() {
        var i;
        var txtValue;
        var tr = this.template.querySelector('c-data-table-component').getElement();
        let input = this.template.querySelector('.quickSearchInput');
        let filter = input.value.toUpperCase();
        for (i = 0; i < tr.length; i++) {
            txtValue = tr[i].textContent;
            if (txtValue.toUpperCase().indexOf(filter) > -1) {
                tr[i].style.display = "";
            } else {
                tr[i].style.display = "none";
            }
        }
    }


    handleApproveRejectEvent(event) {
        this.approveRejectData = event.detail;

    }
    handleApproveRejectSearchEvent(event) {
        this.approveRejectData = event.detail;
    }

    // Approve Button Clicked 
    handleApproveClick() {
        if (this.approveRejectData === undefined) {
            let alertElement = this.template.querySelector('c-lwc-alert');
            alertElement.showAlert = true;
            this.isAlertEnabled = true;
            this.alertMessage = "Select atleast one trip to approve.";
            setTimeout(() => {
                alertElement.showAlert = false;
                this.isAlertEnabled = false;
            }, 5000);
        } else {
            if (this.approveRejectData.length != 0) {
                this.modalHeader = "Mileage Status";
                this.modalContent = "The mileage approval and flagging process could take several minutes. Would you like to receive an email when the process is complete ?"
                var modalShow = this.template.querySelector('c-modal-popup').ModalClassList();
                var modalbackdrop = this.template.querySelector('c-modal-popup').ModalBackdrop();
                modalShow.classList.remove("slds-hide");
                modalbackdrop.classList.remove("slds-hide");
                this.emailaddressvalue = JSON.stringify(this.approveRejectData);
                this.isSelectedChecked = true;
                this.unapproveCheck = false;
                this.approveRejectData = [];

            } else {
                let alertElement = this.template.querySelector('c-lwc-alert');
                alertElement.showAlert = true;
                this.isAlertEnabled = true;
                this.alertMessage = "Select atleast one trip to approve.";
                setTimeout(() => {
                    alertElement.showAlert = false;
                    this.isAlertEnabled = false;
                }, 5000);
            }
        }


    }

    // Unapprove Button Clicked
    handleUnapproveClick(){
        if (this.approveRejectData === undefined) {
            let alertElement = this.template.querySelector('c-lwc-alert');
            alertElement.showAlert = true;
            this.isAlertEnabled = true;
            this.alertMessage = "Select atleast one trip to unapprove.";
            setTimeout(() => {
                alertElement.showAlert = false;
                this.isAlertEnabled = false;
            }, 5000);
        } else {
            if (this.approveRejectData.length != 0) {
                this.modalHeader = "Unapprove Trips";
                this.modalContent = "Are you sure you want to unapprove the selected trips ?"
                var modalShow = this.template.querySelector('c-modal-popup').ModalClassList();
                var modalbackdrop = this.template.querySelector('c-modal-popup').ModalBackdrop();
                modalShow.classList.remove("slds-hide");
                modalbackdrop.classList.remove("slds-hide");
                this.emailaddressvalue = JSON.stringify(this.approveRejectData);
                this.isSelectedChecked = false;
                this.unapproveCheck = true;
                this.approveRejectData = [];
            } else {
                let alertElement = this.template.querySelector('c-lwc-alert');
                alertElement.showAlert = true;
                this.isAlertEnabled = true;
                this.alertMessage = "Select atleast one trip to unapprove.";
                setTimeout(() => {
                    alertElement.showAlert = false;
                    this.isAlertEnabled = false;
                }, 5000);
            }
        }
    }
    // Reject Button Clicked 
    handleRejectClick() {
        if (this.approveRejectData === undefined) {
            let alertElement = this.template.querySelector('c-lwc-alert');
            alertElement.showAlert = true;
            this.isAlertEnabled = true;
            this.alertMessage = "Select atleast one trip to reject.";
            setTimeout(() => {
                alertElement.showAlert = false;
                this.isAlertEnabled = false;
            }, 5000);
        } else {
            if (this.approveRejectData.length != 0) {
                this.modalHeader = "Mileage Status";
                this.modalContent = "The mileage approval and flagging process could take several minutes. Would you like to receive an email when the process is complete ?"
                var modalShow = this.template.querySelector('c-modal-popup').ModalClassList();
                var modalbackdrop = this.template.querySelector('c-modal-popup').ModalBackdrop();
                modalShow.classList.remove("slds-hide");
                modalbackdrop.classList.remove("slds-hide");
                this.emailaddressvalue = JSON.stringify(this.approveRejectData);
                this.isSelectedChecked = false;
                this.unapproveCheck = false;
                this.approveRejectData = [];
            } else {
                let alertElement = this.template.querySelector('c-lwc-alert');
                alertElement.showAlert = true;
                this.isAlertEnabled = true;
                this.alertMessage = "Select atleast one trip to reject.";
                setTimeout(() => {
                    alertElement.showAlert = false;
                    this.isAlertEnabled = false;
                }, 5000);
            }
        }
    }

    handleDeleteTrips() {
        if (this.approveRejectData === undefined) {
            let alertElement = this.template.querySelector('c-lwc-alert');
            alertElement.showAlert = true;
            this.isAlertEnabled = true;
            this.alertMessage = "Select atleast one trip to delete.";
            setTimeout(() => {
                alertElement.showAlert = false;
                this.isAlertEnabled = false;
            }, 5000);
        } else {
            if (this.approveRejectData.length != 0) {
                this.modalHeader = "Delete Trip Status";
                this.modalContent = "Are you sure you want to delete selected trips ?"
                var modalShow = this.template.querySelector('c-modal-popup').ModalClassList();
                var modalbackdrop = this.template.querySelector('c-modal-popup').ModalBackdrop();
                modalShow.classList.remove("slds-hide");
                modalbackdrop.classList.remove("slds-hide");
                this.emailaddressvalue = JSON.stringify(this.approveRejectData);
                this.isSelectedChecked = null;
                this.approveRejectData = [];
            } else {
                let alertElement = this.template.querySelector('c-lwc-alert');
                alertElement.showAlert = true;
                this.isAlertEnabled = true;
                setTimeout(() => {
                    alertElement.showAlert = false;
                    this.isAlertEnabled = false;
                }, 5000);
                this.alertMessage = "Select atleast one trip to delete.";
            }
        }
    }

    // Event fired when approve, reject or unapprove modal is closed
    handleResetEvent(event){
        if(event.detail){
            this.template.querySelector('c-data-table-component').resetSelected();
        }
    }
    // approve reject email handler
    handleSendEmailEvent(event) {
        var isSend = 'email send';
        if (event.detail === 'success') {
            if (this.searchFlag === true) {
                this.handleSearchEvent(isSend);
            } else {
                this.template.querySelector('c-data-table-component').apexMethodCall(isSend);
            }
        }
    }

    handleDeleteTripEvent(event) {
        var isDelete = 'trip deleted';
        if (event.detail === 'deleted') {
            if (this.searchFlag === true) {
                this.handleSearchEvent(isDelete);
            } else {
                this.template.querySelector('c-data-table-component').apexMethodCall(isDelete);
            }
        }
    }

    // success message event
    handleSuccessEvent() {
        var label;
        if (this.isSelectedChecked === false && this.unapproveCheck === false) {
            label = "Trip\'s rejected successfully!";
        } else if (this.isSelectedChecked === true && this.unapproveCheck === false) {
            label = "Trip\'s approved successfully!"
        } else if (this.isSelectedChecked === false && this.unapproveCheck === true){
            label = "Your selected trips have been successfully unapproved!"
        }
        setTimeout(() => {
            this.template.querySelector('c-toast').showToast(
                'Cheers!',
                 label,
                'success',
                true);
        }, 4000)

    }

    handleDeleteSuccessEvent() {
        setTimeout(() => {
            this.template.querySelector('c-toast').showToast(
                'Cheers!',
                'Trip\'s deleted successfully!',
                'success',
                true);
        }, 4000)
    }

    handleDefaultSuccessEvent() {
        var eventLabel;
        if (this.isSelectedChecked === false && this.unapproveCheck === false) {
            eventLabel = "Trip\'s rejected successfully!";
        } else if (this.isSelectedChecked === true && this.unapproveCheck === false) {
            eventLabel = "Trip\'s approved successfully!"
        } else if (this.isSelectedChecked === false && this.unapproveCheck === true){
            eventLabel = "Your selected trips have been successfully unapproved!"
        }
        setTimeout(() => {
            this.template.querySelector('c-toast').showToast(
                'Cheers!',
                eventLabel,
                'success',
                true);
        }, 3000)
    }

    handleUpdateEvent(event) {
        if (event.detail) {
            setTimeout(() => {
                this.template.querySelector('c-toast').showToast(
                    'Cheers!',
                    'Trip\'s updated successfully!',
                    'success',
                    true);
            }, 1000)
        }
    }

    handleDeleteEvent() {
        setTimeout(() => {
            this.template.querySelector('c-toast').showToast(
                'Cheers!',
                'Trip\'s deleted successfully!',
                'success',
                true);
        }, 4000)
    }

    handleChangeActivity(){
        this.template.querySelector('c-data-table-component').changeActivity();
    }

    handleTripModal(event){
        if(event.detail){
            this.isSyncType = false;
            var showTripModal = this.template.querySelector('c-sync-modal').modalClassName();
            var tripModalBackdrop = this.template.querySelector('c-sync-modal').modalBackdropClass();
            showTripModal.classList.remove("slds-hide");
            tripModalBackdrop.classList.remove("slds-hide");
            this.typeOfTripList = event.detail;
        }
    }
    handleSearchActivity(event){
        if(event.detail){
            let alertForExcel = this.template.querySelector('c-lwc-alert');
            alertForExcel.showAlert = true;
            this.isAlertEnabled = true;
            this.alertMessage = "Select atleast one trip to change activity.";
            setTimeout(() => {
                alertForExcel.showAlert = false;
                this.isAlertEnabled = false;
            }, 5000);
        }
    }

    handleDefaultActivity(event){
        if(event.detail){
            let alertForExcel = this.template.querySelector('c-lwc-alert');
            alertForExcel.showAlert = true;
            this.isAlertEnabled = true;
            this.alertMessage = "Select atleast one trip to change activity.";
            setTimeout(() => {
                alertForExcel.showAlert = false;
                this.isAlertEnabled = false;
            }, 5000);
        }
    }

    handleExportExcelEvent(event) {
        if (event.detail) {
            setTimeout(() => {
                this.template.querySelector('c-toast').showToast(
                    'Opps!',
                    'There are no trip\'s found in this date range!',
                    'error',
                    true);
            }, 1000)
        }
    }

    handleCountExcel(event){
        if(event.detail){
            let alertForExcel = this.template.querySelector('c-lwc-alert');
            alertForExcel.showAlert = true;
            this.isAlertEnabled = true;
            this.alertMessage = "Select atleast one trip to export.";
            setTimeout(() => {
                alertForExcel.showAlert = false;
                this.isAlertEnabled = false;
            }, 5000);
        }
    }

    handleSearchCountExcel(event){
        if(event.detail){
            let alertForExcel = this.template.querySelector('c-lwc-alert');
            alertForExcel.showAlert = true;
            this.isAlertEnabled = true;
            this.alertMessage = "Select atleast one trip to export.";
            setTimeout(() => {
                alertForExcel.showAlert = false;
                this.isAlertEnabled = false;
            }, 5000);
        }
    }
    perPageActionEvent(event) {
       // console.log(event.detail);
        if (event.detail) {
            this.handleSearchEvent('', event.detail.rowLimit, event.detail.rowOffSet);
        }
    }
    rowActionEvent(event) {
       // console.log("from home page row action", event.detail.rowOffSet);
        if (event.detail) {
            this.handleSearchEvent('', event.detail.rowLimit, event.detail.rowOffSet);
        }
    }
    // Get Excel For Selected Trips
    exportSelectedTrips() {
        this.template.querySelector('c-data-table-component').exportSelectedTrip();
    }
    // Get Excel For Trips By Date
    exportTripsByDate() {
        this.template.querySelector('c-data-table-component').showFilterModal();
    }

    // Sync All Event 
    handleSyncEvent(event){
        if(event.detail === 'Success'){
            setTimeout(() => {
                this.template.querySelector('c-toast').showToast(
                    'Cheers!',
                    'Please wait for few minutes. mileage sync process is running in background!',
                    'success',
                    true);
            }, 6000);
            setTimeout(() => {
                location.reload();
            }, 8000);
        }
      
    }

    // Change Trip Type Event 
    handleMassChangeTripType(event) {
        if(event.detail){
            setTimeout(() => {
                this.template.querySelector('c-toast').showToast(
                    'Cheers!',
                    'Please wait for few minutes. Mileage activity update process is running in background!',
                    'success',
                    true);
            }, 6000);
            setTimeout(() => {
                location.reload();
            }, 8000);
        }
    }
    connectedCallback() {
        this.ready = true;
        getInsuranceStatus({
            conId: this.Id,
        })
        .then((data) => {
            this.isInsurance = data;
            console.log("from insurance", data);
        })
        .catch((error) => {
            console.log(error);
        });
        if(this.accountId === this.plMarketing){
            this.showSync = (this.ProfileId === '00e31000001FRDYAA4' ||this.ProfileId === '00e31000001FRDZAA4') ? true : false;
            //this.showSync = false;
            this.showUrl = true;
            this.showTripChange = true;
        }else{
            this.showSync = true;
            this.showTripChange = false;
            this.showUrl = false;
        }
        if (this.ProfileId === '00e31000001FRDYAA4') {
            if(this.loginId != null) {
                this.drivermanagerLoggedIn = true;
                this.admindriverLoggedIn = false;
                this.adminLoggedIn = false;
                this.dashboardurl = "/app/drivermanagerdriverdetails?accid=" + this.accountId + "&id=" + this.Id + "&manid="+ this.managerid + "&showteam=" + this.showTeam + "&loginAS=true";
                this.mileageurl = "/app/MileageDashboard?accid=" + this.accountId + "&id=" + this.Id + "&manid="+ this.managerid + "&showteam=" + this.showTeam + "&loginAS=true";
                this.notificationUrl = "/app/ManageNotification?accid=" + this.accountId + "&id=" + this.Id + "&managerid="+ this.managerid + "&showteam=" + this.showTeam + "&loginAS=true";
                this.myDetailurl = "/app/driveradminmanagermydetail?accid=" + this.accountId + "&id=" + this.Id + "&manid="+ this.managerid + "&showteam=" + this.showTeam + "&loginAS=true";
            }else{
                this.drivermanagerLoggedIn = false;
                this.adminLoggedIn = true;
                this.admindriverLoggedIn = false;
                this.dashboardurl = "/app/admindashboard?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
                this.mileageurl = "/app/MileageDashboard?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
                this.driverurl = "/app/roster?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
                this.notificationUrl = "/app/ManageNotification?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
                this.reporturl = "/app/reportlist?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
            }
        } else if (this.ProfileId === '00e31000001FRDWAA4') {
            this.drivermanagerLoggedIn = false;
            this.admindriverLoggedIn = false;
            this.adminLoggedIn = false;
            this.managerLoggedIn = true;
            this.dashboardurl = "/app/managerdashboard?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
            this.mileageurl = "/app/MileageDashboard?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
            this.notificationUrl = "/app/ManageNotification?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
            this.driverurl = "/app/roster?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
            this.reporturl = "/app/reportlist?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
        } else if (this.ProfileId === '00e31000001FRDXAA4') {
            this.drivermanagerLoggedIn = true;
            this.admindriverLoggedIn = false;
            this.adminLoggedIn = false;
            this.dashboardurl = "/app/drivermanagerdashboard?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
            this.mileageurl = "/app/MileageDashboard?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
            this.driverurl = "/app/roster?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
            this.reporturl = "/app/reportlist?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
            this.notificationUrl = "/app/ManageNotification?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
            this.myDetailurl = "/app/driveradminmanagermydetail?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
            this.myDetailInsuranceurl = "/app/uploadInsurance?accid="+ this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam;
        } else if (this.ProfileId === '00e31000001FRDZAA4') {
            if(this.loginId != null) {
                this.drivermanagerLoggedIn = true;
                this.admindriverLoggedIn = false;
                this.adminLoggedIn = false;
                this.dashboardurl = "/app/drivermanagerdriverdetails?accid=" + this.accountId + "&id=" + this.Id + "&manid="+ this.managerid + "&showteam=" + this.showTeam + "&loginAS=true";
                this.mileageurl = "/app/MileageDashboard?accid=" + this.accountId + "&id=" + this.Id + "&manid="+ this.managerid + "&showteam=" + this.showTeam + "&loginAS=true";
                this.notificationUrl = "/app/ManageNotification?accid=" + this.accountId + "&id=" + this.Id + "&managerid="+ this.managerid + "&showteam=" + this.showTeam + "&loginAS=true";
                this.myDetailurl = "/app/driveradminmanagermydetail?accid=" + this.accountId + "&id=" + this.Id + "&manid="+ this.managerid + "&showteam=" + this.showTeam + "&loginAS=true";
                this.myDetailInsuranceurl = "/app/uploadInsurance?accid="+ this.accountId + "&id=" + this.Id + "&managerid="+ this.managerid + "&showteam=" + this.showTeam  + "&loginAS=true";
            }else{
                this.admindriverLoggedIn = true;
                this.drivermanagerLoggedIn = false;
                this.adminLoggedIn = false;
                this.dashboardurl = "/app/admindriverdashboard?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam + "&admindriver=" + this.admindriver
                this.mileageurl = "/app/MileageDashboard?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam + "&admindriver=" + this.admindriver;
                this.driverurl = "/app/roster?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam + "&admindriver=" + this.admindriver;
                this.notificationUrl = "/app/ManageNotification?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam + "&admindriver=" + this.admindriver;
                this.reporturl = "/app/reportlist?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam + "&admindriver=" + this.admindriver;
                this.myDetailurl = "/app/driveradminmanagermydetail?accid=" + this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam + "&admindriver=" + this.admindriver;
                this.myDetailInsuranceurl = "/app/uploadInsurance?accid="+ this.accountId + "&id=" + this.Id + "&showteam=" + this.showTeam + "&admindriver=" + this.admindriver;
            }
        }
    }

    handleSyncAll(){
        this.isSyncType = true;
        var showSyncModal = this.template.querySelector('c-sync-modal').modalClassName();
        var syncModalBackdrop = this.template.querySelector('c-sync-modal').modalBackdropClass();
        showSyncModal.classList.remove("slds-hide");
        syncModalBackdrop.classList.remove("slds-hide");
        this.typeOfTripList = '';
    }
    renderedCallback() {
        if (!this.ready) {
            this.ready = true;
        }

    }

}