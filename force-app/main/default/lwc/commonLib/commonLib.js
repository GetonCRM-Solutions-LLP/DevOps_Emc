/* eslint-disable no-unused-expressions */
/* eslint-disable vars-on-top */
/* eslint-disable consistent-return */
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const showMessage = (page, t, m,type ) => {
    const toastEvt = new ShowToastEvent({
        title: t,
        message:m,
        variant: type
    });
    page.dispatchEvent(toastEvt);
};

const isValidForm = (elements) => {
        var isFormValid=true;
        const allValid = elements.reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
        if (!allValid) {
            isFormValid=false;
        }
        return isFormValid;
};

const typeOfTrip = (list, adId) => {
  var listType = {};
  listType.id = list.id;
  listType.adminId = adId;
  listType.tripdate = list.tripDate;
  listType.conName = list.Name;
  listType.conEmail = list.emailID;
  listType.oldActivity = list.Activity;
  listType.mileage = list.Mileage;
  listType.actualMileage = (list.ActualMileage === undefined) ? 0 : list.ActualMileage;
  listType.tripId = list.TripId;
  listType.accApi = list.TripLogApi;
  return listType;
}
const formatData = (data, pID, aID) => {
    var  tripData = [];
    data.forEach((row) => {
        var dayOfWeek;
        let rowData = {};
        let formatDate = fullDateFormat(row, pID, aID);
        let userDate = dateFormat(row);
        if (row.Day_Of_Week__c !== undefined) {
            dayOfWeek = row.Day_Of_Week__c.toString().slice(0, 3);
        } else {
            dayOfWeek = "";
            dayOfWeek = dayOfWeek.toString();
        }
        let strTime = TimeFormat(row.ConvertedStartTime__c);
        let enTime = TimeFormat(row.ConvertedEndTime__c);
        rowData.id = row.Id;
        rowData.TripId = row.Trip_Id__c;
        rowData.Mileage = (row.Mileage__c === undefined) ? 0 : row.Mileage__c.toString();
        if(pID === aID){
          rowData.ActualMileage = (row.EMP_Mileage__c === undefined) ? 0 : row.EMP_Mileage__c.toString();
        }
        rowData.TripOrigin = row.Trip_Origin__c;
        rowData.TripDestination = row.Trip_Destination__c;
        if (row.Trip_Destination__c != undefined) {
          let getState = validateState(row.Trip_Destination__c);
          rowData.State = getState.slice(0, 2);
        }
        rowData.TriplogMap = row.Triplog_Map__c;
        rowData.TimeZone = row.TimeZone__c;
        rowData.TripStatus = row.Trip_Status__c;
        let convDate = '';
        if(row.Approved_Date__c != null) {
             let chunksDate = (row.Approved_Date__c.toString()).split('-');
             convDate = (chunksDate[1] + '/' + chunksDate[2] + '/' + (chunksDate[0] % 100));
        }
        rowData.ProcessBy = row.Trip_Status__c != null ? (row.Approval_Name__c == 'Tom Honkus' ? 'By System' : row.Approval_Name__c) : '';
        rowData.ProcessDate = row.Trip_Status__c != null ? convDate : '';
        if (row.Way_Points__c != undefined) {
          rowData.waypoint = row.Way_Points__c;
        }
  
        rowData.FromLocation = row.Origin_Name__c;
        rowData.OriginalFromLocation = row.Original_Origin_Name__c;
        rowData.ToLocation = row.Destination_Name__c;
        rowData.OriginalToLocation = row.Original_Destination_Name__c;
        rowData.Day = dayOfWeek;
        rowData.userdate = userDate.toString();
        rowData.tripDate = (row.Trip_Date__c === undefined) ? '' : row.Trip_Date__c;
        rowData.StartTime = strTime.toString();
        rowData.EndTime = enTime.toString();
        rowData.Date = formatDate.toString();
        rowData.Time =
          enTime === "" ?
          strTime.toString() :
          strTime === "" ?
          enTime.toString() :
          strTime.toString() + " " + "-" + " " + enTime.toString();
        rowData.Tags = (row.Tag__c === undefined) ? '' : row.Tag__c;
        rowData.Notes = (row.Notes__c === undefined) ? '' : row.Notes__c; 
        rowData.Activity = (row.Activity__c === undefined) ? '' : row.Activity__c;
        rowData.TrackingMethod = row.Tracing_Style__c;
        rowData.DriveTime = (row.Driving_Time__c === undefined) ? '' : row.Driving_Time__c;
        rowData.StayTime = (row.Stay_Time__c === undefined) ? '' : row.Stay_Time__c;
        rowData.TotalTime = (row.Drive_Stay_Time__c === undefined) ? '' : row.Drive_Stay_Time__c;
        rowData.FromLatitude = row.From_Location__Latitude__s;
        rowData.FromLongitude = row.From_Location__Longitude__s;
        rowData.ToLatitude = row.To_Location__Latitude__s;
        rowData.ToLongitude = row.To_Location__Longitude__s;
  
        if (row.EmployeeReimbursement__r) {
          rowData.TripLogApi = row.EmployeeReimbursement__r.Contact_Id__r.Account.Triplog_API__c;
          if (
            row.EmployeeReimbursement__r.Contact_Id__r.External_Email__c === undefined
          ) {
            rowData.emailID = '';
          } else {
            rowData.emailID =
              row.EmployeeReimbursement__r.Contact_Id__r.External_Email__c;
          }
        }
        if (row.EmployeeReimbursement__c) {
          rowData.Name = row.EmployeeReimbursement__r.Contact_Id_Name__c;
          rowData.VehicleType =
            row.EmployeeReimbursement__r.Contact_Id__r.Vehicle_Type__c;
        }
  
        tripData.push(rowData);
      });

      return tripData;
}

