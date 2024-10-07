/* eslint-disable no-useless-escape */
/* eslint-disable @lwc/lwc/no-api-reassignments */
import { LightningElement, api } from 'lwc';
import svgFile from '@salesforce/resourceUrl/SvgFiles';

export default class UserResourceDetail extends LightningElement {
   
    arrayObject;
    resObj;
    typeId;
    previewIcon = svgFile + '/planPreview.svg';
    parameterIcon = svgFile + '/planParameter.svg';
    downloadIcon = svgFile + '/downloadIcon.svg';
    onboardingIcon = svgFile + '/Onboarding.svg';
    syncIcon = svgFile + '/sync.svg';
    troubleIcon = svgFile + '/troubleshooting.svg';
    optimizeIcon = svgFile + '/optimize.svg';
    mLogFAQIcon = svgFile + '/mLogFAQ.svg';
    instructionIcon = svgFile + '/Instruction.svg';
    complianceIcon = svgFile + '/compliance.svg';
    liabilityIcon = svgFile + '/liability.svg';
    autoInsuranceIcon = svgFile + '/autoInsurance.svg';
    methodologyIcon = svgFile + '/Methodology.svg';
    privacyIcon = svgFile + '/privacy.svg';
    policyIcon = svgFile + '/Policy.svg';
    addUserIcon = svgFile + '/addUser.svg';
    removeUserIcon = svgFile + '/removeUser.svg';
    prorationIcon = svgFile + '/Prorations.svg';
    reportIcon = svgFile + '/Reporting.svg';
    workHourIcon = svgFile + '/SettingWorkHours.svg';
    tagNotesIcon = svgFile + '/TagsNotes.svg';
    gpsIcon = svgFile + '/ManualGPSTrips.svg';
    commuterIcon = svgFile + '/Commuter.svg';
    planningIcon = svgFile + '/RoutePlanning.svg';
    quietIcon = svgFile + '/QuietNotifications.svg';
    deviceIcon = svgFile + '/NewDevice.svg';
    reportLogIcon = svgFile + '/ReportingLog.svg';
    mergingIcon = svgFile + '/MergingTrip.svg';
    locationIcon = svgFile + '/NamingLocations.svg';
    tripEditIcon = svgFile + '/TripEdit.svg';
    turningOffIcon = svgFile + '/TurningOffmLog.svg';
    tripTypeIcon = svgFile + '/ChangingTripTypes.svg';
    entryIcon = svgFile + '/ManualEntry.svg';
    locateIcon = svgFile + '/LocationServices.svg';
    mileageSyncIcon = svgFile + '/MileageSync.svg';
    gettingStartIcon = svgFile + '/GettingStarted.svg';
    proTipIcon = svgFile + '/Pro-tips.svg';
    fAQIcon = svgFile + '/FAQs.svg';
    customizingIcon = svgFile + '/mLogCustomize.svg';
    usingMLogIcon = svgFile + '/UsingmLog.svg';
    debugIcon = svgFile + '/debugLogs.svg';
    confirmingIcon = svgFile + '/confirmingMileage.svg';
    ibeaconIcon = svgFile + '/iBeacon.svg';
    bluetoothIcon = svgFile + '/Bluetooth.svg';

    resource = [];
   
    @api resourceName;
    previousView;
    currentView;
    currentViewClass = '';
    previousViewClass = '';

    driverResource = [];

    adminResource = [];

    managerResource = [];

    showBtns = false;

    backRedirected = false;

    @api role;

    /* convert string to array */
    proxyToObject(e) {
        return JSON.parse(e)
    }


    handleResource(event) {
        var idOfResource;
        idOfResource = event.currentTarget.dataset.id;
        this.dispatchEvent(
            new CustomEvent("show", {
                detail: {id: idOfResource, content: this.resource, typeId: this.typeId}
            })
        );
    }

    handleTarget(event){
        this.typeId = event.currentTarget?.dataset?.id;
    }

