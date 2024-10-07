import { LightningElement, api } from 'lwc';
import editInlineNewEmployee from '@salesforce/apex/RosterController.editInlineNewEmployee';
import getlistAllEmployees from '@salesforce/apex/RosterController.getlistAllEmployees';
import {
    toastEvents, modalEvents
} from 'c/utils';

export default class RemoveEmployee extends LightningElement {
    @api employees;
    @api accid;
    @api contactid
    @api employeeList;
    @api editableView = false;
    @api paginated = false;
    @api isScrollable = false;
    @api isDataLoaded = false;
    @api listOfEditRecord = [];
    sortable = true;
    @api isCheckbox = false;
    @api isSortable = false;
    paginatedModal = true;
    filter = true;
    coltype="String";
    sortorder="desc";
    minDate = '';
    maxDate = '';
    @api classToTable = 'slds-table--header-fixed_container preview-height';
    @api empKeyFields = ['name', 'deactivaedDate'];
    noMessage = 'There is no user data available';
    @api currentRecord;
    @api deavtivationDate ='';
    isDisabledBG = true;
    isEnabled = true;
    isDisabled = false;
    displaySave = false;
    dateFormat = 'mm/dd/yyyy';
    @api column = [
        {
            "id": 1,
            "name": "Name",
            "colName": "name",
            "colType": "String",
            "arrUp": true,
            "arrDown": false,
            "isChecked": false,
            "isCheckBox": false
        },{
            "id": 2,
            "name": "Deactivated Date",
            "colName": "deactivaedDate",
            "colType": "String",
            "arrUp": false,
            "arrDown": false,
            "isChecked": false,
            "isCheckBox": false
        }
    ] //
    @api download = false;
    connectedCallback(){
        var date = new Date();
        const numWeeks = 2;
        const now = new Date();
        now.setDate(now.getDate() + numWeeks * 7);
        this.employeeList = this.proxyToObject(this.employees.filter(emp => !emp.deactivaedDate)); //this.proxyToObject(this.employees.filter(emp => !emp.deactivaedDate))
        this.dynamicBinding(this.employeeList, this.empKeyFields);
        this.isDataLoaded = true;
        this.paginated = true;
        this.paginatedModal = true;
        this.isScrollable = true;
        this.minDate = new Date(date.getFullYear(), date.getMonth() - 1, 1);
        this.maxDate = now;
    }

