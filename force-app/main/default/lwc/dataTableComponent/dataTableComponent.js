/* eslint-disable no-console */
import {
  LightningElement,
  wire,
  track,
  api
} from "lwc";
import fetchMileages from "@salesforce/apex/GetDriverData.fetchMileages";
import fetchMileagesSize from "@salesforce/apex/GetDriverData.fetchMileagesSize";
import MileageDashboardMessage from '@salesforce/label/c.MileageDashboardMessage';
import LwcDesignImage from "@salesforce/resourceUrl/LwcDesignImage";
import updateMileages from '@salesforce/apex/GetDriverData.updateMileages';
import updateMileagesEmail from '@salesforce/apex/GetDriverData.updateMileagesEmail';
// import TIME_ZONE from "@salesforce/i18n/timeZone";
// import LOCALE from '@salesforce/i18n/locale';
import {
  formatData,
  validateDate,
  excelData,
  excelFormatDate,
  changeKeyObjects,
  typeOfTrip
} from 'c/commonLib';
const recordsPerPage = [25, 50, 100, 200];
export default class DataTableComponent extends LightningElement {
  ready = false;
  // tz = TIME_ZONE;
  // ln = LOCALE;
  isRenderCallbackActionExecuted = true;
  isPdf = false;
  isRowSplitterExcecuted = false;
  isPerPageActionExecuted = false;
  isClicked = false;
  isNoteClicked = false;
  isStayTimeClicked = false;
  isTagClicked = false;
  selectBool = false;
  tableSpinner = false;
  updatingText;
  rowLimit;
  rowOffSet = 0;
  activity;
  @track mileageRowLimit;
  @track statusAppImg;
  @track statusRejImg;
  @track columns = [{
      label: "Date & Time",
      fieldName: "Date",
      type: "datetime",
    },
    {
      label: "Driver",
      fieldName: "Name",
    },
    {
      label: "Vehicle",
      fieldName: "VehicleType",
    },
    {
      label: "Mileage",
      fieldName: "Mileage",
    },
    {
      label: "From",
      fieldName: "FromLocation",
    },
    {
      label: "To",
      fieldName: "ToLocation",
    },
    {
      label: "Notes",
      fieldName: "notes",
    },
  ];
  @api accountID;
  @api contactID;
  @api plID;
  @track record = {};
  @track wiredData = [];
  @track currentPage = 1;
  @track loadingSpinner = true;
  @track pageClick = false;
  @track searchallList = [];
  @track allowSorting = false;
  @track reverse = false;
  @track totalrows;
  @track currentData = [];
  @track searchData = [];
  @track option;
  @track totalmileage;
  @track driverId;
  @track field;
  @track object;
  @track key;
  @track searchkeyvalue;
  @track wherefieldvalue;
  @track pageSize;
  @track dataSize;
  @track xlsHeader = [];
  @track xlsData = [];
  @track filename;
  @track xlsSheetContent = [];
  @track workSheetNameList = [];
  @api approveRejectCheck = [];
  @api approveRejectCheckSearch = [];
  @api pageSizeOptions = recordsPerPage;
  @track loadingText = MileageDashboardMessage;
  @track isButtonDisabled = true;
  isSend = false;
  isloadingText = false;
  searchFlag = false;
  searchDataLength = false;
  currentDataLength = false;

  get disableClass() { 
    return (this.accountID === this.plID) ? 'slds_input' : 'slds_input dimmed';
  }

  @api getRowLimit() {
    var mileageRowLt = this.mileageRowLimit;
    // console.log("inside row limit", mileageRowLt);
    return mileageRowLt;
  }

  @api resetSelected(){
    var defaultCheckbox, searchCheckbox, m, lengthOfInput;
    searchCheckbox = this.template.querySelectorAll(
      ".checkboxCheckUncheckSearch"
    );

    defaultCheckbox = this.template.querySelectorAll(
      ".checkboxCheckUncheck"
    );
    this.template.querySelector(".CheckUncheckAll").checked = false;
    if (this.searchData.length != 0) {
      lengthOfInput = searchCheckbox.length;
      for (m = 0; m < lengthOfInput; m++) {
        if (searchCheckbox[m].checked === true) {
          searchCheckbox[m].checked = false;
        }
      }
    }else{
      lengthOfInput = defaultCheckbox.length;
      for (m = 0; m < lengthOfInput; m++) {
        if (defaultCheckbox[m].checked === true) {
          defaultCheckbox[m].checked = false;
        }
      }
    }
  }
  // Advance Search Based on lookups such as Date,Driver,Mileage etc
  @api getSearchData(value, isMailSend, dataLen, rLength) {
  //  console.log("Mileage Size: ", dataLen);
    this.template.querySelector('.paginate').classList.remove('blur');
    this.template.querySelector(".CheckUncheckAll").checked = false;
    if (isMailSend === 'trip deleted') {
      this.isSend = true;
      this.isloadingText = false;
      const successDeleteEvent = new CustomEvent("handledeletesuccessevent", {
        detail: "Event Send"
      })
      this.dispatchEvent(successDeleteEvent);
    } else if (isMailSend === 'email send') {
      this.isSend = true;
      this.isloadingText = true;
      const successEvent = new CustomEvent("handlesuccessevent", {
        detail: "Event Send"
      })
      this.dispatchEvent(successEvent);
    }
    if (!this.loadingSpinner) {
      this.loadingSpinner = true;
    }
    this.isRowSplitterExcecuted = false;
    this.searchallList = [];
    this.searchFlag = true;
    this.searchallList = value;
    if (this.searchallList.length < 25 && !this.pageClick) {
      this.template.querySelector("c-paginator").classList.add("slds-hide");
    } else {
      this.template.querySelector("c-paginator").classList.remove("slds-hide");
      // console.log(this.pageClick)
      if (!this.pageClick) {
        // console.log('inside paginator change')
        this.template.querySelector("c-paginator").defaultPageSize(dataLen, rLength);
      }

      // this.template.querySelector("c-paginator").pageData(value, this.pageSize);
    }
    this.totalrows = dataLen;
    this.searchallList = this.defaultSortingByDate(
      this.searchallList,
      "ConvertedStartTime__c"
    );


    if (this.searchallList.length != 0) {
      this.searchDataLength = true;
      this.loadingSpinner = false;
    } else {
      this.searchDataLength = false;
    }

    this.setSearchRecordsToDisplay();
  }

  // Get all <tr> of accordion(table)
  @api
  getElement() {
    this.deleteRow();
    const table_tr = this.template.querySelectorAll(".collapsible");
    if (table_tr) {
      return table_tr;
    }
  }


  //Get tripRoute Icon
  @api
  getIcon;

  //Get <table> element
  @api
  getTableElement() {
    this.template.querySelector('.paginate').classList.add('blur');
    const table = this.template.querySelector(".accordion_table");
    if (table) {
      return table;
    }
  }

