import { LightningElement, api } from "lwc";
import resourceImage from "@salesforce/resourceUrl/mBurseCss";
import getCompliance from "@salesforce/apex/DriverDashboardLWCController.getCompliance";
// import highcharts from "@salesforce/resourceUrl/HighChart";
// import { loadScript } from "lightning/platformResourceLoader";
export default class UserTaxLiability extends LightningElement {
  downloadIcon =
    resourceImage + "/mburse/assets/mBurse-Icons/Plan-Info/download.png";
  lengthS = false;
  reimbursementValue = false;
  vfHost;
  origin;
  iframeObj;
  messageOfCompliance;
  complianceData;
  reimbursements;
  maxAllow;
  taxLiablity;
  detailReport;
  summaryR;
  taxVal;
  totalApprovedMileage;
  chartResourcesLoaded = false;
  @api contactId;

  proxyToObject(e) {
    return JSON.parse(e);
  }

  getCompliancedata(data) {
    data.forEach((element) => {
      let number = element.quarterno;
      element.ordinal =
        isNaN(number) || number < 1
          ? ""
          : number % 100 === 11 || number % 100 === 12
            ? "th"
            : number % 10 === 1
              ? "st"
              : number % 10 === 2
                ? "nd"
                : number % 10 === 3
                  ? "rd"
                  : "th";
    });
    return data;
  }

  redirectToCompliance() {
    const redirectEvent = new CustomEvent('redirect', { detail: 'Compliance' });
    this.dispatchEvent(redirectEvent);
  }

  fetchCompliance() {
    getCompliance({
      contactId: this.contactId
    })
      .then((data) => {
        console.log("getCompliance", data)
        let reimVal, maxVal, taxVal, totalApprovedMileage;
        if (data[1]) {
          this.messageOfCompliance = this.proxyToObject(data[1]);
        }

        if (data[2]) {
          this.complianceData = this.getCompliancedata(
            this.proxyToObject(data[2])
          );
        }

        if (data[3]) {
          this.detailReport = this.proxyToObject(data[3]);
        }

        if (data[4]) {
          this.summaryR = this.proxyToObject(data[4]);
          this.lengthS = this.summaryR.length > 0 ? true : false;
        }

        if (data[5]) {
          reimVal = this.proxyToObject(data[5]);
          this.reimbursements = parseFloat(reimVal);
        }

        if (data[6]) {
          maxVal = this.proxyToObject(data[6]);
          this.maxAllow = parseFloat(maxVal);
        }

        if (data[7]) {
          taxVal = this.proxyToObject(data[7]);
          this.taxVal = taxVal;
          this.taxLiablity =
            parseFloat(taxVal) === 0 ? null : parseFloat(taxVal);
          console.log("taxVal", taxVal, this.taxLiablity)
        }

        if (data[8]) {
          totalApprovedMileage = this.proxyToObject(data[8]);
          this.totalApprovedMileage = parseFloat(totalApprovedMileage);
        }

        if (this.reimbursements !== undefined && this.maxAllow !== undefined) {
          this.reimbursementValue = true;
        } else {
          this.reimbursementValue = false;
        }
      })
      .catch((error) => {
        console.log("getCompliance error", error.body.message, error.message);
      });
  }

  excelToExport(data, file, sheet) {
    this.template.querySelector('c-export-excel').download(data, file, sheet);
  }

  taxLiabilityDetailReport() {
    let name, excelFileName, excelSheetName
    let excelReport = [];
    name = this.detailReport[0].drivername;
    excelFileName = name + ' Annual Tax Liability Detail Report';
    excelSheetName = 'Detail Report';
    excelReport.push(["Employee Id", "Driver Name", "Email", "Year", "Month", "Approved Mileage", "IRS Mileage Rate", "IRS Max Allowable", "Total Reimbursement", "Imputed Income"])
    console.log('@@@ detailReport ==>', JSON.stringify(this.detailReport));
    this.detailReport.forEach(item => {
      excelReport.push([item.employeeid, item.drivername, item.emailid, item.year, item.month, item.approvedmileages, item.iRSmileageRate, "$" + item.iRSallowable, "$" + item.totalreim, "$" + item.imputedincome])
    })

    this.excelToExport(excelReport, excelFileName, excelSheetName);
  }

  taxLiabilitySummaryReport() {
    let name, excelFileName, excelSheetName
    let excelReport = [];
    name = this.summaryR[0].drivername;
    excelFileName = name + ' Annual Tax Liability Summary Report';
    excelSheetName = 'Summary Report';
    excelReport.push(["Employee Id", "Driver Name", "Email", "Total Approved Mileage", "Total Reimbursement", "IRS allowable", "Imputed Income"])
    this.summaryR.forEach(item => {
      excelReport.push([item.employeeid, item.drivername, item.emailid, this.totalApprovedMileage, "$" + this.reimbursements, "$" + this.maxAllow, "$" + item.imputedincome])
    })

    this.excelToExport(excelReport, excelFileName, excelSheetName);
  }

  initializeChart() {
    // eslint-disable-next-line no-restricted-globals
    let url = location.origin;
    let urlHost = url + '/app/taxLiabilityChart';
    this.vfHost = urlHost;
    this.origin = url;
    let obj = { reimbursements: this.reimbursements, maxAllow: this.maxAllow, taxLiablity: this.taxLiablity }
    let messagePost = JSON.stringify(obj)
    console.log('chart', this.renderInitialized, this.template.querySelector('iframe').contentWindow)
    if (this.template.querySelector('.vf-iframe')) {
      this.template.querySelector('.vf-iframe').contentWindow.postMessage(messagePost, this.origin)
    }
  }

  connectedCallback() {
    this.fetchCompliance();
  }
}