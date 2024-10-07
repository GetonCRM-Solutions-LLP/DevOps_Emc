import { LightningElement, api } from 'lwc';
import getCountryStateCity from '@salesforce/apex/RosterController.getCountryStateCity';

export default class EditAddress extends LightningElement {
    @api zipCode;
    @api cityList = [];
    @api ListOfCity = [];
    @api isValidZip = false;
    @api city;

    connectedCallback(){
        this.getCityList(this.zipCode);
    }

    handleInput(event) {
        let value = this.isZipCode(event.currentTarget.value);
        let inputType = event.currentTarget.dataset.inputType;
        if(inputType === "input") {
            if(value && (value.length >= 3 && value.length <= 6)){
                this.isValidZip = false;
                this.zipCode = value;
                this.getCityList(value);
            } else {
                this.isValidZip = false;
            }
            if(value == null || value == "" || value == undefined) {
                const zipCodeEvent = new CustomEvent('update', {
                    detail : {
                        value: value,
                        fieldName: "zipCode"
                    }
                });
                this.dispatchEvent(zipCodeEvent);
                this.updateCityState("", "");
            }
            this.zipCode = value;
        }
        
        if (inputType === "select") {
            let id = event.detail?.key;
            let city = this.ListOfCity.filter(city => city.Id === id);
            if(city?.length){
                this.updateCityState(event.detail.value, city[0]?.Abbreviation__c);
            }
        }
    }

    isZipCode(inputString) {
		const maxLength = 6;
    	let stringWithOnlyAlphaNumeric = inputString.replace(/[^a-zA-Z0-9]/g, '');
    	return stringWithOnlyAlphaNumeric.slice(0, maxLength);
	}

    getCityList(zip) {
        getCountryStateCity({zipcode: zip})
        .then(responce => {
            if(responce) {
                let ListOfCity = this.proxyToObj(responce);
                this.ListOfCity = JSON.parse(ListOfCity);
                let cityArray = [];
                if(this.ListOfCity && this.ListOfCity.length){
                    this.ListOfCity.forEach(city => {
                        let singleCity = {};
                        singleCity.id =   city.Id;
                        singleCity.label = city.City__c;
                        singleCity.value = city.City__c;
                        cityArray.push(singleCity);
                    });
                    console.log(this.proxyToObj(cityArray)); 
                    this.isValidZip = true;
                    this.cityList = cityArray;
                }
                const zipCodeEvent = new CustomEvent('update', {
                    detail : {
                        value: zip,
                        fieldName: "zipCode"
                    }
                });
                this.dispatchEvent(zipCodeEvent);
            }  else {
                this.ListOfCity = [];
                this.city = '';
                this.isValidZip = false;
                this.updateCityState("", "");
            }
        })
        .catch(err => {
            console.log(err)
        })
    }

    handleToast(event) {
        let zip = event.currentTarget.value
        if(zip) {
            getCountryStateCity({zipcode: zip})
            .then(responce => {
                let ListOfCity = this.proxyToObj(responce);
                if(!ListOfCity || !ListOfCity.length){
                    const inValidZip = new CustomEvent('invalidzip', {
                        detail : {
                            message : "Add valid zip code"
                        }
                    });
                    this.dispatchEvent(inValidZip);
                }
            })
            .catch(err => {
                console.log(err)
            })
        }
    }

    updateCityState(city, state) {
        const cityEvent = new CustomEvent('update', {
            detail : {
                value: city,
                fieldName: "city"
            }
        });
        this.dispatchEvent(cityEvent);
        const stateEvent = new CustomEvent('update', {
            detail : {
                value: state,
                fieldName: "state"
            }
        });
        this.dispatchEvent(stateEvent);
    }

    proxyToObj(data) {
        return JSON.parse(JSON.stringify(data));
    }
}