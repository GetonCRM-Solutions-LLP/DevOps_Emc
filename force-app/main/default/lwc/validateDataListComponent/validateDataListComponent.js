/* eslint-disable no-debugger */
/* eslint-disable no-console */
import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';
import fetchLookUpValues from '@salesforce/apex/GetDriverData.fetchLookUpValues';
export default class ValidateDataListComponent extends LightningElement {
    ready = false;
    renderedCallback = false;
    @track options = [];
    @track filterOption = [];
    @track searchValue = '';
    @api defaultOption;
    @api searchKey;
    @api accId;
    @api adminId;
    @api accField;
    @api objectName;
    @api fieldName;
    @api idOfDriver;
    @api whereField;
    @api keyField;
    @api disable;
    @api dynamicPlaceholder;
    @api selectedAccount = '';
    @track defaultkey = '0000000000BBBBRRRR';
    @track showAccountsListFlag = false;
    @track activeDriver = true;
    @track isSelection = false;
    @api getOption(optValue) {
        this.selectedAccount = optValue;
    }

    @api getActiveDriver(boolValue){
       this.activeDriver = boolValue;
    }
    @api deleteSelectedOption() {
        this.selectedAccount = undefined;
        this.template.querySelector('.selectedOption').classList.add('slds-hide');
    }
    @api clearAll() {
        var selectElement = this.template.querySelector('.selectedOption');
        selectElement.style.display = 'none';
        this.template.querySelector('.searchvalue').value = '';
        this.searchValue = '';
        if (this.searchValue != undefined) {
            let filterItem = this.filterSearch(this.searchValue);
            this.options = filterItem;
        }
        var selectIcon =  this.template.querySelector('.slds-icon-utility-down');
        selectIcon.classList.remove('slds-hide');
        this.template.querySelector('.slds-searchIcon').classList.add('slds-hide');
        this.showAccountsListFlag = false;
        this.isSelection = false;
    }

    @wire(fetchLookUpValues, {
        accId:'$accId',
        adminId:'$adminId',
        accField:'$accField',
        searchKey: '$searchKey',
        idOfDriver: '$idOfDriver',
        fieldName: '$fieldName',
        ObjectName: '$objectName',
        keyField: '$keyField',
        whereField: '$whereField',
        isActive: '$activeDriver'
    })
    picklistvalues({
        data,
        error
    }) {
      //  console.log('From Tags->', this.accId,this.adminId,this.accField,this.searchKey,this.idOfDriver,this.fieldName,this.objectName,this.keyField,this.whereField,this.isActive);
        if (data) { 
           // console.log('From Tags->', data);
            let picklistOptions = [{
                key: this.defaultOption,
                value: this.defaultOption
            }];
            data.forEach(key => {
                picklistOptions.push({
                    key: key[this.keyField],
                    value: key[this.fieldName]
                });
            });

            // To remove duplicate values
            const dupkey = 'value';
            const uniqueArr = [...new Map(picklistOptions.map(item => [item[dupkey], item])).values()]
            picklistOptions = uniqueArr;
            picklistOptions = this.defaultSorting(picklistOptions,'value');
            this.options = picklistOptions;
            this.filterOption = picklistOptions;

        } else if (error) {
            // eslint-disable-next-line no-alert
            console.log(error);
        }

    }

    defaultSorting(sortArr, keyName) {
       let defaultvalue = this.defaultOption
        if (keyName === "value") {
            sortArr.sort(function (a, b) {
                if (a[keyName] != defaultvalue && b[keyName] != defaultvalue) {
                    var nameA =
                        a[keyName] == null || undefined ?
                        "" :
                        a[keyName].toLowerCase(),
                        nameB =
                        b[keyName] == null || undefined ?
                        "" :
                        b[keyName].toLowerCase();
                    //sort string ascending
                    if (nameA < nameB) {
                        return -1;
                    } else if (nameA > nameB) {
                        return 1;
                    } else {
                        return 0;
                    }
                }

            });

        }

        return sortArr;

    }

