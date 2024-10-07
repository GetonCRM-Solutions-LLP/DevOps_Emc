import { LightningElement, api, track } from 'lwc';
import resetPassword from '@salesforce/apex/RosterController.resetPassword';
import putHTTP from '@salesforce/apex/RosterController.putHTTP';
import getCountryStateCity from '@salesforce/apex/RosterController.getCountryStateCity';
import getDrivingStates from '@salesforce/apex/RosterController.getDrivingStates';
import manageEmployee from '@salesforce/apex/RosterController.manageEmployee';
import getJobTitle from '@salesforce/apex/RosterController.getJobTitle';
import getCompany from '@salesforce/apex/RosterController.getCompany';
import getDepartment from '@salesforce/apex/RosterController.getDepartment';
import getPickListValuesIntoList from '@salesforce/apex/RosterController.getPickListValuesIntoList';
import getDriverType from '@salesforce/apex/RosterController.getDriverType';
import getAllManagers from '@salesforce/apex/RosterController.getAllManagers';
import getRoles from '@salesforce/apex/RosterController.getRoles';
import putHTTPConcurConnect from '@salesforce/apex/RosterController.putHTTPConcurConnect';
import concurConnectEmail from '@salesforce/label/c.concurConnectEmail';
import {
    toastEvents, modalEvents
} from 'c/utils';


export default class AddEmployee extends LightningElement {
	
    @track employeeFields = [];
	@api formField;
    @api managersList;
    @api roleList;
	@api contactid;
	@api accid;
	@api cityList;
	@api record;
	@api isAddEmployeModal = false;
	@api tags = [];
	@api managerId;
	validStateList = [];
	@api ListOfCity = [];
	@api listOfVehicles = [];
	newTag = '';
    @api requiredFields = {
        driver : ['firstName', 'activationDate', 'lastName', 'email', 'role', 'managerName', 'cellphone', 'department', 'deptDesign', 'company', 'vehicalType', 'zipCode', 'city', 'jobtitle', 'costCode', 'bpCode','am', 'an','ReimbursementFrequency','CellPhoneProvider'],
        manager: ['firstName', 'activationDate', 'lastName', 'email', 'role', 'managerName', 'department', 'deptDesign', 'company','ReimbursementFrequency','CellPhoneProvider'],
        admin: ['firstName', 'activationDate', 'lastName', 'email', 'role', 'department', 'deptDesign', 'company','ReimbursementFrequency','CellPhoneProvider']
    }
	isUpdateMode = false;
	isSelectedDate = false;
	dateFormat = 'mm/dd/yyyy';
	isRecordFirstTimeLoading;

    connectedCallback() {
        if(this.formField?.length) {
			this.formField = this.formField.map(field => ({
				...field,
				value: field.fieldName === "addedDate" ? this.getTodayDate() : field.value,
				displayValue: field.fieldName === "addedDate" ? this.convertDateFormat(this.getTodayDate()) : field.displayValue
			}));
			this.employeeFields = this.proxyToObj(this.formField);
		}
		if(!this.record) {
			this.employeeFields = this.employeeFields.filter(emp => emp.fieldName !== "appVersion");
		}
		this.getListOfDropDownData();
		this.editRecord();
    }

	@api
	resetFormData(){
		if(this.formField?.length) {
			this.formField = this.formField.map(field => ({
				...field,
				value: field.fieldName === "addedDate" ? this.getTodayDate() : field.value,
				displayValue: field.fieldName === "addedDate" ? this.convertDateFormat(this.getTodayDate()) : field.displayValue
			}));
			this.employeeFields = this.proxyToObj(this.formField);
			this.record = undefined;
			this.employeeFields = this.employeeFields.filter(emp => emp.fieldName !== "appVersion");
		}
		this.getListOfDropDownData();
	}
    
    proxyToObj(data) {
        return data ? JSON.parse(JSON.stringify(data)) : '';
    }