const excelData = (exlData) => {
   var exportData = {};
   exportData.Driver = exlData.Name,
   exportData.Email = exlData.emailID,
   exportData.Status = exlData.TripStatus,
   exportData.Date = exlData.userdate,
   exportData.Day = exlData.Day,
   exportData.StartTime = exlData.StartTime,
   exportData.EndTime = exlData.EndTime,
   exportData.StayTime = exlData.StayTime,
   exportData.DriveTime = exlData.DriveTime,
   exportData.TotalTime = exlData.TotalTime,
   exportData.Activity = exlData.Activity
   if(exlData.ActualMileage !==undefined){
    exportData.ActualMileage = exlData.ActualMileage
   }
   exportData.Mileage = exlData.Mileage,
   exportData.FromLocationName = exlData.OriginalFromLocation,
   exportData.FromLocationAddress = exlData.TripOrigin,
   exportData.ToLocationName = exlData.OriginalToLocation,
   exportData.ToLocationAddress = exlData.TripDestination,
   exportData.State = exlData.State,
   exportData.Tags = exlData.Tags,
   exportData.Notes = exlData.Notes,
   exportData.TrackingMethod = exlData.TrackingMethod
  return exportData;
}
const changeKeyObjects = (csvData) => {
  var filterCSVData = [];
  csvData.forEach((excel) => {
  var replaceKey = {};
  replaceKey.Driver = excel.Name;
  replaceKey.Email = excel.emailID;
  replaceKey.Status = excel.TripStatus;
  replaceKey["Process By"] = excel.ProcessBy;
  replaceKey["Process Date"] = excel.ProcessDate;
  replaceKey.Date = excel.userdate;
  replaceKey.Day = excel.Day;
  replaceKey["Start Time"] = excel.StartTime;
  replaceKey["End Time"] = excel.EndTime;
  replaceKey["Stay Time"] = excel.StayTime;
  replaceKey["Drive Time"] = excel.DriveTime;
  replaceKey["Total Time"] = excel.TotalTime;
  replaceKey.Activity = excel.Activity;
  replaceKey["Tracking Method"] = excel.TrackingMethod;
  replaceKey["Mileage (mi)"] = excel.Mileage;
  replaceKey["From Location Name"] = excel.OriginalFromLocation;
  replaceKey["From Location Address"] = excel.TripOrigin;
  replaceKey["To Location Name"] = excel.OriginalToLocation;
  replaceKey["To Location Address"] = excel.TripDestination;
  replaceKey.State = excel.State;
  replaceKey.Tags = excel.Tags;
  replaceKey.Notes = excel.Notes;
  filterCSVData.push(replaceKey);

  });

  return filterCSVData;
}
const excelFormatDate =(exlDate)=>{
  var today = new Date(exlDate);
  var dd = String(today.getDate()).padStart(2, '0');
  var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
  var yyyy = today.getFullYear();

  today = yyyy + '-' + mm + '-' + dd;
  return today;
}

const toDate = (db) => {
  var today = new Date(db);
  var dd = String(today.getDate()).padStart(2, '0');
  var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
  var yyyy = today.getFullYear().toString().substring(2);

  today = mm + '/' + dd + '/' + yyyy;
  return today;
}

