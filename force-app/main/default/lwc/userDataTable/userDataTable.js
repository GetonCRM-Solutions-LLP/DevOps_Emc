/* eslint-disable @lwc/lwc/no-api-reassignments */
import { LightningElement,api,track } from 'lwc';
import resourceImage from '@salesforce/resourceUrl/mBurseCss';
import {
    events, openEvents
} from 'c/utils';
export default class UserDataTable extends LightningElement {
    sortedColumn = 'tripdate';
    sortedDirection = 'asc';
    previousIcon = '';
    searchPreviousIcon = '';
    cssText = 'cPadding';
    className;
    cssButtonText = 'page-num-block';
    cssPreviousText = 'cPadding';
    downloadIcon = resourceImage + '/mburse/assets/mBurse-Icons/Plan-Info/download.png';
    downloadAllIcon = resourceImage + '/mburse/assets/mBurse-Icons/download-all.png';
    @api isAllDownload;
    @api isVariable;
    @api mainClass;
    @api rowDownload;
    @api scrollable;
    @api filter;
    @api isSortable;
    @api isPaginate;
    @api columns;
    @api options;
    @api pagedData;
    @api modelData;
    @api searchKey;
    @api isBiweek;
    @api colname;
    @api sortorder;
    @api coltype;
    @api isDefaultSort = false;
    norecord = false;
    @track searchVisible = false;
    @track pages = [];
    @track paginate = [];
    @track moveNext = 3;
    @track moveBefore = 7;
    @track shortPaginate = 10;
    @track maxPage = 10;
    @api footerList;
    @api isYtd;
    @api isYtdBiweek;
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
     // Indicators to disable the paging buttons
     disabledPreviousButton = false;
     disabledNextButton = false;
     librariesLoaded = false;
     sortedColName = '';
     accId;
     contactId;

