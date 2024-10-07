import { LightningElement, api ,track} from 'lwc';

export default class newPaginator extends LightningElement {
    currentPage =1;
    totalRecords;
    recordSize;
    visibleRecords;
    totalpagebutton = false;
    totalPage = 0;
    totalPagenew = [];
    pages = [];
    paginate = [];
    setSize;
    @track moveNext = 3;
    @track moveBefore = 3;
    @track shortPaginate = 5;
    @track maxPage = 5;
    currentPagenew;
    @api records;
    @api pageSize;
   
    renderedCallback() {
        this.renderButtons();
    }
    renderButtons = () => {
        this.template.querySelectorAll('a').forEach((but) => {
            if(but.dataset.id != '..'){
                // but.style.backgroundColor = this.currentPage === parseInt(but.dataset.id, 10) ? '#7ABB4A' : '';
                but.style.color = this.currentPage === parseInt(but.dataset.id, 10) ? 'black' : 'rgba(29, 29, 29, 0.40)';
                but.style.fontFamily = this.currentPage === parseInt(but.dataset.id, 10) ? 'Proxima Nova Bold' : 'Proxima Nova';

            }
          else{
              but.classList.remove('slds_link');
              but.classList.add('disable');
          }
        });
    }
    get hasPrev() {
        return this.currentPage > 1;
    }
    /* returns true if the current page is less then the total
           number of pages. */
    get hasNext() {
        if(this.paginate.length > this.shortPaginate){
            return this.currentPage < this.paginate.length
        }else{
            return this.currentPage < this.totalPagenew.length
        }
    }
    connectedCallback(){
        this.updateRecords(this.records,this.pageSize);
    }

    onPrev(){ 
        if(this.currentPage>1){
            //this.hasNext = true;
            this.currentPage = this.currentPage-1
            this.updatedatanew(this.currentPage, this.recordSize)
            if (this.paginate.length > this.shortPaginate) {
                if (this.currentPage < this.paginate.length) {
                    if (this.currentPage > 5) {
                        this.nextPrevChange(this.currentPage);
                    } else {
                        this.noPageChange(this.currentPage);
                    }
                }
            }
        }else if(this.currentPage == 1){
            // this.hasPrev = false;
            // this.hasNext = true;
        }
    }
    onPageClick(event){
        this.currentPage = parseInt(event.target.dataset.id, 10);
       console.log("onpageclick",this.currentPage + '  '+this.recordSize)
        this.updatedatanew(this.currentPage , this.recordSize)
        if (this.paginate.length > this.shortPaginate) {
            this.next;
            if (this.currentPage != this.paginate.length) {
                if (this.currentPage === this.maxPage) {
                    this.next = this.currentPage;
                    this.paginateChange(this.currentPage);
                } else {
                    this.paginateChange(this.currentPage);
                    this.reverseEndPaginate(this.currentPage, this.next);
                }
            } else {
             this.onLastPage(this.currentPage);
                //  this.noPageChange(this.currentPage);
            }
        }
    }
    
    onNext(){
            this.currentPage++;
            this.updatedatanew(this.currentPage , this.recordSize)
            if(this.currentPage == this.paginate.length){
                this.noPageChange(this.currentPage);
                // this.onLastPage(this.currentPage);
            }else{
                if (this.paginate.length > this.shortPaginate) {
                    if (this.currentPage > 5) {
                        this.nextPrevChange(this.currentPage);
                    }
                }
            }
            
    }
    @api updateRecords(totalrecord , recordperPage){ 
        console.log("in page event",totalrecord +'--'+recordperPage)
        this.paginate = [];
        let pagecount = [];
        // this.totalRecords = data;
        this.recordSize = Number(recordperPage);
        this.totalPage = Math.ceil(totalrecord/this.recordSize);
        console.log("totalpage",this.totalPage)
        for(let i=0 ; i < this.totalPage ;i++){
            pagecount.push(i+1) ;
        }
        this.totalPagenew = JSON.parse(JSON.stringify(pagecount));
        this.paginate = JSON.parse(JSON.stringify(pagecount));
        if(this.totalPagenew.length > this.shortPaginate){
            this.mapPages();
        }
        if(this.totalPagenew.length != 0){
            this.totalpagebutton = true;
        }else{
            this.totalpagebutton = false;
        }
        if(this.currentPage == 1){
            this.updatedatanew(this.currentPage,this.recordSize)
        }
        // const start = (this.currentPage-1)*this.recordSize
        // const end = this.recordSize*this.currentPage
        // this.visibleRecords = this.totalRecords.slice(start, end)
        // console.log("this.visibleRecords",this.visibleRecords)
        // this.dispatchEvent(new CustomEvent('update',{ 
            // detail:{ 
                // records:this.visibleRecords
            // }
        // }))
    }
    @api updatedatanew(page,limitSize){
        // let limitSize = this.pageSize;
        let offset = (page - 1) * limitSize ;
        this.dispatchEvent(new CustomEvent('pagechange',{ 
            detail:{ 
                limit:limitSize,
                offset : offset
            }
        }))
    }