    manageFields() {
        this.employeeFields = this.employeeFields.map((field) => ({
            ...field,
            isDateField: field.type === "date",
            isDropDown: field.type === "select",
			isDrivingState: field.fieldName === "drivingStates" ? true : false,
			isDisable: (field.fieldName === "addedDate" || field.fieldName === "state"),
			displayValue : field.fieldName === "addedDate" ? this.convertDateFormat(this.getTodayDate()) : '',
            dropDownList: "",
            errorClass: this.isNotInput(field.type) ? field.fieldName !== "state" ?  'content-input' : 'content-input disabled-input' : '',
			cmpClass : this.getCmpClass(field),
			isValid: false,
			isDependentDropDown: false
        }));
    }

	getCmpClass(field, isValidate) {
		if(!isValidate) {
			if(field.type === "select") {
				return "default-box-input slds-truncate";
			} else if(field.type === "date") {
				if(field.fieldName === "addedDate") {
					return "flat-container disabled-input";
				}else {
					return "flat-container "
				}
			} else {
				return "";
			}
		} else if(isValidate) {
			let isValid = this.validateField(field);
			if(isValid) {
				if(field.type === "select") {
					return "default-box-input slds-truncate box-input-success";
				} else if(field.type === "date") {
					if(field.fieldName === "addedDate") {
						return "flat-container disabled-input box-input-success";
					}else {
						return "flat-container box-input-success"
					}
				} else {
					return "";
				}
			} else {
				if(field.type === "select") {
					return "default-box-input slds-truncate box-input-error ";
				} else if(field.type === "date") {
					if(field.fieldName === "addedDate") {
						return "flat-container disabled-input box-input-error";
					}else {
						return "flat-container box-input-error"
					}
				} else {
					return "";
				}
			}
			
		}
	}

	isNotInput(type) {
		return (type !== "date" && type !== "select" && type !== "component" ) ? true : false
	}

    getTodayDate() {
        const currentDate = new Date();
        const month = (currentDate.getMonth() + 1).toString().padStart(2, '0');
        const day = currentDate.getDate().toString().padStart(2, '0');
        const year = currentDate.getFullYear().toString();
        const formattedDate = `${month}/${day}/${year}`;
        return formattedDate;
    }

    handleInputChange(event) {
        const fieldName = event.target.dataset.fieldname;
        const fieldtype = event.target.dataset.inputType;
        let value;
        if(fieldtype) {
            if(fieldtype === "text") {
                value = event.target.value;
            } else  if( fieldtype === "select") {
                value = event.detail.value;
            } else if( fieldtype === "date") {
                value = event.detail;
            }
        }

        this.employeeFields = this.employeeFields.map((field) => {
			if (field.fieldName === fieldName) {
				if(fieldName === "cellphone") {
					return { ...field, value : this.autoPopulatePhone(value)  }
				}
				if(field.type === "date") {
					console.log("Values", this.convertDateFormat(value))
					return { ...field, value : value, displayValue : this.convertDateFormat(value)  }
				}
				if(fieldName === "costCode") {
					if(field.is7DigitCostCode)
						return { ...field, value : this.autoCostCode7Digit(value)  }
					else
						return { ...field, value : this.autoCostCode(value)  }
				}
				if(fieldName === "am" || fieldName === "an") {
					return { ...field, value : this.isAlphabestOnly(value)  }
				}
				if(fieldName === "zipCode") {
					return { ...field, value : this.isZipCode(value)  }
				}
				if(fieldName === "monthlymileage") {
					return { ...field, value : this.monthlymileage(value)  }
				}
				if(fieldName === "vehicalType") {
					return { ...field, value : this.isVehicalType(value)  }
				}
				
				return { ...field, value };
			}
			return field;
        });
		if(fieldName === "role") {
			this.updateRequiredField(value);
			this.updateVehicleTypeList(value);
		}
		if(fieldName === "city") {
			let id = event.detail.key;
			this.handleCityChange(id)
		}
		if( fieldName === 'managerName'){
			let id = event.detail.key;
			this.managerId = id;
		}
      }

