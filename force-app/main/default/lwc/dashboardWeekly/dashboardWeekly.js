import { LightningElement,api } from 'lwc';
import emcCss from '@salesforce/resourceUrl/EmcCSS';
import getMileageData from '@salesforce/apex/ConfirmTripTimeERMIController.getMileageData';
import sendErrorEmail from '@salesforce/apex/ConfirmTripTimeERMIController.sendErrorEmail';
export default class DashboardWeekly extends LightningElement {
    companyLogoUrl = emcCss + '/emc-design/assets/images/logo/mBurse-logo.png';
    @api profile;
    @api userRole;
    contactId;
    accountId;
    admindriver;
    listOfMileage;
    keyFields;
    listColumn;
    list;
    biweekId;
    typeOfDriver;
    driverName;
    payPr;
    syncParam;
    showTeam = "false";
    tripKeyFields = ["mileage", "driveTime", "stayTime", "totalTime"];
    tripListColumn = [
      {
        id: 1,
        name: "Mileage",
        colName: "mileage"
      },
      {
        id: 2,
        name: "Drive Time",
        colName: "driveTime"
      },
      {
        id: 3,
        name: "Stay Time",
        colName: "stayTime"
      },
      {
        id: 4,
        name: "Total Time",
        colName: "totalTime"
      }
    ]

    tripKeyFields1 = ["mileage"];
    tripListColumn1 = [
      {
        id: 1,
        name: "Total Mileage",
        colName: "mileage"
      }
    ]

    handleLogout(){
        // eslint-disable-next-line no-restricted-globals
        location.href = '/app/secur/logout.jsp';
    }

    parseError(data) {
        return JSON.parse(JSON.stringify(data));
    }

    proxyToObject(data){
        return JSON.parse(data);
    }

    /* Get url parameters */
    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }

    refreshPage(){
        window.location.reload();
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
    
    dynamicBinding(data, keyFields) {
        data.forEach((element) => {
            let model = [];
            for (const key in element) {
                if (Object.prototype.hasOwnProperty.call(element, key)) {
                    let singleValue = {};
                    if (keyFields.includes(key) !== false) {
                        singleValue.key = key;
                        singleValue.value = element[key];
                        singleValue.id = element.contactid;
                        model.push(singleValue);
                    }
                }
            }
            element.id = element.biWeekId
            element.keyFields = this.mapOrder(model, keyFields, "key");
        });
    }

    handleToastEvent(event){
      const toastEvent = new CustomEvent("toast", {
        detail: event.detail
      });
      this.dispatchEvent(toastEvent);
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

    async connectedCallback() {
        const idParamValue = this.getUrlParamValue(window.location.href, 'id');
        const aidParamValue = this.getUrlParamValue(window.location.href, 'accid');
        const showTeam = this.getUrlParamValue(window.location.href, 'showteam');
        const sync = this.getUrlParamValue(window.location.href, 'sync');
        const admindriver = this.getUrlParamValue(window.location.href, 'admindriver');
        this.contactId = idParamValue;
        this.accountId = aidParamValue;
        this.showTeam = showTeam;
        this.syncParam = sync;
        this.admindriver = admindriver;
        await getMileageData({
            contactId: this.contactId
        }).then(result =>{ 
            this.listOfMileage = result;
            if(result){
                this.list = this.proxyToObject(result);
                this.typeOfDriver = (this.list[0] != null || this.list[0] !== undefined) ? this.list[0].driverType : "";
                this.driverName = (this.list[0] != null || this.list[0] !== undefined) ? this.list[0].driverName : "Driver";
                this.biweekId = (this.list[0] != null || this.list[0] !== undefined) ? this.list[0].biWeekId : "";
                this.payPr = (this.list[0] != null || this.list[0] !== undefined) ? this.list[0].biWeekPayperiod : "";
                this.listColumn = (this.typeOfDriver !== 'Driver - Salary') ? this.tripListColumn : this.tripListColumn1;
                this.keyFields =  (this.typeOfDriver !== 'Driver - Salary') ? this.tripKeyFields : this.tripKeyFields1;
                this.dynamicBinding(this.list, this.keyFields);
                if (window.performance.getEntriesByType("navigation")[0].type !== 'reload' && this.syncParam !== null) {
                  sendErrorEmail({
                    conEmail: this.list[0].driverEmail,
                    driverName: this.list[0].driverName,
                    biweekName: this.list[0].biWeekPayperiod,
                    mileage: this.list[0].mileage,
                    driveTime: this.list[0].driveTime,
                    stayTime: this.list[0].stayTime,
                    totalTime: this.list[0].totalTime,
                    countError: this.list[0].countErrorCheck,
                    driverType : this.list[0].driverType
                  })
                  .then({})
                  .catch(err=> {
                    console.log(this.parseError(err));
                  })
                }
            }
            console.log("Biweekly Result---", result);
        })
        .catch(err=> {
          console.log(this.parseError(err));
        })

    }
}