    @api searchByKey(_keyValue){
        if(_keyValue && _keyValue.length > 0 ) {
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
            this.pagedData = result;
            this.searchData = result;
            this.sortedDirection = this.previousIcon;
        }else{
            this.search = false;
            this.norecord = false;
            this.sortedDirection = this.previousIcon;
            this.pagedData = this.modelData;
        }
        this.displaySortIcon(this.sortedColName, this.sortedDirection);
        this.gotoPage(this.currentPage, this.pagedData)
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

                    // Add data element for the data to bind
                    this.pagedData.push(arrayElement);
                }
            }
            // this.perPageMileage = mil.reduce((a, b) => a + b, 0);
            // console.log(this.perPageMileage);
            // console.log(this.pagedData[0]);
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
        if (nextPage > 0 && nextPage <= maxPages) {
            this.gotoPage(nextPage, this.getSource());
        }
    }
    // On previous click
    handleButtonPrevious() {

        var nextPage = this.currentPage - 1;
        var maxPages = this.getMaxPages(this.getSource());

        if (nextPage > 0 && nextPage <= maxPages) {
            this.gotoPage(nextPage, this.getSource());
        }
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

    // totalPages(maxPage){
    //     var j;
    //     this.pages = [];
    //     for(j = 1;j<=maxPage;j++){
    //         this.pages.push(j)
    //     }
    //     if(this.pages.length > 10){
    //         this.mapPages();
    //     }
    // }

    // setPages() {
    //     this.pages = [];
    //     this.paginate = [];
    //     let numberOfPages = Math.ceil(this.modelData.length / Number(this.displayRecordCount));
    //     for (let index = 1; index <= numberOfPages; index++) {
    //         this.pages.push(index);
    //         this.paginate.push(index);
    //     }
    //     if(this.pages.length > 10){
    //         this.mapPages();
    //     }
    // }

    // mapPages(){
    //     var pagelen = this.pages.length;
    //     var indexlen = pagelen - (this.maxPage + 1)
    //     if(this.pages.length > this.maxPage){
    //         this.pages.splice(this.maxPage,indexlen,"...");
    //     }
    //    console.log("this.paginate", JSON.stringify(this.pages));
    // }

    // onLastPage(index){
    //     let pageSkip = index - 10;
    //     this.pages = this.paginate.slice();
    //     this.pages.splice(1,pageSkip,'...');
    // }

    //    /* When user moves back while filter pagination*/
    // reverseEndPaginate(index, nextClick) {
    //     if(nextClick === undefined){
    //         nextClick = this.paginate.length;
    //     }
    //     if (index < nextClick) {
    //         if (index >= 10) {
    //           //  console.log("inside paginateChange")
    //             this.paginateChange(index);
    //         } else {
    //             this.maxPage = 10;
    //             let pagelen = this.paginate.length;
    //             let indexlen = pagelen - (this.maxPage + 1)
    //             this.pages = this.paginate.slice();
    //             this.pages.splice(this.maxPage, indexlen, '...');
    //         }
    //     } else {
    //         if (index === 1) {
    //             this.maxPage = 10;
    //             let pagelen = this.paginate.length;
    //             let indexlen = pagelen - (this.maxPage + 1)
    //             this.pages = this.paginate.slice();
    //             this.pages.splice(this.maxPage, indexlen, '...');
    //         }

    //     }
    //     //  console.log('reverse:-', index, nextClick);
    // }
    // paginateChange(index) {
    //     var totalpage = this.paginate.length;
    //     if (index !== totalpage) {
    //         this.pages = this.paginate.slice();
    //         this.maxPage = index + this.moveNext;
    //         this.minPage = index - this.moveBefore;
    //         let skip = totalpage - (this.maxPage + 1)
    //         if (this.maxPage !== totalpage && this.maxPage < totalpage) {
    //             this.pages.splice(this.maxPage, skip, '...');
    //             this.pages.splice(1, this.minPage, '...');
    //         } else {
    //             this.pages.splice(1, this.minPage, '...');
    //         }
    //     }
    //   console.log(this.pages);
    // }

    // onPageClick = (e) => {
    //     var pageBlock = this.template.querySelectorAll('.page-num-block');
    //     var nowPage = parseInt(e.target.dataset.id, 10);
    //     var maxPages = this.getMaxPages(this.getSource());
    //     var next;
    //     if (this.paginate.length > 10) {
    //         if (nowPage !== this.paginate.length) {
    //             if (nowPage === this.maxPage) {
    //                 next = nowPage
    //                 this.paginateChange(nowPage);
    //             } else {
    //                 this.reverseEndPaginate(nowPage, next);
    //             }
    //         } else {
    //             this.onLastPage(nowPage);
    //         }
    //     }
   
    //     if (nowPage > 0 && nowPage <= maxPages) {
    //         pageBlock.forEach(item=>{
    //             if(item.dataset.id){
    //                 // eslint-disable-next-line radix
    //                 if(parseInt(item.dataset.id) === nowPage){
    //                     item.classList.add('active')
    //                 }else{
    //                     item.classList.remove('active')
    //                 }
    //             }
    //         })
    //         this.gotoPage(nowPage, this.getSource());
    //     }
    //   console.log("pagecount", nowPage, this.maxPages)
    // }

    //   /* increments the page number. */
    //   onNext = () => {
    //     var pageNo = this.currentPage + 1;
    //     this.handleButtonNext()
    //     console.log(this.paginate.length, pageNo)
    //     if (this.paginate.length > this.shortPaginate) {
    //         if (pageNo > 10) {
    //             this.nextPrevChange(pageNo);
    //         }
    //     }
    // }

    // /* decrements the page number. */
    // onPrev = () => {
    //     var pageNo = this.currentPage - 1;
    //     this.handleButtonPrevious();
    //     if (this.paginate.length > this.shortPaginate) {
    //         if (pageNo < this.paginate.length) {
    //             if (pageNo > 10) {
    //                 this.nextPrevChange(pageNo);
    //             } else {
    //                 this.noPageChange(pageNo);
    //             }
    //         }
    //     }
      

    // }

    // noPageChange(index){
    //     this.maxPage = 10;
    //     let pagelen = this.paginate.length;
    //     let indexlen = pagelen - (this.maxPage + 1)
    //     if(index === this.maxPage){
    //         this.pages = this.paginate.slice();
    //         this.pages.splice(this.maxPage,indexlen,'...');
    //     }
    // }

    // nextPrevChange(index){
    //     var len = this.paginate.length;//46
    //     if(index !== len ){
    //         this.pages = this.paginate.slice(); 
    //         let startP = index + this.moveNext;
    //         let skiplen = len - (startP + 1);
    //         let inclen = index - this.moveBefore;
    //         if(startP < len){
    //                 this.pages.splice(startP,skiplen,'...');
    //                 this.pages.splice(1,inclen,'...');
    //         }else{
    //             this.pages.splice(1,inclen,'...');
    //         }
    //       console.log("pages",JSON.stringify(this.pages));
    //     }
    // }

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

    getTotalMileage(){
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
        this.pagedData = JSON.parse(JSON.stringify(data)).sort((a, b) => {
            if (colType === "Decimal") {
                a[colName] = (a[colName].indexOf('$') > -1) ? a[colName].replace(/\$/g, "") : a[colName];
                b[colName] = (b[colName].indexOf('$') > -1) ? b[colName].replace(/\$/g, "") : b[colName];
                a = (a[colName] == null || a[colName] === 'null') ? '' : parseFloat(a[colName])
                b = (b[colName] == null || b[colName] === 'null') ? '' : parseFloat(b[colName])
                return a > b ? 1 * isReverse : -1 * isReverse;
            }
            if(colType === "Date"){
                a = (a[colName] == null || a[colName] === '') ? null : new Date(a[colName].toLowerCase())
                b = (b[colName] == null || b[colName] === '') ? null : new Date(b[colName].toLowerCase())
                return a > b ? 1 * isReverse : -1 * isReverse;
            }
                a = (a[colName] == null || a[colName] === '') ? '' : a[colName].toLowerCase();
                b = (b[colName] == null || b[colName] === '') ? '' : b[colName].toLowerCase();
                return a > b ? 1 * isReverse : -1 * isReverse;
            
        });
        //this.sortedData = this.pagedData
        if (!this.search) {
            this.previousIcon = this.sortedDirection
            this.modelData = this.pagedData;
        }else{
            this.searchPreviousIcon = this.sortedDirection
        }
        this.sortedColName = colName;
        this.displaySortIcon(colName, this.sortedDirection);
        this.gotoPage(this.currentPage, this.pagedData);
    }

    defaultSort(column, type){
        console.log("default", column, type);
        let colName = column ? column : undefined;
        let colType = type ? type : undefined;
        // eslint-disable-next-line vars-on-top
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
        this.pagedData = JSON.parse(JSON.stringify(data)).sort((a, b) => {
            if (colType === "Decimal") {
                a[colName] = (a[colName].indexOf('$') > -1) ? a[colName].replace(/\$/g, "") : a[colName];
                b[colName] = (b[colName].indexOf('$') > -1) ? b[colName].replace(/\$/g, "") : b[colName];
                console.log(a[colName], b[colName])
                a = (a[colName] == null || a[colName] === 'null') ? '' : parseFloat(a[colName])
                b = (b[colName] == null || b[colName] === 'null') ? '' : parseFloat(b[colName])
                return a > b ? 1 * isReverse : -1 * isReverse;
            }
            if(colType === "Date"){
                a = (a[colName] == null) ? '' : new Date(a[colName].toLowerCase())
                b = (b[colName] == null) ? '' : new Date(b[colName].toLowerCase())
                return a > b ? 1 * isReverse : -1 * isReverse;
            }
                a = (a[colName] == null || a[colName] === '') ? '' : a[colName].toLowerCase();
                b = (b[colName] == null || b[colName] === '') ? '' : b[colName].toLowerCase();
                return a > b ? 1 * isReverse : -1 * isReverse;
            
        });
        //this.sortedData = this.pagedData
        if (!this.search) {
            this.previousIcon = this.sortedDirection
            this.modelData = this.pagedData;
        }else{
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
        console.log(this.columns);
        // eslint-disable-next-line @lwc/lwc/no-api-reassignments
        this.columns = data;
    }

    getSource() {
        // if(this.sortedData.length > 0){
        //     if (this.search) {
        //         return this.searchData;
        //     } 
        //         return this.sortedData;
        // }
            if (this.search) {
                return this.searchData;
            } 
                return this.modelData;
    }


    proxyToObj(obj) {
        return JSON.parse(JSON.stringify(obj));
    }


    getElement(data, id){
        var object = {};
        for (let i = 0; i < data.length; i++) {
            if(data[i].contactid === id){
                object = data[i];
            }
        }
        return object
    }

    linkHandler(event){
        let id = event.currentTarget.dataset.id;
        let element =  this.getElement(this.modelData, id);
        const linkEvent = new CustomEvent('access', {detail: JSON.stringify(element)});
        this.dispatchEvent(linkEvent);
        const editRecord = new CustomEvent('edit', { detail: id});
        this.dispatchEvent(editRecord);
    }

    numberWithCommas(x) {
        return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }

    @api
    refreshTable(data, key) {
				var sList = [];
        this.modelData = this.proxyToObj(data);
				if(key){
            sList = this.searchData.map(obj => this.modelData.find(o => o[key] === obj[key]) || obj);
            this.searchData = sList;
        }
        this.className = (this.scrollable) ? (this.modelData.length > 6)  ? 'scrollable_wrapper slds-p-right_small' : 'slds-p-right_small overflow-none' : 'slds-p-right_small';
        this.mainClass = (this.scrollable) ? (this.modelData.length > 6) ? 'fixed-container' : 'fixed-container' : this.mainClass;
        if(this.isPaginate){
            this.sortedColumn = this.columns[0].colName;
            this.gotoPage(this.currentPage, this.modelData);
             //  this.totalPages(this.maxPages);
          //   this.setPages();
        }else{
            this.pagedData = [];
            this.pagedData = this.modelData;
        }
     
        if (!this.modelData.length) {
            this.norecord = true;
            this.nopagedata = true;
            this.searchVisible = true;
        }else{
            this.norecord = false;
        }

        if(this.isDefaultSort){
           // this.defaultSort('tripdate', 'Date') 
           this.defaultSort(this.colname, this.coltype, this.sortorder) 
        }
    }

    connectedCallback() {
        // Initialize data table to the specified current page (should be 1)
        console.log("Trip", JSON.stringify(this.modelData))
        this.className = (this.scrollable) ? (this.modelData.length > 6)  ? 'scrollable_wrapper slds-p-right_small' : 'slds-p-right_small overflow-none' : 'slds-p-right_small';
        this.mainClass = (this.scrollable) ? (this.modelData.length > 6) ? 'fixed-container' : 'fixed-container' : this.mainClass;
        if(this.isPaginate){
            this.sortedColumn = this.columns[0].colName;
            this.gotoPage(this.currentPage, this.modelData);
             //  this.totalPages(this.maxPages);
          //   this.setPages();
        }else{
            this.pagedData = [];
            this.pagedData = this.modelData;
        }
     
        if (!this.modelData.length) {
            this.norecord = true;
            this.nopagedata = true;
            this.searchVisible = true;
        }else{
            this.norecord = false;
        }

        if(this.isDefaultSort){
           // this.defaultSort('tripdate', 'Date') 
           this.defaultSort(this.colname, this.coltype, this.sortorder) 
        }
    }

    renderedCallback(){
        var pageBlock = this.template.querySelectorAll('.page-num-block');
        let customIcon = this.template.querySelectorAll('.navigate');
        let _self = this;
        if(pageBlock){
            pageBlock.forEach(item=>{
                if(item.dataset.id){
                    if(item.dataset.id !== '...'){
                         // eslint-disable-next-line radix
                        if(parseInt(item.dataset.id) === this.currentPage){
                            item.classList.add('active')
                        }else{
                            item.classList.remove('active')
                        }
                    }else{
                        item.classList.add('page-num-disabled');
                    }
                }
            })
        }
        if(customIcon){
            customIcon.forEach(ev=>{
                ev.addEventListener('click', function(e){
                    // console.log("Icon----", e, e.currentTarget.dataset.name)
                    // console.log("Icon----", e, e.currentTarget.dataset.id, e.currentTarget.dataset.st, _self.isBiweek )
                    if(e.currentTarget.dataset.name !== undefined){
                        if(_self.isBiweek !== true){
                            events(_self, e.currentTarget.dataset.name)
                        }else{
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
    }

    handleDownload(event){
        event.stopPropagation();
        openEvents(this, event.currentTarget.dataset.key);
    }

    downloadAllTrips(){
        const tripEvent = new CustomEvent('view', {detail: ''});
        this.dispatchEvent(tripEvent);
    }

    handleAllDownload(){
        const singleEvent = new CustomEvent('record', {detail: ''});
        this.dispatchEvent(singleEvent);
    }
}