	  handleFocusOut(event) {
		const fieldName = event.target.dataset.fieldname;
		let value = event.target.value
		if(fieldName === "zipCode") {
			this.getCityList(value);
		}
	  }

	  handleCityChange(id) {
		let city = this.ListOfCity.filter(city => city.Id === id);
		if(city.length) {
			this.employeeFields = this.employeeFields.map(emp => ({
				...emp,
				value : (emp.fieldName === 'state' && city[0]?.Abbreviation__c) ? city[0]?.Abbreviation__c : emp.value,
			}));
			this.updateNearestDrivingState(city[0]?.Abbreviation__c);
			this.setErrorMessage("zipCode", "");
		}
	  }

	  isVehicalType(inputString) {
		if(inputString == "---") {
			return "";
		} else {
			return inputString;
		}
	  }


	  isAlphabestOnly(inputString) {
		return inputString.replace(/[^a-zA-Z]/g, '');
	  }

	  isDigitOnly(inputString) {
		return inputString.replace(/\D/g, '');
	}

	  isZipCode(inputString) {
		const maxLength = 6;
    	let stringWithOnlyAlphaNumeric = inputString.replace(/[^a-zA-Z0-9]/g, '');
    	return stringWithOnlyAlphaNumeric.slice(0, maxLength);
	  }

	  monthlymileage(inputString) {
		inputString = inputString.replace(/[^\d.]/g, '');

        // Allow only four digits at the beginning
        inputString = inputString.replace(/^(\d{0,4})\d*/, '$1');

        // Allow only two digits after a dot
        inputString = inputString.replace(/^(\d{0,4}\.\d{0,2})\d*/, '$1');
		return inputString;
	  }

	  validateInput(event) {
		const fieldName = event.target.dataset.fieldname;
        // const fieldtype = event.target.dataset.inputType;
		
		if(fieldName === "am" || fieldName === "an") {
			const allowedChars = /[a-zA-Z]/; // Regular expression to allow only alphabets
			if (!allowedChars.test(event.target.value)) {
				event.preventDefault(); // Prevents the non-alphabetic character from being entered
			}
		}
		if(fieldName === "cellphone") {
			// event.target.value = this.autoPopulatePhone(event.target.value);
		}
	  }
	  autoPopulatePhone(phone) {
		if (phone.trim().length > 0 && /^[0-9 \-]+$/.test(phone)) {
			const match = phone.replace(/\D+/g, '').match(/(\d.*){1,10}/)[0];
			const part1 = match.length > 3 ? `${match.substring(0, 3)}` : match;
			const part2 = match.length > 3 ? `-${match.substring(3, 6)}` : '';
			const part3 = match.length > 6 ? `-${match.substring(6, 10)}` : '';
			return `${part1}${part2}${part3}`;
		} else {
			return '';
		}
	}

	autoCostCode(code) {
		if (code.trim().length > 0 && /^[0-9 \-]+$/.test(code)) {
			const match = code.replace(/\D+/g, '').match(/(\d.*){1,9}/)[0];
			const part1 = match.length > 2 ? `${match.substring(0, 2)}` : match;
			const part2 = match.length > 2 ? `-${match.substring(2, 6)}` : '';
			const part3 = match.length > 6 ? `-${match.substring(6, 9)}` : '';
			return `${part1}${part2}${part3}`;
		} else {
			return '';
		}
	}
		
	autoCostCode7Digit(code){
		if (code.trim().length > 0 && /^[0-9 \-]+$/.test(code)) {
			const match = code.replace(/\D+/g, '').match(/(\d.*){1,9}/)[0];
			const part1 = match.length > 5 ? `${match.substring(0, 5)}` : match;
			const part2 = match.length > 5 ? `-${match.substring(5, 7)}` : '';
			return `${part1}${part2}`;
		} else {
			return '';
		}
	}
	
