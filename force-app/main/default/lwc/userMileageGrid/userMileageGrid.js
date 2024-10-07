/* eslint-disable @lwc/lwc/no-api-reassignments */
/* eslint-disable no-useless-escape */
/* eslint-disable no-restricted-globals */
/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, api, track } from "lwc";
import resourceImage from "@salesforce/resourceUrl/mBurseCss";
import approveMileagesClone from "@salesforce/apex/ManagerDashboardController.approveMileagesClone";
import CheckBatchStatus from "@salesforce/apex/ManagerDashboardController.CheckBatchStatus";
import UpdatedReimList from "@salesforce/apex/ManagerDashboardController.UpdatedReimList";
import MassSyncTripsForBiweek from "@salesforce/apex/ManagerDashboardController.MassSyncTripsForBiweek";
import MassSyncTrips from "@salesforce/apex/ManagerDashboardController.MassSyncTrips";
import { toastEvents } from "c/utils";
export default class UserMileageGrid extends LightningElement {
  @api contactList;
  @api contactInfo;
  @api accountId;
  @api contactId;
  @api showTeam;
  @api monthTeamList;
  @api filter;
  @api role;
  @api isAccountBiweek;
  @api singleUser;
  @api userList;
  sortable = true;
  modalOpen = false;
  isRecord = false;
  endProcess = false;
  islockdate = false;
  _flag = false;
  isFalse = false;
  typeFilter = "";
  _value = ""
  syStartDate = "";
  syEndDate = "";
  syncMonth = "";
  tripStatus = 'U';
  activity = 'Business';
  unapprovereimbursements = [];
  headerModalText = "";
  modalClass = "";
  headerClass = "";
  subheaderClass = "";
  modalContent = "";
  styleHeader = "";
  styleClosebtn = "";
  classToTable = "fixed-container";
  noMessage = 'There is no data available';
  originalSelectList = [];
  allReimbursementList = [];
  selectList = [
    {
      id: 1,
      label: "This Page",
      value: "This Page"
    },
    {
      id: 2,
      label: "All Pages",
      value: "All Pages"
    },
    {
      id: 3,
      label: "None",
      value: "None"
    }
  ];

  typeList = [
    {
      id: 1,
      label: "High Risk",
      value: "High Risk"
    },
    {
      id: 2,
      label: "All Trips",
      value: "All Trips"
    }
  ];

  allTeam = [
    {
      id: 1,
      label: "My Team",
      value: "My Team"
    },
    {
      id: 2,
      label: "Company",
      value: "Company"
    }
  ];

  teamList = [
    {
      id: 1,
      label: "My Team",
      value: "My Team"
    },
    {
      id: 2,
      label: "Company",
      value: "Company"
    }
  ];

  @track modelList = [];
  @track highRiskList = [];
  @track renderDriverList = [];
  searchmodelList = [];
  originalModelList;
  modalKeyFields;
  modalListColumn;
  @track myTeamReimbursement = [];

