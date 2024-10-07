import { LightningElement, wire, api } from 'lwc';
import getDriverDetails  from '@salesforce/apex/DriverDashboardLWCController.getDriverDetails';
import resourceImage from '@salesforce/resourceUrl/mBurseCss';
import WAITING_FOR_DOCUMENTATION from '@salesforce/label/c.waitingfordocumentation';
import INSURANCE_CARD from '@salesforce/label/c.Insurancecard';
import EXPIRED_INSURANCE from '@salesforce/label/c.ExpiredInsurance';
import MISSING_COVERAGE_DATES from '@salesforce/label/c.MissingCoverageDates';
import COMPLIANCE_NOT_MEETING from '@salesforce/label/c.compliancenotmeeting';
import INSURANCE_NOT_MEETING from '@salesforce/label/c.insuranceisnotmeeting';
import INSURANCE_NOT_MEETING_MINIMUM from '@salesforce/label/c.noInsurancenotmeetingminimum';
import NO_VEHICLE_VALUE from '@salesforce/label/c.novehiclevalue';
import NO_VEHICLE_AGE from '@salesforce/label/c.NoVehicleAge';
import COMPLIANCE from '@salesforce/label/c.compliance';
import Compliance_Message from '@salesforce/label/c.Compliance_Message';
import No_Insurance_Declaration_Page from '@salesforce/label/c.noInsuranceDeclarationPage';
import No_Mileage_Insurance from '@salesforce/label/c.noMileageInsurance';
import No_Mileage_Vehicle_Age from '@salesforce/label/c.noMileageVehicleAge';
import No_Mileage_Vehicle_Value from '@salesforce/label/c.noMileageVehicleValue';
import No_Umbrella_Policy from '@salesforce/label/c.noUmbrellaPolicy';
import Compliance_Pending from '@salesforce/label/c.CompliancePending';

export default class UserCompliance extends LightningElement {
    exclaimIcon = resourceImage + '/mburse/assets/mBurse-Icons/exclaim.png';
    maginifyIcon = resourceImage + '/mburse/assets/mBurse-Icons/Middle-block/5.png';
    umbrellaIcon = resourceImage + '/mburse/assets/mBurse-Icons/Plan-Parameters/6.png';
    milesPlanIcon = resourceImage + '/mburse/assets/mBurse-Icons/Plan-Parameters/7.png';
    calendarPlanIcon = resourceImage + '/mburse/assets/mBurse-Icons/Plan-Parameters/8.png';
    carPlanIcon = resourceImage + '/mburse/assets/mBurse-Icons/Plan-Parameters/9.png';
    insurancePlanIcon = resourceImage + '/mburse/assets/mBurse-Icons/Plan-Parameters/10.png';
    checkMark = resourceImage + '/mburse/assets/mBurse-Icons/check.png';
    crossMark = resourceImage + '/mburse/assets/mBurse-Icons/Cross.png';
    planInsurance = false;
    planMileage = false;
    planVehicleAge = false;
    planVehicleValue = false;
    planCompliance = false;
    showTaxLiability = false;
    planYear = '';
    complianceMileage = '';
    vehicleValue = '';
    insurancePlan = '';
    complianceStatus = '';
    messageOfCompliance = '';
    annualMileage = '';
    annualReimbursement = '';
    avgMileage = ''
    complianceVideoUrl = '';
    // width of video
    videoWidth = "100%";

    // height of video
    videoHeight = "332px";
    @api contactId;
    @api settings;
    
    proxyToObject(e) {
        return JSON.parse(e)
    }

    redirectToLiability(){
        const redirectEvent = new CustomEvent('redirect', {detail: 'Liability'});
        this.dispatchEvent(redirectEvent);
    }

