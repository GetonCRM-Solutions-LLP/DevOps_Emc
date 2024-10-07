import { LightningElement, api, track, wire } from 'lwc';
import resourceImage from '@salesforce/resourceUrl/mBurseCss';
import getAllUSStates from '@salesforce/apex/ImportLocationController.getAllUSStates';
import getAllCANStates from '@salesforce/apex/ImportLocationController.getAllCANStates';
import { toLocation, getLocations } from "c/apexUtils";
import {
    toastEvents, modalEvents
} from 'c/utils';
export default class ViewUserLocation extends LightningElement {
    @api contactId;
    @api location;
    @track locationModelList;
    @track updateList;
    @api mapCountry;
    classToTable = 'fixed-container';
    column;
    noMessage = 'There is no location data available'
    refreshList;
    resultUpdateLocation;
    isEditMode;
    keyFields;
    locationKeyFields = ["name", "street", "city", "state", "zipCode", "range"];
    // locationKeyFields = ["name", "address", "range"];
    locationColumn = [{
            id: 1,
            name: "Location Name",
            colName: "name",
            colType: "String",
            arrUp: false,
            arrDown: false
        },
        {
            id: 2,
            name: "Street",
            colName: "street",
            colType: "String",
            arrUp: false,
            arrDown: false,
        },
        {
            id: 3,
            name: "City",
            colName: "city",
            colType: "String",
            arrUp: false,
            arrDown: false,
        },
        {
            id: 4,
            name: "State",
            colName: "state",
            colType: "String",
            arrUp: false,
            arrDown: false,
        },
        {
            id: 5,
            name: "Zip Code",
            colName: "zipCode",
            colType: "Integer",
            arrUp: false,
            arrDown: false,
        },
        // {
        //     id: 6,
        //     name: "Location Address",
        //     colName: "address",
        //     colType: "String",
        //     arrUp: true,
        //     arrDown: false
        // },
        {
            id: 6,
            name: "Range (ft)",
            colName: "range",
            colType: "Integer",
            arrUp: false,
            arrDown: false
        }
    ];
    isSortable = false;
    _value = "";
    isScrollable = false;
    isSearchEnable = true;
    paginatedModal = false;
    editableView = false;
    searchIcon = resourceImage + '/mburse/assets/mBurse-Icons/Vector.png';

    usaStates = [];
    cndStates = [];
    stateList;
    @wire(getAllUSStates)
    listOfUsStates ({error, data}) {
        if (error) {
            console.log("Error from listOfStates : " + JSON.stringify(error));
        } else if (data) {
            console.log("Data from metadata : " + JSON.stringify(data));
            data.forEach(element => {
                let tempObj = {
                    label: element.Label,
                    value: element.shortName__c
                }
                this.usaStates.push(tempObj);
            });
        }
    }
    @wire(getAllCANStates)
    listOfCnStates ({error, data}) {
        if (error) {
            console.log("Error from listOfCnStates : " + JSON.stringify(error));
        } else if (data) {
            console.log("Data from metadata : " + JSON.stringify(data));
            data.forEach(element => {
                let tempObj = {
                    label: element.Label,
                    value: element.shortName__c
                }
                this.cndStates.push(tempObj);
            });
        }
    }

