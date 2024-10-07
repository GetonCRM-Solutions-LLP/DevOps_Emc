/*
Author - Nitesh K.(ApplikonTech IT Solution)
Date- 21 Sept 2016
      Trigger "RG_ContactAuditTrailCreate"
*/
public class RG_ContactAuditTrailCreateTgrCls {
    
    public static void TrackHistory(List<Contact> conNew,list<Contact> conOld){
        
        //Map for Manager Name
        Map<id,String> conNewMapidName=new Map<id,string>();
        for(Contact c:[select id, Name from Contact]){
            conNewMapidName.put(c.id,c.Name);
        }
        //Audit Trial
        list<AuditTrail__c> newAuditTrialCreate=new list<AuditTrail__c>();
        for(Contact c:conNew){
            for(Contact ConOldMap:conOld){
                if(c.id==ConOldMap.id){
                if(c.Fixed_Amount__c!=ConOldMap.Fixed_Amount__c)
                newAuditTrialCreate.add(new AuditTrail__c(Field__c='Fixed Amount',Timestamp__c=Datetime.now(),Modifiedby__c=UserInfo.getFirstName()+' '+UserInfo.getLastName(),NewValue__c=string.valueof(c.Fixed_Amount__c),OldValue__c=String.Valueof(ConOldMap.Fixed_Amount__c),Contact__c=c.id));
                if(c.Maintenance_and_Tires__c!=ConOldMap.Maintenance_and_Tires__c)
                    newAuditTrialCreate.add(new AuditTrail__c(Field__c='Maintenance and Tires',Timestamp__c=Datetime.now(),Modifiedby__c=UserInfo.getFirstName()+' '+UserInfo.getLastName(),NewValue__c=String.valueof(c.Maintenance_and_Tires__c),OldValue__c=string.valueof(ConOldMap.Maintenance_and_Tires__c),Contact__c=c.id));
                if(c.Vehicle1Odometer__c!=ConOldMap.Vehicle1Odometer__c)
                    newAuditTrialCreate.add(new AuditTrail__c(Field__c='Vehicle 1 Odometer',Timestamp__c=Datetime.now(),Modifiedby__c=UserInfo.getFirstName()+' '+UserInfo.getLastName(),NewValue__c=String.Valueof(c.Vehicle1Odometer__c),OldValue__c=String.Valueof(ConOldMap.Vehicle1Odometer__c),Contact__c=c.id));
                if(c.Vehicle2Odometer__c!=ConOldMap.Vehicle2Odometer__c)
                    newAuditTrialCreate.add(new AuditTrail__c(Field__c='Vehicle 2 Odometer',Timestamp__c=Datetime.now(),Modifiedby__c=UserInfo.getFirstName()+' '+UserInfo.getLastName(),NewValue__c=String.Valueof(c.Vehicle2Odometer__c),OldValue__c=String.Valueof(ConOldMap.Vehicle2Odometer__c),Contact__c=c.id));
                if(c.MailingStreet!=ConOldMap.MailingStreet || c.MailingCity!=ConOldMap.MailingCity || c.MailingState!=ConOldMap.MailingState || c.MailingPostalCode!=ConOldMap.MailingPostalCode || c.MailingCountry!=ConOldMap.MailingCountry ){
                    string newval=(c.MailingStreet!=null?c.MailingStreet:'') +' '+ (c.MailingCity!=null?c.MailingCity:'') +' '+ (c.MailingState!=null?c.MailingState:'') +' '+ (c.MailingPostalCode!=null?c.MailingPostalCode:'') +' '+ (c.MailingCountry!=null?c.MailingCountry:'');
                    string oldVal=(ConOldMap.MailingStreet!=null?ConOldMap.MailingStreet:'') +' '+ (ConOldMap.MailingCity!=null?ConOldMap.MailingCity:'') +' '+ (ConOldMap.MailingState!=null?ConOldMap.MailingState:'') +' '+ (ConOldMap.MailingPostalCode!=null?ConOldMap.MailingPostalCode:'') +' '+ (ConOldMap.MailingCountry!=null?ConOldMap.MailingCountry:'');
                    newAuditTrialCreate.add(new AuditTrail__c(Field__c='Address',Timestamp__c=Datetime.now(),Modifiedby__c=UserInfo.getFirstName()+' '+UserInfo.getLastName(),NewValue__c=newval,OldValue__c=oldVal,Contact__c=c.id));
                }
                if(c.MPG__c!=ConOldMap.MPG__c)
                    newAuditTrialCreate.add(new AuditTrail__c(Field__c='Miles per Gallon',Timestamp__c=Datetime.now(),Modifiedby__c=UserInfo.getFirstName()+' '+UserInfo.getLastName(),NewValue__c=String.Valueof(c.MPG__c),OldValue__c=String.Valueof(ConOldMap.MPG__c),Contact__c=c.id));
                if(c.Manager__c!=ConOldMap.Manager__c) 
                    newAuditTrialCreate.add(new AuditTrail__c(Field__c='Manager',Timestamp__c=Datetime.now(),Modifiedby__c=UserInfo.getFirstName()+' '+UserInfo.getLastName(),NewValue__c=conNewMapidName.get(c.Manager__c),OldValue__c=conNewMapidName.get(ConOldMap.Manager__c),Contact__c=c.id));
                if(c.compliancestatus__c!=ConOldMap.compliancestatus__c)
                    newAuditTrialCreate.add(new AuditTrail__c(Field__c='Compliance Status',Timestamp__c=Datetime.now(),Modifiedby__c=UserInfo.getFirstName()+' '+UserInfo.getLastName(),NewValue__c=String.Valueof(c.compliancestatus__c),OldValue__c=String.Valueof(ConOldMap.compliancestatus__c),Contact__c=c.id));
                if(c.Vehicle_Type__c!=ConOldMap.Vehicle_Type__c)
                    newAuditTrialCreate.add(new AuditTrail__c(Field__c='Standard Vehicle Make Model and Year',Timestamp__c=Datetime.now(),Modifiedby__c=UserInfo.getFirstName()+' '+UserInfo.getLastName(),NewValue__c=c.Vehicle_Type__c,OldValue__c=ConOldMap.Vehicle_Type__c,Contact__c=c.id));
                }
                
            }
            
        }
    
        if(newAuditTrialCreate.Size()>0)
            upsert newAuditTrialCreate; 
    }