  // Mass change activity
  @api changeActivity(){
    this.tripSelectedData = [];
    var listOfTripType = [], defaultChbox, searchChbox, n, lengthOfCheckbox, dCount = 0, sCount = 0;
    searchChbox = this.template.querySelectorAll(
      ".checkboxCheckUncheckSearch"
    );

    defaultChbox = this.template.querySelectorAll(
      ".checkboxCheckUncheck"
    );
    if (this.searchData.length != 0) {
      lengthOfCheckbox = searchChbox.length;
      for (n = 0; n < lengthOfCheckbox; n++) {
        if (searchChbox[n].checked === true) {
          sCount++;
          if (this.searchData[n].id === searchChbox[n].dataset.id) {
            listOfTripType.push(typeOfTrip(this.searchData[n], this.contactID));
          }
        }
        this.tripSelectedData = listOfTripType;
      }
      if(sCount === 0) {
        const filterEvent = new CustomEvent("handlesearchactivity",{
          detail: "Success"
        })
        this.dispatchEvent(filterEvent);
      }else{
        this.showTripModal(this.tripSelectedData);
      }
    }else{
      lengthOfCheckbox = defaultChbox.length;
      for (n = 0; n < lengthOfCheckbox; n++) {
        if (defaultChbox[n].checked === true) {
          dCount++;
          if (this.currentData[n].id === defaultChbox[n].dataset.id) {
            listOfTripType.push(typeOfTrip(this.currentData[n], this.contactID));
          }
        }
        this.tripSelectedData = listOfTripType;
      }
      if(dCount === 0) {
        const dEvent = new CustomEvent("handledefaultactivity",{
          detail: "Success"
        })
        this.dispatchEvent(dEvent);
      }else{
        this.showTripModal(this.tripSelectedData);
      }
    }
  }
  //Download Excel based selected trips
  @api exportSelectedTrip() {
    this.exportSelectedData = [];
    var checkbox = this.template.querySelectorAll(
      ".checkboxCheckUncheckSearch"
    );

    var checkbox2 = this.template.querySelectorAll(
      ".checkboxCheckUncheck"
    );
    if (this.searchData.length != 0) {
      var i,exportTripData = [],j = checkbox.length, searchCheckCount = 0;
      for (i = 0; i < j; i++) {
        if (checkbox[i].checked === true) {
          searchCheckCount ++;
          if (this.searchData[i].id === checkbox[i].dataset.id) {
            exportTripData.push(excelData(this.searchData[i]));
          }
        }
        //formatted data for excel download
        this.exportSelectedData = exportTripData;
      }
      if(searchCheckCount === 0){
        const countSearchExcel = new CustomEvent("handlesearchcountexcel", {
          detail: "Success"
        })
        this.dispatchEvent(countSearchExcel);
      }
    } else {
      var i,exportTripData = [],j = checkbox2.length, checkCount = 0;
      for (i = 0; i < j; i++) {
        if (checkbox2[i].checked === true) {
          checkCount++;
          if (this.currentData[i].id === checkbox2[i].dataset.id) {
            exportTripData.push(excelData(this.currentData[i]));
          }
        }

        //formatted data for excel download
        this.exportSelectedData = exportTripData;
      }
      if(checkCount === 0){
        const countExcel = new CustomEvent("handlecountexcel", {
          detail: "Success"
        })
        this.dispatchEvent(countExcel);
      }
    }

    if(this.exportSelectedData.length != 0){
      this.xlsFormatter(this.exportSelectedData);
    }
   
  }

  // Filter Modal For CSV Download
  @api showFilterModal() {
    // Calls function from child component (c-filter-modal-popup)
    let filtermodalShow = this.template
      .querySelector("c-filter-modal-popup")
      .ModalClassList();
    var filtermodalbackdrop = this.template
      .querySelector("c-filter-modal-popup")
      .ModalBackdrop();
    filtermodalShow.classList.remove("slds-hide");
    filtermodalbackdrop.classList.remove("slds-hide");
    this.template
      .querySelector("c-filter-modal-popup")
      .infoID(this.accountID, this.contactID);

  }

  // Apex Method Call For Default Data To Display in table
  @api apexMethodCall(isEmailSend, rowLimit, rowOffSet) {
    if (isEmailSend != undefined || isEmailSend != null) {
      if (isEmailSend === 'trip deleted') {
        this.isloadingText = false;
        const deleteEvent = new CustomEvent("handledeleteevent", {
          detail: "Event Send"
        })
        this.dispatchEvent(deleteEvent);
      } else {
        this.isloadingText = true;
        const successDefaultEvent = new CustomEvent("handledefaultsuccessevent", {
          detail: "Event Send"
        })
        this.dispatchEvent(successDefaultEvent);
      }
      this.isSend = true;
      this.isRowSplitterExcecuted = false;

    }

    rowLimit = (rowLimit === null || rowLimit === undefined) ? this.rowLimit : rowLimit;
    rowOffSet = (rowOffSet === null || rowOffSet === undefined) ? this.rowOffSet : rowOffSet;

    fetchMileages({
        accID: this.accountID,
        AdminId: this.contactID,
        limitSize: rowLimit,
        offset: rowOffSet
      })
      .then((data) => {
        if (this.wiredData.length != 0) {
          this.wiredData = [];
        }
        this.wiredData = data;
        // for ( let i = 0; i < data.length; i++ ) {  

        //   let dataParse = data[ i ];

        //   if ( dataParse.ConvertedStartTime__c ) {
              
        //       let dt = new Date( dataParse.ConvertedStartTime__c );
        //       dataParse.ConvertedStartTime__c = new Intl.DateTimeFormat(LOCALE).format( dt );
        //       console.log(dataParse);
        //   }
        // }
        console.log('From fetch mileage', data);

        // console.log('%c fetchMileages data length : %d', 'display: inline-block ; background-color: #e0005a ; color: #ffffff ; font-weight: bold ; padding: 3px 7px 3px 7px ; border-radius: 3px 3px 3px 3px ;', this.wiredData.length);
        this.setRecordsToDisplay();
      })
      .catch((error) => {
        console.log(error);
      });
    // }, 10);
  }

  // Get total number of trips on load
  getDataSize() {
    fetchMileagesSize({
        accID: this.accountID,
        adminId: this.contactID
      })
      .then((data) => {
        this.dataSize = parseInt(data);
        this.template.querySelector("c-paginator").defaultPageSize(this.dataSize, this.pageSize);
        this.totalrows = this.dataSize;
        //console.log("mileage data size", this.dataSize);
      })
      .catch((error) => {
        console.log(error);
      });
  }

