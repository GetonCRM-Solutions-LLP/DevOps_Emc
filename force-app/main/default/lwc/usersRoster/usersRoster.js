import { LightningElement, api, wire } from 'lwc';
import getlistAllEmployees from '@salesforce/apex/RosterController.getlistAllEmployees';
import getListOfDriverToSendEnvelope from '@salesforce/apex/RosterController.ListOfDriverToSendEnvelope';
import resourceImage from '@salesforce/resourceUrl/mBurseCss';
import EDIT_ICON from '@salesforce/resourceUrl/editAction';
import ADD_ICON from '@salesforce/resourceUrl/addAction';
import editInlineNewEmployee from '@salesforce/apex/RosterController.editInlineNewEmployee';
import getDrivingStates from '@salesforce/apex/RosterController.getDrivingStates';
import getJobTitle from '@salesforce/apex/RosterController.getJobTitle';
import getCompany from '@salesforce/apex/RosterController.getCompany';
import getDepartment from '@salesforce/apex/RosterController.getDepartment';
import updateLockDate from '@salesforce/apex/RosterController.updateLockDate';
// import sendSignatureRequestForDriver from '@salesforce/apex/NewAccountDriverController.sendSignatureRequestForDriver';
import getPickListValuesIntoList from '@salesforce/apex/RosterController.getPickListValuesIntoList'
import empNoneEditableField from '@salesforce/label/c.employeeNoneEditableFields'
import MassSyncTrips from '@salesforce/apex/RosterController.MassSyncTrips';
import getCustomAddEmployeeSettings from '@salesforce/apex/RosterController.getCustomAddEmployeeSettings';
import putHTTPMassWlcmMail from '@salesforce/apex/RosterController.putHTTPMassWlcmMail';
import getCustomRedirectURLSettings from '@salesforce/apex/RosterController.getCustomRedirectURLSettings';


import {
    toastEvents, modalEvents
} from 'c/utils';



export default class UsersRoster extends LightningElement {

    @api employeeColumn = [];
	@api activities = [];
	@api activityList = [];
    isSort = true;
    @api employeeList;
	@api employees;
	@api drivers;
    @api empKeyFields;
    // @api empKeyFields = ["name", "email", "deactivaedDate", "role", "freeze", "managerName", "zipCode", "appVersion", "drivingStates", ];
    sortable = true;
    isdataLoaded = false;
    @api editableView = false;
    @api classToTable = 'slds-table--header-fixed_container preview-height';
	@api paginated = false;
	@api isEditMode = false;
	searchIcon = resourceImage + '/mburse/assets/mBurse-Icons/Vector.png';
	isRecord = false;
	@api isScrollable = false;
	@api isCheckbox = false;
	@api editIconUrl = `${EDIT_ICON}#editicon`;
	@api addIconUrl = `${ADD_ICON}#addicon`;
	isListEmployeetab = true;
	isAddEmployeeTab = false;
	isImportTab = false;
	@api showModal = false;
    @api roles;
    @api managers;
	@api jobTitles;
	@api departments;
	@api companies;
	@api vehicleType;
	@api driverTypes;
	minDate = '';
    maxDate = '';
	managersList;
	roleList;
	jobTitleList
	departmentList;
	companyList;
	vehicleTypeList;
	driverTypeList;
	@api accid;
	@api frequency;
	@api cellphone;
	@api contactid;
    isFalse = false;
	@api tags = [];
  	newTag = '';
	noMessage = 'There is no user data available'
	isDrivingStateModal = false;
	isDeactivateDateModal = false;
	isMileageLockDateModal = false;
	isMassDeactivationModal = false;
	isSyncAllModal = false;
	massDeactivationDate  = '';
	validStateList = [];
	currentModalRecord;
	@api deactivaedDate;
	@api payRollAmount;
	@api isSubmitVisible = false;
	@api currentActivity = "Activity";
	lockDateList = [];
	@api reiMonth;
	@api lockDate = '';
	@api syncMonth;
	@api syncStartDate;
	@api syncEndDate;
	currentRecord;
	isFieldDataLoaded = false;
	noneEditableField = [];
	@api addEmpFormField = [];
	@api redirectUserId;
	@api fieldType = {};
	@api isFieldTypeLoaded = false;
	@api employeeFilterOption = ["Active", "Disabled", "All"];
	currentFilter = "Active";
	@api editRecordIdList = [];
	@api exportFields = [];
	isLoginAsVisible = false;
	redirectPageName;
	isClearIconEnable = true;
	tempAllData;
	isSelectedTermDate = false;
	dateFormat = 'mm/dd/yyyy';
	perSTime;
	perETime;