	handleMLog() {
		let toastMessage = ''
		if(this.record && this.isUpdateMode){ 
			resetPassword({contactID : this.record?.userid })
			.then(responce => {
				if(this.proxyToObj(responce) === "Success") {
					toastMessage = { type: "success", message: `Reset link was sent` };
				} else {
					toastMessage = { type: "error", message: "Something went wrong" };
				}
				toastEvents(this, toastMessage);
			})
			.catch(err => {
				console.log(this.proxyToObj(err));
			});
		} else {
			toastMessage = { type: "error", message: "Reset Password will not work while adding employee" };
			toastEvents(this, toastMessage);
		}
	}

	handleMBurse() {
		let emailIndex = this.employeeFields.findIndex(emp => emp.fieldName === "email");
		let email =  this.employeeFields[emailIndex] ? this.employeeFields[emailIndex].value : '';
		let fNameIndex = this.employeeFields.findIndex(emp => emp.fieldName === "firstName");
		let firstName = this.employeeFields[fNameIndex] ? this.employeeFields[fNameIndex].value : '';
		let lNameIndex = this.employeeFields.findIndex(emp => emp.fieldName === "lastName");
		let lastName = this.employeeFields[lNameIndex] ? this.employeeFields[lNameIndex].value : '';
		let toastMessage = ''
		if(this.isValidEmail(email) && firstName && lastName) {
			putHTTP({accountID : this.accid, empEmail : email })
			.then(responce => {
				if(JSON.parse(responce) == "OK") {
					toastMessage = { type: "success", message: `Email has been successfully send to  ${firstName} ${lastName}` };
				} else {
					toastMessage = { type: "error", message: "Something went wrong" };
				}
				toastEvents(this, toastMessage);
			})
			.catch(err => {
				console.log(this.proxyToObj(err));
			});
		} else {
			toastMessage = { type: "error", message: "Please add valid Email , Firstname & LastName." };
			toastEvents(this, toastMessage);
		}
	}

