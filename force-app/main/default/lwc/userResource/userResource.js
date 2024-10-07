/* eslint-disable no-useless-escape */
/* eslint-disable @lwc/lwc/no-api-reassignments */
import { LightningElement, api } from 'lwc';
import svgFile from '@salesforce/resourceUrl/SvgFiles';
export default class UserResource extends LightningElement {
    // width of video
    videoWidth = "100%";

    // height of video
    videoHeight = "332px";
 
    // Header of resources
    resourceText = "";
 
    modalText = "";
 
    //content class of resources
    contentText = ""
    modalContainer = ""
    resource = [];
    toggleResource = false;
    vehicleObject;
    planPreview = false;
    planParameter = false;
    isDownloadmLog = false;
    fileResourcePreview = false;
    documentedVideoPreview = false;
    ismLogPreview = false;
    ismLogInstruction = false;
    downloadMLog = false;
    isTroubleshoot = false;
    isOptimize = false;
    isAdmin = false;
    isManager = false;
    isResource = false;
    getResource = true;
    onboardingIcon = svgFile + '/Onboarding.svg';
    mLogIcon = svgFile + '/mLog(MileageApp).svg';
    mDashIcon = svgFile + '/mDash.svg';
    mBurseIcon = svgFile + '/mBurseProgram.svg';
    micIcon = svgFile + '/Micellaneous.svg';
    videoPlanUrl = '';
    videoDocumentedUrl = '';
    fileDocumentUrl = '';
    videoPlayUrl = '';
    @api carouselLists = [];
    @api styleOfCarousel = 'slds-popover slds-nubbin_top  slds-popover_large slds-popover-resource';
    @api styleBody = 'slds-popover__body';
    @api styleFooter = 'slds-popover__footer';
    @api styleHeader = 'slds-popover__header bg-while';
    @api title = 'Instructions';
    @api driverMeeting;
    clickedResource = '';
    @api reset(){
        this.isResource = false;    
        this.getResource = true;
    }
    driverProfileResource = [{
        header: 'insights',
        content: [{
            title: 'Onboarding',
            iconUrl: this.onboardingIcon + '#onboarding'
        }, {
            title: 'Mileage App',
            iconUrl: this.mLogIcon + '#mLog',
        }, {
            title: 'Dashboard',
            iconUrl: this.mDashIcon + '#mdash'
        }, {
            title: 'mBurse Program',
            iconUrl: this.mBurseIcon + '#mBurseProgram'
        }, {
            title: 'Miscellaneous',
            iconUrl: this.micIcon + '#mice'
        }]
    }]

    driverResource = []
    
    adminProfileResource = [{
        header: 'insights',
        content: [{
            title: 'Onboarding',
            iconUrl: this.onboardingIcon + '#onboarding'
        }, {
            title: 'Dashboard',
            iconUrl: this.mDashIcon + '#mdash'
        }, {
            title: 'mBurse Program',
            iconUrl: this.mBurseIcon + '#mBurseProgram'
        }, {
            title: 'Miscellaneous',
            iconUrl: this.micIcon + '#mice'
        }]
    }]

    
     file = {};
     @api settings;

     /*getter setter method for insurance minimums */
     @api
     get minimums() {
         return this.arrayObject;
     }
     set minimums(value) {
         if (value) {
             let tempObject = this.proxyToObject(value)
             this.arrayObject = tempObject[0];
             if(this.arrayObject.Vehicle_Type__c){
                 let vehicle = this.arrayObject.Vehicle_Type__c;
                 let digit = vehicle.substring(0,5)
                 let isNumber = parseInt(digit)
                 this.arrayObject.Vehicle_Type__c = (isNaN(isNumber)) ? this.arrayObject.Vehicle_Type__c : (vehicle.split(digit))[1];
             }
         }
    }

    @api
    get vehicleMinimums() {
        return this.vehicleObject;
    }
    set vehicleMinimums(value) {
        if (value) {
            let object = this.proxyToObject(value)
            this.vehicleObject = object;
        }
    }

    @api role;

