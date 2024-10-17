/* eslint-disable radix */
/* eslint-disable no-useless-escape */
/* eslint-disable no-restricted-globals */
/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable @lwc/lwc/no-api-reassignments */
/* eslint-disable @lwc/lwc/valid-api */
/* eslint-disable @lwc/lwc/no-leading-uppercase-api-name */
import { LightningElement, api, track, wire } from "lwc";
import logo from "@salesforce/resourceUrl/EmcCSS";
import { loadStyle , loadScript } from 'lightning/platformResourceLoader';
import jQueryMinified from '@salesforce/resourceUrl/jQueryMinified';
import datepicker from '@salesforce/resourceUrl/calendar';
import customMinifiedDP  from '@salesforce/resourceUrl/modalCalDp';
import myTeamDetails from "@salesforce/apex/ManagerDashboardController.myTeamDetails";
import getDriverDetails from "@salesforce/apex/ManagerDashboardController.getDriverDetails";
import getVehicleValue from "@salesforce/apex/ManagerDashboardController.getVehicleValue";
import getLastMonthReimbursements from "@salesforce/apex/ManagerDashboardController.getLastMonthReimbursements";
import getAllDriversLastMonthUnapprovedReimbursementsclone from "@salesforce/apex/ManagerDashboardController.getAllDriversLastMonthUnapprovedReimbursementsclone";
import getUnapprovedMileages from "@salesforce/apex/ManagerDashboardController.getUnapprovedMileages";
import getMileages from "@salesforce/apex/ManagerDashboardController.getMileages";
import contactReimMonthList from "@salesforce/apex/ManagerDashboardController.contactReimMonthList";
import accountDetails from "@salesforce/apex/ManagerDashboardController.accountDetails";
import accountMonthList from "@salesforce/apex/ManagerDashboardController.accountMonthList";
import getUnapprovedReim from "@salesforce/apex/ManagerDashboardController.getUnapprovedReim";
import reimbursementForHighMileageOrRisk from "@salesforce/apex/ManagerDashboardController.reimbursementForHighMileageOrRisk";
import getNotificationMessageList from '@salesforce/apex/ManagerDashboardController.getNotificationMessageList';
import updateNotificationMessage from '@salesforce/apex/ManagerDashboardController.updateNotificationMessage';
import dropdownDriverName from '@salesforce/apex/GetDriverData.getDriverName';
import fetchLookUpValues from '@salesforce/apex/GetDriverData.fetchLookUpValues';
import sendMlogWelcomeEmail from '@salesforce/apex/ResourceController.sendMlogWelcomeEmail';
export default class ManagerDashboardFrame extends LightningElement {
  section = "main";
  /* logged in user name in navigation menu*/
  userName;

  /* logged in user first name in navigation menu*/
  firstName;

  /* logged in user email in navigation menu*/
  userEmail;

  contactInformation;

  contactTitle;
  contactVehicle;
  lastMonth;
  viewTag;
  lastMonthSelected;
  _contactId;
  _accountId;
  accName;
  contactUserId;
  mileageContactName = "";
  dashboardTitle = "";
  driverProfileName = "";
  defaultYear = '';
  defaultMonth = '';
  listOfDriver;
  myTeamList;
  unreadCount;
  isTeamShow;
  listOfReimbursement;
  unapproveMileages;
  viewMileages;
  nameFilter = "";
  monthSelected = "";
  isProfile = false;
  biweekAccount = false;
  checkAll = false;
  isGeneral = true;
  reimbursement = [];
  commuteMileageList = [];
  showDriverView = false;
  navFeature = false;
  isDashboard = false;
  mileageApproval = false;
  notificationModal = false;
  singleUser = false;
  teamList = false;
  mileageSummary = false;
  mileageSummaryView = false;
  resources = false;
  mileageView = false;
  menu = false;
  calendarJsInitialised = false;
  notificationViewClicked = false;
  driverName = "";
  unapproveReimbursements = "";
  driverList;
  driverdetail;
  idContact;
  // width of video
  videoWidth = "100%";

  // height of video
  videoHeight = "332px";
  mileageMonthList = "";
  mileageAccountList = "";
  pageSize = 100;
  Statuspicklist = [{label:'All Status',value:'All Status'}];
  monthpicklist ;
  Statusoptions = [];
  teamColumn = [
    {
      id: 1,
      name: "Name",
      colName: "name",
      colType: "String",
      arrUp: false,
      arrDown: false
    },
    {
      id: 2,
      name: "Activation Date",
      colName: "activationDate",
      colType: "Date",
      arrUp: false,
      arrDown: false
    },
    {
      id: 3,
      name: "Fixed Amount",
      colName: "fixedamount",
      colType: "Decimal",
      arrUp: false,
      arrDown: false
    }
  ];
  teamKeyFields = ["name", "activationDate", "fixedamount"];

  summaryColumn = [
    {
      id: 1,
      name: "Name",
      colName: "name",
      colType: "String",
      arrUp: false,
      arrDown: false
    },
    {
      id: 2,
      name: "Approved",
      colName: "approvedMileages",
      colType: "Decimal",
      arrUp: false,
      arrDown: false
    },
    {
      id: 3,
      name: "Flagged",
      colName: "rejectedMileages",
      colType: "Decimal",
      arrUp: false,
      arrDown: false
    },
    {
      id: 4,
      name: "Total Mileage",
      colName: "totalMileages",
      colType: "Decimal",
      arrUp: false,
      arrDown: false
    }
  ];
  summaryKeyFields = [
    "name",
    "approvedMileages",
    "rejectedMileages",
    "totalMileages"
  ];

