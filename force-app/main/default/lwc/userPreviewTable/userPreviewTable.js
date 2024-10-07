/* eslint-disable radix */
/* eslint-disable @lwc/lwc/no-api-reassignments */
import resourceImage from '@salesforce/resourceUrl/mBurseCss';
import {
    events, openEvents,
    pageEvents,
    searchEvents
} from 'c/utils';
import { LightningElement, api, track } from 'lwc';
export default class UserPreviewTable extends LightningElement {
    className;
    originalClass;
    tableClass;
    rowId;
    sortedColumn = 'tripdate';
    sortedDirection = 'asc';
    previousIcon = '';
    searchPreviousIcon = '';
    cssText = 'cPadding';
    cssButtonText = 'page-num-block';
    cssPreviousText = 'cPadding';
    downloadIcon = resourceImage + '/mburse/assets/mBurse-Icons/Plan-Info/download.png';
    downloadAllIcon = resourceImage + '/mburse/assets/mBurse-Icons/download-all.png';
    @api flagPreview;
    @api userRole;
    @api dFlex;
    @api viewName;
    @api colname;
    @api sortorder;
    @api coltype;
    @api dividerClass;
    @api headTh;
    @api sortTh;
    @api headerDownload;
    @api headerName;
    @api isSortable;
    @api tripMonth;
    @api biweekValue;
    @api startDate;
    @api endDate;
    @api mainClass;
    @api rowDownload;
    @api inlineCheckbox;
    @api scrollable;
    @api isPaginate;
    @api showFooter;
    @api columns;
    @api options;
    @api pagedData;
    @api modelData;
    @api isFooter;
    @api searchKey;
    @api editableView;
    @api isBiweek;
    @api norecordMessage;
    @api mapCountry;
    norecord = false;
    @track searchVisible = false;
    @track pages = [];
    @track paginate = [];
    @track moveNext = 3;
    @track moveBefore = 7;
    @track shortPaginate = 10;
    @track maxPage = 10;
    @api isDefaultSort = false;
    @track isCheckBoxVisible = false;
    @track visibility = true;
    sortedData = [];
    // Current page of results on display
    currentPage = 1;

    // Current maximum pages in sourceData set
    maxPages = 1;

    //per page count
    displayRecordCount = 20;

    //search
    search = false;
    searchData = [];
    totalPage = [];
    // Indicators to disable the paging buttons
    disabledPreviousButton = false;
    disabledNextButton = false;
    librariesLoaded = false;
    sortedColName = '';
    accId;
    contactId;

    get subClass(){
        return this.inlineCheckbox ? 'sub-value-left' : 'sub-value-left-no'
    }

    get subClass_next(){
        return this.inlineCheckbox ? 'sub-value-right' : 'sub-value-right-no'
    }

