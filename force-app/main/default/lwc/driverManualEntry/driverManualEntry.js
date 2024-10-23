import { LightningElement, api } from 'lwc';
import getTrips from '@salesforce/apex/ManualEntryController.getTrips';
import deleteTrips from '@salesforce/apex/ManualEntryController.deleteTrips';
import resourceImage from '@salesforce/resourceUrl/mBurseCss';

export default class DriverManualEntry extends LightningElement {

    @api contactId;
    @api accountId;
    @api userTriplogId;
    @api mapCountry;
    modalclass = 'slds-modal slds-is-fixed slds-fade-in-open animate__animated animate__fadeInTopLeft';
    headerclass = 'slds-modal__header header-preview hedear-style_class header_style';
    modalcontentstyle = 'slds-modal__content slds-p-left_medium slds-p-right_medium slds-p-bottom_medium slds-p-top_small content_div_scroll , slds-modal__content slds-p-left_medium slds-p-right_medium slds-p-bottom_medium slds-p-top_small overflow-visible';
    styleheader = 'slds-modal__container container_style_1';
    subheaderClass = 'slds-modal__title slds-hyphenate hedear-style_class';
    closebtnclass = 'close-notify';
    mileageConfirmMessage;
    calculatedMileage;
    calculatedTime;
    tripToFillMileage;
    distanceTripOrigin;
    distanceTripDestination;
    deleteTripDate;
    deleteTripOrigin;
    deleteTripDestination;
    deleteTripMileage;
    tripToDelete;
    showNewTrip = true;
    noTrips = false;
    addTrip = false;
    norecordMessagenew = 'There is no trip data available';
    tableClass = 'slds-table slds-table_cell-buffer slds-table_striped fixed-table';
    monthDifference;
    headerData = [
        { fieldlabel: 'Trip date', fieldName: 'tripDate', fieldType: 'Date', isUp: false, isDown: false },
        { fieldlabel: 'Origin', fieldName: 'originName', fieldType: 'String', isUp: false, isDown: false },
        { fieldlabel: 'Destination', fieldName: 'destinationName', fieldType: 'String', isUp: false, isDown: false },
        { fieldlabel: 'Mileage', fieldName: 'mileage', fieldType: 'Decimal', isUp: false, isDown: false },
        { fieldlabel: 'Notes', fieldName: 'notes', fieldType: 'String', isUp: false, isDown: false },
        { fieldlabel: 'Tags', fieldName: 'tags', fieldType: 'String', isUp: false, isDown: false }
    ];
    originalTrips = [];
    tripsForOperations = [];
    _tripsToDisplay = [];
    tripDetail = {};
    tripLogApi;
    monthList = [];
    selectedMonth;
    sortDirection = 'desc';
    colName = '';
    colType = '';
    pagePreviousClass = 'cPadding';
    pageNextClass = 'cPadding';
    searchVisible = true;
    isSearchEnable = false;
    searchkey = '';
    isExportTotalVisible = false;
    isMainCheckBoxVisible;
    isDeleteAllVisivble = false;
    mileagesToDelete;
    isMassDeleteMode = false;
    /* Pagination */
    totalRecords = 0;
    pageSize = 20;
    totalPages;
    pageNumber = 1;
    pages = [];
    paginate = [];
    shortPaginate = 10;
    moveNext = 3;
    moveBefore = 7;
    maxPage = 10;
    /* Pagination */
    searchIcon = resourceImage + '/mburse/assets/mBurse-Icons/Vector.png';
    totalMileage = 0.00;
    displayMileage = 0.00;
    exportFields = [
        {
            "name": "tracingStyle",
            "label": "Tracking method"
        },
        {
            "name": "day",
            "label": "Day Of Week"
        },
        {
            "name": "tripDate",
            "label": "Trip Date"
        }, {
            "name": "startTime",
            "label": "Start Time"
        }, {
            "name": "endTime",
            "label": "End Time"
        }, {
            "name": "originName",
            "label": "Origin Name"
        }, {
            "name": "origin",
            "label": "Origin Address"
        }, {
            "name": "destinationName",
            "label": "Destination Name"
        }, {
            "name": "destination",
            "label": "Destination Address"
        },{
            "name": "createdDate",
            "label": "Date Entered"
        },{
            "name": "processDate",
            "label": "Date Processed"
        }, {
            "name": "processBy",
            "label": "Processed By"
        }, {
            "name": "tags",
            "label": "Tags"
        }, {
            "name": "notes",
            "label": "Notes"
        }
    ];

    @api
    get allTrips() {
        return this._tripsToDisplay;
    }
    set allTrips(member) {
        this._tripsToDisplay = member;
    }

    renderedCallback() {
        var pageBlock = this.template.querySelectorAll('.page-num-block');
        if (pageBlock) {
            pageBlock.forEach(item => {
                if (item.dataset.id) {
                    if (item.dataset.id !== '...') {
                        // eslint-disable-next-line radix
                        if (parseInt(item.dataset.id) === this.pageNumber) {
                            item.classList.add('active')
                        } else {
                            item.classList.remove('active')
                        }
                    } else {
                        item.classList.add('page-num-disabled');
                    }
                }
            })
        }

        let allUnapprovedTrips = this.originalTrips.filter(record => record.isCheckbox == true);
        let anyChecked = allUnapprovedTrips.length > 0 ? allUnapprovedTrips.some(record => record.isChecked === true) : false;
        if(anyChecked) {
            this.isDeleteAllVisivble = true;
            let tripsForDelete = allUnapprovedTrips.filter(record => record.isChecked == true);
            let tempMileages = new Set();
            tripsForDelete.forEach(ele => {
                tempMileages.add(ele.id);
            });
            this.mileagesToDelete = Array.from(tempMileages);
        } else {
            this.isDeleteAllVisivble = false;
            this.mileagesToDelete = [];
        }
    }