  // On click event of child (c-validate-data-list-component) component
  handleDriverSelect(event) {
    // eslint-disable-next-line no-console
    event.preventDefault();

    this.driverId = event.detail; // stores id of driver

    // options to be displayed in dropdown based on field,object,key,wherefieldvalue,searchkeyvalue
    this.field = "Trip_Origin__c";
    this.object = "Employee_Mileage__c";
    this.searchkeyvalue = "Trip_Origin__c";
    this.key = "Destination_Name__c";
    this.wherefieldvalue = "EmployeeReimbursement__r.Contact_Id__c";

    //Call function from child component
    this.template
      .querySelector(".fromdatalistcomponent")
      .deleteSelectedOption();
    this.template.querySelector(".todatalistcomponent").deleteSelectedOption();
  }

  handleInlineEvent(event){
   // console.log(event.detail);
    this.isClicked = true;
    this.activity = event.detail;
  }
  // On click event of each row in table
  clickHandler(event) {
    // console.log('inside click handler',event);
    // process.exit(0);
    var i;
    var checkbox;
    var to = event.target ? event.target : event.toElement;
    if (to.parentElement != null || to.parentElement != undefined) {
      checkbox = to.parentElement.previousElementSibling;
      //To prevent checkbox click starts -->
      if (event.target !== event.currentTarget) {
        if (checkbox.checked) {
          checkbox.checked = false;
          if (to.className === "slds-checkbox_faux") {
            return (
              this.CheckUncheckForApprove(), this.CheckUncheckForSearchApprove()
            );
          }
        } else {
          if (to.className === "slds-checkbox_faux") {
            checkbox.checked = true;
            return (
              this.CheckUncheckForApprove(), this.CheckUncheckForSearchApprove()
            );
          }
        }
      }
    }

    var insideTr = to.localName;

    if (insideTr === "input") {
      return;
    }

    //To prevent checkbox click Ends -->

    // data-id of row <tr> -- >
    let targetId = event.currentTarget.dataset.id;

    // Display list of rows with class name 'content'
    let rowList = this.template.querySelectorAll(
      `[data-id="${targetId}"],.content`
    );


    var j = rowList.length;
    //Hide show accordion on each row click Starts -->
    for (i = 0; i < j; i++) {
      let row = rowList[i];
      if (
        row.className === "collapsible even" ||
        row.className === "collapsible odd"
      ) {
        if (targetId === row.dataset.id) {

          if (row.style.display === "table-row" || row.style.display === "")
            row.style.display = "none";
          else row.style.display = "table-row";
        }
      } else if (row.className === "content") {
        if (targetId === row.dataset.id) {
          if (row.style.display === "table-row") row.style.display = "none";
          else row.style.display = "table-row";
        }
      }
    }
    //Hide show accordion on each row click Ends -->

    // To get data inside each row based on targetRow Starts -->
    let targetRow = event.currentTarget.cells;
    this.datetime = targetRow[3].textContent;
    if (this.datetime != '') {
      this.date = this.datetime.slice(0, 10);

      this.date = new Date(this.date);
      this.date =
        this.date.getFullYear() +
        "-" +
        (this.date.getMonth() + 1) +
        "-" +
        this.date.getDate();
    } else {
      this.date = '';
    }

    //get data for 'From' Dropdown list as selected option
    this.fromlocation = targetRow[6].textContent;

    //get data for 'To' Dropdown list as selected option
    this.tolocation = targetRow[7].textContent;

    //console.log("Activity: ", targetRow[10].textContent);

    // Show map component on click of each row in table

    // Pass 'from' and 'to' location to child component (c-map-creation-component) based on target row
    this.template
      .querySelector(`c-map-creation-component[data-id="${targetId}"]`)
      .mapAccess();

    if(targetRow[10].textContent != ''){
      this.template
      .querySelector(`c-inline-dropdown[data-id="${targetId}"]`)
      .showOption();
    }
    
    if(targetRow[8].textContent != ''){
      this.template.querySelector(
        `.tags_Input[data-id="${targetId}"]`
      ).value = targetRow[8].textContent;
    }
   // console.log("inline-dropdown", this.template.querySelector(`c-inline-dropdown[data-id="${targetId}"]`));
    // Pass Stored Data to child component functions Starts -->

    let datetimeComponent = this.template.querySelectorAll(
      `[data-id="${targetId}"],.datetimecomponent`
    );
    var datetimelen = datetimeComponent.length;
    for (i = 0; i < datetimelen; i++) {
      let datelist = datetimeComponent[i];
      if (datelist.className === "datetimecomponent") {
        if (targetId === datelist.dataset.id) {
          datelist.getTime(this.date);
        }
      }
    }

    // Pass Stored Data to child component functions Ends -->

    // To get data inside each row based on targetRow Ends -->
  }

  handleTextAreaInput(event){
    this.isNoteClicked = true;
    let tId = event.currentTarget.dataset.id;
    let txtList = this.template.querySelector(
      `textarea[data-id="${tId}"]`
    );
    txtList.value = event.target.value;
   // nList.value = event.target.value;
  }

  handleTagInput(event) {
    this.isTagClicked = true;
    let tId = event.currentTarget.dataset.id;
    let rList = this.template.querySelector(
      `.tags_Input[data-id="${tId}"]`
    );
    rList.value = event.target.value;
  }

  handleStayTimeInput(event){
    event.target.value = event.target.value.replace(/[^\d]/g, '')
    this.isStayTimeClicked = true;
    let sTime = event.currentTarget.dataset.id;
    let sTimeList = this.template.querySelector(
      `.stayTime_Input[data-id="${sTime}"]`
    );
    sTimeList.value = event.target.value;
  }

