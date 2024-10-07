import {
    LightningElement,
    track,
    api
} from 'lwc';

import {
    loadStyle
} from 'lightning/platformResourceLoader';
import customSR from '@salesforce/resourceUrl/customMinifiedDP';

export default class HelloWorld extends LightningElement {
    @track calStartDate;
    @track calEndDate;
    @track min = Date.now();
    @track fnlmin = this.min - 5184000000;
    @track fnlMax = this.min + 5184000000;
    @track formattedStartDate;
    @track formattedEndDate;
    @track startDate;
    @track endDate;
    @track date1 = new Date(this.fnlmin);

    /* fires after every render of the component. */
    renderedCallback() {
        /* Load Static Resource For Css*/
        Promise.all([
            loadStyle(this, customSR)
        ])
    }

    @api clearAll(){
       var input = this.template.querySelectorAll('lightning-input');
       input.forEach( inputVal => {
            inputVal.value = '';
       })
    }
    /* From Date Change Event */

    changeHandler(event) {
        this.calStartDate = event.target.value;
        // this.StartDateFormat();
        const selectedEvent = new CustomEvent("handlestartdateclickevent", {
            detail: this.calStartDate
        });
        this.dispatchEvent(selectedEvent);
        //  console.log(selectedEvent);
    }

    /* To Date Change Event */
    changeEndDateHandler(event) {
        this.calEndDate = event.target.value;

        const selectedEvent = new CustomEvent("enddateclickevent", {
            detail: this.calEndDate
        });
        this.dispatchEvent(selectedEvent);

    }

    /* Restrict alphabet on input */
    keyHandler(event){
        var dateCode = (event.which) ? event.which : event.keyCode;
		if (dateCode != 47 && dateCode != 46 && dateCode > 31 && (dateCode < 48 || dateCode > 57)){
			if (event.preventDefault) {
				event.preventDefault();
			} 
			else {
					event.returnValue = false;
			} 
		}
    }
   
    /* fires when a component is inserted into the DOM. */

    connectedCallback() {
        var date1;
        var date2;
        date1 = new Date(this.fnlmin);
        this.formattedStartDate = date1.getFullYear() + "-" + (date1.getMonth() + 1) + "-" + date1.getDate()
        date2 = new Date(this.fnlMax);
        this.formattedEndDate = date2.getFullYear() + "-" + (date2.getMonth() + 1) + "-" + date2.getDate()
    }

    /* Date Format Starts */
    StartDateFormat() {
        this.startDate = new Date(this.calStartDate);
        this.startDate = (this.startDate.getMonth() + 1) + "/" + this.startDate.getDate() + "/" + ((this.startDate.getFullYear()).toString()).slice(-2);

    }
    EndDateFormat() {
        this.endDate = new Date(this.calEndDate);
        this.endDate = (this.endDate.getMonth() + 1) + "/" + this.endDate.getDate() + "/" + ((this.endDate.getFullYear()).toString()).slice(-2);

    }
    /* Date Format ends */
}