    connectedCallback() {
        this.createMonthList();
        this.getMonthTrips(this.selectedMonth.value);
    }

    showSpinner() {
        this.dispatchEvent(
            new CustomEvent("spinner", {
              detail: "isShow"
            })
        );
    }

    hideSpinner() {
        this.dispatchEvent(
            new CustomEvent("spinner", {
              detail: "isHide"
            })
        );
    }

    getMonthTrips(month) {
        this.totalMileage = 0.00;
        this.displayMileage = 0.00;
        this.showSpinner();
        getTrips({ contactId: this.contactId, selectedMonth: month })
        .then(result => {
            let convRes = JSON.parse(result);
            if(convRes == 'No trips found for current month.') {
                this.noTrips = true;
                this.isMainCheckBoxVisible = false;
                this.searchVisible = false;
                this.isExportTotalVisible = false;
                this.hideSpinner();
            } else {
                this.noTrips = false;
                this.searchVisible = true;
                this.isExportTotalVisible = true;
                this.tripLogApi = convRes[0].triplogApi;
                convRes.forEach(trip => {
                    this.totalMileage += parseFloat(trip.mileage);
                    if (trip.tripDate) {
                        trip.tripDate = this.convertDate(trip.tripDate);
                    }
                    if (trip.processDate) {
                        trip.processDate = this.convertDate(trip.processDate);
                    }
                    if (trip.startTime) {
                        trip.startTime = this.convertTime(trip.startTime);
                    }
                    if (trip.endTime) {
                        trip.endTime = this.convertTime(trip.endTime);
                    }
                    if (trip.createdDate) {
                        trip.createdDate = this.convertDate((trip.createdDate.split(" ")[0]));
                    }
                });

                /* Pagination */
                this.totalRecords = convRes.length;
                /* Pagination */
                this.originalTrips = convRes;
                this.tripsForOperations = convRes;
                this.gotoPage(this.pageNumber, this.tripsForOperations);
                this.setPages();
                this.defaultSort();
                this.hideSpinner();
            }
        })
        .catch(error => {
            this.hideSpinner();
            this.noTrips = true;
            this.isMainCheckBoxVisible = false;
            this.searchVisible = false;
            this.isExportTotalVisible = false;
            let toaster = {
                detail: {
                    type: "error",
                    message: "Something wrong while load you trips."
                }
            }
            this.handleToast(toaster);
        });
    }

    createMonthList() {
        for (let i = 0; i < 3; i++) {
            const today = new Date();
            today.setDate(1);
            today.setMonth(today.getMonth() - i);
            const month = today.getMonth() + 1;
            const year = today.getFullYear();
            const monthName = today.toLocaleString('default', { month: 'long' });
            let temp = {
                id: monthName,
				label: monthName,
				value: (month < 10 ? '0' : '') + month + '-' + year
            }
            this.monthList.push(temp);
        }
        this.selectedMonth = this.monthList[0];
    }

    convertDate(date) {
        let dYear = parseFloat(date.split('-')[0]);
        let convDate = date.split('-')[1] + '/' + date.split('-')[2] + '/' + (dYear % 100);
        return convDate;
    }

    convertTime(time) {
        let tripStartTime = new Date(time);
        let convStartTime = tripStartTime.toLocaleTimeString("en-US", {
          timeZone: "America/Panama",
          hour: "2-digit",
          minute: "2-digit",
        });
        return convStartTime;
    }

    handleToast(event) {
        this.dispatchEvent(
            new CustomEvent("toast", {
                detail: event.detail
            })
        );
    }

    defaultSort() {
        this.colName = 'tripDate';
        this.colType = 'Date';
        this.sortDirection = 'desc';
        this.sortDataEvent();
    }

    handleSort(event) {
        this.colName = event.target.dataset.name;
        this.colType = event.currentTarget.dataset.sort;
        this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        this.sortDataEvent();
    }

    sortDataEvent() {
        let isReverse = this.sortDirection === 'asc' ? 1 : -1;
        let dataToSort = this.tripsForOperations;
        let sortedData = dataToSort.slice().sort((a, b) => {
            if (this.colType === "Decimal") {
                a[this.colName] = (typeof a[this.colName] === 'string') ? ((a[this.colName].indexOf('$') > -1) ? a[this.colName].replace(/\$/g, "") : a[this.colName]) : a[this.colName];
                b[this.colName] = (typeof b[this.colName] === 'string') ? ((b[this.colName].indexOf('$') > -1) ? b[this.colName].replace(/\$/g, "") : b[this.colName]) : b[this.colName];
                a = (a[this.colName] == null || a[this.colName] === 'null') ? '' : parseFloat(a[this.colName])
                b = (b[this.colName] == null || b[this.colName] === 'null') ? '' : parseFloat(b[this.colName])
                return a > b ? 1 * isReverse : -1 * isReverse;
            }
            if (this.colType === "Integer") {
                a = (a[this.colName] == null || a[this.colName] === 'null') ? '' : parseInt(a[this.colName])
                b = (b[this.colName] == null || b[this.colName] === 'null') ? '' : parseInt(b[this.colName])
                return a > b ? 1 * isReverse : -1 * isReverse;
            }
            if (this.colType === "Date") {
                a = (a[this.colName] == null || a[this.colName] === '') ? null : new Date(a[this.colName].toLowerCase())
                b = (b[this.colName] == null || b[this.colName] === '') ? null : new Date(b[this.colName].toLowerCase())
                return a > b ? 1 * isReverse : -1 * isReverse;
            }
            a = (a[this.colName] == null || a[this.colName] === '') ? '' : (typeof a[this.colName] === 'object') ? a[this.colName].join(',').toLowerCase() : a[this.colName].toLowerCase();
            b = (b[this.colName] == null || b[this.colName] === '') ? '' : (typeof b[this.colName] === 'object') ? b[this.colName].join(',').toLowerCase() : b[this.colName].toLowerCase();
            return a > b ? 1 * isReverse : -1 * isReverse;
        });
        this.tripsForOperations = sortedData;
        this.totalRecords = sortedData.length;
        this.adjustSortIcons(this.colName);
        this.gotoPage(this.pageNumber, this.tripsForOperations);
        this.setPages();
    }