  // Accordion Save  Button click event
  handleSave(event) {
    var tripID, tagName, activity, note, stayInput, textList, rTagList, stayTimeList, conEmail, tripDate, conName, oldActivity, actualMileage, mileage, chMileage, tripLogApi, tripLogId;
    if(this.isClicked === true || this.isNoteClicked === true || this.isTagClicked === true || this.isStayTimeClicked === true) {
      this.tableSpinner = true;
      this.updatingText = "Updating....";
      let tId = event.currentTarget.dataset.id;
      rTagList = this.template.querySelector(
        `.tags_Input[data-id="${tId}"]`
      );
      textList = this.template.querySelector(
        `textarea[data-id="${tId}"]`
      );
      stayTimeList = this.template.querySelector(
        `.stayTime_Input[data-id="${tId}"]`
      );
      tripID = tId;
      tagName = (rTagList.value === undefined) ? '' : rTagList.value;
      note = (textList.value === undefined) ? '' : textList.value;
      activity = (this.activity === undefined || this.activity === '') ? null : this.activity;
      stayInput = (stayTimeList.value === undefined || stayTimeList.value === '') ? 0 : stayTimeList.value;
      conEmail = event.currentTarget.dataset.email;
      tripDate = event.currentTarget.dataset.trip;
      conName = event.currentTarget.dataset.name;
      oldActivity = event.currentTarget.dataset.old;
      actualMileage = (event.currentTarget.dataset.actual === undefined) ? 0 : event.currentTarget.dataset.actual;
      mileage = (event.currentTarget.dataset.mileage === undefined || event.currentTarget.dataset.mileage === null) ? 0 : event.currentTarget.dataset.mileage;
      tripLogApi = (event.currentTarget.dataset.log === undefined) ? null : event.currentTarget.dataset.log;
      tripLogId = (event.currentTarget.dataset.tripid === undefined) ? null : event.currentTarget.dataset.tripid;
      const itemIndex = event.currentTarget.dataset.index;
      const listOfData = (this.searchData.length != 0 ) ? this.searchData[itemIndex] : this.currentData[itemIndex];
      listOfData.Tags = (this.isTagClicked === true) ? tagName : listOfData.Tags;
      listOfData.Notes = (this.isNoteClicked === true) ? note : listOfData.Notes;
      listOfData.Activity =  (this.isClicked === true) ? activity : listOfData.Activity;
      listOfData.StayTime = (this.isStayTimeClicked === true) ? stayInput : listOfData.StayTime;

      updateMileages({
          tripId: tripID,
          tripTag: tagName,
          activity: activity,
          notes: note,
          staytime: stayInput
        })
        .then((data) => {
          // console.log("updateMileages List", data);
          if (data) {
            // console.log("inside list element")
            const saveEvent = new CustomEvent("handleupdateevent", {
              detail: data
            })
            this.dispatchEvent(saveEvent);
            if(this.isClicked){
              chMileage = this.calculate(activity, actualMileage);
              // console.log("updated mileage->", chMileage);
              updateMileagesEmail({
                adminId: this.contactID,
                tripdate: tripDate,
                conName: conName,
                conEmail: conEmail,
                oldActivity: oldActivity,
                newActivity: activity,
                mileage: mileage,
                actualMileage: actualMileage,
                tripId: tripLogId,
                accApi: tripLogApi
              }).then((data) =>{
                // console.log("updateMileagesEmail",data);
                this.isClicked = false;
                listOfData.Mileage = chMileage;
              })
              this.template.querySelector(`.mileageInput[data-id="${tId}"]`).inputValue = chMileage;
              this.handlecloselookUp(event, tId)
              this.tableSpinner = false;
            }else{
              this.tableSpinner = false;
              this.handlecloselookUp(event, tId)
            }
            this.isNoteClicked = false;
            this.isTagClicked = false;
            this.isStayTimeClicked = false;
          }
        })
        .catch((error) => {
          console.log(error);
        });
    }
    //  console.log("save event: ", this.isClicked, this.isNoteClicked, this.isTagClicked);
   
    // console.log("save event: ", event.currentTarget.dataset.name);
    // console.log("save event: ", event.currentTarget.dataset.old);
    // console.log("save event: ", event.currentTarget.dataset.actual);
    // console.log("save event: ", event.currentTarget.dataset.mileage);
  }

  calculate(newActivity, actualMileage) {
    let tripMileage;
    if (newActivity == 'Commute' && actualMileage >= 30) {
      tripMileage = actualMileage - 30;
    } else if (newActivity == 'Commute') {
      tripMileage = 0;
    } else if (newActivity == 'Business') {
      tripMileage = actualMileage;
    }
    return tripMileage;
  }
  // Click event to close opened row
  handlecloselookUp(event, uId) {
    var i, j;
    let targetId;
    if (uId != undefined) {
      targetId = uId;
    } else {
      targetId = event.currentTarget.dataset.id;
    }

    let closerowList = this.template.querySelectorAll(
      `[data-id="${targetId}"],.content`
    );

    j = closerowList.length;
    //Hide show accordion on each row click
    for (i = 0; i < j; i++) {
      let closerow = closerowList[i];
      if (
        closerow.className === "collapsible even" ||
        closerow.className === "collapsible odd"
      ) {
        if (targetId === closerow.dataset.id) {
          if (
            closerow.style.display === "table-row" ||
            closerow.style.display === ""
          )
            closerow.style.display = "none";
          else closerow.style.display = "table-row";
        }
      } else if (closerow.className === "content") {
        if (targetId === closerow.dataset.id) {
          if (closerow.style.display === "table-row")
            closerow.style.display = "none";
          else closerow.style.display = "table-row";
        }
      }
    }
  }