    proxyToObject(e) {
        return JSON.parse(e)
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

    handleClearInput(){
        this._value = "";
        this.isSearchEnable = this._value === "" ? true : false;
        this.template
        .querySelector("c-user-preview-table")
        .searchByKey(this._value);
    }

    dynamicBinding(data, keyFields) {
        data.forEach(element => {
            let model = [];
            for (const key in element) {
                if (Object.prototype.hasOwnProperty.call(element, key)) {
                    let singleValue = {}
                    if (keyFields.includes(key) !== false) {
                        singleValue.key = key;
                        singleValue.value = (element[key] === "null" || element[key] === null) ? "" : element[key];
                        singleValue.isLocZip = key === "zipCode" ? true : false;
                        singleValue.isSearchableDropdown = key === 'state' ? true : false;
                        if(key === 'state') {
                            if(this.mapCountry == 'USA') {
                                singleValue.dropDownList = this.usaStates;
                            } else {
                                singleValue.dropDownList = this.cndStates;
                            }
                        }
                        singleValue.truncate = (key === 'name') ? true : false;
                        singleValue.tooltip = (key === 'name') ? true : false;
                        singleValue.tooltipText =  (key === 'name') ? (element[key] != null) ? element['address'] : 'This trip was manually entered without a name.' : "";
                        // singleValue.isCurrency = (key === 'variableamount' || key === 'VariableRate' || key === 'variableRate'  || key === 'varibleAmount' || key === 'fixed1' || key === 'fixed2' || key === 'fixed3' || key === 'totalFixedAmount') ? true : false;
                        model.push(singleValue);
                    }
                }
            }
            element.isEdited = false;
            element.keyFields = this.mapOrder(model, keyFields, 'key');
        });
    }

    handleChange(event) {
		this._value = event.target.value;
        this.isSearchEnable = this._value === "" ? true : false;
        this.template.querySelector('c-user-preview-table').searchByKey(this._value, this.locationModelList)
	}

    editMode(){
        this.isEditMode = true;
    }

    handleUpdateList(event){
        //this.locationModelList = [];
        this.updateList = this.proxyToObject(event.detail);
        console.log("this.update", JSON.stringify(this.updateList));
    }

    async updateLocations(){
        toastEvents(this, 'Please wait while your locations being updated.');
        let array = this.updateList;
        // eslint-disable-next-line no-unused-vars
        console.log("array : " + JSON.stringify(array));
        const newLocationArr = array.map(({keyFields,isEdited, ...rest}) => { // Removes certain keys from objects of array "keyFields, isEdited"
            let stateDetail = {};
            if(rest.state != '') {
                stateDetail = this.stateList.find(item => item.label == rest.state);
                rest.state = stateDetail.label.replace(/ /g, "_");
            } else {
                stateDetail.value = '';
            }
            rest.address = rest.street + ', ' + rest.city + ', ' + stateDetail.value + ' ' + (rest.zipCode == null ? '' : rest.zipCode);
            rest.range = this.mapCountry == 'CANADA' ? (rest.range == null ? null : parseInt(rest.range * 3.28)) : rest.range;
            return rest;
        });
        console.log("newLocationArr - " + JSON.stringify(newLocationArr));

       const newMlogArr = array.map((ele) => {
            const o = {...ele}; // does not mutuate original array by using spread operator as it creates copy
            o.range = this.mapCountry == 'CANADA' ? (o.range == null ? null : parseInt(o.range * 3.28)) : o.range;
            o["range (ft)"] = o.range;
            delete o.keyFields;
            delete o.isEdited;
            delete o.range;
            let stateDetail = {};
            if(o.state != '') {
                stateDetail = this.stateList.find(item => item.label == o.state);
                o.state = stateDetail.label.replace(/ /g, "_");
            } else {
                stateDetail.value = '';
            }
            // let stateDetail = this.stateList.find(item => item.label == o.state);
            // o.state = stateDetail.label.replace(/ /g, "_");
            o.address = o.street + ', ' + o.city + ', ' + stateDetail.value + ' ' + (o.zipCode == null ? '' : o.zipCode);
            return o;
        });
     
        this.resultUpdateLocation = await toLocation(JSON.stringify(newLocationArr), this.contactId, JSON.stringify(newMlogArr));
        if(this.resultUpdateLocation === 'Success'){
            toastEvents(this, 'Hide');
            modalEvents(this, 'Your location has been updated');
            this.isEditMode = false;
            if(this.template.querySelector('.filter-input')){
                this.template.querySelector('.filter-input').value = "";
            }
            this.refreshList = await getLocations(this.contactId);
            this.locationModelList =  this.proxyToObject(this.refreshList);
            this.dynamicBinding(this.locationModelList, this.keyFields);
            this.template.querySelector('c-user-preview-table').refreshTable(this.locationModelList);
        }else{
            toastEvents(this, 'Hide');
            this.dispatchEvent(
                new CustomEvent("error", {
                    detail: 'Unable to update your locations. Please try again'
                })
            );
        }
    }

    cancelEditMode(){
        this.isEditMode = false;
        if(this.template.querySelector('.filter-input')){
            this.template.querySelector('.filter-input').value = "";
        }
        this.template.querySelector('c-user-preview-table').refreshTable(this.locationModelList);
    }

    connectedCallback(){
        if(this.mapCountry == 'USA') {
            this.stateList = this.usaStates;
        } else {
            this.stateList = this.cndStates;
        }
        console.log("this.location", this.location)
        if (this.location) {
            this.locationModelList = this.proxyToObject(this.location);
            this.column = this.locationColumn.map((ele) => {
                if(ele.colName == 'state' && this.mapCountry == 'CANADA') {
                    ele.name = 'Province';
                } else if(ele.colName == 'zipCode' && this.mapCountry == 'CANADA') {
                    ele.name = 'Postal Code';
                    ele.colType = 'String';
                } else if(ele.colName == 'range' && this.mapCountry == 'CANADA') {
                    ele.name = 'Range (mtr)';
                }
                return ele;
            });
            this.keyFields = this.locationKeyFields;
            this.isSortable = true;
            this.editableView = true;
            if (this.locationModelList !== undefined) {
                this.classToTable = this.locationModelList.length > 6 ? 'fixed-container' : 'fixed-container overflow-none';
                this.isScrollable = this.locationModelList.length > 6 ? true : false;
                this.paginatedModal = true;
                this.dynamicBinding(this.locationModelList, this.keyFields);
            }

          
        }
    }
}