import {
    LightningElement,
    wire,
    api
} from 'lwc';
import mBurseCss from '@salesforce/resourceUrl/mBurseCss';
import getCustomSettings from '@salesforce/apex/NewAccountDriverController.getCustomSettings';
import contactInfo from '@salesforce/apex/NewAccountDriverController.getContactDetail';
// import updateContactDetail from '@salesforce/apex/NewAccountDriverController.updateContactDetail';
import redirectionURL from '@salesforce/apex/NewAccountDriverController.loginRedirection';
import {
    events,
    backEvents
} from 'c/utils';
export default class MBurseDownloadMlog extends LightningElement {
    // Id of driver or contact
    @api contactId;

    // Id of account
    @api accountId;

    // Email of contact
    @api contactEmail;

    // mobile phone of contact
    @api mobilePhone;

    // Type of account (New or Existing)
    @api accountType;

    @api driverMeeting;

    // Type of phone (Employee Provided or Company Provided)
    @api cellType;

    // Watch driver meeting
    @api meeting;

    // Schedule driver meeting 
    @api schedule;

    @api dayLeft;

    @api firstName;

    // Android video link from custom settings
    androidVideoUrl;

    // Ios video link from custom settings
    iosVideoUrl;

    //mLog Tracking
    mLogTracking;

    // Width of iframe
    videoWidth = 100 + '%';

    // Height of iframe
    videoHeight = 100 + '%';

    // Flag to show/hide default element
    isDownload = true;

    // Flag to show/hide download now element
    isDownloadNow = false;

    // Flag to show/hide download later element
    isDownloadLater = false;

    // Flag to show/hide already download element
    isDownloadAlready = false;

    // Flag to show/hide isDownloadForApple
    isDownloadForApple = false;

    isDownloadForAndroid = false;

    isCommonDownload = false;

    switchToVersion = '';

    // Flag to show mburse chat bot
    isChatBot = false;

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

    // A array of contact details
    arrayList;

    // Flag to show/hide element based on cellphone type
    render = false;

    main = false;

    // change Text
    buttonRender;

    // Store image from static resource android
    androidUrl = mBurseCss + '/mburse/assets/Apple_Android/Android.svg';

    // Store image from static resource iOS
    appleUrl = mBurseCss + '/mburse/assets/Apple_Android/Apple.svg';

    // Store image from static resource for video element
    videoLogoUrl = mBurseCss + '/mburse/assets/youtube_play_video_icon.png'

    typePopover = "slds-popover slds-nubbin_left-top  slds-popover_large c_popover"

    QRCode = mBurseCss + '/mburse/assets/QR-code.png'

    IOS1 = mBurseCss + '/mburse/assets/IOS/1.png'

    IOS2 = mBurseCss + '/mburse/assets/IOS/2.png'

    IOS3 = mBurseCss + '/mburse/assets/IOS/3.png'


    ANDR1 = mBurseCss + '/mburse/assets/Android/1.png'

    ANDR2 = mBurseCss + '/mburse/assets/Android/2.png'

    ANDR3 = mBurseCss + '/mburse/assets/Android/3.png'

    carousel = false;

    showWatchBtn = false;

    afterRegister = false;

    carouselLists;

    carouselA = [{
        "id": "1",
        "name": "Select the mLog icon on your phone to open the app to track mileage each day automatically"
    }, {
        "id": "2",
        "name": "Review your trips daily if possible, weekly at a minimum"
    }, {
        "id": "3",
        "name": "Reclassify trips as business, personal, or delete trips you don't want to share"
    }];

    carouselB = [{
        "id": "1",
        "name": "Make sure you turn on the app every day that you are using it by selecting the mLog icon"
    }, {
        "id": "2",
        "name": "Review your trips daily if possible, weekly at a minimum"
    }, {
        "id": "3",
        "name": "You can categorize any trips as Personal or delete any trips you do not want to share"
    }];

