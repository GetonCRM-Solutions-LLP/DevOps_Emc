import {
    LightningElement,
    track,
    api
} from 'lwc';

export default class Paginator extends LightningElement {
    @api perPageSize; // no of the pages we want to show at a time. no of page number buttons.
    @api pageCount = 1;
    @track pages = [];
    @track paginate = [];
    @track setSize;
    @track moveNext = 3;
    @track moveBefore = 7;
    @track shortPaginate = 10;
    @track maxPage = 10;
    /* Data For Pagination */
    @api pageData(data,pageSize) {
        this.setPages(data,pageSize);
    }

    @api defaultPageSize(totalPage, perSize){
        this.pages = [];
        this.paginate = [];
        console.log('inside paginate default', totalPage , perSize, Math.ceil( totalPage / perSize));
        let numberOfPages = Math.ceil( totalPage / perSize);
        for (let index = 1; index <= numberOfPages; index++) {
            this.pages.push(index);
            this.paginate.push(index);
        }
        if(this.paginate.length > this.shortPaginate){
            this.mapPages();
       }
    }
    /* Hightlight Current Page Number */
    renderedCallback() {
        this.renderButtons();
    }
    renderButtons = () => {
        this.template.querySelectorAll('a').forEach((but) => {
            if(but.dataset.id != '..'){
                but.style.backgroundColor = this.pageCount === parseInt(but.dataset.id, 10) ? 'dodgerblue' : '';
                but.style.color = this.pageCount === parseInt(but.dataset.id, 10) ? 'white' : 'black';
            }
          else{
              but.classList.remove('slds_link');
              but.classList.add('disable');
          }
        });
    }

    /* To display Page Numbers */
    get pagesList() {
            console.log('inside pagesList');
            this.setSize = this.pages.length
            console.log(this.setSize);
            // let mid = Math.floor(this.setSize / 2) + 1;
            // if (this.pageCount > mid) {
            //     return this.pages.slice(this.pageCount - mid, this.pageCount + mid - 1);
            // }
            return  this.pages.slice(0, this.setSize);
    }



    setPages = (data,pageSize) => {
        this.pages = [];
        this.paginate = [];
        this.perPageSize = pageSize;
        //console.log('setPages called',this.perPageSize);
        let numberOfPages = Math.ceil(data.length / this.perPageSize);
        for (let index = 1; index <= numberOfPages; index++) {
            this.pages.push(index);
            this.paginate.push(index);
        }
      // console.log(this.pages,this.paginate,numberOfPages);
      if(this.paginate.length > this.shortPaginate){
           this.mapPages();
      }
     
    }

      /* To display Filtered Pagination */
    mapPages(){
        var pagelen = this.pages.length;
        var indexlen = pagelen - (this.maxPage + 1)
        if(this.pages.length > this.maxPage){
            this.pages.splice(this.maxPage,indexlen,"..");
        }
      console.log(this.paginate,this.pages);
    }

    /* if filtered pagiantion used then when user is on last page*/
    onLastPage(index){
        let pageSkip = index - 10;
        this.pages = this.paginate.slice();
        this.pages.splice(1,pageSkip,'..');
    }

    /* Next Previous Button Click when using filtered pagination */
    nextPrevChange(index){
        var len = this.paginate.length;//46
        if(index != len ){
            this.pages = this.paginate.slice(); 
            var startP = index + this.moveNext;
            var skiplen = len - (startP + 1);
            var inclen = index - this.moveBefore;
            if(startP < len){
                    this.pages.splice(startP,skiplen,'..');
                    this.pages.splice(1,inclen,'..');
            }else{
                this.pages.splice(1,inclen,'..');
            }
         //   console.log(this.pages);
        }
    }

    noPageChange(index){
        this.maxPage = 10;
        var pagelen = this.paginate.length;
        var indexlen = pagelen - (this.maxPage + 1)
        if(index === this.maxPage){
            this.pages = this.paginate.slice();
            this.pages.splice(this.maxPage,indexlen,'..');
        }
    }

    /* When user moves back while filter pagination*/
    reverseEndPaginate(index, nextClick) {
        if(nextClick === undefined){
            nextClick = this.paginate.length;
        }
        if (index < nextClick) {
            if (index >= 10) {
              //  console.log("inside paginateChange")
                this.paginateChange(index);
            } else {
                this.maxPage = 10;
                var pagelen = this.paginate.length;
                var indexlen = pagelen - (this.maxPage + 1)
                this.pages = this.paginate.slice();
                this.pages.splice(this.maxPage, indexlen, '..');
            }
        } else {
            if (index === 1) {
                this.maxPage = 10;
                var pagelen = this.paginate.length;
                var indexlen = pagelen - (this.maxPage + 1)
                this.pages = this.paginate.slice();
                this.pages.splice(this.maxPage, indexlen, '..');
            }

        }
        //  console.log('reverse:-', index, nextClick);
    }
    paginateChange(index) {
        var totalpage = this.paginate.length;
        if (index != totalpage) {
            this.pages = this.paginate.slice();
            this.maxPage = index + this.moveNext;
            this.minPage = index - this.moveBefore;
            var skip = totalpage - (this.maxPage + 1)
            if (this.maxPage != totalpage && this.maxPage < totalpage) {
                this.pages.splice(this.maxPage, skip, '..');
                this.pages.splice(1, this.minPage, '..');
            } else {
                this.pages.splice(1, this.minPage, '..');
            }
        }
      //  console.log(this.pages);
    }
    /* returns true if current page is not first page. */
  
    get hasPrev() {
        return this.pageCount > 1;
    }


    /* returns true if the current page is less then the total
           number of pages. */
    get hasNext() {
        if(this.paginate.length > this.shortPaginate){
            return this.pageCount < this.paginate.length
        }else{
            return this.pageCount < this.pages.length
        }
      
    }
    /* increments the page number. */
    onNext = () => {
        ++this.pageCount;
        if (this.paginate.length > this.shortPaginate) {
            if (this.pageCount > 10) {
                this.nextPrevChange(this.pageCount);
            }
        }
        const pageEvent = new CustomEvent("handlepageclick", {
            detail: this.pageCount
        })

        this.dispatchEvent(pageEvent);
    }

    /* decrements the page number. */
    onPrev = () => {
        --this.pageCount;
        if (this.paginate.length > this.shortPaginate) {
            if (this.pageCount < this.paginate.length) {
                if (this.pageCount > 10) {
                    this.nextPrevChange(this.pageCount);
                } else {
                    this.noPageChange(this.pageCount);
                }
            }
        }
        const pageEvent = new CustomEvent("handlepageclick", {
            detail: this.pageCount
        })

        this.dispatchEvent(pageEvent);
    }

    /* Pagination Click Method */
    onPageClick = (e) => {
        this.pageCount = parseInt(e.target.dataset.id, 10);
        if (this.paginate.length > this.shortPaginate) {
            this.next;
            //console.log("buttonClick",this.maxPage,this.pageCount);
            if (this.pageCount != this.paginate.length) {
                if (this.pageCount === this.maxPage) {
                    this.next = this.pageCount;
                    this.paginateChange(this.pageCount);
                  //  console.log('move1',this.next);
                } else {
                    this.reverseEndPaginate(this.pageCount, this.next);
                   // console.log('move',this.next);
                }
            } else {
                this.onLastPage(this.pageCount);
            }
        }
        const pageEvent = new CustomEvent("handlepageclick", {
            detail: this.pageCount
        })

        this.dispatchEvent(pageEvent);
    }

}