    handleToggleResource(event) {
        this.backRedirected = false;
        var idOfResource, type, typeId;
        type = this.template.querySelector(".is-active");
        typeId = type?.dataset.id;
        this.typeId = typeId;
        idOfResource = event.currentTarget.dataset.id;
        switch(idOfResource){
            case 'mLog-Onboarding' : 
                this.arrayObject = {
                    header: 'Onboarding',
                    type: typeId,
                    content: [{
                        title: 'Getting Started',
                        description: '',
                        iconUrl: this.gettingStartIcon + '#started'
                    }, {
                        title: 'Pro-Tips',
                        description: '',
                        iconUrl: this.proTipIcon + '#protips'
                    },{
                        title: `mLog FAQ's`,
                        description: '',
                        iconUrl: this.fAQIcon + '#FAQ'
                    }]
                }
            break;
            case 'mLog-Customizing' :
                this.arrayObject = {
                    header: 'Customizing',
                    type: typeId,
                    content: [{
                        title: 'Location Services',
                        description: '',
                        iconUrl: this.locateIcon + '#locate'
                    }, {
                        title: 'Setting Work Hours',
                        description: '',
                        iconUrl: this.workHourIcon + '#work'
                    },{
                        title: 'Tags & Notes',
                        description: '',
                        iconUrl: this.tagNotesIcon + '#tags'
                    },{
                        title: 'Commuter Rule',
                        description: '',
                        iconUrl: this.commuterIcon + '#commute'
                    },{
                        title: 'Route Planning',
                        description: '',
                        iconUrl: this.planningIcon + '#Route'
                    },{
                        title: 'iBeacon',
                        description: '',
                        iconUrl: this.ibeaconIcon + '#ibeacon'
                    },{
                        title: 'Car Bluetooth',
                        description: '',
                        iconUrl: this.bluetoothIcon + '#bluetooth'
                    },{
                        title: 'Turning mLog Off',
                        description: '',
                        iconUrl: this.turningOffIcon + '#turningOff'
                    },{
                        title: 'Manual GPS',
                        description: '',
                        iconUrl: this.gpsIcon + '#manual-gps'
                    },{
                        title: 'Silencing mLog',
                        description: '',
                        iconUrl: this.quietIcon + '#quiet'
                    }]
                }
            break;
            case 'mLog-Troubleshooting' : 
                this.arrayObject = {
                    header: 'Troubleshooting',
                    type: typeId,
                    content: [{
                        title: 'Location Services',
                        description: '',
                        iconUrl: this.locateIcon + '#locate'
                    },{
                        title: 'Debug Logs',
                        description: '',
                        iconUrl: this.debugIcon + '#debug'
                    },{
                        title: 'Confirming Mileage',
                        description: '',
                        iconUrl: this.confirmingIcon + "#cmileage"
                    }]
                }
            break;
            case 'mLog-Using' : 
                this.arrayObject = {
                    header: 'Using',
                    type: typeId,
                    content: [{
                        title: 'Changing Trip Types',
                        description: '',
                        iconUrl: this.tripTypeIcon + '#tripType'
                    },{
                        title: 'Editing a Trip',
                        description: '',
                        iconUrl: this.tripEditIcon + '#TripEdit'
                    },{
                        title: 'Naming Locations',
                        description: '',
                        iconUrl: this.locationIcon + '#Location'
                    },{
                        title: 'Merging a Trip',
                        description: '',
                        iconUrl: this.mergingIcon + '#merging'
                    },{
                        title: 'Manual Entry',
                        description: '',
                        iconUrl: this.entryIcon + '#manual'
                    },{
                        title: 'Syncing Data',
                        description: '',
                        iconUrl: this.mileageSyncIcon + '#Mileage'
                    },{
                        title: 'Reporting',
                        description: '',
                        iconUrl: this.reportLogIcon + '#Reporting'
                    }]
                }
            break;
        }

        this.resource = []
        this.driverResource = []
        this.driverResource.push(this.arrayObject);
        this.resource = this.driverResource;
        this.currentView = this.resource[0]?.header;
    }

