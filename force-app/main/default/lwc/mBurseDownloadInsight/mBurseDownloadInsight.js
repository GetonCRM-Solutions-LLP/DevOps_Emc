import { LightningElement, wire } from 'lwc';
import  mBurseCss from '@salesforce/resourceUrl/mBurseCss';
import getCustomSettings from '@salesforce/apex/NewAccountDriverController.getCustomSettings';
export default class MBurseDownloadInsight extends LightningElement {
     // Android video link from custom settings
     androidVideoUrl;

     // Ios video link from custom settings
     iosVideoUrl;

     // Width of iframe
     videoWidth = 100 + '%';

     // Height of iframe
     videoHeight = 100 + '%';

     // Flag to show/hide video element for iOS
    isPlay = false;

    // Flag to show/hide video element for android
    isPlayAndroid = false;

    //Flag to call render function once
    renderInitialized = false;

    // Link for instruction for android
    instructionUrlAndroid;

    // Link for instruction for iOS
    instructionUrlIOS;

    // Link for privacy pleadge
    privacyPledgeUrl;

    // Link for mLog mileage tracking
    mLogTracking;

    // A array of contact details
    arrayList;

    // Flag to show/hide element based on cellphone type
    render;

     // Store image from static resource android
     androidUrl = mBurseCss + '/mburse/assets/Apple_Android/Android.svg';

     // Store image from static resource iOS
     appleUrl = mBurseCss + '/mburse/assets/Apple_Android/Apple.svg';

     // Store image from static resource for video element
     videoLogoUrl = mBurseCss + '/mburse/assets/youtube_play_video_icon.png'

      // Get a list of custom setting named NewDashboardVideoLink
    @wire(getCustomSettings)
    myCustomSettings({ error, data }){
        if (data) {
             this.androidVideoUrl = data.Download_mLog_Link_For_Android__c;
             this.iosVideoUrl = data.Download_mLog_Link_For_IOS__c;
             this.privacyPledgeUrl = data.Privacy_Pledge_Link__c;
             this.instructionUrlAndroid = data.Donwload_instruction_for_Android__c;
             this.instructionUrlIOS = data.Donwload_instruction_for_IOS__c;
             this.mLogTracking = data.mLog_Mileage_Tracking__c;
          } else if (error) {
              console.log(error);
          }
    }

    // Event handler for link click
    handleRedirect(){
        window.open(this.instructionUrlIOS)
    }

     // Event handler for video element iOS click
     playVideo(){
        this.isPlay = true;
    }

    // Event handler for video element android click
    playVideoAndroid(){
        this.isPlayAndroid = true;
    }

     // Life cycle hook to render UI
     renderedCallback(){
        if (this.renderInitialized) {
            return;
          }
        this.renderInitialized = true;
    }

    getmLog(){
        this.dispatchEvent(
            new CustomEvent("send", {
                detail: "fire"
            })
        );
    }
}