    adjustSortIcons(colName) {
        this.headerData.forEach(element => {
            element.isUp = false;
            element.isDown = false;
            if(element.fieldName == colName) {
                if(this.sortDirection == 'asc') {
                    element.isUp = true;
                } else {
                    element.isDown = true;
                }
            }
        });
    }

    handleSearchChange(event) {
        this.searchkey = event.target.value;
        this.isSearchEnable = this.searchkey == "" ? false : true;
        let recordsToDisplay = [];

        for (const key in this.originalTrips) {
            if (Object.hasOwnProperty.call(this.originalTrips, key)) {
                let res;
                for (const item in this.originalTrips[key]) {
                    if (Object.hasOwnProperty.call(this.originalTrips[key], item)) {
                        const element = this.originalTrips[key][item];
                        if (element) {
                            res = element.toString().toLowerCase().includes(this.searchkey.toLowerCase());
                            if (res) {
                                recordsToDisplay.push(this.originalTrips[key]);
                                break;
                            }
                        }
                    }
                }
            }
        }
        this.totalRecords = recordsToDisplay.length;
        this.tripsForOperations = recordsToDisplay;
        this.gotoPage(this.pageNumber, this.tripsForOperations);
        this.setPages();
        if(this.colName !== '') {
            this.sortDataEvent();
        }
    }

    handleClearInput() {
        this.searchkey = '';
        this.isSearchEnable = false;
        let recordsToDisplay = this.originalTrips;
        this.totalRecords = recordsToDisplay.length;
        this.tripsForOperations = recordsToDisplay;
        this.gotoPage(this.pageNumber, this.tripsForOperations);
        this.setPages();
        if(this.colName !== '') {
            this.sortDataEvent();
        }
    }