    mapPages(){
        this.maxPage = 5;
        var pagelen = this.totalPagenew.length;
        console.log("this.maxPage",this.maxPage + ' ' +pagelen)
        var indexlen = pagelen - (this.maxPage + 1)
        console.log("indexlen",indexlen)
        if(this.totalPagenew.length > this.maxPage){
            this.totalPagenew.splice(this.maxPage,indexlen,"..");
        }
      console.log(this.totalPagenew);
    }

    onLastPage(index){
        let pageSkip = index - 5;
        this.totalPagenew = this.paginate.slice();
        this.totalPagenew.splice(1,pageSkip,'..');
    }
    nextPrevChange(index){
        var len = this.paginate.length;//46
        if(index != len ){
            this.totalPagenew = this.paginate.slice(); 
            var startP = index + this.moveNext;
            var skiplen = len - (startP + 1);
            var inclen = index - this.moveBefore;
            if(startP < len){
                    this.totalPagenew.splice(startP,skiplen,'..');
                    this.totalPagenew.splice(1,inclen,'..');
            }else{
                this.totalPagenew.splice(1,inclen,'..');
            }
        }
    }

    noPageChange(index){
        this.maxPage = 5;
        var pagelen = this.paginate.length;
        var indexlen = pagelen - (this.maxPage + 1)
        if(index === this.maxPage){
            this.totalPagenew = this.paginate.slice();
            this.totalPagenew.splice(this.maxPage,indexlen,'..');
        }
    }

    /* When user moves back while filter pagination*/
    reverseEndPaginate(index, nextClick) {
        if(nextClick === undefined){
            nextClick = this.paginate.length;
            console.log("undefined nextClick")
        }
        if (index < nextClick) {
            if (index >= 5) {
                console.log("index < nextClick")
                this.paginateChange(index);
            } else {
                console.log("else < nextClick")
                this.maxPage = 5;
                var pagelen = this.paginate.length;
                var indexlen = pagelen - (this.maxPage + 1)
                this.totalPagenew = this.paginate.slice();
                this.totalPagenew.splice(this.maxPage, indexlen, '..');
            }
        } else {
            if (index === 1) {
                this.maxPage = 5;
                var pagelen = this.paginate.length;
                var indexlen = pagelen - (this.maxPage + 1)
                this.totalPagenew = this.paginate.slice();
                this.totalPagenew.splice(this.maxPage, indexlen, '..');
            }

        }
        //  console.log('reverse:-', index, nextClick);
    }
    paginateChange(index) {
        var totalpage = this.paginate.length;
        if (index != totalpage) {
            this.totalPagenew = this.paginate.slice();
            this.maxPage = index + this.moveNext;
            this.minPage = index - this.moveBefore;
            var skip = totalpage - (this.maxPage + 1)
            if (this.maxPage != totalpage && this.maxPage < totalpage) {
                this.totalPagenew.splice(this.maxPage, skip, '..');
                this.totalPagenew.splice(1, this.minPage, '..');
            } else if(index < 5){
                console.log('in < 10')
                this.noPageChange(index);
                //this.totalPagenew.splice(1, this.maxPage, '..');
            } else {
                console.log('in else')
                this.totalPagenew.splice(1, this.minPage, '..');
            }
        }
      //  console.log(this.pages);
    }
}