  // Default Sorting By Date
  defaultSortingByDate(sortArr, keyName) {

    if (!this.reverse) {
      this.reverse = true;
    }
    if (keyName === "ConvertedStartTime__c") {
      sortArr.sort(function (a, b) {
        var dateA =
          a[keyName] == null || undefined ?
          "" :
          new Date(a[keyName].toLowerCase()),
          dateB =
          b[keyName] == null || undefined ?
          "" :
          new Date(b[keyName].toLowerCase());
        //sort string ascending
        if (dateA < dateB) {
          return -1;
        } else if (dateA > dateB) {
          return 1;
        } else {
          return 0;
        }
      });

    }

    return sortArr;

  }
  // Sorting based on header click 'chevronup' and 'chevrondown' icons in table
  updateColumnSorting(event) {
    this.deleteRow();
    this.loadingSpinner = true;
    var header, keyName;
    this.allowSorting = true;
    var targetValue = event.currentTarget.children[0].firstChild;
    setTimeout(() => {
      this.loadingSpinner = false;
      if (targetValue) {
        header = targetValue.data;
        // header = targetelem.parentElement.parentNode.textContent;
        if (header === "Driver") {
          keyName = "Name";
        } else if (header === "From") {
          keyName = "FromLocation";
        } else if (header === "To") {
          keyName = "ToLocation";
        } else if (header === "Mileage") {
          keyName = "Mileage";
        } else if (header === "Date & Time") {
          keyName = "Date";
        } else if (header === "Tags") {
          keyName = "Tags";
        } else if (header === "Notes") {
          keyName = "Notes";
        } else if (header === "Activity") {
          keyName = "Activity";
        }
      }
      if (!this.reverse) {
        this.reverse = true;
        if (
          keyName === "Name" ||
          keyName === "FromLocation" ||
          keyName === "ToLocation" ||
          keyName === "Tags" ||
          keyName === "Notes" || 
          keyName === "Activity"
        ) {
          if (this.searchData.length != 0) {
            this.searchData.sort(function (a, b) {
              var nameA = a[keyName] == null || undefined ?
                "" : a[keyName].toLowerCase(),
                nameB = b[keyName] == null || undefined ?
                "" : b[keyName].toLowerCase();
              //sort string ascending
              if (nameA < nameB) {
                return -1;
              } else if (nameA > nameB) {
                return 1;
              } else {
                return 0;
              }
            });
          } else {
            this.currentData.sort(function (a, b) {
              var nameA = a[keyName] == null || undefined ?
                "" : a[keyName].toLowerCase(),
                nameB = b[keyName] == null || undefined ?
                "" : b[keyName].toLowerCase();
              //sort string ascending
              if (nameA < nameB) {
                return -1;
              } else if (nameA > nameB) {
                return 1;
              } else {
                return 0;
              }
            });
          }
        } else if (keyName === "Mileage") {
          if (this.searchData.length != 0) {
            this.searchData.sort(function (a, b) {
              var floatA = a[keyName] == null || undefined ?
                "" : parseFloat(a[keyName]),
                floatB = b[keyName] == null || undefined ?
                "" : parseFloat(b[keyName]);

              //sort string ascending
              if (floatA < floatB) {
                return -1;
              } else if (floatA > floatB) {
                return 1;
              } else {
                return 0;
              }
            });
          } else {
            this.currentData.sort(function (a, b) {
              var floatA = a[keyName] == null || undefined ?
                "" : parseFloat(a[keyName]),
                floatB = b[keyName] == null || undefined ?
                "" : parseFloat(b[keyName]);

              //sort string ascending
              if (floatA < floatB) {
                return -1;
              } else if (floatA > floatB) {
                return 1;
              } else {
                return 0;
              }
            });
          }
        } else if (keyName === "Date") {
          if (this.searchData.length != 0) {
            this.searchData.sort(function (a, b) {
              var formatDateA = a[keyName] == null || undefined ?
                "" : a[keyName].slice(0, 9),
                formatDateB = b[keyName] == null || undefined ?
                "" : b[keyName].slice(0, 9);
              var dateA = formatDateA == "" ? "" : new Date(formatDateA.toLowerCase()),
                dateB = formatDateB == "" ? "" : new Date(formatDateB.toLowerCase());
              //sort string ascending
              const searchTime12to24 = (time12h, cdate) => {
							if(typeof cdate === 'object'){
                const [time, modifier] = time12h.split(' ');

                let [hours, minutes] = time.split(':');

                if (hours === '12') {
                  hours = '00';
                }

                if (modifier === 'PM') {
                  hours = parseInt(hours, 10) + 12;
                }
                let seconds = '00'
                cdate.setHours(hours, minutes, seconds);
							}
                return cdate
                //return `${hours}:${minutes}`;
              }

              let timeA = searchTime12to24(a.StartTime, dateA),
                time = searchTime12to24(b.StartTime, dateB);
              if (dateA < dateB) {
                return -1;
              } else if (dateA > dateB) {
                return 1;
              } else {
                return 0;
              }
            });
          } else {
            this.currentData.sort(function (a, b) {
              var formatDateA = a[keyName] == null || undefined ?
                "" : a[keyName].slice(0, 9),
                formatDateB = b[keyName] == null || undefined ?
                "" : b[keyName].slice(0, 9);

              var dateA = formatDateA == "" ? "" : new Date(formatDateA.toLowerCase()),
                dateB = formatDateB == "" ? "" : new Date(formatDateB.toLowerCase());

              const Time12to24 = (time12h, cdate) => {
                if(typeof cdate === 'object'){
                  const [time, modifier] = time12h.split(' ');

                  let [hours, minutes] = time.split(':');

                  if (hours === '12') {
                    hours = '00';
                  }

                  if (modifier === 'PM') {
                    hours = parseInt(hours, 10) + 12;
                  }
                  let seconds = '00'
                  cdate.setHours(hours, minutes, seconds);
                }
                return cdate
                //return `${hours}:${minutes}`;
              }

              let timeA = Time12to24(a.StartTime, dateA),
                time = Time12to24(b.StartTime, dateB);
              //sort string ascending
              if (dateA < dateB) {
                return -1;
              } else if (dateA > dateB) {
                return 1;
              } else {
                return 0;
              }
            });
          }
        }
      } else {
        this.reverse = false;
        if (
          keyName === "Name" ||
          keyName === "FromLocation" ||
          keyName === "ToLocation" ||
          keyName === "Tags" ||
          keyName === "Notes" || 
          keyName === "Activity"
        ) {
          if (this.searchData.length != 0) {
            this.searchData.sort(function (a, b) {
              var nameA = a[keyName] == null || undefined ?
                "" : a[keyName].toLowerCase(),
                nameB = b[keyName] == null || undefined ?
                "" : b[keyName].toLowerCase();
              //sort string descending
              if (nameA < nameB) {
                return 1;
              } else if (nameA > nameB) {
                return -1;
              } else {
                return 0;
              }
            });
          } else {
            this.currentData.sort(function (a, b) {
              var nameA = a[keyName] == null || undefined ?
                "" : a[keyName].toLowerCase(),
                nameB = b[keyName] == null || undefined ?
                "" : b[keyName].toLowerCase();
              //sort string descending
              if (nameA < nameB) {
                return 1;
              } else if (nameA > nameB) {
                return -1;
              } else {
                return 0;
              }
            });
          }
        } else if (keyName === "Mileage") {
          if (this.searchData.length != 0) {
            this.searchData.sort(function (a, b) {
              var floatA = a[keyName] == null || undefined ?
                "" : parseFloat(a[keyName]),
                floatB = b[keyName] == null || undefined ?
                "" : parseFloat(b[keyName]);

              //sort string descending
              if (floatA < floatB) {
                return 1;
              } else if (floatA > floatB) {
                return -1;
              } else {
                return 0;
              }
            });
          } else {
            this.currentData.sort(function (a, b) {
              var floatA = a[keyName] == null || undefined ?
                "" : parseFloat(a[keyName]),
                floatB = b[keyName] == null || undefined ?
                "" : parseFloat(b[keyName]);

              //sort string descending
              if (floatA < floatB) {
                return 1;
              } else if (floatA > floatB) {
                return -1;
              } else {
                return 0;
              }
            });
          }
        } else if (keyName === "Date") {
          if (this.searchData.length != 0) {
            this.searchData.sort(function (a, b) {
              var formatDateA = a[keyName] == null || undefined ?
                "" : a[keyName].slice(0, 9),
                formatDateB = b[keyName] == null || undefined ?
                "" : b[keyName].slice(0, 9);

              var dateA = formatDateA == "" ? "" : new Date(formatDateA.toLowerCase()),
                dateB = formatDateB == "" ? "" : new Date(formatDateB.toLowerCase());

              const searchconvertTime12to24 = (time12h, cdate) => {
								console.log("date--", cdate)
									if(typeof cdate === 'object'){
											 const [time, modifier] = time12h.split(' ');
												let [hours, minutes] = time.split(':');

												if (hours === '12') {
													hours = '00';
												}

												if (modifier === 'PM') {
													hours = parseInt(hours, 10) + 12;
												}
												let seconds = '00'
												cdate.setHours(hours, minutes, seconds);
									}
               
                return cdate
                //return `${hours}:${minutes}`;
              }

              var time12 = searchconvertTime12to24(a.StartTime, dateA),
                timeB12 = searchconvertTime12to24(b.StartTime, dateB);
              //sort string descending
              if (dateA < dateB) {
                return 1;
              } else if (dateA > dateB) {
                return -1;
              } else {
                return 0;
              }
            });
          } else {
            this.currentData.sort(function (a, b) {
              var formatDateA = a[keyName] == null || undefined ?
                "" : a[keyName].slice(0, 9),
                formatDateB = b[keyName] == null || undefined ?
                "" : b[keyName].slice(0, 9);

              var dateA = formatDateA == "" ? "" : new Date(formatDateA.toLowerCase()),
                dateB = formatDateB == "" ? "" : new Date(formatDateB.toLowerCase());

              const convertTime12to24 = (time12h, cdate) => {
										if(typeof cdate === 'object'){
												const [time, modifier] = time12h.split(' ');

												let [hours, minutes] = time.split(':');

												if (hours === '12') {
													hours = '00';
												}

												if (modifier === 'PM') {
													hours = parseInt(hours, 10) + 12;
												}
												let seconds = '00'
												cdate.setHours(hours, minutes, seconds);
										}
                return cdate
                //return `${hours}:${minutes}`;
              }

              var time12 = convertTime12to24(a.StartTime, dateA),
                timeB12 = convertTime12to24(b.StartTime, dateB);

              //sort string descending
              if (dateA < dateB) {
                return 1;
              } else if (dateA > dateB) {
                return -1;
              } else {
                return 0;
              }
            });
          }
        }
      }
    }, 1000)
  }