    /* convert string to array */
    proxyToObject(e) {
        return JSON.parse(e)
    }

    
    /* event handler for plan preview*/
    OnPlanpreview() {
        this.contentText = "slds-modal__content transparent_content";
        this.modalContainer = "slds-modal__container slds-m-top_medium";
        this.planPreview = true;
        this.fileResourcePreview = false;
        this.documentedVideoPreview = false;
        this.planParameter = false;
        this.resourceText = "Your Plan Preview";
        if (this.template.querySelector('c-user-profile-modal')) {
            this.template.querySelector('c-user-profile-modal').show();
        }
    }

    /* event handler for plan parameters*/
    OnPlanparameter() {
        this.contentText = "slds-modal__content content hidden-content";
        this.modalContainer = "slds-modal__container slds-m-top_medium"
        this.planPreview = false;
        this.fileResourcePreview = false;
        this.documentedVideoPreview = false;
        this.planParameter = true;
        this.resourceText = this.driverResource[0].content[1].description;
        if (this.template.querySelector('c-user-profile-modal')) {
            this.template.querySelector('c-user-profile-modal').show();
        }
    }

    filePreview(url, text) {
        if(url){
            let extension = url.match(/\.([^\./\?]+)($|\?)/);
            this.contentText = "slds-modal__content content slds-p-left_medium slds-p-right_medium slds-p-bottom_medium slds-p-top_small overflow-visible";
            this.modalContainer = "slds-modal__container modal-file"
            this.planPreview = false;
            this.planParameter = false;
            this.documentedVideoPreview = false;
            this.file.downloadUrl = url
            this.file.Extension = extension[1]
            this.fileResourcePreview = true;
            this.resourceText = text;
            if (this.template.querySelector('c-user-profile-modal')) {
                this.template.querySelector('c-user-profile-modal').show();
            }
        }
        // const showPreview = this.template.querySelector("c-preview-file-modal");
        // showPreview.show();
    }

    documentedPreview(text) {
        this.contentText = "slds-modal__content transparent_content";
        this.modalContainer = "slds-modal__container slds-m-top_medium";
        this.documentedVideoPreview = true;
        this.planPreview = false;
        this.fileResourcePreview = false;
        this.planParameter = false;
        this.resourceText = text
        if (this.template.querySelector('c-user-profile-modal')) {
            this.template.querySelector('c-user-profile-modal').show();
        }
    }

    troubleshootView(){
        this.isDownloadmLog = false;
        this.isTroubleshoot = true;
        this.documentedVideoPreview = false;
        this.planPreview = false;
        this.isOptimize = false;
        this.fileResourcePreview = false;
        this.ismLogPreview = false;
        this.ismLogInstruction = false;
        this.planParameter = false;
        this.carousel = [{
            "id": "1",
            "name": "Enable the debug logs so our team can easily identify any issues you encounter with mLog."
        }, {
            "id": "2",
            "name": "The debug logs will run for about a week before they auto turn off."
        }, {
            "id": "3",
            "name": "The debug logs will not affect the apps performance."
        }]
        this.carouselLists = JSON.stringify(this.carousel);
        this.resourceText = "Troubleshooting";
        if (this.template.querySelector('c-preview-file-modal')) {
            this.template.querySelector('c-preview-file-modal').show();
        }
    }


    optimizeView(){
        this.isDownloadmLog = false;
        this.isOptimize = true;
        this.isTroubleshoot = false;
        this.documentedVideoPreview = false;
        this.planPreview = false;
        this.fileResourcePreview = false;
        this.ismLogPreview = false;
        this.ismLogInstruction = false;
        this.resourceText = "Optimize";
        if (this.template.querySelector('c-preview-file-modal')) {
            this.template.querySelector('c-preview-file-modal').show();
        }
    }