    gotoPage(pageNumber, source) {
        if(source.length > 0) {
            var recordStartPosition, recordEndPosition;
            var i, arrayElement; // Loop helpers
            var maximumPages = Math.ceil(this.totalRecords / this.pageSize);

            // Validate that desired page number is available
            if (pageNumber > maximumPages || pageNumber < 0) {
                this.pageNumber = 1;
                return;
            }

            // Reenable both buttons
            this.disabledPreviousButton = false;
            this.disabledNextButton = false;
            this.pageNextClass = 'cPadding';
            this.pagePreviousClass = (!this.disabledPreviousButton) ? 'cPadding' : 'cPadding disabled';
            // Is data source valid?
            if (source.length > 0) {

                // Empty the data source used
                // eslint-disable-next-line @lwc/lwc/no-api-reassignments
                this._tripsToDisplay = [];
                this.displayMileage = 0.00;

                // Start the records at the page position
                recordStartPosition = (pageNumber - 1) * this.pageSize;

                // End the records at the record start position with an extra increment for the page size
                recordEndPosition = (pageNumber * this.pageSize);

                // Loop through the selected page of records
                for (i = recordStartPosition; i < recordEndPosition; i++) {
                    arrayElement = source[i];
                    if (arrayElement) {
                        this._tripsToDisplay.push(arrayElement);
                        this.displayMileage += parseFloat(arrayElement.mileage);
                    }
                }
                this.dynamicBinding(this._tripsToDisplay, this.headerData);
                this.dynamicBinding(this.originalTrips, this.headerData);
                this.dynamicBinding(this.tripsForOperations, this.headerData);
                this.noTrips = false;
                this.searchVisible = true;
                let allUnapprovedTrips = this._tripsToDisplay.filter(record => record.isCheckbox == true);
                let anyUnchecked;
                if(allUnapprovedTrips.length > 0) {
                    this.isMainCheckBoxVisible = true;
                    anyUnchecked = allUnapprovedTrips.some(record => record.isChecked === false);
                } else {
                    anyUnchecked = true;
                    this.isMainCheckBoxVisible = false;
                }
                if(this.template.querySelector('.select-all-checkbox .checkbox-input')) {
                    let selectAllCheckbox = this.template.querySelector('.select-all-checkbox .checkbox-input');
                    selectAllCheckbox.checked = !anyUnchecked;
                }

                this.pageNumber = pageNumber;
                if (maximumPages === this.pageNumber) {
                    this.disabledNextButton = true;
                    this.pageNextClass = 'cPadding disabled'
                }
                // If current page is the first page then disable the previous button
                if (this.pageNumber === 1) {
                    this.disabledPreviousButton = true;
                    this.pagePreviousClass = 'cPadding disabled'
                }
            }
        } else {
            this._tripsToDisplay = [];
            this.displayMileage = 0.00;
            this.noTrips = true;
            this.isMainCheckBoxVisible = false;
            this.searchVisible = this.searchkey == '' ? false : true;
        }
    }
    setPages() {
        this.pages = [];
        this.paginate = [];
        for (let index = 1; index <= Math.ceil(this.totalRecords / this.pageSize); index++) {
            this.pages.push(index);
            this.paginate.push(index);
        }
        if (this.pages.length > 10) {
            this.mapPages();
        }
    }
    mapPages() {
        var pagelen = this.pages.length;
        var indexlen = pagelen - (this.maxPage + 1);
        if (this.pages.length > this.maxPage) {
            this.pages.splice(this.maxPage, indexlen, "...");
        }
    }
    onPrev = () => {
        var pageNo = this.pageNumber - 1;
        this.handleButtonPrevious();
        if (this.paginate.length > this.shortPaginate) {
            if (pageNo < this.paginate.length) {
                if (pageNo > 10) {
                    this.nextPrevChange(pageNo);
                } else {
                    this.noPageChange(pageNo);
                }
            }
        }
    }
    handleButtonPrevious() {
        var nextPage = this.pageNumber - 1;
        var maxPages = Math.ceil(this.totalRecords / this.pageSize);
        var pageBlock = this.template.querySelectorAll('.page-num-block');
        if (nextPage > 0 && nextPage <= maxPages) {
            pageBlock.forEach(item => {
                if (item.dataset.id) {
                    // eslint-disable-next-line radix
                    if (parseInt(item.dataset.id) === nextPage) {
                        item.classList.add('active')
                    } else {
                        item.classList.remove('active')
                    }
                }
            })
            this.gotoPage(nextPage, this.tripsForOperations);
        }
    }
    onNext = () => {
        var pageNo = this.pageNumber + 1;
        this.handleButtonNext()
        if (this.paginate.length > this.shortPaginate) {
            if (pageNo > 10) {
                this.nextPrevChange(pageNo);
            }
        }
    }
    handleButtonNext() {
        var nextPage = this.pageNumber + 1;
        var maxPages = Math.ceil(this.totalRecords / this.pageSize);
        var pageBlock = this.template.querySelectorAll('.page-num-block');
        if (nextPage > 0 && nextPage <= maxPages) {
            pageBlock.forEach(item => {
                if (item.dataset.id) {
                    // eslint-disable-next-line radix
                    if (parseInt(item.dataset.id) === nextPage) {
                        item.classList.add('active')
                    } else {
                        item.classList.remove('active')
                    }
                }
            })
            this.gotoPage(nextPage, this.tripsForOperations);
        }
    }
    nextPrevChange(index) {
        var len = this.paginate.length;//46
        if (index !== len) {
            this.pages = this.paginate.slice();
            let startP = index + this.moveNext;
            let skiplen = len - (startP + 1);
            let inclen = index - this.moveBefore;
            if (startP < len) {
                this.pages.splice(startP, skiplen, '...');
                this.pages.splice(1, inclen, '...');
            } else {
                this.pages.splice(1, inclen, '...');
            }
        }
    }
    noPageChange(index) {
        this.maxPage = 10;
        let pagelen = this.paginate.length;
        let indexlen = pagelen - (this.maxPage + 1)
        if (index === this.maxPage) {
            this.pages = this.paginate.slice();
            this.pages.splice(this.maxPage, indexlen, '...');
        }
    }
    onPageClick = (e) => {
        var pageBlock = this.template.querySelectorAll('.page-num-block');
        var nowPage = parseInt(e.target.dataset.id, 10);
        var maxPages = Math.ceil(this.totalRecords / this.pageSize);
        var next;
        if (this.paginate.length > 10) {
            if (nowPage !== this.paginate.length) {
                if (nowPage === this.maxPage) {
                    next = nowPage
                    this.paginateChange(nowPage);
                } else {
                    this.reverseEndPaginate(nowPage, next);
                }
            } else {
                this.onLastPage(nowPage);
            }
        }

        if (nowPage > 0 && nowPage <= maxPages) {
            pageBlock.forEach(item => {
                if (item.dataset.id) {
                    // eslint-disable-next-line radix
                    if (parseInt(item.dataset.id) === nowPage) {
                        item.classList.add('active')
                    } else {
                        item.classList.remove('active')
                    }
                }
            })
            this.gotoPage(nowPage, this.tripsForOperations);
        }
    }
    paginateChange(index) {
        var totalpage = this.paginate.length;
        if (index !== totalpage) {
            this.pages = this.paginate.slice();
            this.maxPage = index + this.moveNext;
            this.minPage = index - this.moveBefore;
            let skip = totalpage - (this.maxPage + 1)
            if (this.maxPage !== totalpage && this.maxPage < totalpage) {
                this.pages.splice(this.maxPage, skip, '...');
                this.pages.splice(1, this.minPage, '...');
            } else {
                this.pages.splice(1, this.minPage, '...');
            }
        }
    }
    reverseEndPaginate(index, nextClick) {
        if (nextClick === undefined) {
            nextClick = this.paginate.length;
        }
        if (index < nextClick) {
            if (index >= 10) {
                this.paginateChange(index);
            } else {
                this.maxPage = 10;
                let pagelen = this.paginate.length;
                let indexlen = pagelen - (this.maxPage + 1)
                this.pages = this.paginate.slice();
                this.pages.splice(this.maxPage, indexlen, '...');
            }
        } else {
            if (index === 1) {
                this.maxPage = 10;
                let pagelen = this.paginate.length;
                let indexlen = pagelen - (this.maxPage + 1)
                this.pages = this.paginate.slice();
                this.pages.splice(this.maxPage, indexlen, '...');
            }

        }
    }
    onLastPage(index) {
        let pageSkip = index - 10;
        this.pages = this.paginate.slice();
        this.pages.splice(1, pageSkip, '...');
    }

    handleMonthChange(event) {
        this.searchkey = "";
        this._tripsToDisplay = [];
        this.originalTrips = [];
        this.tripsForOperations = [];
        let tempMonth = this.monthList.find(month => month.label == event.detail.value);
        this.selectedMonth = tempMonth;
        this.pageNumber = 1;
        if(this.addTrip == true) {
            let eventObj = {
                detail: { tripType : true }
            };
            this.handleCloseTrip(eventObj);
        }
        this.getMonthTrips(this.selectedMonth.value);
    }