  //function to display data based on advance search
  setSearchRecordsToDisplay() {
    if (!this.loadingSpinner) {
      this.loadingSpinner = true;
    }
   setTimeout(() => {
      this.loadingSpinner = false;
      this.isloadingText = false;
      if (this.pageClick) {
        this.pageClick = false;
      }
    }, 400);
    this.searchData = [];
    var mileagecount = 0;
    this.totalmileage = 0;
    //console.log(this.searchallList)
    this.searchData = formatData(this.searchallList, this.plID, this.accountID);
    if (this.searchData.length != 0) {
      this.searchData.forEach((value) => {
        mileagecount = mileagecount + parseFloat(value.Mileage);
        mileagecount =
          Math.round(
            parseFloat((mileagecount * Math.pow(10, 2)).toFixed(2))
          ) / Math.pow(10, 2);
      });

      this.totalmileage = mileagecount;
    }
  }

  validateState(stateVal) {
    var regDigit = /\b\d{5}\b/g,
      tripSate, bool;
    bool = /^[0-9,-.]*$/.test(stateVal);
    if (!bool) {
      let state = stateVal;
      let digit = state.slice(-5);
      if (digit.match(regDigit)) {
        tripSate = stateVal.slice(-9);
      } else {
        tripSate = '';
      }
    } else {
      tripSate = '';
    }

    return tripSate;
  }
  // Pagination event
  pageEventClick(event) {
    this.pageClick = true;
    this.isRowSplitterExcecuted = false;
    let page = event.detail;
    this.rowOffSet = page;
    this.rowOffSet = (this.rowOffSet - 1) * this.rowLimit
    this.template.querySelector(".CheckUncheckAll").checked = false;
    if (this.searchData.length != 0) {
      console.log("inside row action", this.rowOffSet, this.rowLimit);
      const rowAction = new CustomEvent("rowactionevent", {
        detail: {
          rowLimit: this.rowLimit,
          rowOffSet: this.rowOffSet
        }
      })
      this.dispatchEvent(rowAction);
    } else {
			console.log("inside row action not search", this.rowOffSet, this.rowLimit);
      this.apexMethodCall(undefined, this.rowLimit, this.rowOffSet);
    }

  }


  // from filter modal event passed
  handleCSVEvent(event) {
    if (event.detail) {
      const excelEvent = new CustomEvent("handleexportexcelevent", {
        detail: "Excel Event"
      });
      this.dispatchEvent(excelEvent);
    }
  }
  //function to display default data
  setRecordsToDisplay() {
    if (!this.loadingSpinner) {
      this.loadingSpinner = true;
    }

    setTimeout(() => {
     this.loadingSpinner = false;
      this.isloadingText = false;
      if (this.pageClick) {
        this.pageClick = false;
      }
    }, 400);

    this.isRenderCallbackActionExecuted = true;
    var mileagecount = 0;

    this.currentData = [];
    // console.log("from records display",this.currentData.length);
    this.totalmileage = 0;

    let apexData = [];
    apexData = JSON.parse(JSON.stringify(this.wiredData));
    //apexData = this.defaultSortingByDate(apexData, "ConvertedStartTime__c");
    // this.totalrows = apexData.length;
    this.currentData = formatData(apexData, this.plID, this.accountID);

    // console.log('Modified', this.currentData);
    if (this.currentData.length != 0) {
      this.currentDataLength = true;
      this.currentData.forEach((value) => {
        mileagecount = mileagecount + parseFloat(value.Mileage);
        mileagecount =
          Math.round(
            parseFloat((mileagecount * Math.pow(10, 2)).toFixed(2))
          ) / Math.pow(10, 2);
      });

      this.totalmileage = mileagecount;
    } else {
      this.currentDataLength = false;
    }



  }

  actionForPerPage = (pageEntry) => {
    this.isPerPageActionExecuted = true;
    this.isRowSplitterExcecuted = false;
    this.rowLimit = pageEntry;
    this.template.querySelector(".CheckUncheckAll").checked = false;
    if (this.searchData.length != 0) {
      this.rowOffSet = 0;
      const perPageAction = new CustomEvent("perpageactionevent", {
        detail: {
          rowLimit: this.rowLimit,
          rowOffSet: this.rowOffSet
        }
      })
      this.dispatchEvent(perPageAction);
      //this.setSearchRecordsToDisplay();
    } else {
      this.template.querySelector("c-paginator").defaultPageSize(this.dataSize, this.rowLimit);
      this.apexMethodCall(undefined, this.rowLimit, this.rowOffSet);
      //this.setRecordsToDisplay();
    }

  }
  // Change event of display number of records in table based on dropdown values
  handleRecordsPerPage(event) {
    var $pageNo;
    $pageNo = parseInt(event.target.value);
    setTimeout(() => {
      this.actionForPerPage($pageNo);
    }, 2)
  }

  // Click event to check all checkbox checked in table
  IsAllCheckForApprove(event) {
    //console.log('checkbox checked for All', event);
    // process.exit(0);
    var checkbox = this.template.querySelectorAll(".checkboxCheckUncheck");
    var checkbox2 = this.template.querySelectorAll(
      ".checkboxCheckUncheckSearch"
    );
    if (this.searchData.length != 0) {
      if (event.target.checked === true) {
        checkbox2.forEach(value => {
          value.checked = true;
        });
        this.CheckUncheckForSearchApprove();
      } else {
        checkbox2.forEach(value => {
          value.checked = false;
        });
      }
    } else {
      if (event.target.checked === true) {
        //  console.time("foreach")
        checkbox.forEach(value => {
          value.checked = true;
        });
        // console.timeEnd("foreach");
        this.CheckUncheckForApprove();
      } else {
        checkbox.forEach(value => {
          value.checked = false;
        });
      }
    }
  }