    handleClick() {
        // console.log(this.selectedOption);

        if (!this.showAccountsListFlag) {

            this.showAccountsListFlag = true;



            this.template
                .querySelector('.accounts_list')
                .classList.remove('slds-hide');

            this.template
                .querySelector('.slds-searchIcon')
                .classList.remove('slds-hide');

            this.template
                .querySelector('.slds-icon-utility-down')
                .classList.add('slds-hide');

        }
        this.template
            .querySelector('.slds-dropdown-trigger')
            .classList.add('slds-is-open');


    }

    handleKeyUp(event) {
        this.searchValue = event.target.value;
        if (this.searchValue) {
            // eslint-disable-next-line @lwc/lwc/no-async-operation

            this.searchValue = this.searchValue;
            let filterItem = this.filterSearch(this.searchValue);
            this.options = filterItem;
        }


        if (this.searchValue === '') {
            this.template
                .querySelector('.accounts_list')
                .classList.add('slds-hide');

            this.template
                .querySelector('.slds-searchIcon')
                .classList.add('slds-hide');

            this.template
                .querySelector('.slds-icon-utility-down')
                .classList.remove('slds-hide');

            this.showAccountsListFlag = false;
        }

    }
    filterSearch(searchValue) {
        var searchArr = [];
        this.filterOption.forEach((opt) => {
            searchArr.push({
                key: opt.key,
                value: opt.value
            });
        });
        const filter = searchValue.toUpperCase();
        let filSearchArr = searchArr.filter(option => {
            if (option.value != undefined) {
                if (option.value.toUpperCase().includes(filter)) {
                    return option;
                }
            }
        });

        return filSearchArr;
    }
    handleOptionSelect(event) {
        event.preventDefault();
        const targetId = event.currentTarget.dataset.id;
        const targetname = event.currentTarget.dataset.name;
        this.selectedAccount = event.currentTarget.dataset.name;
        if (!this.isSelection) {
            this.isSelection = true;
        }
        if(this.template.querySelector('.selectedOption').style.display === 'none') {
            this.template.querySelector('.selectedOption').style.display = 'block';
        }else{
        this.template
            .querySelector('.selectedOption')
            .classList.remove('slds-hide');
        }
        this.template
            .querySelector('.accounts_list')
            .classList.add('slds-hide');

        const selectedEvent = new CustomEvent("handleclickevent", {
            detail: targetId
        });
        this.dispatchEvent(selectedEvent);
        
        const targetEvent = new CustomEvent("handleselectevent", {
            detail: targetname
        });

        this.dispatchEvent(targetEvent);

    }

    handleRemoveSelectedOption(event) {
        event.preventDefault();

        this.isSelection = false;

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.selectedAccount = '';
        this.template
            .querySelector('.selectedOption')
            .classList.add('slds-hide');

        this.template
            .querySelector('.slds-icon-utility-down')
            .classList.remove('slds-hide');

        this.template
            .querySelector('.slds-searchIcon')
            .classList.add('slds-hide');

        this.template.querySelector('.searchvalue').value = '';
        this.searchValue = '';
				let filterItem = this.filterSearch(this.searchValue);
        this.options = filterItem;
        this.showAccountsListFlag = false;

        const selectedEvent = new CustomEvent("handleclickevent", {
            detail: null
        });
        this.dispatchEvent(selectedEvent);

        const targetEvent = new CustomEvent("handleselectevent", {
            detail: null
        });
        this.dispatchEvent(targetEvent);

    }

    handleBlur() {
        if (!this.isSelection) {
            this.template
                .querySelector('.slds-dropdown-trigger')
                .classList.remove('slds-is-open');

            this.template
                .querySelector('.slds-searchIcon')
                .classList.add('slds-hide');

            this.template
                .querySelector('.slds-icon-utility-down')
                .classList.remove('slds-hide');

            this.showAccountsListFlag = false;

        }
    }

    renderedCallback() {
        if (!this.ready) {
            this.ready = true;
        }
        if (this.selectedAccount != '') {
            this.template
                .querySelector('.selectedOption')
                .classList.remove('slds-hide');
        }
    
    }
    connectedCallback() {
        setTimeout(() => {
            this.ready = true;
        }, 2000);
    }

}