    allowRedirect = false;
    // Get a list of custom setting named NewDashboardVideoLink
    @wire(getCustomSettings)
    myCustomSettings({
        error,
        data
    }) {
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

    // Event handler for Download now button click
    downloadNow() {
        this.isPlay = false;
        this.isPlayAndroid = false;
        this.isDownload = false;
        this.isDownloadNow = true;
        this.isDownloadLater = false;
        this.isDownloadAlready = false;
        this.carousel = false;
        this.isChatBot = true;
        this.sendCorporateLink();
    }

    // Event handler for Download later button click
    downloadLater() {
        this.isPlay = false;
        this.isPlayAndroid = false;
        this.isDownload = false;
        this.isDownloadNow = false;
        this.isDownloadLater = true;
        this.isDownloadAlready = false;
        this.isChatBot = false;
        this.carousel = false;
        this.sendCorporateLink();
    }

    // Event handler for I already have mLog button click
    downloadAlready() {
        this.isPlay = false;
        this.isPlayAndroid = false;
        this.isDownload = false;
        this.isDownloadNow = false;
        this.isDownloadLater = false;
        this.isDownloadAlready = true;
        this.isChatBot = false;
        this.carousel = false;
    }

    nextTodownload(event) {
        this.switchToVersion = event.currentTarget.dataset.id;
        this.isPlay = false;
        this.isPlayAndroid = false;
        this.isDownload = false;
        this.isDownloadNow = false;
        this.isDownloadLater = false;
        this.isCommonDownload = true;
        this.isChatBot = false;
        this.carousel = false;
        this.sendCorporateLink();
    }

    backToDownloadmLog(){
        this.isDownload = true;
        this.isCommonDownload = false;
    }

    backToStep1(){
        this.isCommonDownload = true;
        this.isDownloadForAndroid = false;
        this.isDownloadForApple = false;
    }

    nextPageOfmLog(){
        this.isCommonDownload = false;
        this.isDownloadForAndroid = (this.switchToVersion === 'Android') ? true : false;
        this.isDownloadForApple = (this.switchToVersion === 'Apple') ? true : false;
    }

    // Convert JSON to Object
    proxyToObject(e) {
        return JSON.parse(e)
    }

    // Event handler for watch driver meeting button click
    nextDriverMeeting() {
        //var list, d;
        contactInfo({
                contactId: this.contactId
            })
            .then((data) => {
                if (data) {
                    // list = this.proxyToObject(data);
                    // this.arrayList = list;
                    // d = this.arrayList;
                    // d[0].checkDriverMeeting = true;
                    // updateContactDetail({
                    //     contactData: JSON.stringify(d),
                    //     driverPacket: true
                    // })
                    events(this, 'Next mburse meeting');
                    // if (d[0].accountStatus === 'New Account') {
                    //     window.open(this.schedule)
                    // } else {
                    //     window.open(this.meeting)
                    // }
                }
            })
            .catch((error) => {
                // If the promise rejects, we enter this code block
                console.log(error);
            })
    }

    takeMeToDashboard() {
        redirectionURL({
                contactId: this.contactId
            })
            .then((result) => {
                let url = window.location.origin + result;
                window.open(url, '_self');
            })
            .catch((error) => {
                // If the promise rejects, we enter this code block
                console.log(error);
            })
    }

    // Event handler for back button click
    backToDownloadPage() {
        this.isDownload = true;
        this.isPlay = false;
        this.isPlayAndroid = false;
        this.isDownloadNow = false;
        this.isDownloadLater = false;
        this.isDownloadAlready = false;
        this.isChatBot = false;
        this.carousel = false;
    }

    // Event handler for back button click
    backToPage() {
        backEvents(this, 'Next mLog Preview');
    }

    // Event handler for link click
    handleRedirect() {
        window.open(this.instructionUrlIOS)
    }

    // Event handler to render chat bot
    contactSupport(event) {
        event.preventDefault();
        event.stopPropagation();
        this.template.querySelector('c-m-burse-support').renderChat();
    }

    // Event handler for video element iOS click
    playVideo() {
        this.isPlay = true;
    }

    // Event handler for video element android click
    playVideoAndroid() {
        this.isPlayAndroid = true;
    }

    popOut() {
        this.carousel = true;
        if(window.screen.width <= 1024){
            this.typePopover = "slds-popover slds-nubbin_left-top  slds-popover_medium c_popover"
        }
        console.log(window.screen.width, this.template.querySelector('.c_popover'))
    }

    handlePopover() {
        this.carousel = false;
    }

    sendCorporateLink() {
        this.dispatchEvent(
            new CustomEvent("send", {
                detail: {
                    contactEmail: this.contactEmail,
                    mobilePhone: this.mobilePhone,
                    accountId: this.accountId
                }
            })
        );
    }

    renderButton(){
        let contact;
        contactInfo({contactId: this.contactId})
        .then((data) => {
          if (data) {
            contact = this.proxyToObject(data);
            if(this.dayLeft === true){
                this.allowRedirect = true;
            }else{
                if(contact[0].driverPacketStatus === 'Uploaded' && contact[0].insuranceStatus === 'Uploaded'){
                    this.allowRedirect = true;
                }else{
                    this.allowRedirect = false;
                }
            }
          }
        })
        .catch((error)=>{
            // If the promise rejects, we enter this code block
            console.log(error);
        })
    }

    // Life cycle hook to render UI
    renderedCallback() {
        if (this.renderInitialized) {
            return;
        }
        this.renderInitialized = true;
        this.render = (this.cellType === 'Company Provide') ? true : false;
        this.isChatBot = (this.render) ? true : false;
        this.carouselLists = (this.cellType === 'Company Provide') ? this.carouselB : this.carouselA;
        this.buttonRender = (this.accountType === 'New Account') ? 'Register for your driver meeting' : 'Watch your driver meeting';
        this.renderButton();
        this.showWatchBtn = (this.accountType === 'New Account') ? false : true;
        this.afterRegister = (this.accountType === 'New Account' && this.driverMeeting === 'Scheduled') ? true : false;
        console.log("rendered--", this.render)
    }

}