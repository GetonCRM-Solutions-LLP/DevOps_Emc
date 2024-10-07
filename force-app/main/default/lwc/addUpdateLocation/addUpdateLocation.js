import { LightningElement, api, wire } from 'lwc';
import getAllUSStates from '@salesforce/apex/ManualEntryController.getAllUSStates';
import getAllCANStates from '@salesforce/apex/ManualEntryController.getAllCANStates';
import insertLocation from '@salesforce/apex/ManualEntryController.insertLocation';
import updateLocation from '@salesforce/apex/ManualEntryController.updateLocation';
import getLatLong from '@salesforce/apex/GoogleAPICallouts.getLatLong';
import getCountryStateCity from '@salesforce/apex/RosterController.getCountryStateCity';
import MEChannel from "@salesforce/messageChannel/ManualEntry__c";
import { subscribe, MessageContext } from 'lightning/messageService';

export default class AddUpdateLocation extends LightningElement {

    @api tripLogApi;
    @api userTriplogId;
    @api mapCountry;
    @api accountId;
    contactId;
    showLocation;
    _locationState = false;
    locationToAddUpdate;
    addModal = false;
    showDownloadButton = false;
    modalclass = 'slds-modal slds-is-fixed slds-fade-in-open animate__animated animate__fadeInTopLeft';
    headerclass = 'slds-modal__header header-preview hedear-style_class header_style';
    modalcontentstyle = 'slds-modal__content slds-p-left_medium slds-p-right_medium slds-p-bottom_medium slds-p-top_small';
    styleheader = 'slds-modal__container container_style_1';
    subheaderClass = 'slds-modal__title slds-hyphenate hedear-style_class';
    closebtnclass = 'close-notify';
    isCanadianDriver = false;
    dataField;
    tripId;
    statesList;
    // usaStates = [
    //     { label: "Alabama", value: "AL" },
    //     { label: "Alaska", value: "AK" },
    //     { label: "Arizona", value: "AZ" },
    //     { label: "Arkansas", value: "AR" },
    //     { label: "California", value: "CA" },
    //     { label: "Colorado", value: "CO" },
    //     { label: "Connecticut", value: "CT" },
    //     { label: "Delaware", value: "DE" },
    //     { label: "Florida", value: "FL" },
    //     { label: "Georgia", value: "GA" },
    //     { label: "Hawaii", value: "HI" },
    //     { label: "Idaho", value: "ID" },
    //     { label: "Illinois", value: "IL" },
    //     { label: "Indiana", value: "IN" },
    //     { label: "Iowa", value: "IA" },
    //     { label: "Kansas", value: "KS" },
    //     { label: "Kentucky", value: "KY" },
    //     { label: "Louisiana", value: "LA" },
    //     { label: "Maine", value: "ME" },
    //     { label: "Maryland", value: "MD" },
    //     { label: "Massachusetts", value: "MA" },
    //     { label: "Michigan", value: "MI" },
    //     { label: "Minnesota", value: "MN" },
    //     { label: "Mississippi", value: "MS" },
    //     { label: "Missouri", value: "MO" },
    //     { label: "Montana", value: "MT" },
    //     { label: "Nebraska", value: "NE" },
    //     { label: "Nevada", value: "NV" },
    //     { label: "New Hampshire", value: "NH" },
    //     { label: "New Jersey", value: "NJ" },
    //     { label: "New Mexico", value: "NM" },
    //     { label: "New York", value: "NY" },
    //     { label: "North Carolina", value: "NC" },
    //     { label: "North Dakota", value: "ND" },
    //     { label: "Ohio", value: "OH" },
    //     { label: "Oklahoma", value: "OK" },
    //     { label: "Oregon", value: "OR" },
    //     { label: "Pennsylvania", value: "PA" },
    //     { label: "Rhode Island", value: "RI" },
    //     { label: "South Carolina", value: "SC" },
    //     { label: "South Dakota", value: "SD" },
    //     { label: "Tennessee", value: "TN" },
    //     { label: "Texas", value: "TX" },
    //     { label: "Utah", value: "UT" },
    //     { label: "Vermont", value: "VT" },
    //     { label: "Virginia", value: "VA" },
    //     { label: "Washington", value: "WA" },
    //     { label: "West Virginia", value: "WV" },
    //     { label: "Wisconsin", value: "WI" },
    //     { label: "Wyoming", value: "WY" }
    // ];
    // cndStates = [
    //     { label: "Alberta", value: "AB" },
    //     { label: "British Columbia", value: "BC" },
    //     { label: "Manitoba", value: "MB" },
    //     { label: "New Brunswick", value: "NB" },
    //     { label: "Newfoundland and Labrador", value: "NL" },
    //     { label: "Northwest Territories", value: "NT" },
    //     { label: "Nova Scotia", value: "NS" },
    //     { label: "Nunavut", value: "NU" },
    //     { label: "Ontario", value: "ON" },
    //     { label: "Prince Edward Island", value: "PE" },
    //     { label: "Quebec", value: "QC" },
    //     { label: "Saskatchewan", value: "SK" },
    //     { label: "Yukon", value: "YT" }
    // ];

