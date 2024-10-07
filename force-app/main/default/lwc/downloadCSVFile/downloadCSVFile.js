import { LightningElement, api } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import WORK_BOOK from "@salesforce/resourceUrl/xlsx";

export default class downloadCSVFile extends LightningElement {
  
  librariesLoaded = false;
  renderedCallback() {
    console.log("renderedCallback xlsx");
    if (this.librariesLoaded) return;
    this.librariesLoaded = true;
    //to load static resource for xlsx file
    Promise.all([loadScript(this, WORK_BOOK)])
      .then(() => {
        console.log("success");
      })
      .catch(error => {
        console.log("failure");
      });
  }
  //To download xlsx file
  @api download(headerList , filename , worksheetNameList , sheetData) {
    console.log("in download")
    
    const XLSX = window.XLSX;
    let xlsData = sheetData;
    let xlsHeader = headerList;
    let ws_name = worksheetNameList;
    let createXLSLFormatObj = Array(xlsData.length).fill([]);
    //let xlsRowsKeys = [];
    /* form header list */
      xlsHeader.forEach((item, index) => createXLSLFormatObj[index] = [item])
    console.log("in download",JSON.parse(JSON.stringify(xlsHeader)))
      
    /* form data key list */
      xlsData.forEach((item, selectedRowIndex)=> {
          let xlsRowKey = Object.keys(item[0]);
    console.log("xlsRowKey",xlsRowKey)

          item.forEach((value, index) => {
              var innerRowData = [];
              xlsRowKey.forEach(item=>{
                  innerRowData.push(value[item]);
              })
    console.log("xlsData",innerRowData)

              createXLSLFormatObj[selectedRowIndex].push(innerRowData);
          })
          console.log("createXLSLFormatObj",createXLSLFormatObj)

      });

    /* creating new Excel */
    var wb = XLSX.utils.book_new();
    console.log("wb",wb)
    /* creating new worksheet */
    var ws = Array(createXLSLFormatObj.length).fill([]);
    for (let i = 0; i < ws.length; i++) {
      /* converting data to excel format and puhing to worksheet */
      let data = XLSX.utils.aoa_to_sheet(createXLSLFormatObj[i]);
      ws[i] = [...ws[i], data];

      /* Add worksheet to Excel */
      XLSX.utils.book_append_sheet(wb, ws[i][0], ws_name[i]);
    }

    /* Write Excel and Download */
    XLSX.writeFile(wb, filename);
  }
}