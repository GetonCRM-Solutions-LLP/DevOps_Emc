import { LightningElement, track, api, wire } from 'lwc';
import fetchLookUpValues from '@salesforce/apex/GetDriverData.fetchLookUpValues';
export default class InlineDropdown extends LightningElement {
    @track options = [];
    @track searchValue = '';
    @api defaultOption;
    @api searchKey;
    @api selectedClass;
    @api objectName;
    @api fieldName;
    @api accId;
    @api adminId;
    @api accField;
    @api idOfDriver;
    @api whereField;
    @api keyField;
    @api plAccId;
    @api selectedAccount;
    @api dynamicPlaceholder;
    @track defaultkey = '0000000000BBBBRRRR';
    @track showAccountsListFlag = false;
    @track activeDriver = true;
    @track isSelection = false;

    get isRestricted() {
        return (this.accId === this.plAccId) ? false : true;
    }
    @api showOption() {
        this.template.querySelector('.selectedOption').classList.remove('slds-hide');
    }
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
        var selectIcon =  this.template.querySelector('.slds-icon-utility-down');
        selectIcon.classList.remove('slds-hide');
        this.template.querySelector('.slds-searchIcon').classList.add('slds-hide');
        this.showAccountsListFlag = false;
        this.isSelection = false;
    }

    // wire property to get data from apex
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
        if (data) {
            let picklistOptions = [];
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
            picklistOptions = picklistOptions.filter(function(x){return (x.value !== undefined && x.value != 'All Activities') })
            this.options = picklistOptions;

        } else if (error) {
            // eslint-disable-next-line no-alert
            console.log(error);
        }

    }

    // Open Dropdown
    handleClick() {

        if (!this.showAccountsListFlag) {

            this.showAccountsListFlag = true;


            /* hide/show icons*/
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

    // On search in dropdown list event
    handleKeyUp(event) {
        this.searchValue = event.target.value;
        if (this.searchValue) {
            // eslint-disable-next-line @lwc/lwc/no-async-operation

            this.searchValue = this.searchValue;
            const filter = this.searchValue.toUpperCase();
            const span = this.template.querySelector('.slds-listbox_vertical').childNodes;


            for (let i = 1; i < span.length; i++) {
                const option = span[i].textContent;
                if (option.toUpperCase().indexOf(filter) > -1) {
                    span[i].style.display = "";
                } else {
                    span[i].style.display = "none";
                }
            }

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

    // Select Option From Dropdown List
    handleOptionSelect(event) {
        event.preventDefault();
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
        // this.template
        //     .querySelector('.selectedOption')
        //     .classList.add('expand-css');

        this.template
            .querySelector('.accounts_list')
            .classList.add('slds-hide');

        const targetEvent = new CustomEvent("handleselectevent", {
            detail: targetname
        });
     
        this.dispatchEvent(targetEvent);
    }

    // Remove Selected Option in Dropdown
    handleRemoveSelectedOption(event) {
        event.preventDefault();
        this.isSelection = false;

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.selectedAccount = '';
        this.template
            .querySelector('.selectedOption')
            .classList.add('slds-hide');

        this.template
            .querySelector('.selectedOption')
            .classList.remove('expand-css');

        this.template
            .querySelector('.slds-icon-utility-down')
            .classList.remove('slds-hide');

        this.template
            .querySelector('.slds-searchIcon')
            .classList.add('slds-hide');

        const targetEvent = new CustomEvent("handleselectevent", {
            detail: this.selectedAccount
        });

        this.dispatchEvent(targetEvent);
        this.template.querySelector('.searchvalue').value = '';
        this.searchValue = '';
        const span = this.template.querySelector('.slds-listbox_vertical').childNodes;

        for (let i = 0; i < span.length; i++) {

            if (span[i].style.display === 'none') {

                span[i].style.display = "";
            }
        }
        this.showAccountsListFlag = false;


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
}