    @api searchByKey(_keyValue) {
        var searchList;
        if (_keyValue && _keyValue.length > 0) {
            this.search = true;
            this.searchData = [];
            let data = this.modelData;
            let result = [];
            for (const key in data) {
                if (Object.prototype.hasOwnProperty.call(data, key)) {
                    let res;
                    for (const item in data[key]) {
                        if (this.options.includes(item)) {
                            //hasOwnProperty : Returns true if the object has the specified property as own property; false otherwise.
                            if (data[key].hasOwnProperty.call(data[key], item)) {
                                const element = data[key][item];
                                if (element) {
                                    res = element.toString().toLowerCase().includes(_keyValue.toLowerCase());
                                    if (res) {
                                        result.push(data[key]);
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            this.norecord = (!result.length) ? true : false
            // this.tableClass = (this.norecord) ? 'slds-table slds-table_cell-buffer slds-table_striped' : 'slds-table slds-table_cell-buffer slds-table_striped fixed-table'
            // this.className = (result.length > 6) ? this.originalClass : 'slds-p-right_small'
            this.pagedData = result;
            this.searchData = result;
            this.sortedDirection = this.previousIcon;
        } else {
            //  console.log("search key --- ", this.modelData);
            this.tableClass = 'slds-table slds-table_cell-buffer slds-table_striped fixed-table'
            this.search = false;
            this.norecord = false;
            this.className = this.originalClass;
            this.sortedDirection = this.previousIcon;
            this.pagedData = this.modelData;
        }
        searchList = { content: this.pagedData, search: this.search }
        if (this.searchData.length > 0) {
            this.mainClass = (this.searchData.length > 6) ? this.mainClass : 'fixed-container';
        }
        searchEvents(this, JSON.stringify(searchList));
        this.displaySortIcon(this.sortedColName, this.sortedDirection);
        this.gotoPage(this.currentPage, this.pagedData)
        this.totalPages(this.maxPages);
        pageEvents(this, this.maxPages);
        //console.log("total pages", this.maxPages)
    }

    @api clearSearch(){
        this.tableClass = 'slds-table slds-table_cell-buffer slds-table_striped fixed-table'
        this.mainClass = 'fixed-container';
        this.search = false;
        this.norecord = false;
        this.className = this.originalClass;
        this.sortedDirection = this.previousIcon;
        this.pagedData = this.modelData;
        this.displaySortIcon(this.sortedColName, this.sortedDirection);
        this.gotoPage(this.currentPage, this.pagedData)
        this.totalPages(this.maxPages);
    }


    @api
    viewData(data, key, needSort) {
        this.modelData = [...data];
        this.currentPage = 1
        if(key){
            if(this.search){
                const searchRes = this.modelData.filter(row => {
                    for (const obj of this.searchData) {
                      if (row[key] === obj[key]) {
                        return row
                      }
                    }
                })
                this.searchData = searchRes;
                this.gotoPage(this.currentPage, this.searchData)
            }else{
                this.gotoPage(this.currentPage, this.modelData)
                this.setPages();
            }
        }else{
            this.gotoPage(this.currentPage, this.modelData)
            this.setPages();
        }
        if (this.modelData.length > 8) {
            this.searchVisible = true;
        } else {
            this.searchVisible = false;
        }
        this.className = (this.scrollable) ? (this.modelData.length > 6) ? 'scrollable_wrapper slds-p-right_small' : (this.viewName === 'User') ? 'scrollable_wrapper slds-p-right_small' : 'overflow-none slds-p-right_small' : 'slds-p-right_small';
        this.mainClass = (this.scrollable) ? 'fixed-container' : this.mainClass;
        if (!this.modelData.length) {
            this.norecord = true;
            this.nopagedata = true;
            // this.tableClass = 'slds-table slds-table_cell-buffer slds-table_striped'
        } else {
            this.norecord = false;
            this.tableClass = 'slds-table slds-table_cell-buffer slds-table_striped fixed-table';
        }
        pageEvents(this, this.maxPages);
        if(needSort){
            this.defaultSort(this.colname, this.coltype, this.sortorder) 
        }
    }

    @api tableListRefresh(data) {
        this.modelData = [...data];
        this.tableClass = 'slds-table slds-table_cell-buffer slds-table_striped fixed-table';
        if (this.modelData) {
            this.originalClass = (this.scrollable) ? (this.modelData.length > 6) ? 'scrollable_wrapper slds-p-right_small' : (this.viewName === 'User') ? 'scrollable_wrapper slds-p-right_small' : 'overflow-none slds-p-right_small' : 'slds-p-right_small';
            this.className = (this.scrollable) ? (this.modelData.length > 6) ? 'scrollable_wrapper slds-p-right_small' : (this.viewName === 'User') ? 'scrollable_wrapper slds-p-right_small' : 'overflow-none slds-p-right_small' : 'slds-p-right_small';
            this.mainClass = (this.scrollable) ? 'fixed-container' : this.mainClass;
            // this.originalClass = (this.scrollable) ? (this.modelData.length > 6)  ? ((this.viewName === 'Team') ? 'scrollable_wrapper slds-p-right_small' : 'scrollable_wrapper  slds-p-right_small') : 'slds-p-right_small' : 'slds-p-right_small';
            // this.className = (this.scrollable) ? (this.modelData.length > 6)  ? ((this.viewName === 'Team') ? 'scrollable_wrapper slds-p-right_small' : 'scrollable_wrapper  slds-p-right_small') : 'slds-p-right_small' : 'slds-p-right_small';
            // this.mainClass = (this.scrollable) ? (this.modelData.length > 6) ? 'fixed-container ' : 'fixed-container  overflow-none' : this.mainClass;
            //console.log("PAGINATE", this.isPaginate);
            if (this.isPaginate) {
                this.sortedColumn = this.columns[0].colName;
                this.gotoPage(this.currentPage, this.modelData);
                //  this.totalPages(this.maxPages);
                this.setPages();
            } else {
                this.pagedData = [];
                this.pagedData = this.modelData;
            }
            pageEvents(this, this.maxPages);
            if (!this.modelData.length) {
                this.norecord = true;
                this.nopagedata = true;
                // this.tableClass = 'slds-table slds-table_cell-buffer slds-table_striped'
            } else {
                this.norecord = false;
                this.tableClass = 'slds-table slds-table_cell-buffer slds-table_striped fixed-table';
            }
            if (this.modelData.length > 8) {
                this.searchVisible = true;
            } else {
                this.searchVisible = false;
            }

            if (this.isDefaultSort) {
                this.defaultSort(this.colname, this.coltype, this.sortorder)
            }
        }
    }

    @api refreshTable(_data) {
        this.search = false;
        this.modelData = _data;
        this.pagedData = _data;
        this.gotoPage(this.currentPage, this.pagedData)
    }

    @api updateView(isChecked, recordId){
        let dataList = (this.search) ? this.proxyToObj(this.searchData) : this.proxyToObj(this.modelData);
        if (recordId) {
            let recordIndex = dataList.findIndex(record => record.reimbursementid === recordId);
            if (dataList && "isSelected" in dataList[recordIndex]) {
                dataList[recordIndex].isSelected = isChecked;
            }
            
        } else {
            for (let i = 0; i < dataList.length; i++) {
                if (dataList[i] && "isSelected" in dataList[i]) {
                    dataList[i].isSelected = isChecked;
                }
            }
        }

        if (this.search) {
            this.modelData = dataList;
            this.searchData = dataList;
        } else {
            this.modelData = dataList;
        }
        this.pagedData = dataList;
        this.gotoPage(this.currentPage, this.pagedData)
    }

    @api resetView(_data, key) {
        var refresh = [], search = [];
        this.pagedData = _data;
        refresh = this.modelData.map(obj => this.pagedData.find(o => o[key] === obj[key]) || obj);
        if(this.search){
        search = this.searchData.map(obj => this.pagedData.find(o => o[key] === obj[key]) || obj);
        this.searchData = search;
        }
        this.modelData = refresh;
        // console.log(" this.searchData-----",  JSON.stringify(this.searchData));
        // console.log(" this.modelData----",  JSON.stringify(this.modelData));

        //  this.pagedData = _data;
        this.gotoPage(this.currentPage, this.pagedData)
       // this.defaultSort(this.colname, this.coltype, this.sortorder)
    }

    @api resetPageView(_data, key) {
        var list = [], sList = [];
        // console.log("page data", _data, this.modelData);
        this.pagedData = _data;
        list = this.modelData.map(obj => this.pagedData.find(o => o[key] === obj[key]) || obj);
        sList = this.searchData.map(obj => this.pagedData.find(o => o[key] === obj[key]) || obj);
        this.searchData = sList;
        this.modelData = list;
        //  console.log(" this.modelData----",  this.modelData);

        //  this.pagedData = _data;
        this.gotoPage(this.currentPage, this.modelData)
        this.defaultSort(this.colname, this.coltype, this.sortorder)
    }

    getElement(data, id) {
        var object = {};
        for (let i = 0; i < data.length; i++) {
            if (data[i].contactid === id) {
                object = data[i];
            }
        }
        return object
    }

    getSingleObject(data, id, key){
        var object = {};
        for (let i = 0; i < data.length; i++) {
            if (data[i][key] === id) {
                object = data[i];
            }
        }
        return object
    }

    gotoPage(pageNumber, source) {
        var recordStartPosition, recordEndPosition;
        var i, arrayElement; // Loop helpers
        var maximumPages = this.maxPages;

        maximumPages = this.getMaxPages(source);
        // Validate that desired page number is available
        if (pageNumber > maximumPages || pageNumber < 0) {
            this.currentPage = 1;
            return;
        }

        // Reenable both buttons
        this.disabledPreviousButton = false;
        this.disabledNextButton = false;
        this.cssText = 'cPadding';
        this.cssPreviousText = (!this.disabledPreviousButton) ? 'cPadding' : 'cPadding disabled';
        // Is data source valid?
        if (source) {

            // Empty the data source used 
            // eslint-disable-next-line @lwc/lwc/no-api-reassignments
            this.pagedData = [];

            // Start the records at the page position
            recordStartPosition = this.displayRecordCount * (pageNumber - 1);

            // End the records at the record start position with an extra increment for the page size
            recordEndPosition = recordStartPosition + parseInt(this.displayRecordCount, 10);

            let mil = [];
            let varmout = [];
            // Loop through the selected page of records
            for (i = recordStartPosition; i < recordEndPosition; i++) {

                arrayElement = source[i];

                if (arrayElement) {
                    let tempData = this.proxyToObj(arrayElement);
                    // console.log(parseFloat(tempData.mileage));

                    if (tempData.mileage) {
                        tempData.mileage = parseFloat(tempData.mileage);
                        mil.push(tempData.mileage);
                    }
                    if (tempData.variableamount) {
                        tempData.variableamount = parseFloat(tempData.variableamount);
                        varmout.push(tempData.variableamount);
                    }

                    //  this.template.querySelectorAll('.page-num-block').forEach(item=>{

                    //  })
                    // Add data element for the data to bind
                    this.pagedData.push(arrayElement);
                }
            }
            // this.perPageMileage = mil.reduce((a, b) => a + b, 0);
            // console.log(this.perPageMileage);
            this.perPageMileage = mil.reduce((a, b) => a + b, 0);
            this.perPageMileage = parseFloat(this.perPageMileage).toFixed(2);
            this.perPageMileage = this.numberWithCommas(this.perPageMileage);
            this.perPageVariable = varmout.reduce((a, b) => a + b, 0);
            this.perPageVariable = parseFloat(this.perPageVariable).toFixed(2);
            this.perPageVariable = this.numberWithCommas(this.perPageVariable);
            this.totalVarAmount = this.getTotalVarAmount();
            this.totalVarAmount = parseFloat(this.totalVarAmount).toFixed(2);
            this.totalVarAmount = this.numberWithCommas(this.totalVarAmount);
            this.totalMileage = this.getTotalMileage();
            this.totalMileage = parseFloat(this.totalMileage).toFixed(2);
            this.totalMileage = this.numberWithCommas(this.totalMileage);
            // Set global current page to the new page
            this.currentPage = pageNumber;
            // If current page is the final page then disable the next button
            if (maximumPages === this.currentPage) {
                this.disabledNextButton = true;
                this.cssText = 'cPadding disabled'
            }
            // If current page is the first page then disable the previous button
            if (this.currentPage === 1) {
                this.disabledPreviousButton = true;
                this.cssPreviousText = 'cPadding disabled'
            }
        }
    }

    // On next click
    handleButtonNext() {
        var nextPage = this.currentPage + 1;
        var maxPages = this.getMaxPages(this.getSource());
        var pageBlock = this.template.querySelectorAll('.page-num-block');
        //console.log("HANDLE NEXT");
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

            this.gotoPage(nextPage, this.getSource());

        }
    }
    // On previous click
    handleButtonPrevious() {
        var nextPage = this.currentPage - 1;
        var maxPages = this.getMaxPages(this.getSource());
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
            this.gotoPage(nextPage, this.getSource());
        }

    }

    handlePageChanged(event) {
        var number = parseInt(event.target.dataset.id)
        console.log(number, this.currentPage)
    }

    // How many pages of results?
    getMaxPages(source) {

        // There will always be 1 page, at least
        var result = 1;
        // var data;
        // Number of elements on sourceData
        var arrayLength;

        // Number of elements on sourceData divided by number of rows to display in table (can be a float value)
        var divideValue;

        // Ensure sourceData has a value
        if (source.length) {

            arrayLength = source.length;

            // Float value of number of pages in data table
            divideValue = arrayLength / this.displayRecordCount;
            // Round up to the next Integer value for the actual number of pages
            result = Math.ceil(divideValue);
        }

        this.maxPages = result;
        return result;
    }

    totalPages(maxPage) {
        var j;
        this.pages = [];
        for (j = 1; j <= maxPage; j++) {
            this.pages.push(j)
        }
        if (this.pages.length > 10) {
            this.mapPages();
        }
    }

    setPages() {
        this.pages = [];
        this.paginate = [];
        let numberOfPages = Math.ceil(this.modelData.length / Number(this.displayRecordCount));
        for (let index = 1; index <= numberOfPages; index++) {
            this.pages.push(index);
            this.paginate.push(index);
        }
        if (this.pages.length > 10) {
            this.mapPages();
        }
    }


    mapPages() {
        var pagelen = this.pages.length;
        var indexlen = pagelen - (this.maxPage + 1)
        if (this.pages.length > this.maxPage) {
            this.pages.splice(this.maxPage, indexlen, "...");
        }
    }

    onLastPage(index) {
        let pageSkip = index - 10;
        this.pages = this.paginate.slice();
        this.pages.splice(1, pageSkip, '...');
    }

    /* When user moves back while filter pagination*/
    reverseEndPaginate(index, nextClick) {
        if (nextClick === undefined) {
            nextClick = this.paginate.length;
        }
        if (index < nextClick) {
            if (index >= 10) {
                //  console.log("inside paginateChange")
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
        //  console.log('reverse:-', index, nextClick);
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
        //console.log(this.pages);
    }

    onPageClick = (e) => {
        var pageBlock = this.template.querySelectorAll('.page-num-block');
        var nowPage = parseInt(e.target.dataset.id, 10);
        var maxPages = this.getMaxPages(this.getSource());
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
            this.gotoPage(nowPage, this.getSource());
        }
        // console.log("pagecount", nowPage, this.maxPages)
    }

    /* increments the page number. */
    onNext = () => {
        var pageNo = this.currentPage + 1;
        this.handleButtonNext()
        //  console.log(this.paginate.length, pageNo)
        if (this.paginate.length > this.shortPaginate) {
            if (pageNo > 10) {
                this.nextPrevChange(pageNo);
            }
        }
    }

    /* decrements the page number. */
    onPrev = () => {
        var pageNo = this.currentPage - 1;
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

    noPageChange(index) {
        this.maxPage = 10;
        let pagelen = this.paginate.length;
        let indexlen = pagelen - (this.maxPage + 1)
        if (index === this.maxPage) {
            this.pages = this.paginate.slice();
            this.pages.splice(this.maxPage, indexlen, '...');
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
            //console.log("pages",JSON.stringify(this.pages));
        }
    }

    getTotalVarAmount() {
        let data = this.proxyToObj(this.modelData);
        let totalVar = 0;
        if (data) {
            for (let i = 0; i < data.length; i++) {
                totalVar = totalVar + parseFloat(data[i].variableamount);
            }
        }
        return totalVar;
    }

    getTotalMileage() {
        let data = this.proxyToObj(this.modelData);
        let totalAmt = 0;
        if (data) {
            for (let i = 0; i < data.length; i++) {
                totalAmt = totalAmt + parseFloat(data[i].mileage);
            }
        }
        return totalAmt;
    }

    sort(event) {
        let colName = event ? event.target.dataset.name : undefined;
        let colType = event ? event.target.dataset.type : undefined;
        var data;
        if (this.sortedColumn === colName)
            this.sortedDirection = (this.sortedDirection === 'asc' ? 'desc' : 'asc');
        else
            this.sortedDirection = 'asc';

        let isReverse = this.sortedDirection === 'asc' ? 1 : -1;

        if (colName)
            this.sortedColumn = colName;
        else
            colName = this.sortedColumn;

        data = this.getSource();
        if (colType !== undefined) {
            this.pagedData = JSON.parse(JSON.stringify(data)).sort((a, b) => {
                if (colType === "Decimal") {
                    a[colName] = (typeof a[colName] === 'string') ? ((a[colName].indexOf('$') > -1) ? a[colName].replace(/\$/g, "") : a[colName]) : a[colName];
                    b[colName] = (typeof b[colName] === 'string') ? ((b[colName].indexOf('$') > -1) ? b[colName].replace(/\$/g, "") : b[colName]) : b[colName];
                    a = (a[colName] == null || a[colName] === 'null') ? '' : parseFloat(a[colName])
                    b = (b[colName] == null || b[colName] === 'null') ? '' : parseFloat(b[colName])
                    return a > b ? 1 * isReverse : -1 * isReverse;
                }
                if (colType === "Integer") {
                    a = (a[colName] == null || a[colName] === 'null') ? '' : parseInt(a[colName])
                    b = (b[colName] == null || b[colName] === 'null') ? '' : parseInt(b[colName])
                    return a > b ? 1 * isReverse : -1 * isReverse;
                }
                if (colType === "Date") {
                    a = (a[colName] == null || a[colName] === '') ? null : new Date(a[colName].toLowerCase())
                    b = (b[colName] == null || b[colName] === '') ? null : new Date(b[colName].toLowerCase())
                    return a > b ? 1 * isReverse : -1 * isReverse;
                }
                a = (a[colName] == null || a[colName] === '') ? '' : (typeof a[colName] === 'object') ? a[colName].join(',').toLowerCase() : a[colName].toLowerCase();
                b = (b[colName] == null || b[colName] === '') ? '' : (typeof b[colName] === 'object') ? b[colName].join(',').toLowerCase() : b[colName].toLowerCase();
                return a > b ? 1 * isReverse : -1 * isReverse;

            });
            //this.sortedData = this.pagedData
            if (!this.search) {
                this.previousIcon = this.sortedDirection
                this.modelData = this.pagedData;
            } else {
                this.searchPreviousIcon = this.sortedDirection
            }
            this.sortedColName = colName;
            this.displaySortIcon(colName, this.sortedDirection);
            this.gotoPage(this.currentPage, this.pagedData);
        }

    }

    @api defaultSort(column, type, sortDirect) {
        console.log("default", column, type, sortDirect, this.sortedColumn);
        let colName = column ? column : undefined;
        let colType = type ? type : undefined;
        // eslint-disable-next-line vars-on-top
        var data;
        if (this.sortedColumn === colName)
            this.sortedDirection = (sortDirect === 'asc' ? 'desc' : 'asc');
        else
            this.sortedDirection = 'asc';

        let isReverse = this.sortedDirection === 'asc' ? 1 : -1;

        if (colName)
            this.sortedColumn = colName;
        else
            colName = this.sortedColumn;

        data = this.getSource();
        this.pagedData = JSON.parse(JSON.stringify(data)).sort((a, b) => {
            if (colType === "Decimal") {
                a[colName] = (typeof a[colName] === 'string') ? ((a[colName].indexOf('$') > -1) ? a[colName].replace(/\$/g, "") : a[colName]) : a[colName];
                b[colName] = (typeof b[colName] === 'string') ? ((b[colName].indexOf('$') > -1) ? b[colName].replace(/\$/g, "") : b[colName]) : b[colName];
                a = (a[colName] == null || a[colName] === 'null') ? '' : parseFloat(a[colName])
                b = (b[colName] == null || b[colName] === 'null') ? '' : parseFloat(b[colName])
                return a > b ? 1 * isReverse : -1 * isReverse;
            }
            if (colType === "Date") {
                a = (a[colName] == null) ? '' : new Date(a[colName].toLowerCase())
                b = (b[colName] == null) ? '' : new Date(b[colName].toLowerCase())
                return a > b ? 1 * isReverse : -1 * isReverse;
            }
            a = (a[colName] == null || a[colName] === '') ? '' : a[colName].toLowerCase();
            b = (b[colName] == null || b[colName] === '') ? '' : b[colName].toLowerCase();
            return a > b ? 1 * isReverse : -1 * isReverse;

        });
        console.log("default direction", this.sortedDirection);

        //this.sortedData = this.pagedData
        if (!this.search) {
            this.previousIcon = this.sortedDirection
            this.modelData = this.pagedData;
        } else {
            this.searchPreviousIcon = this.sortedDirection
        }
        this.sortedColName = colName;
        this.displaySortIcon(colName, this.sortedDirection);
        this.gotoPage(this.currentPage, this.pagedData);
    }

    displaySortIcon(colName, sortOrder) {
        let data = this.proxyToObj(this.columns);
        if (data) {
            for (let i = 0; i < data.length; i++) {
                data[i].arrUp = false;
                data[i].arrDown = false;
                if (data[i].colName === colName) {
                    if (sortOrder === 'asc') {
                        data[i].arrUp = true;
                    } else {
                        data[i].arrDown = true;
                    }

                }
            }
        }
        // eslint-disable-next-line @lwc/lwc/no-api-reassignments
        this.columns = data;
    }

    getSource() {
        if (this.search) {
            return this.searchData;
        }
        return this.modelData;
    }

    linkHandler(event) {
        let id = event.currentTarget.dataset.id;
        let element = this.getElement(this.modelData, id);
        const linkEvent = new CustomEvent('access', { detail: JSON.stringify(element) });
        this.dispatchEvent(linkEvent);
        this.dispatchEdit(id);
    }

    dispatchEdit(id) {
        const editRecord = new CustomEvent('edit', { detail: id });
        this.dispatchEvent(editRecord);
    }

    modalHandler() {
        const showProcess = new CustomEvent('approvalprocess', { detail: '' });
        this.dispatchEvent(showProcess);
    }

    validateInputField(event) {
        let _name = event.currentTarget.dataset.name;
        if (_name === 'range' && this.mapCountry != undefined && this.mapCountry != null && this.mapCountry != '') {
            if(this.mapCountry == 'CANADA') {
                event.target.value = event.target.value
                    .replace(/[^0-9]/g, '')
                    .slice(0, 2);
            } else {
                event.target.value = event.target.value
                    .replace(/[^0-9]/g, '')
                    .slice(0, 3);
            }
            event.target.value = event.target.value
                .replace(/[^\d]/g, '')             // numbers only
                .replace(/(^\.*)\./g, '$1')          // single dot retricted
                .replace(/(^[\d]{5})[\d]/g, '$1')   // not more than 4 digits at the beginning
        } else if (_name === 'Integer' || _name === 'totalMileage') {
            event.target.value = event.target.value
                .replace(/[^\d.]/g, '')             // numbers and decimals only
                .replace(/(^\.*)\./g, '$1')          // single dot retricted
                .replace(/(^[\d]{5})[\d]/g, '$1')   // not more than 4 digits at the beginning
                .replace(/(\..*)\./g, '$1')          // decimal can't exist more than once
                .replace(/(\.[\d]{2})./g, '$1');    // not more than 2 digits after decimal
        } else if(_name == 'zipCode' && this.mapCountry != undefined && this.mapCountry != null && this.mapCountry != '') {
            if(this.mapCountry == 'CANADA') {
                event.target.value = event.target.value
                    .replace(/[^a-zA-Z0-9]/g, '')
                    .toUpperCase()
                    .slice(0, 6);
            } else {
                event.target.value = event.target.value
                    .replace(/\D/g, '')
                    .slice(0, 5);
            }
        }
    }

    handleFocusInput(){
        console.log("focus")
        let dataList = (this.search) ? this.proxyToObj(this.searchData) : this.proxyToObj(this.modelData);
        const eventFired = new CustomEvent("sortedlist", {
            detail: JSON.stringify(dataList)
        })
        this.dispatchEvent(eventFired);
    }
    handleProratedInput(event){
        console.log("Inside Prorated Input")
        this.validateInputField(event);
        //let id = event.currentTarget.dataset.id ;
        let tripid = event.currentTarget.dataset.tripid;
        let inputType = event.currentTarget.dataset.inputType;
        let keyName = event.currentTarget.dataset.key;
        let input;
        if (inputType === "input") {
            input = event.target.value;
        }
        let dataList = (this.search) ? this.proxyToObj(this.searchData) : this.proxyToObj(this.modelData);
        let updatedList = [];
        // let element = dataList.find(ele  => ele.id === this.rowId);
        console.log("dataList before Operation : " + JSON.stringify(dataList));
        for (let i = 0; i < dataList.length; i++) {
            if (dataList[i].Id === tripid) {
                let keyList = dataList[i].keyFields;
                dataList[i][keyName] = (input !== null) ? input : input;
                for (let j = 0; j < keyList.length; j++) {
                    if (keyList[j].key === keyName) {
                        keyList[j].value = input;
                    }
                }
            }
        }
        console.log("dataList after Operation : " + JSON.stringify(dataList));
        updatedList = dataList;
        if (this.search) {
            this.modelData = dataList;
            this.searchData = dataList;
        } else {
            this.modelData = dataList;
        }
        this.pagedData = dataList;
        this.gotoPage(this.currentPage, this.pagedData)
        const eventD = new CustomEvent("update", {
                detail: { 
                    list: JSON.stringify(updatedList), 
                    id: tripid
                }
            })

        // var object = {};
        // for (let i = 0; i < data.length; i++) {
        //     if(id === undefined){
        //         if (data[i].Id === tripid) {
        //             object = data[i];
        //         }
        //     }else{
        //      if (data[i].id === id) {
        //         object = data[i];
        //     }
        //    }
        // }
        // const eventD = new CustomEvent('update', { detail: {list : JSON.stringify(object) , inputValue: event.target.value, key: event.currentTarget.dataset.key}});
        this.dispatchEvent(eventD);
    }

    keyPressInput(){
        this.dispatchEvent(
            new CustomEvent("keyinputpress", {
                detail: ''
            })
        );
    }

    handleInput(event) {
        this.validateInputField(event);
        let inputType = event.currentTarget.dataset.inputType;
        let keyName = event.currentTarget.dataset.name;
        let id = event.currentTarget.dataset.id;
        let input;
        if (inputType === "select" || inputType === "address") {
            input = event.detail.value;
            if (event.detail.fieldName) {
                keyName = event.detail.fieldName;
            }
        } else if (inputType === "input") {
            input = event.target.value;
        } else if(inputType === "searchSelect") {
            this.rowId = id;
            input = this.template.querySelector(`c-select2-dropdown[data-id="${id}"]`).selectedValue;
        }
        let dataList = (this.search) ? this.proxyToObj(this.searchData) : this.proxyToObj(this.modelData);
        let updatedList = [];
        // let element = dataList.find(ele  => ele.id === this.rowId);
        for (let i = 0; i < dataList.length; i++) {
            if (dataList[i].id === this.rowId) {
                let keyList = dataList[i].keyFields;
                dataList[i][keyName] = (input !== null) ? (keyName === 'range') ? parseInt(input) : input : input;
                if (keyName === "managerName") {
                    let manager = this.proxyToObj(event.detail);
                    dataList[i].managerId = manager?.key;
                }
                for (let j = 0; j < keyList.length; j++) {
                    if (keyList[j].key === keyName) {
                        keyList[j].value = input;
                    }
                }
            }
        }
        updatedList = dataList;
        if (this.search) {
            this.modelData = dataList;
            this.searchData = dataList;
        } else {
            this.modelData = dataList;
        }
        this.pagedData = dataList;
        this.gotoPage(this.currentPage, this.pagedData)
        this.dispatchEvent(
            new CustomEvent("update", {
                detail: JSON.stringify(updatedList)
            })
        );
        if (keyName === "role") {
            this.dispatchEdit(this.rowId);
        }
    }

    handleEditMode(event) {
        //console.log("handleEditMode");
        let targetId = (event.currentTarget) ? event.currentTarget.dataset.id : undefined;
        this.rowId = targetId;
        let data = (this.search) ? this.proxyToObj(this.searchData) : this.proxyToObj(this.modelData);
        if (targetId) {
            this.dispatchEvent(
                new CustomEvent("editmode", {
                    detail: targetId
                })
            );
            if (data) {
                for (let i = 0; i < data.length; i++) {
                    if (data[i].id === targetId) {
                        data[i].isEdited = true;
                    } else {
                        data[i].isEdited = !data[i].isEdited ? false : true;
                    }
                }
                if (this.search) {
                    this.modelData = data;
                    this.searchData = data;
                } else {
                    this.modelData = data;
                }
                this.pagedData = data;
                this.gotoPage(this.currentPage, this.pagedData);
            }
        }

    }

    /** Handler if checkbox available in UI */

    @api checkUncheckAll(checked) {
        let i;
        let checkboxes = this.template.querySelectorAll('.checkbox-input');
        for (i = 0; i < checkboxes.length; i++) {
            checkboxes[i].checked = checked;
        }
    }

    @api returnList() {
        return JSON.parse(JSON.stringify(this.modelData));
    }

    @api returnSearchList() {
        return JSON.parse(JSON.stringify(this.searchData));
    }

    @api returnPageList() {
        return JSON.parse(JSON.stringify(this.pagedData));
    }


    handleCheckbox(event) {
        let checked = event.target.checked;
        let targetId = event.currentTarget.dataset.id;
        let rowObject = { isChecked: checked, targetId: targetId }
        this.dispatchEvent(new CustomEvent('rowselection', { detail: rowObject }));
    }

    sendBtnHandler(key, record){
        const id = record
        const name = key
        const obj = this.getSingleObject(this.modelData, id, 'employeeReimbursementId')
        if(name === 'Mileage'){
            let rowObject = {
                Id : obj.employeeReimbursementId,
                month : obj.month,
                fuel : obj.fuel,
                maintainsAndTyres: obj.maintainsAndTyres,
                mpg : obj.mpg
            }
            this.dispatchEvent(new CustomEvent('rowsync', { detail: rowObject }));
        }else{
            let concurObject = {
                Id : obj.employeeReimbursementId,
                contactEmail : obj.contactEmail,
                totalReimbursements : obj.totalReimbursements
            }
            this.dispatchEvent(new CustomEvent('concursync', { detail: concurObject }));
        }
     
        console.log("btn handler", name)
        console.log("employeeReimbursementId" ,obj.employeeReimbursementId)
        console.log("month" ,obj.month)
        console.log("fuel" ,obj.fuel)
        console.log("maintainsAndTyres" ,obj.maintainsAndTyres)
        console.log("mpg" ,obj.mpg)
        console.log("contactEmail" ,obj.contactEmail)
        console.log("totalReimbursements" ,obj.totalReimbursements)
       
    }

    checkboxHandler(event) {
        event.stopPropagation();
        let checked = event.target.checked;
        let targetId = event.currentTarget.dataset.id;
        let rowObject = { isChecked: checked, targetId: targetId }
        this.dispatchEvent(new CustomEvent('rowselection', { detail: rowObject }));
        let recordIndex = this.modelData.findIndex(record => record.id === targetId);
        if (this.modelData[recordIndex] && "isChecked" in this.modelData[recordIndex]) {
            this.updateCheckBox(event.target.checked, targetId);
        }
    }

    proxyToObj(obj) {
        return JSON.parse(JSON.stringify(obj));
    }

    numberWithCommas(x) {
        return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }

    connectedCallback() {
        // Initialize data table to the specified current page (should be 1)
    //    console.log("Trip", JSON.stringify(this.modelData), this.norecord, this.scrollable)
    //    console.log("Role", this.userRole);
        //Object.assign({},this.objContactData);
        // this.myContactData = this.objContactData;
        this.tableClass = 'slds-table slds-table_cell-buffer slds-table_striped fixed-table';
        if (this.modelData) {
            this.originalClass = (this.scrollable) ? (this.modelData.length > 6) ? 'scrollable_wrapper slds-p-right_small' : (this.viewName === 'User') ? 'scrollable_wrapper slds-p-right_small' : 'overflow-none slds-p-right_small' : 'slds-p-right_small';
            this.className = (this.scrollable) ? (this.modelData.length > 6) ? 'scrollable_wrapper slds-p-right_small' : (this.viewName === 'User') ? 'scrollable_wrapper slds-p-right_small' : 'overflow-none slds-p-right_small' : 'slds-p-right_small';
            this.mainClass = (this.scrollable) ? 'fixed-container' : this.mainClass;
            // this.originalClass = (this.scrollable) ? (this.modelData.length > 6)  ? ((this.viewName === 'Team') ? 'scrollable_wrapper slds-p-right_small' : 'scrollable_wrapper slds-p-right_small') : 'slds-p-right_small' : 'slds-p-right_small';
            // this.className = (this.scrollable) ? (this.modelData.length > 6)  ? ((this.viewName === 'Team') ? 'scrollable_wrapper slds-p-right_small' : 'scrollable_wrapper slds-p-right_small') : 'slds-p-right_small' : 'slds-p-right_small';
            // this.mainClass = (this.scrollable) ? (this.modelData.length > 6) ? 'fixed-container' : 'fixed-container overflow-none' : this.mainClass;
            if (this.isPaginate) {
                this.sortedColumn = (this.viewName === 'User') ? this.colname : this.columns[0].colName;
                this.gotoPage(this.currentPage, this.modelData);
                //  this.totalPages(this.maxPages);
                this.setPages();
            } else {
                this.pagedData = [];
                this.pagedData = this.modelData;
            }
            pageEvents(this, this.maxPages);
            if (!this.modelData.length) {
                this.norecord = true;
                this.nopagedata = true;
                // this.tableClass = 'slds-table slds-table_cell-buffer slds-table_striped'
            } else {
                this.norecord = false;
                this.tableClass = 'slds-table slds-table_cell-buffer slds-table_striped fixed-table';
            }
            if (this.modelData.length > 8) {
                this.searchVisible = true;
            } else {
                this.searchVisible = false;
            }

            if (this.isDefaultSort) {
                this.sortedColumn = this.colname
                this.defaultSort(this.colname, this.coltype, this.sortorder)
            }
        }

    }

    renderedCallback() {
        var pageBlock = this.template.querySelectorAll('.page-num-block');
        let customIcon = this.template.querySelectorAll('.navigate');
        let _self = this;
        if (pageBlock) {
            pageBlock.forEach(item => {
                if (item.dataset.id) {
                    if (item.dataset.id !== '...') {
                        // eslint-disable-next-line radix
                        if (parseInt(item.dataset.id) === this.currentPage) {
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
        if (customIcon) {
            customIcon.forEach(ev => {
                ev.addEventListener('click', function (e) {
                    // console.log("Icon----", e, e.currentTarget.dataset.id, e.currentTarget.dataset.st, _self.isBiweek )
                    if (e.currentTarget.dataset.name !== undefined) {
                        if (_self.isBiweek !== true) {
                            events(_self, e.currentTarget.dataset.name)
                        } else {
                            events(_self, {
                                id: e.currentTarget.dataset.id,
                                startDate: e.currentTarget.dataset.st,
                                endDate: e.currentTarget.dataset.ed
                            })
                        }

                    }
                    e.stopPropagation();
                });
            });
        }
        if(this.template.querySelector('c-select2-dropdown') != null) {
            let allseachableDD = this.template.querySelectorAll('c-select2-dropdown');
            allseachableDD.forEach(element => {
                element.setDynamicContentStyle('10rem', '98%');
            });
        }
    }

    handleDownload(event) {
        event.stopPropagation();
        openEvents(this, event.currentTarget.dataset.key);
    }

    downloadAllTrips() {
        const tripEvent = new CustomEvent('view', { detail: this.tripMonth });
        this.dispatchEvent(tripEvent);
    }

    handleIcon(event) {
        // event.stopPropagation();
        let record = event.currentTarget.dataset.id;
        let key = event.currentTarget.dataset.key;
        const dateIconEvent = new CustomEvent('iconclick', {
            detail: {
                id: record,
                key: key
            }
        });
        this.dispatchEvent(dateIconEvent);
    }

    handleConditionalIcon(event) {
        // event.stopPropagation();
        let record = event.currentTarget.dataset.id;
        const deleteIconEvent = new CustomEvent('conditionalclick', {
            detail: {
                id: record
            }
        });
        this.dispatchEvent(deleteIconEvent);
    }

    handleMultipleIcon(event) {
        event.stopPropagation();
        let record = event.currentTarget.dataset.id;
        let key = event.currentTarget.dataset.key;
        if(key === 'Mileage' || key === 'Concur'){
            this.sendBtnHandler(key, record);
        }else{
            const dateIconEvent = new CustomEvent('icon2click', {
                detail: {
                    id: record,
                    key: key
                }
            });
            this.dispatchEvent(dateIconEvent);
       }
    }

    handleRemoveTag(event) {
        // event.stopPropagation();
        let detail = {
            key: event.currentTarget.dataset.key,
            tag: event.detail,
            record: event.currentTarget.dataset.id
        }
        const removeTag = new CustomEvent('removetag', {
            detail: detail
        });
        this.dispatchEvent(removeTag);
    }

    handleSelectAll(event) {
       // console.log("checkboxHandler");
        this.updateCheckBox(event.currentTarget.checked, null);
    }

    updateCheckBox(isChecked, recordId) {
        let dataList = (this.search) ? this.proxyToObj(this.searchData) : this.proxyToObj(this.modelData);
        let updatedList = [];
        // let element = dataList.find(ele  => ele.id === this.rowId);
        if (recordId) {
            let recordIndex = dataList.findIndex(record => record.id === recordId);
            if (dataList && "isChecked" in dataList[recordIndex]) {
                dataList[recordIndex].isChecked = isChecked;
            }
            // Check if any object has isChecked = false
            const hasFalseValue = dataList.some(obj => obj.isChecked === false);

            // Set the value of the "Select All" checkbox
            const selectAllCheckbox = this.template.querySelector('.select-all-checkbox .checkbox-input');
            selectAllCheckbox.checked = !hasFalseValue;
        } else {
            for (let i = 0; i < dataList.length; i++) {
                if (dataList[i] && "isChecked" in dataList[i]) {
                    dataList[i].isChecked = isChecked;
                }
            }
        }
        updatedList = dataList;

        if (this.search) {
            this.modelData = dataList;
            this.searchData = dataList;
        } else {
            this.modelData = dataList;
        }
        this.pagedData = dataList;
        this.gotoPage(this.currentPage, this.pagedData)
        this.dispatchEvent(
            new CustomEvent("update", {
                detail: JSON.stringify(updatedList)
            })
        );
        this.triggerDisableCheckbox(dataList);
    }

    preventEdit(event) {
        event.stopPropagation();
    }

    @api
    toggleCheckBox(toogle, activity) {
        this.isCheckBoxVisible = toogle;
        if (!toogle) {
            this.disableAll();
        }else{
            if(activity){
                this.envelopeVisible(activity);
            }
        } 
    }


    @api
    hidden() {
        let dataList = (this.search) ? this.proxyToObj(this.searchData) : this.proxyToObj(this.modelData);
        let updatedList = [];
        for (let i = 0; i < dataList.length; i++) {
            if (dataList[i]) {
                if (!dataList[i].resendDriverPacket) {
                    dataList[i].showCheckbox = false;
                }else{
                    dataList[i].showCheckbox = true;
                }
            }
        }
        updatedList = dataList;
        if (this.search) {
            this.modelData = updatedList;
            this.searchData = updatedList;
        } else {
            this.modelData = updatedList;
        }
        this.pagedData = updatedList;
        this.gotoPage(this.currentPage, this.pagedData)
    }

    disableAll() {
        let dataList = (this.search) ? this.proxyToObj(this.searchData) : this.proxyToObj(this.modelData);
        let updatedList = [];
        for (let i = 0; i < dataList.length; i++) {
            if (dataList[i] && "isChecked" in dataList[i]) {
                dataList[i].isChecked = false;
            }
        }
        updatedList = dataList;

        if (this.search) {
            this.modelData = dataList;
            this.searchData = dataList;
        } else {
            this.modelData = dataList;
        }
        this.pagedData = dataList;
        this.gotoPage(this.currentPage, this.pagedData)
        this.dispatchEvent(
            new CustomEvent("update", {
                detail: JSON.stringify(updatedList)
            })
        );
    }

    envelopeVisible(activity){
        if(activity === 'Send Driver Packet'){
            let dataList = (this.search) ? this.proxyToObj(this.searchData) : this.proxyToObj(this.modelData);
            let updatedList = [];
            for (let i = 0; i < dataList.length; i++) {
                if(dataList[i].role === 'Admin' || dataList[i].role === 'Manager'){
                    dataList[i].checkbox = false
                }else{
                    // dataList[i].checkbox = dataList[i].resendDriverPacket === '' ? true : dataList[i].packet === 'Sent to Driver' ? true : false;
                    dataList[i].checkbox = dataList[i].resendDriverPacket === true ? true : false;
                }
            }
            updatedList = dataList;
            if (this.search) {
                this.modelData = dataList;
                this.searchData = dataList;
            } else {
                this.modelData = dataList;
            }
            this.pagedData = dataList;
            this.gotoPage(this.currentPage, this.pagedData)
            this.dispatchEvent(
                new CustomEvent("update", {
                    detail: JSON.stringify(updatedList)
                })
            );
        }else{
            let dataList = (this.search) ? this.proxyToObj(this.searchData) : this.proxyToObj(this.modelData);
            let updatedList = [];
            for (let i = 0; i < dataList.length; i++) {
                    dataList[i].checkbox = true;
            }
            updatedList = dataList;
            if (this.search) {
                this.modelData = dataList;
                this.searchData = dataList;
            } else {
                this.modelData = dataList;
            }
            this.pagedData = dataList;
            this.gotoPage(this.currentPage, this.pagedData)
            this.dispatchEvent(
                new CustomEvent("update", {
                    detail: JSON.stringify(updatedList)
                })
            );
        }
    }

    triggerDisableCheckbox(data) {
        const hasTrueValue = data.some(obj => obj.isChecked === true);
        if (!hasTrueValue) {
            this.dispatchEvent(
                new CustomEvent("disablecheckbox", {})
            );
        } else {
            this.dispatchEvent(
                new CustomEvent("enablesubmit", {})
            );
        }
    }

    handleInvalidZip(event) {
        let message = event.detail?.message;
        this.dispatchToast("error", message);

    }

    dispatchToast(type, message) {
        let toastObj = { type: type, message: message }
        this.dispatchEvent(new CustomEvent('toast', { detail: toastObj }));
    }
}