    handleCreateTrip() {
        if(this.addTrip == true) {
            let eventObj = {
                detail: { tripType : true }
            };
            this.handleCloseTrip(eventObj);
        } else {
            let d = new Date();
            let day = d.getDate();
            let month = d.getMonth() + 1;
            let year = d.getFullYear() % 100;
            let hours = d.getHours();
            let minutes = d.getMinutes();
            let ampm = hours >= 12 ? 'PM' : 'AM';
            hours = hours % 12;
            hours = hours ? hours : 12;
            let selectedDate = new Date(`${this.selectedMonth.label} 1, 2000`);
            this.monthDifference = d.getMonth() - selectedDate.getMonth();
            this.tripDetail = {
                tripDate: this.monthDifference == 0 ? (month < 10 ? '0' : '') + month + '/' + (day < 10 ? '0' : '') + day + '/' + (year < 10 ? '0' : '') + year : '',
                startTime: (hours < 10 ? "0" : "") + hours + ":" + (minutes < 10 ? "0" : "") + minutes + " " + ampm,
                endTime: '',
                origin: '',
                destination: '',
                originName: '',
                destinationName: '',
                mileage: '',
                tags: '',
                notes: '',
                isEditMode: true
            };
            this.showNewTrip = false;
            this.addTrip = true;
        }
    }

    handleMassDeleteTrips() {
        this.isMassDeleteMode = true;
        if (this.template.querySelector('c-user-profile-modal')) {
            this.template.querySelector('c-user-profile-modal[data-id="deleteMileage"]').show();
        }
    }

    handleDownloadTrips() {
        let mileageToExport = [];
		let filename = `Manual Mileage Details ${this.selectedMonth.label} ${new Date().getFullYear()}`;
		let sheetName = `Mileage Details ${this.selectedMonth.label} ${new Date().getFullYear()}`;
        let mileageList = this.originalTrips;
        mileageList = mileageList.slice().sort((a, b) => {
            a = (a['tripDate'] == null || a['tripDate'] === '') ? null : new Date(a['tripDate'].toLowerCase())
            b = (b['tripDate'] == null || b['tripDate'] === '') ? null : new Date(b['tripDate'].toLowerCase())
            return a > b ? 1 : -1;
        });
		let excelLabel = [];
		let excelField = [];
		this.exportFields.forEach(field => {
			excelLabel.push(field.label);
			excelField.push(field.name);
		});
		mileageToExport.push(excelLabel);
		mileageList.forEach(trip => {
			let singleRecord = [];
			for (const field of excelField) {
                if(field == 'day') {
                    let date = new Date(trip.tripDate);
                    let dayOfWeek = date.toLocaleString('en-US', { weekday: 'short' });
                    singleRecord.push(dayOfWeek);
                } else if(field == 'processBy' || field == 'processDate') {
                    if(trip.tripStatus != null) {
                        if(field == 'processBy') {
                            trip[field] == 'Tom Honkus' ? singleRecord.push('By System') : singleRecord.push(trip[field]);
                        } else {
                            singleRecord.push(trip[field]);
                        }
                    } else {
                        singleRecord.push('');
                    }
                } else if(field == 'state') {
                    if(trip.originState == trip.destinationState) {
                        singleRecord.push(trip.originState);
                    } else {
                        trip.originState == '' ? singleRecord.push(trip.destinationState) : 
                        (trip.destinationState == '' ? singleRecord.push(trip.originState) : singleRecord.push(trip.originState + ', ' + trip.destinationState));
                    }
                } else {
                    singleRecord.push(trip[field]);
                }
			};
			mileageToExport.push(singleRecord);
		});
		this.template.querySelector("c-export-excel").download(mileageToExport, filename, sheetName);
    }

    handleTripAccordian(event) {
        let tripId = event.currentTarget.dataset.id;
        this._tripsToDisplay = this._tripsToDisplay.map(record => {
            if(record.id === tripId) {
                return { ...record, isEditMode: !record.isEditMode };
            }
            return record;
        });
        this.originalTrips = this.originalTrips.map(record => {
            if(record.id === tripId) {
                return { ...record, isEditMode: !record.isEditMode };
            }
            return record;
        });
        this.tripsForOperations = this.tripsForOperations.map(record => {
            if(record.id === tripId) {
                return { ...record, isEditMode: !record.isEditMode };
            }
            return record;
        });
    }

    handleCloseTrip(event) {
        let isNewTrip = event.detail.tripType;
        if(isNewTrip == true) {
            this.showNewTrip = true;
            this.tableClass = 'slds-table slds-table_cell-buffer slds-table_striped fixed-table';
            this.addTrip = false;
        } else {
            let idOfTrip = event.detail.tripId;
            // let idOfTrip = event.currentTarget.dataset.id;
            this._tripsToDisplay = this._tripsToDisplay.map(record => {
                if(record.id == idOfTrip) {
                    return { ...record, isEditMode: false };
                }
                return record;
            });
            this.originalTrips = this.originalTrips.map(record => {
                if(record.id === idOfTrip) {
                    return { ...record, isEditMode: false };
                }
                return record;
            });
            this.tripsForOperations = this.tripsForOperations.map(record => {
                if(record.id === idOfTrip) {
                    return { ...record, isEditMode: false };
                }
                return record;
            });
        }
    }

    handleCloseModal() {}

    handleAllCheckbox(event) {
        this.handleCheckbox(event.currentTarget.checked, null);
    }

    handleIndividualCheckbox(event) {
        let checked = event.currentTarget.checked;
        let tripId = event.currentTarget.dataset.id;
        this.handleCheckbox(checked, tripId);
    }

    handlePreventAccordion(event) {
        event.stopPropagation();
    }