	AddEmployee() {
		let employeeData = this.proxyToObj(this.employeeFields);
		console.log("employeeData",JSON.stringify(employeeData));
		employeeData = employeeData.map(emp => ({
			...emp,
			isValid : this.validateField(emp),
			errorClass : this.getClassName(emp),
			cmpClass : this.getCmpClass(emp, true)
		}));
		this.employeeFields = employeeData;
		if(this.employeeFields.every(emp => emp.isValid)) {
			let employee = {}
			
			this.employeeFields.forEach(emp => {
				if(emp.fieldName == "mileageForDeduction" && !emp.value ){

				}else{
					employee[emp.fieldName] = emp.value;
				}
			});
			if(this.isUpdateMode) {
				employee['userid'] = this.record?.userid;
			}
			if(this.managerId) {
				employee['managerId'] = this.managerId;
			}
			this.startSpinner();
			manageEmployee({addNewEmployee: JSON.stringify([employee]), accid: this.accid, contactid: this.contactid })
			.then(responce => {
				let result = JSON.parse(responce);
				if(result?.hasError) {
					this.stopSpinner();
					console.error(result?.message);
					let toastError = { type: "error", message: result?.message };
					toastEvents(this, toastError);
				} 
				if(!result?.hasError) {
					let mode = this.isUpdateMode ? 'Updated' : 'Added';
					if (this.isUpdateMode == false && concurConnectEmail.includes(this.accid)) {
						putHTTPConcurConnect({
							accountID: this.accid,
							empEmail: employee.email
						})
						.then(result => {
							let convRes = JSON.parse(JSON.stringify(result));
							console.log('convRes : ' + convRes);
							console.log('Type of convRes : ' + typeof(convRes));
							if(convRes == 200) {
								let updateEmpMessage = `Success! You Just ${mode}  ${employee?.firstName}'s Details. Also Concur Connect to mLog connection established.` ;
								if(this.isAddEmployeModal) {
									this.stopSpinner();
									let toastMessage = { type: "success", message: updateEmpMessage };
									toastEvents(this, toastMessage);
								}
								const onAddEmployee = new CustomEvent("addemployee", {
									detail : {
										result : result.result,
										updateEmpMessage : updateEmpMessage,
									}
								});
								this.ListOfCity = [];
								this.managerId = '';
								this.dispatchEvent(onAddEmployee);
							} else {
								let updateEmpMessage = `Success! You Just ${mode}  ${employee?.firstName}'s Details. Unable to established mLog connection.` ;
								if(this.isAddEmployeModal) {
									this.stopSpinner();
									let toastMessage = { type: "success", message: updateEmpMessage };
									toastEvents(this, toastMessage);
								}
								const onAddEmployee = new CustomEvent("addemployee", {
									detail : {
										result : result.result,
										updateEmpMessage : updateEmpMessage,
									}
								});
								this.ListOfCity = [];
								this.managerId = '';
								this.dispatchEvent(onAddEmployee);
							}
						})
						.catch(error => {
							console.log("Error from putHTTPConcurConnect : " + error);
							let updateEmpMessage = `Success! You Just ${mode}  ${employee?.firstName}'s Details. Unable to established mLog connection.` ;
							if(this.isAddEmployeModal) {
								this.stopSpinner();
								let toastMessage = { type: "success", message: updateEmpMessage };
								toastEvents(this, toastMessage);
							}
							const onAddEmployee = new CustomEvent("addemployee", {
								detail : {
									result : result.result,
									updateEmpMessage : updateEmpMessage,
								}
							});
							this.ListOfCity = [];
							this.managerId = '';
							this.dispatchEvent(onAddEmployee);
						});
					} else {
						let updateEmpMessage = `Success! You Just ${mode}  ${employee?.firstName}'s Details.` ;
						if(this.isAddEmployeModal) {
							this.stopSpinner();
							let toastMessage = { type: "success", message: updateEmpMessage };
							toastEvents(this, toastMessage);
						}
						const onAddEmployee = new CustomEvent("addemployee", {
							detail : {
								result : result.result,
								updateEmpMessage : updateEmpMessage,
							}
						});
						this.ListOfCity = [];
						this.managerId = '';
						this.dispatchEvent(onAddEmployee);
					}
				}
				
			})
			.catch(err => {
				this.stopSpinner();
				let toastError = { type: "error", message: 'Something went wrong.' };
				toastEvents(this, toastError);
				console.log(this.proxyToObj(err));
			});
		} else {
			let invalidFields = this.employeeFields.filter(emp => emp.isValid === false);
			let validFields = this.employeeFields.filter(emp => emp.isValid === true);
			let fields = [];
			let fieldsLabel = [];
			//Please complete 

			invalidFields.forEach(emp => {
				fieldsLabel.push(emp.label)
				fields.push(emp.fieldName);
			});
			if(fields?.length){
				this.validateFieldFormate(fields)
			}
			if(invalidFields.length === 1) {
				let error = {type : "error", message: "Complete the required, they cannot be left blank"}
				toastEvents(this, error);
			} else if(invalidFields && invalidFields.length > 1) {
				let error = {type : "error", message: `Please complete ${fieldsLabel.join(", ")} required fields.`}
				toastEvents(this, error);
			}
			validFields.forEach(emp => {
				this.setErrorMessage(emp.fieldName, "");
			});
		}
	}

	validateFieldFormate(fields) {
		fields.forEach(field => {
			if(field === "cellphone") {
				let phoneNumber = this.getValueByField(field);
				const phoneNumberRegex = /^\d{3}-\d{3}-\d{4}$/;
				if(phoneNumber && !phoneNumberRegex.test(phoneNumber) ) {
					this.setErrorMessage(field, "Please add valid phone");
				}else {
					this.setErrorMessage(field, "");
				}
			}
			if(field === "costCode") {
				let costCodeNumber = this.getValueByField(field);
				const costCodeNumberRegex = /^\d{2}-\d{4}-\d{3}$/;
				if(costCodeNumber && !costCodeNumberRegex.test(costCodeNumber)) {
						this.setErrorMessage(field, "Please add valid cost code");
				} else {
					this.setErrorMessage(field, "");

				}
			}
		})
	}