    redirectToPrevPage(){
        this.backRedirected = false;
        this.revertHandler();
    }

    redirectToNextPage(){
        this.backRedirected = false;
        //this.revertHandler();
    }

    redirectToHomePage(){
        this.backRedirected = true;
        this.revertHandler();
    }

    revertHandler() {
        if(this.backRedirected){
            this.previousView = '';
            this.dispatchEvent(
                new CustomEvent("back", {
                    detail: ''
                })
            );
        }else{
            this.currentView = '';
            this.renderResource(this.resourceName, this.role)
            this.adminResource = [];
            this.driverResource = [];
            this.managerResource = [];
            this.resource = [];
            if(this.role === 'Admin'){
                this.adminResource.push(this.resObj);
            }else if(this.role === 'Manager'){
               this.managerResource.push(this.resObj);
            }else{
                this.driverResource.push(this.resObj);
            }
            
            this.resource = (this.role === 'Admin') ? this.adminResource : (this.role === 'Manager') ? this.managerResource : this.driverResource;
        }
    }

    

    renderedCallback(){
        const buttonItem = this.template.querySelectorAll(".btn-toggle");
        if (buttonItem !== undefined) {
            buttonItem.forEach((el) =>
                el.addEventListener("click", () => {
                    buttonItem.forEach((el2) => el2.classList.remove("is-active"));
                    el.classList.add("is-active");
                })
            );
        }

        this.currentViewClass = (this.currentView) ? 'current' : '';
        this.previousViewClass = (this.currentView) ? '' : 'current';
    }