    dynamicBinding(data, keyFields) {
        data.forEach(element => {
            let model = [];
            for (const key in element) {
                if (Object.prototype.hasOwnProperty.call(element, key)) {
                    let singleValue = {}
                    if (keyFields.includes(key) !== false) {
                        singleValue.key = key;
						singleValue.value = (key === "deactivaedDate" && element[key]) ? this.convertDateFormat(element[key]) : element[key];
						// singleValue.isToggle = 
						// Drop down keys
						

						singleValue.twoDecimal = false;
						singleValue.uId = element.userid;
                        singleValue.onlyLink = key === "name" ? true : false;
                        singleValue.isLink = key === "name" ? true : false;
                        model.push(singleValue);
                    }
                    singleValue.id = element['userid'];
                }
            }
			element.id = element['userid'];
            element.keyFields = this.mapOrder(model, keyFields, 'key');
        });
		this.employeeList = data;
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

    handleModal(event) {
        this.currentRecord = event.detail;
        this.listOfEditRecord.push(this.currentRecord);
        let selectedRecord = this.getSingleEmployee(this.currentRecord);
        if(selectedRecord?.deactivaedDate) {
            this.deavtivationDate = selectedRecord?.deactivaedDate
        }
        this.template.querySelector('c-user-profile-modal').show();
    }

    handleCloseModal(){
        this.currentRecord = '';
        this.deavtivationDate = '';
        this.template.querySelector('c-user-profile-modal').hide();
    }

    handledate(event) {
        this.deavtivationDate = event.detail;
    }

    @api
    handleSearch(search) {
        this.template.querySelector('c-user-data-table').searchByKey(search, this.employeeList);
    }

    updateDeactivationDate() {   
        // if(!this.deavtivationDate){
        //     let errorObj = {
        //         type: 'error',
        //         message : 'Please select date'
        //     }
        //     toastEvents(this, errorObj);
        //     return;
        // }
        this.displaySave = true;
        let recordIndex = this.employeeList.findIndex(emp => emp.userid === this.currentRecord);
        this.employeeList[recordIndex].deactivaedDate = this.deavtivationDate;
        this.employeeList[recordIndex].deactivateUser = (this.deavtivationDate) ? true : false;
        this.dynamicBinding(this.employeeList, this.empKeyFields);
        this.template.querySelector("c-user-data-table").refreshTable(this.employeeList, "userid");
        this.handleCloseModal();
    }

    updateRecord() {
        if(this.listOfEditRecord.length){
            let recordToBeUpdate = [];
				this.listOfEditRecord.forEach(id => {
					recordToBeUpdate.push(this.getSingleEmployee(id))
				})
            this.startSpinner();
            editInlineNewEmployee({
                listofemployee: JSON.stringify(recordToBeUpdate),
                accid: this.accid ,
                contactid: this.contactid
            })
            .then(response => {
                let result = JSON.parse(response);
                if(result?.hasError) {
                    this.stopSpinner();
                    console.error(result.message);
                    let toastError = { type: "error", message: "Something went wrong." };
                    toastEvents(this, toastError);
                }
                if(!result?.hasError) {
                    this.displaySave = false;
                    this.listOfEditRecord = [];
                    this.getEmployees();
                    this.stopSpinner();
                }
                // this.getEmployees();
            })
            .catch(err=> {
                console.log(this.proxyToObject(err));
            })
        }
    }

    getEmployees(){
        getlistAllEmployees({accid: this.accid, contactid: this.contactid})
        .then(response => {
			this.employees = JSON.parse(response);
            if(this.isEnabled) {
                this.employeeList =  this.proxyToObject(this.employees.filter(emp => !emp.deactivaedDate));
            }else if(this.isDisabled) {
                this.employeeList = this.proxyToObject(this.employees.filter(emp => emp.deactivaedDate));
            }
            this.dynamicBinding(this.employeeList, this.empKeyFields);
            this.template.querySelector("c-user-data-table").refreshTable(this.employeeList);
						this.template.querySelector('c-user-data-table').searchByKey("", this.employeeList);
            this.stopSpinner();
            let updateEmpMessage = `Records updated`;
            let toastSuccess = { type: "success", message: updateEmpMessage };
            toastEvents(this, toastSuccess);
        })
        .catch(err => {
            console.log(this.proxyToObject(err));
        });
    }

    getSingleEmployee(id) {
		let employelist = this.proxyToObject(this.employeeList);
		return employelist.find(employee => (employee.userid === id));
	}

    proxyToObject(data) {
        return data ? JSON.parse(JSON.stringify(data)) : '';
    }

    convertDateFormat(inputDate) {
        if(inputDate){
            // Step 1: Parse the input string to create a Date object
            const dateObj = new Date(inputDate);
    
            // Step 2: Extract the month, day, and year from the Date object
            const month = dateObj.getMonth() + 1; // Months are zero-based, so adding 1 to get the correct value
            const day = dateObj.getDate();
            const year = dateObj.getFullYear().toString().slice(-2); // Extract the last two digits of the year
          
            // Step 3: Format the month, day, and year values to match MM/DD/YY format
            const formattedMonth = month < 10 ? `0${month}` : month;
            const formattedDay = day < 10 ? `0${day}` : day;
          
            // Step 4: Concatenate the formatted values to get the final date string
            const formattedDate = `${formattedMonth}/${formattedDay}/${year}`;
          
            return formattedDate;
        } else {
            return '';
        }
	}

    startSpinner() {
		this.dispatchEvent(
            new CustomEvent("show", {
                detail: "spinner"
            })
        );
	}

	stopSpinner() {
		this.dispatchEvent(
            new CustomEvent("hide", {
                detail: "spinner"
            })
        );
	}

    handleTab(event) {
        let tab = event.currentTarget.dataset.id;
        if(tab === 'enabled') {
            this.isEnabled = true;
            this.isDisabled = false;
            this.displaySave = false;
            this.listOfEditRecord = [];
            this.employeeList =  this.proxyToObject(this.employees.filter(emp => !emp.deactivaedDate));
        }else if(tab === "disabled") {
            this.isEnabled = false;
            this.isDisabled = true;
            this.displaySave = false;
            this.listOfEditRecord = [];
            this.employeeList = this.proxyToObject(this.employees.filter(emp => emp.deactivaedDate));
        }
        this.dynamicBinding(this.employeeList, this.empKeyFields);
        this.template.querySelector("c-user-data-table").refreshTable(this.employeeList);
        const buttons = this.template.querySelectorAll('.tab-btn');
        buttons.forEach(button => {
            button.classList.remove('is-active');
        });

        // Add the active class to the clicked button
        const clickedButton = event.target;
        clickedButton.classList.add('is-active');
    }
}