  //Click event to check single checkbox checked for advance search data
  CheckUncheckForSearchApprove() {
    var checkboxlist = this.template.querySelectorAll(
      ".checkboxCheckUncheckSearch"
    );
    var approveCheckForSearch = [];

    checkboxlist.forEach((list, index) => {
      if (list.checked === true) {
        if (this.searchData[index].id === list.dataset.id) {
          approveCheckForSearch.push({
            Id: list.dataset.id,
            employeeEmailId: this.searchData[index].emailID,
          });
        }
      }
    });
    this.approveRejectCheckSearch = approveCheckForSearch;
    if (this.approveRejectCheckSearch != 0) {
      const approveRejectSearch = new CustomEvent(
        "handleapproverejectsearchevent", {
          detail: this.approveRejectCheckSearch,
        }
      );

      this.dispatchEvent(approveRejectSearch);
    }
  }

  //Click event to check single checkbox checked for default data
  CheckUncheckForApprove() {
    var checkboxlist = this.template.querySelectorAll(".checkboxCheckUncheck");
    var approveCheck = [];
    //  chkblistlen = checkboxlist.length;

    checkboxlist.forEach((list, index) => {
      if (list.checked === true) {
        if (this.currentData[index].id === list.dataset.id) {
          approveCheck.push({
            Id: list.dataset.id,
            employeeEmailId: this.currentData[index].emailID,
          });
        }
      }
    });
    this.approveRejectCheck = approveCheck;

    if (this.approveRejectCheck) {
      const approveReject = new CustomEvent("handleapproverejectevent", {
        detail: this.approveRejectCheck
      });
      this.dispatchEvent(approveReject);
    }
  }

  // Style row based on approve and reject trips
  RowStatusStyle() {
    // console.log('RowStatusStyle');
    var row = this.template.querySelectorAll(".collapsible");
    if (this.searchData.length != 0) {
      // var j = this.searchData.length;
      this.searchData.forEach((rowItem, index) => {
        var routeicon = this.template.querySelectorAll('.ms-help-icon');
        if ((rowItem.FromLatitude === undefined && rowItem.FromLongitude === undefined &&
          rowItem.ToLatitude === undefined && rowItem.ToLongitude === undefined) || (rowItem.FromLatitude === 0 && rowItem.FromLongitude === 0 &&
            rowItem.ToLatitude === 0 && rowItem.ToLongitude === 0) || (rowItem.FromLatitude === 0 && rowItem.FromLongitude === 0 ||
            rowItem.ToLatitude === 0 && rowItem.ToLongitude === 0)) {
          if (row[index].dataset.id === routeicon[index].dataset.id) {
            routeicon[index].classList.add('slds-hide');
          }
        } else {
          routeicon[index].classList.remove('slds-hide')
        }

        if (rowItem.TripStatus === "Approved") {
          this.statusAppImg = LwcDesignImage + "/LwcImages/status_Approve.png";
          let imgAppClass = this.template.querySelectorAll(".statusApImage");
          if (rowItem.id === row[index].dataset.id) {
            row[index].style.backgroundColor = "#b3ffe6";
            if (row[index].dataset.id === imgAppClass[index].dataset.id) {
              imgAppClass[index].style.display = "block";
            }
          }
        } else if (rowItem.TripStatus === "Rejected") {
          let imgRejClass = this.template.querySelectorAll(".statusRejImage");
          this.statusRejImg = LwcDesignImage + "/LwcImages/status_Reject.png";
          if (rowItem.id === row[index].dataset.id) {
            row[index].style.backgroundColor = "#f4a4a4";
            if (row[index].dataset.id === imgRejClass[index].dataset.id) {
              imgRejClass[index].style.display = "block";
            }
          }
        }
      })
    } else {
      // console.log('RowStatusStyle current data');

      this.currentData.forEach((rowElem, ind) => {
        // console.log(rowElem.Name,rowElem.Mileage,rowElem.TripStatus,rowElem.StartTime)
        var routeicon = this.template.querySelectorAll('.ms-help-icon');
        if ((rowElem.FromLatitude === undefined && rowElem.FromLongitude === undefined &&
          rowElem.ToLatitude === undefined && rowElem.ToLongitude === undefined) || (rowElem.FromLatitude === 0 && rowElem.FromLongitude === 0 &&
          rowElem.ToLatitude === 0 && rowElem.ToLongitude === 0) || (rowElem.FromLatitude === 0 && rowElem.FromLongitude === 0 ||
            rowElem.ToLatitude === 0 && rowElem.ToLongitude === 0)) {
          if (row[ind].dataset.id === routeicon[ind].dataset.id) {
            routeicon[ind].classList.add('slds-hide');
          }
        } else {
          routeicon[ind].classList.remove('slds-hide')
        }
        if (rowElem.TripStatus === "Approved") {
          this.statusAppImg = LwcDesignImage + "/LwcImages/status_Approve.png";
          let imgAppClass = this.template.querySelectorAll(".statusApImage");
          if (rowElem.id === row[ind].dataset.id) {
            row[ind].style.backgroundColor = "#b3ffe6";
            if (row[ind].dataset.id === imgAppClass[ind].dataset.id) {
              imgAppClass[ind].style.display = "block";
            }
          }
        } else if (rowElem.TripStatus === "Rejected") {
          let imgRejClass = this.template.querySelectorAll(".statusRejImage");
          this.statusRejImg = LwcDesignImage + "/LwcImages/status_Reject.png";
          if (rowElem.id === row[ind].dataset.id) {
            row[ind].style.backgroundColor = "#f4a4a4";
            if (row[ind].dataset.id === imgRejClass[ind].dataset.id) {
              imgRejClass[ind].style.display = "block";
            }
          }
        }
      });
    }
  }