    handleCheckbox(isChecked, tripId) {
        if (tripId) {
            let indexOfDisplayTrips = this._tripsToDisplay.findIndex(record => record.id === tripId);
            if (indexOfDisplayTrips !== -1 && "isChecked" in this._tripsToDisplay[indexOfDisplayTrips]) {
                this._tripsToDisplay[indexOfDisplayTrips].isChecked = isChecked;
            }
            let indexOfOriginalTrips = this.originalTrips.findIndex(record => record.id === tripId);
            if (indexOfOriginalTrips !== -1 && "isChecked" in this.originalTrips[indexOfOriginalTrips]) {
                this.originalTrips[indexOfOriginalTrips].isChecked = isChecked;
            }
            let indexOfOperationTrips = this.tripsForOperations.findIndex(record => record.id === tripId);
            if (indexOfOperationTrips !== -1 && "isChecked" in this.tripsForOperations[indexOfOperationTrips]) {
                this.tripsForOperations[indexOfOperationTrips].isChecked = isChecked;
            }
        } else {
            for (let i = 0; i < this._tripsToDisplay.length; i++) {
                if (this._tripsToDisplay[i] && "isChecked" in this._tripsToDisplay[i]) {
                    this._tripsToDisplay[i].isChecked = isChecked;
                }
            }
            this.originalTrips.forEach(element => {
                let indexOfRecord = this._tripsToDisplay.findIndex(record => record.id === element.id);
                if(indexOfRecord !== -1 && "isChecked" in this.originalTrips[indexOfRecord]) {
                    element.isChecked = isChecked;
                }
            });
            this.tripsForOperations.forEach(element => {
                let indexOfRecord = this._tripsToDisplay.findIndex(record => record.id === element.id);
                if(indexOfRecord !== -1 && "isChecked" in this.tripsForOperations[indexOfRecord]) {
                    element.isChecked = isChecked;
                }
            });
        }

        this.gotoPage(this.pageNumber, this.tripsForOperations);
        this.setPages();
    }

    distancePopUp(event) {
        this.calculatedMileage = event.detail.res.distance;
        this.calculatedTime = event.detail.res.duration;
        this.tripToFillMileage = event.detail.tripId;
        this.distanceTripOrigin = event.detail.origin;
        this.distanceTripDestination = event.detail.destination;
        this.mileageConfirmMessage = 'Do you want to apply to the trip?';
        if (this.template.querySelector('c-user-profile-modal')) {
            this.template.querySelector('c-user-profile-modal[data-id="mileageCalc"]').show();
        }
    }

    handleDistanceCancel() {
        if (this.template.querySelector('c-user-profile-modal')) {
            this.template.querySelector('c-user-profile-modal[data-id="mileageCalc"]').hide();
        }
    }

    handleDistanceOk() {
        this.template.querySelector(`c-trip-accordian-view[data-id=${this.tripToFillMileage}]`).fillMileage(this.calculatedMileage, this.calculatedTime);
        this.template.querySelector('c-user-profile-modal[data-id="mileageCalc"]').hide();
    }

    deletePopUp(event) {
        this.isMassDeleteMode = false;
        this.deleteTripDate = event.detail.tripDate;
        this.deleteTripOrigin = event.detail.originName == '' ? (event.detail.origin == '' ? '' : event.detail.origin) : event.detail.originName;
        this.deleteTripDestination = event.detail.destinationName == '' ? (event.detail.destination == '' ? '' : event.detail.destination) : event.detail.destinationName;
        this.deleteTripMileage = event.detail.mileage;
        this.tripToDelete = event.detail.id;
        if (this.template.querySelector('c-user-profile-modal')) {
            this.template.querySelector('c-user-profile-modal[data-id="deleteMileage"]').show();
        }
    }

    handleDeleteCancel() {
        this.isMassDeleteMode = false;
        if (this.template.querySelector('c-user-profile-modal')) {
            this.template.querySelector('c-user-profile-modal[data-id="deleteMileage"]').hide();
        }
    }

    handleDeleteOk() {
        if(this.isMassDeleteMode == true) {
            this.isMassDeleteMode = false;
            this.deleteMassMileages();
        } else {
            this.template.querySelector(`c-trip-accordian-view[data-id=${this.tripToDelete}]`).clearTrip(this.tripToDelete);
        }
        this.template.querySelector('c-user-profile-modal[data-id="deleteMileage"]').hide();
    }

    deleteMassMileages() {
        this.showSpinner();
        let tripToClear = '';
        this.mileagesToDelete.forEach(mileage => {
            tripToClear = tripToClear.length == 0 ? (tripToClear + mileage) : (tripToClear + ',' + mileage);
        });
        deleteTrips({ tripIds: JSON.stringify(tripToClear) })
            .then(result => {
                this.hideSpinner();
                if (result == 'Failure') {
                    this.dispatchEvent(
                        new CustomEvent("toast", {
                            detail: {
                                type: "error",
                                message: 'Something wrong while deleting trips.'
                            }
                        })
                    );
                } else {
                    this.dynamicMassDelete();
                    this.dispatchEvent(
                        new CustomEvent("toast", {
                            detail: {
                                type: "success",
                                message: 'Trips deleted successfully.'
                            }
                        })
                    );
                }
            })
            .catch(error => {
                this.hideSpinner();
                console.log("Error from deleteTrips : " + JSON.stringify(error));
                this.dispatchEvent(
                    new CustomEvent("toast", {
                        detail: {
                            type: "error",
                            message: 'Something wrong while deleting trips.'
                        }
                    })
                );
            });
    }

    handleRedirect() {
        this.dispatchEvent(
            new CustomEvent("back", {
                detail: ''
            })
        );
    }