const validateDate=(dob)=>{
  var filterDate = dob;
  var date = new Date(filterDate);
  var dd = date.getDate();
  var mm = date.getMonth() + 1;
  var yy = date.getFullYear();
  var dateModified = mm + "/" + dd + "/" + yy;
  return dateModified;
}

const dateTypeFormat =(dt)=>{
  var tDate = dt;
  var td = new Date(tDate);
 // var tdd = td.getDate();
  var tmm = td.getMonth() + 1;
  var tyy = td.getFullYear();
 // tdd = (tdd < 10) ? ('0' + tdd) : tdd;
  tmm = (tmm < 10) ? ('0' + tmm) : tmm;
  var dateReturn = tmm + "-" + tyy;
  return dateReturn;
}

const yearMonthDate = (ydt) => {
  var yearDate = ydt;
  var yd = new Date(yearDate);
  var ydd = yd.getDate();
  var ymm = yd.getMonth() + 1;
  var yyy = yd.getFullYear();
  ydd = (ydd < 10) ? ('0' + ydd) : ydd;
  ymm = (ymm < 10) ? ('0' + ymm) : ymm;
  var yearDateReturn = yyy + "-" + ymm + "-" + ydd;
  return yearDateReturn;
}

const dateString = (dt) =>{
  var dateArr = dt.split('-');
  var yyyy, mm, dd
  if(dateArr.length === 3){
    yyyy = dateArr[0];
    mm = dateArr[1].replace(/^0+/, '');
    dd = dateArr[2];
  }

  return mm + '/' + dd + '/' + yyyy;
}
   // function to format date with week day
  const fullDateFormat=(rowObj, plmarketing, accountId) => {
    if(plmarketing === accountId) {
      if (rowObj.Trip_Date__c != undefined) {
        let tripDate = dateString(rowObj.Trip_Date__c);
        let dayofweek;
        if (rowObj.Day_Of_Week__c != undefined) {
          dayofweek = rowObj.Day_Of_Week__c.toString().slice(0, 3);
        } else {
          dayofweek = "";
          dayofweek = dayofweek.toString();
        }

        return tripDate + " " + dayofweek;
      } 
        return "";
      
    }
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
      } 
        return "";
      
    
    
  }
  // function to format date
  const dateFormat = (rowObj) => {
    if (rowObj.ConvertedStartTime__c != undefined) {
      let newdate = new Date(rowObj.ConvertedStartTime__c);
      let dd = newdate.getDate();
      let mm = newdate.getMonth() + 1;
      let yy = newdate.getFullYear();

      return mm + "/" + dd + "/" + yy;
    } 
      return "";
    
  }

    // function to format time
    const TimeFormat = (timeObj) => {
      if (timeObj !== undefined) {
        let startendTime = new Date(timeObj);
        let convertedTime = startendTime.toLocaleTimeString("en-US", {
          timeZone: "America/Panama",
          hour: "2-digit",
          minute: "2-digit",
        });
        return convertedTime;
      } 
        return "";
      
    }

    const validateState = (stateVal) => {
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

    const formatDateOfMessage = (date) => {
      var d = new Date(date),
          month = '' + (d.getMonth() + 1),
          day = '' + d.getDate(),
          year = d.getFullYear();
  
      if (month.length < 2) 
          month = '0' + month;
      if (day.length < 2) 
          day = '0' + day;
  
      return [year, month, day].join('-');
  }

    const formatList = (reList) => {
      if (reList.length > 0) {
        const newData = [...new Set(reList.map(d => d.Date))].map(Dt => {
          return {
            Dt,
            Title: (Dt === formatDateOfMessage(new Date())) ? 'Today' : (Dt === formatDateOfMessage((new Date(Date.now() - 1000 * 60 * 60 * 24)))) ? 'Yesterday' : Date.parse(Dt),
            Messages: reList.filter(d => d.Date === Dt).map(d => d)
          }
        })
  
        for (let i = 0; i < newData.length; i++) {
          newData[i].aId = newData[i].messageId;
          newData[i].isString = (newData[i].Title === 'Today' || newData[i].Title === 'Yesterday') ? true : false;
        }
        return newData
      }
    }

export 
{
    showMessage,
    isValidForm,
    excelData,
    validateDate,
    formatData, 
    excelFormatDate,
    changeKeyObjects,
    dateTypeFormat,
    yearMonthDate,
    typeOfTrip,
    formatList,
    toDate
}