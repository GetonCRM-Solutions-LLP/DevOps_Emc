import { LightningElement, api, wire } from 'lwc';
import getReports from '@salesforce/apex/ReportListController.getAllReports';
import updatelockdate from '@salesforce/apex/ReportListController.updateLockDate';
// import getpayperiodDate from '@salesforce/apex/BiweeklyPayPeriod.getPayPeriodDates';
import { NavigationMixin } from 'lightning/navigation';
// import accountMonthList from "@salesforce/apex/ManagerDashboardController.accountMonthList";
import accountMonthList from "@salesforce/apex/ReportDetailsController.monthList";
import { loadStyle , loadScript } from 'lightning/platformResourceLoader';
import jQueryMinified from '@salesforce/resourceUrl/jQueryMinified';
import datepicker from '@salesforce/resourceUrl/calendar';
import customMinifiedDP  from '@salesforce/resourceUrl/modalCalDp';
import REPORT_LIST_STYLE from '@salesforce/resourceUrl/ReportListResource';
import ERMIPayPeriod from '@salesforce/label/c.ERMIPayPeriodDate';
import PayPeriodDatelabel from '@salesforce/label/c.PayPeriodDate';
import TripDetailReport from '@salesforce/apex/ReportListController.TripDetailReport';
import monthPicklist from '@salesforce/label/c.Ermi_Tax_Report_month_picklist';
import employeeTypePicklist from '@salesforce/label/c.Ermi_Tax_Report_employee_type_picklist';
import biweekpayperiod from '@salesforce/apex/ReportListController.payPeriodDateList';
import AccountYear from '@salesforce/apex/ReportListController.AccountYear';
import postVariablePaymentAPI from '@salesforce/apex/ReportListController.postVariablePaymentAPI';
import postFixedAmountAPI from '@salesforce/apex/ReportListController.postFixedAmountAPI';
import DeleteNetchexCallout from '@salesforce/apex/ReportListController.DeleteNetchexCallout';
 import postTimeSheetImportAPI from '@salesforce/apex/ReportListController.postTimeSheetImportAPI';
import taxLiabilityReport from '@salesforce/apex/ReportListController.taxLiabilityReport';
import downloadExcel from '@salesforce/apex/ReportListController.downLoadComplianceReport';
import postHalfFPFullDriverAPI  from '@salesforce/apex/ReportListController.postHalfFPFullDriverAPI';
import ErmiDriverList  from '@salesforce/apex/ReportListController.ErmiDriverList';
import CheckStatus  from '@salesforce/apex/ReportListController.CheckStatus';

import ERMI_ADMIN_ID from '@salesforce/label/c.ERMI_ADMIN_ID';
import Bi_Weekly_Payment_Report from '@salesforce/label/c.Bi_Weekly_Payment_Report';
import AISAccount from '@salesforce/label/c.AISAccount';
import FramptonConstruction from '@salesforce/label/c.FramptonConstruction';
import ERMI_Account from '@salesforce/label/c.ERMI_Account';

export default class ReportList extends NavigationMixin(LightningElement) {
    reportname = [];
    reportdetailname = [];
    currentReport;
    reportID;
    title='Mileage Lock Date';
    isFalse=true;
    modalclass = "slds-modal slds-fade-in-open ";
    headerclass = "slds-modal__header header-preview hedear-style_class header_style";
    subheaderClass = "slds-modal__title slds-hyphenate hedear-style_class ";
    modalcontentstyle = "slds-modal__content slds-p-left_medium slds-p-right_medium slds-p-bottom_medium slds-p-top_small content_div_scroll"
    styleheader = "slds-modal__container container_style"
    closebtnclass = "close-notify"
    modalcontentmessage = 'Please confirm all mileage has been approved before closing the report.';
    modalcontentmessagenew = 'Would you like to continue?';
    updatetext;
    btnlabel;
    picklist = [];
    istrue = false;
    header =[];
    detail=[];
    modaldata =[];
    monthoption = [];
    isLoading = false;
    _accid;
    _adminid;
    payperiodList = [];
    monthList = [];
    emptypeList = [];
    title='';
    empMonth='';
    empType = '';
    payperioddropdown = false;
    monthlytaxreport = false;
    byweeksubmit = false;
    downloadBtn = false;
    dateoption = [];
    buttonLabel='';
    fromdate = '';
    todate = '';
    netchexDate;
    anual_tax_detail = [];
    visibleAccounts = [];
    message = '';
    toastmsg = false;
    yearList =[];
    progress = 0;
    progressbar = false;
    year ;
    isAreaDisabled = true;
    yeardropdown = false;
    BiWeekly_Payment;
    ERMI_ACCOUNT;
    toggele = true;
    checkBoxFlag = false;
    checkedList = [];
    // intervalId;
    // data;

    renderedCallback(){
        Promise.all([loadStyle(this, REPORT_LIST_STYLE + '/ReportListCSS/reportListstaticResouce.css')]);
          loadScript(this, jQueryMinified)
          .then(() => {
              console.log('jquery loaded')
              Promise.all([
                loadStyle(this, datepicker + "/minifiedCustomDP.css"),
                loadStyle(this, datepicker + "/datepicker.css"),
                loadStyle(this, customMinifiedDP),
                loadScript(this, datepicker + '/datepicker.js')
              ]).then(() => {
                  this.calendarJsInitialised = true;
                  console.log("script datepicker loaded--");
                })
                .catch((error) => {
                  console.error(error);
                });
          })
          .catch(error => {
            console.log('jquery not loaded ' + error )
          })

      }

      getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
      }
  
    connectedCallback(){
       
        this._accid  = this.getUrlParamValue(location.href, 'accid')
        this._adminid  = this.getUrlParamValue(location.href, 'id')
        this.getYear();
        this.getAccountMonthList();
        this.getCustomLabelArray();
        getReports({contactId : this._adminid})
        .then(result => {
            this.reportdata = JSON.parse(result);
            console.log("result",JSON.stringify(this.reportdata));
            this.reportdata.forEach(element => {
                element.currentReports.forEach(index =>{
                    if(index.reportName != null){
                        this.reportdetailname.push({name:element.categoryName , reportname : index.reportName })
                    }
                })
            });
                this.ERMI_ACCOUNT.forEach(eermiacct => {
                    if(eermiacct === this._adminid){
                        this.reportdetailname.push(
                        {name:"Reimbursement Reports" , reportname : "Time and Attendance Detail Report" },
                        {name:"Reimbursement Reports" , reportname : "Time, Attendance and Mileage Summary Report" },
                        {name:"Reimbursement Reports" , reportname : "Monthly Tax Report" },
                        {name:"NetChex Payable Reports" , reportname : "Bi-weekly Time and Attendance Payment" },
                        {name:"NetChex Payable Reports" , reportname : "Bi-weekly Salary and Full Time Fixed Payment" },
                        {name:"NetChex Payable Reports" , reportname : "Monthly NetChex Variable Payment" },
                        {name:"NetChex Payable Reports" , reportname : "Monthly Part Time Fixed Amount Payment" },
                        {name:"NetChex Payable Reports" , reportname : "Delete NetChex Report" })
                    }
                })
               
                this.BiWeekly_Payment.forEach(biweekpay => {
                    if(biweekpay == this._accid){
                        this.reportdetailname.push({name:"Reimbursement Reports" , reportname : "Bi-Weekly Payment Report" })
                    }
                })
                // this.reportdetailname.push({name:"Reimbursement Reports" , reportname : "Biweekly Mileage Reimbursement Report" })
                

                this.reportdetailname.push({name:"Tax Liability Reports" , reportname : "Annual Tax Liability Report" },
                {name:"Tax Liability Reports" , reportname : "Tax Liability" })
                // this.reportdetailname.push({name:"Reimbursement Reports" , reportname : "Variable Reimbursement Report" })
               
                if(FramptonConstruction == this._accid){
                    this.reportdetailname.push({name:"My Custom Reports" , reportname : "Job Costing Summary Report" })
                }
                if(ERMI_Account == this._accid){
                    this.reportdetailname.push({name:"My Custom Reports" , reportname : "Trip Detail Report" })
                }
                // this.reportdetailname.push({name:"Reimbursement Reports" , reportname : "Bi-Weekly Reimbursement Report" })


            let reports =JSON.parse(JSON.stringify(this.reportdetailname));
            console.log("reports")
            let merged = Object.values(reports.reduce((a,{name, reportname }) => (
                (a[name] = a[name] || {name, reportname:[] })["reportname"].push(reportname), a
            ),{}))
            let reportsDisplay = JSON.parse(JSON.stringify(merged));
            let transformedData = reportsDisplay.map(item => ({
                name: item.name,
                displayName: item.name.startsWith("My ") ? item.name.split(' ')[1] : item.name.slice(0, -8),
                reportname: item.reportname.map(name => {
                  if (name.endsWith(" Report")) {
                    return { key: name, value: name.slice(0, -7) }; // Remove " Report" from the end
                  } else {
                    return { key: name, value: name }; // If " Report" is not present, value is same as key
                  }
                })
            }));
            this.reportname = JSON.parse(JSON.stringify(transformedData));
            console.log('this.reportname : ' + JSON.stringify(this.reportname));
        })
        .catch(error => {
            console.log("error",JSON.stringify(error));
        })

    }
    getCustomLabelArray(){
        var clabel = new Array();
        clabel = ERMI_ADMIN_ID.split(",");
        this.ERMI_ACCOUNT =JSON.parse(JSON.stringify(clabel));

        var clabel1 = new Array();
        clabel1 = Bi_Weekly_Payment_Report.split(",");
        this.BiWeekly_Payment =JSON.parse(JSON.stringify(clabel1));
    }
    getPayPeriodOption(){
        this.payperiodList = [];
        var headerarry = new Array();
        headerarry = ERMIPayPeriod.split(",");
        const dateArray =JSON.parse(JSON.stringify(headerarry));
        const currentDate = new Date();
        const currentMonth = currentDate.getMonth() + 1;
        const lastMonth = currentMonth === 1 ? 12 : currentMonth - 1;
        const nextMonth = currentMonth === 1 ? 12 : currentMonth + 1;
        const filteredDates = dateArray.filter(dateRange => {
            const startDate = dateRange.split(' to ')[0];
            const endDate = dateRange.split(' to ')[1];
           return (startDate.split('-')[1] ==  currentMonth && endDate.split('-')[1] == currentMonth) || 
           (startDate.split('-')[1] ==  lastMonth && endDate.split('-')[1] == lastMonth) ||
            (startDate.split('-')[1] ==  nextMonth && endDate.split('-')[1] == nextMonth)||
           (startDate.split('-')[1] ==  currentMonth && endDate.split('-')[1] == nextMonth) || 
           (startDate.split('-')[1] ==  lastMonth && endDate.split('-')[1] == currentMonth)
          });
        let finaldata = JSON.parse(JSON.stringify(filteredDates));
        finaldata.forEach((element,index) => {
            console.log("index",index)
            let split1 = element.split(' to ')[0];
            let split2 = element.split(' to ')[1];
            let finalsplit = split1.split('-')[1]+'/'+split1.split('-')[2]+'/'+(split1.split('-')[0]).slice(-2)+' - '+split2.split('-')[1]+'/'+split2.split('-')[2]+'/'+(split2.split('-')[0]).slice(-2)
            this.payperiodList.push({id:index,label:finalsplit,value:finalsplit});
        })
        this.payperiodList = JSON.parse(JSON.stringify(this.payperiodList))
    }
    getPayPeriodlabel(){
        this.payperiodList = [];
        var headerarry = new Array();
        headerarry = PayPeriodDatelabel.split(",");
        const dateArray =JSON.parse(JSON.stringify(headerarry));
        const currentDate = new Date();
        const currentMonth = currentDate.getMonth() + 1;
        const lastMonth = currentMonth === 1 ? 12 : currentMonth - 1;
        const nextMonth = currentMonth === 1 ? 12 : currentMonth + 1;
        const filteredDates = dateArray.filter(dateRange => {
            const startDate = dateRange.split(' to ')[0];
            const endDate = dateRange.split(' to ')[1];
           return (startDate.split('-')[1] ==  currentMonth && endDate.split('-')[1] == currentMonth) || (startDate.split('-')[1] ==  lastMonth && endDate.split('-')[1] == lastMonth) || (startDate.split('-')[1] ==  nextMonth && endDate.split('-')[1] == nextMonth)||
           (startDate.split('-')[1] ==  currentMonth && endDate.split('-')[1] == nextMonth) || 
           (startDate.split('-')[1] ==  lastMonth && endDate.split('-')[1] == currentMonth)
          });
        let finaldata = JSON.parse(JSON.stringify(filteredDates));
        finaldata.forEach(element => {
            let split1 = element.split(' to ')[0];
            let split2 = element.split(' to ')[1];
            let finalsplit = split1.split('-')[1]+'/'+split1.split('-')[2]+'/'+(split1.split('-')[0]).slice(-2)+' - '+split2.split('-')[1]+'/'+split2.split('-')[2]+'/'+(split2.split('-')[0]).slice(-2)
            this.payperiodList.push({label:finalsplit,value:finalsplit});
        })
        this.payperiodList = JSON.parse(JSON.stringify(this.payperiodList))
    }
    getDateOption(){
        var makeDate = new Date();
       
          let monthNumber = makeDate.getMonth()+1;
          if(monthNumber < 10){
            monthNumber = '0'+monthNumber
          }
          let year = makeDate.getFullYear();
          let convertFromDate = year+'-'+monthNumber +'-01'
          let convertToDate = year+'-'+monthNumber +'-15'
          this.dateoption = [{label : convertFromDate , value:convertFromDate},
                            {label : convertToDate , value:convertToDate}]
    }

    getYear(){
        AccountYear({accountId : this._accid})
        .then(result => {
            let account = JSON.parse(JSON.stringify(result));
            let currentYear = new Date().getFullYear();
            if(account != currentYear){
                for(let i = account; i <= currentYear ;i++){
                    this.yearList.push({label:i.toString() , value:i.toString()})
                }
            }else{
                this.yearList.push({label:account.toString() , value:account.toString()})
            }
            this.yearList = JSON.parse(JSON.stringify(this.yearList))
            
         })
         .catch(error => {
             console.log("error",error)
         })
    }

    // getbiweekpayperiod(){
    //     console.log("in report")
    //     biweekpayperiod({accId:this._accid})
    //         .then(result => {
    //             console.log("in report")
    //             var payarray1 = new Array();
    //             payarray1 = result.split(",");
    //             let finaldata =JSON.parse(JSON.stringify(payarray1));
    //             finaldata.forEach(element => {
    //                 this.payperiodList.push({label:element,value:element});
    //             })
    //             this.payperiodList = JSON.parse(JSON.stringify(this.payperiodList))
    //             console.log("in report",this.payperiodList)
    //         })
    //         .catch(error => {
    //             console.log("error",error)
    //         })
    // }
    
    handleReportopen(event){
        this.currentReport = event.target.dataset.item;
        let data = JSON.parse(JSON.stringify(this.reportdata))
        data.forEach(row => {
            row.currentReports.forEach(item => {
                if(item.reportName == this.currentReport){
                this.reportID = item.reportId;
                    if(item.lockDate == true && (!item.mileageLockDate) ){
                        if (this.template.querySelector('c-user-profile-modal')) {
                            this.template.querySelector('c-user-profile-modal[data-id="mileges"]').show();
                        }
                    }else{
                            this.dispatchEvent(
                                new CustomEvent("viewreport", {
                                  detail:{reportID : this.reportID , monthList : this.monthoption}
                                })
                              );
                    }
                     
                }
            })
        })
    if(this.currentReport == 'Time and Attendance Detail Report'){
            // console.log("in else",item.reportName)
            this.buttonLabel = 'Submit';
            this.title = 'Contact List';
            this.isAreaDisabled = false;
             this.fromdate = null;
                        this.todate = null;
                        // this.template.querySelector(`.flat-container[data-id="from"]`).classList.remove('area_disable');
                        // this.template.querySelector(`.flat-container[data-id="to"]`).classList.remove('area_disable');
            this.modalcontentstyle = "slds-modal__content slds-p-left_medium slds-p-right_medium slds-p-bottom_medium slds-p-top_small content_div_scroll"
            this.styleheader = "slds-modal__container container_style"
            if (this.template.querySelector('c-user-profile-modal')) {
                this.template.querySelector('c-user-profile-modal[data-id="attendance_detail_report"]').show();
                setTimeout(() => {
                    if(this.template.querySelectorAll('.date-selector').length > 0){
                      this.intializeDatepickupnew();
                    }
                  },1000);
            }
        }else if(this.currentReport == 'Biweekly Mileage Reimbursement Report'){
            this.getPayPeriodlabel();
            this.title = 'Biweekly Mileage Reimbursement Report';
            this.payperioddropdown = true;
            this.downloadBtn = true;
            this.modalcontentstyle = "slds-modal__content slds-p-left_medium slds-p-right_medium slds-p-bottom_medium slds-p-top_small content_div_scroll"
            this.styleheader = "slds-modal__container container_style"
            if (this.template.querySelector('c-user-profile-modal')) {
                this.template.querySelector('c-user-profile-modal[data-id="attendance_summary_report"]').show();
            }
        }else if(this.currentReport == 'Bi-Weekly Payment Report' ){
            biweekpayperiod({accId:this._accid})
            .then(result => {
                console.log("in report")
                var payarray1 = new Array();
                payarray1 = result.split(",");
                let finaldata1 =JSON.parse(JSON.stringify(payarray1));
                this.payperiodList = [];
                finaldata1.forEach(element => {
                    let split1 = element.split(' to ')[0];
                    let split2 = element.split(' to ')[1];
                    let finalsplit = split1.split('-')[1]+'/'+split1.split('-')[2]+'/'+(split1.split('-')[0]).slice(-2)+' - '+split2.split('-')[1]+'/'+split2.split('-')[2]+'/'+(split2.split('-')[0]).slice(-2)
           
                    this.payperiodList.push({label:finalsplit,value:finalsplit});
                })
                this.payperiodList = JSON.parse(JSON.stringify(this.payperiodList))
                this.payperioddropdown = true;
                this.downloadBtn = true;
                console.log("in report",this.payperiodList)
            })
            .catch(error => {
                console.log("error",error)
            })
                if(this.currentReport == 'Bi-Weekly Payment Report'){
                    this.title = 'Bi-Weekly Payment Report';
                }
                
                this.modalcontentstyle = "slds-modal__content slds-p-left_medium slds-p-right_medium slds-p-bottom_medium slds-p-top_small content_div_scroll"
                this.styleheader = "slds-modal__container container_style"
                if (this.template.querySelector('c-user-profile-modal')) {
                    this.template.querySelector('c-user-profile-modal[data-id="attendance_summary_report"]').show();
                  
                }    
        } else if(this.currentReport == 'Time, Attendance and Mileage Summary Report'){
            this.getPayPeriodOption();
            this.title = 'Time, Attendance and Mileage Summary Report';
            this.modalcontentstyle = "slds-modal__content slds-p-left_medium slds-p-right_medium slds-p-bottom_medium slds-p-top_small content_div_scroll"
            this.styleheader = "slds-modal__container container_style"
            this.payperioddropdown = true;
            this.downloadBtn = true;
            if (this.template.querySelector('c-user-profile-modal')) {
                this.template.querySelector('c-user-profile-modal[data-id="attendance_summary_report"]').show();
            }
        }else if(this.currentReport == 'Monthly Tax Report'){
            this.downloadBtn = true;
            var payarray = new Array();
            payarray = monthPicklist.split(",");
            let finaldata =JSON.parse(JSON.stringify(payarray));
            finaldata.forEach(element => {
                this.monthList.push({label:element,value:element});
            })
            this.monthList = JSON.parse(JSON.stringify(this.monthList))

            var emparray = new Array();
            emparray = employeeTypePicklist.split(",");
            let finaldatanew =JSON.parse(JSON.stringify(emparray));
            finaldatanew.forEach(element => {
                this.emptypeList.push({label:element,value:element});
            })
            this.emptypeList = JSON.parse(JSON.stringify(this.emptypeList))
            
            this.monthlytaxreport = true;
            this.title = 'Monthly Tax Report';
            this.modalcontentstyle = "slds-modal__content slds-p-left_medium slds-p-right_medium slds-p-bottom_medium slds-p-top_small content_div_scroll"
            this.styleheader = "slds-modal__container container_style"
            if (this.template.querySelector('c-user-profile-modal')) {
                this.template.querySelector('c-user-profile-modal[data-id="attendance_summary_report"]').show();
                
            }
        }else if(this.currentReport == 'Bi-weekly Time and Attendance Payment'){
            this.downloadBtn = true;
            this.byweeksubmit = true;
            this.getPayPeriodOption();
            this.title = 'Time and Attendance Payment Report';
            this.modalcontentstyle = "slds-modal__content slds-p-left_medium slds-p-right_medium slds-p-bottom_medium slds-p-top_small content_div_scroll"
            this.styleheader = "slds-modal__container container_style"
            this.payperioddropdown = true;
            if (this.template.querySelector('c-user-profile-modal')) {
                this.template.querySelector('c-user-profile-modal[data-id="attendance_summary_report"]').show();
            }
        }else if(this.currentReport == 'Bi-weekly Salary and Full Time Fixed Payment'){
            this.getPayPeriodOption();
            this.title = 'Salary and Full Time Fixed Amount Payment Report';
            this.payperioddropdown = true;
            this.byweeksubmit = true;
            this.modalcontentstyle = "slds-modal__content slds-p-left_medium slds-p-right_medium slds-p-bottom_medium slds-p-top_small content_div_scroll"
            this.styleheader = "slds-modal__container container_style"
            if (this.template.querySelector('c-user-profile-modal')) {
                this.template.querySelector('c-user-profile-modal[data-id="attendance_summary_report"]').show();
            }

        }else if(this.currentReport == 'Monthly NetChex Variable Payment'){
            this.getDateOption();
            this.title = 'Monthly Variable Payment Report';
            this.modalcontentstyle = "slds-modal__content slds-p-left_medium slds-p-right_medium slds-p-bottom_medium slds-p-top_small content_div_scroll"
            this.styleheader = "slds-modal__container container_style"
            if (this.template.querySelector('c-user-profile-modal')) {
                this.template.querySelector('c-user-profile-modal[data-id="netchex_variable_payment"]').show();
            }
        }else if(this.currentReport == 'Monthly Part Time Fixed Amount Payment'){
            this.getDateOption();
            this.title = 'Part Time Fixed Amount Payment Report';
            this.modalcontentstyle = "slds-modal__content slds-p-left_medium slds-p-right_medium slds-p-bottom_medium slds-p-top_small content_div_scroll"
            this.styleheader = "slds-modal__container container_style"
            if (this.template.querySelector('c-user-profile-modal')) {
                this.template.querySelector('c-user-profile-modal[data-id="netchex_variable_payment"]').show();
            }
        }else if(this.currentReport == 'Delete NetChex Report'){
            this.buttonLabel = 'Delete';
            this.title = 'Delete Netchex Report';
            this.isAreaDisabled = false;
            this.modalcontentstyle = "slds-modal__content slds-p-left_medium slds-p-right_medium slds-p-bottom_medium slds-p-top_small content_div_scroll"
            this.styleheader = "slds-modal__container container_style"
            if (this.template.querySelector('c-user-profile-modal')) {
                this.template.querySelector('c-user-profile-modal[data-id="attendance_detail_report"]').show();
                setTimeout(() => {
                    if(this.template.querySelectorAll('.date-selector').length > 0){
                      this.intializeDatepickupnew();
                    }
                  },1000);
            }
        }else if(this.currentReport == 'Job Costing Summary Report'){
            this.buttonLabel = 'Submit';
            this.backbutton = true;
            this.title = 'Job Costing Summary Report';
            this.isAreaDisabled = false;
            this.modalcontentstyle = "slds-modal__content slds-p-left_medium slds-p-right_medium slds-p-bottom_medium slds-p-top_small content_div_scroll"
            this.styleheader = "slds-modal__container container_style"
            if (this.template.querySelector('c-user-profile-modal')) {
                this.template.querySelector('c-user-profile-modal[data-id="attendance_detail_report"]').show();
                setTimeout(() => {
                    if(this.template.querySelectorAll('.date-selector').length > 0){
                      this.intializeDatepickupnew();
                    }
                  },1000);
            }
        }else if(this.currentReport == 'Trip Detail Report'){
            this.buttonLabel = 'Download';
            this.title = 'Trip Detail Report';
            this.isAreaDisabled = false;
            this.modalcontentstyle = "slds-modal__content slds-p-left_medium slds-p-right_medium slds-p-bottom_medium slds-p-top_small content_div_scroll"
            this.styleheader = "slds-modal__container container_style"
            if (this.template.querySelector('c-user-profile-modal')) {
                this.template.querySelector('c-user-profile-modal[data-id="attendance_detail_report"]').show();
                setTimeout(() => {
                    if(this.template.querySelectorAll('.date-selector').length > 0){
                      this.intializeDatepickupnew();
                    }
                  },1000);
            }
        }else if(this.currentReport == 'Annual Tax Liability Report'){
            // this.yeardropdown = true;
            // taxLiabilityReport({accId:this._accid})
            // .then(result => {
            //    console.log("taxLiabilityReport",JSON.parse(result))
            //    this.anual_tax_detail = JSON.parse(result);
            //    this.template.querySelector('c-simple-pagination').updateRecords(this.anual_tax_detail,10)
            // })
            // .catch(error => {
            //     console.log("error",error)
            // })
            // this.styleheader = "slds-modal__container container_style_1"
            // this.modalcontentstyle = "slds-modal__content slds-p-left_medium slds-p-right_medium slds-p-bottom_medium slds-p-top_small"
            // if (this.template.querySelector('c-user-profile-modal')) {
            //     this.template.querySelector('c-user-profile-modal[data-id="anual_tax_liability"]').show();
            // }
            this.dispatchEvent(
                new CustomEvent("viewreport", {
                  detail:{reportID : 'ANNUAL_TAX' , monthList : this.monthoption}
                })
            );
        }else if(this.currentReport == "Tax Liability"){
            this.dispatchEvent(
                new CustomEvent("viewreport", {
                  detail:{reportID : 'TAX123' , monthList : this.monthoption}
                })
              );
        }
    }
    handleenter(){
        console.log("in mouse down")
        if(this.payperiodList.length > 6){
          if(this.template.querySelector(`c-dropdown-select[data-id="bi_week"]`)){
            console.log("hiii",this.template.querySelector(`c-dropdown-select[data-id="bi_week"]`))
            this.template.querySelector(`c-dropdown-select[data-id="bi_week"]`).toggleStyle(this.toggele) ;  
          }   
        }    
    }

    handlemodalSubmit(){
        console.log("in yes")
        this.dispatchEvent(
            new CustomEvent("show", { detail :''})
          );
        updatelockdate({accountId : this._accid , contactId : this._adminid})
        .then(result => {
            setTimeout(() => {
                this.dispatchEvent(
                  new CustomEvent("hide", { detail : ''})
                );
              },3000); 
            this.closeModal();
            this.dispatchEvent(
                new CustomEvent("viewreport", {
                  detail:{reportID : this.reportID , monthList : this.monthoption}
                })
              );
        })
        .catch(error => {
            console.log("error",error)
        })
        console.log("in yes")

    }

    handlemodalDelete(){
        if(this.fromdate && this.todate){
            this.template.querySelector(`.flat-container[data-id="from"]`).classList.add('area_disable');
            this.template.querySelector(`.flat-container[data-id="to"]`).classList.add('area_disable');

            this.isAreaDisabled = true;
            if(this.currentReport == 'Time and Attendance Detail Report'){
                ErmiDriverList({startDate:this.fromdate,endDate:this.todate,accountId:this._accid})
                .then(result => {
                    let parsedata = JSON.parse(result);
                    console.log("parsedata",parsedata)
                    if(parsedata.length > 0){
                        if (this.template.querySelector('c-user-profile-modal')) {
                            this.template.querySelector('c-user-profile-modal[data-id="attendance_detail_report"]').hide();
                        }
                        // this.fromdate = null;
                        // this.todate = null;
                        // this.template.querySelector(`.flat-container[data-id="from"]`).classList.remove('area_disable');
                        // this.template.querySelector(`.flat-container[data-id="to"]`).classList.remove('area_disable');
                        if (this.template.querySelector('c-user-profile-modal')) {
                            this.template.querySelector('c-user-profile-modal[data-id="anual_tax_liability"]').show();
                        }
                        this.anual_tax_detail = parsedata;
                        this.template.querySelector('c-simple-pagination').updateRecords(this.anual_tax_detail,10)
                        
                    }else{
                        this.dispatchEvent(
                            new CustomEvent("toastmessage", {
                            detail: {
                                errormsg: "error",
                                message:"None of the driver has trips for your selected dates. Please change the dates"
                            } 
                            })
                        )
                        this.fromdate = null;
                        this.todate = null;
                        this.template.querySelector(`.flat-container[data-id="from"]`).classList.remove('area_disable');
                        this.template.querySelector(`.flat-container[data-id="to"]`).classList.remove('area_disable');
                        this.isAreaDisabled = false;
                    }
                
                    
                })
                .catch(error => {
                    console.log("error",error)
                //     this.dispatchEvent(
                //         new CustomEvent("toastmessage", {
                //         detail: {
                //             errormsg: "error",
                //             message:"Failed to send data."
                //         } 
                //         })
                //     )
                })
            }else if(this.currentReport == 'Delete NetChex Report'){
                this.progressbar = true;
                DeleteNetchexCallout({startDate:this.fromdate,endDate:this.todate})
                .then(result => {
                    this.progress = 20;
                    let intervalId;
                    console.log("Delete",result)
                   

                    const callCheckStatus = () => {
                        CheckStatus({longtime:Date.parse(result),batchName:'NetchexDeleteCallout'})
                        .then((acc) => {
                            this.progress = this.progress + 20;
                            let successresult = JSON.parse(acc);
                            console.log("status", JSON.parse(JSON.stringify(acc)));
                            if (successresult.enablePollar == false) {
                                this.progress = 100;
                                clearInterval(intervalId);
                                this.template.querySelector(`.flat-container[data-id="from"]`).classList.remove('area_disable');
                                this.template.querySelector(`.flat-container[data-id="to"]`).classList.remove('area_disable');
                        
                                this.isAreaDisabled = false;
                                if (this.template.querySelector('c-user-profile-modal')) {
                                    this.template.querySelector('c-user-profile-modal[data-id="attendance_detail_report"]').hide();
                                }
                                this.dispatchEvent(
                                    new CustomEvent("toastmessage", {
                                    detail: {
                                        errormsg: "success",
                                        message:"Successfully deleted data."
                                    } 
                                    })
                                )
                                this.template.querySelector(`.date-selector[data-id="from_date"]`).value = '';
                                this.template.querySelector(`.date-selector[data-id="to_date"]`).value = '';
                                this.fromdate = null;
                                this.todate = null;
                                this.progressbar = false;
                                this.progress = 0;
                            
                            }
                            // this.executeCheckStatusfordetail("Successfully deleted data.")
                        })
                        .catch(error => {
                            console.log("CheckStatus",JSON.parse(JSON.stringify(error)))
                        })
                    };  
                    callCheckStatus();
                    intervalId = setInterval(callCheckStatus, 5000);

                })
                .catch(error => {
                    this.dispatchEvent(
                        new CustomEvent("toastmessage", {
                        detail: {
                            errormsg: "error",
                            message:"Failed deleted data."
                        } 
                        })
                    )
                })
            }else if(this.currentReport == 'Job Costing Summary Report'){
            
                    ErmiDriverList({startDate:this.fromdate,endDate:this.todate,accountId:this._accid})
                    .then(result => {
                        let parsedata = JSON.parse(result);
                        if(parsedata.length > 0){
                            if (this.template.querySelector('c-user-profile-modal')) {
                                this.template.querySelector('c-user-profile-modal[data-id="attendance_detail_report"]').hide();
                            }
                            
                            if (this.template.querySelector('c-user-profile-modal')) {
                                this.template.querySelector('c-user-profile-modal[data-id="anual_tax_liability"]').show();
                            }
                            this.anual_tax_detail = parsedata;
                            this.template.querySelector('c-simple-pagination').updateRecords(this.anual_tax_detail,10)
                            
                        }else{
                            this.dispatchEvent(
                                new CustomEvent("toastmessage", {
                                detail: {
                                    errormsg: "error",
                                    message:"None of the driver has trips for your selected dates. Please change the dates"
                                } 
                                })
                            )
                            this.template.querySelector(`.flat-container[data-id="from"]`).classList.remove('area_disable');
                            this.template.querySelector(`.flat-container[data-id="to"]`).classList.remove('area_disable');
                            this.isAreaDisabled = false;
                        }
                    })
                    .catch(error => {
                    })
               
                
            }else if(this.currentReport == 'Trip Detail Report'){
                TripDetailReport({tripStartDate:this.fromdate,tripEndDate:this.todate,id:this._accid})
                .then(result => {
                    let parsedata = JSON.parse(result);
                    console.log("trip detail",parsedata)
                    if(parsedata.length > 0){
                        if (this.template.querySelector('c-user-profile-modal')) {
                            this.template.querySelector('c-user-profile-modal[data-id="attendance_detail_report"]').hide();
                        }
                        let tripdetail = [];
                        parsedata.forEach(index => {
                            tripdetail.push({Driver:index.driverName,Email:index.driverEmail,Date:index.tripDate,Day:index.tripDay,StartTime:index.startTime,
                                EndTime:index.endTime,Mileage:index.mileage,FromLocation:index.FLocationName,FromLocationAddress:index.FLocationAdd,
                                ToLocation:index.TLocationName,ToLocationAddress:index.TLocationAdd,Notes:index.notes,TrackingMethod:index.trackingMethod,
                            fromlat:index.FLocationLatitude,fromlon:index.FLocationLongitude,tolat:index.TLocationLatitude,tolong:index.TLocationLongitude})
                        })
                        tripdetail = JSON.parse(JSON.stringify(tripdetail))
                        let summaryheadernew = ["Driver",  "Email", "Date", "Day", "Start Time", "End Time", "Mileage (mi)", "From Location Name", "From Location Address",
                        "To Location Name", "To Location Address", "Notes", "Tracking Method", "From Location Lat", "From Location Long", "To Location Lat", "To Location Long"];
                        
                        let tempheader = [];
                        let tempworkSheetNameList = [];
                        let tempxlsData = [];
                        let name = '';
                        //push data , custom header , filename and worksheetname for detail xlsx file
                        tempheader.push(summaryheadernew);
                        tempworkSheetNameList.push("Trip Detail Report Report");
                        tempxlsData.push(tripdetail);
                        name = 'Trip Detail Report.xlsx';
                        //Download Summary report(xlsx file)
                            if(tempxlsData.length > 0){
                                console.log("in if")
                                this.callcreatexlsxMethod(tempheader ,name, tempworkSheetNameList , tempxlsData);
                                this.template.querySelector(`.date-selector[data-id="from_date"]`).value = '';
                                this.template.querySelector(`.date-selector[data-id="to_date"]`).value = '';
                                this.fromdate = null;
                                this.todate = null;
                            }
                    }else{
                        this.dispatchEvent(
                            new CustomEvent("toastmessage", {
                            detail: {
                                errormsg: "error",
                                message:"None of the driver has trips for your selected dates. Please change the dates"
                            } 
                            })
                        )
                    }
                })
                .catch(error => {
                })
            }
        }else{
            this.template.querySelector(`.flat-container[data-id="from"]`).classList.remove('area_disable');
                    this.template.querySelector(`.flat-container[data-id="to"]`).classList.remove('area_disable');
                    this.isAreaDisabled = false;
        }
    }

    closeModal(){
        if (this.template.querySelector('c-user-profile-modal[data-id="mileges"]')) {
            this.template.querySelector('c-user-profile-modal[data-id="mileges"]').hide();
        }
    }
    handleCloseModal(){
        this.monthlytaxreport = false;
        this.downloadBtn = false;
        this.byweeksubmit = false;
        this.payperioddropdown = false;
        this.progressbar = false;
        this.progress = 0;
        this.isAreaDisabled = true;
        this.fromdate = '';
        this.todate = '';
    }

    getAccountMonthList() {
        accountMonthList({
          accountId: this._accid
        })
        .then((data) => {
          if (data) {
            console.log("monthoption",JSON.stringify(data))
            this.monthoption = Object.entries(data).map(([label, value]) => ({ label, value }));
            // console.log("monthoption",this.monthoption)

            this.monthoption = JSON.parse(JSON.stringify( this.monthoption))
            console.log("monthoption",JSON.stringify(this.monthoption))
          }
        })
        .catch(error => {
            console.log("monthlist error",error)
        })
    }
    
    handleselectPayPeriod(event){
        this.payperioddate = event.detail.value;
        console.log("this.payperioddate",this.payperioddate)
        let date1 = this.payperioddate.split(' - ')[0];
        let date2 = this.payperioddate.split(' - ')[1];
        this.payperioddate = '20'+date1.split('/')[2]+'-'+date1.split('/')[0]+'-'+date1.split('/')[1]+' - '+'20'+date2.split('/')[2]+'-'+date2.split('/')[0]+'-'+date2.split('/')[1]
        this.isAreaDisabled = false;
        // this.toggele = false;
        // this.template.querySelector(`c-dropdown-select[data-id="bi_week"]`).toggleStyle(this.toggele);
    }
    handleselectMonth(event){
        this.empMonth = event.detail.value;
        this.isAreaDisabled = false;
    }
    handleselectemployeeType(event){
        let type  = event.detail.value;
         this.empType = type.replace(" ","%20")
         this.isAreaDisabled = false;
    }
    handleselectDate(event){
        this.netchexDate = event.detail.value;
        this.isAreaDisabled = false;
    }
    handledownloadsummary(){
        if(this.currentReport == 'Time, Attendance and Mileage Summary Report'){
            if(this.payperioddate){
                window.open("https://"+window.location.host+"/app/TimeandSummaryDetailReport?id="+this._accid+"&endDate="+this.payperioddate.split(' - ')[1]+"&startDate="+this.payperioddate.split(' - ')[0])
            }
            this.payperioddropdown = false; 
        }else if(this.currentReport == 'Bi-Weekly Payment Report'){
            if(this.payperioddate){
                window.open("https://"+window.location.host+"/app/PayDateReport?id="+this._accid+"&endDate="+this.payperioddate.split(' - ')[1]+"&startDate="+this.payperioddate.split(' - ')[0])
            }
            this.payperioddropdown = false; 
        }else if(this.currentReport == 'Variable Reimbursement Report'){
            if(this.payperioddate){
                window.open("https://"+window.location.host+"/app/PayDateReport?id="+this._accid+"&startDate="+this.payperioddate.split(' - ')[0]+"&endDate="+this.payperioddate.split(' - ')[1])
            }
            this.payperioddropdown = false; 
        }else if(this.currentReport == 'Monthly Tax Report'){
            if(this.empMonth &&  this.empType){
                window.open("https://"+window.location.host+"/app/TaxReportPage?month="+this.empMonth+"&empType="+this.empType)
            }
            this.monthlytaxreport = false;
        } else if(this.currentReport == 'Bi-weekly Time and Attendance Payment'){
            if(this.payperioddate){
                window.open("https://"+window.location.host+"/app/TimeSheetNetchexReport?id="+this._accid+"&startDate="+this.payperioddate.split(' - ')[0]+"&endDate="+this.payperioddate.split(' - ')[1])
            }
            this.payperioddropdown = false; 
            this.byweeksubmit = false;
        }  else if(this.currentReport == 'Biweekly Mileage Reimbursement Report'){
            if(this.payperioddate){
                window.open("https://"+window.location.host+"/app/TimeSheetNetchexReport?startDate="+this.payperioddate.split(' - ')[0]+"&endDate="+this.payperioddate.split(' - ')[1])
            }
            this.payperioddropdown = false;
        }   
         
        if (this.template.querySelector('c-user-profile-modal')) {
            this.template.querySelector('c-user-profile-modal[data-id="attendance_summary_report"]').hide();
        }  
        
    }
    handleSubmit(){
        this.template.querySelector(`.pay_period[data-id="pay_period"]`).classList.add('area_disable');
        this.isAreaDisabled = true;
        // this.isAreaDisabled = true;
        this.progressbar = true;
        if(this.currentReport == 'Bi-weekly Time and Attendance Payment'){
            console.log("Bi-weekly Time and Attendance Payment",this.payperioddate.split(' - ')[0])
            postTimeSheetImportAPI({startDate:this.payperioddate.split(' - ')[0],endDate:this.payperioddate.split(' - ')[1],adminId:this._adminid})
            .then((data) => {
                console.log("TimeSheetImportNetchexBatch",data)
                this.progress = 20;
                let intervalId;
                const callCheckStatus = () => {
                    CheckStatus({longtime:Date.parse(data),batchName:'TimeSheetImportNetchexBatch'})
                    .then((acc) => {
                        if(this.progress < 90){
                            this.progress = this.progress + 15;
                        }
                        let successresult = JSON.parse(acc);
                        console.log("status", successresult.enablePollar);
                        // this.executeCheckStatusforbiweek("Succesfully send data to netchex.")
                        if (successresult.enablePollar == false) {
                            this.progress = 100;
                            clearInterval(intervalId);
                            this.template.querySelector(`.pay_period[data-id="pay_period"]`).classList.remove('area_disable');
                            this.isAreaDisabled = false;
                            if (this.template.querySelector('c-user-profile-modal')) {
                                this.template.querySelector('c-user-profile-modal[data-id="attendance_summary_report"]').hide();
                            }
                            this.dispatchEvent(
                                new CustomEvent("toastmessage", {
                                  detail: {
                                    errormsg: "success",
                                    message:"Succesfully send data to netchex."
                                  } 
                                })
                            )
                           
                            this.progressbar = false;
                            this.progress = 0;
                            this.byweeksubmit = false;
                            this.payperioddropdown = false;
                        }
                    })
                    .catch(error => {
                        console.log("CheckStatus",error)
                    })
                };  
                callCheckStatus();
                intervalId = setInterval(callCheckStatus, 5000);
                
            })
            .catch(error => {
               
                this.dispatchEvent(
                    new CustomEvent("toastmessage", {
                      detail: {
                        errormsg: "error",
                        message:"Faild send data to netchex."
                      } 
                    })
                )
            })
           
        }else if(this.currentReport == 'Bi-weekly Salary and Full Time Fixed Payment'){
            
            postHalfFPFullDriverAPI ({startDate:this.payperioddate.split(' - ')[0],endDate:this.payperioddate.split(' - ')[1],adminId:this._adminid})
            .then((data) => {
                this.progress = 20;
                let intervalId;
                const callCheckStatus = () => {
                    CheckStatus({longtime:Date.parse(data),batchName:'NetchexFulltimeHalfFPBatch'})
                    .then((acc) => {
                        if(this.progress < 90){
                            this.progress = this.progress + 15;
                        }
                        
                        let successresult = JSON.parse(acc);
                        console.log("status", successresult.enablePollar);
                        if (successresult.enablePollar == false) {
                            this.progress = 100;
                            clearInterval(intervalId);
                            this.template.querySelector(`.pay_period[data-id="pay_period"]`).classList.remove('area_disable');
                            this.isAreaDisabled = false;
                            if (this.template.querySelector('c-user-profile-modal')) {
                                this.template.querySelector('c-user-profile-modal[data-id="attendance_summary_report"]').hide();
                            }
                            this.dispatchEvent(
                                new CustomEvent("toastmessage", {
                                  detail: {
                                    errormsg: "success",
                                    message:"Full Time Fixed Amount Payment is succesfully send to netchex."
                                  } 
                                })
                            )
                           
                            this.progressbar = false;
                            this.progress = 0;
                            this.byweeksubmit = false;
                            this.payperioddropdown = false;
                        }
                        // this.executeCheckStatusforbiweek("Full Time Fixed Amount Payment is succesfully send to netchex.")
                    })
                    .catch(error => {
                        console.log("CheckStatus",error)
                    })
                };  
                callCheckStatus();
                intervalId = setInterval(callCheckStatus, 5000);
            })
            .catch(error => {
                this.dispatchEvent(
                    new CustomEvent("toastmessage", {
                      detail: {
                        errormsg: "error",
                        message:"Faild send data to netchex."
                      } 
                    })
                )
            })
            
        }
       
    }
  
   
    handleSubmitDate(){
        this.template.querySelector(`.pay_period[data-id="date"]`).classList.add('area_disable');
        this.isAreaDisabled = true;
        this.progressbar = true;
        if(this.currentReport == 'Monthly NetChex Variable Payment'){
            postVariablePaymentAPI({startDate:this.netchexDate ,adminId:this._adminid})
            .then((result) => {
                this.progress = 20;
                let intervalId;
                const callCheckStatus = () => {
                    CheckStatus({longtime:Date.parse(result),batchName:'NetchexVariablePaymentBatch'})
                    .then((acc) => {
                        if(this.progress < 90){
                            this.progress = this.progress + 15;
                        }
                        let successresult = JSON.parse(acc);
                        console.log("status", successresult.enablePollar);
                        // this.executeCheckStatus("Variable Payment is successfully sent to Netchex.")
                        if (successresult.enablePollar == false) {
                            this.progress = 100;
                            clearInterval(intervalId);
                            this.template.querySelector(`.pay_period[data-id="date"]`).classList.remove('area_disable');
                            this.isAreaDisabled = false;
                            if (this.template.querySelector('c-user-profile-modal')) {
                              this.template.querySelector('c-user-profile-modal[data-id="netchex_variable_payment"]').hide();
                            }
                            this.dispatchEvent(
                                new CustomEvent("toastmessage", {
                                  detail: {
                                    errormsg: "success",
                                    message:"Variable Payment is successfully sent to Netchex."
                                  } 
                                })
                            )
                           
                            this.progressbar = false;
                            this.progress = 0;
                        }
                    })
                    .catch(error => {
                        console.log("CheckStatus",error)
                    })
                };  
                callCheckStatus();
                intervalId = setInterval(callCheckStatus, 5000);
               
            })
            .catch(error => {
                this.dispatchEvent(
                    new CustomEvent("toastmessage", {
                      detail: {
                        errormsg: "error",
                        message:"Variable Payment is failed send to netchex."
                      } 
                    })
                )
            })
        }else if(this.currentReport == 'Monthly Part Time Fixed Amount Payment'){
            postFixedAmountAPI({startDate:this.netchexDate ,adminId:this._adminid})
            .then((data) => {
                console.log("result",data)
                this.progress = 20;
                let intervalId;
                const callCheckStatus = () => {
                    CheckStatus({longtime:Date.parse(data),batchName:'NetchexSalaryPartFixAmountBatch'})
                    .then((acc) => {
                        if(this.progress < 90){
                            this.progress = this.progress + 15;
                        }
                        let successresult = JSON.parse(acc);
                        console.log("status", successresult.enablePollar);
                        // this.executeCheckStatus("Fixed Amount Payment is succesfully send to netchex.")
                        if (successresult.enablePollar == false) {
                            this.progress = 100;
                            clearInterval(intervalId);
                            this.template.querySelector(`.pay_period[data-id="date"]`).classList.remove('area_disable');
                            this.isAreaDisabled = false;
                            if (this.template.querySelector('c-user-profile-modal')) {
                              this.template.querySelector('c-user-profile-modal[data-id="netchex_variable_payment"]').hide();
                            }
                            this.dispatchEvent(
                                new CustomEvent("toastmessage", {
                                  detail: {
                                    errormsg: "success",
                                    message:"Fixed Amount Payment is succesfully send to netchex."
                                  } 
                                })
                            )
                           
                            this.progressbar = false;
                            this.progress = 0;
                        }
                    })
                    .catch(error => {
                        console.log("CheckStatus",error)
                    })
                };  
                callCheckStatus();
                intervalId = setInterval(callCheckStatus, 5000);
            })
            .catch(error => {
                this.dispatchEvent(
                    new CustomEvent("toastmessage", {
                      detail: {
                        errormsg: "error",
                        message:"Fixed Amount Payment is failed send to netchex."
                      } 
                    })
                )
              
            })
        }
    }
    intializeDatepickupnew(){
        console.log("datetime",this.fromdate + this.todate )
          let $jq = jQuery.noConflict();
          let $input = $jq(this.template.querySelectorAll('.date-selector'))
          let _self = this
          $input.each(function(index) {
                let _self2 = $jq(this)
                console.log("before")
                let $btn = $jq(this).next()
                console.log("after")
  
                $jq(this).datepicker({
                  // inline mode
                  inline: false,
      
                  // additional CSS class
                  classes: 'flatpickr-cal',
      
                  // language
                  language: 'en',
      
                  // start date
                  startDate: new Date(),
                  //selectedDates: new Date(),
                  
                  // array of day's indexes
                  weekends: [6, 0],
      
                  // custom date format
                  dateFormat:'yyyy-mm-dd',
      
                  // Alternative text input. Use altFieldDateFormat for date formatting.
                  altField: '',
      
                  // Date format for alternative field.
                  altFieldDateFormat: '@',
      
                  // remove selection when clicking on selected cell
                  toggleSelected: false,
      
                  // keyboard navigation
                  keyboardNav: false,
      
                  // position
                  position: 'bottom left',
                  offset: 12,
      
                  // days, months or years
                  view: 'days',
                  minView: 'days',
                  showOtherMonths: true,
                  selectOtherMonths: true,
                  moveToOtherMonthsOnSelect: true,
      
                  showOtherYears: true,
                  selectOtherYears: true,
                  moveToOtherYearsOnSelect: true,
      
                  minDate: '',
                  maxDate: '',
                  disableNavWhenOutOfRange: true,
      
                  multipleDates: false, // Boolean or Number
                  multipleDatesSeparator: ',',
                  range: false,
                  isMobile: false,
                  // display today button
                  todayButton: new Date(),
      
                  // display clear button
                  clearButton: false,
                  
                  // Event type
                  showEvent: 'focus',
      
                  // auto close after date selection
                  autoClose: true,
      
                  // navigation
                  monthsFiled: 'monthsShort',
                  prevHtml: '<svg><path d="M 17,12 l -5,5 l 5,5"></path></svg>',
                  nextHtml: '<svg><path d="M 14,12 l 5,5 l -5,5"></path></svg>',
                  navTitles: {
                      days: 'M <i>yyyy</i>',
                      months: 'yyyy',
                      years: 'yyyy1 - yyyy2'
                  },
      
                  // timepicker
                  datepicker: true,
                  timepicker: false,
                  onlyTimepicker: false,
                  dateTimeSeparator: ' ',
                  timeFormat: '',
                  minHours: 0,
                  maxHours: 24,
                  minMinutes: 0,
                  maxMinutes: 59,
                  hoursStep: 1,
                  minutesStep: 1,
      
                  // callback events
                  onSelect: function(date, formattedDate, datepicker){
  
                       if(index ===  0){
                        let fromdate = date;
                        _self.fromdate =  fromdate;
                       }
                       if(index ===  1){
                        let todate = date;
                        _self.todate =  todate;
                       }
                    //    if(this.fromdate.length > 0 && this.todate.length>0){
                    //     this.isAreaDisabled = false;
                    //    }
                  },
                  
                  onShow: function (dp, animationCompleted) {
                  if (!animationCompleted) {
                    if (dp.$datepicker.find('span.datepicker--close--button').html()===undefined) { /*ONLY when button don't existis*/
                        dp.$datepicker.find('div.datepicker--buttons').append('<span  class="datepicker--close--button">Close</span>');
                        dp.$datepicker.find('span.datepicker--close--button').click(function() {
                          dp.hide();
                        });
                    }
                  }
                },
                  //onShow: '',
                  onHide: '',
                  onChangeMonth: '',
                  onChangeYear: '',
                  onChangeDecade: '',
                  onChangeView: '',
                  // eslint-disable-next-line consistent-return
                  onRenderCell: function(date){
                      if (date.getDay() === 0) {
                            return {
                                classes: 'color-weekend-sunday'
                            }
                      }
                        if (date.getDay() === 6) {
                            return {
                                classes: 'color-weekend-saturday'
                            }
                      }
                  }
                })//.data('datepicker').selectDate(new Date(_self2.val()))
                console.log("complete")
                $btn.on('click', function(){
                  _self2.focus();
                });
                
  
          })
        }
        handlemousedownonsearch(){

        }

        handlePageEvent(event) {
            this.visibleAccounts=[...event.detail.records]
            let checkboxes = this.template.querySelector('.checkbox_all')
           
              checkboxes.checked = false;
           
        }
        handleselectYear(event){
            this.year = event.detail.value;
            console.log("year",this.year)
            if(this.checkBoxFlag == true) {
                this.isAreaDisabled = false;
            }
        }
        handleCheckboxAll(event){
            let checked = event.target.checked;
            let checkboxes = this.template.querySelectorAll('.checkboxCheckUncheckSearch')
            this.checkedList = [];
            for(let i=0; i<checkboxes.length; i++) {
              checkboxes[i].checked = checked;
            }
            if(checked){
                this.checkBoxFlag = true;
                this.visibleAccounts.forEach(element => {
                    this.checkedList.push(element.reimbId);
                });
                if(this.year != null) {
                    this.isAreaDisabled = false;
                }
            } else {
                this.checkBoxFlag = false;
                this.checkedList = [];
                this.isAreaDisabled = true;
            }
        }
        handleCheckbox(event){
            if(event.target.checked == true){
                if(!this.checkedList.includes(event.target.dataset.id)) {
                    this.checkedList.push(event.target.dataset.id);
                }
                this.checkBoxFlag = true;
                if(this.year != null) {
                    this.isAreaDisabled = false;
                }
            } else {
                if(this.checkedList.includes(event.target.dataset.id)) {
                    this.checkedList.splice(this.checkedList.indexOf(event.target.dataset.id), 1);
                }
                if(this.checkedList.length == 0) {
                    this.checkBoxFlag = false;
                    this.isAreaDisabled = true;
                }
            }
        }
        handleDownloadExcel(){
            let selectedId =[];
            console.log("currentreport",this.currentReport)
           
            if(this.currentReport == "Annual Tax Liability Report"){
                let checkboxes = this.template.querySelectorAll('.checkboxCheckUncheckSearch')
                for(let i=0; i<checkboxes.length; i++) {
                    console.log("checkboxes[i].checked",checkboxes[i].checked)
                if(checkboxes[i].checked  == true){
                    selectedId.push(this.visibleAccounts[i].reimbId)
                }
                }
                console.log(JSON.stringify(selectedId))
                downloadExcel({condata: JSON.stringify(selectedId),year:this.year})
                .then((data) => {
                let arrOfSummry = [];
                let summaryxlsData = [] ;
                // let tempheader = [];
                let resultdata = JSON.parse(data);
                console.log("resultdata",resultdata.length)
                if(resultdata.length > 0){
                    this.template.querySelector('.modal_header').classList.add('area_disable');
                    this.isAreaDisabled = true;
                    resultdata.forEach(element =>{
                        arrOfSummry.push({drivername:element.drivername,employeeid:element.employeeid,emailid:element.emailid,imputedincome:element.imputedincome})
                        return arrOfSummry;
                    })
                    summaryxlsData = JSON.parse(JSON.stringify(arrOfSummry))
                    console.log("in if",summaryxlsData)

                    let summaryheadernew = [ "Employee Name","Employee ID","Employee Email","Imputed Income"];
                    let tempheader = [];
                    let tempworkSheetNameList = [];
                    let tempxlsData = [];
                    let name = '';
                    //push data , custom header , filename and worksheetname for detail xlsx file
                    tempheader.push(summaryheadernew);
                    tempworkSheetNameList.push("Annual Tax Liability Report");
                    tempxlsData.push(summaryxlsData);
                    name = 'Annual Tax Liability Report.xlsx';
                    //Download Summary report(xlsx file)
                        if(tempxlsData.length > 0){
                            console.log("in if")
                            this.callcreatexlsxMethod(tempheader ,name, tempworkSheetNameList , tempxlsData);
                        }
                        this.template.querySelector('.modal_header').classList.remove('area_disable');
                        this.isAreaDisabled = false;
                        if (this.template.querySelector('c-user-profile-modal')) {
                            this.template.querySelector('c-user-profile-modal[data-id="anual_tax_liability"]').hide();
                            this.yeardropdown = false;
                        } 

                }else{
                    if (this.template.querySelector('c-user-profile-modal')) {
                        this.template.querySelector('c-user-profile-modal[data-id="anual_tax_liability"]').hide();
                        this.yeardropdown = false;
                    } 
                    this.dispatchEvent(
                        new CustomEvent("toastmessage", {
                        detail: {
                            errormsg: "success",
                            message:"No data found for this driver."
                        } 
                        })
                    )
                
                }        
                })
                .catch(error => {
                    console.log("error",error)
                })
            }else if(this.currentReport == "Job Costing Summary Report" ){
                console.log("in if")
                // let remid =[];
                let checkboxes = this.template.querySelectorAll('.checkboxCheckUncheckSearch')
                for(let i=0; i<checkboxes.length; i++) {
                    if(checkboxes[i].checked  == true){
                        // remid.push(this.visibleAccounts[i].reimbId);
                        window.open("https://"+window.location.host+"/app/JobCostingSummary?id="+this.visibleAccounts[i].reimbId+"&startDate="+this.fromdate+"&endDate="+this.todate);
                    }
                }
                console.log("console",this.fromdate + this.todate)
               
                if (this.template.querySelector('c-user-profile-modal')) {
                    this.template.querySelector('c-user-profile-modal[data-id="anual_tax_liability"]').hide();
                }
                this.template.querySelector(`.date-selector[data-id="from_date"]`).value = '';
                this.template.querySelector(`.date-selector[data-id="to_date"]`).value = '';
                this.fromdate = null;
                this.todate = null;
            } else if(this.currentReport == "Time and Attendance Detail Report" ){
                console.log("in if")
                // let remid =[];
                let checkboxes = this.template.querySelectorAll('.checkboxCheckUncheckSearch')
                for(let i=0; i<checkboxes.length; i++) {
                    console.log("checkboxes[i].checked ",checkboxes[i].checked )

                    if(checkboxes[i].checked  == true){
                        // remid.push(this.visibleAccounts[i].reimbId);
                        window.open("https://"+window.location.host+"/app/TimeandSummaryReport?id="+this.visibleAccounts[i].reimbId+"&startDate="+this.fromdate+"&endDate="+this.todate);
                    }
                }
                if (this.template.querySelector('c-user-profile-modal')) {
                    this.template.querySelector('c-user-profile-modal[data-id="anual_tax_liability"]').hide();
                }
                // this.template.querySelector(`.date-selector[data-id="from_date"]`).value = '';
                // this.template.querySelector(`.date-selector[data-id="to_date"]`).value = '';
                this.fromdate = null;
                this.todate = null;
            } 
        }
        callcreatexlsxMethod(headerList , filename , worksheetNameList , sheetData ){
            //Download Summary report(xlsx file)
            // <c-download-C-S-V-File></c-download-C-S-V-File>
            console.log("in xl")
            this.template.querySelector("c-download-C-S-V-File").download(headerList , filename , worksheetNameList , sheetData);
        }
        handleClose(){
            if (this.template.querySelector('c-user-profile-modal')) {
                this.template.querySelector('c-user-profile-modal[data-id="anual_tax_liability"]').hide();
                this.yeardropdown = false;
                this.backbutton = false;
            } 
        }
        handleBack() {
            this.dispatchEvent(new CustomEvent('backtodashboard', {}));
        }
}