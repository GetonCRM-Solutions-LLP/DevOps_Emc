import { LightningElement, api} from 'lwc';
import resourceImage from '@salesforce/resourceUrl/mBurseCss';
import driverDetails from '@salesforce/apex/NewAccountDriverController.getContactDetail';
import { events } from 'c/utils';
export default class DashboardInsuranceView extends LightningElement {
    @api videoLink;
    @api expired;
    @api videoCss;
    @api css;
    video;
    videoWidth = 396;
    videoHeight = 223;
    isPlay = false;
    @api contactId;
    @api  accountId;
    information;
    renderInitialized = false;
    exclaimIcon = resourceImage + '/mburse/assets/mBurse-Icons/exclaim.png';
    
    // /* decorator used to pass list from parent component */
    // @api 
    // videoStyle(data){
    //         if(data){ 
    //             this.videoCss = data
    //         }
    //  }
    // /* decorator used to pass list from parent component */
    // @api 
    // cssStyle(data){
    //         if(data){ 
    //             this.css = data
    //         }
    // }

     /* Get url parameters */
    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }
    /* Move to next page */
    nextDeclarationUpload(){
        events(this, 'Next Declaration Upload')
    }

    /* converts string to json object */
    proxyToObject(e) {
        return JSON.parse(e)
    }

    /* play video on click of button */
    playVideo(){
        this.isPlay = true;
    }

    callApex() {
        driverDetails({
            contactId: this.contactId
          })
          .then((data) => {
            if (data) {
              console.log("getContactDetail",data);
              this.information = data;
            }
          })
          .catch((error) => {
            console.log('Error', error)
          })
    }

    /* rendered callback */ 
    renderedCallback() {
        if (this.renderInitialized) {
            return;
        }
        this.renderInitialized = true;
        let pathname = window.location.pathname;
        if(this.template.querySelector('.transition')){
            if(pathname !== "/app/driverProfileDashboard")
                this.template.querySelector('.transition').style.paddingTop = "80px"
        }

        if(this.template.querySelector('video-frame')){
            this.template.querySelector('video-frame').load();
        }
    }

}