    dynamicAddLoc(event) {
        let allAccordians = this.template.querySelectorAll('c-trip-accordian-view');
        allAccordians.forEach(element => {
            element.dynamicLocAdd(event.detail.location);
        });
        this.template.querySelector(`c-trip-accordian-view[data-id=${event.detail.tripId}]`).fillLocation(event.detail);
    }

    dynamicUpdtLoc(event) {
        let allAccordians = this.template.querySelectorAll('c-trip-accordian-view');
        allAccordians.forEach(element => {
            element.dynamicLocUpdt(event.detail);
        });
    }

    extractState(address) {
        const right4 = address.slice(-4);
        const right9 = address.slice(-9);
        const left3 = right9.slice(0, 3);
        const trimmedLeft3 = left3.trim();

        const isRight4Number = !isNaN(Number(right4));
        const isLeft3NotNumber = isNaN(Number(left3));
        const isTrimmedLength2 = trimmedLeft3.length === 2;

        if (isRight4Number && isLeft3NotNumber && isTrimmedLength2) {
            return trimmedLeft3;
        } else {
            return '';
        }
    }

    dynamicAddTrip(event) {
        let date = new Date();
        let day = date.getDate();
        let month = date.getMonth() + 1;
        let year = date.getFullYear();
        let selectedDate = new Date(`${this.selectedMonth.label} 1, 2000`);
        if(event.detail.tripNew.reimMonth.split("-")[0] == (selectedDate.getMonth() + 1)) {
            let newTrip = {
                id: event.detail.tripNew.trip.Id,
                tripStatus: event.detail.tripNew.trip.Trip_Status__c,
                tags: event.detail.tripNew.trip.Tag__c == null ? '' : event.detail.tripNew.trip.Tag__c,
                notes: event.detail.tripNew.trip.Notes__c == null ? '' : event.detail.tripNew.trip.Notes__c,
                mileage: event.detail.tripNew.trip.EMP_Mileage__c.toString(),
                startTime: '',
                endTime: '',
                origin: event.detail.tripNew.trip.Trip_Origin__c,
                destination: event.detail.tripNew.trip.Trip_Destination__c,
                originName: event.detail.tripNew.trip.Original_Origin_Name__c,
                destinationName: event.detail.tripNew.trip.Original_Destination_Name__c,
                createdDate: (month < 10 ? '0' : '') + month + '/' + (day < 10 ? '0' : '') + day + '/' + (year < 10 ? '0' : '') + year,
                tracingStyle: 'mDash Manual Entry',
                processDate: '',
                processBy: '',
                originState: this.extractState(event.detail.tripNew.trip.Trip_Origin__c),
                destinationState: this.extractState(event.detail.tripNew.trip.Trip_Destination__c),
                fromLat: event.detail.tripNew.trip?.From_Location__Latitude__s ? event.detail.tripNew.trip.From_Location__Latitude__s : null,
                fromLong: event.detail.tripNew.trip?.From_Location__Longitude__s ? event.detail.tripNew.trip.From_Location__Longitude__s : null,
                toLat: event.detail.tripNew.trip?.To_Location__Latitude__s ? event.detail.tripNew.trip.To_Location__Latitude__s : null,
                toLong: event.detail.tripNew.trip?.To_Location__Longitude__s ? event.detail.tripNew.trip.To_Location__Longitude__s : null,
                timeZone: event.detail.tripNew.trip.TimeZone__c,
                wayPoints: event.detail.tripNew.trip?.Way_Points__c ? event.detail.tripNew.trip.Way_Points__c : null,
                triplogApi: this.tripLogApi
            };

            newTrip.tripDate = this.convertDate(event.detail.tripNew.trip.Trip_Date__c);
            if (event.detail.tripNew.trip.StartTime__c != null) {
                newTrip.startTime = this.convertTime(event.detail.tripNew.trip.StartTime__c);
            }
            if (event.detail.tripNew.trip.EndTime__c != null) {
                newTrip.endTime = this.convertTime(event.detail.tripNew.trip.EndTime__c);
            }

            let isNewTrip = event.detail.tripType;
            if(isNewTrip == true) {
                this.noTrips = false;
                this.isMainCheckBoxVisible = true;
                this.searchVisible = true;
                this.isExportTotalVisible = true;
            }

            this._tripsToDisplay.push(newTrip);
            this.originalTrips.push(newTrip);
            this.tripsForOperations.push(newTrip);
            this.totalMileage += parseFloat(newTrip.mileage);

            this.gotoPage(this.pageNumber, this.tripsForOperations);
            this.setPages();
            this.defaultSort();
        }
    }

