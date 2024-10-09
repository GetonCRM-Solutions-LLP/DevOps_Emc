/* eslint-disable radix */
/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable guard-for-in */
import {
    LightningElement,
    api, wire, track
} from 'lwc';
import logo from '@salesforce/resourceUrl/EmcCSS';
import redirectionURL from '@salesforce/apex/NewAccountDriverController.loginRedirection';
import getAllReimbursements from "@salesforce/apex/DriverDashboardLWCController.getAllReimbursements";
import getDriverDetails from '@salesforce/apex/DriverDashboardLWCController.getDriverDetailsClone';
import getCompanyLogoUrl from '@salesforce/apex/DriverDashboardLWCController.getCompanyLogoUrl';
import getNotificationMessageList from '@salesforce/apex/ManagerDashboardController.getNotificationMessageList';
import updateNotificationMessage from '@salesforce/apex/ManagerDashboardController.updateNotificationMessage';
import updateContactDetail from '@salesforce/apex/DriverDashboardLWCController.updateContactDetail';
import sendMlogWelcomeEmail from '@salesforce/apex/ResourceController.sendMlogWelcomeEmail';
import ManualEntry from '@salesforce/label/c.Manual_Entry';
import {validateDate} from 'c/commonLib';
export default class DriverDashboardFrame extends LightningElement {
    @track notifyList;
    @track userNotification;
    @track updateNotifyList;
    @track notificationList;
    @api chartData;
    @api profile;
    @api roleId;
    @api customSetting;
    @api driverMeeting;
    @api last2Year;
    @api systemNotification;
    @api activationDate;
    @api updatedDate;
    @api loginCount;
    mapCountry;
    section = 'main';
    // width of video
    videoWidth = "100%";

    // height of video
    videoHeight = "332px";
    unreadCount;
    insuranceVideo;
    navFeatureLink;
    contentCss;
    videoCss;
    contactInformation;
    isTripType = 'MyTrip';
    ytdList;
    excelYtdList;
    @track isTrip = true;
    @track isAttendance = false;
    notificationViewClicked = false;
    managerRole = false;
    isNewSyncFeature = false;
    navFeature = false;
    toggle = false;
    checkAll = false;
    isArchive = false;
    notificationModal = false;
    isFalse = false;
    archive = true;
    isGeneral = true;
    isNewFeature = false;
    dateOfExpiration = '';
    defaultYear = '';
    defaultMonth = '';
    contentMessage = '';
    monthMilesLast = '';
    monthMilesThis = '';
    subMessage = '';
    myProfile = true;
    menu = true;
    reimbursementView = false;
    manualEntryView = false;
    reimbursementArchive = false;
    viewNotification = false;
    headerModalText = '';
    modalClass = '';
	headerClass = '';
	subheaderClass = '';
	modalContent = '';
	styleHeader = '';
	styleClosebtn = '';
    insuranceView = false;
    resources = false;
    locationUploadView = false;
    complianceView = false;
    liabilityView = false;
    tripView = false;
    biweek = false;
    monthOfTrip;
    yearOfTrip;
    startDt;
    endDt;
    biweekId;
    userName;
    firstName;
    userEmail;
    userTriplogId;
    companyLogoUrl;
    @track isNotify = false;
    @track isUnNotify = false;
    unreadCount;
    adminCount;
    autoCount;
    @track unnotifyList;
    @track unnotificationList;
    @track isHomePage = false;
    _contactId;
    _accountId;
    isManualEntryUser;
    originalProfileMenu = [];
    @track driverProfileMenu = [{
        "id": 1,
        "label": "Mileage",
        "menuItem": [{
            "menuId": 101,
            "menu": "Mileage",
            "menuLabel" : "Plan Info / Mileage",
            "menuClass": "tooltipText",
            "logo": logo + '/emc-design/assets/images/Icons/SVG/Green/Mileage.svg#mileage',
            "logoHov": logo + '/emc-design/assets/images/Icons/SVG/White/Mileage.svg#mileage'
        }, {
            "menuId": 102,
            "menu": "Archive",
            "menuLabel" : "Archive",
            "menuClass": "tooltipText",
            "logo": logo + '/emc-design/assets/images/Icons/SVG/Green/Archive.svg#archive',
            "logoHov": logo + '/emc-design/assets/images/Icons/SVG/White/Archive.svg#archive'
          }
    ]
    },
     {
        "id": 2,
        "label": "Plan management",
        "menuItem": [{
            "menuId": 201,
            "menu": "Insurance-Upload",
            "menuLabel" : "Insurance Upload",
            "menuClass": "tooltipText",
            "logo": logo + '/emc-design/assets/images/Icons/SVG/Green/Insurance_Upload.svg#insurance',
            "logoHov": logo + '/emc-design/assets/images/Icons/SVG/White/Insurance_Upload.svg#insurance'
        }, {
            "menuId": 202,
            "menu": "Locations",
            "menuLabel" : "Locations",
            "menuClass": "tooltipText",
            "logo": logo + '/emc-design/assets/images/Icons/SVG/Green/Locations.svg#location',
            "logoHov": logo + '/emc-design/assets/images/Icons/SVG/White/Locations.svg#location'
        }, {
            "menuId": 203,
            "menu": "Compliance",
            "menuLabel" : "Compliance",
            "menuClass": "tooltipText",
            "logo": logo + '/emc-design/assets/images/Icons/SVG/Green/Compliance.svg#compliance',
            "logoHov": logo + '/emc-design/assets/images/Icons/SVG/White/Compliance.svg#compliance'
        }]
    }, {
        "id": 3,
        "label": "Help & info",
        "menuItem": [{
            "menuId": 301,
            "menu": "Videos",
            "menuLabel" : "Videos/Training",
            "menuClass": "tooltipText",
            "logo": logo + '/emc-design/assets/images/Icons/SVG/Green/Driver_Videos_Training.svg#videos',
            "logoHov": logo + '/emc-design/assets/images/Icons/SVG/White/Driver_Videos_Training.svg#videos'
        }]
    }]

    yearList = [];
    
    listOfMonth = [
        {
          id: 1,
          label: "January",
          value: "January"
        },
        {
          id: 2,
          label: "February",
          value: "February"
        },
        {
          id: 3,
          label: "March",
          value: "March"
        },
        {
          id: 4,
          label: "April",
          value: "April"
        },
        {
          id: 5,
          label: "May",
          value: "May"
        },
        {
          id: 6,
          label: "June",
          value: "June"
        },
        {
          id: 7,
          label: "July",
          value: "July"
        },
        {
          id: 8,
          label: "August",
          value: "August"
        },
        {
          id: 9,
          label: "September",
          value: "September"
        },
        {
          id: 10,
          label: "October",
          value: "October"
        },
        {
          id: 11,
          label: "November",
          value: "November"
        },
        {
          id: 12,
          label: "December",
          value: "December"
        }
    ]
    
    monthList  = []

    @wire(getCompanyLogoUrl, {
        accountId: '$_accountId'
    }) getCompanyLogo({ data, error }) {
        if (data) {
            this.companyLogoUrl = (data !== '' || data !== undefined || data !== null) ? JSON.parse(data) : data;
        } else if (error) {
            console.log("loggo", error);
        }
    }

    // renderedCallback(){
    //     const url = new URL(document.location);
    //     // let address = params.get('#'); // is the string "Jonathan Smith".
    //     setTimeout(function (){
    //      console.log('Main---->', url.hash)
    //     }, 2000)
    // }
     