    mLogInstructionView(){
        this.isDownloadmLog = false;
        this.isOptimize = false;
        this.isTroubleshoot = false;
        this.documentedVideoPreview = false;
        this.planPreview = false;
        this.fileResourcePreview = false;
        this.ismLogPreview = false;
        this.ismLogInstruction = true;
        this.carousel = [{
            "id": "1",
            "name": "Access additional guides, videos, and more"
        }]
        this.carouselLists = JSON.stringify(this.carousel);
        this.resourceText = "Learn More";
        if (this.template.querySelector('c-preview-file-modal')) {
            this.template.querySelector('c-preview-file-modal').show();
        }
    }

    mLogPreviewView(){
        this.isDownloadmLog = false;
        this.isOptimize = false;
        this.isTroubleshoot = false;
        this.documentedVideoPreview = false;
        this.planPreview = false;
        this.fileResourcePreview = false;
        this.ismLogInstruction = false;
        this.ismLogPreview = true;
        this.resourceText = "Preview";
        if (this.template.querySelector('c-preview-file-modal')) {
            this.template.querySelector('c-preview-file-modal').show();
        }
    }

    downloadMlog() {
        this.isDownloadmLog = true;
        this.documentedVideoPreview = false;
        this.planPreview = false;
        this.isOptimize = false;
        this.isTroubleshoot = false;
        this.ismLogInstruction = false;
        this.ismLogPreview = true;
        this.fileResourcePreview = false;
        this.planParameter = false;
        this.carousel = [{
            "id": "1",
            "name": "Select the mLog icon on your phone to open the app to track mileage each day automatically"
        }, {
            "id": "2",
            "name": "Review your trips daily if possible, weekly at a minimum"
        }, {
            "id": "3",
            "name": "Reclassify trips as business, personal, or delete trips you don't want to share"
        }]
        this.carouselLists = JSON.stringify(this.carousel);
        this.resourceText = "Get the mLog app";
        if (this.template.querySelector('c-preview-file-modal')) {
            this.template.querySelector('c-preview-file-modal').show();
        }
    }

    isValidDocument(url) {
        return /^https?:\/\/.+\.(doc|docx|odt|pdf|tex|txt|rtf|wps|wks|wpd)$/.test(url);
    }



    handleDriverResource() {
        this.resource = this.driverProfileResource
        this.role = 'Driver'
    }

    handleAdminResource() {
        this.resource = this.adminProfileResource
        this.role = 'Admin'
    }

    handleManagerResource() {
        this.resource = this.adminProfileResource
        this.role = 'Manager'
    }

    handleResource(event){
        var idOfResource;
        idOfResource = event.currentTarget.dataset.id;
        this.getResource = !this.getResource;
        this.clickedResource = idOfResource
        this.isResource = true;
    }



    backToDashboard(){
        this.getResource = !this.getResource;
        this.isResource = false;       
       // this.toggleResource = (this.role) ? (this.role === 'Admin' || this.role === 'Manager') ? true : false : false
    }

