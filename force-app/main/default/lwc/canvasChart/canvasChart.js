/* eslint-disable @lwc/lwc/no-document-query */
/* eslint-disable no-else-return */
/* eslint-disable vars-on-top */
/*
 * @Author: GetonCRM Solutions LLP - Megha Sachania 
 * @Date: 2024-02-13 17:22:23 
 * @Modification logs
 * ========================================================================================================================
 * @Last Modified by: Megha Sachania
 * @Last Modified time: 2024-02-16 14:48:22
 * @Description: This component shows combination of bar and line graph from Highcharts
 */
import {
    LightningElement,
    api
} from 'lwc';
import {
    loadScript,
    loadStyle
} from 'lightning/platformResourceLoader';
import highchartsResource from '@salesforce/resourceUrl/HighChart';
// import Chart from '@salesforce/resourceUrl/chartJs';
export default class CanvasChart extends LightningElement {
    error;
    chart;
    chartV;
    chartJsInitialized = false;
    @api chartComponent;
    @api chartData;
    @api defaultMonth;
    config;

    /**
     * @author: Megha Sachania
     * @method: reflowChart
     * @description: This method is used to call from parent component when toggle of sidebar so that the chart becomes responsive
     */
    @api reflowChart() {
        var _self = this
        setTimeout(function() {
						if(_self.chartV){
            	 _self.chartV.setSize(
                _self.refs.chartRef.offsetWidth - 20,
                _self.refs.chartRef.offsetHeight - 20,
                true
            	);
            	_self.chartV.reflow();
            }
        }, 200);
    }