  showTripModal(dataOfTrip){
    const modalTrip = new CustomEvent("handletripmodal",{
      detail: JSON.stringify(dataOfTrip)
    });
    this.dispatchEvent(modalTrip);
  }
  // Send formatted excel data to child component 'c-excel-sheet'
  xlsFormatter(data) {
    let Header = Object.keys(data[0]);
    if(Header.includes("ActualMileage")){
      Header[5] = "Start Time";
      Header[6] = "End Time";
      Header[7] = "Stay Time";
      Header[8] = "Drive Time";
      Header[9] = "Total Time";
      Header[11] = "Actual Mileage";
      Header[12] = "Mileage (mi)";
      Header[13] = "From Location Name";
      Header[14] = "From Location Address";
      Header[15] = "To Location Name";
      Header[16] = "To Location Address";
      Header[20] = "Tracking Method";
    }else{
      Header[5] = "Start Time";
      Header[6] = "End Time";
      Header[7] = "Stay Time";
      Header[8] = "Drive Time";
      Header[9] = "Total Time";
      Header[11] = "Mileage (mi)";
      Header[12] = "From Location Name";
      Header[13] = "From Location Address";
      Header[14] = "To Location Name";
      Header[15] = "To Location Address";
      Header[19] = "Tracking Method";
    }
    
    if(this.xlsHeader.length > 0){
      this.xlsHeader = [];
      this.xlsHeader.push(Header);
    }else{
      this.xlsHeader.push(Header);
    }
    if(this.xlsData.length > 0){
      this.xlsData = [];
      this.xlsData.push(data);
    }else{
      this.xlsData.push(data);
    }
    //console.log("from data table",this.xlsData);
    this.template.querySelector("c-excel-sheet").download(this.xlsHeader, this.xlsData);
  }

  // function to format date with week day
  fullDateFormat(rowObj) {
    if (rowObj.ConvertedStartTime__c != undefined) {
      let newdate = new Date(rowObj.ConvertedStartTime__c);
      let dayofweek;
      let dd = newdate.getDate();
      let mm = newdate.getMonth() + 1;
      let yy = newdate.getFullYear();
      if (rowObj.Day_Of_Week__c != undefined) {
        dayofweek = rowObj.Day_Of_Week__c.toString().slice(0, 3);
      } else {
        dayofweek = "";
        dayofweek = dayofweek.toString();
      }
      return mm + "/" + ("0" + dd).slice(-2) + "/" + yy + " " + dayofweek;
    } else {
      return "";
    }
  }
  // function to format date
  dateFormat(rowObj) {
    if (rowObj.ConvertedStartTime__c != undefined) {
      let newdate = new Date(rowObj.ConvertedStartTime__c);
      let dd = newdate.getDate();
      let mm = newdate.getMonth() + 1;
      let yy = newdate.getFullYear();

      return mm + "/" + dd + "/" + yy;
    } else {
      return "";
    }
  }

  // Trip Status Tooltip Starts
  handleMouseEnter(event) {
    let targetId = event.target.dataset.id;
    this.template
      .querySelector(`c-tooltip-component[data-id="${targetId}"]`)
      .classList.remove("slds-hide");
  }
  handleMouseLeave(event) {
    let targetId = event.target.dataset.id;
    this.template
      .querySelector(`c-tooltip-component[data-id="${targetId}"]`)
      .classList.add("slds-hide");
  }
  // Trip Status Tooltip Ends

  // function to format time
  TimeFormat(timeObj) {
    if (timeObj != undefined) {
      let startendTime = new Date(timeObj);
      let convertedTime = startendTime.toLocaleTimeString("en-US", {
        timeZone: "America/Panama",
        hour: "2-digit",
        minute: "2-digit",
      });
      return convertedTime;
    } else {
      return "";
    }
  }

  // Dynamic row creation
  createRow(rowElem) {
    rowElem.classList.add("list-split-top");
    var table = this.template.querySelector(".accordion_table");
    var extraRow = table.insertRow(rowElem.rowIndex);
    extraRow.className = "extra_row";
    var cell = extraRow.insertCell(0);
    cell.setAttribute("colspan", "11");
    cell.style["padding"] = "0px";
    cell.style["line-height"] = "0px";
    cell.innerHTML =
      "<div class='row_splitter' style='height: 8px;background-color: #ffffff;border-right: 1px solid #dfdfdf;border-top: #dfdfdf 1px solid'></div>";
  }

  // Delete Unused rows from table
  deleteRow() {
    var i, tblRowLen;
    var table = this.template.querySelector(".accordion_table");
    var tableRow = table.rows;

    tblRowLen = tableRow.length;
    for (i = tblRowLen; i > 0; i--) {
      if (tableRow[i] != undefined) {
        if (tableRow[i].className === "extra_row") {
          table.deleteRow(i);
        }
      }
    }
    this.isPerPageActionExecuted = false;
  }

  // Row Splitter after every new date
  rowSplitter() {
    this.isRowSplitterExcecuted = true;
    var i,
      extraRow,
      rowslen,
      regExp = /(\d{1,4}([.\-/])\d{1,2}([.\-/])\d{1,4})/g;
    extraRow = this.template.querySelectorAll(".collapsible");
    rowslen = extraRow.length;
    if (!this.allowSorting) {
      if (rowslen > 0) {
        for (i = 0; i < rowslen; i++) {
          let beforeRow = extraRow[i];
          let afterRow = extraRow[i + 1];
          if (beforeRow != undefined && afterRow != undefined) {
            let beforeRowDate = new Date(
              beforeRow.cells[3].textContent.match(regExp)
            );
            let afterRowDate = new Date(
              afterRow.cells[3].textContent.match(regExp)
            );
            if (beforeRowDate < afterRowDate) {
              this.createRow(afterRow);
            }
          }
        }
      }
    }
    if (this.searchFlag || this.isPerPageActionExecuted || this.isSend) {
      this.isRowSplitterExcecuted = false;
    }
  }


  // fires when a component is inserted into the DOM.
  connectedCallback() {
    // console.log("Time Zone is: " + this.tz);
    // console.log("Locale is: " + this.ln);
    this.getDataSize();
    if (this.pageSizeOptions && this.pageSizeOptions.length > 0) {
      this.selectBool = true;
      this.pageSize = this.pageSizeOptions[2];
      this.rowLimit = this.pageSize;
      this.mileageRowLimit = this.pageSize;
    }
    this.apexMethodCall(undefined, this.rowLimit, this.rowOffSet);
  }

  // fires after every render of the component.
  renderedCallback() {
    if (this.selectBool) {
      let selected = this.template.querySelector('.recordperpageSelect');
      selected.value = this.pageSizeOptions[2];
      this.selectBool = false;
    }
    var i, rowslen;
    if (this.isPerPageActionExecuted || this.searchFlag || this.pageClick || this.isSend) {
      this.deleteRow();
    }
    if (!this.isRenderCallbackActionExecuted && !this.isRowSplitterExcecuted) {
      this.rowSplitter();
    }

    let rows = [];
    rows = this.template.querySelectorAll(".collapsible");
    rowslen = rows.length;
    // avoid change in row style while sorting
    //if (!this.allowSorting) {
    if (rowslen > 0) {
      for (i = 0; i < rowslen; i++) {
        let even_row = rows[i * 2];
        let odd_row = rows[i * 2 + 1];
        if (even_row != undefined) {
          even_row.classList.add("even");
        }
        if (odd_row != undefined) {
          odd_row.classList.add("odd");
        }
      }

      this.RowStatusStyle();
    }
    // }
    this.isRenderCallbackActionExecuted = false;
  }
}