  summaryDetailColumn = [
    {
      id: 1,
      name: "Trip Date",
      colName: "tripdate",
      colType: "Date",
      arrUp: false,
      arrDown: false
    },
    {
      id: 2,
      name: "Origin",
      colName: "originname",
      colType: "String",
      arrUp: false,
      arrDown: false
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
  summaryDetailKeyFields = [
    "tripdate",
    "originname",
    "destinationname",
    "submitteddate",
    "status",
    "mileage",
    "variableamount"
  ];

  @track isHomePage = false;
  @track isNotify = false;
  @track isUnNotify = false;
  @track notifyList;
  @track userNotification;
  @track updateNotifyList;
  @track notificationList;
  @api unnotifyList;
  @api unnotificationList;
  @api showTeam;
  @api loginCount;
  @api userRole;
  @api managerId;
  @api roleId;
  @api profile;
  @api mileageRecord;
  @api customSetting;
  @api driverMeeting;
  @api systemNotification;
  @api activationDate;
 
  @track managerProfileMenu = [
    {
      id: 0,
      label: "Bookmark",
      menuItem: [
        {
          menuId: 1,
          menuLabel: "Bookmarks",
          menuClass: "tooltipText hasItem",
          logo: logo + "/emc-design/assets/images/Icons/SVG/Green/Bookmark.svg#bookmarks",
          logoHov: logo + "/emc-design/assets/images/Icons/SVG/White/Bookmark.svg#bookmarks",
          subMenuItem: []
        }
      ],
    },
    {
      id: 1,
      label: "Mileage",
      menuItem: [
        {
          menuId: 101,
          menu: "Mileage-Approval",
          menuLabel: "Mileage",
          menuClass: "tooltipText hasItem",
          logo:
            logo +
            "/emc-design/assets/images/Icons/SVG/Green/Approval.svg#approval",
          logoHov:
            logo +
            "/emc-design/assets/images/Icons/SVG/White/Approval.svg#approval",
          subMenuItem: [
            {
              menuId: 1011,
              menu: "Mileage-Approval",
              menuLabel: "Unapproved",
              menuClass: "active",
							pinBookmark: false 
            },
            {
              menuId: 1012,
              menu: "Mileage-Preview",
              menuLabel: "Preview",
              menuClass: "",
							pinBookmark: false 
            },
            {
              menuId: 1013,
              menu: "Mileage-Summary",
              menuLabel: "Summary",
              menuClass: "",
							pinBookmark: false 
            }
          ],
        },
        /* {
          menuId: 102,
          menu: "Mileage-Summary",
          menuLabel: "Summary",
          menuClass: "active",
          logo:
            logo +
            "/emc-design/assets/images/Icons/SVG/Green/Mileage_summary.svg#summary",
          logoHov:
            logo +
            "/emc-design/assets/images/Icons/SVG/White/Mileage_summary.svg#summary"
        },
        {
          menuId: 103,
          menu: "Mileage-Preview",
          menuLabel: "Preview",
          menuClass: "active",
          logo:
            logo +
            "/emc-design/assets/images/Icons/SVG/Green/Historical_Mileage.svg#historical",
          logoHov:
            logo +
            "/emc-design/assets/images/Icons/SVG/White/Historical_Mileage.svg#historical"
        }*/
      ],
    },
    {
      id: 2,
      label: "Plan management",
      menuItem: [
        {
          menuId: 201,
          menu: "Team",
          menuLabel: "Team",
          menuClass: "tooltipText",
          logo:
            logo +
            "/emc-design/assets/images/Icons/SVG/Green/Drivers_list.svg#drivers",
          logoHov:
            logo +
            "/emc-design/assets/images/Icons/SVG/White/Drivers_list.svg#drivers",
        }
      ],
    },
    {
      id: 3,
      label: "Help & info",
      menuItem: [
        {
          menuId: 301,
          menu: "Videos",
          menuLabel: "Videos/Training",
          menuClass: "tooltipText",
          logo:
            logo +
            "/emc-design/assets/images/Icons/SVG/Green/Driver_Videos_Training.svg#videos",
          logoHov:
            logo +
            "/emc-design/assets/images/Icons/SVG/White/Driver_Videos_Training.svg#videos"
        }
      ]
    }
  ];

  //selectList = [];
  selectList = [
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
  ];

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

  /*Return json to array data */
  proxyToObject(e) {
    return JSON.parse(e);
  }

  /*Get parameters from URL*/
  getUrlParamValue(url, key) {
    return new URL(url).searchParams.get(key);
  }

  /* sidebar open/close arrow navigation event*/
  handleSidebarToggle(event) {
    this.section = (event.detail === 'sidebar open') ? 'sidebar-open' : 'main';
    this.template
      .querySelector("c-dashboard-profile-header")
      .styleHeader(event.detail);
  }
  /* Logout button event on header*/
  handleLogout() {
    // eslint-disable-next-line no-restricted-globals
    location.href = "/app/secur/logout.jsp";
  }

  @wire(getDriverDetails, {
    managerId:'$managerId'
  })userInfo({data,error}) {
      if (data) {
        this.contactInformation = data;
        let contact = JSON.parse(data)
        this.driverdetail = data;
        this.userEmail = contact[0].External_Email__c;
        this.userName = contact[0].Name;
        this.firstName = contact[0].FirstName;
        this.biweekAccount = contact[0].Account.Bi_Weekly_Pay_Period__c;
      }else if(error){
          console.log("getDriverDetails error", error.message)
      }
  }

  @wire(getVehicleValue, {
    accountId:'$_accountId'
  })vehicleValue({data,error}) {
      if (data) {
        this.contactVehicle = data;
      }else if(error){
          console.log("vehicleValue error", error.message)
      }
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
   }).catch((err)=>{console.log(err.message)})
     
  }

  modifyUrl(title, url) {
    if (typeof (history.pushState) != "undefined") {
     let obj = {
      Title: title,
      Url: url
     };
     history.pushState(obj, obj.Title, obj.Url);
    }
   }


  handleCloseModal() {
    this.navFeature = false;
  }