    dynamicBinding(data, keyFields) {
		console.log('At Dyn_binding : ' + JSON.stringify(data));
        data.forEach(element => {
            let model = [];
            for (const key in element) {
                if (Object.prototype.hasOwnProperty.call(element, key)) {
                    let singleValue = {}
                    if (keyFields.includes(key) !== false) {
                        singleValue.key = key;
						singleValue.value = this.getValue(key, element);
						singleValue.isIcon = key === "deactivaedDate" ? true : false;
						singleValue.isDate = (this.fieldType && this.fieldType?.date?.includes(key)) ? true : false;
                        singleValue.isDropDown = (this.fieldType && this.fieldType?.select?.includes(key) && !this.noneEditableField?.includes(key)) ? true : false; //select
						singleValue.isTag = key === "drivingStates" ? true : false;
						singleValue.isAddress = key === "zipCode" ? true : false;
						singleValue.city = key === "zipCode" ? element['city'] : '';
						singleValue.isNoneEditable = (this.noneEditableField && this.noneEditableField.includes(key)) ?  true : false;
						singleValue.toggle = false;
						// singleValue.isToggle =
						// Drop down keys
						if(this.fieldType?.select?.includes(key)){
							singleValue.dropDownList = this.getDropDown(key);
						}

						// icon keys
						if(key === "deactivaedDate") {
							singleValue.iconUrl = this.editIconUrl;
						} else if(key === "drivingStates") {
							singleValue.iconUrl = this.addIconUrl;
						} else {
							singleValue.iconUrl = '';
						}

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
			element.toggle = false;
			element.isChecked = element.isChecked === true;
			element.isEdited = false;
			//element.checkbox = true;
			element.checkbox = (this.currentActivity === 'Send Driver Packet') ? (element.packet === '' || element.packet === 'Sent To Driver') ? true : false : true;
            element.keyFields = this.mapOrder(model, keyFields, 'key');
        });
		this.employeeList = data;
    }

	getValue(key, element) {
		if(key === "drivingStates") {
			if(element[key]) {
				return element[key];
			}else {
			  	return [];
			}
		  } else if(this.fieldType?.date?.includes(key)) {
			return element[key] ? this.convertDateFormat(element[key]) : '';
		  } else {
			return element[key];
		  }
	}

	getDropDown(key) {
		if(key === "role") {
			return this.roleList;
		} else if(key === "managerName") {
			return this.managersList;
		} else if(key === "jobtitle"){
			return this.jobTitleList;
		} else if(key === "department") {
			return this.departmentList
		} else if(key === "company") {
			return this.companyList;
		} else if(key === "vehicalType") {
			return this.vehicleTypeList;
		} else if(key === "driverType") {
			return this.driverTypeList;
		}
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

    connectedCallback() {
		this.perSTime = new Date().getTime();
		console.log('perSTime : ' + this.perSTime);
		var date = new Date();
        const numWeeks = 2;
        const now = new Date();
        now.setDate(now.getDate() + numWeeks * 7);
        this.accid = this.getUrLParam('accid');
        this.contactid = this.getUrLParam('id');
		// this.activityList = this.formatArray(this.activities);
		this.employeeFilterOption = this.formatArray(this.employeeFilterOption);
		this.getDrivingStatesList();
		this.getFieldType();
		this.noneEditableField = empNoneEditableField ? empNoneEditableField.split(',') : [];
		this.minDate = new Date(date.getFullYear(), date.getMonth() - 1, 1);
        this.maxDate = now;
	}

	initailizeTable() {

		this.activityList = this.formatArray(this.activities);
		if(this.managers && this.roles) {
			this.managersList = this.proxyToObject(this.managers);
			this.roleList = this.proxyToObject(this.roles)
		}
		if(this.jobTitles) {
			this.jobTitleList = this.proxyToObject(this.jobTitles);
		}
		if(this.departments) {
			this.departmentList = this.proxyToObject(this.departments);
		}
		if(this.companies){
			this.companyList = this.proxyToObject(this.companies);
		}
		if(this.vehicleType){
			this.vehicleTypeList = this.proxyToObject(this.vehicleType);
		}
		if(this.driverTypes){
			this.driverTypeList = this.proxyToObject(this.driverTypes);
		}
		if(this.employees && this.employees.length){

			this.employeeList = this.proxyToObject(this.employees.filter(emp => !emp.deactivaedDate));
			this.tempAllData = this.employeeList;
			this.dynamicBinding(this.employeeList, this.empKeyFields);
            this.isdataLoaded = true;
            this.editableView = true;
			this.paginated = true;
			this.isScrollable = true;
			this.isCheckbox = true;
			if(this.redirectUserId) {
				let event = {
					detail : this.redirectUserId
				}
				this.editEmployee(event);
			}
			console.log("End InitializeTable");
		} else {
			this.getEmployees();
		}
	}

    proxyToObject(data) {
        return JSON.parse(JSON.stringify(data));
    }

	getUrLParam(param) {
		let url = new URL(location.href);
		return url.searchParams.get(param);
	}

	editMode(event){
        this.isEditMode = true;
		let id = event.detail;
		if(id && !this.editRecordIdList.includes(id)){
			this.editRecordIdList.push(id);
		}
    }

	cancelEditMode(){
        this.isEditMode = false;
        if(this.template.querySelector('.filter-input')){
            this.template.querySelector('.filter-input').value = "";
        }
		this.editRecordIdList = [];
		this.startSpinner();
		this.getEmployees();
        // this.template.querySelector('c-user-preview-table').refreshTable(this.employeeList);
    }

	handleUpdateList(event){
		console.log("Before checkbox : " + JSON.stringify(this.employeeList));
		let arrayToUpdate = JSON.parse(event.detail);
		arrayToUpdate.forEach(updateRecord => {
			let index = this.employeeList.findIndex(record => record.id === updateRecord.id);
			if (index !== -1) {
				this.employeeList[index] = updateRecord;
			}
		});
		console.log("Aftee checkbox : " + JSON.stringify(this.employeeList));
		// this.employeeList = JSON.parse(event.detail);
    }

	async updateEmployee() {
		// if(this.edit)
		if(!this.editRecordIdList.length){
			this.startSpinner();
			editInlineNewEmployee({
				listofemployee: JSON.stringify(this.employeeList),
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
					this.tempAllData = this.employeeList;
					this.dynamicBinding(this.employeeList, this.empKeyFields);
					this.template.querySelector('c-user-preview-table').refreshTable(this.employeeList);
					this.isEditMode = false;
					this.stopSpinner();
					let updateEmpMessage = `Records updated`;
					let toastSuccess = { type: "success", message: updateEmpMessage };
					toastEvents(this, toastSuccess);
				}
				// this.getEmployees();
			})
			.catch(err=> {
				console.log(this.proxyToObject(err));
			})
		} else {
			let inValidRecordEmail =  [];
			let inValidRecordZip = [];
			let inValidRecordCity = [];
			let inValidrecordNameEmail = [];
			let inValidrecordNameZip = [];
			let invalidrecordNameCity = [];
			this.editRecordIdList.forEach(id=> {
				let singleRecord = this.getSingleEmployee(id);
				if(singleRecord?.email && !this.isValidEmail(singleRecord?.email)){
					inValidRecordEmail.push(singleRecord);
					inValidrecordNameEmail.push(singleRecord?.name);
				}
				if(singleRecord?.role && (singleRecord?.role !== "Manager" && singleRecord?.role !== "Admin")) {
					if(!singleRecord?.zipCode) {
						inValidRecordZip.push(singleRecord);
						inValidrecordNameZip.push(singleRecord?.name);
					}
					if(!singleRecord?.state) {
						inValidRecordCity.push(singleRecord);
						invalidrecordNameCity.push(singleRecord?.name);
					}
				}
			});
			if(inValidRecordEmail.length){
				let event = {
					detail : {
						type : "error",
						message : `Please add valid email for ${inValidrecordNameEmail.toString()}`
					}
				}
				this.showToast(event)
			} else if(inValidRecordZip.length){
				let event = {
					detail : {
						type : "error",
						message : `Please add valid Zip code for ${inValidrecordNameZip.toString()}`
					}
				}
				this.showToast(event)
			} else if(inValidRecordCity.length) {
				let event = {
					detail : {
						type : "error",
						message : `Please select  city for ${invalidrecordNameCity.toString()}`
					}
				}
				this.showToast(event)
			} else {
				let recordToBeUpdate = [];
				this.editRecordIdList.forEach(id => {
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
						let employees = this.proxyToObject(this.employees)
						for (const updatedRecord of recordToBeUpdate) {
							const index = employees.findIndex((record) => record.userid === updatedRecord.id);
							if (index !== -1) {
								employees[index] = updatedRecord;
							}
						}
						this.employees = employees;
						this.getFilterEmployee(this.currentFilter);
						this.dynamicBinding(this.employeeList, this.empKeyFields);
						this.template.querySelector('c-user-preview-table').refreshTable(this.employeeList);
						this.isEditMode = false;
						this.stopSpinner();
						let updateEmpMessage = `Records updated`;
						let toastSuccess = { type: "success", message: updateEmpMessage };
						this.editRecordIdList = [];
						toastEvents(this, toastSuccess);
					}
					// this.getEmployees();
				})
				.catch(err=> {
					console.log(this.proxyToObject(err));
				})
			}
		}
	}

	isValidEmail(email) {
		if(email) {
			const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  			return emailRegex.test(email);
		}
		return false;
	}

	handleChange(event) {
		let searchKey = event.target.value;
		this.isClearIconEnable = searchKey ? true : false;
        this.template.querySelector('c-user-preview-table').searchByKey(searchKey);
	}
	handleClearInput(){
		let searchKey = "";
		if(this.template.querySelector('.filter-input')){
            this.template.querySelector('.filter-input').value = "";
        }
		this.isClearIconEnable = false;
		console.log('At clear input : ' + JSON.stringify(this.employeeList));
		this.dynamicBinding(this.employeeList, this.empKeyFields);
		console.log('At db : ' + JSON.stringify(this.employeeList));
		this.template.querySelector('c-user-preview-table').refreshTable(this.employeeList);
		this.template.querySelector('c-user-preview-table').toggleCheckBox(true, this.currentActivity);
		this.template.querySelector("c-user-preview-table").searchByKey(searchKey);
	}

	downloadAllEmployee(){
		console.log("this.employeeList : " + JSON.stringify(this.employeeList));
		let employee = [];
		let filename = `Plan Participants ${this.dateTime(new Date())}`;
		let sheetName = "Employee"
		let employeeList = this.sort(this.employeeList, "name");
		let excelLabel = [];
		let excelField = [];
		this.exportFields.forEach(field => {
			excelLabel.push(field.label);
			excelField.push(field.name);
		});
		// let exelLable = this.exportFields.map(f => ({}))
		employee.push(excelLabel);
		employeeList.forEach(emp => {
			let singleRecord = []
			for (const field of excelField) {
				if(field === "drivingStates" && emp[field]?.length) {
					singleRecord.push(emp[field].join(','));
				}else if(field === 'zipCode'){
					if(emp[field] && emp[field].length < 6) {
                		singleRecord.push(emp[field].padStart(5, '0'));
            		} else {
						singleRecord.push(emp[field]);
					}
				}else{
					singleRecord.push(emp[field]);
				}
			};
			employee.push(singleRecord)
		});
		this.template.querySelector("c-export-excel").download(employee, filename, sheetName);
	}

	handleTab(event) {
		let tab = event.currentTarget.dataset.id;
		if(tab === 'employee'){
			this.currentRecord = '';
			if(!this.isListEmployeetab){
				this.cancelEditMode();
			}
			this.isListEmployeetab = true;
			this.isAddEmployeeTab = false;
			this.isImportTab = false;
			this.isLoginAsVisible = false
			this.redirectPageName = '';
		}
		if(tab === 'add') {
			this.isListEmployeetab = false;
			this.isImportTab = false;
			if(this.isAddEmployeeTab) {
				this.isLoginAsVisible = false;
				this.redirectPageName = '';
			}
			this.isAddEmployeeTab = true;
			this.resetAddEmployeeFields();
		}

		if(tab === 'import') {
			this.currentRecord = '';
			this.isListEmployeetab = false;
			this.isAddEmployeeTab = false;
			this.isImportTab = true;
			this.isLoginAsVisible = false;
			this.redirectPageName = '';
		}
		const buttons = this.template.querySelectorAll('.tab-btn');
        buttons.forEach(button => {
            button.classList.remove('is-active');
        });

        // Add the active class to the clicked button
        const clickedButton = event.target;
        clickedButton.classList.add('is-active');
	}

	resetAddEmployeeFields() {
		if(this.template.querySelector('c-add-employee')) {
			this.template.querySelector('c-add-employee').resetFormData();
		}
	}

	handleModal(event) {
    	this.template.querySelector('c-user-profile-modal').show();
		if(event && event.detail ) {
			let key = event.detail.key;
			let id = event.detail.id;
			this.currentModalRecord = id;
			let singleEmp = this.getSingleEmployee(id);
			if(key === "drivingStates") {
				this.isDrivingStateModal = true;
				this.tags = (singleEmp && singleEmp.drivingStates) ? singleEmp.drivingStates : [];
			} else if(key === "deactivaedDate") {
				this.deactivaedDate = (singleEmp && singleEmp?.deactivaedDate) ? singleEmp?.deactivaedDate : '';
				this.isDeactivateDateModal = true;
				if(this.deactivaedDate != '') {
					this.isSelectedTermDate = true;
				} else {
					this.isSelectedTermDate = false;
				}
			}
		}
	}

	handleCloseModal(){
		this.tags = [];
		this.deactivaedDate = '';
		this.payRollAmount = '';
		this.massDeactivationDate = ''
		this.reiMonth = '';
		this.lockDate = '';
		this.syncMonth = '';
		this.syncStartDate = '';
		this.syncEndDate = '';
		this.template.querySelector('c-user-profile-modal').hide();
		this.disableCheckbox();
		this.isSubmitVisible = false;
		this.isDeactivateDateModal = false;
		this.isDrivingStateModal = false;
		this.isMileageLockDateModal = false;
		this.isMassDeactivationModal = false;
		this.isSyncAllModal = false;
	}

	handleCancel() {
		this.showModal = false;
	}

	handleTagInput(event) {
		if (event.key === 'Enter' || event.type === 'blur') {
			const value = event.target.value.trim();
		  let validState = this.validStateList ? this.validStateList.split(',') : [];
		  if (value &&  this.validStateList && validState.includes(value) && !this.tags.includes(value)) {
				this.tags.push(value);
				let empIndex = this.employeeList.findIndex(emp => emp.userid === this.currentModalRecord )
				this.employeeList[empIndex].drivingStates = this.tags;
				this.template.querySelector('c-tag-state-list').updatetags(this.tags);
				this.updateEmp(this.currentModalRecord);
				this.newTag = '';
		  }
		}
	  }

	handleRemoveTag(event) {
		const tagToRemove = this.proxyToObject(event.detail);
		if(tagToRemove && tagToRemove.hasOwnProperty('record')) {
			let recordId = {
				detail : tagToRemove.record
			}
			this.editMode(recordId);
			let recordIndex = this.employeeList.findIndex((emp => emp.userid == tagToRemove.record));
			let stateList = this.employeeList[recordIndex].drivingStates;
			if(stateList && stateList.length && stateList.includes(tagToRemove.tag)) {
					stateList = stateList.filter(state => state !== tagToRemove.tag);
			}
			this.tags = stateList;
			this.employeeList[recordIndex].drivingStates = stateList;
			// this.template.querySelector('c-tag-state-list').updatetags(this.tags);
			this.updateEmp();
		} else {
			let recordIndex = this.employeeList.findIndex((emp => emp.userid == this.currentModalRecord));
			let stateList = this.employeeList[recordIndex].drivingStates;
			if(stateList && stateList.length && stateList.includes(tagToRemove)) {
					stateList = stateList.filter(state => state !== tagToRemove);
			}
			this.tags = stateList;
			this.employeeList[recordIndex].drivingStates = stateList;
			this.template.querySelector('c-tag-state-list').updatetags(this.tags);
			this.updateEmp();
		}
	}


	getEmployees() {
		getlistAllEmployees({accid: this.accid, contactid: this.contactid})
        .then(response => {
			this.employees = JSON.parse(response);
			if(this.currentFilter) {
				this.getFilterEmployee(this.currentFilter);
			} else {
				this.employeeList = this.employees
			}
			
            this.dynamicBinding(this.employeeList, this.empKeyFields);
			console.log("SINGLE_EMP",this.proxyToObject(this.employeeList));
			this.isdataLoaded = true;
            this.editableView = true;
			this.paginated = true;
			this.isScrollable = true;
			this.isCheckbox = true;
			this.template.querySelector('c-user-preview-table').refreshTable(this.employeeList);
			// this.cancelEditMode();
			this.dispatchEvent(new CustomEvent('updateemployee', {}));
			this.stopSpinner();
        })
        .catch(err => {
            console.log(this.proxyToObject(err));
        });
	}

	getSingleEmployee(id) {
		let employelist = this.proxyToObject(this.employeeList);
		return employelist.find(employee => (employee.userid === id));
	}

	updateEmp() {
		this.dynamicBinding(this.employeeList, this.empKeyFields);
		this.template.querySelector('c-user-preview-table').refreshTable(this.employeeList);
	}

	AddEmployee(event) {
		this.template.querySelector(".tab-wrapper .employee").click();
		let updateEmpMessage = event?.detail?.updateEmpMessage;
		let result = event?.detail?.result;
		this.getEmployees();
		let toastSuccess = { type: "success", message: updateEmpMessage };
		toastEvents(this, toastSuccess);
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

	showToast(event) {
		this.dispatchEvent(
		  new CustomEvent("toast", {
			detail: event.detail
		  })
		);
	  }

	  showErrorToast(event){
		this.dispatchEvent(
			new CustomEvent("error", {
				detail: event.detail
			})
		);
	  }


	dateTime(date) {
		var yd, ydd, ymm, yy, hh, min, sec;
		yd = date;
		ydd = yd.getDate();
		ymm = yd.getMonth() + 1;
		yy = yd.getFullYear();
		hh = yd.getHours();
		min = yd.getMinutes();
		sec = yd.getSeconds();
		ydd = ydd < 10 ? "0" + ydd : ydd;
		ymm = ymm < 10 ? "0" + ymm : ymm;
		return (
		  ymm.toString() +
		  ydd.toString() +
		  yy.toString() +
		  hh.toString() +
		  min.toString() +
		  sec.toString()
		);
	  }

	  sort(employees, colName) {
		employees.sort((a, b) => {
		  let fa =
			  a[colName] == null || a[colName] === ""
				? ""
				: a[colName].toLowerCase(),
			fb =
			  b[colName] == null || b[colName] === ""
				? ""
				: b[colName].toLowerCase();

		  if (fa < fb) {
			return -1;
		  }
		  if (fa > fb) {
			return 1;
		  }
		  return 0;
		});

		return employees;
	  }


	showTooltip(){
		let popOver = this.template.querySelector('.state-popover');
		if(popOver.style) {
			popOver.style.visibility = "visible";
		}
	}

	hideTooltip() {
		let popOver = this.template.querySelector('.state-popover');
		if(popOver.style) {
			popOver.style.visibility = "hidden";
		}
	}

	getDrivingStatesList() {
		getDrivingStates()
		.then(response => {
			let stateList = JSON.parse(response);
			if(stateList && stateList.length){
				this.validStateList = stateList.toString();
			}
			console.log("End DrivingState");
		})
		.catch(err => {
			console.log(err)
		});
		this.generateLockDateMonthList()
	}

	generateLockDateMonthList() {
		var currentDate, lastTwoMonths, month, year
		currentDate = new Date();
		lastTwoMonths = [];

		for (let i = 0; i < 2; i++) {
			month = currentDate.getMonth() - i;
			year = currentDate.getFullYear();

			if (month < 0) {
				month += 12;
				year -= 1;
			}

			lastTwoMonths.push(`${("0" + (month + 1)).slice(-2)}-${year}`);
		}

		lastTwoMonths.reverse();
		this.lockDateList = this.formatArray(lastTwoMonths);
	}

	formatArray(data) {
		if(data && data.length){
		return 	data.map(key => ({
				id: key,
				label: key,
				value: key
			}));
		}
		return data;
	}

	handledate(event) {
		console.log("deactivaedDate : " + event.detail);
		this.deactivaedDate = event.detail;
	}

	updateDeactivationDate() {
		let id = this.currentModalRecord;
		let recordIndex = this.employeeList.findIndex(emp => emp.userid === id);
		this.employeeList[recordIndex].deactivaedDate = this.deactivaedDate;
		this.employeeList[recordIndex].deactivateUser = (this.deactivaedDate) ? true : false;
		this.updateEmp(id);
		this.handleCloseModal();
	}

	handleKeyDown(event) {
		// Allow only digit-related keys, arrow keys, delete, and backspace
		if (
		  !(
			/[0-9]/.test(event.key) ||
			['ArrowLeft', 'ArrowRight', 'Delete', 'Backspace'].includes(event.key)
		  )
		) {
		  event.preventDefault();
		}
	}

	handleInput(event) {
		// Remove any non-digit characters from the input value
		const inputValue = event.target.value.replace(/\D/g, '');
		event.target.value = inputValue;
	}

	handleActivity(event) {
		if(event && event.detail && event.detail.value) {
			this.currentActivity = event.detail.value;
			let activityList = this.activityList;
			const filteredArray = activityList.filter(obj => obj.id !== "Activity");
			this.activityList = filteredArray;
		}
		//isMassDeactivationModal
		//if(this.currentActivity === "Send Driver Packet") {
			//this.sendPacket(this.accid);
		//} else {
			if(this.currentActivity === "Mileage Lock Date"){
				this.isMileageLockDateModal = true;
				this.template.querySelector('c-user-profile-modal').show();
			}else if(this.currentActivity === "Sync All"){
				this.isSyncAllModal = true;
				this.template.querySelector('c-user-profile-modal').show();
			} else {
				this.template.querySelector('c-user-preview-table').toggleCheckBox(true, this.currentActivity);
				if(event && event.detail && event.detail.value) {
					this.currentActivity = event.detail.value;
				}
			}
		//}

		// else if(this.currentActivity === "Resend mLog App" ) {
		// 	this.sendWelcomeEmail(this.accid);
		//}
	}

	disableCheckbox(event) {
		this.isSubmitVisible = false;
		this.isDeactivateDateModal = false
		this.template.querySelector('c-user-preview-table').toggleCheckBox(false);
	}

	enableSubmit() {
		if(this.isSubmitVisible) {
			return
		}
		this.isSubmitVisible = true;
	}

	submitActivity(event) {
		let employeeList = this.getSelectedRecords();
		if(this.currentActivity === "Mass Deactivate") {
			this.isMassDeactivationModal = true;
			this.template.querySelector('c-user-profile-modal').show();
		} else {
			this.template.querySelector('c-activity-actions').handleActivity(this.currentActivity, employeeList, this.accid, this.contactid);
		}
	}

	getSelectedRecords() {
		let selectedEmployee = this.employeeList;
		selectedEmployee = selectedEmployee.filter(employee => employee.isChecked === true);
		return selectedEmployee;
	}

	// sendWelcomeEmail(accId) {
	// 	this.startSpinner()
	// 	let empEmailList = this.employeeList.map(item => item.email);
	// 	putHTTPMassWlcmMail({accountID: accId, empEmail : JSON.stringify(empEmailList) })
	// 	.then(responce => {
	// 		console.log(this.proxyToObject(responce));
	// 		this.stopSpinner();
	// 	})
	// 	.catch(err => {
	// 		console.log(this.proxyToObject(err));
	// 		this.stopSpinner();
	// 	})
	// }

	handleLockMonth(event) {
		if(event && event.detail) {
			this.reiMonth = event.detail.value;
		}
	}

	handleMileageLockDate(event) {
		if(event && event.detail) {
			this.lockDate = event.detail;
		}
	}

	handleLockDate(event) {
		this.startSpinner()
		updateLockDate({accountId: this.accid, lockDate: this.lockDate, reiMonth: this.reiMonth})
		.then(responce => {
			this.stopSpinner();
			if(this.proxyToObject(responce) == "Success") {
				this.handleCloseModal();
				let toastSuccess = { type: "success", message: "Mileage has been locked." };
                    toastEvents(this, toastSuccess);
			} else {
				let toastError = { type: "error", message: "Something went wrong." };
            	toastEvents(this, toastError);
			}

		})
		.catch(err => {
			console.log(this.proxyToObject(err));
			this.stopSpinner();
		})
	}

	editEmployee(event) {
		let record = this.getSingleEmployee(event?.detail);
		if(record) {
			let role = record?.role;
			getCustomRedirectURLSettings()
			.then(response => {
				let redirectSettings = this.proxyToObject(response);
				let roles = redirectSettings[0]?.roles__c.split(',');
				let roleFieldName = `${role.replace(/\//g, '_')}__c`;
				this.redirectPageName = redirectSettings[0][`${roleFieldName}`];
				if(roles.includes(role) && this.redirectPageName){
					this.isLoginAsVisible = true;
				}
				console.log("End editEmployee");
			})
			.catch(err => {
				console.log(this.proxyToObject(err))
			})
		}
		this.currentRecord = record;
		let intervalID = setInterval(()=> {
			if(this.template.querySelector('.tab-wrapper .add-employee')) {
				this.template.querySelector('.tab-wrapper .add-employee').click();
				clearInterval(intervalID);
			}
		},500);
	}

	handleMassDeactivationDate(event) {
		console.log('massDeactivationDate : ' + event.detail);
		this.massDeactivationDate = event?.detail;
	}

	handleMassDeactivation() {
		if(!this.massDeactivationDate) {
			let message = "please select mass deactivation date";
			let evtobj = {type : "error", message : message}
			toastEvents(this, evtobj)
		} else {
			this.startSpinner();
			let employeeList = this.getSelectedRecords();
			employeeList = employeeList.map(emp => ({
				...emp,
				IsMassDeactivated: true,
				deactivateUser: true,
				deactivaedDate: this.massDeactivationDate
			}));
			editInlineNewEmployee({listofemployee: JSON.stringify(employeeList), accid: this.accid, contactid: this.contactid})
            .then(response => {
                let result = JSON.parse(response);
                // this.displayToast(result, `Records updated`);
                if(result?.hasError) {
                    this.stopSpinner();
                    console.error(result.message);
                    let toastError = { type: "error", message: "Something went wrong." };
                    toastEvents(this, toastError);
                }
                if(!result?.hasError) {
                    // this.stopSpinner();
                    let updateEmpMessage = `Records updated`;
                    let toastSuccess = { type: "success", message: updateEmpMessage };
                    toastEvents(this, toastSuccess);
					this.isSubmitVisible = false;
					this.template.querySelector('c-user-preview-table').toggleCheckBox(false);
					this.handleCloseModal();
					this.getEmployees();
                }
            })
            .catch(err => {
                this.stopSpinner()
                console.log(this.proxyToObject(err))
            });
		}

	}

	convertDateFormat(dateString) {
		let dateParts = dateString.split('/');
		let month = dateParts[0].padStart(2, '0'); // Add leading zero if necessary
  		let day = dateParts[1].padStart(2, '0');
		let year = dateParts[2];

		let formattedDate = year + '-' + month + '-' + day;
		return formattedDate;
	}

	handleTableField(event) {
		console.log("Start tableFiled");
		let fieldData = this.proxyToObject(event.detail);
		this.employeeColumn = fieldData?.column;
		this.empKeyFields = fieldData?.key;
		this.activities = fieldData?.activities;
		this.exportFields = fieldData?.export;
		this.isFieldDataLoaded = true;
		this.initailizeTable();
	}

	handleFormField(event) {
		let addEmpFormData = this.proxyToObject(event.detail);
		this.addEmpFormField = addEmpFormData?.column;
		this.perETime = new Date().getTime();
		console.log('perETime : ' + this.perETime);
	}

	handleSyncAllMonth(event) {
		if(event && event.detail) {
			this.syncMonth = event.detail.value;
			let dates = this.getStartAndEndDate(this.syncMonth);
			this.syncStartDate = dates?.startDate;
			this.syncEndDate = dates?.endDate;
		}
	}

	handleUnSubscribe(){
		if(this.syncStartDate && this.syncEndDate && this.syncMonth) {
			this.startSpinner();
			MassSyncTrips({
				accountId: this.accid,
				startDate: this.syncStartDate,
				endDate: this.syncEndDate,
				month : this.syncMonth,
				tripStatus: "U"
			})
			.then(responce => {
				this.handleSubscribe();
			})
			.catch(err=> {
				this.stopSpinner()
				console.log(this.proxyToObject(err));
			})
		} else {
			let toastError = { type: "error", message: "something went wrong..!" };
            toastEvents(this, toastError);
		}
	}

	handleSubscribe() {
		MassSyncTrips({
			accountId: this.accid,
			startDate: this.syncStartDate,
			endDate: this.syncEndDate,
			month : this.syncMonth,
			tripStatus: "S"
		})
		.then(responce => {
			console.log("responce --> handleSubscribe",this.proxyToObject(responce));
			let toastSuccess = { type: "success", message: "Sync All successfull" };
            toastEvents(this, toastSuccess);
			this.handleCloseModal();
			this.getEmployees();
		})
		.catch(err=> {
			console.log(this.proxyToObject(err));
		})
	}

	getStartAndEndDate(dateString) {
		const [month, year] = dateString.split('-');
		const startDate = new Date(year, month - 1, 1);
		const endDate = new Date(year, month, 0);

		const formattedStartDate = `${(startDate.getMonth() + 1).toString().padStart(2, '0')}/${startDate.getDate().toString().padStart(2, '0')}/${startDate.getFullYear()}`;
		const formattedEndDate = `${(endDate.getMonth() + 1).toString().padStart(2, '0')}/${endDate.getDate().toString().padStart(2, '0')}/${endDate.getFullYear()}`;

		return { startDate: formattedStartDate, endDate: formattedEndDate };
	}

	resetRedirectUser(){
		this.redirectUserId = '';
	}

	getFieldType() {
		getCustomAddEmployeeSettings()
		.then(responce => {
			let result = this.proxyToObject(responce);
            if(result?.length) {
                result.forEach(res => {
                    if(res?.Name === "addEmployee") {
						this.fieldType = {
							text : res?.text__c ? res?.text__c.split(',') : [],
							select : res?.select__c ? res?.select__c.split(',') : [],
							date : res?.date__c ? res?.date__c.split(',') : [],
							required : res?.required__c ? res?.required__c.split(',') : [],
						}
                    }
                });
				this.isFieldTypeLoaded = true;
				console.log("End FieldType");
            }
		})
		.catch(err => {
			console.log(this.proxyToObject(err));
		})
	}

	handleBack(){
		this.template.querySelector(".tab-wrapper .employee").click();
		this.cancelEditMode();
	}

	disconnectedCallback(){
		this.isFieldTypeLoaded = false;
	}

	handleEmployeeFilter(event) {
		let filter = event?.detail?.value;
		if(filter){
			this.currentFilter = filter;
			this.getFilterEmployee(this.currentFilter);
			this.dynamicBinding(this.employeeList, this.empKeyFields);
			this.template.querySelector('c-user-preview-table').tableListRefresh(this.employeeList);
		}
	}


	getFilterEmployee(filter){
		// if(this.currentActivity === "Send Driver Packet") {
		// 	if(filter === "Active") {
		// 		this.employeeList =  this.proxyToObject(this.drivers.filter(emp => !emp.deactivaedDate));
		// 	}else if(filter === "Disabled") {
		// 		this.employeeList = this.proxyToObject(this.drivers.filter(emp => emp.deactivaedDate));
		// 	} else if(filter === "All") {
		// 		this.employeeList = this.proxyToObject(this.drivers);
		// 	}
		// }else{
			if(filter === "Active") {
				this.employeeList =  this.proxyToObject(this.employees.filter(emp => !emp.deactivaedDate));
			}else if(filter === "Disabled") {
				this.employeeList = this.proxyToObject(this.employees.filter(emp => emp.deactivaedDate));
			} else if(filter === "All") {
				this.employeeList = this.proxyToObject(this.employees);
			}
		//}

	}

	handleLoginAs() {
		let url = new URL(location.href);
		let newUrlSearch = this.updateIdOfLoginUser(url.search);
		let targetUrl = `${this.redirectPageName}${newUrlSearch}`;
		window.open(targetUrl, '_blank');
	}

	updateIdOfLoginUser(inputString) {
		// Input string
		// var inputString = "?accid=0010Z00001ygUenQAE&id=0030Z00003NFLRoQAP&showteam=true";

		// New value for the 'id' parameter
		var newIdValue = this.currentRecord?.id;

		// Split the input string by '&' to separate the parameters
		var params = inputString.split("&");

		// Iterate through the parameters to find and replace the 'id' parameter
		for (var i = 0; i < params.length; i++) {
		var param = params[i].split("=");
		if (param[0] === "id") {
			param[1] = newIdValue; // Replace the value with the new value
			params[i] = param.join("=");
			break; // No need to continue iterating once 'id' is found and replaced
		}
		}

		// Join the parameters back together with '&' and create the updated string
		return params.join("&");
	}

	handleBackToDashboard() {
		this.dispatchEvent(new CustomEvent('backtodashboard', {}));
	}
}