    dynamicUpdateTrip(event) {
        let updtTrip = {
            id: event.detail.Id,
            tripStatus: event.detail.Trip_Status__c,
            tags: event.detail.Tag__c == null ? '' : event.detail.Tag__c,
            notes: event.detail.Notes__c == null ? '' : event.detail.Notes__c,
            mileage: event.detail.EMP_Mileage__c.toString(),
            startTime: '',
            endTime: '',
            origin: event.detail.Trip_Origin__c,
            destination: event.detail.Trip_Destination__c,
            originName: event.detail.Original_Origin_Name__c,
            destinationName: event.detail.Original_Destination_Name__c,
            fromLat: event.detail.From_Location__Latitude__s,
            createdDate: this.convertDate(event.detail.CreatedDate.split('T')[0]),
            tracingStyle: event.detail.Tracing_Style__c == null ? '' : event.detail.Tracing_Style__c,
            processDate: event.detail.Approved_Date__c == null ? '' : event.detail.Approved_Date__c,
            processBy: event.detail.Approval_Name__c == null ? '' : event.detail.Approval_Name__c,
            originState: this.extractState(event.detail.Trip_Origin__c),
            destinationState: this.extractState(event.detail.Trip_Destination__c),
            fromLong: event.detail.From_Location__Longitude__s,
            toLat: event.detail.To_Location__Latitude__s,
            toLong: event.detail.To_Location__Longitude__s,
            timeZone: event.detail.TimeZone__c,
            wayPoints: event.detail.Way_Points__c,
            triplogApi: this.tripLogApi
        };

        updtTrip.tripDate = this.convertDate(event.detail.Trip_Date__c);
        if (event.detail.StartTime__c != null) {
            updtTrip.startTime = this.convertTime(event.detail.StartTime__c);
        }
        if (event.detail.EndTime__c != null) {
            updtTrip.endTime = this.convertTime(event.detail.EndTime__c);
        }

        let indexOfDisplayTrips = this._tripsToDisplay.findIndex(record => record.id == updtTrip.id);
        if (indexOfDisplayTrips !== -1) {
            this.displayMileage -= parseFloat(this._tripsToDisplay[indexOfDisplayTrips].mileage);
            this._tripsToDisplay[indexOfDisplayTrips] = updtTrip;
            this.displayMileage += parseFloat(updtTrip.mileage);
        }
        let indexOfOriginalTrips = this.originalTrips.findIndex(record => record.id == updtTrip.id);
        if (indexOfOriginalTrips !== -1) {
            this.totalMileage -= parseFloat(this.originalTrips[indexOfOriginalTrips].mileage);
            this.originalTrips[indexOfOriginalTrips] = updtTrip;
        }
        let indexOfOperationTrips = this.tripsForOperations.findIndex(record => record.id == updtTrip.id);
        if (indexOfOperationTrips !== -1) {
            this.tripsForOperations[indexOfOperationTrips] = updtTrip;
        }
        this.totalMileage += parseFloat(updtTrip.mileage);
        this.dynamicBinding(this._tripsToDisplay, this.headerData);
        this.dynamicBinding(this.originalTrips, this.headerData);
        this.dynamicBinding(this.tripsForOperations, this.headerData);
        this._tripsToDisplay = JSON.parse(JSON.stringify(this._tripsToDisplay));
    }

    dynamicDeleteTrip(event) {
        let delTripId = event.detail.tripDelete;
        let indexOfDisplayTrips = this._tripsToDisplay.findIndex(record => record.id == delTripId);
        if (indexOfDisplayTrips !== -1) {
          this._tripsToDisplay.splice(indexOfDisplayTrips, 1);
        }
        let indexOfOriginalTrips = this.originalTrips.findIndex(record => record.id == delTripId);
        if (indexOfOriginalTrips !== -1) {
            this.totalMileage -= parseFloat(this.originalTrips[indexOfOriginalTrips].mileage);
            this.originalTrips.splice(indexOfOriginalTrips, 1);
        }
        let indexOfOperationTrips = this.tripsForOperations.findIndex(record => record.id == delTripId);
        if (indexOfOperationTrips !== -1) {
            this.tripsForOperations.splice(indexOfOperationTrips, 1);
        }

        this.totalRecords = this.originalTrips.length;
        if(this.totalRecords <= 0) {
            this.isExportTotalVisible = false;
            this.totalMileage = 0.00;
        }
        this.gotoPage(this.pageNumber, this.tripsForOperations);
        this.setPages();
    }

    dynamicMassDelete() {
        this._tripsToDisplay = this._tripsToDisplay.filter(record => !this.mileagesToDelete.includes(record.id));
        this.originalTrips = this.originalTrips.filter(record => !this.mileagesToDelete.includes(record.id));
        this.tripsForOperations = this.tripsForOperations.filter(record => !this.mileagesToDelete.includes(record.id));

        this.mileagesToDelete = [];
        this.isDeleteAllVisivble = false;

        this.totalRecords = this.originalTrips.length;
        if(this.totalRecords <= 0) {
            this.isExportTotalVisible = false;
            this.totalMileage = 0.00;
        } else {
            this.totalMileage = 0.00;
            this.originalTrips.forEach(element => {
                this.totalMileage += parseFloat(element.mileage);
            });
        }

        this.gotoPage(this.pageNumber, this.tripsForOperations);
        this.setPages();
    }

    dynamicBinding(trips, header) {
        trips.forEach(trip => {
            let keyFields = [];
            header.forEach(column => {
                let tempObj = {
                    key: column.fieldName,
                    type: column.fieldType,
                    isTooltip: (column.fieldName == 'originName' || column.fieldName == 'destinationName') ? true : false,
                    tooltipText : ((column.fieldName == 'originName' || column.fieldName == 'destinationName') ? (column.fieldName == 'originName' ? trip.origin : trip.destination) : "")
                };
                if(trip.hasOwnProperty(column.fieldName)) {
                    if(column.fieldName == 'mileage') {
                        tempObj.value = (parseFloat(trip[column.fieldName]).toFixed(2)).toString();
                    } else if(column.fieldName == 'originName' || column.fieldName == 'destinationName') {
                        if(trip[column.fieldName] != '') {
                            tempObj.value = trip[column.fieldName];
                        } else {
                            tempObj.value = column.fieldName == 'originName' ? trip.origin : trip.destination;
                        }
                    } else {
                        tempObj.value = trip[column.fieldName];
                    }
                } else {
                    tempObj.value = '';
                }
                keyFields.push(tempObj);
            });
            trip.keyFields = keyFields;
            trip.mileageClass = trip.tripStatus == 'Approved' ? 'approved-mileage' : (trip.tripStatus == 'Rejected' ? 'rejected-mileage' : '');
            trip.isDeltetable = trip.tripStatus == 'Not Approved Yet' ? true : false;
            trip.isEditMode = trip.isEditMode === true;
            trip.isCheckbox = trip.tripStatus == 'Not Approved Yet' ? true : false;
            if(trip.isCheckbox) {
                trip.isChecked = trip.isChecked === true;
            }
        });
    }

}