    public static void populatestaticValue(List<Contact> conList){
        Boolean isEMCUser = [select UserRole.name from User where Id=:userinfo.getUserId()].UserRole.Name == 'EMC' ? true : false;

        for(Contact c:conList) {
            if(!isEMCUser){
                c.Pay_Number__c = '3';
                c.Batch_ID_Fixed__c = 'M351';
                c.Adjust_Ded_Code_Fixed__c = 'MR';
                c.Batch_Variable_ID__c = 'M352';
                c.Adjust_Ded_Code_Variable__c = 'VR';
                c.Special_Action__c = 'W';  
            }  else {
                c.Pay_Number__c = String.IsBlank(c.Pay_Number__c) ? '3' : c.Pay_Number__c;
                c.Batch_ID_Fixed__c = String.IsBlank(c.Batch_ID_Fixed__c) ? 'M351' : c.Batch_ID_Fixed__c;
                c.Adjust_Ded_Code_Fixed__c = String.IsBlank(c.Adjust_Ded_Code_Fixed__c) ? 'MR' : c.Adjust_Ded_Code_Fixed__c;
                c.Batch_Variable_ID__c = String.IsBlank(c.Batch_Variable_ID__c) ? 'M352' : c.Batch_Variable_ID__c;
                c.Adjust_Ded_Code_Variable__c = String.IsBlank(c.Adjust_Ded_Code_Variable__c) ? 'VR' : c.Adjust_Ded_Code_Variable__c;
                c.Special_Action__c = String.IsBlank(c.Special_Action__c) ? 'W' : c.Special_Action__c;  
            } 
        }

        
    }
}