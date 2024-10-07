public with sharing class UpdateInsuranceDataController {
    public static String accId;
    public List<ContactWrapper> conWrapList {get; set;}
    public string conWrapper {get; set;}
    public UpdateInsuranceDataController() {
        accId = ApexPages.currentPage().getParameters().get('id');
        System.debug('accId=='+accId);
        if(accId != null){
            System.debug('accId'+accId);
           conWrapper = updatedNewEmployee();
        }
    }
    
    @RemoteAction
    public static string updatedNewEmployee()
    {
        System.debug('updatedNewEmployee');
        List<ContactWrapper> conWrapList = new List<ContactWrapper>();
            for(Contact con : [SELECT id,name,Insurance__c, Meeting_Minimum__c,
                                        Current_Level__c, Expiration_Date__c,
                                        Vehicle_Value_Check__c, Vehicle_Age__c,
                                        monthly_compliance_status__c, Role__c,Added_Date__c 
                                FROM Contact 
                                WHERE AccountId =: accId 
                                AND Role__c != 'Admin' AND Role__c != 'Manager' 
                                AND Deactivated_Date__c = null order by FirstName asc]) {
                                    ContactWrapper conWrap = new ContactWrapper();
                                    conWrap.contactId = con.Id;
                                    conWrap.name = con.Name;
                                    conWrap.insurance = con.Insurance__c;
                                    conWrap.meetingMinimum = con.Meeting_Minimum__c;
                                    if(con.Current_Level__c != null){
                                        conWrap.currentLeval = con.Current_Level__c;
                                    }
                                    if(con.Expiration_Date__c != null){
                                        //conWrap.expirationDate = con.Expiration_Date__c;
                                        conWrap.expirationDate = String.valueOf(con.Expiration_Date__c.month())+'/'+String.valueOf(con.Expiration_Date__c.day())+'/'+String.valueOf(con.Expiration_Date__c.year());
                                    }
                                    conWrap.vehicleValue = con.Vehicle_Value_Check__c;
                                    conWrap.vehicleAge = con.Vehicle_Age__c;
                                    conWrap.complianceStatus = con.monthly_compliance_status__c;
                                    conWrap.addedDate = con.Added_Date__c;
                                    conWrap.isEditable = false;
                                    conWrapList.add(conWrap);
            }
            System.debug('conWrapList'+conWrapList.size());
            String wrapjson = JSON.serialize(conWrapList);
            System.debug('wrapjson'+wrapjson);
            return wrapjson;
    }
    @RemoteAction
    public static string editInlineNewEmployee(String listofemployee)
    {
        System.debug('editInlineNewEmployee'+listofemployee);
        List<Contact> updateEmployeeList = new List<Contact>();
        map<id,Contact> conMap = new map<id,Contact>();
        if(listofemployee!=null)
        {
            List<ContactWrapper> conWrapUpdateList = new List<ContactWrapper>();
            conWrapUpdateList = (List<ContactWrapper>)Json.deserialize(listofemployee,List<ContactWrapper>.class);
            
            for(ContactWrapper conwrap : conWrapUpdateList){
                system.debug('conwrap.contactId'+ conwrap.contactId);
                System.debug('conwrap.meetingMinimum'+conwrap.meetingMinimum);
                Contact currentContact = new Contact();
                currentContact.Id = conwrap.contactId;
                currentContact.Insurance__c = conwrap.insurance;
                
                currentContact.Meeting_Minimum__c = conwrap.meetingMinimum;
                //currentContact.Current_Level__c = date.valueOf(conwrap.currentLeval);
                if(conwrap.expirationDate != null){
                    currentContact.Expiration_Date__c = date.valueOf(conwrap.expirationDate);
                } else {
                    currentContact.Expiration_Date__c = null;
                }
                
                currentContact.Vehicle_Value_Check__c = conwrap.vehicleValue;
                currentContact.Vehicle_Age__c = conwrap.vehicleAge;
                currentContact.monthly_compliance_status__c	 = conwrap.complianceStatus;
                updateEmployeeList.add(currentContact);
            }
        }
        conMap.putall(updateEmployeeList);
        if(conMap.size() > 0){
            
            update conMap.values();
        }
        System.debug('2nd updatedNewEmployee');
        return 'Success';
    }
    @RemoteAction
    public static String getComplianceStatus()
    {
        List<String> roleList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Contact.monthly_compliance_status__c.getDescribe();
        List<Schema.PicklistEntry> pickListEntries = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry currentEntries : pickListEntries)
        {
            roleList.add(currentEntries.getValue());
        }
        return JSON.serialize(roleList);     
    }
    
    public class ContactWrapper {
        public string contactId { get; set; }
        public string name { get; set; }
        public string insurance { get; set; }
        public Boolean meetingMinimum { get; set; }
        public Boolean isEditable { get; set; }
        public date currentLeval { get; set; }
        public date addedDate { get; set; }
        public String expirationDate { get; set; }
        public string vehicleValue { get; set; }
        public string vehicleAge { get; set; }
        public string complianceStatus { get; set; }
    }
}