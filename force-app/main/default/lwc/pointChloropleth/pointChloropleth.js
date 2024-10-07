import { LightningElement, api } from 'lwc';

export default class PointChloropleth extends LightningElement {
    vfHost;
    origin;
    iframeObj;
    renderInitialized = false;
    @api locate;
    @api type;
    @api frameClass;
    @api background;
    @api borderColor;
    @api height;
    @api width;
    @api vH;
    @api margin;
    @api mapNavigation;
    @api spacingTop;
    @api spacingBottom;
    @api title;
    @api reloadChart(){
      this.initializeChart()
    }
    
    initializeChart() {
        // eslint-disable-next-line no-restricted-globals
        let url = location.origin;
        let urlHost = url + '/app/mapPointChart';
        this.vfHost = urlHost;
        this.origin = url;
        // eslint-disable-next-line @lwc/lwc/no-api-reassignments
        this.locate = (this.locate !== undefined) ? this.locate : [];
        console.log("Mapp---", this.locate)
        let obj = {modal : this.locate, title: this.title, background: this.background, border: this.borderColor, height: this.height, width: this.width, navigation: this.mapNavigation, vertical: this.vH, margin: this.margin, top: this.spacingTop, bottom: this.spacingBottom, mapType: this.type}
        let messagePost = JSON.stringify(obj)
        console.log("MEssgae" , messagePost)
        if(this.template.querySelector('.vf-iframe').contentWindow){
                    this.template.querySelector('.vf-iframe').contentWindow.postMessage(messagePost, this.origin)
            }
    }
}