	getValueByField(field) {
		let currentField =  this.employeeFields.find(emp => emp.fieldName === field);
		return currentField?.value;
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

	validateSingleField(employee, index) {
		let isValid = this.validateField(employee);
		let errorClass = this.getClassName(employee);
		let cmpClass = this.getCmpClass(employee, true);
		let empList = this.proxyToObj(this.employeeFields);
		empList[index].isValid = isValid;
		empList[index].errorClass = errorClass;
		empList[index].cmpClass = cmpClass;
		this.employeeFields = empList;
	}

	getClassName(employee) {
		let isValid = this.validateField(employee);
		if(isValid) {
			if(employee.type === "select" || employee.type === "date" || employee.type === "component") {
				return 'content-select-success';
			} else {
				return 'content-input-success';
			}
		} else {
			if(employee.type === "select" || employee.type === "date" || employee.type === "component") {
				return 'content-select-error';
			} else {
				return 'content-input-error';
			}
		}
	}

	validateField(employee) {
		let  { value, fieldName, isRequired } = employee;
	       console.log("Fi", fieldName);
			if(fieldName === "email" && isRequired) {
				return this.isRequired(value) && this.isValidEmail(value)
			}else if(isRequired) {
				return this.isRequired(value);
			}  else if (fieldName === "costCode" && value && value.length !== 11) {
				return false;
			} else{
				return true;
			}
	}

	isRequired(value) {
		if(!value) {
			return false
		}
		return true;
	}

	isValidEmail(email) {
		if(email) {
			const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  			return emailRegex.test(email);
		}
		return false;
	}

	updateRequiredField(role) {
		let employeeFields = this.proxyToObj(this.employeeFields);
		if(role.includes('Driver')) {
			employeeFields = employeeFields.map(field => ({
				...field,
				isRequired : this.requiredFields.driver.includes(field.fieldName) ? true : false
			}) );
			this.employeeFields = employeeFields;
		} else if(role === "Manager") {
			employeeFields = employeeFields.map(field => ({
				...field,
				isRequired : this.requiredFields.manager.includes(field.fieldName) ? true : false
			}));
			this.employeeFields = employeeFields;
		} else if(role === "Admin") {
			employeeFields = employeeFields.map(field => ({
				...field,
				isRequired : this.requiredFields.admin.includes(field.fieldName) ? true : false
			}));
			this.employeeFields = employeeFields;
		}
	}

	updateVehicleTypeList(role){
		if(role.includes('Driver')) {
			if(this.listOfVehicles.length === 2){
				this.setValue('vehicalType', this.listOfVehicles[1]?.value);
			}
		}else{
			this.setValue('vehicalType', '');
		}
	}

	getCityList(zip) {
		if(zip && (zip.length >= 3 && zip.length <= 6)) {
			let newZip = zip.padStart(5, '0')
			getCountryStateCity({zipcode: newZip})
			.then(responce => {
				let cityArray = [];
				let isDependentDropDown = false;
				let state = '';
				if(responce) {
					let ListOfCity = this.proxyToObj(responce);
					this.ListOfCity = JSON.parse(ListOfCity);
					if(this.ListOfCity && this.ListOfCity.length){
						this.ListOfCity.forEach(city => {
							let singleCity = {};
							singleCity.id =   city.Id;
							singleCity.label = city.City__c;
							singleCity.value = city.City__c;
							cityArray.push(singleCity);
							state = city?.Abbreviation__c;
						});
						isDependentDropDown = true
					}
				} 
				
				if(cityArray.length === 0) {
					this.setValue('city', '');
					this.setValue('state', '');
					this.setDependentDropDown("city", []);
					let toastSuccess = { type: "error", message: "Add valid zip code" };
					toastEvents(this, toastSuccess);
					this.setErrorMessage("zipCode", '');
				} else {
					let message = 'Select one city for the associated zip code';

					this.employeeFields = this.employeeFields.map(emp => ({
						...emp,
						isDependentDropDown: (emp.fieldName === "city") ? isDependentDropDown : emp.isDependentDropDown,
						dropDownList: (emp.fieldName === "city") ? cityArray : emp.dropDownList
					}));
					if(this.ListOfCity?.length > 1) {
						if(!this.isRecordFirstTimeLoading) {
							this.setErrorMessage("zipCode", message);
						} else {
							this.isRecordFirstTimeLoading = false;
							this.setErrorMessage("zipCode", '');
						}
					}
					if(this.ListOfCity?.length == 1) {
						this.setErrorMessage("zipCode", '');
						this.setValue('city', cityArray[0]?.value);
						this.setValue('state', state);
						this.updateNearestDrivingState(state);
					}
				}
			})
			.catch(err => {
				console.log(this.proxyToObj(err));
			})
		} else {
			this.employeeFields = this.employeeFields.map(emp => ({
				...emp,
				value : (emp.fieldName === 'state' || emp.fieldName === 'city' ) ? '' : emp.value,
				dropDownList: (emp.fieldName === "city") ? [] : emp.dropDownList,
			}));
			this.setErrorMessage("zipCode", "");
			this.ListOfCity = [];
		}
	}

	updateNearestDrivingState(state) {
		let validState = this.validStateList ? this.validStateList.split(',') : [];
			if (state &&  this.validStateList && validState.includes(state) && !this.tags.includes(state)) {
				  this.tags.push(state);
				  this.updateDrivingState(this.tags);
			}
	}

	setErrorMessage(field, message){
		this.employeeFields = this.employeeFields.map(emp => ({
			...emp,
			errorMsg: (emp.fieldName === field)  ?  message  : emp.errorMsg
		}));
	}

	setValue(field, value) {
		this.employeeFields = this.employeeFields.map(emp => ({
			...emp,
			value: (emp.fieldName === field)  ?  value  : emp.value
		}));
	}

	handleRemoveTag(event) {
		const tagToRemove = event?.detail;
		if(this.tags && this.tags.length) {
			this.tags = this.tags.filter(state => state !== tagToRemove);
			this.updateDrivingState(this.tags);
		}
	}

	handleTagInput(event) {
		if (event.key === 'Enter' || event.type === 'blur' || event.type === 'focusout') {
			const value = event.target.value.trim();
			let validState = this.validStateList ? this.validStateList.split(',') : [];
			if (value &&  this.validStateList && validState.includes(value) && !this.tags.includes(value)) {
				  this.tags.push(value);
				  this.updateDrivingState(this.tags);
			}
			if(value && !validState.includes(value) && event.type !== 'blur'){
				let invalidStateError = `<b> Driving State entered </b> is a invalid state. Please enter an valid state.`;
				let toastSuccess = { type: "error", message: invalidStateError };
				toastEvents(this, toastSuccess);
			}
		}
	}

	updateDrivingState(tags) {
		this.employeeFields = this.employeeFields.map(emp => ({
			...emp,
			value : emp.fieldName === "drivingStates" ? tags : emp.value
		}))
	}
	
	editRecord(){
		let record = this.proxyToObj(this.record);
		if(record?.zipCode) {
			this.isRecordFirstTimeLoading = true;
			this.getCityList(record?.zipCode);
		}
		if(record?.role) {
			this.updateRequiredField(record?.role);
		}
		if(record?.userid) {
			this.isUpdateMode = true;
			this.isSelectedDate = true;
		}
		if(record?.drivingStates) {
			this.tags = record?.drivingStates;
		} 
		if(record) {
			this.employeeFields = this.employeeFields.map(emp => ({
				...emp,
				value :  record[emp.fieldName] ? record[emp.fieldName] : emp.value,
				displayValue: (emp.type === "date") ? record[emp.fieldName] ? this.convertDateFormat(record[emp.fieldName]) : '' : ''
			}));
		}
		this.dispatchEvent(new CustomEvent("resetuser", {}));
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

	getListOfDropDownData() {
		getAllManagers({accID: this.accid})
		.then(managers => {
			let managerList = JSON.parse(managers);
			let managerArray = [];
			managerList.forEach(manager => {
				let singleManager = {};
				singleManager.id = manager.Id;
				singleManager.label = manager.Name;
				singleManager.value = manager.Id;
				managerArray.push(singleManager);
			});
			// this.managers = managerArray;
			this.setDependentDropDown("managerName", managerArray);
		})
		.catch(err => {
			console.log(err);
		});

		
		let reimFreqList = [{id: 'Monthly Reimbursement',label: 'Monthly Reimbursement' , value: 'Monthly Reimbursement'},
							{id: 'Bi-Weekly Reimbursement',label: 'Bi-Weekly Reimbursement' , value: 'Bi-Weekly Reimbursement'}];
			
		this.setDependentDropDown("ReimbursementFrequency", reimFreqList);
		let cellPhoneList = [{id: 'Company Provide',label: 'Company Provide' , value: 'Company Provide'},
							{id: 'Employee Provide',label: 'Employee Provide' , value: 'Employee Provide'}];
			
		this.setDependentDropDown("CellPhoneProvider", cellPhoneList);

		getRoles()
		.then(roles => {
			let roleList = this.formatArray(JSON.parse(roles));
			this.setDependentDropDown("role", roleList);
		})
		.catch(err => {
			console.log(err);
		});
		getDrivingStates()
		.then(response => {
			let stateList = JSON.parse(response);
			if(stateList && stateList.length){
				this.validStateList = stateList.toString();
			}
		})
		.catch(err => {
			console.log(err)
		});
		getJobTitle()
		.then(responce => {
			let jobTitles = this.formatArray(JSON.parse(responce));
			this.setDependentDropDown("jobtitle", jobTitles);
		})
		.catch(err => {
			console.log("JOBLISTERRR",err);
		});
		getDepartment()
		.then(responce => {
			let departments = this.formatArray(JSON.parse(responce));
			this.setDependentDropDown("department", departments);
		})
		.catch(err => {
			console.log({err});
		});
		getCompany()
		.then(responce => {
			let companies = this.formatArray(JSON.parse(responce));
			this.setDependentDropDown("company", companies);
		})
		.catch(err => {
			console.log({err});
		});
		getPickListValuesIntoList({accid:this.accid})
		.then(responce => {
			let vehicles = JSON.parse(responce);
			if(vehicles && vehicles.length && Array.isArray(vehicles)) {
				let vehicleTypeList = this.formatArray(vehicles[1].split(";"));
				vehicleTypeList.unshift({id: '---', label: '---', value: '---' });
				this.setDependentDropDown("vehicalType", vehicleTypeList);
				this.listOfVehicles = vehicleTypeList;
			}
		})
		.catch(err => {
			console.log(this.proxyToObj(err));
		})
		getDriverType()
		.then(responce => {
			let driverTypes = this.formatArray(JSON.parse(responce));
			this.setDependentDropDown("driverType", driverTypes)
		})
		.catch(err => {
			console.log(this.proxyToObj(err));
		})
	}

	setDependentDropDown(field, dropDownList) {
		this.employeeFields = this.employeeFields.map(emp => ({
			...emp,
			isDependentDropDown: (emp.fieldName === field) ? true : emp.isDependentDropDown,
			dropDownList: (emp.fieldName === field) ? dropDownList : emp.dropDownList
		}));
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

	convertDateFormat(dateString) {
		if(dateString) {
			var dateParts = dateString.split('/');
			var month = dateParts[0];
			var day = dateParts[1];
			var year = dateParts[2].slice(-2);
			
			return month + '/' + day + '/' + year;
		} else {
			return '';
		}
	}
}