  handleClose(event) {
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
      }).catch((err)=>{console.log(err.message)})
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
    }).catch(error=>{console.log(error)})
  
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

  getMileageList(event) {
    this.isProfile = false;
    this.isDashboard = false;
    this.notificationViewClicked = false;
    this.contactTitle = "Unapproved Mileage";
   this.isHomePage = false;
    window.location.href =
      location.origin +
      location.pathname +
      location.search +
      "#Mileage-Approval";
    this.toogleStyleElement("Mileage-Approval");
    this.listOfDriver = event.detail;
  }

  getMyTeamList(event) {
    this.isProfile = false;
    this.mileageApproval = false;
    this.resources = false;
    this.notificationViewClicked = false;
    this.isDashboard = false;
    this.teamList = true;
    this.contactTitle = "My Team";
   this.isHomePage = false;
    window.location.href =
      location.origin + location.pathname + location.search + "#Team";
    this.toogleStyleElement("Team");
    this.myTeamList = event.detail;
  }

  redirectToMileage(event) {
    if(event.detail !== 'Dashboard'){    
      this.isProfile = false;
      this.isDashboard = false;
      this.mileageApproval = true;
      this.notificationViewClicked = false;
      this.contactTitle = "Unapproved Mileage";
      this.isHomePage = false;
      this.listOfDriver = undefined;
      window.location.href =
        location.origin +
        location.pathname +
        location.search +
        "#Mileage-Approval";
      this.toogleStyleElement("Mileage-Approval");
    }else{
      document.title = "Admin Dashboard";
      let url =  location.origin + location.pathname + location.search
      this.contactTitle = this.userName;
      this.notificationModal = false;
      this.notificationViewClicked = false;
      this.mileageView = false;
      this.showDriverView = false;
      this.showUsers = false;
      this.showTools = false;
      this.showReports = false;
      this.reportDetail = false;
      this.resources = false;
      this.isHomePage = false;
      this.isProfile = true;
      this.isDashboard = false;
      this.toogleStyleElement("");
      this.modifyUrl(document.title, url)
    }
  }

  redirectToSummary(event) {
    if(event.detail !== 'Dashboard'){
    this.isProfile = false;
    this.mileageApproval = false;
    this.resources = false;
    this.isDashboard = false;
    this.mileageSummaryView = false;
    this.notificationViewClicked = false;
    this.mileageSummary = true;
    this.contactTitle = this.viewTag;
    let hasVal = (this.viewTag === 'High Risk') ? '#Mileage-Summary-Risk' : (this.viewTag === 'High Mileage') ? '#Mileage-Summary-High' : '#Mileage-Summary';
    this.isHomePage = false;
    window.location.href =
      location.origin +
      location.pathname +
      location.search +
      hasVal
    this.toogleStyleElement("Mileage-Summary");
    }else{
      document.title = "Admin Dashboard";
      let url =  location.origin + location.pathname + location.search
      this.contactTitle = this.userName;
      this.notificationModal = false;
      this.notificationViewClicked = false;
      this.mileageView = false;
      this.showDriverView = false;
      this.showUsers = false;
      this.showTools = false;
      this.showReports = false;
      this.reportDetail = false;
      this.resources = false;
      this.isHomePage = false;
      this.isProfile = true;
      this.isDashboard = false;
      this.toogleStyleElement("");
      this.modifyUrl(document.title, url)
    } 
  }

  redirectToHighRiskMileage() {
    this.isProfile = false;
    this.mileageApproval = false;
    this.resources = false;
    this.mileageSummaryView = false;
    this.notificationViewClicked = false;
    this.isDashboard = false;
    this.mileageSummary = true;
    this.lastMonthSelected = this.lastMonth;
    this.contactTitle = "High Risk";
   this.isHomePage = false;
    window.location.href =
      location.origin +
      location.pathname +
      location.search +
      "#Mileage-Summary-Risk";
    this.toogleStyleElement("Mileage-Summary");
  }

  redirectToRiskMileage(event){
    this.viewTag = 'High Risk';
    let detailList = JSON.parse(event.detail);
    let contactId = detailList.id;
    this.contactUserId = contactId;
    this.mileageContactName = detailList.name;
    this.notificationViewClicked = false;
    this.isHomePage = false;
    this.isProfile = false;
    this.mileageApproval = false;
    this.resources = false;
    this.mileageSummary = false;
    this.isDashboard = true;
    this.mileageSummaryView = true;
    this.viewMileages = "";
    window.location.href =
      location.origin +
      location.pathname +
      location.search +
      "#Mileage-Summary-Detail";
    this.toogleStyleElement("Mileage-Summary");
    contactReimMonthList({
      contactId: contactId
    })
      .then((data) => {
        let objList = JSON.parse(data)
        let monthName = this.lastMonthSelected;
        //let monthName = data ? ((objList.length > 1) ? ((objList[0] === this.defaultMonth) ? objList[1] : objList[0]): objList[0]) : "";
        let mileageMonth = data ? this.removeDuplicateValue(this.proxyToObject(data)) : [];
        this.mileageMonthList = this.review(mileageMonth);
        this.monthSelected = monthName ? monthName : "";
        this.contactTitle = "High Risk " + this.monthSelected + " Mileage For " + detailList.name;
        this.dashboardTitle = this.contactTitle;
        this.getListMileages(contactId, this.monthSelected);
      })
      .catch((error) => {
        console.log("contactReimMonthList error", error);
      });
  }

  redirectMileage(event){
    this.viewTag = 'High Mileage';
    let detailList = JSON.parse(event.detail);
    let contactId = detailList.id;
    this.contactUserId = contactId;
    this.mileageContactName = detailList.name;
    this.isHomePage = false;
    this.isProfile = false;
    this.notificationViewClicked = false;
    this.mileageApproval = false;
    this.resources = false;
    this.mileageSummary = false;
    this.mileageSummaryView = true;
    this.isDashboard = true;
    this.viewMileages = "";
    window.location.href =
      location.origin +
      location.pathname +
      location.search +
      "#Mileage-Summary-Detail";
    this.toogleStyleElement("Mileage-Summary");
    contactReimMonthList({
      contactId: contactId
    })
      .then((data) => {
        let objList = JSON.parse(data)
        let monthName = this.lastMonthSelected;
       // let monthName = data ? ((objList.length > 1) ? ((objList[0] === this.defaultMonth) ? objList[1] : objList[0]): objList[0]) : "";
        let mileageMonth = data ? this.removeDuplicateValue(this.proxyToObject(data)) : [];
        this.mileageMonthList = this.review(mileageMonth);
        this.monthSelected = monthName ? monthName : "";
        this.contactTitle =
          detailList.name + " " + this.monthSelected + " Mileage";
        this.dashboardTitle = this.contactTitle;
        this.getListMileages(contactId, this.monthSelected);
      })
      .catch((error) => {
        console.log("contactReimMonthList error", error);
      });
  }


  redirectToHighMileage(){
    this.isProfile = false;
    this.mileageApproval = false;
    this.mileageSummaryView = false;
    this.resources = false;
    this.notificationViewClicked = false;
    this.mileageSummary = true;
    this.isDashboard = false;
    this.contactTitle = "High Mileage";
   this.isHomePage = false;
    window.location.href =
      location.origin +
      location.pathname +
      location.search +
      "#Mileage-Summary-High";
    this.toogleStyleElement("Mileage-Summary");
  }

  handleMonthYearRender(event){
    const url = new URL(document.location);
    let params = new URL(document.location).searchParams;
    let address = url.hash;
    let showteam = params.get("showteam");
    let v = showteam === "false" ? false : true;
    let boolean = (address === "#Mileage-Summary-High") ? true : false;
    this.lastMonthSelected = event.detail;
    if(address === '#Mileage-Summary'){
      this.getAllReimbursement(v, this.lastMonthSelected);
    }else{
      this.getMileageHighRisk(v, boolean, event.detail);
    }
  }

  getMileageHighRisk(boolean, v, monthName) {
    const url = new URL(document.location);
    let address = url.hash;
    this.notificationViewClicked = false;
    this.lastMonthSelected = (this.lastMonthSelected === undefined) ? monthName : this.lastMonthSelected;
    this.listOfReimbursement = "";
    let column = [{
          id: 1,
          name: "Name",
          colName: "name",
          colType: "String",
          arrUp: false,
          arrDown: false
        },
        {
          id: 2,
          name: "Approved",
          colName: "highRiskTotalApproved",
          colType: "Decimal",
          arrUp: false,
          arrDown: false
        },
        {
          id: 3,
          name: "Flagged",
          colName: "highRiskTotalRejected",
          colType: "Decimal",
          arrUp: false,
          arrDown: false
        },
        {
          id: 4,
          name: "Total Mileage",
          colName: "totalHighRiskMileages",
          colType: "Decimal",
          arrUp: false,
          arrDown: false
        }
    ];
    let columnKeyFields = [
        "name",
        "highRiskTotalApproved",
        "highRiskTotalRejected",
        "totalHighRiskMileages"
    ];

    let columnA = [{
          id: 1,
          name: "Name",
          colName: "name",
          colType: "String",
          arrUp: false,
          arrDown: false
        },
        {
          id: 2,
          name: "Approved",
          colName: "approvedMileages",
          colType: "Decimal",
          arrUp: false,
          arrDown: false
        },
        {
          id: 3,
          name: "Flagged",
          colName: "rejectedMileages",
          colType: "Decimal",
          arrUp: false,
          arrDown: false
        },
        {
          id: 4,
          name: "Total Mileage",
          colName: "totalMileages",
          colType: "Decimal",
          arrUp: false,
          arrDown: false
        }
    ];

    let columnAKeyFields = [
        "name",
        "approvedMileages",
        "rejectedMileages",
        "totalMileages"
    ];

    this.summaryColumn = (address === "#Mileage-Summary-Risk") ? column : columnA;
    this.summaryKeyFields = (address === "#Mileage-Summary-Risk") ? columnKeyFields : columnAKeyFields;
    reimbursementForHighMileageOrRisk({
      managerId: this._contactId,
      accountId: this._accountId,
      month: monthName,
      showteam: boolean,
      highMileage: v,
      role: this.userRole
    })
      .then((data) => {
        let resData = data.replace(/\\/g, "");
        this.listOfReimbursement = resData;
      })
      .catch((error) => {
        console.log("reimbursementForHighMileageOrRisk error", error);
      });
  }

  getUnapproveMileage(event) {
    var arrayInput, original, filterList;
    // this.dispatchEvent(
    //     new CustomEvent("show", {
    //         detail: "spinner"
    //     })
    // );
    this.contactTitle = "Unapproved Mileage";
    this.nameFilter = event.detail.type;
   this.isHomePage = false;
   this.singleUser = false;
   this.notificationViewClicked = false;
   this.isDashboard = (event.detail.target) ? true : false;
    window.location.href =
      location.origin +
      location.pathname +
      location.search +
      "#Mileage-Approval-Flag";
    this.toogleStyleElement("Mileage-Approval");
    this.unapproveMileages = "";
    this.unapproveReimbursements = (event.detail.data) ? event.detail.data : event.detail.message;
    this.reimbursement = (this.unapproveReimbursements) ? JSON.parse(this.unapproveReimbursements)?.reimbursementIdList : [];
    getUnapprovedReim({ reimbursements: JSON.stringify(this.reimbursement) }).then(result => { this.commuteMileageList = result; })
    getUnapprovedMileages({
      reimbursementDetails: (event.detail.data) ? event.detail.data : event.detail.message,
      accountId: this._accountId
    })
      .then((data) => {
        let resData = this.safeJSONParse(data);
        // this.notificationModal = false;
        // this.isProfile = false;
        // this.mileageApproval = false;
        // this.mileageSummary = false;
        // this.mileageSummaryView = false;
        // this.teamList = false;
        // this.mileageView = false;
        // this.showDriverView = false;
        arrayInput = resData;
        original = arrayInput;

        if (event.detail.type === "High Risk") {
          filterList = arrayInput.mileagesList.filter(function (b) {
            return b.highRiskMileage === true;
          });
          this.unapproveMileages = JSON.stringify(filterList);
        } else {
          filterList = original.mileagesList;
          this.unapproveMileages = JSON.stringify(filterList);
        }
        this.driverName = arrayInput.name;

        // this.dispatchEvent(
        //     new CustomEvent("hide", {
        //         detail: "spinner"
        //     })
        // );
      })
      .catch((error) => {
        console.log("getUnapproveMileages error", error);
      });
  }

  safeJSONParse(jsonString) {
    try {
      // Step 1: Unescape JSON strings to handle double-escaped characters
      const unescapedJSON = jsonString.replace(/\\./g, (match) => {
        switch (match) {
          case '\\"': return '"';
          case '\\n': return '\n';
          case '\\t': return '\t';
          case '\\&#39;': return "\'";
          case '(&quot\;)': return '\"';
          case '\\\\|\'' : return '\\';
          case '\\s' : return "\'";
          case '\\' : return '""';
          // Add more escape sequences as needed
          default: return match[1]; // Remove the backslash
        }
      });
  
      // Step 2: Parse the unescaped JSON
      const parsedData = JSON.parse(unescapedJSON);
  
      return parsedData;
    } catch (error) {
      console.error('Error parsing JSON:', error.message);
      return null; // Handle the error gracefully or throw an exception if necessary
    }
  }
		
	 escapeSpecialChars(str){
    return str
    .replace(/\\'/g, "\'")
    .replace(/\\&#39;/g, "\'")
    .replace(/(&quot\;)/g,"\"")
    .replace(/\\\\|\'/g,"\\")
    .replace(/\\s/g,"\'");
  }

  getListMileages(contactId, month) {
    var arrayList, filterList, original, year;
    const current = new Date();
    year = (month === 'December' && current.getMonth() === 0) ? (current.getFullYear() - 1).toString() : (current.getFullYear()).toString();
    getMileages({
      clickedMonth: month,
      clickedYear: year,
      did: contactId
    })
      .then((data) => {
       // var pattern = /\\\\|\'/g;
       // var resultdata = data.replace(pattern, "\\");
				let resultdata = this.escapeSpecialChars(data);
        arrayList = this.proxyToObject(resultdata);
        original = this.proxyToObject(resultdata);
        if (this.viewTag === "High Risk") {
          filterList = arrayList.filter(function (b) {
            return b.highRiskMileage === true;
          });
          
          this.viewMileages = JSON.stringify(filterList);
        } else {
          filterList = original;
          this.viewMileages = JSON.stringify(filterList);
        }
       // this.viewMileages = arrayList;
      })
      .catch((error) => {
        console.log("getMileage error", error);
      });
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

    return newArray;
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

  refreshDetailSummary(event) {
    this.viewMileages = "";
    this.monthSelected = event.detail;
    this.notificationViewClicked = false;
    this.contactTitle = (this.viewTag === 'High Risk') ? "High Risk " + this.monthSelected + " Mileage For " + this.mileageContactName : 
                        this.mileageContactName + " " + this.monthSelected + " Mileage"
    this.getListMileages(this.contactUserId, event.detail);
  }

  replaceToFirst(array, el){
    let element = JSON.parse(el)
    const index = array.findIndex(x => x.contactid === element.contactid);
    var newArray = []
    if (index !== -1) {
      const items = array.splice(index, 1);
     // array.splice(index, 1);
      newArray.splice(0, 0, ...items);
    }

    return JSON.stringify(newArray)
  }

  getMileage(event) {
    this.viewTag = this.contactTitle;
    let detailList = JSON.parse(event.detail);
    let contactId = detailList.contactid;
    this.contactUserId = contactId;
    this.mileageContactName = detailList.name;
    this.isHomePage = false;
    this.isProfile = false;
    this.mileageApproval = false;
    this.resources = false;
    this.notificationViewClicked = false;
    this.mileageSummary = false;
    this.mileageSummaryView = true;
    this.viewMileages = "";
    window.location.href =
      location.origin +
      location.pathname +
      location.search +
      "#Mileage-Summary-Detail";
    this.toogleStyleElement("Mileage-Summary");
    contactReimMonthList({
      contactId: contactId
    })
      .then((data) => {
        let objList = JSON.parse(data)
        let monthName = this.lastMonthSelected;
       // let monthName = data ? ((objList.length > 1) ? ((objList[0] === this.defaultMonth) ? objList[1] : objList[0]): objList[0]) : "";
        let mileageMonth = data ? this.removeDuplicateValue(this.proxyToObject(data)) : [];
        this.mileageMonthList = this.review(mileageMonth);
        this.monthSelected = monthName ? monthName : "";
        this.contactTitle = (this.viewTag === 'High Risk') ?  "High Risk " + this.monthSelected + " Mileage For " + detailList.name : 
          detailList.name + " " + this.monthSelected + " Mileage";
        this.dashboardTitle = this.contactTitle;
        this.getListMileages(contactId, this.monthSelected);
       
      })
      .catch((error) => {
        console.log("contactReimMonthList error", error);
      });
  }

  showSpinner(event) {
    this.dispatchEvent(
      new CustomEvent("show", {
        detail: event.detail
      })
    );
  }

  hideSpinner(event) {
    this.dispatchEvent(
      new CustomEvent("hide", {
        detail: event.detail
      })
    );
  }

  showLoader(event) {
    this.dispatchEvent(
      new CustomEvent("spinnershow", {
        detail: event.detail
      })
    );
  }

  hideLoader(event) {
    this.dispatchEvent(
      new CustomEvent("spinnerhide", {
        detail: event.detail
      })
    );
  }

  showToast(event) {
    this.dispatchEvent(
      new CustomEvent("toast", {
        detail: event.detail
      })
    );
  }

  handleComplete() {
    var arrayInput, original, filterList;
    this.dispatchEvent(
      new CustomEvent("show", {
        detail: "spinner"
      })
    );
    this.unapproveMileages = "";
    let team = this.isTeamShow === "false" ? false : true;
    getAllDriversLastMonthUnapprovedReimbursementsclone({
      accountId: this._accountId,
      contactId: this._contactId,
      showTeam: team,
      role: this.userRole
    })
      .then((b) => {
        let resultDriver = b.replace(/\\'/g, "'");
        this.userOfDriver = resultDriver;
        this.listOfDriver = resultDriver;
        this.singleUser = true;
        if(resultDriver.length > 0){
          this.listOfDriver =  this.replaceToFirst(JSON.parse(resultDriver), event.detail);
        }else{
          this.listOfDriver = resultDriver;
        }
      })
      .catch((error) => {
        console.log(
          "getAllDriversLastMonthUnapprovedReimbursementsclone error",
          error
        );
        this.dispatchEvent(
          new CustomEvent("hide", {
            detail: "spinner"
          })
        );
      });

    if (this.unapproveReimbursements) {
      this.reimbursement = (this.unapproveReimbursements) ? JSON.parse(this.unapproveReimbursements)?.reimbursementIdList : [];
      getUnapprovedReim({ reimbursements: JSON.stringify(this.reimbursement) }).then(result => { this.commuteMileageList = result; })
      getUnapprovedMileages({
        reimbursementDetails: this.unapproveReimbursements,
        accountId: this._accountId
      })
        .then((data) => {
          this.isProfile = false;
          this.mileageApproval = false;
          let escapedData = data.replace(/\'/g,"\\")
          arrayInput = this.proxyToObject(escapedData);
          original = arrayInput;
          this.driverName = arrayInput.name;
          if (this.nameFilter === "High Risk") {
            filterList = arrayInput.mileagesList.filter(function (b) {
              return b.highRiskMileage === true;
            });
            this.unapproveMileages = JSON.stringify(filterList);
          } else {
            filterList = original.mileagesList;
            this.unapproveMileages = JSON.stringify(filterList);
          }          //this.unapproveMileages = JSON.stringify(arrayInput.mileagesList);
         
          this.dispatchEvent(
            new CustomEvent("hide", {
              detail: "spinner"
            })
          );
        })
        .catch((error) => {
          console.log("getUnapproveMileages error", error);
          this.dispatchEvent(
            new CustomEvent("hide", {
              detail: "spinner"
            })
          );
        });
    }
  }

  refreshSync(){
    var arrayInput, original, filterList;
    this.dispatchEvent(
      new CustomEvent("show", {
        detail: "spinner"
      })
    );
    this.unapproveMileages = "";
    let team = this.isTeamShow === "false" ? false : true;
    getAllDriversLastMonthUnapprovedReimbursementsclone({
      accountId: this._accountId,
      contactId: this._contactId,
      showTeam: team,
      role: this.userRole
    })
      .then((b) => {
        let resultDriver = b.replace(/\\'/g, "'");
        this.listOfDriver = resultDriver;
      })
      .catch((error) => {
        console.log(
          "getAllDriversLastMonthUnapprovedReimbursementsclone error",
          error
        );
        this.dispatchEvent(
          new CustomEvent("hide", {
            detail: "spinner"
          })
        );
      });

    if (this.unapproveReimbursements) {
      this.reimbursement = (this.unapproveReimbursements) ? JSON.parse(this.unapproveReimbursements)?.reimbursementIdList : [];
      getUnapprovedReim({ reimbursements: JSON.stringify(this.reimbursement) }).then(result => { this.commuteMileageList = result; })
      getUnapprovedMileages({
        reimbursementDetails: this.unapproveReimbursements,
        accountId: this._accountId
      })
        .then((data) => {
          try{
            let escapedData = data.replace(/\'/g,"\\")
            this.isProfile = false;
            this.mileageApproval = false;
            arrayInput = this.proxyToObject(escapedData);
            original = arrayInput;
            this.driverName = arrayInput.name;
            if (this.nameFilter === "High Risk") {
              filterList = arrayInput.mileagesList.filter(function (b) {
                return b.highRiskMileage === true;
              });
              this.unapproveMileages = JSON.stringify(filterList);
            } else {
              filterList = original.mileagesList;
              this.unapproveMileages = JSON.stringify(filterList);
            }
            //this.unapproveMileages = JSON.stringify(arrayInput.mileagesList);
            this.dispatchEvent(
              new CustomEvent("hide", {
                detail: "spinner"
              })
            );
            this.dispatchEvent(
              new CustomEvent("toast", {
                detail: {
                  type: "success",
                  message: 'Mileage has been synced.'
                } 
              })
            );
          }
          catch(e){
            console.log("getUnapproveMileages--", e.message)
          }
        })
        .catch((error) => {
          console.log("getUnapproveMileages error", error.message);
          this.dispatchEvent(
            new CustomEvent("hide", {
              detail: "spinner"
            })
          );
        });
    }
  }

  handleSyncDone(){
    clearTimeout(this.timeoutId); // no-op if invalid id
    this.timeoutId = setTimeout(this.refreshSync.bind(this), 2000);
  }

  getAllReimbursement(boolean, m) {
      this.listOfReimbursement = "";
      this.summaryColumn = [
        {
          id: 1,
          name: "Name",
          colName: "name",
          colType: "String",
          arrUp: false,
          arrDown: false
        },
        {
          id: 2,
          name: "Approved",
          colName: "approvedMileages",
          colType: "Decimal",
          arrUp: false,
          arrDown: false
        },
        {
          id: 3,
          name: "Flagged",
          colName: "rejectedMileages",
          colType: "Decimal",
          arrUp: false,
          arrDown: false
        },
        {
          id: 4,
          name: "Total Mileage",
          colName: "totalMileages",
          colType: "Decimal",
          arrUp: false,
          arrDown: false
        }
      ];
      this.summaryKeyFields = [
        "name",
        "approvedMileages",
        "rejectedMileages",
        "totalMileages"
      ];
      getLastMonthReimbursements({
        accountId: this._accountId,
        contactId: this._contactId,
        showTeam: boolean,
        month: m,
        role: this.userRole
      })
      .then((b) => {
        let driverResult = b.replace(/\\'/g, "'");
        this.listOfReimbursement = driverResult;
      })
      .catch((error) => {
        console.log("getAllDriversLastMonthReimbursements error", error);
      });
  }

  getAllUnapprove(boolean) {
    getAllDriversLastMonthUnapprovedReimbursementsclone({
      accountId: this._accountId,
      contactId: this._contactId,
      showTeam: boolean,
      role: this.userRole
    })
      .then((b) => {
        let resultDriver = b.replace(/\\'/g, "'");
        this.listOfDriver = resultDriver;
      })
      .catch((error) => {
        console.log(
          "getAllDriversLastMonthUnapprovedReimbursementsclone error",
          error
        );
      });
  }



  getDriverList(){
    var parsedaata, driverlist = [] ;
      dropdownDriverName({accountId: this._accountId,managerId: this._contactId,role:this.userRole })
      .then((data) => {
        parsedaata = JSON.parse(data)
        let i = 2;
        for(let key in parsedaata) {
          if (Object.prototype.hasOwnProperty.call(parsedaata, key)) {
            i = i+1;
            driverlist.push({Id: i,label:`${parsedaata[key]}`,value:key})
          }
        }
        this.driverdetail =  JSON.parse(JSON.stringify(this.removeDuplicate(driverlist , it => it.label)));
       
      })
      .catch((error) => {
        console.log(error);
      })
  }
  getStatus(){
    fetchLookUpValues({
      accId:this._accountId,
      adminId:'',
      accField:'EmployeeReimbursement__r.Contact_Id__r.AccountId',
      searchKey: 'Trip_Status__c',
      idOfDriver: '',
      fieldName: 'Trip_Status__c',
      ObjectName: 'Employee_Mileage__c',
      keyField: 'Id',
      whereField: '',
      isActive: ''
    }) 
    .then((result) => {
      let data = JSON.parse( JSON.stringify( result ) ).sort( ( a, b ) => {
        a = a.Trip_Status__c ? a.Trip_Status__c.toLowerCase() : ''; // Handle null values
        b = b.Trip_Status__c ? b.Trip_Status__c.toLowerCase() : '';
        return a > b ? 1 : -1;
      });;
      let i=0;
      data.forEach(element => {
        if(element.Trip_Status__c !== undefined){
          i = i + 1;
          this.Statuspicklist.push({Id: i ,label:element.Trip_Status__c,value:element.Trip_Status__c})
        }
      });
      this.Statusoptions = JSON.parse(JSON.stringify(this.removeDuplicate(this.Statuspicklist , it => it.value)));
    })
    .catch((error) => {
      console.log(error)
    })
  }

  removeDuplicate(data , key){
    return [
      ... new Map(
        data.map(x => [key(x) , x])
      ).values()
    ]
  }

  getAccountDetails() {
    accountDetails({accountId: this._accountId})
        .then(result => {
          if(result == 'Failure') {
            console.log("Fail to get account details.");
            this.accName = '';
          } else {
            this.accName = result;
          }
        })
        .catch(error => {
            console.log("Error while getting account details : " + error);
            this.accName = '';
        });
  }

  getAccountMonthList() {
    accountMonthList({
      accountId: this._accountId
    }).then((data) => {
      if (data) {
        let mileageAccount = data ? this.removeDuplicateValue(this.proxyToObject(data)) : [];
        this.mileageAccountList = this.review(mileageAccount);
      }
      // this.mileageAccountList = JSON.parse(this.mileageAccountList)
    });
  }

  handleToastMessage(event){
    this.dispatchEvent(
      new CustomEvent("toast", {
        detail: {
          type: event.detail.errormsg,
          message:event.detail.message
        } 
      })
    );
  }

  getAllTeam(boolean) {
    myTeamDetails({
      managerId: this._contactId,
      accountId: this._accountId,
      showteam: boolean,
      role: this.userRole
    })
      .then((data) => {
        let result = data.replace(/\\'/g, "'");
        this.myTeamList = result;
      })
      .catch((error) => {
        console.log("myTeamDetails error", error);
      });
  }

  redirectToDriverView(event){
    this.notificationViewClicked = false;
    this.isDashboard = (event.detail.target) ? true : false;
    let contactDetail = (event.detail.message) ? JSON.parse(event.detail.message) : JSON.parse(event.detail)
    this.idContact = contactDetail.id;
    this.driverProfileName = contactDetail.name;
    this.contactTitle = contactDetail.name;
    document.title = "Team";
    window.location.href = location.origin + location.pathname + location.search + '#Driver-view'
  }

  redirectToUser(event){
    this.notificationViewClicked = false;
    let contactDetail = JSON.parse(event.detail)
    this.idContact = contactDetail.id;
    this.driverProfileName = contactDetail.name;
    this.contactTitle = contactDetail.name;
    document.title = "Team";
    window.location.href = location.origin + location.pathname + location.search + '#Driver-view'
    this.toogleStyleElement("Team");
  }

  redirectToMyTeam(event){
    if(event.detail !== 'Dashboard'){
    this.isProfile = false;
    this.mileageApproval = false;
    this.resources = false;
    this.mileageView = false;
    this.notificationViewClicked = false;
    this.mileageSummary = false;
    this.mileageSummaryView = false;
    this.teamList = true;
    this.showDriverView = false;
    this.isDashboard = false;
    this.contactTitle = "My Team";
    this.isHomePage = true;
      window.location.href =
        location.origin +
        location.pathname +
        location.search +
        "#Team";
      this.toogleStyleElement("Team");
    }else{
      document.title = "Admin Dashboard";
      let url =  location.origin + location.pathname + location.search
      this.contactTitle = this.userName;
      this.notificationModal = false;
      this.notificationViewClicked = false;
      this.mileageView = false;
      this.showDriverView = false;
      this.showUsers = false;
      this.showTools = false;
      this.showReports = false;
      this.reportDetail = false;
      this.resources = false;
      this.isHomePage = false;
      this.isProfile = true;
      this.isDashboard = false;
      this.toogleStyleElement("");
      this.modifyUrl(document.title, url)
    }
  }


  resetStateManagement(){
    window.history.go(window.history.length - window.history.length - 1);
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

  showNavFeature(){
    this.headerModalText = "New Feature";
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

  handleMileageApproval(){
    document.title = "Mileage Approval";
    this.contactTitle = "Unapproved Mileage";
    this.isHomePage = true;
    this.notificationModal = false;
    this.isProfile = false;
    this.mileageApproval = true;
    this.teamList = false;
    this.mileageView = false;
    this.mileageSummary = false;
    this.mileageSummaryView = false;
    this.showDriverView = false;
    this.resources = false;
    this.notificationViewClicked = false;
  }

  handleMileageFlag(state){
    if (state === "reload") {
      this.resetStateManagement();
    } else {
      document.title = "Mileage Approval";
      this.contactTitle = "Unapproved Mileage";
      this.isHomePage = true;
      this.notificationModal = false;
      this.isProfile = false;
      this.mileageApproval = false;
      this.resources = false;
      this.teamList = false;
      this.mileageView = false;
      this.mileageSummary = false;
      this.notificationViewClicked = false;
      this.mileageSummaryView = false;
      this.showDriverView = false;
    }
  }

  handleTeam(){
      document.title = "Team";
      this.contactTitle = "My Team";
      this.isHomePage = true;
      this.notificationModal = false;
      this.notificationViewClicked = false;
      this.isProfile = false;
      this.mileageApproval = false;
      this.resources = false;
      this.mileageView = false;
      this.mileageSummary = false;
      this.mileageSummaryView = false;
      this.teamList = true;
      this.showDriverView = false;
  }

  handleMileageSummary(){
    document.title = "Mileage Summary";
    this.contactTitle = "Mileage Summary";
    this.isHomePage = true;
    this.notificationModal = false;
    this.notificationViewClicked = false;
    this.isProfile = false;
    this.mileageApproval = false;
    this.resources = false;
    this.teamList = false;
    this.mileageView = false;
    this.mileageSummaryView = false;
    this.mileageSummary = true;
    this.showDriverView = false;
  }

  handleSummaryDetail(state){
    if (state === "reload") {
      this.resetStateManagement();
    } else {
      document.title = "Mileage Summary";
      this.contactTitle = this.dashboardTitle;
      this.isHomePage = true;
      this.notificationModal = false;
      this.notificationViewClicked = false;
      this.isProfile = false;
      this.mileageApproval = false;
      this.resources = false;
      this.teamList = false;
      this.mileageView = false;
      this.mileageSummary = false;
      this.mileageSummaryView = true;
      this.showDriverView = false;
    }
  }

  handleHighRisk(){
    document.title = "High Risk";
    this.contactTitle = "High Risk";
    this.isHomePage = true;
    this.notificationModal = false;
    this.notificationViewClicked = false;
    this.isProfile = false;
    this.mileageView = false;
    this.mileageApproval = false;
    this.resources = false;
    this.teamList = false;
    this.mileageSummary = true;
    this.mileageSummaryView = false;
    this.showDriverView = false;
  }

  handleHighMileage(){
    document.title = "High Mileage";
    this.contactTitle = "High Mileage";
    this.isHomePage = true;
    this.notificationModal = false;
    this.notificationViewClicked = false;
    this.isProfile = false;
    this.mileageApproval = false;
    this.resources = false;
    this.mileageView = false;
    this.teamList = false;
    this.mileageSummary = true;
    this.mileageSummaryView = false;
    this.showDriverView = false;
  }

  handleMileagePreview(){
        document.title = "Mileage Preview";
        this.contactTitle = "Mileage Preview";
        this.notificationViewClicked = false;
        this.notificationModal = false;
        this.isHomePage = true;
        this.isProfile = false;
        this.mileageApproval = false;
        this.resources = false;
        this.teamList = false;
        this.showDriverView = false;
        this.mileageSummary = false;
        this.mileageSummaryView = false;
        this.mileageView = true;
  }

  handleNotificationView(){
    this.notificationViewClicked = !this.notificationViewClicked;
    this.notificationModal = !this.notificationModal;
    this.isHomePage = this.isHomePage ? true : false;
    this.mileageApproval = this.mileageApproval ? true : false;
    this.isGeneral = true;
    this.debounce(() => {
      this.notificationViewClicked = false
    }, 100)(); 
    this.teamList = this.teamList ? true : false;
    this.mileageSummary = this.mileageSummary ? true : false;
    this.mileageSummaryView = this.mileageSummaryView ? true : false;
    this.mileageView = this.mileageView ? true : false;
    this.showDriverView = this.mileageView ? true : false;
    this.resources = this.resources ? true : false;
    this.myProfile = this.myProfile ? true : false;
    if (this.showTools) {
      if (this.template.querySelector("c-user-tools")) {
        this.template.querySelector("c-user-tools").closeChildDialog();
      }
    }

    this.debounce(() => { this.template.querySelector("c-dashboard-profile-header").styleLink(""); }, 10)();
  }

  handleDriverMileage(state){
    if (state === "reload") {
      this.resetStateManagement();
    } else {
      document.title = "Team";
      this.isHomePage = true;
      this.notificationViewClicked = false;
      this.notificationModal = false;
      this.isProfile = false;
      this.mileageApproval = false;
      this.resources = false;
      this.teamList = false;
      this.mileageView = false;
      this.mileageSummary = false;
      this.mileageSummaryView = false;
      this.showDriverView = true;
      this.contactTitle = this.driverProfileName;
    }
  }

  handleTraining(){
    document.title = "Videos/Training";
    this.contactTitle = "Videos/Training";
    this.myProfile = false;
    this.notificationViewClicked = false;
    this.notificationModal = false;
    this.isProfile = false;
    this.mileageApproval = false;
    this.resources = false;
    this.teamList = false;
    this.mileageView = false;
    this.mileageSummary = false;
    this.mileageSummaryView = false;
    this.showDriverView = false;
    this.isHomePage = true;
    this.resources = true;
    this.debounce(() => { this.template.querySelector("c-user-resource").reset(); }, 10)();
  }

  handleDefaultState(){
    document.title = "Manager Dashboard";
    this.contactTitle = this.userName;
    this.notificationModal = false;
    this.notificationViewClicked = false;
    this.mileageView = false;
    this.showDriverView = false;
    this.resources = false;
    this.isHomePage = false;
    this.isProfile = true;
  }


  popStateMessage = (event) => {
    const address = new URL(location).hash;
    const state = window.performance.getEntriesByType("navigation")[0].type;
    const showteam = new URL(location).searchParams.get("showteam");
    const v = showteam === "false" ? false : true;
    switch (address) {
      case "#Mileage-Approval":
        this.handleMileageApproval();
        this.getAllUnapprove(v);
        this.toogleStyleElement("Mileage-Approval");
        break;
      case "#Mileage-Approval-Flag":
        this.handleMileageFlag(state);
        this.toogleStyleElement("Mileage-Approval");
        break;
      case "#Team":
          this.handleTeam();
          this.getAllTeam(v);
          this.toogleStyleElement("Team");
          break;
      case "#Mileage-Summary":
          this.handleMileageSummary();
          this.getAccountMonthList();
          this.getAllReimbursement(v, this.lastMonthSelected);
          this.toogleStyleElement("Mileage-Summary");
          break;
      case "#Mileage-Summary-Detail":
          this.handleSummaryDetail(state);
          this.getAccountMonthList();
          this.getAllReimbursement(v, this.lastMonthSelected);
          this.toogleStyleElement("Mileage-Summary");
          break;
      case "#Mileage-Summary-Risk":
          this.handleHighRisk();
          this.getAccountMonthList();
          this.getMileageHighRisk(v, false, this.lastMonthSelected);
          this.toogleStyleElement("Mileage-Summary");
          break;
      case "#Mileage-Summary-High":
          this.handleHighMileage();
          this.getAccountMonthList();
          this.getMileageHighRisk(v, true, this.lastMonthSelected);
          this.toogleStyleElement("Mileage-Summary");
          break;
      case "#Mileage-Preview":
          this.handleMileagePreview();
          this.getAccountMonthList();
          this.getDriverList();
          this.getStatus();
          this.toogleStyleElement("Mileage-Preview");
          break;
      case "#Notifications":
        this.handleNotificationView();
        break;
      case "#Driver-view":
        this.handleDriverMileage(state);
        this.toogleStyleElement("Team");
        break;
      case "#Mileage":
        this.handleDriverMileage(state);
        this.toogleStyleElement("Team");
        break;
      case "#Videos":
        this.handleTraining();
        this.toogleStyleElement("Videos");
        break;
      default:
        this.handleDefaultState();
        this.toogleStyleElement("");
    }

    this.template
      .querySelector("c-dashboard-profile-header")
      .setSource(this.isHomePage);
  
  };

   renderedCallback(){
    if (this.calendarJsInitialised) {
      return;
    }

    const buttonItem = this.template.querySelectorAll(".btn-toggle");

    buttonItem.forEach((el) =>
      el.addEventListener("click", () => {
        buttonItem.forEach((el2) => el2.classList.remove("is-active"));
        el.classList.add("is-active");
      })
    );
    
    if(this.mileageView){
      loadScript(this, jQueryMinified)
      .then(() => {
          Promise.all([
            loadStyle(this, datepicker + "/minifiedCustomDP.css"),
            loadStyle(this, datepicker + "/datepicker.css"),
            loadStyle(this, customMinifiedDP),
            loadScript(this, datepicker + '/datepicker.js')
          ]).then(() => {
              this.calendarJsInitialised = true;
            })
            .catch((error) => {
              console.error(error);
            });
      })
      .catch(error => {
        console.log('jquery not loaded ' + error )
      })
    }
  }

  backToDashboard(){
    document.title = "Admin Dashboard";
    let url =  location.origin + location.pathname + location.search
    this.contactTitle = this.userName;
    this.notificationModal = false;
    this.notificationViewClicked = false;
    this.mileageView = false;
    this.showDriverView = false;
    this.showUsers = false;
    this.showTools = false;
    this.showReports = false;
    this.reportDetail = false;
    this.resources = false;
    this.isHomePage = false;
    this.isProfile = true;
    this.isDashboard = false;
    this.singleUser = false;
    this.toogleStyleElement("");
    this.modifyUrl(document.title, url)
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


  handleOutsideClick = (event) => {
    if(!this.notificationViewClicked){
        this.closeNotification();
    }   
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
    /*Get logged in user id */
    const idParamValue = this.getUrlParamValue(window.location.href, "id");
    /*Get logged in user's account id */
    const aidParamValue = this.getUrlParamValue(window.location.href, "accid");
    const showIsTeam = this.getUrlParamValue(window.location.href, "showteam");
   // const manager = this.getUrlParamValue(window.location.href, 'managerid');
    const current = new Date();
    this.navFeatureLink = this.customSetting.Nav_Feature_For_Manager__c;
    this.yearList = this.getUpdatedYear();
    current.setMonth(current.getMonth()-1);
    const previousMonth = current.toLocaleString('default', { month: 'long' });
    this.lastMonth = previousMonth;
    this.lastMonthSelected = this.lastMonth;
    this._contactId = idParamValue;
    this._accountId = aidParamValue;
    this.isTeamShow = showIsTeam;
    const debouncedFunction = this.debounce(() => {
      this.dispatchEvent(
        new CustomEvent("hide", {
          detail: "spinner",
        })
      )
    }, 0); 
    
    debouncedFunction();
    if(this.loginCount > 0 && this.loginCount <= 5 && location.hash === ''){
      this.debounce(() => { this.showNavFeature() }, 0)();
    }
    this.getAccountDetails();
    this.getAccountMonthList();
    this.getDriverList();
    this.getStatus();
    this.contactTitle = this.userName;
    this.isProfile = true;
    window.addEventListener('keydown', this.handleKeyDown);
    window.addEventListener('click', this._handler = this.handleOutsideClick.bind(this));
    window.addEventListener("popstate", this.popStateMessage);

    if (window.location.hash !== "") {
      this.debounce(() => {   this.popStateMessage(); }, 0)();
    }

    this.getContactNotification();
  }
}