    setResource(event) {
        var idOfResource, idOfType;
        idOfResource = event?.detail.id;
        idOfType = event?.detail?.typeId;
        // console.log("From##", idOfResource, event?.detail?.typeId);
        this.driverResource = (event?.detail) ?  (event?.detail?.content) : [];
        if (idOfResource === "mBurse FAQ's") {
            this.fileDocumentUrl = this.settings.mBurse_FAQ_s__c
            this.filePreview(this.fileDocumentUrl,  "mBurse FAQ's");
        } else if (idOfResource === "Auto Insurance") {
            this.videoDocumentedUrl = this.settings.Auto_Insurance__c;
            this.documentedPreview('Auto Insurance - Why & How Much');
        } else if (idOfResource === "mLog Privacy") {
            this.videoDocumentedUrl = this.settings.Privacy__c;
            this.documentedPreview('mLog Privacy');
        } else if (idOfResource === "Compliance") {
            this.videoDocumentedUrl = this.settings.Compliance__c;
            this.documentedPreview('Compliance - How It Works');
        } else if(idOfResource === 'Optimize'){
            this.optimizeView();
        } else if(idOfResource === 'Methodology'){
            if(this.settings.Methodology__c){
                if(this.isValidDocument(this.settings.Methodology__c)){
                    this.fileDocumentUrl = this.settings.Methodology__c
                    this.filePreview(this.fileDocumentUrl,  "Methodology");
                }else{
                    this.videoDocumentedUrl = this.settings.Methodology__c;
                    this.documentedPreview('Methodology');
                }
            }
        } else if(this.role !== 'Admin' && this.role !== 'Manager'){
            if (idOfResource === 'Welcome') {
                this.videoPlanUrl = this.settings.Welcome_Link_Driver__c;
                this.OnPlanpreview();
            } else if (idOfResource === 'mDash') {
                this.videoDocumentedUrl = this.settings.mDash_Tour_Driver__c;
                this.documentedPreview('Dashboard Intro');
            } 
            else if (idOfResource === 'Getting Started') {
                this.videoDocumentedUrl = (idOfType) ? (idOfType === 'IOS') ? this.settings.Download_mLog_Link_For_IOS__c : this.settings.Download_mLog_Link_For_Android__c : '';
                this.documentedPreview('Getting Started');
            } 
            else if (idOfResource === 'Pro-Tips') {
                this.videoDocumentedUrl = (idOfType) ? (idOfType === 'IOS') ? this.settings.mLog_Instruction_IOS_Video__c : this.settings.mLog_Instruction_Android_Video__c : '';
                this.documentedPreview('Pro-Tips');
            } 
            else if (idOfResource === 'Location Services') {
                this.videoDocumentedUrl = (idOfType) ? (idOfType === 'IOS') ? this.settings.IOS_Location_Service__c : this.settings.Android_Location_Service__c : '';
                this.documentedPreview('Location Services');
            } 
            else if (idOfResource === 'Setting Work Hours') {
                this.videoDocumentedUrl = (idOfType) ? (idOfType === 'IOS') ? this.settings.IOS_Work_Hours__c : this.settings.Android_Work_Hours__c : '';
                this.documentedPreview('Setting Work Hours');
            } 
            else if (idOfResource === 'Tags & Notes') {
                this.videoDocumentedUrl = (idOfType) ? (idOfType === 'IOS') ? this.settings.IOS_Notes__c : this.settings.Android_Notes__c : '';
                this.documentedPreview('Tags & Notes');
            } 
            else if (idOfResource === 'Commuter Rule') {
                this.videoDocumentedUrl = (idOfType) ? (idOfType === 'IOS') ? this.settings.IOS_Commuter_Rule__c : this.settings.Android_Commuter_Rule__c : '';
                this.documentedPreview('Commuter Rule');
            } 
            else if (idOfResource === 'Route Planning') {
                this.videoDocumentedUrl = (idOfType) ? (idOfType === 'IOS') ? this.settings.IOS_Route_Planing__c : this.settings.Android_Route_Planing__c : '';
                this.documentedPreview('Route Planning');
            } 
            else if (idOfResource === 'Turning mLog Off') {
                this.videoDocumentedUrl = (idOfType) ? (idOfType === 'IOS') ? this.settings.IOS_Turning_Off__c : this.settings.IOS_Turning_Off__c : '';
                this.documentedPreview('Turning mLog Off');
            }
            else if (idOfResource === 'Debug Logs') {
                this.videoDocumentedUrl = (idOfType) ? (idOfType === 'IOS') ? this.settings.IOS_Debug_Logs__c : this.settings.Android_Debug_Logs__c : '';
                this.documentedPreview('Debug Logs');
            }

            else if (idOfResource === 'iBeacon') {
                if(this.isValidDocument(this.settings.iBeacon_iOS__c)){
                    this.fileDocumentUrl = (idOfType) ? (idOfType === 'IOS') ? this.settings.iBeacon_iOS__c : this.settings.iBeacon_android__c : '';
                    this.filePreview(this.fileDocumentUrl,  "iBeacon");
                }else{
                    this.videoDocumentedUrl = (idOfType) ? (idOfType === 'IOS') ? this.settings.iBeacon_iOS__c : this.settings.iBeacon_android__c : ''
                    this.documentedPreview('iBeacon');
                }
            } 
            else if (idOfResource === 'Car Bluetooth') {
                if(this.isValidDocument(this.settings.Bluetooth_iOS__c)){
                    this.fileDocumentUrl = (idOfType) ? (idOfType === 'IOS') ? this.settings.Bluetooth_iOS__c : this.settings.Bluetooth_android__c : '';
                    this.filePreview(this.fileDocumentUrl,  "Car Bluetooth");
                }else{
                    this.videoDocumentedUrl = (idOfType) ? (idOfType === 'IOS') ? this.settings.Bluetooth_iOS__c : this.settings.Bluetooth_android__c : '';
                    this.documentedPreview('Car Bluetooth');
                }
            }
            else if (idOfResource === 'Silencing mLog'){
                this.videoDocumentedUrl = (idOfType) ? (idOfType === 'IOS') ? this.settings.IOS_Silencing_Notifications__c : this.settings.Android_Silencing_Notifications__c : '';
                this.documentedPreview('Silencing mLog');
            }
            else if (idOfResource === 'Confirming Mileage'){
                this.videoDocumentedUrl = (idOfType) ? (idOfType === 'IOS') ? this.settings.IOS_Confirming_Mileage__c : this.settings.Android_Confirming_Mileage__c : '';
                this.documentedPreview('Confirming Mileage');
            }
            else if (idOfResource === 'Manual GPS'){
                this.videoDocumentedUrl = (idOfType) ? (idOfType === 'IOS') ? this.settings.Manual_GPS_IOS__c : this.settings.Manual_GPS_Android__c : '';
                this.documentedPreview('Manual GPS');
            }
            else if (idOfResource === 'Changing Trip Types'){
                this.videoDocumentedUrl = (idOfType) ? (idOfType === 'IOS') ? this.settings.IOS_Trip_Type__c : this.settings.Android_Trip_Type__c : '';
                this.documentedPreview('Changing Trip Types');
            }
            else if (idOfResource === 'Editing a Trip'){
                this.videoDocumentedUrl = (idOfType) ? (idOfType === 'IOS') ? this.settings.IOS_Edit_Trip__c : this.settings.Android_Edit_Trip__c : '';
                this.documentedPreview('Editing a Trip');
            }
            else if (idOfResource === 'Naming Locations'){
                this.videoDocumentedUrl = (idOfType) ? (idOfType === 'IOS') ? this.settings.IOS_Naming_Location__c : this.settings.Android_Naming_Location__c : '';
                this.documentedPreview('Naming Locations');
            }
            else if (idOfResource === 'Merging a Trip'){
                this.videoDocumentedUrl = (idOfType) ? (idOfType === 'IOS') ? this.settings.IOS_Merging_Trip__c : this.settings.Android_Merging_Trip__c : '';
                this.documentedPreview('Merging a Trip');
            }
            else if (idOfResource === 'Manual Entry'){
                this.videoDocumentedUrl = (idOfType) ? (idOfType === 'IOS') ? this.settings.IOS_Entry__c : this.settings.Android_Entry__c : '';
                this.documentedPreview('Manual Entry');
            }
            else if (idOfResource === 'Reporting'){
                this.videoDocumentedUrl = (idOfType) ? (idOfType === 'IOS') ? this.settings.IOS_Reporting__c : this.settings.Android_Reporting__c : '';
                this.documentedPreview('Reporting');
            }
            else if (idOfResource === 'Syncing Data'){
                this.videoDocumentedUrl = (idOfType) ? (idOfType === 'IOS') ? this.settings.Sync_Data_iOS__c : this.settings.Sync_Data_Android__c : '';
                this.documentedPreview('Syncing Data');
            }
            else if (idOfResource === 'Guidelines') {
                this.OnPlanparameter();
            } else if (idOfResource === "Download mLog") {
                this.downloadMlog();
            } else if (idOfResource === "Data Sync") {
                this.videoDocumentedUrl = this.settings.Data_Sync_Driver__c;
                this.documentedPreview('Data Sync - Phone to Dashboard');
            } else if(idOfResource === 'Troubleshooting'){
                this.troubleshootView();
            }  else if(idOfResource === `mLog FAQ's`){
                if(this.settings.mLog_FAQ_s__c){
                    if(this.isValidDocument(this.settings.mLog_FAQ_s__c)){
                        this.fileDocumentUrl = this.settings.mLog_FAQ_s__c
                        this.filePreview(this.fileDocumentUrl,  "mLog FAQ's");
                    }else{
                        this.videoDocumentedUrl = this.settings.mLog_FAQ_s__c;
                        this.documentedPreview("mLog FAQ's");
                    }
                }
            } else if(idOfResource === 'mLog Protips'){
               this.mLogInstructionView();
            }  else if(idOfResource === 'mBurse Policy'){
                if(this.settings.Reimbursement_Policy__c){
                    if(this.isValidDocument(this.settings.Reimbursement_Policy__c)){
                        this.fileDocumentUrl = this.settings.Reimbursement_Policy__c
                        this.filePreview(this.fileDocumentUrl,  "Our Privacy Policy");
                    }else{
                        this.videoDocumentedUrl = this.settings.Reimbursement_Policy__c;
                        this.documentedPreview('Our Privacy Policy');
                    }
                }
            } else if(idOfResource === 'mLog Preview'){
                this.mLogPreviewView();
            } else if(idOfResource === 'Driver Meeting'){
                if(this.driverMeeting){
                    if(this.isValidDocument(this.driverMeeting)){
                        this.fileDocumentUrl = this.driverMeeting
                        this.filePreview(this.fileDocumentUrl,  "Your Plan Overview");
                    }else{
                        this.videoDocumentedUrl = this.driverMeeting;
                        this.documentedPreview('Your Plan Overview');
                    }
                }
            }
        }else{
            if (idOfResource === 'Welcome') {
                this.videoPlanUrl = this.settings.Welcome_Link_Admin__c;
                this.OnPlanpreview();
            }else if (idOfResource === 'Getting Started') {
                this.videoDocumentedUrl = (this.role === 'Admin') ? this.settings.mDash_Tour_Admin__c : this.settings.mDash_Tour_Manager__c;
                this.documentedPreview('Getting Started Using mDash');
            }else if (idOfResource === 'Approving Mileage') {
                if(this.role === 'Admin'){
                    if(this.settings.Approving_Mileage_Admin__c){
                        if(this.isValidDocument(this.settings.Approving_Mileage_Admin__c)){
                            this.fileDocumentUrl = this.settings.Approving_Mileage_Admin__c
                            this.filePreview(this.fileDocumentUrl,  "Approving Mileage");
                        }else{
                            this.videoDocumentedUrl = this.settings.Approving_Mileage_Admin__c;
                            this.documentedPreview('Approving Mileage');
                        }
                    }
                }else{
                    if(this.settings.Approving_Mileage_Admin__c){
                        if(this.isValidDocument(this.settings.Approving_Mileage_Manager__c)){
                            this.fileDocumentUrl = this.settings.Approving_Mileage_Manager__c
                            this.filePreview(this.fileDocumentUrl,  "Approving Mileage");
                        }else{
                            this.videoDocumentedUrl = this.settings.Approving_Mileage_Manager__c;
                            this.documentedPreview('Approving Mileage');
                        }
                    }
                }
            }else if(idOfResource === 'Data Sync'){
                if(this.settings.Data_Sync_Admin__c){
                    if(this.isValidDocument(this.settings.Data_Sync_Admin__c)){
                        this.fileDocumentUrl = this.settings.Data_Sync_Admin__c
                        this.filePreview(this.fileDocumentUrl,  "Data Sync");
                    }else{
                        this.videoDocumentedUrl = this.settings.Data_Sync_Admin__c;
                        this.documentedPreview('Data Sync');
                    }
                }
            }else if(idOfResource === 'mBurse Policy'){
                if(this.settings.Reimbursement_Policy_Admin__c){
                    if(this.isValidDocument(this.settings.Reimbursement_Policy_Admin__c)){
                        this.fileDocumentUrl = this.settings.Reimbursement_Policy_Admin__c
                        this.filePreview(this.fileDocumentUrl,  "Our Privacy Policy");
                    }else{
                        this.videoDocumentedUrl = this.settings.Reimbursement_Policy_Admin__c;
                        this.documentedPreview('Our Privacy Policy');
                    }
                }

            } else if(idOfResource === `mDash FAQ's`){
                if(this.settings.mLog_FAQ_s__c){
                    if(this.isValidDocument(this.settings.mLog_FAQ_s__c)){
                        this.fileDocumentUrl = this.settings.mLog_FAQ_s__c
                        this.filePreview(this.fileDocumentUrl,  "mDash FAQ's");
                    }else{
                        this.videoDocumentedUrl = this.settings.mLog_FAQ_s__c;
                        this.documentedPreview("mDash FAQ's");
                    }
                }
            } else if(idOfResource === 'mDash Protips'){
                if(this.settings.mLog_Instruction__c){
                    if(this.isValidDocument(this.settings.mLog_Instruction__c)){
                        this.fileDocumentUrl = this.settings.mLog_Instruction__c
                        this.filePreview(this.fileDocumentUrl,  "mDash Protips");
                    }else{
                        this.videoDocumentedUrl = this.settings.mLog_Instruction__c;
                        this.documentedPreview('mDash Protips');
                    }
                }
            } else if(idOfResource === 'Adding Users'){
                if(this.settings.Add_User__c){
                    if(this.isValidDocument(this.settings.Add_User__c)){
                        this.fileDocumentUrl = this.settings.mLog_Instruction__c
                        this.filePreview(this.fileDocumentUrl,  "Adding Users");
                    }else{
                        this.videoDocumentedUrl = this.settings.Add_User__c;
                        this.documentedPreview('Adding Users');
                    }
                }
            } else if(idOfResource === 'Removing Users'){
                if(this.settings.Remove_User__c){
                    if(this.isValidDocument(this.settings.Remove_User__c)){
                        this.fileDocumentUrl = this.settings.Remove_User__c
                        this.filePreview(this.fileDocumentUrl,  "Removing Users");
                    }else{
                        this.videoDocumentedUrl = this.settings.Remove_User__c;
                        this.documentedPreview('Removing Users');
                    }
                }
            } else if(idOfResource === 'Prorations'){
                if(this.settings.Prorations__c){
                    if(this.isValidDocument(this.settings.Prorations__c)){
                        this.fileDocumentUrl = this.settings.Prorations__c
                        this.filePreview(this.fileDocumentUrl,  "Prorations");
                    }else{
                        this.videoDocumentedUrl = this.settings.Prorations__c;
                        this.documentedPreview('Prorations');
                    }
                }
            } else if(idOfResource === 'Reporting'){
                if(this.settings.Reports__c){
                    if(this.isValidDocument(this.settings.Reports__c)){
                        this.fileDocumentUrl = this.settings.Reports__c
                        this.filePreview(this.fileDocumentUrl,  "Reporting");
                    }else{
                        this.videoDocumentedUrl = this.settings.Reports__c;
                        this.documentedPreview('Reporting');
                    }
                }
            }
        }       
    }

