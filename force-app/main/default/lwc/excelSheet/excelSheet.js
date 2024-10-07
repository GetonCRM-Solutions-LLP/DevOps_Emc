import { LightningElement, api } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import workbook from "@salesforce/resourceUrl/xlsx";
export default class ExcelSheet extends LightningElement {
  @api filename;
  librariesLoaded = false;
  renderedCallback() {
    if (this.librariesLoaded) return;
    this.librariesLoaded = true;
    Promise.all([loadScript(this, workbook)])
      .then(() => {
        console.log("success");
      })
      .catch((error) => {
        console.log("error while loading script");
      });
  }

  @api download(headerList, sheetContent) {
    let xlsContent = [];
   // console.log("downloading", sheetContent)
    xlsContent = sheetContent;
    let xlsColumnHeader = headerList;
    let filename = "Mileage Details" + " " + this.dateFormat();
   // console.log("Worksheet", xlsContent);
    let createXLSLFormatObj = Array(xlsContent.length).fill([]);
    //console.log("createXLSLFormatObj", createXLSLFormatObj);
    /* form header list */
    xlsColumnHeader.forEach(
      (item, index) => (createXLSLFormatObj[index] = [item])
    );

    /* form data key list */
    xlsContent.forEach((item, selectedRowIndex) => {
      let xlsRowKey = Object.keys(item[0]);
      item.forEach((value, index) => {
        var innerRowData = [];
        xlsRowKey.forEach((item) => {
          innerRowData.push(value[item]);
        });
        createXLSLFormatObj[selectedRowIndex].push(innerRowData);
      });
    });
    /* creating new Excel */
    var wb = XLSX.utils.book_new();
    /* creating new worksheet */

    var ws = Array(createXLSLFormatObj.length).fill([]);
   // console.log("Worksheet 2", ws, createXLSLFormatObj.length);
    for (let i = 0; i != ws.length; i++) {
      /* converting data to excel format and puhing to worksheet */
      let data = XLSX.utils.aoa_to_sheet(createXLSLFormatObj[i]);
      ws[i] = [...ws[i], data];

      /* Add worksheet to Excel */
  
      XLSX.utils.book_append_sheet(wb, ws[i][0], filename);
    }

  
    /* Write Excel and Download */
    XLSX.writeFile(wb, filename + ".xlsx");
    ws = [];
  }

  dateFormat() {
    let date = new Date();
    var d = date.getDate();
    var m = date.getMonth() + 1;
    var y = date.getFullYear();
    var dateString = m + "" + d + "" + y;
    return dateString.toString();
  }
}