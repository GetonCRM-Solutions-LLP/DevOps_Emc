/* eslint-disable no-unused-vars */
/* eslint-disable vars-on-top */
/* eslint-disable no-console */
import {
    LightningElement,
    track,
    api
} from 'lwc';
export default class HelloWorld extends LightningElement {
    @track greeting;
    @track formatNumberStart;
    @track formatNumberEnd;
    @track error;
    @api clearAll() {
        this.formatNumberStart = '';
        this.formatNumberEnd = '';
    }
    changeHandler(event) {
        this.greeting = event.target.value;
    }
    handleChangeStart(event) {
        let entry = event.target.value;
        const mileageEvent = new CustomEvent("handlemileagechange", {
            detail: entry
        });
        this.dispatchEvent(mileageEvent);
        let lastChar = entry.slice(-1);
        //  console.log('lastChar'+isNaN(lastChar));
        //  console.log(entry, entry.slice(0,-1), lastChar, isNaN(lastChar));
        this.error = '';
        if (lastChar === '.') {
            console.log('inside if');
        } else if (isNaN(lastChar)) {
            var inputCmp = this.template.querySelector('[data-entry]');
            this.template.querySelector('[data-entry]').value = entry.slice(0, -1);
            this.error = 'Enter numeric value';
        }
        this.greeting = event.target.value;
        console.log('this' + this.greeting);
        if (this.greeting.indexOf(',') > 0) {
            this.greeting = this.greeting.replace(/,/g, "");
        }
        //truncate to 2 decimal
        if (this.greeting.includes('.')) {
            if (this.greeting.substr(this.greeting.indexOf('.')).length > 3) {
                this.greeting = Number(this.greeting).toFixed(2);
            }
        }
        this.formatNumberStart = addCommas(this.greeting);

        function addCommas(str) {
            var x = str;
            var afterPoint = '';
            var otherNumbers;
            var lastThree;
            var res;
            x = x.toString();
            if (x.indexOf('.') > 0)
                afterPoint = x.substring(x.indexOf('.'), x.length);
            x = Math.floor(x);
            x = x.toString();
            lastThree = x.substring(x.length - 3);
            otherNumbers = x.substring(0, x.length - 3);
            if (otherNumbers !== '')
                lastThree = ',' + lastThree;
            res = otherNumbers.replace(/\B(?=(\d{2})+(?!\d))/g, ",") + lastThree + afterPoint;
            return res;
        }
    }

    handleChangeEnd(event) {
        let Endentry = event.target.value;
        const mileageEndEvent = new CustomEvent("handlemileagechangeatend", {
            detail: Endentry
        });
        this.dispatchEvent(mileageEndEvent);
        let lastChar = Endentry.slice(-1);
        // console.log('lastChar'+isNaN(lastChar));
        // console.log(entry, entry.slice(0,-1), lastChar, isNaN(lastChar));
        this.error = '';
        if (lastChar === '.') {
            console.log('inside if');
        } else if (isNaN(lastChar)) {
            var inputCmp = this.template.querySelector('[data-entry]');
            this.template.querySelector('[data-entry]').value = Endentry.slice(0, -1);
            this.error = 'Enter numeric value';
        }
        this.greeting = event.target.value;
        // console.log('this'+this.greeting);
        if (this.greeting.indexOf(',') > 0) {
            this.greeting = this.greeting.replace(/,/g, "");
        }
        //truncate to 2 decimal
        if (this.greeting.includes('.')) {
            if (this.greeting.substr(this.greeting.indexOf('.')).length > 3) {
                this.greeting = Number(this.greeting).toFixed(2);
            }
        }
        this.formatNumberEnd = addCommas(this.greeting);

        function addCommas(str) {
            var x = str;
            var afterPoint = '';
            var otherNumbers;
            var lastThree;
            var res;
            x = x.toString();
            if (x.indexOf('.') > 0)
                afterPoint = x.substring(x.indexOf('.'), x.length);
            x = Math.floor(x);
            x = x.toString();
            lastThree = x.substring(x.length - 3);
            otherNumbers = x.substring(0, x.length - 3);
            if (otherNumbers !== '')
                lastThree = ',' + lastThree;
            res = otherNumbers.replace(/\B(?=(\d{2})+(?!\d))/g, ",") + lastThree + afterPoint;
            return res;
        }
    }
    keyHandler(event) {
        var x;
        x = event.which || event.keycode;
        //truncate to 2 decimal
        this.greeting = event.target.value;
        if (this.greeting.includes('.')) {
            let test = this.greeting.substr(Number(this.greeting.indexOf('.')));
            if (test.length > 2) {
                if (!(x === 8 || (x >= 37 && x <= 40) || x === 46)) {
                    event.preventDefault();
                }
            }
        }
    }
    handleBlur(event) {
        console.log('onblurfun');
        var x;
        x = event.which || event.keycode;
        //truncate to 2 decimal
        this.greeting = event.target.value;
        if (this.greeting.includes('.')) {
            let test = this.greeting.substr(Number(this.greeting.indexOf('.')));
            console.log('test' + test.length);
            if (test.length === 2) {
                console.log('test---' + test.length);
                this.greeting = this.greeting.toString();
                console.log('this.greeting-----' + this.greeting + '0');
                this.greeting = this.greeting + '0';
                this.formatNumberStart = this.greeting;
                this.formatNumberEnd = this.greeting;
            }
        }
    }
}