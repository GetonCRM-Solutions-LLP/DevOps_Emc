import { LightningElement, api } from 'lwc';
import getCustomEmployeeTableSettings from '@salesforce/apex/RosterController.getCustomEmployeeTableSettings';
import getCustomAddEmployeeSettings from '@salesforce/apex/RosterController.getCustomAddEmployeeSettings';

 //name email city state deactivaedDate role freez manager 
//       
export default class ManageEmployeeField extends LightningElement {

    @api accid;
    @api frequency;
    @api cellphone;
    @api allFields = [
        { name: 'appVersion', label: 'App Version' },
        { name: 'employeeId', label: 'Employee Id' },
        { name: 'glcode', label: 'GL Code' },
        { name: 'department', label: 'Department' },
        { name: 'company', label: 'Company' },
        { name: 'territory', label: 'Territory' },
        { name: 'am', label: 'Region' },
        { name: 'drivingStates', label: 'Driving States' },
        { name: 'deactivaedDate', label: 'Term' },
        { name: 'name', label: 'Name' },
        { name: 'deactivationBy', label: 'Deactivation By' },
        { name: 'managerName', label: 'Manager' },
        { name: 'sage100ID', label: 'Sage 100 ID' },
        { name: 'code', label: 'Code' },
        { name: 'driverType', label: 'Driver Type' },
        { name: 'freeze', label: 'Freeze' },
        { name: 'costCode', label: 'Cost Code' },
        { name: 'bpCode', label: 'BP Code' },
        { name: 'email', label: 'Email' },
        { name: 'jobtitle', label: 'Job Title' },
        { name: 'city', label: 'City' },
        { name: 'zipCode', label: 'Zip Code' },
        { name: 'district', label: 'District' },
        { name: 'deptDesign', label: 'Department Design' },
        { name: 'netchexEmployeeID', label: 'Netchex Employee Id' },
        { name: 'role', label: 'Role' },
        {name: 'state', label : 'State'},
        {name: 'firstName', label : 'First Name'},
        {name: 'lastName', label : 'Last Name'},
        {name: 'activationDate', label : 'Activation Date'},
        {name: 'addedDate', label : 'Added Date'},
        {name: 'vehicalType', label : 'Vehicle Type'},
        {name: 'cellphone', label : 'Cell Phone'},
        {name: 'monthlymileage', label : 'Average Monthly Mileage'},
        {name : 'Businesshours', label : 'Business and After Hours'},
        {name: 'appSetting', label : 'App Setting'},
        {name: 'lastSynced', label: 'Last Sync Date' },
        {name: 'mileageForDeduction', label: 'Mileage For Deduction'},
        {name: 'fixedamount', label: 'Fixed Amount'},
        {name: 'compliancestatus', label: 'Compliance'},
        {name : 'totalreimbursement', label: 'Average Monthly Reimbursement'},
        {name: 'ReimbursementFrequency', label : 'Reimbursement Frequency'},
        {name: 'CellPhoneProvider', label : 'Cell Phone Provider'},
        {name: 'manualEntryUser', label : 'Manual Entry User'}
      ];
    
    @api activities = ["Activity","Mass Deactivate", "Freeze", "UnFreeze", "Send Driver Packet", "Resend mLog App", "Mass Reset Password", "Enable User", "Mileage Lock Date"];
    @api defaultAddEmployeeFields = ['firstName', 'lastName', 'email', 'role', 'managerName', 'employeeId', 'cellphone', 'activationDate', 'addedDate', 'vehicalType', 'zipCode', 'city', 'state', 'drivingStates', 'monthlymileage']
    @api defaultField = ['name', 'email', 'city', 'state', 'deactivaedDate', 'role', 'freeze', 'managerName', 'zipCode', 'appVersion', 'drivingStates'];
    @api defaultExportField = ['appVersion', 'appSetting', 'Businesshours', 'lastSynced'];
    @api defaultExportField2 = ['employeeId','firstName','lastName','email','city','state','zipCode','cellphone','drivingStates','activationDate','freeze','deactivaedDate','role','managerName','vehicalType','fixedamount','compliancestatus','monthlymileage','totalreimbursement','appVersion'];
     
   


    @api ERMI_Account_table;
    @api SPBS_Account_table;
    @api NewEnglandGypsum_table;
    @api DesignAir_table;
    @api SurfacePrep_Account_table;
    @api GPSAccount_table;
    customSetting;
	accountName;
    @api viewAllEmploye
    @api keyFields
    @api addEmpKeyFields
    @api exportFields
    @api addEmployee
    @api date;
    @api required;
    @api select;
    @api text;
    @api disabled;
    @api component;
    @api planField;


