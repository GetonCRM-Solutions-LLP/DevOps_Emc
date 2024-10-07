public with sharing class ResourceController {
    public static String videoCustom {get;set;}
    public static String contactDetails {get;set;}
    public String obj_content_version {get;set;}
    public List<Attachment> driverPacketAttachmentList {get;set;}
    public ResourceController() {
       NewDashboardVideoLink__c videoCustomSetting = NewDashboardVideoLink__c.getOrgDefaults();
       videoCustom = json.serialize(videoCustomSetting );
       contactDetails = getContactDetail(getContactid());
       driverPacketAttachmentList = new List<Attachment>();
       driverPacketAttachmentList = [select id,Body,Name from Attachment where ParentId =: getAccountid() and Name LIKE '%Parameters%' order by createddate desc limit 1];
       try{
            List<ContentDocumentLink> contentDocLink = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink where LinkedEntityId  =: getAccountid()];
            Set<Id> ids = new Set<Id>();
            for(ContentDocumentLink obj:  contentDocLink){
                ids.add(obj.ContentDocumentId);
            }
            ContentDistribution contentDist = [SELECT id,ContentDownloadUrl from ContentDistribution where ContentDocumentId in : ids and Name Like '%Parameters%' order by createddate desc limit 1];
            obj_content_version = contentDist.ContentDownloadUrl;
        }catch(Exception e){System.debug('Exception:-->'+e.getmessage()+'--'+e.getLineNumber());}
    }
    
    public static String getContactid() {
        if(ApexPages.currentPage().getParameters().containsKey('id') && String.isNotBlank(ApexPages.currentPage().getParameters().get('id'))) {
           return ApexPages.currentPage().getParameters().get('id');
        } else {
            return '';
        } 
    }
    
    public static String getAccountid()
    {
        if(ApexPages.currentPage().getParameters().containsKey('accid') && String.isNotBlank(ApexPages.currentPage().getParameters().get('accid'))) {
           return ApexPages.currentPage().getParameters().get('accid');
        } else {
            return '';
        } 
    }
    
    public static string getContactDetail(String contactId){
        List<ContactWrapper> contactWrapList = new List<ContactWrapper >();
        date currentDate = system.today();
        try{
                for(Contact contactobj : [SELECT Id,External_Email__c,
                                                Phone,
                                                Vehicle_Value__c, 
                                                Vehicle_Age__c,
                                                Plan_Years__c,
                                                Compliance_Mileages__c,
                                                Schedule_Driver_Meeting__c,
                                                Account.Goto_Driver_Meeting__c,
                                                Account.Schedule_Goto_Meeting__c,
                                                Account.Bodily_Injury__c, 
                                                Account.Uninsured_Motorist__c, 
                                                Account.Property_Damage__c, 
                                                Account.Comprehensive__c, 
                                                Account.Collision__c,
                                                Account.Umbrella_Coverage__c,
                                                Account.MburseDashboardRedirect__c 
                                            FROM Contact  
                                            WHERE Id =: contactId
                                            WITH SECURITY_ENFORCED]){
                                                ContactWrapper contactWrapper = new ContactWrapper();                                        
                                                contactWrapper.contactId =  contactobj.Id;
                                                contactWrapper.contactEmail =  contactobj.External_Email__c;
                                                contactWrapper.phone =  String.valueOf(contactobj.Phone);                                                
                                                contactWrapper.meetingVideoLink =  contactobj.Account.Goto_Driver_Meeting__c != null ? contactobj.Account.Goto_Driver_Meeting__c : null;
                                                contactWrapper.scheduleLink =  contactobj.Account.Schedule_Goto_Meeting__c != null ? contactobj.Account.Schedule_Goto_Meeting__c : null;
                                                contactWrapper.bodilyInjury =  contactobj.Account.Bodily_Injury__c != null ? contactobj.Account.Bodily_Injury__c : null;
                                                contactWrapper.unInsuranceMotorist =  contactobj.Account.Uninsured_Motorist__c != null ? contactobj.Account.Uninsured_Motorist__c : null;
                                                contactWrapper.propertyDamage =  contactobj.Account.Property_Damage__c != null ? contactobj.Account.Property_Damage__c : null;
                                                contactWrapper.comprehensive =  contactobj.Account.Comprehensive__c != null ? contactobj.Account.Comprehensive__c : null;
                                                contactWrapper.collision =  contactobj.Account.Collision__c != null ? contactobj.Account.Collision__c : null;
                                                contactWrapper.umbrella =  contactobj.Account.Umbrella_Coverage__c != null ? contactobj.Account.Umbrella_Coverage__c : null;
                                                contactWrapper.complianceMileage =  contactobj.Compliance_Mileages__c != null ? contactobj.Compliance_Mileages__c : null;
                                                contactWrapper.vehicleValue =  contactobj.Vehicle_Value__c != null ? contactobj.Vehicle_Value__c : null;
                                                contactWrapper.vehicleAge =  contactobj.Vehicle_Age__c != null ? contactobj.Vehicle_Age__c : null;
                                                contactWrapper.planYear =  contactobj.Plan_Years__c != null ? contactobj.Plan_Years__c : null;
                                                contactWrapper.checkDriverMeeting =  contactobj.Schedule_Driver_Meeting__c != null ? contactobj.Schedule_Driver_Meeting__c : false;
                                                contactWrapper.mburseDashboard =  contactobj.Account.MburseDashboardRedirect__c != null ? contactobj.Account.MburseDashboardRedirect__c : false;
                                                contactWrapList.add(contactWrapper);
                                            }
        } catch(System.QueryException qe) {
            System.debug(qe.getMessage());
        }
        return JSON.serialize(contactWrapList);       
    }
    
    @AuraEnabled
    public static string sendMlogWelcomeEmail(String accountID,String empEmail) {       
        String jsonSubset = RosterController.putHTTP(accountID,empEmail);        
        return jsonSubset;
    }
    public class ContactWrapper {
        public string contactId { get; set; }
        public string contactEmail {get; set;}
        public string phone {get; set;}
        public string meetingVideoLink {get; set;}
        public string scheduleLink {get; set;}
        public string bodilyInjury {get; set;}
        public string unInsuranceMotorist {get; set;}
        public Decimal propertyDamage {get; set;}
        public Decimal comprehensive {get; set;}
        public Decimal collision {get; set;}
        public Decimal umbrella {get; set;}
        public Decimal complianceMileage {get; set;}
        public Decimal vehicleValue {get; set;}
        public string vehicleAge {get; set;}
        public Decimal planYear {get;set;}
        public Boolean mlogApp {get; set;}
        public Boolean checkDriverMeeting {get; set;}
        public Boolean mburseDashboard {get; set;}
    }
}