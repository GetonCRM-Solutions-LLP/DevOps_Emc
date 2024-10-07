import {
  LightningElement,
  track,
  api
} from 'lwc';

export default class DatetimeComponent extends LightningElement {
  @track dateValue;
  @api strtimeValue;
  @api entimeValue;

  // Get Data From Parent Component
  @api getTime(dateV) {
    this.dateValue = this.dateFormat(dateV);
  }

  // To Restrict User Input Starts -->
  handleEditInput(event) {
    event.preventDefault();
    return false;
  }
  handleClickInput(event) {
    event.preventDefault();
    return false;
  }
  // To Restrict User Input Ends -->

  // Format Date
  dateFormat(date) {
    if (date != '') {
      let newdate = new Date(date);
      let dd = newdate.getDate();
      let mm = newdate.getMonth() + 1;
      let yy = newdate.getFullYear();
      return mm + "/" + ('0' + dd).slice(-2) + "/" + yy;
    } else {
      return "";
    }
  }
}