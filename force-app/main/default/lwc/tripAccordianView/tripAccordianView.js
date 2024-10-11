import { LightningElement, api, wire } from 'lwc';
import manualEntryIcons from '@salesforce/resourceUrl/manualEntryIcons';
import getLocations from '@salesforce/apex/ManualEntryController.getLocations';
import insertTrip from '@salesforce/apex/ManualEntryController.insertTrip';
import updateTrip from '@salesforce/apex/ManualEntryController.updateTrip';
import deleteTrips from '@salesforce/apex/ManualEntryController.deleteTrips';
import getDistance from '@salesforce/apex/GoogleAPICallouts.getDistance';
import MEChannel from "@salesforce/messageChannel/ManualEntry__c";
import { publish, MessageContext } from 'lightning/messageService';

export default class TripAccordianView extends LightningElement {

    @api contactId;
    @api accountId;
    @api mapCountry;
    _tripFromRow;
    recordIdToUpdate;
    toAccordian;
    @api isAddTrip;
    @api selectedMonth;
    @api monthDifference;
    @api activationDate;
    tripStartTime;
    tripOrigin;
    tripDestination;
    mapComponentFields = {};

    addLocationIcon = manualEntryIcons + '/manEntIcs/Cross.svg#cross';
    editLocationIcon = manualEntryIcons + '/manEntIcs/manual.svg#manual';
    startTimeSelectedPart;
    endTimeSelectedPart;
    _options = [];
    fromLocationToUpdate;
    toLocationToUpdate;
    sDate;
    eDate;
    isSelectedDate = true;
    isDeletable;
    dateFormat = 'mm/dd/yy';

    @wire(MessageContext)
    messageContext;

    @api
    get tripFields() {
        return this._tripFromRow;
    }

    set tripFields(member) {
        this._tripFromRow = {
            id: member.id ? member.id : '',
            tripDate: member.tripDate,
            startTime: member.startTime,
            endTime: member.endTime,
            origin: member.origin,
            destination: member.destination,
            originName: member.originName,
            destinationName: member.destinationName,
            mileage: member.mileage,
            tags: member.tags,
            notes: member.notes,
        };
        console.log("_tripFromRow : " + JSON.stringify(this._tripFromRow));
        this.isDeletable = member.isDeltetable;
        this.toAccordian = member.isEditMode;
        this.recordIdToUpdate = this._tripFromRow.id;
        this.tripStartTime = this._tripFromRow.startTime;
        this.tripOrigin = this._tripFromRow.originName == '' ? this._tripFromRow.origin : this._tripFromRow.originName;
        this.tripDestination = this._tripFromRow.destinationName == '' ? this._tripFromRow.destination : this._tripFromRow.destinationName;
        /* For map component */
        // this.mapComponentFields.fromLatitude = member.fromLat == null ? undefined : member.fromLat;
        // this.mapComponentFields.fromLongitude = member.fromLong == null ? undefined : member.fromLong;
        // this.mapComponentFields.toLatitude = member.toLat == null ? undefined : member.toLat;
        // this.mapComponentFields.toLongitude = member.toLong == null ? undefined : member.toLong;
        // this.mapComponentFields.timeZone = member.timeZone == null ? undefined : member.timeZone;
        // this.mapComponentFields.wayPoints = member.wayPoints == null ? undefined : member.wayPoints;
        // this.mapComponentFields.tripId = member.id == '' ? '' : parseInt(member.id);
        // this.mapComponentFields.triplogKey = member.triplogApi == null ? '' : member.triplogApi;
        /* For map component */
    }

    @api
    get allLocations() {
        return this._options;
    }

    set allLocations(member) {
        this._options = member;
    }

    renderedCallback() {
        if (this.toAccordian == true) {
            if (this.tripOrigin != '') {
                this.fromLocationToUpdate = this.template.querySelector(`c-select2-dropdown[data-id="from_dropdown"]`).getLocationId(this.tripOrigin);
            }
            if (this.tripDestination != '') {
                this.toLocationToUpdate = this.template.querySelector(`c-select2-dropdown[data-id="to_dropdown"]`).getLocationId(this.tripDestination);
            }

            /* For map component */
            // if(this.template.querySelector('c-map-creation-component') != null) {
            //     this.template.querySelector('c-map-creation-component').mapAccess();
            // }
            /* For map component */

            let allsearchableDD = this.template.querySelectorAll('c-select2-dropdown');
            allsearchableDD.forEach(element => {
                element.setDynamicContentStyle('8rem', '98%');
            });
        }
    }