    connectedCallback() {
        getCustomEmployeeTableSettings()
        .then(responce => {
            let result = this.proxyToObj(responce);
            let isAccountInCustomSetting = false;
            let expFields;
            result.forEach(res => {
                console.log('res : ' + JSON.stringify(res));
                if(res && res?.Account_Id__c && res?.Account_Id__c?.split(',').includes(this.accid)) {
                    this.keyFields = res?.fields__c.split(',');
                    this.addEmpKeyFields = res?.addEmployeeFields__c.split(',');
                    this.viewAllEmploye = this.getFormatedTableArray(this.keyFields);
                    if(res.hasOwnProperty('Export_field__c')){
                        expFields = res?.Export_field__c.split(',');
                    } else {
                        expFields = this.defaultExportField2;
                    }
										this.accountName = res?.Name;
                    if(res?.Name === "ERMI_Account") {
                        this.activities.push("Sync All");
                    } else if(res?.Name === "SPBS_Account" || res?.Name === "NewEnglandGypsum" || res?.Name === "Cowtown Materials" || res?.Name === "Commonwealth Building" || res?.Name === "Greer Laboratories" || res?.Name === "Test Accounts"){
                        this.activities.push("Concur Connect");
                    }
                    isAccountInCustomSetting = true;
                }
            });
            if(!isAccountInCustomSetting) {
                this.keyFields = this.defaultField;
                this.viewAllEmploye = this.getFormatedTableArray(this.keyFields);
                this.addEmpKeyFields = this.defaultAddEmployeeFields
                expFields = this.defaultExportField2;
            }
            /* Update Reimbursement Frequency field & Cell Phone field based on account field */
            let originalAddEmpKeyFields = this.addEmpKeyFields, exportFields = expFields;
            let newAddEmpKeyFields = (this.frequency) ? (this.frequency === 'Both') ? [...originalAddEmpKeyFields, 'ReimbursementFrequency'] : originalAddEmpKeyFields : originalAddEmpKeyFields;
            newAddEmpKeyFields = (this.cellphone) ? (this.cellphone === 'Both') ? [...newAddEmpKeyFields, 'CellPhoneProvider'] : newAddEmpKeyFields : newAddEmpKeyFields;
            let newExpFields = (this.frequency) ? (this.frequency === 'Both') ? [...exportFields, 'ReimbursementFrequency'] : exportFields : exportFields;
            newExpFields = (this.cellphone) ? (this.cellphone === 'Both') ? [...newExpFields, 'CellPhoneProvider'] : newExpFields : newExpFields;
            this.addEmpKeyFields = newAddEmpKeyFields
            expFields = newExpFields
    
            if(expFields && expFields.length){
                this.exportFields = this.getExportFields(expFields);
            } 
            if(this.viewAllEmploye?.length) {
                this.dispatchEvent(new CustomEvent('tablefield', {
                    detail: {
                        column : this.viewAllEmploye,
                        key: this.keyFields,
                        activities: this.activities,
                        export : this.exportFields
                    }
                }));
            }
            this.getAddEmployeField();
        })
        .catch(err => {
            console.log(this.proxyToObj(err))
        })
    }

    getExportFields(expFields){
        let fields =  ["employeeId",...expFields, ...this.defaultExportField];
        fields = [...new Set(fields)];
        let exportFields = [];
        fields = fields.forEach(f => {
            let expFiled = {
                name : f,
                label :  this.getFieldLable(f)
            }
            expFiled.label = (expFiled.label === 'Freeze') ? 'Frozen Date' : (expFiled.label === 'Driver Type') ? 'Status' : (expFiled.label === 'Vehicle Type') ? 'Standard Vehicle' : expFiled.label
            exportFields.push(expFiled)
        });
        return exportFields;
    }

    proxyToObj(data) {
        return data ? JSON.parse(JSON.stringify(data)) : '';
    }

