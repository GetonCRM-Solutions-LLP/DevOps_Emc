import { LightningElement, api, track  } from 'lwc';
import jQueryMinified from '@salesforce/resourceUrl/jQueryMinified';
import datepicker from '@salesforce/resourceUrl/calendar';
import customMinifiedDP  from '@salesforce/resourceUrl/modalCalDp';
import { loadStyle , loadScript } from 'lightning/platformResourceLoader';

export default class DatePicker extends LightningElement {
    @api date;
    @api dateFormat;
    @api isDisable = false;
    /** Used to disable dates */
    @api minDate = '';
    @api maxDate = '';
    @api isSelectedDate = false;

    @api cmpClass = 'flat-container';
	  isWidgetVisible = false;
    constructor() {
      super();
      this.handleKeyDown = this.handleKeyDown.bind(this);
    }
    connectedCallback() {
      window.addEventListener('keydown', this.handleKeyDown);
      loadScript(this, jQueryMinified)
      .then(() => {
          Promise.all([
            loadStyle(this, datepicker + "/minifiedCustomDP.css"),
            loadStyle(this, datepicker + "/datepicker.css"),
            loadStyle(this, customMinifiedDP),
            loadScript(this, datepicker + '/datepicker.js')
          ]).then(() => {
              this.calendarJsInitialised = true;
              console.log(this.minDate, this.maxDate)
              this.intializeDatepickup();
            })
            .catch((error) => {
              console.error(error);
            });
      })
      .catch(error => {
        console.log('jquery not loaded ' + error )
      })
    }

    intializeDatepickup(){
        let $jq = jQuery.noConflict();
        let $input =  $jq(this.template.querySelectorAll('.date-selector'));
        let _self = this;

        $input.each(function(index) {
              let _self2 =  $jq(this)
              let $btn =  $jq(this).next()
              let tempDatePicker = 
              $jq(this).datepicker({
    
                // inline mode
                inline: false,
    
                // additional CSS class
                classes: 'flatpickr-cal',
    
                // language
                language: 'en',
    
                // start date
                startDate: new Date(),
                //selectedDates: new Date(),
                
                // array of day's indexes
                weekends: [6, 0],
    
                // custom date format
                dateFormat: _self.dateFormat,
    
                // Alternative text input. Use altFieldDateFormat for date formatting.
                altField: '',
    
                // Date format for alternative field.
                altFieldDateFormat: '@',
    
                // remove selection when clicking on selected cell
                toggleSelected: false,
    
                // keyboard navigation
                keyboardNav: false,
    
                // position
                position: 'bottom left',
                offset: 12,
    
                // days, months or years
                view: 'days',
                minView: 'days',
                showOtherMonths: true,
                selectOtherMonths: true,
                moveToOtherMonthsOnSelect: true,
    
                showOtherYears: true,
                selectOtherYears: true,
                moveToOtherYearsOnSelect: true,
    
                minDate: _self.minDate,
                maxDate: _self.maxDate,
                disableNavWhenOutOfRange: true,
    
                multipleDates: false, // Boolean or Number
                multipleDatesSeparator: ',',
                range: false,
                isMobile: false,
                // display today button
                todayButton: new Date(),
    
                // display clear button
                clearButton: false,
                
                // Event type
                showEvent: 'focus',
    
                // auto close after date selection
                autoClose: true,
    
                // navigation
                monthsFiled: 'monthsShort',
                prevHtml: '<svg><path d="M 17,12 l -5,5 l 5,5"></path></svg>',
                nextHtml: '<svg><path d="M 14,12 l 5,5 l -5,5"></path></svg>',
                navTitles: {
                    days: 'M <i>yyyy</i>',
                    months: 'yyyy',
                    years: 'yyyy1 - yyyy2'
                },
                
                // timepicker
                datepicker: true,
                timepicker: false,
                onlyTimepicker: false,
                dateTimeSeparator: ' ',
                timeFormat: '',
                minHours: 0,
                maxHours: 24,
                minMinutes: 0,
                maxMinutes: 59,
                hoursStep: 1,
                minutesStep: 1,
                // callback events
                onSelect: function(date, formattedDate, datepicker){
                    //datepicker.$el.val(_self2.val())
                    const onDateSelect = new CustomEvent('dateselect', {
                      detail : date
                    });
                    _self.dispatchEvent(onDateSelect);
                },

                onShow: function (dp, animationCompleted) {
				          _self.isWidgetVisible = true;
                 // _self.date = dp.$el.val()
                  if (!animationCompleted) {
                    if (dp.$datepicker.find('span.datepicker--close--button').html()===undefined) { /*ONLY when button don't existis*/
                        dp.$datepicker.find('div.datepicker--buttons').append('<span  class="datepicker--close--button">Close</span>');
                        dp.$datepicker.find('span.datepicker--close--button').click(function() {
                          dp.hide();
                          console.log('onshow');
                        });
                    }
                  }
                },
                // onShow: '',
                onHide: function() {
					      _self.isWidgetVisible = false;
				        },
                onChangeMonth: '',
                onChangeYear: '',
                onChangeDecade: '',
                onChangeView: '',
                // eslint-disable-next-line consistent-return
                onRenderCell: function(date){
                    if (date.getDay() === 0) {
                          return {
                              classes: 'color-weekend-sunday'
                          }
                    }
                    if (date.getDay() === 6) {
                          return {
                              classes: 'color-weekend-saturday'
                          }
                    }
                }
              })//.data('datepicker').selectDate(new Date(_self2.val()))
              if(_self.isSelectedDate == true && _self2.val() != '') {
                tempDatePicker.data('datepicker').selectDate(new Date(_self2.val()));
              }
              $btn.on('click', function(){
                console.log('Inside button click');
                _self2.datepicker({showEvent: 'none'}).data('datepicker').show();
                _self2.focus();
                const onDateSelect = new CustomEvent('dateselect', {
                  detail : _self.date
                });
                _self.dispatchEvent(onDateSelect);
              });
        })
      }

    handleKeyDown = (event) =>{
        if (event.keyCode === 27) {
           // console.log('Esc key pressed.');
            // write code to hide date picker
            let $jq = jQuery.noConflict();
            let $input = $jq(this.template.querySelectorAll('.date-selector'))
            $input.each(function(index) {
              let _self2 =  $jq(this)
              _self2.datepicker({showEvent: 'none'}).data('datepicker').hide();
            })
        }

        if (event.keyCode === 8) {
          // Backspace key was pressed
          let $jq = jQuery.noConflict();
          let $input = $jq(this.template.querySelectorAll('.date-selector'))
          let _self = this;
          $input.each(function(index) {
            let _self2 =  $jq(this)
          if(_self.isWidgetVisible) {
            _self2.datepicker({showEvent: 'none'}).data('datepicker').clear();
            const onDateSelect = new CustomEvent('dateselect', {
              detail : ''
            });
            _self.dispatchEvent(onDateSelect);
          }
          })
          // Add your desired logic here
        }
    }
}