    /**
     * @author: Megha Sachania
     * @method: runHighcharts
     * @description: This method is used to load chart once Highchart Scripts has been loaded
     */
    runHighcharts(){
        var  options, chartView, containerChart, _self = this, monthHighlighted, current, monthTo;
        containerChart = this.refs.chartRef
        if (this.chartData !== undefined) {
            let listOfChart = this.chartData;
            let currentMonth = new Date().getMonth();
            let monthList = this.defaultMonth;
            monthHighlighted = this.getMonthName(currentMonth)
            let backgroundColorA = [
                'rgba(217,217,217,1)',
                'rgba(217,217,217,1)',
                'rgba(217,217,217,1)',
                'rgba(217,217,217,1)',
                'rgba(217,217,217,1)',
                'rgba(217,217,217,1)',
                'rgba(217,217,217,1)',
                'rgba(217,217,217,1)',
                'rgba(217,217,217,1)',
                'rgba(217,217,217,1)',
                'rgba(217,217,217,1)',
                'rgba(217,217,217,1)'
            ]

            if(containerChart){
                options = {
                    chart: {
                        zoomType: 'xy',
                        events: {
                            load: function() {
                                let chart = this, x, fx;
                                chart.series[0].points.forEach(p => {
                                if (p.category === monthHighlighted.substring(0, 3)) {
                                    x = p.x;
                                    fx = (x === 11) ? 0 : x + 1
                                    if(p.graphic){
                                        p.graphic.element.style.fill = 'rgba(235, 188, 54, 0.8)'
                                    }
                                }
                                })
                            }
                        }
                    },
                    title: {
                        text: '',
                    },
                    exporting: {
                        enabled: false
                    },
                    credits: {
                        enabled: false
                    },
                    xAxis: [{
                        categories: listOfChart.chartLabel,
                        labels:{
                            style:{
                                color: "#000000",
                                fontFamily: 'Proxima Nova Bold'
                            },
                            formatter: function () {
                                var now = new Date()
                                var label = this.axis.defaultLabelFormatter.call(this),
                                series = this.chart.series[0];
                                if (now.getMonth() == 11) {
                                    current = new Date(now.getFullYear() + 1, 0, 1);
                                } else {
                                    current = new Date(now.getFullYear(), now.getMonth() + 1, 1);
                                }
                                monthTo = _self.getMonthName(current.getMonth());
                              if (
                                Highcharts.defined(
                                  series.xData.find((x, i) => {
                                    return this.pos === x && series.yData[i] !== 0;
                                  }, this)
                                )
                              ) {
                                if(label === monthTo.substring(0, 3)){
                                    label = '<span style="fill: rgb(153, 153, 153);">' + label + '</span>';
                                }else{
                                    series.xData.find((x, i) => {
                                        if(this.pos === x && series.yData[i] === null){
                                            label = '<span style="fill: rgba(217,217,217,0.5);">' + label + '</span>'
                                        }else{
                                            label = label
                                        }
                                    })
                                }
                              }
                              return label;
                            }
                            
                        },
                        // crosshair: true,
                        lineWidth: 0, 
                        gridLineWidth: 0
                    }],
                    yAxis: [{
                        min: 0,
                        title: {
                            text: null
                        },labels:{
                            style:{
                                color: "#000000",
                                fontFamily: 'Proxima Nova'
                            },
                            formatter: function () {
                                const label = this.axis.defaultLabelFormatter.call(this);
                                
                                // Use thousands separator for four-digit numbers too
                                 // Convert the number to a string and splite the string every 3 charaters from the end
                                 this.value = this.value.toString();
                                 this.value = this.value.split(/(?=(?:...)*$)/);
                                 this.value = this.value.join(',');
                                 if (_self.chartComponent === 'Reimbursement') {
                                     return '$' + this.value;
                                 }else{
                                     return this.value;
                                 }
                               /* if (/^[0-9]{4}$/.test(label)) {
                                    return Highcharts.numberFormat(this.value, 0);
                                }
                                return label;*/
                            }
                        },
                        gridLineWidth: 0
                   }],
                    tooltip: {
                        shared: true
                    },
                    responsive:{
                        rules:[{
                            condition:{
                                maxWidth: 500
                            }
                        }]
                    },
                    legend: {
                        reversed: true,
                        itemMarginTop: 5,
                        itemMarginBottom: 5,
                        itemStyle: {
                            fontFamily: "Proxima Nova Bold",
                            fontWeight: "normal"
                        },
                        backgroundColor:
                            Highcharts.defaultOptions.legend.backgroundColor || // theme
                            'rgba(255,255,255,0.25)'
                    },
                    plotOptions: {
                        series: {
                            cursor: 'pointer',
                            pointWidth: 20,
                           // groupPadding: 0.25,
                            maxPointWidth: 50,
                            point: {
                                events: {
                                  mouseOver() {
                                    const point = this, x = currentMonth === 11 ? 0 : currentMonth + 1;
                                    if (point.index > x) // specific condition for point
                                      return false;
                                  }
                                }
                            },
                            marker: {
                                enabled: false,
                                states: {
                                    hover: {
                                        enabled: false
                                    }
                                }
                            }
                        }
                    },
                    tooltip: {
                        useHTML: true,
                        padding: 10,
                        formatter: function () {
                                const monthData = ["January", "February", "March", "April", "May", "June",
                                "July", "August", "September", "October", "November", "December"
                                ];                               
                                const title = _self.getFullMonth(this.x, monthData)
                                const stringA = (_self.chartComponent === 'Reimbursement') ? ': $' : ': '
                                return this.points.reduce(function (s, point) {
                                    return s + '<br/><b>' + point.series.name  + '</b>' + stringA +
                                        (point.y).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",") ;
                                }, '<b style="color: #7abb4a; font-size: 12px">' + title + '</b><div style="border-bottom: 1px solid; padding: 2px 0 2px 0"></div>');
                        },
                        shared: true,
                        style: {
                            color: "#1d1d1d",
                            fontFamily: "Proxima Nova",
                        },
                        borderColor: "#7abb4a",
                    },
            
                    series: [{
                        name: listOfChart.labelA,
                        type: 'column',
                        color: 'rgba(217,217,217,1)',
                        yAxis: 0,
                        data: [...listOfChart.dataA],
                    }, {
                        name: listOfChart.labelB,
                        type: 'line',
                        color:  'rgba(122, 187, 74, 1)',
                        yAxis:0,
                        data: [...listOfChart.dataB]
                    }]
                }
                chartView = Highcharts.chart(containerChart, options);
                this.chartV = chartView;
            }
        }
    }

    /**
     * @author: Megha Sachania
     * @method: renderedCallback
     * @description: called after a component has finished the rendering phase.
     */
    renderedCallback() {
        var _self = this;
        if (this.chartJsInitialized) {
            return;
        }
        /* Load Static Resource For Script*/
        loadScript(this, highchartsResource + "/highcharts.js")
        .then(() => {
               console.log("SUCCESS: highcharts.js");

                loadScript(this, highchartsResource + "/export-data.js")

                    .then(() => {
                        try {
                        console.log("SUCCESS: export-data.js");
                        this.runHighcharts();
                        }catch(e){
                            console.log("Excep", e.message)
                        }

                    })

                    .catch(error => console.log("ERROR: export-data.js", error.message));

        })

        .catch(error => console.log("ERROR: highcharts.js", error.message))
    }

     /**
     * @author: Megha Sachania
     * @method: getFullMonth
     * @description: Used to get full month name based on first 3 character.
     * @returns: For example if params = 'Feb' then returns 'February'
     */
    getFullMonth(params, list){
        let month = ''
        list.forEach((element) => {
            if (params === element.substring(0, 3)) {
                month = element
            }
        })
        return month
    }

     /**
     * @author: Megha Sachania
     * @method: getMonthName
     * @description: Used to get full month name based on month index.
     * @returns: For example if monthIndex = '0' then returns 'January'
     */
    getMonthName(monthIndex) {
        let daymonth = new Array();
        daymonth[0] = "January";
        daymonth[1] = "February";
        daymonth[2] = "March";
        daymonth[3] = "April";
        daymonth[4] = "May";
        daymonth[5] = "June";
        daymonth[6] = "July";
        daymonth[7] = "August";
        daymonth[8] = "September";
        daymonth[9] = "October";
        daymonth[10] = "November";
        daymonth[11] = "December";
        return daymonth[monthIndex];
    }

}