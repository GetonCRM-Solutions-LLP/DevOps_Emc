import {
  LightningElement,
  api,
  track
} from 'lwc';
import mileageListData from '@salesforce/apex/GetDriverData.mileageListData';
import {
  formatData,
  validateDate,
  excelFormatDate,
  changeKeyObjects
} from 'c/commonLib';
export default class FilterModalPopup extends LightningElement {
  @track spinnerLoad = false;
  @track filterToDate;
  @track filterFromDate;
  @track calStartDate;
  @track calEndDate;
  @api isExcelEmpty = false;
  @api modalHeader;
  @api modalContent;
  @track accountId;
  @track contactId;
  @api csvFiledata = [];
  @api infoID(acc_id, contact_id){
    this.accountId = acc_id;
    this.contactId = contact_id;
  }
  async downloadCSVFile() {
    this.spinnerLoad = true;
    // console.log(this.isExcelEmpty);
    let exportList = await this.exportExcelByDateRange();
    if (!this.isExcelEmpty) {
      if (exportList.length > 0) {
        let rowEnd = '\n';
        let csvString = '';
        let regExp = /^[0-9/]*$/gm;
        let regExpForTime = /^[0-9:\sAM|PM]*$/gm
        let decimalExp = /^(\d*\.)?\d+$/gm
        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();


        // getting keys from data
        // console.log("csvFiledata", this.csvFiledata);
        this.csvFiledata.forEach(function (record) {
          Object.keys(record).forEach(function (key) {
            rowData.add(key);
          });
        });

        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(rowData);
        // console.log("rowData", rowData);
        // splitting using ','
        csvString += rowData.join(',');
        csvString += rowEnd;

        // console.log(rowData);
        var i = 0;
        for(let i=0; i < this.csvFiledata.length; i++){
          let colVal = 0;

          // validating keys in data
          for(let key in rowData) {
              if(rowData.hasOwnProperty(key)) {
                  // Key value 
                  // Ex: Id, Name
                  let rowKey = rowData[key];
                  // add , after every value except the first.
                  if(colVal > 0){
                      csvString += ',';
                  }
                  // If the column is undefined, it as blank in the CSV file.
                  let value = this.csvFiledata[i][rowKey] === undefined ? '' : this.csvFiledata[i][rowKey];
                  if (value != null || value != '') {
                    if (value.match) {
                      if (value.match(regExp) || value.match(regExpForTime) || value.match(decimalExp)) {
                        csvString += '="' + value + '"';
                      } else {
                        csvString += '"' + value + '"';
                      }
                    } else {
                      csvString += '"' + value + '"';
                    }
                  } else {
                    csvString += '"' + value + '"';
                  }
                 // csvString += '"'+ value +'"';
                 
              }
              colVal++;
          }
        
          csvString += rowEnd;
      }
        // this.csvFiledata.forEach((filedata) => {
        //   let colVal = 0;
        //   rowData.forEach((row, ind) => {
        //     // Key value 
        //     // Ex: Id, Name
        //     let rowKey = row;
        //     //  console.log(rowKey)
        //     // add , after every value except the first.
        //     if (colVal > 0) {
        //       csvString += ',';
        //     }
        //     // If the column is undefined, it as blank in the CSV file.
        //     //  console.log(this.csvFiledata[ind],filedata);
        //     let value = filedata[rowKey] === undefined ? '' : filedata[rowKey];
        //     if (value != null || value != '') {
        //       if (value.match) {
        //         if (value.match(regExp) || value.match(regExpForTime) || value.match(decimalExp)) {
        //           csvString += '="' + value + '"';
        //         } else {
        //           csvString += '"' + value + '"';
        //         }
        //       } else {
        //         csvString += '"' + value + '"';
        //       }
        //     } else {
        //       csvString += '"' + value + '"';
        //     }

        //     colVal++;

        //   })
        //   csvString += rowEnd;
        // })
        // Creating anchor element to download
        this.spinnerLoad = false;
        /* Updated change on 27-09-2021 */
        var universalBOM = "\uFEFF";
        var a = window.document.createElement('a');
        a.setAttribute('href', 'data:text/csv; charset=utf-8,' + encodeURIComponent(universalBOM+csvString));
        a.setAttribute('target', '_self');
        a.setAttribute('download',  'all_trips_' + this.calStartDate + '_to_' + this.calEndDate + '.csv')
        window.document.body.appendChild(a);
        a.click();
        // let downloadElement = document.createElement('a');
        // downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        // downloadElement.target = '_self';
        // // CSV File Name
        // downloadElement.download = 'all_trips_' + this.calStartDate + '_to_' + this.calEndDate + '.csv';
        // // below statement is required if you are using firefox browser
        // document.body.appendChild(downloadElement);
        // //click() Javascript function to download CSV file
        // downloadElement.click();
        this.handleCancel();
        this.filterFromDate = "";
        this.filterToDate = "";
      }
    } else {
      const csvEvent = new CustomEvent("handlecsvevent", {
        detail: "CSV Event"
      })
      this.dispatchEvent(csvEvent);
      this.handleCancel();
      this.filterFromDate = "";
      this.filterToDate = "";
      this.spinnerLoad = false;
    }
   // console.log("csvdownloaded", this.csvFiledata);

  }

  // Filter Modal To Pass Data To Parent Component
  @api ModalClassList() {
      let sectionElement = this.template.querySelector("section");
      return sectionElement;
  }
  @api ModalBackdrop() {
      let modalbackdrop = this.template.querySelector("div.modalBackdrops");
      return modalbackdrop;
  }

  // From Date Change Event
  changeFromHandler(event) {
      this.calStartDate = validateDate(event.target.value);
      // const selectedFilterDate = new CustomEvent("handlefilterdateevent", {
      //     detail: this.calStartDate
      // })
      // this.dispatchEvent(selectedFilterDate);
  }

 // To Date Change Event
  changeToHandler(event) {
      // console.log('inside change handler')
      this.calEndDate = validateDate(event.target.value);
      // const selectedFilterEndDate = new CustomEvent("handlefiltertodateevent", {
      //     detail: this.calEndDate
      // });

      // this.dispatchEvent(selectedFilterEndDate);
  }

  //On Cancel Modal
  handleCancel() {
      this.template.querySelector("section").classList.add("slds-hide");
      this.template
          .querySelector("div.modalBackdrops")
          .classList.add("slds-hide");
  }

  // Method call excel download AI-000615 
  async exportExcelByDateRange() {
    try {
      let convertFromDate = excelFormatDate(this.calStartDate);
      let convertToDate = excelFormatDate(this.calEndDate);
      let resData = await mileageListData({
        accId: this.accountId,
        adminId: this.contactId,
        startDate: convertFromDate,
        endDate: convertToDate
      });
      console.log("response->", resData, convertFromDate, convertToDate);
      var exportCSV = [];
      if (resData.length > 0) {
        this.isExcelEmpty = false;
        exportCSV = formatData(resData);
        this.csvExportData = exportCSV;
        //  console.log("response csv->", exportCSV);
        if (this.csvExportData.length != 0) {
          this.csvFiledata = changeKeyObjects(this.csvExportData);
        }
       return this.csvFiledata;
      } else {
        this.isExcelEmpty = true;
      }
    } catch (error) {
      console.log("Error while exporting list ", error);
    }
  }
}