  isSubmitVisible = false;
  isScrollable = false;
  isSearchEnable = true;
  isSort = true;
  isCheckbox = false;
  tripColumn = [
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
      name: "Unapproved",
      colName: "totalMileages",
      colType: "Decimal",
      arrUp: false,
      arrDown: false
    },
    {
      id: 3,
      name: "Approved",
      colName: "approvedMileages",
      colType: "Decimal",
      arrUp: false,
      arrDown: false
    },
    {
      id: 4,
      name: "Total",
      colName: "TotalReimMileages",
      colType: "Decimal",
      arrUp: false,
      arrDown: false
    }
  ];
  tripKeyFields = ["name", "totalMileages","approvedMileages","TotalReimMileages"];
  tripListColumn = [
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
      name: "Unapproved",
      colName: "totalMileages",
      colType: "Decimal",
      arrUp: false,
      arrDown: false
    },
    {
      id: 3,
      name: "Approved",
      colName: "approvedMileages",
      colType: "Decimal",
      arrUp: false,
      arrDown: false
    },
    {
      id: 4,
      name: "Flagged",
      colName: "rejectedMileges",
      colType: "Decimal",
      arrUp: false,
      arrDown: false
    },
    {
      id: 5,
      name: "Total",
      colName: "TotalReimMileages",
      colType: "Decimal",
      arrUp: false,
      arrDown: false
    }
  ];
  tripListKeyFields = ["name", "totalMileages", "approvedMileages","rejectedMileges","TotalReimMileages"];
  searchIcon = resourceImage + "/mburse/assets/mBurse-Icons/Vector.png";
  checkMark = resourceImage + "/mburse/assets/mBurse-Icons/check.png";

  getUrlParamValue(url, key) {
    return new URL(url).searchParams.get(key);
  }

  proxyToObject(e) {
    return JSON.parse(e);
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

  sortByNumber(employees, colName){
    employees.sort((a, b) => {
      // if(typeof a[colName] === 'number' && typeof b[colName] === 'number'){
      //   return b[colName] - a[colName];
      // }else{
       
      return b[colName] - a[colName];
      //}
    });

    return employees;
  }

  sort(employees, colName) {
    employees.sort((a, b) => {
      // if(typeof a[colName] === 'number' && typeof b[colName] === 'number'){
      //   return b[colName] - a[colName];
      // }else{
        let fa = a[colName] == null || a[colName] === "" ? "" : a[colName].toLowerCase(),
            fb = b[colName] == null || b[colName] === "" ? "" : b[colName].toLowerCase();

        if (fa < fb) {
          return -1;
        }
        if (fa > fb) {
          return 1;
        }
        return 0;
      //}
    });

    return employees;
  }

  numberWithCommas(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
  }

  dynamicBinding(data, keyFields) {
    data.forEach((element) => {
      let model = [];
      for (const key in element) {
        if (Object.prototype.hasOwnProperty.call(element, key)) {
          let singleValue = {};
          if (keyFields.includes(key) !== false) {
            singleValue.key = key;
            singleValue.value = (key === "totalMileages" ||
            key === "rejectedMileges" ||
            key === "totalHighRiskMileages" ||
            key === "highRiskTotalApproved" || 
            key === "highRiskTotalPending" ||
            key === "highRiskTotalRejected" ||
            key === "TotalReimMileages" ||
            key === "approvedMileages") ? (element[key] === '0.00' || element[key] === '0.0' || element[key] === 0) ? '' : element[key] : element[key];
            singleValue.uId = element.contactid;
            singleValue.onlyLink = false;
            singleValue.isProcess = this.endProcess ? true : false;
            singleValue.isLink = key === "name" ? true : false;
            singleValue.twoDecimal =
              key === "totalMileages" ||
              key === "rejectedMileges" ||
              key === "totalHighRiskMileages" ||
              key === "highRiskTotalApproved" || 
              key === "highRiskTotalPending" ||
              key === "highRiskTotalRejected" ||
              key === "TotalReimMileages" ||
              key === "approvedMileages"
                ? true
                : false;
            model.push(singleValue);
          }
        }
      }
      element.id = element.reimbursementid;
      element.isApproval = true;
      element.isDisabled  = element?.contactid === this.contactId ? true : false;
      if(element.isDisabled){
        element.titleText = 'You can’t self approve mileage.'
      }
      if(this.typeFilter === 'High Risk'){
        element.showCheckbox = element.highRiskTotalPending > 0 && (element.status === "Pending" || element.status === "") ? true : false;
      }else{
        element.showCheckbox =
        element.totalMileages > "0.00" &&
        (element.status === "Pending" || element.status === "")
          ? true
          : false;
      }
      element.keyFields = this.mapOrder(model, keyFields, "key");
    });
  }

  @api singleUserList(){
     this.singleUser = true
  }

  resetMileage(list) {
    var count = 0;
    let element = this.originalModelList;
    let type = list;
    this.typeFilter = type;
    console.log("REset Mileage", list);
    if (type === "High Risk") {
      this.highRiskList = element.filter(function (b) {
        return b.totalHighRiskMileages !== 0;
      });
      this.tripColumn[1].colName = "highRiskTotalPending";
      this.tripColumn[2].colName = "highRiskTotalApproved";
      this.tripColumn[3].colName = "totalHighRiskMileages";

      this.tripListColumn[1].colName = "highRiskTotalPending";
      this.tripListColumn[2].colName = "highRiskTotalApproved";
      this.tripListColumn[3].colName = "highRiskTotalRejected";
      this.tripListColumn[4].colName = "totalHighRiskMileages";

      this.tripKeyFields[1] = "highRiskTotalPending";
      this.tripKeyFields[2] = "highRiskTotalApproved";
      this.tripKeyFields[3] = "totalHighRiskMileages";

      this.tripListKeyFields[1] = "highRiskTotalPending";
      this.tripListKeyFields[2] = "highRiskTotalApproved";
      this.tripListKeyFields[3] = "highRiskTotalRejected";
      this.tripListKeyFields[4] = "totalHighRiskMileages";
      this.highRiskList.forEach((el) => {
        if (el.highRiskTotalRejected > "0.00") {
          count++;
        }
      });
      this.modelList = this.highRiskList;

      if (count > 0) {
        this.modalListColumn = this.tripListColumn;
        this.modalKeyFields = this.tripListKeyFields;
      } else {
        this.modalListColumn = this.tripColumn;
        this.modalKeyFields = this.tripKeyFields;
      }

      this.dynamicBinding(this.modelList, this.modalKeyFields);
      this.modelList = this.sort(this.modelList, "name");
      this.template
        .querySelector("c-user-preview-table")
        .viewData(this.modelList, null, true);
    } else {
      this.tripColumn[1].colName = "totalMileages";
      this.tripColumn[2].colName = "approvedMileages";
      this.tripColumn[3].colName = "TotalReimMileages";

      this.tripListColumn[1].colName = "totalMileages";
      this.tripListColumn[2].colName = "approvedMileages";
      this.tripListColumn[3].colName = "rejectedMileges";
      this.tripListColumn[4].colName = "TotalReimMileages";

      this.tripKeyFields[1] = "totalMileages";
      this.tripKeyFields[2] = "approvedMileages";
      this.tripKeyFields[3] = "TotalReimMileages";

      this.tripListKeyFields[1] = "totalMileages";
      this.tripListKeyFields[2] = "approvedMileages";
      this.tripListKeyFields[3] = "rejectedMileges";
      this.tripListKeyFields[4] = "TotalReimMileages";
      this.modelList = this.originalModelList;
      this.modelList.forEach((el) => {
        if (el.rejectedMileges > "0.00") {
          count++;
        }
      });

      if (count > 0) {
        this.modalListColumn = this.tripListColumn;
        this.modalKeyFields = this.tripListKeyFields;
      } else {
        this.modalListColumn = this.tripColumn;
        this.modalKeyFields = this.tripKeyFields;
      }

      this.dynamicBinding(this.modelList, this.modalKeyFields);
      this.modelList = this.sort(this.modelList, "name");
      this.template
        .querySelector("c-user-preview-table")
        .viewData(this.modelList, 'name', true);
    }

    console.log(
      JSON.stringify(this.highRiskList),
      type,
      this.originalModelList
    );
  }

  handleChange(event) {
    var pageItem = { id: 1, label: "This Page", value: "This Page" };
    let _typeList = this.typeFilter;
    this._value = event.target.value;
    this.isSearchEnable = this._value === "" ? true : false;
    this.filter = _typeList;
    this.template
      .querySelector("c-user-preview-table")
      .searchByKey(this._value);
    if (this.selectList.length < 2) {
      this.selectList.splice(0, 0, pageItem);
    }
    //console.log("event-->", JSON.parse(event.detail), JSON.parse(event.detail).length);
  }

  handleClearInput(){
    this._value = "";
    this.isSearchEnable = this._value === "" ? true : false;
    this.template
    .querySelector("c-user-preview-table")
    .searchByKey(this._value);
  }

  handleSearchEvent(event) {
    this.searchmodelList = JSON.parse(event.detail);
    if (this.searchmodelList.search === false) {
      this.searchmodelList.content = [];
    }
    //console.log("event-->", JSON.parse(event.detail), JSON.parse(event.detail).length);
  }

  renderList(event) {
    var arrayElement = [],
      originalItem = [],
      item = { id: 2, label: "All Pages", value: "All Pages" };
    arrayElement = this.selectList;
    originalItem = this.selectList;
    let eventAt = (event.detail) ? event.detail : event;
    if (eventAt < 2) {
      this.selectList = arrayElement.filter(function (a) {
        return a.value !== "All Pages";
      });
    } else if (this.searchmodelList.search === true) {
      this.selectList = arrayElement.filter(function (a) {
        return a.value !== "All Pages";
      });
    } else {
      if (this.selectList.length <= 2) {
        this.selectList.splice(1, 0, item);
      } else {
        this.selectList = originalItem;
      }
    }
  }

  /** Handler if checkbox available in UI */

  removeDuplicateValue(myArray) {
    var newArray = [];
    myArray.forEach((value) => {
      var exists = false;
      newArray.forEach((val2) => {
        if (value === val2) {
          exists = true;
        }
      });
      if (exists === false && value !== "") {
        newArray.push(value);
      }
    });
    return newArray;
  }

  handlePageChange(event) {
    var listElement = [],
      pageItem = { id: 1, label: "This Page", value: "This Page" };
    listElement = this.selectList;
    let userInput = event.detail.value;
    let boolean =
      userInput === "All Pages" ? true : userInput === "None" ? false : false;
    if (userInput === "This Page") {
      this.approvePerPage();
      this.modelList = this.template
        .querySelector("c-user-preview-table")
        .returnList();
    } else {
      if (userInput === "All Pages") {
        this.selectList = listElement.filter(function (a) {
          return a.value !== "This Page";
        });
      } else {
        let isValid = this.selectList.some(
          (list) => list.value === pageItem.value
        );
        if (this.selectList.length === 2 && !this.searchmodelList.search) {
          if (!isValid) this.selectList.splice(0, 0, pageItem);
        }
      }
      this.approveAllHandler(boolean);
      this.modelList = this.template
        .querySelector("c-user-preview-table")
        .returnList();
    }
    //console.log("Select--->", JSON.stringify(event.detail))
  }

  handleTeamChange(event) {
    let teamInput = event.detail.value;
    if (teamInput) {
      if (teamInput === "My Team") {
        let urlRedirect =
          location.origin +
          location.pathname +
          "?accid=" +
          this.getUrlParamValue(window.location.href, "accid") +
          "&id=" +
          this.getUrlParamValue(window.location.href, "id") +
          "&showteam=false" +
          location.hash;
        location.assign(urlRedirect);
      } else {
        let urlRedirect =
          location.origin +
          location.pathname +
          "?accid=" +
          this.getUrlParamValue(window.location.href, "accid") +
          "&id=" +
          this.getUrlParamValue(window.location.href, "id") +
          "&showteam=true" +
          location.hash;
        location.assign(urlRedirect);
      }
    }
  }

  handleTypeChange(event) {
    if(this.endProcess){
      this.template.querySelector(
        'c-dropdown-select[data-id="typeSelect"]'
      ).selection();
      this.showModal()
    }else{
      let element = this.originalModelList;
      let type = event.detail ? event.detail.value : event;
      this.typeFilter = type;
      this.filter = "";
      this.isSubmitVisible = false;
      //this.isSort = false;
      this.resetViewList(element);
      if (this.typeFilter === "All Trips") {
        if (
          this.template.querySelector('c-dropdown-select[data-id="typeSelect"]')
        ) {
          this.template.querySelector(
            'c-dropdown-select[data-id="typeSelect"]'
          ).selectedValue = "All Trips";
          this.template
            .querySelector('c-dropdown-select[data-id="typeSelect"]')
            .toggleSelected("All Trips");
          this.template
            .querySelector('c-dropdown-select[data-id="typeSelect"]')
            .removeHidden("High Risk");
        }
      } else {
        if (
          this.template.querySelector('c-dropdown-select[data-id="typeSelect"]')
        ) {
         
          this.template.querySelector(
            'c-dropdown-select[data-id="typeSelect"]'
          ).selectedValue = "High Risk";
          this.template
            .querySelector('c-dropdown-select[data-id="typeSelect"]')
            .toggleSelected("High Risk");
          this.template
            .querySelector('c-dropdown-select[data-id="typeSelect"]')
            .removeHidden("All Trips");
        }
      }

      // console.log(
      //   JSON.stringify(this.highRiskList),
      //   type,
      //   this.originalModelList
      // );
    }
  }

  checkUncheckRow(id, value, table) {
    var _tbody = table;
    //console.log("inside check", _tbody)
    for (let i = 0; i < _tbody.length; i++) {
      _tbody[i].isSelected = _tbody[i].reimbursementid === id ? value : _tbody[i].isSelected;
    }

    this.template
    .querySelector("c-user-preview-table")
    .updateView(value, id);
    this.template
      .querySelector("c-user-preview-table")
      .resetView(_tbody, "contactid");
      /*this.template
      .querySelector("c-user-preview-table")
      .defaultSort('totalMileages', 'Decimal', 'asc');*/
    // this.template
    //   .querySelector("c-user-preview-table")
    //   .defaultSort("name", "String", "desc");
    //console.log("Gotooo---",  this.template.querySelector('c-user-preview-table').returnList())
    return true;
  }

  approvePerPage() {
    var data = [],
      count = 0;
    this._flag = true;
    //  view = this.modelList.filter(obj => obj.isSelected === true);
    //  if(this.searchmodelList.search){
    // console.log("inside search model")
    //  data =  this.searchmodelList.content;
    //}else{
    data = this.template.querySelector("c-user-preview-table").returnPageList();
    //}
    for (let i = 0; i < data.length; i++) {
      if(data[i].contactid !== this.contactId){
        if (data[i].totalMileages > "0.00") {
          data[i].isSelected = this._flag;
        }
      }
    }
    //   console.log("approve per page All---", data, data.length)
    this.template
      .querySelector("c-user-preview-table")
      .resetPageView(data, "contactid");
    this.template
      .querySelector("c-user-preview-table")
      .defaultSort('totalMileages', 'Decimal', 'asc');

    for (let i = 0; i < data.length; i++) {
      if(data[i].contactid !== this.contactId){
        if (data[i].isSelected) {
          if (data[i].reimbursementIdList.length > 0) {
            for (let j = 0; j < data[i].reimbursementIdList.length; j++) {
              this.myTeamReimbursement.push(data[i].reimbursementIdList[j]);
            }
          }
          count++;
        }
      }
    }
    this.isSubmitVisible = count > 0 ? true : false;
    if (count > 0) {
      this.myTeamReimbursement = this.removeDuplicateValue(
        this.myTeamReimbursement
      );
    } else {
      this.myTeamReimbursement = [];
    }
    console.log("Team reimbursement", JSON.stringify(this.myTeamReimbursement));
  }

  removeIds(target) {
    for (let i = 0; i < this.modelList.length; i++) {
      if (this.modelList[i].reimbursementid === target) {
        if (this.modelList[i].reimbursementIdList.length > 0) {
          for (
            let j = 0;
            j < this.modelList[i].reimbursementIdList.length;
            j++
          ) {
            let index = this.myTeamReimbursement
              .map((a) => {
                return a;
              })
              .indexOf(this.modelList[i].reimbursementIdList[j]);
            // console.log("index", el, target);
            if (index !== -1) {
              this.myTeamReimbursement.splice(index, 1);
            }
          }
        } else {
          let index = this.myTeamReimbursement
            .map((a) => {
              return a;
            })
            .indexOf(target);
          // console.log("index", el, target);
          if (index !== -1) {
            this.myTeamReimbursement.splice(index, 1);
          }
        }
      }
    }
  }

  rowHandler(event) {
    var checkbox,
      target,
      count = 0,
      boolean,
      model,
      len,
      content;
    checkbox = event.detail.isChecked;
    target = event.detail.targetId;
    this.modelList = this.template
      .querySelector("c-user-preview-table")
      .returnList();
    // if(this.searchmodelList.search){
    //     this.searchmodelList.content = this.template.querySelector('c-user-preview-table').returnSearchList();
    // }
    // console.log( "original----",this.template.querySelector('c-user-preview-table').returnSearchList())
    // console.log("search", this.searchmodelList.search, this.searchmodelList)
    // this.modelList =  this.template.querySelector('c-user-preview-table').returnList();
   // content = this.modelList;
    content = (this.searchmodelList.content) ? (this.searchmodelList.content.length > 0) ? this.searchmodelList.content : this.modelList : this.modelList;
    //  console.log('search----',this.searchmodelList);
    //  console.log(this.modelList);
    boolean = this.checkUncheckRow(target, checkbox, content);
    //  console.log(boolean);
    model = content;
    len = content.length;
    for (let i = 0; i < len; i++) {
      if (model[i].totalMileages > "0.00") {
        if (boolean) {
          if (model[i].isSelected) {
            count++;
            if (model[i].reimbursementIdList.length > 0) {
              for (let j = 0; j < model[i].reimbursementIdList.length; j++) {
                this.myTeamReimbursement.push(model[i].reimbursementIdList[j]);
              }
            }
          }
        }
      }
    }
    this.isSubmitVisible = count > 0 ? true : false;
    if (count > 0) {
      this.myTeamReimbursement = this.removeDuplicateValue(
        this.myTeamReimbursement
      );
      if (checkbox === false) {
        this.removeIds(target);
        // this.myTeamReimbursement.forEach((el) => {
        //   if (el === target) {
        //     let index = this.myTeamReimbursement
        //       .map((a) => {
        //         return a;
        //       })
        //       .indexOf(target);
        //     // console.log("index", el, target);
        //     this.myTeamReimbursement.splice(index, 1);
        //   }
        // });
      }
    } else {
      this.myTeamReimbursement = [];
    }

    console.log("Team reimbursement", JSON.stringify(this.myTeamReimbursement));
  }

  approveAllHandler(flagValue) {
    var data = [],
      count = 0;
    this._flag = flagValue;
    this.modelList = this.template
      .querySelector("c-user-preview-table")
      .returnList();
    // console.log(this.searchmodelList.search, flagValue)
    if (this.searchmodelList.search && flagValue === false) {
      data = this.searchmodelList.content;
    } else {
      data = this.modelList;
    }
    //console.log("approveAll---", data)
    this.myTeamReimbursement = [];
    this.template
      .querySelector("c-user-preview-table")
      .checkUncheckAll(this._flag);
    for (let i = 0; i < data.length; i++) {
      if(data[i].contactid !== this.contactId){
        data[i].isSelected = this._flag;
      }
    }
    this.template
      .querySelector("c-user-preview-table")
      .resetView(data, "contactid");
    this.template
      .querySelector("c-user-preview-table")
      .defaultSort('totalMileages', 'Decimal', 'asc');

    for (let i = 0; i < data.length; i++) {
      if(data[i].contactid !== this.contactId){
        if (data[i].isSelected) {
          if (data[i].reimbursementIdList.length > 0) {
            for (let j = 0; j < data[i].reimbursementIdList.length; j++) {
              this.myTeamReimbursement.push(data[i].reimbursementIdList[j]);
            }
          }
          count++;
        }
      }
    }

    this.isSubmitVisible = count > 0 ? true : false;
    if (count > 0) {
      this.myTeamReimbursement = this.removeDuplicateValue(
        this.myTeamReimbursement
      );
    } else {
      this.myTeamReimbursement = [];
    }
    console.log("Team reimbursement", JSON.stringify(this.myTeamReimbursement));
  }

  redirectModal(event) {
    const redirectEvent = new CustomEvent("preview", {
      detail: { data: event.detail, type: this.typeFilter }
    });
    this.dispatchEvent(redirectEvent);
  }

  showModal() {
    this.islockdate = false;
    this.modalOpen = true;
    this.headerModalText = "Mileage approvals are processing";
    this.modalClass =
      "slds-modal modal_info slds-is-fixed slds-fade-in-open animate__animated animate__slideInUp animate__fast";
    this.headerClass = "slds-modal__header";
    this.subheaderClass = "slds-p-top_large header-v1";
    this.modalContent = "slds-modal__content";
    this.styleHeader = "slds-modal__container slds-m-top_medium";
    this.styleClosebtn = "close-notify";
    this.contentMessage = "Updating Reimbursements";
    if (this.template.querySelector("c-user-profile-modal")) {
      this.template.querySelector("c-user-profile-modal").show();
    }
  }

  resetList(reimList) {
    this.modelList = reimList;
    this.dynamicBinding(this.modelList, this.modalKeyFields);
    if (this.modelList) {
      this.isSubmitVisible = false;
      this.modelList = this.sort(this.modelList, "name");
      if(this.template.querySelector('.filter-input')){
        this.template.querySelector('.filter-input').value = '';
        this.isSearchEnable = true;
      }
      this.template
        .querySelector("c-user-preview-table")
        .refreshTable(this.modelList);
      this.template.querySelector('c-user-preview-table').defaultSort('totalMileages', 'Decimal', 'asc')
    }
  }

  getAllUsers(){
    this.singleUser = false;
    if(this.userList){
      let b = JSON.parse(this.userList)
      this.resetViewList(b)
    }
  }

  resetViewList(b) {
    var count = 0;
    let element = b;
    this.modalListColumn = [];
    this.modalKeyFields = [];
    this.originalModelList = element;
    if (this.typeFilter === "High Risk") {
      this.highRiskList = element.filter(function (m) {
        return (m.totalHighRiskMileages > "0.00" && m.totalHighRiskMileages != null)
      });
      this.tripColumn[1].colName = "highRiskTotalPending";
      this.tripColumn[2].colName = "highRiskTotalApproved";
      this.tripColumn[3].colName = "totalHighRiskMileages";

      this.tripListColumn[1].colName = "highRiskTotalPending";
      this.tripListColumn[2].colName = "highRiskTotalApproved";
      this.tripListColumn[3].colName = "highRiskTotalRejected";
      this.tripListColumn[4].colName = "totalHighRiskMileages";

      this.tripKeyFields[1] = "highRiskTotalPending";
      this.tripKeyFields[2] = "highRiskTotalApproved";
      this.tripKeyFields[3] = "totalHighRiskMileages";

      this.tripListKeyFields[1] = "highRiskTotalPending";
      this.tripListKeyFields[2] = "highRiskTotalApproved";
      this.tripListKeyFields[3] = "highRiskTotalRejected";
      this.tripListKeyFields[4] = "totalHighRiskMileages";
      this.highRiskList.forEach((el) => {
        if (el.highRiskTotalRejected > 0) {
          count++;
        }
      });
      this.modelList = this.highRiskList;
      if (count > 0) {
        this.modalListColumn = this.tripListColumn;
        this.modalKeyFields = this.tripListKeyFields;
      } else {
        this.modalListColumn = this.tripColumn;
        this.modalKeyFields = this.tripKeyFields;
      }

      this.dynamicBinding(this.modelList, this.modalKeyFields);
      // this.modelList = this.sort(this.modelList, "name");
      // this.template
      //   .querySelector("c-user-preview-table")
      //   .viewData(this.modelList);
    } else {
      this.tripColumn[1].colName = "totalMileages";
      this.tripColumn[2].colName = "approvedMileages";
      this.tripColumn[3].colName = "TotalReimMileages";

      this.tripListColumn[1].colName = "totalMileages";
      this.tripListColumn[2].colName = "approvedMileages";
      this.tripListColumn[3].colName = "rejectedMileges";
      this.tripListColumn[4].colName = "TotalReimMileages";

      this.tripKeyFields[1] = "totalMileages";
      this.tripKeyFields[2] = "approvedMileages";
      this.tripKeyFields[3] = "TotalReimMileages";

      this.tripListKeyFields[1] = "totalMileages";
      this.tripListKeyFields[2] = "approvedMileages";
      this.tripListKeyFields[3] = "rejectedMileges";
      this.tripListKeyFields[4] = "TotalReimMileages";
      this.modelList = b;
      this.modelList.forEach((el) => {
        if (el.rejectedMileges > "0.00") {
          count++;
        }
      });

      if (count > 0) {
        this.modalListColumn = this.tripListColumn;
        this.modalKeyFields = this.tripListKeyFields;
      } else {
        this.modalListColumn = this.tripColumn;
        this.modalKeyFields = this.tripKeyFields;
      }

      this.dynamicBinding(this.modelList, this.modalKeyFields);
      // this.modelList = this.sort(this.modelList, 'name');
      // this.template.querySelector('c-user-preview-table').viewData(this.modelList);
    }
    if (this.modelList) {
      this.isSubmitVisible = false;
      this.modelList = (this.typeFilter === 'High Risk') ? this.sortByNumber(this.modelList, "highRiskTotalPending") : this.sort(this.modelList, "totalMileages");
      this.isRecord = this.modelList.length > 0 ? true : false;
      console.log("Reimbu--", JSON.stringify(this.modelList))
      if(this.typeFilter === 'High Risk'){
        this.template
        .querySelector("c-user-preview-table")
        .viewData(this.modelList, 'name', false);
      }else{
        this.template
        .querySelector("c-user-preview-table")
        .viewData(this.modelList, 'name', true);
      }
      
    }
  }

  CheckStatus(runTime) {
    var errResult, toast, message, batchId;
    this.islockdate = false;
    CheckBatchStatus({
      batchprocessid: runTime.Id
    })
      .then((result) => {
        console.log("CheckBatchStatus", result);
        sessionStorage.setItem("Batch-Id", runTime.Id);
        // console.log("Batch Id", runTime.Id);
        batchId = sessionStorage.getItem("Batch-Id");
        if (batchId !== null) {
          console.log("inside rendered approval");
          this.endProcess = true;
          let item = this.modelList;
          for (let i = 0; i < item.length; i++) {
            if (item[i].isSelected && item[i].status !== "Approved") {
              item[i].reimbursementApproval = true;
            }
          }
          this.resetList(item);
        }
        if (result != null && result !== "") {
          if (result === "Completed") {
            this.dispatchEvent(
              new CustomEvent("show", {
                detail: "spinner"
              })
            );
            this.unapprovereimbursements = [];
            // if(this.singleUser){
            //   const redirectEvent = new CustomEvent("resetuser", {
            //     detail: ''
            //   });
            //   this.dispatchEvent(redirectEvent);
            // }
            if (this.modelList !== undefined) {
              for (let i = 0; i < this.modelList.length; i++) {
                if (this.modelList[i].isSelected) {
                  this.unapprovereimbursements.push(this.modelList[i]);
                }
              }
            }
            this.msg = "";
            this.msg = "Mileage has been approved.";
            this.singleUser = false
            UpdatedReimList({
              did: this.contactId,
              accid: this.accountId,
              showTeamRecord: this.showTeam,
              role: this.role
            })
              .then((a) => {
                if (a != null && a !== "") {
                  toast = { type: "success", message: this.msg };
                  toastEvents(this, toast);
                  console.log("UpdatedReimList", a);
                  console.log("UpdatedReimList", a);
                  this.endProcess = false;
                  /* Bad Escaped */
                  let escapedData = a[1].replace(/\'/g,"\\")
                  let reimList = JSON.parse(escapedData);
                  this.resetViewList(reimList);
                }
                this.dispatchEvent(
                  new CustomEvent("hide", {
                    detail: "spinner"
                  })
                );
                if (this.modalOpen) {
                  if (this.template.querySelector("c-user-profile-modal")) {
                    this.template.querySelector("c-user-profile-modal").hide();
                    this.modalOpen = false;
                  }
                }
                // setTimeout(()=>{
                //     location.reload()
                // }, 2000);
              })
              .catch((error) => {
                console.log(error, error.body);
                if (error.body !== undefined) {
                  if (Array.isArray(error.body)) {
                    message = error.body.map((e) => e.message).join(", ");
                  } else if (typeof error.body.message === "string") {
                    message = error.body.message;
                  }
                  toast = { type: "error", message: message };
                  toastEvents(this, toast);
                }
              });

            // if(this.modalOpen){
            //     if (this.template.querySelector('c-user-profile-modal')) {
            //         this.template.querySelector('c-user-profile-modal').hide();
            //         this.modalOpen = false;
            //     }
            // }
          } else if (result.includes("Failed=")) {
            this.dispatchEvent(
              new CustomEvent("hide", {
                detail: "spinner"
              })
            );
            if (this.modalOpen) {
              if (this.template.querySelector("c-user-profile-modal")) {
                this.template.querySelector("c-user-profile-modal").hide();
                this.modalOpen = false;
              }
            }
            errResult = result.split("=");
            toast = { type: "error", message: errResult[1] };
            toastEvents(this, toast);
          } else {
            this.dispatchEvent(
              new CustomEvent("hide", {
                detail: "spinner"
              })
            );
            // if(this.modalOpen){
            //     if (this.template.querySelector('c-user-profile-modal')) {
            //         this.template.querySelector('c-user-profile-modal').hide();
            //         this.modalOpen = false;
            //     }
            // }
            this.CheckStatus(runTime);
            // setTimeout(function () {
            //     this.CheckStatus(runTime);
            // }, 5000);
          }
        } else {
          if (this.modalOpen) {
            if (this.template.querySelector("c-user-profile-modal")) {
              this.template.querySelector("c-user-profile-modal").hide();
              this.modalOpen = false;
            }
          }
          toast = { type: "error", message: "Error while approving" };
          toastEvents(this, toast);
        }
      })
      .catch((error) => {
        if (this.modalOpen) {
          if (this.template.querySelector("c-user-profile-modal")) {
            this.template.querySelector("c-user-profile-modal").hide();
            this.modalOpen = false;
          }
        }
        if (error.body !== undefined) {
          if (Array.isArray(error.body)) {
            message = error.body.map((e) => e.message).join(", ");
          } else if (typeof error.body.message === "string") {
            message = error.body.message;
          }
          toast = { type: "error", message: message };
          toastEvents(this, toast);
        }
        console.log("CheckBatchStatus", error);
      });
  }

  dateTime(date) {
    var yd, ydd, ymm, yy, hh, min, sec;
    yd = date;
    ydd = yd.getDate();
    ymm = yd.getMonth() + 1;
    yy = yd.getFullYear();
    hh = yd.getHours();
    min = yd.getMinutes();
    sec = yd.getSeconds();
    ydd = ydd < 10 ? "0" + ydd : ydd;
    ymm = ymm < 10 ? "0" + ymm : ymm;
    return (
      ymm.toString() +
      ydd.toString() +
      yy.toString() +
      hh.toString() +
      min.toString() +
      sec.toString()
    );
  }

  handleSyncDone(){
    clearTimeout(this.timeoutId); // no-op if invalid id
    this.timeoutId = setTimeout(this.refreshSync.bind(this), 4000);
  }
  
  refreshSync(){
    /*this.dispatchEvent(
      new CustomEvent("show", {
        detail: "spinner"
      })
    );
    setTimeout(function () {
      location.reload();
    }, 10000);*/
    this.dispatchEvent(
      new CustomEvent("complete", {
          detail: ''
      })
    );
  }

  approvalProcess() {
    var toastMessage, message , toast, filterType;
    this.islockdate = false;
    this.modalOpen = true;
    this.headerModalText = "Processing Mileage Approvals";
    this.modalClass = "slds-modal modal_info slds-fade-in-open";
    this.headerClass = "slds-modal__header";
    this.subheaderClass = "slds-p-top_large header-v1";
    this.modalContent = "slds-modal__content";
    this.styleHeader = "slds-modal__container slds-m-top_medium";
    this.styleClosebtn = "close-notify";
    this.contentMessage = "Updating Reimbursements";
    this.msg = "";
    this.msg = "Mileage has been approved.";
    filterType = (this.filter !== '') ? this.filter : this.typeFilter
    this.dispatchEvent(
      new CustomEvent("show", {
        detail: "spinner"
      })
    );
    approveMileagesClone({
      mileages: JSON.stringify(this.myTeamReimbursement),
      did: this.contactId,
      accid: this.accountId,
      showTeamRecord: this.showTeam,
      highrisk: (filterType === 'High Risk') ? true : false
    })
      .then((result) => {
        if (result != null) {
          this.dispatchEvent(
            new CustomEvent("hide", {
              detail: "spinner"
            })
          );
          console.log("approveMileagesClone Result", result);
          if (this.template.querySelector("c-user-profile-modal")) {
            this.template.querySelector("c-user-profile-modal").show();
          }
          this.CheckStatus(result);
        }else{
           this.dispatchEvent(
            new CustomEvent("hide", {
              detail: "spinner"
            })
          );
        }
      })
      .catch((error) => {
        this.dispatchEvent(
          new CustomEvent("hide", {
            detail: "spinner"
          })
        );
        if (Array.isArray(error.body)) {
          message = error.body.map((e) => e.message).join(", ");
        } else if (typeof error.body.message === "string") {
          message = error.body.message;
        }
        toastMessage = { type: "error", message: message };
        toastEvents(this, toastMessage);
        console.log("approveMileagesClone", error);
      });
  }

  cancelApproval(){
    this.islockdate = false;
    if (this.template.querySelector("c-user-profile-modal")) {
      this.template.querySelector("c-user-profile-modal").hide();
    }
    this.resetList(this.originalModelList)
  }

  closeModal(){
    if(this.islockdate){
      this.resetList(this.originalModelList)
      this.islockdate = false
    }
  }


  handleApproval(){
    if (this.template.querySelector("c-user-profile-modal")) {
      this.template.querySelector("c-user-profile-modal").hide();
    }
    this.approvalProcess();
  }

  submitHandler() {
    let data = this.modelList,
      lockdatecount = 0;
    for (let i = 0; i < data.length; i++) {
      if (data[i].reimbursementIdList.length > 0) {
        for (let j = 0; j < data[i].reimbursementIdList.length; j++) {
          if (
            this.myTeamReimbursement.includes(data[i].reimbursementIdList[j])
          ) {
            if (data[i].lockDate !== null) {
              if(data[i].lockDate !== ''){
                lockdatecount++;
              }
            }
          }
        }
      }
    }

    if (lockdatecount > 0) {
      let lockDate = this.modelList[0].lockDate;
      let currentDateLocked = new Date(lockDate);
      console.log("date", lockDate, currentDateLocked)
      //let lockedMonth = currentDateLocked.toLocaleString('default', { month: 'long' });
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
      this.approvalProcess();
    }

    console.log(
      "Final----",
      JSON.stringify(this.myTeamReimbursement),
      lockdatecount
    );
  }

  syncAllTrips() {
    let element = this.modelList;
    element.forEach((el) => {
      if (el.reimbursementIdList) {
        el.reimbursementIdList.forEach((fl) => {
          this.allReimbursementList.push(fl);
        });
      }
    });

    if(this.isAccountBiweek) {
      console.log("Inside biweek", this.isAccountBiweek)
      MassSyncTripsForBiweek({
        biWeek: JSON.stringify(element),
        accID: this.accountId
      })
        .then((result) => {
          if (result) {
            let toast = {
              type: "success",
              message:
                "The mileage is syncing in background. It could take up to a minute for sync to mileage."
            };
            toastEvents(this, toast);
            setTimeout(function () {
              location.reload();
            }, 4000);
          }
        })
        .catch((error) => {
          console.log("Error", error);
        });
    }else{
      console.log("Inside monthly", this.isAccountBiweek)
      let dates = this.getStartAndEndDate(this.syncMonth);
			this.syStartDate = dates?.startDate;
			this.syEndDate = dates?.endDate;
      MassSyncTrips({
				accountId: this.accountId, 
				startDate: this.syStartDate, 
				endDate: this.syEndDate, 
				month : this.syncMonth,
				tripStatus: this.tripStatus,
        activityStatus: this.activity
			})
        .then((result) => {
          if (result) {
            let toast = {
              type: "success",
              message:
                "The mileage is syncing in background. It could take up to a minute for sync to mileage."
            };
            toastEvents(this, toast);
            this.handleSyncDone();
          }
        })
        .catch((error) => {
          console.log("Error", error);
        });
    }
  
    console.log("Reimbu-->", JSON.stringify(this.allReimbursementList));
  }

  excelToExport(data, file, sheet) {
    this.template.querySelector("c-export-excel").download(data, file, sheet);
  }

  getStartAndEndDate(dateString) {
		const [month, year] = dateString.split('-');
		const startDate = new Date(year, month - 1, 1);
		const endDate = new Date(year, month, 0);
	  
		const formattedStartDate = `${(startDate.getMonth() + 1).toString().padStart(2, '0')}/${startDate.getDate().toString().padStart(2, '0')}/${startDate.getFullYear()}`;
		const formattedEndDate = `${(endDate.getMonth() + 1).toString().padStart(2, '0')}/${endDate.getDate().toString().padStart(2, '0')}/${endDate.getFullYear()}`;
	  
		return { startDate: formattedStartDate, endDate: formattedEndDate };
	}

  downloadAllTrips() {
    console.log("Type--", this.typeFilter);
    let mileage = [];
    let fileName =
      this.contactInfo + "'s Unapproved Mileage " + this.dateTime(new Date());
    let sheetName = "Mileage Report";
    let excelList = this.sort(this.modelList, "name");
    mileage.push([
      "Month",
      "Name",
      "Unapproved Mileage",
      "Approved Mileage",
      "Approved By",
      "Approval Date",
      "Lock Date/Report Run",
      "Managers Name",
      "Managers Email"
    ]);
    excelList.forEach((item) => {
      mileage.push([
        item.month,
        item.name.replace(/\\'/g, "'"),
        this.typeFilter === "High Risk"
          ? item.totalHighRiskMileages
          : item.totalMileages,
        item.approvedMileages,
        item.mileageApproval,
        item.approvedDate,
        item.lockDate,
        item.managerName,
        item.managerEmail
      ]);
    });
    this.excelToExport(mileage, fileName, sheetName);
  }

  revertHandler(){
    this.dispatchEvent(
      new CustomEvent("back", {
          detail: ''
      })
   );
   // window.history.go(window.history.length - window.history.length - 1);
  }

  renderedCallback() {
    console.log(
      "Rendered---",
      this.template.querySelector('c-dropdown-select[data-id="teamSelect"]'),
      this.teamList
    );
    let showTeamValue = this.getUrlParamValue(window.location.href, "showteam");
    if (this.showTeam) {
      if (showTeamValue === "false") {
        if (
          this.template.querySelector('c-dropdown-select[data-id="teamSelect"]')
        ) {
          this.template.querySelector(
            'c-dropdown-select[data-id="teamSelect"]'
          ).selectedValue = "My Team";
          this.template
            .querySelector('c-dropdown-select[data-id="teamSelect"]')
            .toggleSelected("My Team");
        }
      } else {
        if (
          this.template.querySelector('c-dropdown-select[data-id="teamSelect"]')
        ) {
          this.template.querySelector(
            'c-dropdown-select[data-id="teamSelect"]'
          ).selectedValue = "Company";
          this.template
            .querySelector('c-dropdown-select[data-id="teamSelect"]')
            .toggleSelected("Company");
        }
      }
    }
    console.log("rendered---", this.typeFilter, this.filter);
    if (this.filter === "High Risk" && this.typeFilter === "High Risk") {
      if (
        this.template.querySelector('c-dropdown-select[data-id="typeSelect"]')
      ) {
        this.template.querySelector(
          'c-dropdown-select[data-id="typeSelect"]'
        ).selectedValue = "High Risk";
        this.template
          .querySelector('c-dropdown-select[data-id="typeSelect"]')
          .toggleSelected("High Risk");
        this.template
          .querySelector('c-dropdown-select[data-id="typeSelect"]')
          .removeHidden("All Trips");
      }
    } else {
      if (this.filter === "All Trips") {
        if (
          this.template.querySelector('c-dropdown-select[data-id="typeSelect"]')
        ) {
          this.template.querySelector(
            'c-dropdown-select[data-id="typeSelect"]'
          ).selectedValue = "All Trips";
          this.template
            .querySelector('c-dropdown-select[data-id="typeSelect"]')
            .toggleSelected("All Trips");
          // this.template
          //   .querySelector('c-dropdown-select[data-id="typeSelect"]')
          //   .removeHidden("High Risk");
        }
      } else {
        if (this.typeFilter === 'High Risk') {
            if (this.template.querySelector('c-dropdown-select[data-id="typeSelect"]')) {
              this.template.querySelector(
                'c-dropdown-select[data-id="typeSelect"]'
              ).selectedValue = "High Risk";
              this.template
                .querySelector('c-dropdown-select[data-id="typeSelect"]')
                .toggleSelected("High Risk");
              this.template
                .querySelector('c-dropdown-select[data-id="typeSelect"]')
                .removeHidden("All Trips");
          }
       } else {
          if (this.template.querySelector('c-dropdown-select[data-id="typeSelect"]')) {
            this.template.querySelector(
              'c-dropdown-select[data-id="typeSelect"]'
            ).selectedValue = "All Trips";
            this.template
              .querySelector('c-dropdown-select[data-id="typeSelect"]')
              .toggleSelected("All Trips");
            this.template
              .querySelector('c-dropdown-select[data-id="typeSelect"]')
              .removeHidden("High Risk");
          }
        }
      }
      
    }

    //    let selectedValue = sessionStorage.getItem("selected");
    //     if(this.flagVisited){
    //         if(selectedValue != null){
    //             this.teamValue = selectedValue;
    //             this.resetList(this.renderDriverList);
    //         }
    //     }
    //     var batchId = sessionStorage.getItem("Batch-Id");
    //    // this.modalOpen = true;
    //     console.log("render--", batchId);
    //     if(batchId !== null){
    //         console.log("inside rendered approval")
    //         let item  = this.modelList;
    //         for (let i = 0; i < item.length; i++) {
    //             if (item[i].isSelected && item[i].status !== 'Approved'){
    //                 item[i].reimbursementApproval = true;
    //             }
    //         }
    //         this.resetList(item);
    //     }
  }

  connectedCallback() {
    sessionStorage.removeItem("Batch-Id");
    const formatter = new Intl.DateTimeFormat("default", {
      month: "numeric", year: "numeric"
    });
    const date = new Date();
    let number = 1;
    let prevMonth = formatter.format(
      new Date(date.getFullYear(), date.getMonth() - `${number}`)
    );
    let prevList = prevMonth.split('/');
    prevList[0] = prevList[0].padStart(2, '0');
    this.syncMonth = prevList.join('-');
    let count = 0;
    this.isScrollable = true;
    this.paginatedModal = true;
    //this.isSort = false;
    this.isCheckbox = true;
    this.modalListColumn = [];
    this.modalKeyFields = [];
    if (this.contactList) {
      this.modelList = this.proxyToObject(this.contactList);
      this.originalModelList = this.proxyToObject(this.contactList);
      this.classToTable =
        this.modelList.length > 5
          ? 'fixed-container' : 'fixed-container overflow-none';
      if (this.filter === "High Risk") {
        this.typeFilter = this.filter;
        let element = this.originalModelList;
        this.highRiskList = element.filter(function (b) {
          return b.totalHighRiskMileages !== 0;
        });
        this.tripColumn[1].colName = "highRiskTotalPending";
        this.tripColumn[2].colName = "highRiskTotalApproved";
        this.tripColumn[3].colName = "totalHighRiskMileages";
  
        this.tripListColumn[1].colName = "highRiskTotalPending";
        this.tripListColumn[2].colName = "highRiskTotalApproved";
        this.tripListColumn[3].colName = "highRiskTotalRejected";
        this.tripListColumn[4].colName = "totalHighRiskMileages";
  
        this.tripKeyFields[1] = "highRiskTotalPending";
        this.tripKeyFields[2] = "highRiskTotalApproved";
        this.tripKeyFields[3] = "totalHighRiskMileages";
  
        this.tripListKeyFields[1] = "highRiskTotalPending";
        this.tripListKeyFields[2] = "highRiskTotalApproved";
        this.tripListKeyFields[3] = "highRiskTotalRejected";
        this.tripListKeyFields[4] = "totalHighRiskMileages";
        this.highRiskList.forEach((el) => {
          if (el.highRiskTotalRejected > "0.00") {
            count++;
          }
        });
        this.modelList = this.highRiskList;

        if (count > 0) {
          this.modalListColumn = this.tripListColumn;
          this.modalKeyFields = this.tripListKeyFields;
        } else {
          this.modalListColumn = this.tripColumn;
          this.modalKeyFields = this.tripKeyFields;
        }
         
        console.log("Get---", JSON.stringify(this.modelList))
        this.dynamicBinding(this.modelList, this.modalKeyFields);
      } else {
        this.tripColumn[1].colName = "totalMileages";
        this.tripColumn[2].colName = "approvedMileages";
        this.tripColumn[3].colName = "TotalReimMileages";

        this.tripListColumn[1].colName = "totalMileages";
        this.tripListColumn[2].colName = "approvedMileages";
        this.tripListColumn[3].colName = "rejectedMileges";
        this.tripListColumn[4].colName = "TotalReimMileages";

        this.tripKeyFields[1] = "totalMileages";
        this.tripKeyFields[2] = "approvedMileages";
        this.tripKeyFields[3] = "TotalReimMileages";

        this.tripListKeyFields[1] = "totalMileages";
        this.tripListKeyFields[2] = "approvedMileages";
        this.tripListKeyFields[3] = "rejectedMileges";
        this.tripListKeyFields[4] = "TotalReimMileages";
        this.modelList = this.originalModelList;
        this.modelList.forEach((el) => {
          if (el.rejectedMileges > "0.00") {
            count++;
          }
        });


        if (count > 0) {
          this.modalListColumn = this.tripListColumn;
          this.modalKeyFields = this.tripListKeyFields;
        } else {
          this.modalListColumn = this.tripColumn;
          this.modalKeyFields = this.tripKeyFields;
        }

        this.dynamicBinding(this.modelList, this.modalKeyFields);
      }


      this.isRecord = this.modelList.length > 0 ? true : false;
      // this.modelList.forEach((el)=>{
      //     if(el.rejectedMileges > '0.00'){
      //         count++;
      //     }
      // })

      // if(count > 0){
      //     this.modalListColumn = this.tripListColumn;
      //     this.modalKeyFields = this.tripListKeyFields;
      // }else{
      //     this.modalListColumn = this.tripColumn;
      //     this.modalKeyFields = this.tripKeyFields;
      // }

      // this.dynamicBinding(this.modelList, this.modalKeyFields)
    }
  }
}