    proxyToObject(e) {
        return JSON.parse(e)
    }

    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }

    handleOutsideClick = (event) => {
       // console.log("OUtside", event, this.notificationViewClicked)
        if(!this.notificationViewClicked){
            this.closeNotification();
        }   
    }

    buttonToggle(event){
        var name = (event) ? event.currentTarget.dataset.name : 'admin' ;
        this.isGeneral = (name === 'admin') ? true : false;
    }

    handleToggle(event){
          this.buttonToggle(event);
          //this.getContactNotification();
          let notification = this.updateNotifyList;
          this.unnotifyList = notification.filter(e=> e.unread === true);
          this.unnotificationList = this.unnotifyList.slice(0, 1);
          this.unreadCount = this.unnotifyList.length;
          this.isUnNotify = (this.unnotifyList.length > 0) ? true : false;
          this.notifyList = (this.isGeneral) ? notification.filter(e => e.createdBy != 'Tom Honkus') : notification.filter(e => e.createdBy === 'Tom Honkus')
          this.adminCount = (notification.filter(e => e.createdBy != 'Tom Honkus' && e.unread === true)).length;
          this.autoCount = (notification.filter(e => e.createdBy === 'Tom Honkus' && e.unread === true)).length;
          this.isNotify = (this.notifyList.length > 0) ? true : false;
    }

    handleKeyDown = (event) =>{
        if (event.keyCode === 27) {
           // console.log('Esc key pressed.');
            if(!this.notificationViewClicked){
              this.closeNotification();
            }  
        }
     // console.log("keyboard###", event, this.notificationViewClicked)
    }

    handleLiveNotification = (event) => {
        event.stopPropagation();
    }

    /*Existing Notification Logic */
    driverNotification(message, date, insuranceDt) {
        //  if (this.isInformation) {
        var notification = [], currentDate, deadline, mileageMsg, pastDate, fourthOfMonth, monthName, insuranceMsg, insuranceMsg1, dateOpt;
        currentDate = new Date(); /** "2021-07-31" */
        deadline = 5;
        /** Custom Notification **/
        if (message != null) {
            notification.push({
                value: message,
                dt: date
            }
            );
        }
        /** Driver Notification - 5 days before the mileage Monthly and bi-weekly notifications for upcoming mileage sync  **/

        fourthOfMonth = new Date(currentDate.getFullYear(), currentDate.getMonth(), 4);
        if (currentDate > fourthOfMonth) {
            fourthOfMonth = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 4);
            pastDate = new Date(fourthOfMonth);
            pastDate.setDate(pastDate.getDate() - deadline);
            monthName = fourthOfMonth.toLocaleString('default', {
                month: 'long'
            });
        } else {
            pastDate = new Date(fourthOfMonth);
            pastDate.setDate(pastDate.getDate() - deadline);
            monthName = currentDate.toLocaleString('default', {
                month: 'long'
            });
            // console.log(pastDate, fourthOfMonth);
        }

        if (currentDate >= pastDate && currentDate < fourthOfMonth) {
            mileageMsg = "Mileage will be automatically synced " + monthName + " 3 at 11:59 PM PST.";
            notification.push({
                value: mileageMsg,
                dt: new Date()
            });
        }

        /** Driver Notification - Insurance deadline 5 days before the insurance request dates (Jan 1 and June 30) to support the email that is sent to drivers.  **/

        dateOpt = {
            year: "numeric",
            month: "2-digit",
            day: "2-digit"
        };
        let cDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate()).toLocaleDateString('fr-CA', dateOpt);
        let firstMonth = new Date(currentDate.getFullYear(), 0, 1);
        let sixthMonth = new Date(currentDate.getFullYear(), 6, 0);
        let first = new Date(firstMonth.getFullYear(), 0, 1).toLocaleDateString('fr-CA', dateOpt);
        if (cDate > first) {
            firstMonth = new Date(currentDate.getFullYear() + 1, 0, 1);
        }
        let insurancePastDate = new Date(firstMonth);
        insurancePastDate.setDate(insurancePastDate.getDate() - deadline);
        let insuranceEndDate = new Date(sixthMonth);
        insuranceEndDate.setDate(insuranceEndDate.getDate() - deadline);
        if (currentDate >= insurancePastDate && currentDate < firstMonth) {
            insuranceMsg = "Happy Holidays – Don’t forget to upload your insurance dec page next week.";
            notification.push({
                value: insuranceMsg,
                dt: new Date()
            });
        }
        if (currentDate >= insuranceEndDate && currentDate < sixthMonth) {
            insuranceMsg1 = "You have to upload your most recent insurance declaration page(s) in 5 days.";
            notification.push({
                value: insuranceMsg1,
                dt: new Date()
            });
        }

        /** Driver Notification - 35 days after the first request for insurance (January 31 and July 31) to support a new email that will be sent to all drivers that have not uploaded their insurance.  **/
        let emailMsg;
        let lastDayOfSeventh = new Date(currentDate.getFullYear(), 7, 0).toLocaleDateString('fr-CA', dateOpt);;
        let lastDay = new Date(currentDate.getFullYear(), 1, 0).toLocaleDateString('fr-CA', dateOpt);;
        if (cDate === lastDayOfSeventh || cDate === lastDay) {
            emailMsg = "In 5 days, you could forfeit your fixed amount unless you upload your insurance declaration page(s).";
            notification.push({
                value: emailMsg,
                dt: new Date()
            });
        }
        // console.log(notification);

        /** Trigger-based notifications */
        let day = currentDate.getDate();
        let approvalMsg;
        let flaggedMsg;
        let pendingMsg;
        let insuranceUpload;
        let pastDay;
        let nameOfMonth;
        let fourth = new Date(currentDate.getFullYear(), currentDate.getMonth(), 4).toLocaleDateString('fr-CA', dateOpt);
        if (cDate >= fourth) {
            pastDay = new Date(currentDate.getFullYear(), currentDate.getMonth() - 1, currentDate.getDate());
            nameOfMonth = pastDay.toLocaleString('default', {
                month: 'long'
            });
        } else {
            pastDay = new Date(currentDate.getFullYear(), currentDate.getMonth() - 2, currentDate.getDate());
            nameOfMonth = pastDay.toLocaleString('default', {
                month: 'long'
            });
        }
        let mileageObject;
        this.mileageList.forEach((m) => {
            if (nameOfMonth === m.month) {
                mileageObject = m;
            }
        })
        // console.log(mileageObject);
        if (mileageObject !== undefined) {
            /** Trigger-based notifications - Display mileage approval (total for the month) – should disappear after the lock date or by the 18th of the month */
            if (mileageObject.totalApprove !== undefined) {
                if (mileageObject.lockdate === null && day < 18) {
                    approvalMsg = "For " + nameOfMonth + " you had " + mileageObject.totalApprove + " approved miles";
                    notification.push({
                        value: approvalMsg,
                        dt: new Date()
                    });
                }
            }

            /** Trigger-based notifications - When mileage is flagged for the month (total for the month) until the 18th of the month or the lock date */
            if (mileageObject.totalRejected !== undefined) {
                if ((mileageObject.lockdate != null)) {
                    flaggedMsg = "For " + nameOfMonth + " you had " + mileageObject.totalRejected + " flagged miles";
                    notification.push({
                        value: emailMsg,
                        dt: new Date()
                    });
                } else {
                    if (day <= 18) {
                        flaggedMsg = "For " + nameOfMonth + " you had " + mileageObject.totalRejected + " flagged miles";
                        notification.push({
                            value: flaggedMsg,
                            dt: new Date()
                        });
                    }
                }
            }


            /** Trigger-based notifications - Display the total of unapproved mileage (mileage that was unapproved after the 18th or the lock date). This number should be displayed until the 3rd of the next month.*/
            if (mileageObject.totalPending !== undefined) {
                if ((mileageObject.lockdate != null)) {
                    pendingMsg = "For " + nameOfMonth + " you had " + mileageObject.totalPending + " miles that were not yet approved";
                    notification.push({
                        value: emailMsg,
                        dt: new Date()
                    });
                } else {
                    if (day >= 18) {
                        pendingMsg = "For " + nameOfMonth + " you had " + mileageObject.totalPending + " miles that were not yet approved";
                        notification.push({
                            value: pendingMsg,
                            dt: new Date()
                        });
                    }
                }
            }


        }

        /** Trigger-based notifications - 4.	Thank you for uploading your insurance – immediately after uploading an insurance */

        let isDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate()).toLocaleDateString('fr-CA');
        let insuranceDate = insuranceDt;
        if (insuranceDate != null) {
            if (isDate === insuranceDate) {
                insuranceUpload = "Thank you for uploading your insurance, our team will evaluate your insurance by the end of the month"
                notification.push({
                    value: insuranceUpload,
                    dt: new Date()
                });
            }
        }

        let messageList = [];
        for (let index = 0; index < notification.length; index++) {
            const element = {}
            element.Id = index;
            element.message = notification[index].value;
            element.date = notification[index].dt;
            messageList.push(element);
        }

        this.notifyList = messageList;
        this.notificationList = this.notifyList.slice(0, 2);
        this.isNotify = (this.notifyList.length > 0) ? true : false;
        // }
    }

    sortByDesc(data, colName, colType) {
        data.sort((a, b) => {
            if (colType === "Date") {
                a = a[colName] ? new Date(a[colName].toLowerCase()) : "";
                b = b[colName] ? new Date(b[colName].toLowerCase()) : "";
                return a > b ? -1 : 1;
            }
            a = a[colName] ? a[colName] : "";
            b = b[colName] ? b[colName] : "";
            return a > b ? -1 : 1;
        });
            return data;
      
    }

    /*New Notification logic - From Apex */

    getContactNotification(){
        var notification = [], result;
        this.unreadCount = 0;
        getNotificationMessageList({
            conId: this._contactId,
            year: parseInt(this.defaultYear),
            month: this.defaultMonth
        }).then((data) => { 
            result = data
            notification = this.proxyToObject(result);
            notification = this.sortByDesc(notification, "modifiedDate", "Date");
            notification = this.sortByDesc(notification, "unread", "Boolean");
            this.userNotification = notification;
            this.updateNotifyList = notification;
            this.notifyList = notification;
            this.notificationList = this.notifyList.slice(0, 1);
            this.unnotifyList = notification.filter(e=> e.unread === true);
            this.unnotificationList = this.unnotifyList.slice(0, 1);
            for (let i = 0; i < this.notifyList.length; i++) {
                if (this.notifyList[i].unread === true) {
                  this.unreadCount++;
                }
            }
            this.notifyList = (this.isGeneral) ? notification.filter(e => e.createdBy != 'Tom Honkus') : notification.filter(e => e.createdBy === 'Tom Honkus')
          //  this.notificationList = notification;
            this.adminCount = (notification.filter(e => e.createdBy != 'Tom Honkus' && e.unread === true)).length;
            this.autoCount = (notification.filter(e => e.createdBy === 'Tom Honkus' && e.unread === true)).length;
            this.isNotify = (this.notifyList.length > 0) ? true : false
            this.isUnNotify = (this.unnotifyList.length > 0) ? true : false;
            this.debounce(() => {   this.dispatchEvent(
                new CustomEvent("show", {
                    detail: "spinner"
                })
                ); }, 0)();
        }).catch(error=>{console.log(error)})
      
    }

    handleNotification(event) {
        // eslint-disable-next-line radix
          var rd = event.detail, notification;
          notification = this.userNotification;
          for (let i = 0; i < notification.length; i++) {
            if (notification[i].id === rd) {
                notification[i].unread = false;
                // this.notifyList.splice(i, 1);
                // if(this.unreadCount > 0){
                //     this.unreadCount = this.unreadCount - 1;
                // }
            }
          }
          notification = this.sortByDesc(notification, "modifiedDate", "Date");
          notification = this.sortByDesc(notification, "unread", "Boolean");
          this.updateNotifyList = notification;
          this.unnotifyList = notification.filter(e=> e.unread === true);
          this.unnotificationList = this.unnotifyList.slice(0, 1);
          this.unreadCount = this.unnotifyList.length;
          this.isUnNotify = (this.unnotifyList.length > 0) ? true : false;
          this.notifyList = (this.isGeneral) ? notification.filter(e => e.createdBy != 'Tom Honkus') : notification.filter(e => e.createdBy === 'Tom Honkus')
          this.adminCount = (notification.filter(e => e.createdBy != 'Tom Honkus' && e.unread === true)).length;
          this.autoCount = (notification.filter(e => e.createdBy === 'Tom Honkus' && e.unread === true)).length;
          this.isNotify = (this.notifyList.length > 0) ? true : false;
          updateNotificationMessage({msgId: rd, year: this.defaultYear, month: this.defaultMonth}).then((data) => {
            let  result = data;
            notification = this.proxyToObject(result);
            // notification = this.sortByDesc(notification, "modifiedDate", "Date");
            // notification = this.sortByDesc(notification, "unread", "Boolean");
           // this.userNotification = notification;
         }).catch((err)=>{console.log(err.message)})
            /*for (let i = 0; i < this.unnotifyList.length; i++) {
              if (this.unnotifyList[i].id === rd) {
                  this.unnotifyList.splice(i, 1);
                  if(this.unreadCount > 0){
                    this.unreadCount = this.unreadCount - 1;
                  }
              }
            }
            this.unnotificationList = this.unnotifyList.slice(0, 1);
            this.isUnNotify = (this.unnotifyList.length > 0) ? true : false;
            this.notificationList = this.notifyList.slice(0, 1);
            updateNotificationMessage({msgId: rd, year: this.defaultYear, month: this.defaultMonth}).then((data) => { 
                let  result = data
                notification = this.proxyToObject(result);
                this.notifyList = notification;
                this.unnotifyList = notification.filter(e=> e.unread === true);
                this.unnotificationList = this.unnotifyList.slice(0, 1);
                this.unreadCount = this.unnotifyList.length;
                this.isUnNotify = (this.unnotifyList.length > 0) ? true : false;
                this.notifyList = (this.isGeneral) ? notification.filter(e => e.createdBy != 'Tom Honkus') : notification.filter(e => e.createdBy === 'Tom Honkus')
                this.adminCount = (notification.filter(e => e.createdBy != 'Tom Honkus' && e.unread === true)).length;
                this.autoCount = (notification.filter(e => e.createdBy === 'Tom Honkus' && e.unread === true)).length;
                this.isNotify = (this.notifyList.length > 0) ? true : false;
                console.log("Notification", result, this.unreadCount)
            }).catch(error=>{console.log(error)})*/
    }

    handleClose(event) {
        // console.log("id", event.target.dataset.id)
        // eslint-disable-next-line radix
        var eId = event.currentTarget.dataset.id, notification;
        notification = this.userNotification;
      //  this.unreadCount = 0
       for (let i = 0; i < notification.length; i++) {
            if (notification[i].id === eId) {
                notification[i].unread = false;
                // this.notifyList.splice(i, 1);
                // if(this.unreadCount > 0){
                //     this.unreadCount = this.unreadCount - 1;
                // }
            }
        }
        notification = this.sortByDesc(notification, "modifiedDate", "Date");
        notification = this.sortByDesc(notification, "unread", "Boolean");
        this.updateNotifyList = notification;
        this.unnotifyList = notification.filter(e=> e.unread === true);
        this.unnotificationList = this.unnotifyList.slice(0, 1);
        this.isUnNotify = (this.unnotifyList.length > 0) ? true : false;
        this.unreadCount = this.unnotifyList.length;
        this.notifyList = (this.isGeneral) ? notification.filter(e => e.createdBy != 'Tom Honkus') : notification.filter(e => e.createdBy === 'Tom Honkus')
        this.adminCount = (notification.filter(e => e.createdBy != 'Tom Honkus' && e.unread === true)).length;
        this.autoCount = (notification.filter(e => e.createdBy === 'Tom Honkus' && e.unread === true)).length;
        this.isNotify = (this.notifyList.length > 0) ? true : false;
        updateNotificationMessage({msgId: eId, year: this.defaultYear, month: this.defaultMonth}).then((data) => {
            let  result = data;
            notification = this.proxyToObject(result);
            // notification = this.sortByDesc(notification, "modifiedDate", "Date");
            // notification = this.sortByDesc(notification, "unread", "Boolean");
            //this.userNotification = notification;
        }).catch((err)=>{console.log(err.message)})
       /* updateNotificationMessage({msgId: eId, year: this.defaultYear, month: this.defaultMonth}).then((data) => { 
            let  result = data
            notification = this.proxyToObject(result);
            notification = this.sortByDesc(notification, "modifiedDate", "Date");
            notification = this.sortByDesc(notification, "unread", "Boolean");
            this.unnotifyList = notification.filter(e=> e.unread === true);
            this.unnotificationList = this.unnotifyList.slice(0, 1);
            this.isUnNotify = (this.unnotifyList.length > 0) ? true : false;
            this.unreadCount = this.unnotifyList.length;
            //this.unnotifyList = (this.isGeneral) ? this.notifyList.filter(e => e.createdBy != 'Tom Honkus') : this.notifyList.filter(e => e.createdBy === 'Tom Honkus')
            this.notifyList = (this.isGeneral) ? notification.filter(e => e.createdBy != 'Tom Honkus') : notification.filter(e => e.createdBy === 'Tom Honkus')
            //this.notifyList = this.sortByDateDesc(this.notifyList, "modifiedDate");;
            this.adminCount = (notification.filter(e => e.createdBy != 'Tom Honkus' && e.unread === true)).length;
            this.autoCount = (notification.filter(e => e.createdBy === 'Tom Honkus' && e.unread === true)).length;
            this.isNotify = (this.notifyList.length > 0) ? true : false;
            console.log("Notification", JSON.stringify(this.unnotifyList), JSON.stringify(this.notifyList))
        }).catch(error=>{console.log(error)})*/
    }

    viewAllNotification() {
        this.notificationViewClicked = true;
        this.headerModalText = 'Notifications';
        this.modalClass = "slds-modal slds-modal_large slds-is-fixed slds-fade-in-open animate__animated animate__fadeInTopLeft animate__delay-1s"
        this.headerClass = "slds-modal__header header-preview slds-p-left_xx-large slds-clearfix"
        this.subheaderClass = "slds-text-heading slds-hyphenate slds-float_left"
        this.modalContent = "slds-modal__content slds-p-left_medium slds-p-right_medium slds-p-bottom_medium slds-p-top_small"
        this.styleHeader = "slds-modal__container slds-m-top_medium"
        this.styleClosebtn = "close-notify"
        // eslint-disable-next-line no-restricted-globals
        this.notificationModal = true;
        this.buttonToggle();
        this.handleToggle();
        this.debounce(() => {  this.notificationViewClicked = false }, 100)();
        // if (this.template.querySelector('c-user-profile-modal')) {
        //     this.template.querySelector('c-user-profile-modal').show();
        // }
    }

    editEntryTripLocation(){
        this.headerModalText = 'Edit Location';
        this.modalClass = "slds-modal slds-modal_medium slds-is-fixed slds-fade-in-open animate__animated animate__fadeInTopLeft animate__delay-1s"
        this.headerClass = "slds-modal__header header-preview slds-p-left_xx-large slds-clearfix"
        this.subheaderClass = "slds-text-heading slds-hyphenate slds-float_left"
        this.modalContent = "slds-modal__content  overflow-none slds-p-left_medium slds-p-right_medium slds-p-bottom_medium slds-p-top_small"
        this.styleHeader = "slds-modal__container slds-m-top_medium"
        this.styleClosebtn = "close-notify"
        // eslint-disable-next-line no-restricted-globals
        this.notificationModal = false;
        this.notificationViewClicked = false;
        if (this.template.querySelector('c-user-profile-modal')) {
            this.template.querySelector('c-user-profile-modal').show();
        }
    }

    handleSidebarToggle(event) {
        this.section = (event.detail === 'sidebar open') ? 'sidebar-open' : 'main';
        this.contentCss = (event.detail === 'sidebar open') ? "slds-align_absolute-center content-flex content-open" : "slds-align_absolute-center content-padding2-close content-flex";
        this.videoCss = (event.detail === 'sidebar open') ?   "slds-align_absolute-center video-container video-padding" : "slds-align_absolute-center video-container video-padding-close"
        this.template.querySelector('c-dashboard-profile-header').styleHeader(event.detail);
        if(!this.toggle){
            if (this.template.querySelector('c-driver-user-profile')) {
                this.toggle = true;
                this.template.querySelector('c-driver-user-profile').reflow();
            }
        }
    }

    navigateToInsurance() {
        this.insuranceView = true;
        this.contentCss = (this.section === 'sidebar-open') ? "slds-align_absolute-center content-flex content-open" : "slds-align_absolute-center content-padding2-close content-flex";
        this.videoCss = (this.section === 'sidebar-open') ?   "slds-align_absolute-center video-container video-padding" : "slds-align_absolute-center video-container video-padding-close"
        // this.contentCss = "slds-align_absolute-center content-padding2-close content-flex";
        // this.videoCss = "slds-align_absolute-center video-container video-padding-close"
        this.reimbursementView = false;
        this.manualEntryView = false;
        this.reimbursementArchive = false;
        this.complianceView = false;
        this.liabilityView = false;
        this.tripView = false;
        this.locationUploadView = false;
        this.resources = false;
        this.notificationModal = false;
        this.notificationViewClicked = false;
        // eslint-disable-next-line no-restricted-globals
        window.location.href = location.origin + location.pathname + location.search + '#Insurance-Upload';
        this.template.querySelector('c-navigation-menu').toggleStyle('Insurance-Upload');
    }

    navigateToResource(){
        this.insuranceView = false;
        this.reimbursementView = false;
        this.manualEntryView = false;
        this.reimbursementArchive = false;
        this.complianceView = false;
        this.liabilityView = false;
        this.tripView = false;
        this.locationUploadView = false;
        this.notificationModal = false;
        this.notificationViewClicked = false;
        this.resources = true;
        // eslint-disable-next-line no-restricted-globals
        window.location.href = location.origin + location.pathname + location.search + '#Videos';
        this.template.querySelector('c-navigation-menu').toggleStyle('Videos');
    }

    navigateToPage() {
        this.isHomePage = true;
        this.reimbursementView = true;
        this.manualEntryView = false;
        this.myProfile = false;
        // eslint-disable-next-line no-restricted-globals
        window.location.href = location.origin + location.pathname + location.search + '#Mileage';
        this.template.querySelector('c-navigation-menu').toggleStyle('Mileage');
        this.template.querySelector('c-dashboard-profile-header').setSource(this.isHomePage);
    }

    viewPage(){
        this.insuranceView = false;
        this.reimbursementView = false;
        this.manualEntryView = false;
        this.reimbursementArchive = false;
        this.complianceView = false;
        this.liabilityView = false;
        this.tripView = false;
        this.locationUploadView = false;
        this.notificationModal = false;
        this.notificationViewClicked = false;
        this.resources = true;
        // eslint-disable-next-line no-restricted-globals
        window.location.href = location.origin + location.pathname + location.search + '#Videos';
        this.template.querySelector('c-navigation-menu').toggleStyle('Videos');
        this.template.querySelector('c-dashboard-profile-header').setSource(this.isHomePage);
    }

    // takeMeToMenu(event) {
    //     // eslint-disable-next-line @lwc/lwc/no-async-operation
    //     setTimeout(() => {
    //         this.template.querySelector('c-dashboard-profile-header').styleLink(event.detail);
    //     }, 10)
    //     //this.template.querySelector('c-dashboard-profile-header').styleLink(event.detail);
    //     this.template.querySelector('c-dashboard-profile-header').setSource(this.isHomePage);
    // }

    reimbursementArchived(event) {
        this.isHomePage = true;
        this.template.querySelector('c-dashboard-profile-header').setSource(this.isHomePage);
        this.myProfile = false;
        this.reimbursementView = false;
        this.manualEntryView = false;
        this.reimbursementArchive = true;
        this.isTripType = event.detail;
        this.isTrip = (this.isTripType === 'MyTrip') ? true : false;
        this.isAttendance = (this.isTripType === 'timeAttendance') ? true : false;
        this.dispatchEvent(
            new CustomEvent("profile", {
                detail: 'isHide'
            })
        );
        // eslint-disable-next-line no-restricted-globals
        window.location.href = location.origin + location.pathname + location.search + '#Archive';
        this.template.querySelector('c-navigation-menu').toggleStyle('Archive');
    }

    toggleHandler(event){
        this.isTripType = event.detail;
        this.isTrip = (this.isTripType === 'MyTrip') ? true : false;
        this.isAttendance = (this.isTripType === 'timeAttendance') ? true : false;
    }

    modifyUrl(title, url) {
        if (typeof (history.pushState) != "undefined") {
         let obj = {
          Title: title,
          Url: url
         };
         history.pushState(JSON.stringify(obj), obj.Title, obj.Url);
        }
    }

    backToDashboard(){
        document.title = "Driver Dashboard";
        let url =  location.origin + location.pathname + location.search
        this.isHomePage = false;
        this.notificationModal = false;
        this.notificationViewClicked = false;
        if (this.template.querySelector('c-user-profile-modal')) {
            this.template.querySelector('c-user-profile-modal').hide();
        }
        this.myProfile = true;
        this.reimbursementView = false;
        this.manualEntryView = false;
        this.reimbursementArchive = false;
        this.complianceView = false;
        this.insuranceView = false;
        this.resources = false;
        this.liabilityView = false;
        this.locationUploadView = false;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.toogleStyleElement("");
        this.modifyUrl(document.title, url)
    }

    switchToCompliance() {
        this.liabilityView = false;
        this.complianceView = true;
        // eslint-disable-next-line no-restricted-globals
        window.location.href = location.origin + location.pathname + location.search + '#Compliance';
        this.template.querySelector('c-navigation-menu').toggleStyle('Compliance');
    }

    switchToLiability() {
        this.liabilityView = true;
        this.complianceView = false;
        // eslint-disable-next-line no-restricted-globals
        window.location.href = location.origin + location.pathname + location.search + '#Tax-Liability';
        this.template.querySelector('c-navigation-menu').toggleStyle('Tax-Liability');
    }

    navigateToReimbursement() {
        this.isTrip = (this.isTripType === 'MyTrip') ? true : false;
        this.isAttendance = (this.isTripType === 'timeAttendance') ? true : false;
        this.myProfile = false;
        this.isHomePage = true;
        this.template.querySelector('c-dashboard-profile-header').setSource(this.isHomePage);
        this.reimbursementView = true;
        this.manualEntryView = false;
        this.reimbursementArchive = false;
        // eslint-disable-next-line no-restricted-globals
        window.location.href = location.origin + location.pathname + location.search + '#Mileage';
        this.template.querySelector('c-navigation-menu').toggleStyle('Mileage');
    }

    showModalEvent(event){
        this.headerModalText = '';
        this.isNewFeature = false;
        this.navFeature = false;
        this.modalClass = "slds-modal modal_info slds-is-fixed slds-fade-in-open animate__animated animate__slideInUp animate__fast"
        this.headerClass = "slds-modal__header resource-header slds-clearfix"
        this.subheaderClass = ""
        this.modalContent = "slds-modal__content overflow-none content"
        this.styleHeader = "slds-modal__container slds-m-top_medium"
        this.styleClosebtn = "close-message"
        this.contentMessage = 'You have successfully added '+ event.detail + ' new locations.';
        this.subMessage = 'Your locations should show up after your next data sync..'
        if (this.template.querySelector('c-user-profile-modal')) {
            this.template.querySelector('c-user-profile-modal').show();
        }
    }

    showModalListEvent(){
        this.headerModalText = '';
        this.isNewFeature = false;
        this.navFeature = false;
        this.modalClass = "slds-modal modal_info slds-is-fixed slds-fade-in-open animate__animated animate__slideInUp animate__fast"
        this.headerClass = "slds-modal__header resource-header slds-clearfix"
        this.subheaderClass = ""
        this.modalContent = "slds-modal__content overflow-none content"
        this.styleHeader = "slds-modal__container slds-m-top_medium"
        this.styleClosebtn = "close-message"
        this.contentMessage = 'Your location has been updated';
        this.subMessage = 'Your locations should show up in the listing..'
        if (this.template.querySelector('c-user-profile-modal')) {
            this.template.querySelector('c-user-profile-modal').show();
        }
    }

    showNavFeature(){
        this.headerModalText = "New Feature";
        this.isNewFeature = false;
        this.navFeature = true;
        this.modalClass = "slds-modal slds-modal_x-small slds-is-fixed slds-fade-in-open animate__animated animate__slideInUp animate__fast"
        this.headerClass = "slds-modal__header resource-header slds-clearfix"
        this.subheaderClass = ""
        this.modalContent = "slds-modal__content transparent_content"
        this.styleHeader = "slds-modal__container slds-m-top_medium"
        this.styleClosebtn = "close-notify-video"
        if (this.template.querySelector('c-user-profile-modal')) {
            this.template.querySelector('c-user-profile-modal').show();
        }
    }

    showSyncFeature(){
        this.headerModalText = "Mobile app & dashboard mileage don't match?";
        this.isNewFeature = true;
        this.navFeature = false;
        this.modalClass = "slds-modal slds-modal_x-small slds-is-fixed slds-fade-in-open animate__animated animate__slideInUp animate__fast"
        this.headerClass = "slds-modal__header header-preview slds-p-horizontal_xx-large slds-p-top_x-large slds-p-bottom_xxx-small slds-clearfix"
        this.subheaderClass = "slds-text-heading_medium slds-hyphenate slds-float_left"
        this.modalContent = "slds-modal__content slds-p-left_large slds-p-right_large slds-p-bottom_medium slds-p-top_small"
        this.styleHeader = "slds-modal__container slds-m-top_medium"
        this.styleClosebtn = "close-modal-paginated"
        if (this.template.querySelector('c-user-profile-modal')) {
            this.template.querySelector('c-user-profile-modal').show();
        }
    }

    dontShow(){
        this.isNewFeature = false;
        this.navFeature = false;
        this.isNewSyncFeature = false;
        if (this.template.querySelector('c-user-profile-modal')) {
            this.template.querySelector('c-user-profile-modal').hide();
        }
        updateContactDetail({contactId: this._contactId}).then((data) => { 
        }).catch((err)=>{
            console.log("Error--", err);
        })
    }

    closeModal(){
        this.isNewFeature = false;
        this.navFeature = false;
        this.isNewSyncFeature = false;
        if (this.template.querySelector('c-user-profile-modal')) {
            this.template.querySelector('c-user-profile-modal').hide();
        }
    }

    handleCloseModal(){
        if(this.navFeature){
            this.navFeature = false;
            if(this.isNewSyncFeature && !this.navFeature){
                this.debounce(() => {  this.showSyncFeature() }, 100)();
            }
        }else{
            this.isNewFeature = false;
            this.navFeature = false;
            this.isNewSyncFeature = false;
        }
        if(!this.notificationModal){
                if(this.template.querySelector('c-user-location')){
                    this.template.querySelector('c-user-location').generateView();
                }
        }
    }

    myTripDetail(event) {
        this.biweek = event.detail.boolean;
        // console.log("biweek", this.biweek)
        if (event.detail.boolean !== undefined) {
            if (event.detail.boolean === false) {
                this.monthOfTrip = event.detail.month;
                this.yearOfTrip = event.detail.year;
                this.tripView = true;
            } else {
                let listVal = event.detail.trip;
                this.startDt = listVal.startDate;
                this.endDt = listVal.endDate;
                this.biweekId = listVal.id;
                this.tripView = true;
            }
        }

        // console.log("trips", event.detail.month, event.detail.year)
        // console.log("trips", this.startDt,  this.endDt, this.biweekId)
    }

    revertToReimbursement() {
        this.isAttendance = false;
        this.isTrip = true;
        // console.log("trip boolean", this.isAttendance, this.isTrip)
        this.myProfile = false;
        this.tripView = false;
        this.isHomePage = true;
        this.template.querySelector('c-dashboard-profile-header').setSource(this.isHomePage);
        // this.isTrip = (this.isTripType === 'MyTrip') ? true : false;
        // this.isAttendance = (this.isTripType === 'timeAttendance') ? true : false;

    }

    viewDashboardProfile() {
        // this.myProfile = true;
        var splitText, splitName;
        window.history.back();
        setTimeout(()=>{
            const url = new URL(document.location);
            let address = url.hash;
            if(address === undefined || address === '')
                  redirectionURL({ contactId: this._contactId })
                  .then((result) => {
                        let urlDirect = window.location.origin + result;
                        window.open(urlDirect, '_self');
                    })
            else
                splitText = address.split('#');
                splitName = (splitText.length > 0) ? splitText[1] : '';
                this.toogleStyleElement(splitName);
        }, 1000)
    }

    handleToast() {
        this.dispatchEvent(
            new CustomEvent("toast", {
                detail: ""
            })
        );
    }

    handleToastEvent(event) {
        this.dispatchEvent(
            new CustomEvent("toastmessage", {
                detail: event.detail
            })
        );
    }

    showSpinner(event) {
        // console.log("navigate spin")
        this.dispatchEvent(
            new CustomEvent("profile", {
                detail: event.detail
            })
        );
    }

    showToastEvent(event){
        this.dispatchEvent(
            new CustomEvent("location", {
                detail: event.detail
            })
        );
    }

    throwError(event){
        this.dispatchEvent(
            new CustomEvent("toast", {
                detail: event.detail
            })
        );
    }

    handleLogout() {
        // eslint-disable-next-line no-restricted-globals
        location.href = '/app/secur/logout.jsp';
    }

    profileModalHide(){
        if (this.template.querySelector("c-user-profile-modal")) {
          this.template.querySelector("c-user-profile-modal").hide();
        }
    }

    debounce(fn, delay) {
        let timeout;
        return function() {
          clearTimeout(timeout);
          timeout = setTimeout(() => {
            fn();
          }, delay);
        };
    }

    toogleStyleElement(element){
        this.template
        .querySelector("c-navigation-menu")
        .toggleStyle(element);
    }

    
    resetStateManagement(){
        window.history.go(window.history.length - window.history.length - 1);
    }

    handleArchive(){
        document.title = 'Archive'
        this.myProfile = false;
        this.notificationModal = false;
        this.notificationViewClicked = false;
        this.isHomePage = true;
        this.isTrip = (this.isTripType === 'MyTrip') ? true : false;
        this.isAttendance = (this.isTripType === 'timeAttendance') ? true : false;
      //  this.isTripType = (this.isTrip === true) ? 'MyTrip' : 'timeAttendance';
        this.reimbursementView = false;
        this.manualEntryView = false;
        this.reimbursementArchive = true;
        this.complianceView = false;
        this.insuranceView = false;
        this.resources = false;
        this.liabilityView = false;
        this.locationUploadView = false;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.debounce(() => { this.template.querySelector("c-dashboard-profile-header").styleLink(""); }, 10)();
    }

    handleInsurance(){
        document.title = 'My Insurance Upload'
        this.myProfile = false;
        this.notificationModal = false;
        this.notificationViewClicked = false;
        this.isHomePage = true;
        this.reimbursementView = false;
        this.manualEntryView = false;
        this.isTrip = true;
        this.isAttendance = false;
        this.reimbursementArchive = false;
        this.complianceView = false;
        this.insuranceView = true;
        this.contentCss = (this.section === 'sidebar-open') ? "slds-align_absolute-center content-flex content-open" : "slds-align_absolute-center content-padding2-close content-flex";
        this.videoCss = (this.section === 'sidebar-open') ?   "slds-align_absolute-center video-container video-padding" : "slds-align_absolute-center video-container video-padding-close"
        this.resources = false;
        this.liabilityView = false;
        this.locationUploadView = false;
    }

    handleManualEntry(){
        document.title = 'Manual Entry'
        this.myProfile = false;
        this.notificationModal = false;
        this.notificationViewClicked = false;
        this.isHomePage = true;
        this.isTrip = true;
        this.isAttendance = false;
        this.reimbursementView = false;
        this.manualEntryView = true;
        this.reimbursementArchive = false;
        this.complianceView = false;
        this.insuranceView = false;
        this.resources = false;
        this.liabilityView = false;
        this.locationUploadView = false;
    }

    handleNotificationView(){
        this.notificationViewClicked = !this.notificationViewClicked;
        this.notificationModal = !this.notificationModal;
        this.isTrip = true;
        this.isAttendance = false;
        this.isGeneral = true;
        this.debounce(() => {
            this.notificationViewClicked = false
        }, 100)(); 
        this.isHomePage = (this.isHomePage) ? true : false;
        this.reimbursementView = (this.reimbursementView) ? true : false;
        this.reimbursementArchive = (this.reimbursementArchive) ? true : false;
        this.complianceView = (this.complianceView) ? true : false;
        this.manualEntryView = (this.manualEntryView) ? true : false;
        this.insuranceView = (this.insuranceView) ? true : false;
        this.resources = (this.resources) ? true : false;
        this.locationUploadView = (this.locationUploadView) ? true : false;
        this.liabilityView = (this.liabilityView) ? true : false;
        this.myProfile = (this.myProfile) ? true : false;
    }

    handleCompliance(){
        document.title = 'Compliance'
        this.myProfile = false;
        this.notificationModal = false;
        this.isTrip = true;
        this.isAttendance = false;
        this.notificationViewClicked = false;
        this.isHomePage = true;
        this.reimbursementView = false;
        this.manualEntryView = false;
        this.reimbursementArchive = false;
        this.complianceView = true;
        this.insuranceView = false;
        this.resources = false;
        this.liabilityView = false;
        this.locationUploadView = false;
    }

    handleMileage(){
        document.title = 'Mileage'
        this.myProfile = false;
        this.notificationModal = false;
        this.notificationViewClicked = false;
        this.isHomePage = true;
        this.reimbursementView = true;
        this.isTrip = (this.isTripType === 'MyTrip') ? true : false;
        this.isAttendance = (this.isTripType === 'timeAttendance') ? true : false;
        this.manualEntryView = false;
        this.reimbursementArchive = false;
        this.complianceView = false;
        this.insuranceView = false;
        this.resources = false;
        this.liabilityView = false;
        this.locationUploadView = false;
    }

    handleTaxLiability(){
        document.title = 'Tax Liability'
        this.myProfile = false;
        this.notificationModal = false;
        this.isTrip = true;
        this.isAttendance = false;
        this.notificationViewClicked = false;
        this.isHomePage = true;
        this.reimbursementView = false;
        this.manualEntryView = false;
        this.reimbursementArchive = false;
        this.complianceView = false;
        this.insuranceView = false;
        this.resources = false;
        this.liabilityView = true;
        this.locationUploadView = false;
    }

    handleLocation(){
        document.title = 'Locations'
        this.myProfile = false;
        this.isTrip = true;
        this.isAttendance = false;
        this.notificationModal = false;
        this.notificationViewClicked = false;
        this.isHomePage = true;
        this.reimbursementView = false;
        this.manualEntryView = false;
        this.reimbursementArchive = false;
        this.complianceView = false;
        this.insuranceView = false;
        this.resources = false;
        this.liabilityView = false;
        this.locationUploadView = true;
    }

    handleTraining(){
        document.title = 'Videos/Training'
        this.myProfile = false;
        this.isTrip = true;
        this.isAttendance = false;
        this.notificationModal = false;
        this.notificationViewClicked = false;
        this.isHomePage = true;
        this.reimbursementView = false;
        this.manualEntryView = false;
        this.reimbursementArchive = false;
        this.complianceView = false;
        this.insuranceView = false;
        this.resources = true;
        this.liabilityView = false;
        this.locationUploadView = false;
        this.debounce(() => { this.template.querySelector("c-user-resource").reset(); }, 10)();
    }

    handleDefaultState(){
        document.title = "Driver Dashboard";
        this.isHomePage = false;
        this.notificationModal = false;
        this.notificationViewClicked = false;
        this.myProfile = true;
        this.reimbursementView = false;
        this.manualEntryView = false;
        this.reimbursementArchive = false;
        this.complianceView = false;
        this.insuranceView = false;
        this.resources = false;
        this.liabilityView = false;
        this.locationUploadView = false;
    }

    renderedCallback() {
        let pageBlock
        if(this.datepickerInitialized){
          return;
        }

        const buttonItem = this.template.querySelectorAll(".btn-toggle");

        buttonItem.forEach((el) =>
          el.addEventListener("click", () => {
            buttonItem.forEach((el2) => el2.classList.remove("is-active"));
            el.classList.add("is-active");
          })
        );

        pageBlock = this.template.querySelectorAll('.page-num-block');
        if (pageBlock) {
          pageBlock.forEach(item => {
            if (item.dataset.id) {
              // eslint-disable-next-line radix
              if (parseInt(item.dataset.id) === this.currentPage) {
                item.classList.add('active')
              } else {
                item.classList.remove('active')
              }
            }
          })
        }
    
    }

    popStateMessage = () => {
        const address = new URL(location).hash;
        this.tripView = false;
        this.profileModalHide();
        switch (address) {
            case "#Archive":
                this.handleArchive();
                this.toogleStyleElement("Archive");
                break;
            case "#Insurance-Upload":
                this.handleInsurance();
                this.toogleStyleElement("Insurance-Upload");
                break;
            case "#Manual-Entry":
                this.handleManualEntry();
                this.toogleStyleElement("Manual-Entry");
                break;
            case "#Notifications":
                this.handleNotificationView();
                this.toogleStyleElement("Notifications");
                break;
            case "#Compliance":
                this.handleCompliance();
                this.toogleStyleElement("Compliance");
                break;
            case "#Mileage":
                this.handleMileage();
                this.toogleStyleElement("Mileage");
                break;
            case "#Tax-Liability":
                this.handleTaxLiability();
                this.toogleStyleElement("Tax-Liability");
                break;
            case "#Locations":
                this.handleLocation();
                this.toogleStyleElement("Locations");
                break;
            case "#Videos":
                this.handleTraining();
                this.toogleStyleElement("Videos");
                break;
            default:
                this.handleDefaultState();
                this.toogleStyleElement("");
        }
        this.template.querySelector('c-dashboard-profile-header').setSource(this.isHomePage);
    }

    getLastYear(){
        var current, year, count = 5, i, list = [];
        current = new Date();
        year = current.getFullYear();
        for (i = year; i > year - count; i--) {
            let obj = {}
            obj.id = i;
            obj.label = (i).toString();
            obj.value = (i).toString();
            list.push(obj);
         }

         return list
    }

    closeNotification(){
        let divElement = this.template.querySelector('.vue-sidebar');
        const url = new URL(document.location);
        let address = url.hash;
      
        if (divElement) {
          divElement.classList.remove("transition");
          divElement.classList.add("transition-back");
          this.debounce(() => {
            this.notificationModal = false;
            if (address === "#Notifications") {
              this.resetStateManagement();
            }
          }, 100)(); 
        }
       // this.notificationModal = false;
    }

    handleYearChange(event){
        this.defaultYear = event.detail.value;
        this.getContactNotification();
    }

    
    handleMonthChange(event){
        this.defaultMonth = event.detail.value;
        this.getContactNotification();
    }

    emailSent(event){
        var emailOfContact
        if(event.detail.contactEmail !== '' && event.detail.contactEmail != null && event.detail.contactEmail !== undefined){
            emailOfContact = event.detail.contactEmail;
            sendMlogWelcomeEmail({
                accountID: this._accountId,
                empEmail: emailOfContact
            })
            .then((result) => {
                if (result === "\"OK\"") {
                    this.dispatchEvent(
                        new CustomEvent("sent", {
                            detail: event.detail
                        })
                    );
                }else{
                    this.dispatchEvent(
                        new CustomEvent("senterror", {
                            detail: 'Error While Sending Email'
                        })
                    );
                }
            })
        }else{
            this.dispatchEvent(
                new CustomEvent("senterror", {
                    detail: 'Please provide your email address'
                })
            );
        }
    }

    reimburseEvent(event){
        this.monthMilesThis = event?.detail?.thisMonthMiles;
        this.monthMilesLast = event?.detail?.lastMonthMiles;
    }

    getUpdatedYear() {
        var activated, i, list = [], month = [], monthCount, compareCount, compareYear, year, yearCurrent, systemNotification, now;
        systemNotification = this.systemNotification; // Contact's System notification
        let activationDate = this.activationDate; // Contact's activation date
        const getMonths = (fromDate, toDate) => {
            const fromYear = fromDate.getFullYear();
            const fromMonth = fromDate.getMonth();
            const toYear = toDate.getFullYear();
            const toMonth = toDate.getMonth();
            const months = [];
            if(fromDate > toDate){
              //for(let year = fromYear; year <= toYear; year++) {
                let monthNum = year === fromYear ? fromMonth : 0;
                let month = monthNum;
                let name = this.listOfMonth[month]
                months.push(name);
              //}
            }else{
              for(let year = fromYear; year <= toYear; year++) {
                  let monthNum = year === fromYear ? fromMonth : 0;
                  const monthLimit = year === toYear ? toMonth : 11;
                  for(; monthNum <= monthLimit; monthNum++) {
                      let month = monthNum;
                      let name = this.listOfMonth[month]
                      months.push(name);
                  }
              }
          }
            return months;
        }
        activated = (activationDate) ? new Date(activationDate) : new Date();
        year = activated.getFullYear();
        now = new Date().getFullYear();
        yearCurrent = 2023;
        compareYear = new Date(2023, 9, 0);
        compareCount = new Date();
        if (systemNotification === 'New') {
          /*this.defaultYear = (activated.getFullYear()).toString();
          this.defaultMonth = activated.toLocaleString('default', {
              month: 'long'
          })*/
          this.defaultYear = now.toString();
          this.defaultMonth = compareCount.toLocaleString('default', {
              month: 'long'
          })
          monthCount = activated
          month = getMonths(monthCount, compareCount);
          if(monthCount > compareCount){
            let obj = {}
            obj.id = year;
            obj.label = (year).toString();
            obj.value = (year).toString();
            list.push(obj);
          }else{
            for (i = year; i <= now; i++) {
              let obj = {}
              obj.id = i;
              obj.label = (i).toString();
              obj.value = (i).toString();
              list.push(obj);
            }
          }
        } else {
          this.defaultYear = now.toString();
          this.defaultMonth = compareCount.toLocaleString('default', {
              month: 'long'
          })
          monthCount = compareYear
          month = getMonths(monthCount, compareCount);
          if(monthCount > compareCount){
            let obj = {}
            obj.id = yearCurrent;
            obj.label = (yearCurrent).toString();
            obj.value = (yearCurrent).toString();
            list.push(obj);
          }else{
            for (i = yearCurrent; i <= now; i++) {
              let obj = {}
              obj.id = i;
              obj.label = (i).toString();
              obj.value = (i).toString();
              list.push(obj);
            }
          }
        }
        this.monthList = month
        return list
      }

    constructor() {
        super();
        this.handleKeyDown = this.handleKeyDown.bind(this);
    }

    connectedCallback() {
        if(this.loginCount > 0 && this.loginCount <= 5 && location.hash === ''){
            this.debounce(() => { this.showNavFeature() }, 0)();
        }
        var currentDay = new Date(), currentYear = '', selectedYear = '', menuList = [];
        const idParamValue = this.getUrlParamValue(window.location.href, 'id');
        const aidParamValue = this.getUrlParamValue(window.location.href, 'accid');
        this.currentDate = validateDate(new Date());
        this.defaultYear = (currentDay.getFullYear()).toString();
        this.defaultMonth = currentDay.toLocaleString('default', {
            month: 'long'
        })
        //this.currentDate = 'null';
        this._contactId = idParamValue;
        this._accountId = aidParamValue;
        this.isHomePage = false;
        this.originalProfileMenu = this.driverProfileMenu;
        this.yearList = this.getUpdatedYear();
        this.isArchive = (this.last2Year) ? (JSON.parse(this.last2Year).length > 1) ? true : false : false;
        this.archive = this.isArchive;
        this.insuranceVideo = this.customSetting.Insurance_Link__c;
        this.navFeatureLink = this.customSetting.Nav_Feature_For_Driver__c;
        window.addEventListener('click', this._handler = this.handleOutsideClick.bind(this));
        window.addEventListener('keydown', this.handleKeyDown);
        window.addEventListener('popstate', this.popStateMessage);
            if (currentDay.getMonth() === 0) {
                currentYear = currentDay.getFullYear() - 1;
                selectedYear = currentYear.toString();
            } else {
                currentYear = currentDay.getFullYear();
                selectedYear = currentYear.toString();
            }

            getDriverDetails({
                contactId: this._contactId
            }).then((data) => {
                if (data) {
                    var planVehicleAge, planInsurance, planVehicleValue, planCompliance, planYear, complianceMileage, annualMileage, isValid, planMileage, syncFeature
                    let contactList = this.proxyToObject(data);
                    this.contactInformation = data;
                    // console.log("contact--->", this.contactInformation);
                    this.isManualEntryUser = contactList[0].is_Manual_Entry_User__c;
                    this.userTriplogId = contactList[0].Triplog_UserID__c;
                    this.mapCountry = contactList[0].Map_Country__c;
                    this.userEmail = contactList[0].External_Email__c;
                    this.userName = contactList[0].Name;
                    this.firstName = contactList[0].FirstName;
                    this.dateOfExpiration = contactList[0].Expiration_Date__c;
                    planInsurance = (contactList[0].Insurance__c !== undefined) ? (contactList[0].Insurance__c === 'Yes') ? true : false : false;
                    planVehicleAge =  (contactList[0].Vehicle_Age__c !== undefined) ?  (contactList[0].Vehicle_Age__c === 'Yes') ? true : false : false;
                    planVehicleValue = (contactList[0].Vehicle_Value_Check__c !== undefined) ?   (contactList[0].Vehicle_Value_Check__c === 'Yes') ? true : false : false;
                    planCompliance =  (contactList[0].monthly_compliance_status__c !== undefined) ?  (contactList[0].monthly_compliance_status__c === 'Yes') ? true : false : false;
                    planYear = (contactList[0].Plan_Years__c !== undefined) ?  contactList[0].Plan_Years__c : 0;
                    complianceMileage = (contactList[0].Compliance_Mileage__c !== undefined) ? contactList[0].Compliance_Mileage__c : 0;
                    annualMileage = (contactList[0].Total_Approved_Mileages__c !== undefined) ? contactList[0].Total_Approved_Mileages__c : '0';
                    isValid = parseFloat(annualMileage) >= parseFloat(complianceMileage) ? true : false;
                    planMileage =  (isValid) ? true : false;
                    syncFeature = (contactList[0].Role__c === undefined) ? false : (contactList[0].Role__c === 'Driver' || contactList[0].Role__c === 'Driver/Manager' || contactList[0].Role__c === 'Driver/Admin') ? (contactList[0].Sync_Feature__c === undefined) ? false : contactList[0].Sync_Feature__c : false;
                    this.isNewSyncFeature = syncFeature;
                    if(this.isNewSyncFeature && !this.navFeature){
                        this.debounce(() => {  this.showSyncFeature() }, 100)();
                    }
                    if(!this.isArchive){
                        const archiveMenuId = 102;
                        const newArray = this.originalProfileMenu.map(v => ({
                            ...v,
                            menuItem: v.menuItem.map(r =>  r.menuId === archiveMenuId ? false : r
                            ).filter(Boolean)
                            })
                        )
                        this.driverProfileMenu = newArray
                     }else{
                        this.driverProfileMenu = this.originalProfileMenu
                     }
                    // M-E
                    if(ManualEntry.includes(this._accountId) && this.isManualEntryUser == true) {
                        let menuList = this.driverProfileMenu[0].menuItem;
                        menuList.push({
                            menuId: menuList[menuList.length - 1].menuId + 1,
                            menu: "Manual-Entry",
                            menuLabel : "Manual Entry",
                            menuClass: "tooltipText",
                            logo: logo + '/emc-design/assets/images/Icons/SVG/Green/Manual_Entry.svg#manual',
                            logoHov: logo + '/emc-design/assets/images/Icons/SVG/White/Manual_Entry.svg#manual'
                        });
                    }
                    // M-E
                    getAllReimbursements({
                        year: selectedYear,
                        contactId: this._contactId,
                        accountId: this._accountId
                    })
                    .then((result) => {
                        let reimbursementList = this.proxyToObject(result[0]);
                        this.mileageList = reimbursementList;
                        this.excelYtdList = this.proxyToObject(result[1]);
                        this.ytdList = this.proxyToObject(result[1]);
                        this.getContactNotification();
                        if (this.ytdList) {
                            this.ytdList.varibleAmountCalc = (this.ytdList.varibleAmountCalc) ? this.ytdList.varibleAmountCalc.replace(/\$/g, "") : this.ytdList.varibleAmountCalc;
                            this.ytdList.totalFixedAmountCalc = (this.ytdList.totalFixedAmountCalc) ? this.ytdList.totalFixedAmountCalc.replace(/\$/g, "") : this.ytdList.totalFixedAmountCalc;
                            this.ytdList.totalReim = (this.ytdList.totalReim) ? this.ytdList.totalReim.replace(/\$/g, "") : this.ytdList.totalReim;
                            this.ytdList.totalMonthlyFixedCalc = (this.ytdList.totalMonthlyFixedCalc) ? this.ytdList.totalMonthlyFixedCalc.replace(/\$/g, "") : this.ytdList.totalMonthlyFixedCalc;
                            this.ytdList.totalAVGCalc = (this.ytdList.totalAVGCalc) ? this.ytdList.totalAVGCalc.replace(/\$/g, "") : this.ytdList.totalAVGCalc;
                            if(window.location.hash !== ''){
                                this.debounce(() => {   this.popStateMessage(); }, 0)();
                            }
                        }
                    })
                    .catch((error) => {
                        console.log("getAllReimbursements error", error);
                    });
                    // this.driverNotification(contactList[0].Notification_Message__c, contactList[0].Notification_Date__c, contactList[0].Insurance_Upload_Date__c);
                }
            }).catch((error) => {
                console.log("getDriverDetails error", error)
            })

          


    }
}