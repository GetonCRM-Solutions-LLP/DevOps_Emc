import {
  LightningElement, wire, api
} from 'lwc';
import getCustomSettings from '@salesforce/apex/NewAccountDriverController.getCustomSettings';
export default class CarouselPopover extends LightningElement {
  @api totalContacts;
  @api styleCarousel;
  @api styleHeader;
  @api styleFooter;
  @api styleBody;
  @api headerTitle;
  @api countStyle;
  @api help;
  videoAndroid;
  videoIOS;
  footerText;
   // Link for instruction for android
   instructionUrlAndroid;

   // Link for instruction for iOS
   instructionUrlIOS;

   visibleContacts;

   // Link for mLog mileage tracking
   mLogTracking;

   troubleshootingAndroid;

   troubleshootingIOS;

   optimizeAndroid;

   optimizeIOS;
  // Get a list of custom setting named NewDashboardVideoLink
  @wire(getCustomSettings)
  myCustomSettings({
    error,
    data
  }) {
    if (data) {
      console.log("List--", data)
      this.instructionUrlAndroid = data.Donwload_instruction_for_Android__c;
      this.instructionUrlIOS = data.Donwload_instruction_for_IOS__c;
      this.mLogTracking = data.mLog_Mileage_Tracking__c;
      this.troubleshootingAndroid = data.Troubleshooting_Android__c;
      this.troubleshootingIOS = data.Troubleshooting_IOS__c;
      this.optimizeAndroid = data.Optimize_Android__c;
      this.optimizeIOS = data.Optimize_IOS__c;
      this.footerText = (this.help === 'mLogDownload') ? 'Follow these tips and download instructions for IOS' : (this.help === 'mLogInstruction') ? 'Follow these additional resources for IOS' : 'Follow this link to disable the debug logs for IOS'
      this.videoAndroid = (this.help === 'mLogDownload') ? this.instructionUrlAndroid : this.troubleshootingAndroid;
      this.videoIOS = (this.help === 'mLogDownload') ? this.mLogTracking : this.troubleshootingIOS;
    } else if (error) {
      console.log(error);
    }
  }
  updateContactHandler(event) {
    this.visibleContacts = [...event.detail.records]
    console.log("visible", this.visibleContacts)
  }
  // Event handler for link click
  handleRedirect(){
    if(this.help === 'mLogDownload'){
      window.open(this.instructionUrlIOS)
    }
  }


  closePopover() {
    this.dispatchEvent(new CustomEvent('pop', {
      detail: ''
    }))
  }

}