    revertHandler() {
        this.dispatchEvent(
            new CustomEvent("back", {
                detail: ''
            })
        );
    }

    mLogResource(event) {
        let id = event.currentTarget.dataset.id;
        this.videoPlayUrl = (id === 'Android') ? this.settings.Download_mLog_Link_For_Android__c : this.settings.Download_mLog_Link_For_IOS__c;
        this.modalText = (id === 'Android') ? 'Android - Getting Started' : 'iOS - Getting Started';
        this.documentedVideoPreview = false;
        this.planPreview = false;
        this.fileResourcePreview = false;
        this.planParameter = false;
        this.template.querySelector('c-preview-file-modal').showVideo(this.modalText, this.videoPlayUrl)
    }
    
    mLogTroubleshoot(event) {
        let id = event.currentTarget.dataset.id;
        this.videoPlayUrl = (id === 'Android') ? this.settings.Troubleshooting_Android_video__c : this.settings.Troubleshooting_IOS_video__c;
        this.modalText = (id === 'Android') ? 'Android - Debug Logs' : 'iOS - Debug Logs';
        this.documentedVideoPreview = false;
        this.planPreview = false;
        this.fileResourcePreview = false;
        this.planParameter = false;
        this.template.querySelector('c-preview-file-modal').showVideo(this.modalText, this.videoPlayUrl)
    }