    usaStates = [];
    cndStates = [];

    @wire(getAllUSStates)
    listOfUsStates({ error, data }) {
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
    listOfCnStates({ error, data }) {
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

    @wire(MessageContext)
    messageContext;

    @api
    get showLocation() {
        return this._locationState;
    }

    renderedCallback() {
        if (this.template.querySelector('c-select2-dropdown') != null) {
            this.template.querySelector('c-select2-dropdown').setDynamicContentStyle('8rem', '98%');
        }
    }

    connectedCallback() {
        if (this.mapCountry == 'CANADA') {
            this.isCanadianDriver = true;
            this.statesList = this.cndStates;
        } else {
            this.statesList = this.usaStates;
        }
        this.subscription = subscribe(this.messageContext, MEChannel, (detail) => {
            this._locationState = true;
            console.log("detail : " + JSON.stringify(detail));
            this.contactId = detail.contactId;
            this.dataField = detail.dataField;
            this.tripId = detail.tripId;
            if (this.dataField.split('-')[1] == 'add') {
                this.addModal = true;
            } else {
                this.addModal = false;
            }
            this.locationToAddUpdate = detail.locationToUpdate;
            // this.formattedLocation(this.locationToAddUpdate);
            console.log("this.locationToAddUpdate : " + JSON.stringify(this.locationToAddUpdate));
            if (this.template.querySelector('c-user-profile-modal')) {
                this.template.querySelector('c-user-profile-modal[data-id="addedit_loction"]').show();
            }
        });
    }

    startSpinner() {
        this.dispatchEvent(
            new CustomEvent("loading", {})
        );
    }

    stopSpinner() {
        this.dispatchEvent(
            new CustomEvent("loaded", {})
        );
    }

    formattedLocation(locObj) {
        let locArr = [];
        for (const ele in locObj) {
            locArr.push({
                label: this.getFieldLabel(ele),
                value: locObj[ele],
                isNormalField: this.getFieldPosition(ele),
                isText: this.isTextField(ele),
                isNumeric: this.isNumericField(ele),
                isTextarea: this.isTextareaField(ele),
                isRequired: this.isRequiredField(ele)
            });
        }
        console.log("locArr : " + JSON.stringify(locArr));
    }

    getFieldLabel(field) {
        if (field == 'label') { return 'Tags'; }
        else if (field == 'value') { return 'Address'; }
        else { return field; }
    }
    getFieldPosition(field) {
        if (field == 'label' || field == 'value') {
            return true;
        } else {
            return false;
        }
    }
    isTextField(field) {
        if (field == 'label' || field == 'latitude' || field == 'longitude' || field == 'phone') {
            return true;
        } else {
            return false;
        }
    }
    isNumericField(field) {
        if (field == 'range') {
            return true;
        } else {
            return false;
        }
    }
    isTextareaField(field) {
        if (field == 'value') {
            return true;
        } else {
            return false;
        }
    }
    isRequiredField(field) {
        if (field == 'value') {
            return true;
        } else {
            return false;
        }
    }

    handleRangeUp() {
        let convRange = Number(this.locationToAddUpdate.range);
        let maxLimit = this.isCanadianDriver ? 90 : 300;
        if (convRange < maxLimit) {
            convRange++;
        }
        this.locationToAddUpdate = {
            ...this.locationToAddUpdate,
            range: convRange.toString()
        };
        console.log("After Change : " + JSON.stringify(this.locationToAddUpdate));
    }

    handleRangeDown() {
        let convRange = Number(this.locationToAddUpdate.range);
        if (convRange > 0) {
            convRange--;
        }
        this.locationToAddUpdate = {
            ...this.locationToAddUpdate,
            range: convRange.toString()
        };
        console.log("After Change : " + JSON.stringify(this.locationToAddUpdate));
    }

    handleInputChange(event) {
        let field = event.target.dataset.id;
        if (field == 'name' || field == 'street') {
            this.locationToAddUpdate = {
                ...this.locationToAddUpdate,
                [field]: event.target.value
            };
        } else if (field == 'phone') {
            if (event.target.value.trim().length > 0 && /^[0-9 \-]+$/.test(event.target.value)) {
                const match = event.target.value.replace(/\D+/g, '').match(/(\d.*){1,10}/)[0];
                const part1 = match.length > 3 ? `${match.substring(0, 3)}` : match;
                const part2 = match.length > 3 ? `-${match.substring(3, 6)}` : '';
                const part3 = match.length > 6 ? `-${match.substring(6, 10)}` : '';
                this.locationToAddUpdate = {
                    ...this.locationToAddUpdate,
                    [field]: `${part1}${part2}${part3}`
                };
            } else {
                let convPhone = event.target.value.replace(/[^\d-]/g, '');
                this.locationToAddUpdate = {
                    ...this.locationToAddUpdate,
                    [field]: convPhone
                };
            }
        } else if (field == 'state') {
            let selectedState = this.template.querySelector(`c-select2-dropdown[data-id="state"]`).selectedValue;
            this.locationToAddUpdate = {
                ...this.locationToAddUpdate,
                [field]: selectedState
            };
        } else if (field == 'city') {
            this.locationToAddUpdate = {
                ...this.locationToAddUpdate,
                [field]: event.target.value
            };
        } else if (field == 'zipCode') {
            let convCode;
            if (this.isCanadianDriver == true) {
                convCode = event.target.value
                    .replace(/[^a-zA-Z0-9]/g, '')
                    .toUpperCase()
                    .slice(0, 6);
            } else {
                convCode = event.target.value
                    .replace(/\D/g, '')
                    .slice(0, 5);
            }
            this.locationToAddUpdate = {
                ...this.locationToAddUpdate,
                [field]: convCode.toString()
            };
        } else if (field == 'range') {
            let convRange;
            if (this.isCanadianDriver == true) {
                convRange = event.target.value
                    .replace(/[^0-9]/g, '')
                    .slice(0, 2);
            } else {
                convRange = event.target.value
                    .replace(/[^0-9]/g, '')
                    .slice(0, 3);
            }
            this.locationToAddUpdate = {
                ...this.locationToAddUpdate,
                [field]: convRange
            };
        } else if (field == 'latitude' || field == 'longitude') {
            let convTude = event.target.value;
            convTude = convTude
                .replace(/[^\d.-]/g, '') // Remove non-numeric characters except dot (.) and minus (-)
                .replace(/^(-?)0+(\d)/, '$1$2') // Remove leading zeros, keeping negative sign if present
                .replace(/^(-?)\.+/g, '$10.') // Remove leading dots, keeping negative sign if present
                .replace(/-+/g, '-') // Remove multiple consecutive '-' signs, keeping only one
                // .replace(/^(-)?(.*)-/, '$1$2') // Remove '-' signs from anywhere except the beginning
                .replace(/^(.{3})-/, '$1') // Remove '-' if it's beyond the second character
                // .replace(/(\.{2,})/g, '.') // Replace more than one dot with single dot
                .replace(/^(-?)(\.)(\d*)/g, '$1$30') // Add leading zero if only dot is present
                .replace(/(\.\d*[^.]*)\./g, '$1') // Remove dots if there are more than one
                .replace(/(\.\d{6})[^.]*/g, '$1') // Limit to 6 digits after decimal point
                .replace(/^(-?\d{2})\d+(?=\.\d+)/, '$1'); // // Replace any more than 2 digits before '.' with the first 2 digits
            this.locationToAddUpdate = {
                ...this.locationToAddUpdate,
                [field]: convTude
            };
        }
        console.log('After Change : ' + JSON.stringify(this.locationToAddUpdate));
    }

    handleFocus() {
        let ele = this.template.querySelector('.mileage-input');
        let parentEle = ele.parentNode;
        let mainEle = parentEle.parentNode;
        mainEle.style.setProperty('border', '2px solid rgba(108, 108, 108, 0.43)', 'important');
    }

    handleLatLong() {
        let zipCode = this.locationToAddUpdate.zipCode;
        if (zipCode != '') {
            getCountryStateCity({ zipcode: zipCode })
                .then(result => {
                    console.log('Result from getCountryStateCity : ' + result);
                    let listOfZcode = JSON.parse(JSON.stringify(result));
                    if (listOfZcode != '') {
                        getLatLong({ zipCode })
                            .then(result => {
                                console.log('Result from getLatLong : ' + result);
                                if (result == '' || result == 'Failure') {
                                    this.dispatchEvent(
                                        new CustomEvent("toast", {
                                            detail: {
                                                type: "info",
                                                message: 'Something wrong while fetch latitude & longitude, don\'t worry go ahead.'
                                            }
                                        })
                                    )
                                } else {
                                    let convRes = JSON.parse(result);
                                    this.locationToAddUpdate = {
                                        ...this.locationToAddUpdate,
                                        latitude: parseFloat(convRes.lati.toFixed(6)).toString(),
                                        longitude: parseFloat(convRes.longi.toFixed(6)).toString()
                                    };
                                }
                            })
                            .catch(error => {
                                console.log('Error in getLatLong : ' + JSON.stringify(error));
                                this.dispatchEvent(
                                    new CustomEvent("toast", {
                                        detail: {
                                            type: "info",
                                            message: 'Something wrong while fetch latitude & longitude, don\'t worry go ahead.'
                                        }
                                    })
                                )
                            });
                    } else {
                        console.log("Invalid zip.");
                        this.dispatchEvent(
                            new CustomEvent("toast", {
                                detail: {
                                    type: "error",
                                    message: this.isCanadianDriver ? 'Please enter valid postal code.' : 'Please enter valid zip code.'
                                }
                            })
                        )
                    }
                })
                .catch(error => {
                    console.log('Error in getCountryStateCity : ' + JSON.stringify(error));
                });
        }
    }

    handleRangeLimit() {
        let ele = this.template.querySelector('.mileage-input');
        let parentEle = ele.parentNode;
        let mainEle = parentEle.parentNode;
        mainEle.style.setProperty('border', '1px solid #e4e4e4', 'important');

        let maxLimit = this.isCanadianDriver ? 90 : 300
        if (Number(this.locationToAddUpdate.range) > maxLimit) {
            this.dispatchEvent(
                new CustomEvent("toast", {
                    detail: {
                        type: "info",
                        message: `Range should not be more than ${maxLimit}.`
                    }
                })
            )
            this.locationToAddUpdate = {
                ...this.locationToAddUpdate,
                range: maxLimit.toString()
            };
        }
    }

    handleSaveLocation() {
        this.locationToAddUpdate = {
            ...this.locationToAddUpdate,
            city: this.locationToAddUpdate.city.trim(),
            street: this.locationToAddUpdate.street.trim(),
            name: this.locationToAddUpdate.name.trim()
        };
        let streetInput = this.template.querySelector('.textarea-input');
        streetInput.value = streetInput.value.trim();
        if (this.locationToAddUpdate.state == '' ||
            this.locationToAddUpdate.city == '' ||
            this.locationToAddUpdate.street == '' ||
            this.locationToAddUpdate.zipCode == '' ||
            this.locationToAddUpdate.name == ''
        ) {
            this.dispatchEvent(
                new CustomEvent("toast", {
                    detail: {
                        type: "error",
                        message: 'Please enter required fields.'
                    }
                })
            )
        } else {
            this.startSpinner();
            getCountryStateCity({ zipcode: this.locationToAddUpdate.zipCode })
                .then(result => {
                    console.log('Result from getCountryStateCity : ' + result);
                    let listOfZcode = JSON.parse(JSON.stringify(result));
                    if (listOfZcode != '') {
                        let tempState = this.statesList.find(st => st.label == this.locationToAddUpdate.state);
                        this.locationToAddUpdate.address = this.locationToAddUpdate.street + ', ' + this.locationToAddUpdate.city +
                            ', ' + tempState.value + ' ' + this.locationToAddUpdate.zipCode;
                        this.locationToAddUpdate.state = this.locationToAddUpdate.state.replace(/ /g, "_");
                        if (this.addModal == true) {
                            let mLogObj = [];
                            mLogObj.push(this.locationToAddUpdate);
                            let mLog = mLogObj.map((ele) => {
                                const o = { ...ele };
                                o.userId = this.userTriplogId;
                                delete o.city;
                                delete o.state;
                                delete o.zipCode;
                                delete o.street;
                                delete o.phone;
                                delete o.range;
                                return o;
                            });
                            console.log("mLog - " + JSON.stringify(mLog));
                            console.log('locationToAddUpdate - ' + JSON.stringify(this.locationToAddUpdate));
                            insertLocation({ locationJSONString: JSON.stringify(this.locationToAddUpdate), accountId: this.accountId, contactId: this.contactId, driverCountry: this.mapCountry, mLogArray: JSON.stringify(mLog) })
                                .then(result => {
                                    this.stopSpinner();
                                    if (result == 'Failure') {
                                        this.dispatchEvent(
                                            new CustomEvent("toast", {
                                                detail: {
                                                    type: "error",
                                                    message: 'Something wrong while adding location.'
                                                }
                                            })
                                        )
                                    } else {
                                        console.log("Location Inserted");
                                        let convRes = JSON.parse(result);
                                        this.dispatchEvent(
                                            new CustomEvent("locationadd", {
                                                detail: {
                                                    location: convRes,
                                                    locPoint: this.dataField.split('-')[0],
                                                    tripId: this.tripId
                                                }
                                            })
                                        );
                                        this.dispatchEvent(
                                            new CustomEvent("toast", {
                                                detail: {
                                                    type: "success",
                                                    message: 'Location added successfully.'
                                                }
                                            })
                                        );
                                        this.template.querySelector('c-user-profile-modal[data-id="addedit_loction"]').hide();
                                    }
                                })
                                .catch(error => {
                                    console.log("Error in insertLocation : " + JSON.stringify(error));
                                    this.stopSpinner();
                                    this.dispatchEvent(
                                        new CustomEvent("toast", {
                                            detail: {
                                                type: "error",
                                                message: 'Something wrong while adding location.'
                                            }
                                        })
                                    )
                                });
                        } else {
                            updateLocation({ locationJSONString: JSON.stringify(this.locationToAddUpdate), contactId: this.contactId, driverCountry: this.mapCountry })
                                .then(result => {
                                    this.stopSpinner();
                                    if (!result.startsWith("{")) {
                                        console.log('Fail to update location');
                                        this.dispatchEvent(
                                            new CustomEvent("toast", {
                                                detail: {
                                                    type: "error",
                                                    message: result
                                                }
                                            })
                                        )
                                    } else {
                                        console.log('Location updated');
                                        let convRes = JSON.parse(result);
                                        this.dispatchEvent(
                                            new CustomEvent("locationupdate", {
                                                detail: convRes
                                            })
                                        );
                                        this.dispatchEvent(
                                            new CustomEvent("toast", {
                                                detail: {
                                                    type: "success",
                                                    message: 'Location updated successfully.'
                                                }
                                            })
                                        );
                                        this.template.querySelector('c-user-profile-modal[data-id="addedit_loction"]').hide();
                                    }
                                })
                                .catch(error => {
                                    console.log("Error in updateLocation : " + JSON.stringify(error));
                                    this.stopSpinner();
                                    this.dispatchEvent(
                                        new CustomEvent("toast", {
                                            detail: {
                                                type: "error",
                                                message: 'Something wrong while updating location.'
                                            }
                                        })
                                    );
                                });
                        }
                    } else {
                        console.log("Invalid zip.");
                        this.stopSpinner();
                        this.dispatchEvent(
                            new CustomEvent("toast", {
                                detail: {
                                    type: "error",
                                    message: this.isCanadianDriver ? 'Please enter valid postal code.' : 'Please enter valid zip code.'
                                }
                            })
                        )
                    }
                })
                .catch(error => {
                    console.log('Error in getCountryStateCity : ' + JSON.stringify(error));
                    this.stopSpinner();
                });
        }
    }

    handleCloseLocation() {
        this.template.querySelector('c-user-profile-modal[data-id="addedit_loction"]').hide();
        this.dispatchEvent(
            new CustomEvent("close", {})
        );
    }
}