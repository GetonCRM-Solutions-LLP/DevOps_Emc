/* eslint-disable vars-on-top */
/*
 * @Author: GetonCRM Solutions LLP - Megha Sachania 
 * @Date: 2024-03-28 11:17:31 
 * @Modification logs
 * ========================================================================================================================
 * @Last Modified by: Someone
 * @Last Modified time: 2024-07-09 14:14:38
 * @Description: Export excels for download in entire system UI
 */
import { LightningElement, api } from 'lwc';
import sheetWorkbook from '@salesforce/resourceUrl/xlsx';
import workbook from '@salesforce/resourceUrl/EMC_Header_Scripts';
import { loadScript } from "lightning/platformResourceLoader";
export default class ExportExcel extends LightningElement {
    librariesLoaded = false;
    renderedCallback() {
        console.log("renderedCallback xlsx");
        if (this.librariesLoaded) return;
        this.librariesLoaded = true;
        Promise.all([
            loadScript(this, sheetWorkbook),
            loadScript(this, workbook + "/EMC_Header_Scripts/js/jszip.js"),
            loadScript(this, workbook + "/EMC_Header_Scripts/js/FileSaver.min.js")
        ])
        .then(() => {
            console.log("success");
        })
        .catch(error => {
            console.log("failure", error);
        });
    }

    s2ab(s){
        var buf = new ArrayBuffer(s.length);
        var view = new Uint8Array(buf);
        for (var i = 0; i !== s.length; ++i) view[i] = s.charCodeAt(i) & 0xFF
        return buf;
    }

    @api download(data, fileName, sheetName){
        this.dispatchEvent(
            new CustomEvent("loading", {
              detail: ""
            })
        );
        let XL = window.XLSX;
        var wb = XL.utils.book_new();
        wb.SheetNames.push(sheetName);
        var ws = {};
        var range = { s: { c: 10000000, r: 10000000 }, e: { c: 0, r: 0 } };
        for (var R = 0; R !== data.length; ++R) {
            for (var C = 0; C !== data[R].length; ++C) {
                if (range.s.r > R) range.s.r = R;
                if (range.s.c > C) range.s.c = C;
                if (range.e.r < R) range.e.r = R;
                if (range.e.c < C) range.e.c = C;
                var cell = { v: data[R][C] };
                if (cell.v == null) continue;
                var cell_ref = XL.utils.encode_cell({ c: C, r: R });
                //console.log("cell##", cell.v)
                if (typeof cell.v === 'number') cell.t = 'n';
                else if (typeof cell.v === 'boolean') cell.t = 'b';
                else if (cell.v instanceof Date) {
                    cell.t = 'n'; cell.z = XL.SSF._table[14];
                    cell.v = this.datenum(cell.v);
                }
                else cell.t = (isNaN(cell.v * 1)) ? 's' : 'n';
                if (data[0][C] == 'Zip Code') cell.t = 's';
                ws[cell_ref] = cell;
            }
        }
        if (range.s.c < 10000000) ws['!ref'] = XL.utils.encode_range(range);
        
        wb.Sheets[sheetName] = ws;
        var wbout = XL.write(wb, { bookType: 'xlsx', bookSST: true, type: 'binary' });
        // eslint-disable-next-line no-undef
        saveAs(new Blob([this.s2ab(wbout)], { type: "application/octet-stream" }), fileName + '.xlsx');
    }

    datenum(v, date1904) {
        if (date1904) v += 1462;
        var epoch = Date.parse(v);
        return (epoch - new Date(Date.UTC(1899, 11, 30))) / (24 * 60 * 60 * 1000);
    }
}