    mLogOptimize(event) {
        let id = event.currentTarget.dataset.id;
        this.videoPlayUrl = (id === 'Android') ? this.settings.Optimize_Android__c : this.settings.Optimize_IOS__c;
        this.modalText = (id === 'Android') ? 'Android - Optimizing mLog' : 'iOS - Optimizing mLog';
        this.documentedVideoPreview = false;
        this.planPreview = false;
        this.fileResourcePreview = false;
        this.planParameter = false;
        this.template.querySelector('c-preview-file-modal').showVideo(this.modalText, this.videoPlayUrl)
    }

    mLogInstruction(event) {
        let id = event.currentTarget.dataset.id;
        this.videoPlayUrl = (id === 'Android') ? this.settings.mLog_Instruction_Android_Video__c : this.settings.mLog_Instruction_IOS_Video__c;
        this.modalText = (id === 'Android') ? 'Android - Protips' : 'iOS - Protips';
        this.documentedVideoPreview = false;
        this.planPreview = false;
        this.fileResourcePreview = false;
        this.planParameter = false;
        this.template.querySelector('c-preview-file-modal').showVideo(this.modalText, this.videoPlayUrl)
    }

    mLogPreview(event){
        let id = event.currentTarget.dataset.id;
        this.videoPlayUrl = (id === 'Android') ? this.settings.mLog_Preview_Android_Video__c : this.settings.mLog_Preview_IOS_Video__c;
        this.modalText = (id === 'Android') ? 'Android - Preview' : 'iOS - Preview';
        this.documentedVideoPreview = false;
        this.planPreview = false;
        this.fileResourcePreview = false;
        this.planParameter = false;
        this.template.querySelector('c-preview-file-modal').showVideo(this.modalText, this.videoPlayUrl)
    }

