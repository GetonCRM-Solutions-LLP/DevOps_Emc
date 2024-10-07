import { LightningElement, api } from 'lwc';

export default class ChartViewDashboard extends LightningElement {
    @api chartList;
    @api viewName;
    vfHost;
    origin;
    iframeObj;
    initializeChart() {
        // eslint-disable-next-line no-restricted-globals
        let url = location.origin;
        let urlHost = url + '/app/chartDashboard';
        console.log("list", this.chartList)
        this.vfHost = urlHost;
        this.origin = url;
        if(this.chartList){
            let statusList = [];
            statusList = JSON.parse(this.chartList);
            statusList.view = this.viewName;
            console.log("status", statusList);
            if(this.template.querySelector('.vf-iframe').contentWindow){
                this.template.querySelector('.vf-iframe').contentWindow.postMessage(JSON.stringify(statusList), this.origin)
            }
        }
       
    }
}