/*
Author - Nitesh K.(ApplikonTech IT Solution)
Date - 21 Sept 2016
Contact History Tracking for some field for Reports
*/
trigger RG_ContactAuditTrailCreate on Contact (after Update, after insert, before insert, before update) {
    
    /*if(Trigger.isUpdate && Trigger.isAfter && !RG_CummuntyUserCreateTgr.isRecursive) {
        RG_ContactAuditTrailCreateTgrCls.TrackHistory(Trigger.new,Trigger.old);
        Set<Id> conIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Set<Id> contactNameChange = new Set<Id>();
        for(Contact singleContact : Trigger.New) {
            if(singleContact.Role__c != Trigger.oldMap.get(singleContact.Id).Role__c) {
                conIds.add(singleContact.Id);  
            }
            if(singleContact.External_Email__c != Trigger.oldMap.get(singleContact.Id).External_Email__c) {
                contactIds.add(singleContact.Id);
            }
            if((singleContact.FirstName != Trigger.oldMap.get(singleContact.Id).FirstName) || (singleContact.LastName != Trigger.oldMap.get(singleContact.Id).LastName)) {
                contactNameChange.add(singleContact.Id);
            }
        }
        if(!conIds.isEmpty()) {
            RG_CummuntyUserCreateTgr.changeProfileRole(conIds);
        }
        if(!contactIds.isEmpty()) {
            RG_CummuntyUserCreateTgr.updateUserEmail(contactIds);
        }
        if(!contactNameChange.isEmpty()) {
            RG_CummuntyUserCreateTgr.updateUserData(contactNameChange);
        }
        RG_CummuntyUserCreateTgr.updateComplianceStatus(Trigger.New, Trigger.oldMap);
        RG_CummuntyUserCreateTgr.sendEmailToAdmin(Trigger.New, Trigger.oldMap, Trigger.Old);
    }
    
    if(Trigger.isInsert) {
        //RG_CummuntyUserCreateTgr commObj = new RG_CummuntyUserCreateTgr();
        RG_CummuntyUserCreateTgr.setAdminAsManager(Trigger.New);
        if(Trigger.isAfter) {
            RG_CummuntyUserCreateTgr obj = new RG_CummuntyUserCreateTgr();
            obj.CommunityUserCreate(Trigger.new);
        }
    }
    if(Trigger.isBefore && !RG_CummuntyUserCreateTgr.isRecursive) {
        RG_ContactAuditTrailCreateTgrCls.populatestaticValue(Trigger.New);
    }*/
}