    renderResource(resource, role){
        this.backRedirected = true;
        if(role === 'Admin'){
            switch(resource){
                case 'Onboarding' :
                    this.showBtns = false;
                    this.resObj = {
                            header: 'Onboarding',
                            content: [{
                                title: 'Welcome',
                                description: 'Plan Preview',
                                iconUrl: this.previewIcon + '#planPreview'
                            }, {
                                title: 'Getting Started',
                                description: 'Using mDash',
                                iconUrl: this.previewIcon + '#planPreview'
                            }]
                    }
                    break;
    
                case 'Dashboard' :
                    this.showBtns = false;
                    this.resObj = {
                        header: 'Dashboard',
                        content: [{
                            title: 'Approving Mileage',
                            description: 'Best Practices',
                            iconUrl: this.complianceIcon + '#compliance'
                        },{
                            title: 'Adding Users',
                            description: `Add or Reactivate User's`,
                            iconUrl: this.addUserIcon + '#add'
                        },{
                            title: 'Removing Users',
                            description: 'The Process',
                            iconUrl: this.removeUserIcon + '#remove'
                        },{
                            title: 'Prorations',
                            description: 'Adjusting the Fixed Amount',
                            iconUrl: this.prorationIcon + '#proration'
                        },{
                            title: 'Reporting',
                            description: 'Process & Downloads',
                            iconUrl: this.reportIcon + '#report'
                        }]
                    }
                    break;
                
                case 'mBurse Program' : 
                    this.showBtns = false;
                    this.resObj = {
                            header: 'mBurse Program',
                            content: [{
                                title: 'Compliance',
                                description: 'How It Works',
                                iconUrl: this.complianceIcon + '#compliance'
                            }, {
                                title: 'Auto Insurance',
                                description: 'Why & How Much',
                                iconUrl: this.autoInsuranceIcon + '#insurance'
                            }, {
                                title: `mBurse FAQ's`,
                                description: 'What You Need To Know',
                                iconUrl: this.mLogFAQIcon + '#mLogFAQ'
                            }, {
                                title: 'Methodology',
                                description: 'Rate Calculations',
                                iconUrl: this.methodologyIcon + '#methodology'
                            }]
                    }
                    break;
                
                case 'Miscellaneous' : 
                    this.showBtns = false;
                    this.resObj = {
                        header: 'Miscellaneous',
                        content: [{
                            title: 'mLog Privacy',
                            description: 'How It Works',
                            iconUrl: this.privacyIcon + '#privacy'
                        }, {
                            title: 'mBurse Policy',
                            description: 'Our Privacy policy',
                            iconUrl: this.policyIcon + '#policy'
                        }]
                    }
                    break;
            } 
        } else if(role === 'Manager'){
            switch(resource){
                    case 'Onboarding' :
                        this.showBtns = false;
                        this.resObj = {
                            header: 'Onboarding',
                            content: [{
                                title: 'Welcome',
                                description: 'Plan Preview',
                                iconUrl: this.previewIcon + '#planPreview'
                            }, {
                                title: 'Getting Started',
                                description: 'Using mDash',
                                iconUrl: this.previewIcon + '#planPreview'
                            }]
                        }
                    break;
        
                    case 'Dashboard' :
                        this.showBtns = false;
                        this.resObj = {
                                header: 'Dashboard',
                                content: [{
                                    title: 'Approving Mileage',
                                    description: 'Refreshing the Dashboard',
                                    iconUrl: this.complianceIcon + '#compliance'
                                }]
                        }
                    break;
                    
                    case 'mBurse Program' : 
                        this.showBtns = false;
                        this.resObj = {
                            header: 'mBurse Program',
                            content: [{
                                title: 'Compliance',
                                description: 'How It Works',
                                iconUrl: this.complianceIcon + '#compliance'
                            }, {
                                title: 'Auto Insurance',
                                description: 'Why & How Much',
                                iconUrl: this.autoInsuranceIcon + '#insurance'
                            }, {
                                title: `mBurse FAQ's`,
                                description: 'What You Need To Know',
                                iconUrl: this.mLogFAQIcon + '#mLogFAQ'
                            }, {
                                title: 'Methodology',
                                description: 'Rate Calculations',
                                iconUrl: this.methodologyIcon + '#methodology'
                            }]
                        }
                        break;
                    
                    case 'Miscellaneous' : 
                        this.showBtns = false;
                        this.resObj = {
                            header: 'Miscellaneous',
                            content: [{
                                title: 'mLog Privacy',
                                description: 'How It Works',
                                iconUrl: this.privacyIcon + '#privacy'
                            }, {
                                title: 'mBurse Policy',
                                description: 'Our Privacy policy',
                                iconUrl: this.policyIcon + '#policy'
                            }]
                        }
                        break;
            } 
        }
        else{
            switch(resource){
                case 'Onboarding' :
                    this.showBtns = false;
                    this.resObj = {
                        header: 'Onboarding',
                        content: [{
                            title: 'Welcome',
                            description: 'Your Plan Preview',
                            iconUrl: this.previewIcon + '#planPreview'
                        }, {
                            title: 'Guidelines',
                            description: 'Your Plan Guidelines',
                            iconUrl: this.parameterIcon + '#parameter'
                        }, {
                            title: 'mLog Preview',
                            description: 'Demo & Tour',
                            iconUrl: this.previewIcon + '#planPreview'
                        },/* {
                            title: 'Download mLog',
                            description: 'Install & Sign In',
                            iconUrl: this.downloadIcon + '#download'
                        },*/ {
                            title: 'Driver Meeting',
                            description: 'Your Plan Overview',
                            iconUrl: this.previewIcon + '#planPreview'
                        }]
                    }
                    break;
    
                case 'Mileage App' :
                    this.showBtns = true;
                    this.resObj = {
                        header: 'Mileage App',
                        nestedContent: true,
                        content: [{
                                title: 'Onboarding',
                                detail: 'mLog-Onboarding',
                                iconUrl: this.onboardingIcon + '#onboarding'

                            },{
                                title: 'Customizing',
                                detail: 'mLog-Customizing',
                                iconUrl:  this.customizingIcon + '#mCustomize'
                            },{
                                title: 'Troubleshooting',
                                detail: 'mLog-Troubleshooting',
                                iconUrl: this.troubleIcon + '#troubleshoot'
                            },{
                                title: 'Using',
                                detail: 'mLog-Using',
                                iconUrl: this.usingMLogIcon + '#using'
                            }]
                       
                        /*content: [{
                            title: 'Data Sync',
                            description: 'Phone To Dashboard',
                            iconUrl: this.syncIcon + '#syncData'
                        }, {
                            title: 'Troubleshooting',
                            description: 'Debugging mLog',
                            iconUrl: this.troubleIcon + '#troubleshoot'
                        }, {
                            title: 'Optimize',
                            description: 'mLog Settings',
                            iconUrl: this.optimizeIcon + '#optimize'
                        }, {
                            title: `mLog FAQ's`,
                            description: 'What You Need To Know',
                            iconUrl: this.mLogFAQIcon + '#mLogFAQ'
                        }, {
                            title: 'mLog Protips',
                            description: 'How To Use mLog',
                            iconUrl: this.instructionIcon + '#Instruction'
                        }]*/
                    }
                    break;

                case 'Dashboard' : 
                    this.showBtns = false;
                    this.resObj = {
                        header: 'Dashboard',
                        content: [{
                            title: 'mDash',
                            description: 'Dashboard Intro',
                            iconUrl: this.previewIcon + '#planPreview'
                        }]
                    }
                    break;

                case 'mBurse Program' : 
                    this.showBtns = false;
                    this.resObj = {
                        header: 'mBurse Program',
                        content: [{
                            title: 'Compliance',
                            description: 'How It Works',
                            iconUrl: this.complianceIcon + '#compliance'
                        }, /*{
                            title: 'Tax Liability',
                            description: 'How it works',
                            iconUrl: this.liabilityIcon + '#liability'
                        },*/ {
                            title: 'Auto Insurance',
                            description: 'Why & How Much',
                            iconUrl: this.autoInsuranceIcon + '#insurance'
                        }, {
                            title: `mBurse FAQ's`,
                            description: 'What You Need To Know',
                            iconUrl: this.mLogFAQIcon + '#mLogFAQ'
                        }, {
                            title: 'Methodology',
                            description: 'Rate Calculations',
                            iconUrl: this.methodologyIcon + '#methodology'
                        }]
                    }
                    break;
                
                case 'Miscellaneous' : 
                    this.showBtns = false;
                    this.resObj = {
                        header: 'Miscellaneous',
                        content: [{
                            title: 'mLog Privacy',
                            description: 'How It Works',
                            iconUrl: this.privacyIcon + '#privacy'
                        }, {
                            title: 'mBurse Policy',
                            description: 'Our Privacy Policy',
                            iconUrl: this.policyIcon + '#policy'
                        }]
                    }
                    break;
            } 
        }
        //this.driverResource[0].content[1].description = (this.role === 'Admin' || this.role === 'Manager') ? 'Your Plan Guidelines' : 'Your Reimbursement Guidelines'
       // this.resource = (this.role === 'Admin' || this.role === 'Manager') ? this.adminResource : this.driverResource;

    }

    connectedCallback() {
        if(this.resourceName){
            this.previousView = this.resourceName;
            this.renderResource(this.resourceName, this.role);
            if(this.role === 'Admin'){
                this.adminResource.push(this.resObj);
            }else if(this.role === 'Manager'){
               this.managerResource.push(this.resObj);
            }else{
                this.driverResource.push(this.resObj);
            }
            
            this.resource = (this.role === 'Admin') ? this.adminResource : (this.role === 'Manager') ? this.managerResource : this.driverResource;
        }
    }
}