    connectedCallback() {
        let actDate = new Date(this.activationDate);
        let currentDate = new Date();
        let tempDate = new Date();
        this.eDate = this.monthDifference == 0 ? currentDate : new Date(tempDate.setMonth(currentDate.getMonth() - (this.monthDifference - 1), 0));
        if(actDate.getFullYear() < currentDate.getFullYear()) {
            this.sDate = new Date(currentDate.getFullYear(), currentDate.getMonth() - 2, 1);
        } else {
            if(actDate.getMonth() <= (currentDate.getMonth() - 2)) {
                this.sDate = new Date(currentDate.getFullYear(), currentDate.getMonth() - 2, 1);
            } else {
                this.sDate = new Date(currentDate.getFullYear(), actDate.getMonth(), actDate.getDate());
            }
        }
        getLocations({ contactId: this.contactId, driverCountry: this.mapCountry })
            .then(result => {
                let convRes = JSON.parse(result);
                console.log('Result from getLocations : ' + JSON.stringify(convRes));
                console.log('convRes.length : ' + convRes.length);
                let locations = [];
                convRes.forEach(element => {
                    if (element.address !== '' && element.address !== undefined) {
                        locations.push({
                            id: element.id,
                            label: element.name != '' ? element.name : element.address,
                            value: element.address,
                            locName: element.name,
                            latitude: element.latitude != '' ? (parseFloat(element.latitude).toFixed(6)).toString() : '',
                            longitude: element.longitude != '' ? (parseFloat(element.longitude).toFixed(6)).toString() : '',
                            range: element.range ? element.range : '',
                            phone: element.phone ? element.phone : '',
                            state: element.state.replace(/_/g, " "),
                            city: element.city,
                            street: element.street,
                            zipCode: element.zipCode
                        });
                    }
                });
                this._options = JSON.parse(JSON.stringify(this.removeDuplicate(locations, it => it.locName)));
                // this._options = JSON.parse(JSON.stringify(locations));
                console.log('this._options : ' + JSON.stringify(this._options));
                console.log('this._options.length : ' + this._options.length);
            })
            .catch(error => {
                console.log("Error in getLocations : " + JSON.stringify(error));
            });
    }