    complianceMessage(Status) {
		if(Status === null || Status === undefined){
            this.messageOfCompliance = WAITING_FOR_DOCUMENTATION + '. ' + Compliance_Message;
        }else{
            if(this.planInsurance === true &&  this.planVehicleAge === true && this.planVehicleValue === true && Status === 'Yes' && this.planMileage === true){
                this.messageOfCompliance = COMPLIANCE;
            }else{
                if(Status === 'No – Insurance Card'){
                    this.messageOfCompliance = INSURANCE_CARD + '. ' + Compliance_Message;
                }
                else if((Status === 'No - Expired Insurance' || Status === 'Expired Insurance')){
                    this.messageOfCompliance = EXPIRED_INSURANCE + '. ' + Compliance_Message;
                }
                else if(Status === 'No - Missing Coverage Dates'){
                    this.messageOfCompliance = MISSING_COVERAGE_DATES + '. ' + Compliance_Message;
                }
                else if(Status === 'No – Insurance Not Meeting Minimum'){
                    this.messageOfCompliance = INSURANCE_NOT_MEETING_MINIMUM + '. ' + Compliance_Message;
                }
                else if(Status === 'No – Vehicle Value'){
                    this.messageOfCompliance = NO_VEHICLE_VALUE + '. ' + Compliance_Message;
                }
                else if(Status === 'No - Mileage'){
                    this.messageOfCompliance = COMPLIANCE_NOT_MEETING + '. ' + Compliance_Message;
                }
                else if(Status === 'No - Insurance Not Provided'){
                    this.messageOfCompliance = INSURANCE_NOT_MEETING + '. ' + Compliance_Message;
                }
                else if(Status === 'No – Vehicle Age'){
                    this.messageOfCompliance = NO_VEHICLE_AGE + '. ' + Compliance_Message;
                }
                else if(Status === 'No - Mileage & Insurance'){
                    this.messageOfCompliance = No_Mileage_Insurance + '. ' + Compliance_Message;
                }
                else if(Status === 'No - Mileage & Vehicle Age'){
                    this.messageOfCompliance = No_Mileage_Vehicle_Age + '. ' + Compliance_Message;
                }
                else if(Status === 'No - Mileage & Vehicle Value'){
                    this.messageOfCompliance = No_Mileage_Vehicle_Value + '. ' + Compliance_Message;
                }
                else if(Status === 'No - Insurance Dec Page'){
                    this.messageOfCompliance = No_Insurance_Declaration_Page + '. ' + Compliance_Message;
                }
                else if(Status === 'No - Umbrella Policy'){
                    this.messageOfCompliance = No_Umbrella_Policy + '. ' + Compliance_Message;
                }
                else if(Status === 'Pending'){
                    this.messageOfCompliance = Compliance_Pending + '. ' + Compliance_Message;
                }
            }
        }
	}

    @wire(getDriverDetails, {
        contactId:'$contactId'
    })driverDetailInfo({data,error}) {
        if (data) {
            let count = 0;
            let contactList = this.proxyToObject(data);
            let settings = this.settings;
            this.complianceVideoUrl = settings.Compliance__c;
            this.contactDetails = contactList;
            this.planInsurance = (this.contactDetails[0].Insurance__c !== undefined) ? (this.contactDetails[0].Insurance__c === 'Yes') ? true : false : false;
          //  this.planMileage =    (this.contactDetails[0].Mileage_Meet__c !== undefined) ? (this.contactDetails[0].Mileage_Meet__c === 'Yes') ? true : false : false;
            this.planVehicleAge =  (this.contactDetails[0].Vehicle_Age__c !== undefined) ?  (this.contactDetails[0].Vehicle_Age__c === 'Yes') ? true : false : false;
            this.planVehicleValue = (this.contactDetails[0].Vehicle_Value_Check__c !== undefined) ?   (this.contactDetails[0].Vehicle_Value_Check__c === 'Yes') ? true : false : false;
            this.planCompliance =  (this.contactDetails[0].monthly_compliance_status__c !== undefined) ?  (this.contactDetails[0].monthly_compliance_status__c === 'Yes') ? true : false : false;
            this.planYear = (this.contactDetails[0].Plan_Years__c !== undefined) ?  this.contactDetails[0].Plan_Years__c : 0;
            this.complianceMileage = (this.contactDetails[0].Compliance_Mileage__c !== undefined) ? this.contactDetails[0].Compliance_Mileage__c : 0;
            this.vehicleValue = (this.contactDetails[0].Vehicle_Value__c !== undefined) ? (this.contactDetails[0].Vehicle_Value__c) : 0;
            this.insurancePlan = (this.contactDetails[0].Insurance_Plan__c !== undefined) ? this.contactDetails[0].Insurance_Plan__c : '';
            this.complianceStatus = (this.contactDetails[0].monthly_compliance_status__c !== undefined) ? this.contactDetails[0].monthly_compliance_status__c : '';
            this.avgMileage = (this.contactDetails[0].Avg_Mileage__c !== undefined) ? this.contactDetails[0].Avg_Mileage__c : '0';
            this.annualMileage = (this.contactDetails[0].Total_Approved_Mileages__c !== undefined) ? this.contactDetails[0].Total_Approved_Mileages__c : '0';
            this.annualReimbursement = (this.contactDetails[0].Total_reimbursment__c !== undefined) ? this.contactDetails[0].Total_reimbursment__c : '0';
            //this.isValid = parseFloat(this.annualMileage) >= parseFloat(this.complianceMileage) ? true : false;
            this.isValid = parseFloat(this.avgMileage) >= 416.66 ? true : false;
            this.planMileage =  (this.isValid) ? true : false;
            this.complianceMessage(this.contactDetails[0].monthly_compliance_status__c);
            console.log("getDriverDetails data", data, contactList)
            count = (this.planInsurance === true &&  this.planVehicleAge === true && this.planVehicleValue === true && this.planCompliance === true && this.planMileage === true) ? count + 1 : 0
            this.showTaxLiability = (count > 0) ? false : true;
        }else if(error){
            console.log("getDriverDetails error", error)
        }
    }
}