    popOut() {
        this.toggleSlider("block");
    }

    toggleSlider(state){
        let slider = this.template.querySelector('.help-text');
        if(slider){
            slider.style.display = state;
        }
    }

    handleSliderClose(){
        this.toggleSlider("none");
    }


    getmLog(){
        this.dispatchEvent(
            new CustomEvent("send", {
                detail: {contactEmail: this.arrayObject.External_Email__c, contactPhone: this.arrayObject.MobilePhone}
            })
        );
    }

    // Event handler for link click
    handleRedirect(){
        window.open(this.instructionUrlIOS)
    }


    renderedCallback() {
        const buttonItem = this.template.querySelectorAll(".btn-toggle");
        if (buttonItem !== undefined) {
            buttonItem.forEach((el) =>
                el.addEventListener("click", () => {
                    buttonItem.forEach((el2) => el2.classList.remove("is-active"));
                    el.classList.add("is-active");
                })
            );
        }

        if(this.toggleResource){
            let btnItem = this.template.querySelectorAll(".btn-toggle");
            btnItem.forEach((el) => {
             el.classList.remove("is-active");
            });
            if(this.role === 'Admin' || this.role === 'Manager'){
                if(this.template.querySelector('.admin')){
                    this.template.querySelector('.admin').classList.add("is-active");
                }
            }else{
                if(this.template.querySelector('.driver')){
                    this.template.querySelector('.driver').classList.add("is-active");  
                }
            }
           
        }
    }


    connectedCallback() {
        this.toggleResource = (this.role) ? (this.role === 'Admin' || this.role === 'Manager') ? true : false : false
        this.resource = (this.role === 'Admin' || this.role === 'Manager') ? this.adminProfileResource : this.driverProfileResource;
        this.isManager = (this.role === 'Manager') ? true : false;
        this.isAdmin = (this.role === 'Admin' || this.role === 'Manager') ? true : false;
    }
}