    removeDuplicate(data, key) {
        const nonEmptyKeyElements = data.filter(x => key(x) !== '');
        const emptyKeyElements = data.filter(x => key(x) === '');
        const uniqueNonEmptyKeyElements = [
            ...new Map(
                nonEmptyKeyElements.map(x => [key(x), x])
            ).values()
        ];
        return [...uniqueNonEmptyKeyElements, ...emptyKeyElements];
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


    handleInputChange(event) {
        let fieldName = event.target.dataset.field;
        if (fieldName == 'origin') {
            let fromLocation = this.template.querySelector(`c-select2-dropdown[data-id="from_dropdown"]`).selectedValue;
            this.fromLocationToUpdate = this.template.querySelector(`c-select2-dropdown[data-id="from_dropdown"]`).getLocationId(fromLocation);
            this.tripOrigin = this.fromLocationToUpdate.locName == '' ? fromLocation : this.fromLocationToUpdate.locName;
            this._tripFromRow = {
                ...this._tripFromRow,
                [fieldName]: this.fromLocationToUpdate.value,
                originName: this.fromLocationToUpdate.locName
            };
            console.log("From Location : " + JSON.stringify(this.fromLocationToUpdate));
        }
        if (fieldName == 'destination') {
            let toLocation = this.template.querySelector(`c-select2-dropdown[data-id="to_dropdown"]`).selectedValue;
            this.toLocationToUpdate = this.template.querySelector(`c-select2-dropdown[data-id="to_dropdown"]`).getLocationId(toLocation);
            this.tripDestination = this.toLocationToUpdate.locName == '' ? toLocation : this.toLocationToUpdate.locName;
            this._tripFromRow = {
                ...this._tripFromRow,
                [fieldName]: this.toLocationToUpdate.value,
                destinationName: this.toLocationToUpdate.locName
            };
            console.log("To Location : " + JSON.stringify(this.toLocationToUpdate));
        }
        if (fieldName == 'tripDate') {
            let convertedDate = event.detail;
            console.log('convertedDate : ' + convertedDate);
            let formattedDate;
            if (convertedDate) {
                var dateParts = convertedDate.split('/');
                var month = dateParts[0];
                var day = dateParts[1];
                var year = parseInt(dateParts[2]) % 100;
                formattedDate = month + '/' + day + '/' + year;
            } else {
                formattedDate = '';
            }
            this._tripFromRow = {
                ...this._tripFromRow,
                [fieldName]: formattedDate
            };
        }
        if (fieldName == 'startTime' || fieldName == 'endTime') {
            this._tripFromRow = {
                ...this._tripFromRow,
                [fieldName]: event.target.value
            };
        }
        if (fieldName == 'mileage') {
            let mileage = event.target.value;
            mileage = mileage
                .replace(/[^\d.]/g, '') // Remove non-numeric characters except dot (.)
                .replace(/^0+(\d)/, '$1') // Remove leading zeros
                .replace(/^\.+/, '') // Remove leading dots
                .replace(/\.{2,}/g, '.') // Remove more than one dot
                .replace(/^(\.\d*)\./g, '$1') // Remove leading dots before numbers
                .replace(/(\.\d*[^.]*)\./g, '$1') // Remove dots if there are more than one
                .replace(/(\.\d{2})[^.]*/g, '$1'); // // Limit to 2 digits after decimal point
            this._tripFromRow = {
                ...this._tripFromRow,
                [fieldName]: mileage.toString()
            };
        }
        if (fieldName == 'tags' || fieldName == 'notes') {
            this._tripFromRow = {
                ...this._tripFromRow,
                [fieldName]: event.target.value
            };
        }
        console.log("After Change : " + JSON.stringify(this._tripFromRow));
    }

    handleFocus(event) {
        let fieldName = event.target.dataset.field;
        let ele = this.template.querySelector(`.mileage-input[data-field=${fieldName}]`);
        let parentEle = ele.parentNode;
        let mainEle = parentEle.parentNode;
        mainEle.style.setProperty('border', '2px solid rgba(108, 108, 108, 0.43)', 'important');
    }

    handleOffFocus(event) {
        let fieldName = event.target.dataset.field;
        let ele = this.template.querySelector(`.mileage-input[data-field=${fieldName}]`);
        let parentEle = ele.parentNode;
        let mainEle = parentEle.parentNode;
        mainEle.style.setProperty('border', '1px solid #e4e4e4', 'important');

        if (fieldName != 'mileage') {
            if (/^(0[1-9]|1[0-2]|[1-9]):([0-5][0-9]|[0-9]) (AM|PM|am|pm|Am|aM|Pm|pM)$/.test(this._tripFromRow[event.target.dataset.field])) {
                let convTime = this.adjustTime(event.target.value);
                this._tripFromRow = {
                    ...this._tripFromRow,
                    [event.target.dataset.field]: convTime
                };
            }
            // else {
            //     if(event.target.dataset.id == 'startTimeInput') {
            //         this._tripFromRow = {
            //             ...this._tripFromRow,
            //             [event.target.dataset.field]: this.tripStartTime
            //         };
            //     }
            //     if (event.target.dataset.id == 'endTimeInput') {
            //         this._tripFromRow = {
            //             ...this._tripFromRow,
            //             [event.target.dataset.field]: '08:00 AM'
            //         };
            //     }
            // }
            console.log("After Change : " + JSON.stringify(this._tripFromRow));
        }
    }

    adjustTime(time) {
        let splitedTime = time.split(' ');
        let hour = parseInt(splitedTime[0].split(':')[0]);
        let min = parseInt(splitedTime[0].split(':')[1]);
        let period = splitedTime[1];
        if (period == 'am' || period == 'Am' || period == 'aM' || period == 'AM') {
            period = "AM";
        } else if (period == 'pm' || period == 'Pm' || period == 'pM' || period == 'PM') {
            period = "PM";
        }
        return ((hour < 10 ? "0" : "") + hour + ":" + (min < 10 ? "0" : "") + min + " " + period);
    }

    handleStartTime(event) {
        var cursorPosition = event.target.selectionStart;
        if (cursorPosition >= 0 && cursorPosition <= 2) {
            this.startTimeSelectedPart = "hour";
        } else if (cursorPosition >= 3 && cursorPosition <= 5) {
            this.startTimeSelectedPart = "minute";
        } else {
            this.startTimeSelectedPart = "period";
        }
        console.log("selected Part : " + this.startTimeSelectedPart);
    }
    handleEndTime(event) {
        var cursorPosition = event.target.selectionStart;
        if (cursorPosition >= 0 && cursorPosition <= 2) {
            this.endTimeSelectedPart = "hour";
        } else if (cursorPosition >= 3 && cursorPosition <= 5) {
            this.endTimeSelectedPart = "minute";
        } else {
            this.endTimeSelectedPart = "period";
        }
    }

    handleStartTimeUp() {
        var time = this._tripFromRow.startTime != '' ? this._tripFromRow.startTime : '08:00 AM';
        var splitTime = time.split(" ");
        var hourMin = splitTime[0].split(":");
        var hour = parseInt(hourMin[0]);
        var minute = parseInt(hourMin[1]);
        var period = splitTime[1];
        switch (this.startTimeSelectedPart) {
            case "hour":
                hour = (hour + 1) % 12 || 12;
                break;
            case "minute":
                minute = (minute + 1) % 60;
                break;
            case "period":
                period = period === "AM" ? "PM" : "AM";
                break;
        }
        this._tripFromRow = {
            ...this._tripFromRow,
            startTime: ((hour < 10 ? "0" : "") + hour + ":" + (minute < 10 ? "0" : "") + minute + " " + period)
        };
        console.log("After Change : " + JSON.stringify(this._tripFromRow));
    }
    handleEndTimeUp() {
        var time = this._tripFromRow.endTime != '' ? this._tripFromRow.endTime : '08:00 AM';
        var splitTime = time.split(" ");
        var hourMin = splitTime[0].split(":");
        var hour = parseInt(hourMin[0]);
        var minute = parseInt(hourMin[1]);
        var period = splitTime[1];
        switch (this.endTimeSelectedPart) {
            case "hour":
                hour = (hour + 1) % 12 || 12;
                break;
            case "minute":
                minute = (minute + 1) % 60;
                break;
            case "period":
                period = period === "AM" ? "PM" : "AM";
                break;
        }
        this._tripFromRow = {
            ...this._tripFromRow,
            endTime: ((hour < 10 ? "0" : "") + hour + ":" + (minute < 10 ? "0" : "") + minute + " " + period)
        };
        console.log("After Change : " + JSON.stringify(this._tripFromRow));
    }

    handleStartTimeDown() {
        var time = this._tripFromRow.startTime != '' ? this._tripFromRow.startTime : '08:00 AM';
        var splitTime = time.split(" ");
        var hourMin = splitTime[0].split(":");
        var hour = parseInt(hourMin[0]);
        var minute = parseInt(hourMin[1]);
        var period = splitTime[1];
        switch (this.startTimeSelectedPart) {
            case "hour":
                hour = (hour - 1) % 12 || 12;
                if (hour === 0) hour = 12;
                break;
            case "minute":
                minute = (minute - 1 + 60) % 60;
                break;
            case "period":
                period = period === "AM" ? "PM" : "AM";
                break;
        }
        this._tripFromRow = {
            ...this._tripFromRow,
            startTime: ((hour < 10 ? "0" : "") + hour + ":" + (minute < 10 ? "0" : "") + minute + " " + period)
        };
        console.log("After Change : " + JSON.stringify(this._tripFromRow));
    }
    handleEndTimeDown() {
        var time = this._tripFromRow.endTime != '' ? this._tripFromRow.endTime : '08:00 AM';
        var splitTime = time.split(" ");
        var hourMin = splitTime[0].split(":");
        var hour = parseInt(hourMin[0]);
        var minute = parseInt(hourMin[1]);
        var period = splitTime[1];
        switch (this.endTimeSelectedPart) {
            case "hour":
                hour = (hour - 1) % 12 || 12;
                if (hour === 0) hour = 12;
                break;
            case "minute":
                minute = (minute - 1 + 60) % 60;
                break;
            case "period":
                period = period === "AM" ? "PM" : "AM";
                break;
        }
        this._tripFromRow = {
            ...this._tripFromRow,
            endTime: ((hour < 10 ? "0" : "") + hour + ":" + (minute < 10 ? "0" : "") + minute + " " + period)
        };
        console.log("After Change : " + JSON.stringify(this._tripFromRow));
    }

    handleMileageUp() {
        if (this._tripFromRow.mileage != "") {
            let convMileage = parseFloat(this._tripFromRow.mileage);
            if (Number.isInteger(convMileage)) {
                convMileage++;
            } else {
                convMileage = (convMileage + 0.01).toFixed(2);
            }
            this._tripFromRow = {
                ...this._tripFromRow,
                mileage: convMileage.toString()
            };
        }
        console.log("After Change : " + JSON.stringify(this._tripFromRow));
    }

    handleMileageDown() {
        if (this._tripFromRow.mileage != "") {
            let convMileage = parseFloat(this._tripFromRow.mileage);
            if (convMileage > 0) {
                if (Number.isInteger(convMileage)) {
                    convMileage--;
                } else {
                    convMileage = (convMileage - 0.01).toFixed(2);
                }
                // convMileage--;
            }
            this._tripFromRow = {
                ...this._tripFromRow,
                mileage: convMileage.toString()
            };
        }
        console.log("After Change : " + JSON.stringify(this._tripFromRow));
    }

    handleCreateTrip() {
        this._tripFromRow = {
            ...this._tripFromRow,
            tags: this._tripFromRow.tags.trim(),
            notes: this._tripFromRow.notes.trim()
        };
        let notesInput = this.template.querySelector('.textarea-input');
        notesInput.value = notesInput.value.trim();
        let convStartTime = new Date("2000-01-01 " + this._tripFromRow.startTime);
        let convEndTime = new Date("2000-01-01 " + this._tripFromRow.endTime);
        if (this._tripFromRow.tripDate == '' || this._tripFromRow.origin == '' || this._tripFromRow.destination == '' || this._tripFromRow.mileage == '') {
            console.log("Error of mandatory.");
            this.dispatchEvent(
                new CustomEvent("toast", {
                    detail: {
                        type: "error",
                        message: 'Please enter required fields.'
                    }
                })
            );
        } else if (this._tripFromRow.startTime != '' && this._tripFromRow.endTime != '' && convEndTime < convStartTime) {
            console.log('Error of time.');
            this.dispatchEvent(
                new CustomEvent("toast", {
                    detail: {
                        type: "error",
                        message: 'End time should be greater than start time.'
                    }
                })
            );
        } else {
            console.log('Trip at Save : ' + JSON.stringify(this._tripFromRow));
            this.startSpinner();
            if (this.isAddTrip == true) {
                let selectedDate = new Date(`${this.selectedMonth.label} 1, 2000`);
                insertTrip({
                    contactId: this.contactId,
                    tripToInsert: JSON.stringify(this._tripFromRow),
                    selectedMonth: (selectedDate).getMonth() + 1
                })
                    .then(result => {
                        console.log("Result from Create Trip : " + result);
                        this.stopSpinner();
                        if (!result.startsWith("{")) {
                            this.dispatchEvent(
                                new CustomEvent("toast", {
                                    detail: {
                                        type: "error",
                                        message: result
                                    }
                                })
                            );
                        } else {
                            console.log('Trip Inserted');
                            let convRes = JSON.parse(result);
                            this.dispatchEvent(
                                new CustomEvent("tripinsert", {
                                    detail: {
                                        tripNew: convRes,
                                        tripType: this.isAddTrip
                                    }
                                })
                            );
                            this.handleCloseTrip();
                            this.dispatchEvent(
                                new CustomEvent("toast", {
                                    detail: {
                                        type: "success",
                                        message: 'Trip created successfully.'
                                    }
                                })
                            )
                        }
                    })
                    .catch(error => {
                        console.log("Error in create Trip : " + JSON.stringify(error));
                        this.stopSpinner();
                        this.dispatchEvent(
                            new CustomEvent("toast", {
                                detail: {
                                    type: "error",
                                    message: 'Something wrong while creating trip.'
                                }
                            })
                        );
                    });
            } else {
                updateTrip({
                    contactId: this.contactId,
                    tripToUpdate: JSON.stringify(this._tripFromRow)
                })
                    .then(result => {
                        console.log("Result from Update Trip : " + result);
                        this.stopSpinner();
                        if (!result.startsWith("{")) {
                            console.log('Fail to update trip');
                            this.stopSpinner();
                            this.dispatchEvent(
                                new CustomEvent("toast", {
                                    detail: {
                                        type: "error",
                                        message: result
                                    }
                                })
                            )
                        } else {
                            console.log('Trip updated');
                            let convRes = JSON.parse(result);
                            this.dispatchEvent(
                                new CustomEvent("tripupdate", {
                                    detail: convRes
                                })
                            );
                            this.handleCloseTrip();
                            this.dispatchEvent(
                                new CustomEvent("toast", {
                                    detail: {
                                        type: "success",
                                        message: 'Trip updated successfully.'
                                    }
                                })
                            );
                        }
                    })
                    .catch(error => {
                        console.log("Error in create Trip : " + JSON.stringify(error));
                        this.stopSpinner();
                        this.dispatchEvent(
                            new CustomEvent("toast", {
                                detail: {
                                    type: "error",
                                    message: 'Something wrong while updating trip.'
                                }
                            })
                        );
                    });
            }
        }
    }

    handleShowModal(event) {
        const dataField = event.currentTarget.dataset.fieldname;
        console.log("dataField : " + dataField);
        let detail = {
            contactId: this.contactId,
            dataField
        };
        if (dataField.split('-')[1] == 'edit') {
            let tempLoc = {};
            if (dataField.split('-')[0] == 'from') {
                let selFromLoc = this.template.querySelector(`c-select2-dropdown[data-id="from_dropdown"]`).selectedValue;
                if (selFromLoc != '') {
                    tempLoc.id = this.fromLocationToUpdate.id;
                    tempLoc.address = this.fromLocationToUpdate.value ? this.fromLocationToUpdate.value : '';
                    tempLoc.name = this.fromLocationToUpdate.locName ? this.fromLocationToUpdate.locName : '';
                    tempLoc.phone = this.fromLocationToUpdate.phone ? this.fromLocationToUpdate.phone : '';
                    tempLoc.latitude = this.fromLocationToUpdate.latitude ? this.fromLocationToUpdate.latitude.toString() : '';
                    tempLoc.longitude = this.fromLocationToUpdate.longitude ? this.fromLocationToUpdate.longitude.toString() : '';
                    tempLoc.range = this.fromLocationToUpdate.range ? this.fromLocationToUpdate.range.toString() : '';
                    tempLoc.state = this.fromLocationToUpdate.state ? this.fromLocationToUpdate.state.toString() : '';
                    tempLoc.city = this.fromLocationToUpdate.city ? this.fromLocationToUpdate.city.toString() : '';
                    tempLoc.street = this.fromLocationToUpdate.street ? this.fromLocationToUpdate.street.toString() : '';
                    tempLoc.zipCode = this.fromLocationToUpdate.zipCode ? this.fromLocationToUpdate.zipCode.toString() : '';
                    detail.locationToUpdate = tempLoc;
                    publish(this.messageContext, MEChannel, detail);
                } else {
                    this.dispatchEvent(
                        new CustomEvent("toast", {
                            detail: {
                                type: "info",
                                message: 'Please select from location.'
                            }
                        })
                    )
                }
            } else {
                let selToLoc = this.template.querySelector(`c-select2-dropdown[data-id="to_dropdown"]`).selectedValue;
                if (selToLoc != '') {
                    tempLoc.id = this.toLocationToUpdate.id;
                    tempLoc.address = this.toLocationToUpdate.value ? this.toLocationToUpdate.value : '';
                    tempLoc.name = this.toLocationToUpdate.locName ? this.toLocationToUpdate.locName : '';
                    tempLoc.phone = this.toLocationToUpdate.phone ? this.toLocationToUpdate.phone : '';
                    tempLoc.latitude = this.toLocationToUpdate.latitude ? this.toLocationToUpdate.latitude.toString() : '';
                    tempLoc.longitude = this.toLocationToUpdate.longitude ? this.toLocationToUpdate.longitude.toString() : '';
                    tempLoc.range = this.toLocationToUpdate.range ? this.toLocationToUpdate.range.toString() : '';
                    tempLoc.state = this.toLocationToUpdate.state ? this.toLocationToUpdate.state.toString() : '';
                    tempLoc.city = this.toLocationToUpdate.city ? this.toLocationToUpdate.city.toString() : '';
                    tempLoc.street = this.toLocationToUpdate.street ? this.toLocationToUpdate.street.toString() : '';
                    tempLoc.zipCode = this.toLocationToUpdate.zipCode ? this.toLocationToUpdate.zipCode.toString() : '';
                    detail.locationToUpdate = tempLoc;
                    publish(this.messageContext, MEChannel, detail);
                } else {
                    this.dispatchEvent(
                        new CustomEvent("toast", {
                            detail: {
                                type: "info",
                                message: 'Please select to location.'
                            }
                        })
                    )
                }
            }
        } else {
            detail.locationToUpdate = {
                name: '',
                address: '',
                state: '',
                city: '',
                zipCode: '',
                street: '',
                phone: '',
                latitude: '',
                longitude: '',
                range: '',
                activity: 'Business'
            };
            if (this.isAddTrip == true) {
                detail.tripId = "newOne"
            } else {
                detail.tripId = this._tripFromRow.id
            }
            publish(this.messageContext, MEChannel, detail);
        }
    }

    calculateMileage() {
        if (this._tripFromRow.origin == '' || this._tripFromRow.destination == '') {
            this.dispatchEvent(
                new CustomEvent("toast", {
                    detail: {
                        type: "error",
                        message: 'Select both from and to locations.'
                    }
                })
            );
        } else {
            let objToPass = {
                origins: this._tripFromRow.origin,
                destinations: this._tripFromRow.destination
            };
            getDistance({ address: JSON.stringify(objToPass) })
                .then(result => {
                    if (result == '' || result == 'Failure') {
                        console.log('Result from getDistance : ' + result);
                        this.dispatchEvent(
                            new CustomEvent("toast", {
                                detail: {
                                    type: "info",
                                    message: 'Something went wrong while calculating your mileage. Please enter your mileage manually.'
                                }
                            })
                        );
                    } else {
                        console.log('Result from getDistance : ' + result);
                        let convRes = JSON.parse(result);
                        if (this.isAddTrip == true) {
                            this.dispatchEvent(
                                new CustomEvent("distance", {
                                    detail: {
                                        res: convRes,
                                        origin: this._tripFromRow.originName == '' ? (this._tripFromRow.origin == '' ? '' : this._tripFromRow.origin) : this._tripFromRow.originName,
                                        destination: this._tripFromRow.destinationName == '' ? (this._tripFromRow.destination == '' ? '' : this._tripFromRow.destination) : this._tripFromRow.destinationName,
                                        tripId: "newOne"
                                    }
                                })
                            );
                        } else {
                            this.dispatchEvent(
                                new CustomEvent("distance", {
                                    detail: {
                                        res: convRes,
                                        origin: this._tripFromRow.originName == '' ? (this._tripFromRow.origin == '' ? '' : this._tripFromRow.origin) : this._tripFromRow.originName,
                                        destination: this._tripFromRow.destinationName == '' ? (this._tripFromRow.destination == '' ? '' : this._tripFromRow.destination) : this._tripFromRow.destinationName,
                                        tripId: this._tripFromRow.id
                                    }
                                })
                            );
                        }
                    }
                })
                .catch(error => {
                    console.log('Error in getDistance : ' + JSON.stringify(error));
                    this.dispatchEvent(
                        new CustomEvent("toast", {
                            detail: {
                                type: "info",
                                message: 'Something went wrong while calculating your mileage. Please enter your mileage manually.'
                            }
                        })
                    );
                });
        }
    }

    @api
    fillMileage(calculatedMileage, calculatedTime) {
        console.log('typeof calculatedTime : ' + typeof (calculatedTime));
        let calculatedEndTime;
        if (calculatedTime > 0) {
            let sTimeToPass = this._tripFromRow.startTime == '' ? '08:00 AM' : this._tripFromRow.startTime;
            calculatedEndTime = this.calculateEndTime(sTimeToPass, calculatedTime);
        }
        this._tripFromRow = {
            ...this._tripFromRow,
            mileage: calculatedMileage,
            startTime: calculatedTime > 0 ? (this._tripFromRow.startTime == '' ? '08:00 AM' : this._tripFromRow.startTime) : this._tripFromRow.startTime,
            endTime: calculatedTime > 0 ? calculatedEndTime : this._tripFromRow.endTime,
        };
    }

    calculateEndTime(timeStr, minutesToAdd) {
        // Parse the time string
        var [time, period] = timeStr.trim().split(' ');
        var [hours, minutes] = time.split(':').map(Number);
        // Convert to 24-hour format
        if (period.toLowerCase() === 'pm' && hours !== 12) {
            hours += 12;
        }
        if (period.toLowerCase() === 'am' && hours === 12) {
            hours = 0;
        }
        var tempHours = hours;
        while (minutesToAdd >= 60) {
            tempHours += 1;
            if (tempHours == 24) {
                tempHours = 0;
            }
            minutesToAdd -= 60;
        }
        var tempMin = minutes;
        while (minutesToAdd != 0) {
            tempMin += 1;
            if (tempMin == 60) {
                tempMin = 0;
                tempHours++;
            }
            minutesToAdd -= 1;
        }
        // Create a Date object and add minutes
        var date = new Date();
        date.setHours(tempHours);
        date.setMinutes(tempMin);
        // Convert back to 12-hour format
        var newHours = date.getHours();
        var newMinutes = date.getMinutes();
        var newPeriod = newHours >= 12 ? 'PM' : 'AM';
        newHours = newHours % 12;
        newHours = newHours ? (newHours < 10 ? '0' + newHours : newHours) : 12; // the hour '0' should be '12'
        newMinutes = newMinutes < 10 ? '0' + newMinutes : newMinutes;
        return `${newHours}:${newMinutes} ${newPeriod}`;
    }

    @api
    fillLocation(info) {
        let locToSelect = this._options.find(record => record.id == info.location.Id);
        console.log("info.locPoint : " + info.locPoint);
        console.log("locToSelect : " + JSON.stringify(locToSelect));
        if (info.locPoint == 'from') {
            this.fromLocationToUpdate = locToSelect;
            this.tripOrigin = locToSelect.locName == '' ? locToSelect.value : locToSelect.locName;
            this._tripFromRow = {
                ...this._tripFromRow,
                origin: this.fromLocationToUpdate.value,
                originName: this.fromLocationToUpdate.locName
            };
        } else if (info.locPoint == 'to') {
            this.toLocationToUpdate = locToSelect;
            this.tripDestination = locToSelect.locName == '' ? locToSelect.value : locToSelect.locName;
            this._tripFromRow = {
                ...this._tripFromRow,
                destination: this.toLocationToUpdate.value,
                destinationName: this.toLocationToUpdate.locName
            };
        }
    }

    @api
    dynamicLocAdd(location) {
        let newLoc = {
            id: location.Id,
            label: location.Name,
            value: location.Location_Address__c,
            locName: location.Name,
            latitude: location.Latitude,
            longitude: location.Longitude,
            range: location.Range__c == null ? '' : location.Range__c,
            phone: location.Phone__c,
            state: location.Address__StateCode__s.replace(/_/g, " "),
            city: location.Address__City__s,
            zipCode: location.Address__PostalCode__s,
            street: location.Address__Street__s
        }
        this._options.push(newLoc);
    }

    @api
    dynamicLocUpdt(location) {
        let updtLoc = {
            id: location.Id,
            label: location.Name,
            value: location.Location_Address__c,
            locName: location.Name,
            latitude: location.Latitude,
            longitude: location.Longitude,
            range: location.Range__c == null ? '' : location.Range__c,
            phone: location.Phone__c,
            state: location.Address__StateCode__s.replace(/_/g, " "),
            city: location.Address__City__s,
            zipCode: location.Address__PostalCode__s,
            street: location.Address__Street__s
        }
        let index = this._options.findIndex(record => record.id === updtLoc.id);
        if (index !== -1) {
            this._options[index] = updtLoc;
        }
        if (this.fromLocationToUpdate && this.fromLocationToUpdate.id == updtLoc.id) {
            this.fromLocationToUpdate = updtLoc;
            this.tripOrigin = updtLoc.locName == '' ? updtLoc.value : updtLoc.locName;
        }
        if (this.toLocationToUpdate && this.toLocationToUpdate.id == updtLoc.id) {
            this.toLocationToUpdate = updtLoc;
            this.tripDestination = updtLoc.locName == '' ? updtLoc.value : updtLoc.locName;
        }
    }

    handleDeleteTrip() {
        this.dispatchEvent(
            new CustomEvent("clearmileage", {
                detail: this._tripFromRow
            })
        );
    }

    @api
    clearTrip(mileageId) {
        this.startSpinner();
        let tripToClear = '';
        tripToClear = tripToClear.length == 0 ? (tripToClear + mileageId) : (tripToClear + ',' + mileageId);
        deleteTrips({ tripIds: JSON.stringify(tripToClear) })
            .then(result => {
                this.stopSpinner();
                if (result == 'Failure') {
                    this.dispatchEvent(
                        new CustomEvent("toast", {
                            detail: {
                                type: "error",
                                message: 'Something wrong while deleting trip.'
                            }
                        })
                    );
                } else {
                    this.dispatchEvent(
                        new CustomEvent("tripdelete", {
                            detail: {
                                tripDelete: mileageId
                            }
                        })
                    );
                    this.handleCloseTrip();
                    this.dispatchEvent(
                        new CustomEvent("toast", {
                            detail: {
                                type: "success",
                                message: 'Trip deleted successfully.'
                            }
                        })
                    );
                }
            })
            .catch(error => {
                this.stopSpinner();
                console.log("Error from deleteTrips : " + JSON.stringify(error));
                this.dispatchEvent(
                    new CustomEvent("toast", {
                        detail: {
                            type: "error",
                            message: 'Something wrong while deleting trip.'
                        }
                    })
                );
            });
    }

    handleCloseTrip() {
        if (this.isAddTrip == true) {
            this.dispatchEvent(
                new CustomEvent("hidetrip", {
                    detail: {
                        tripType: this.isAddTrip
                    }
                })
            );
            this.isAddTrip = false;
        } else {
            this.dispatchEvent(
                new CustomEvent("hidetrip", {
                    detail: {
                        tripType: this.isAddTrip,
                        tripId: this.recordIdToUpdate
                    }
                })
            );
        }
    }

}