    getAddEmployeField() {
        getCustomAddEmployeeSettings()
        .then(responce => {
            let result = this.proxyToObj(responce);
            if(result?.length) {
                result.forEach(res => {
                    if(res?.Name === "addEmployee") {
                        this.text = res?.text__c ? res?.text__c.split(',') : [];
                        this.select = res?.select__c ? res?.select__c.split(',') : [];
                        this.date = res?.date__c ? res?.date__c.split(',') : [];
                        this.component = res?.component__c ? res?.component__c.split(',') : [];
                        this.disabled = res?.Disabled__c ? res?.Disabled__c.split(',') : [];
                        this.required = res?.required__c ? res?.required__c.split(',') : [];
                        this.planField = res?.planField__c ? res?.planField__c.split(',') : [];
                    }
                })
            }
            this.addEmployee = this.getFormatedFormArray(this.addEmpKeyFields);
            console.log("Add Employee", JSON.stringify(this.addEmployee))
            if(this.addEmployee?.length) {
                this.dispatchEvent(new CustomEvent('formfield', {
                    detail: {
                        column : this.addEmployee,
                    }
                }));
            }
        })
        .catch(err => {
            console.log(this.proxyToObj(err));
        })
    }

    getFormatedTableArray(arr) {
        let data = [];
        let  i = 1;
        arr.forEach(f => {
            let tmp = {
                "id": i,
                "name": this.getFieldLable(f),
                "colName": `${f}`,
                "colType": "String",
                "arrUp": false,
                "arrDown": false,
                "isChecked": false,
                "isCheckBox": false
            }
            data.push(tmp);
            i++;
        });
        return data;
    }

    getFormatedFormArray(arr) {
        let data = [];
        arr.forEach(f => {
            let fldObject = {
                fieldName: f,
                label: this.getFieldLable(f),
                type: this.getFieldType(f),
                value: this.setValue(f),
                isRequired: this.isRequired(f),
                isDateField: this.isDate(f),
                isDropDown: this.isSelect(f),
                isDrivingState: this.isComponent(f),
                isDisable: this.isDisable(f),
                displayValue :  '',
                dropDownList: "",
								is7DigitCostCode: (this.accountName === 'Flashco') ? true : false,
                errorClass: this.isText(f) ? this.isDisable(f) ?  'content-input disabled-input' : 'content-input' : '',
                // errorClass: this.isNotInput(field.type) ? field.fieldName !== "state" ?  'content-input' : 'content-input disabled-input' : '',
                cmpClass : this.getCmpClass(f),
                isValid: false,
                isDependentDropDown: false,
                isPlanField : this.planField?.includes(f) ? true : false,
                errorMsg : ''
            }
            data.push(fldObject);
        });
        return data;
    }

    getFieldLable(field) {
        let currentField = this.allFields.filter(f => f.name === field);
        return currentField[0]?.label ? currentField[0]?.label : '';
    }

    setValue(field) {
        if(field === "addedDate") {
            return this.getTodayDate()
        } else if( field === "drivingStates") {
            return []
        } else {
            return "";
        }
    }

    getTodayDate() {
        const currentDate = new Date();
        const month = (currentDate.getMonth() + 1).toString().padStart(2, '0');
        const day = currentDate.getDate().toString().padStart(2, '0');
        const year = currentDate.getFullYear().toString();
        const formattedDate = `${month}/${day}/${year}`;
        return formattedDate;
    }

    getFieldType(field) {
        if(this.isDate(field)) {
            return "date";
        } else if(this.isSelect(field)) {
            return "select";
        } else if(this.isText(field)) {
            return "text";
        } else if(this.isComponent(field)) {
            return "component"
        } else {
            console.error("field does added in custom setting..!");
            return '';
        }
    }

    getCmpClass(field) {
        if(this.isSelect(field)) {
            return "default-box-input slds-truncate";
        } else if(this.isDate(field)) {
            if(this.isDisable(field)) {
                return "flat-container disabled-input";
            } else {
                return "flat-container ";
            }
        } else {
            return '';
        }
    }

    isDate(field) {
        // return (this.date?.length && this.date.includes(field)) ? true : false ;
        return this.isFieldInclude(this.date, field);
        // return (this.date && this.date?length && this.date.includes(field)) ?  true : false;
    }

    isText(field) {
        return this.isFieldInclude(this.text, field);
    }

    isSelect(field) {
        return this.isFieldInclude(this.select, field);
    }

    isComponent(field) {
        return this.isFieldInclude(this.component, field);
    }

    isRequired(field) {
        return this.isFieldInclude(this.required, field);
    }

     isDisable(field) {
        return this.isFieldInclude(this.disabled, field);
     }

    isFieldInclude(data, field) {
        return (data?.length && data.includes(field)) ? true : false ;
    }
}