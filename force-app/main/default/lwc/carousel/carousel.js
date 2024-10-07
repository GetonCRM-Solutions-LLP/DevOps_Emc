import { LightningElement, api } from 'lwc';
import LEFT_ICON from '@salesforce/resourceUrl/leftCarouselIcon'; 
import RIGHT_ICON from '@salesforce/resourceUrl/rightCarouselIcon';

export default class Carousel extends LightningElement {
    /* default page number */
    currentPage =1

    @api countStyle = 'is--text--help'
    @api leftIcon = `${LEFT_ICON}#leftIcon`;
    @api rightIcon = `${RIGHT_ICON}#rightIcon`;
    // @api isIconSlider = false;
    isIconSlider = true;
    /* Store data from parent component */
    totalRecords

    @api recordSize = 1
    totalPage = 0

    /* get list from parent component */
    get records(){
        return this.visibleRecords
    }

    /* decorator used to pass list from parent component */
    @api 
    set records(data){
        if(data){ 
            this.totalRecords = data
            // eslint-disable-next-line @lwc/lwc/no-api-reassignments
            this.recordSize = Number(this.recordSize)
            this.totalPage = Math.ceil(data.length/this.recordSize)
            console.log(this.totalPage, data.length,this.recordSize )
            this.updateRecords()
        }
    }

    /* To disable previous button */
    get disablePrevious(){ 
        return this.currentPage<=1
    }

     /* To disable next button */
    get disableNext(){ 
        return this.currentPage>=this.totalPage
    }

     /* Previous button event click */
    previousHandler(){ 
        if(this.currentPage>1){
            this.currentPage = this.currentPage-1
            this.updateRecords()
        }
    }

     /* Next button event click */
    nextHandler(){
        if(this.currentPage < this.totalPage){
            this.currentPage = this.currentPage+1
            this.updateRecords()
        }
    }

    /* Display data based on pagination changed */
    updateRecords(){ 
        const start = (this.currentPage-1)*this.recordSize
        const end = this.recordSize*this.currentPage
        this.visibleRecords = this.totalRecords.slice(start, end)
        console.log(JSON.stringify(this.totalRecords), JSON.stringify(this.visibleRecords))
        this.dispatchEvent(new CustomEvent('update',{ 
            detail:{ 
                records:this.visibleRecords
            }
        }))
    }
}