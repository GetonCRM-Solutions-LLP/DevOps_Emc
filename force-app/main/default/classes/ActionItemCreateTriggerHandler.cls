public with sharing class ActionItemCreateTriggerHandler {   
    public static void sendEmail(List<ActionItem__c> action, String emailTemplateName)
    {
        ActionItemCreateCustom__c objCustomSet = ActionItemCreateCustom__c.getValues('CustomData');
        
        List<String> actId = new List<String>();
        for(ActionItem__c act : action)
		{
            actId.add(act.id);
		}

        List<string> actionItemFields = new List<string>();
        actionItemFields = Utils.getAllFields('ActionItem__c');

        String objectName = 'ActionItem__c';
        SObjectType actType = ((SObject)(Type.forName('Schema.ActionItem__c').newInstance())).getSObjectType();
        DescribeSObjectResult descSObject = actType.getDescribe();

        Map<String,String> refMap = new Map<String,String>();
        List<string> actionItemFieldAdd = new List<string>();
        for(String actField:actionItemFields)
        { 
            if(String.valueof(descSObject.fields.getMap().get(actField).getDescribe().getType()) == 'REFERENCE' && actField.contains('__c') == true)
            { 
                String actRefField = actField.replace('__c', '__r.Name');               
                refMap.put(actField, actRefField);
                actionItemFieldAdd.add(actRefField);
            }            
            if(String.valueof(descSObject.fields.getMap().get(actField).getDescribe().getType()) == 'REFERENCE' 
                    && actField.contains('__c') != true && actField.contains('Id') == true
                    && actField !='ConnectionReceivedId' && actField !='ConnectionSentId')
            { 
                String actRefField = actField.replace('Id', '.Name'); 
                String actStaRefField = actField.replace('Id', '');               
                refMap.put(actStaRefField, actRefField);
                actionItemFieldAdd.add(actRefField);                            
            }
        }
        actionItemFields.addAll(actionItemFieldAdd);
        actionItemFields.add('Ticket_User__r.email__c');

        String query = String.join(actionItemFields, ', ');            
        query = 'SELECT '+ query + ' FROM ActionItem__c WHERE Id In: actId'; 

        List<ActionItem__c> actionData = new list<ActionItem__c>();
        actionData = Database.query(query); 
        
        EmailTemplate emailTemplate = [SELECT Id,
                                              HtmlValue,
                                              Name,
                                              Subject 
                                       FROM EmailTemplate 
                                       WHERE DeveloperName =: emailTemplateName];
        String newBody = emailTemplate.HtmlValue;        
        String emailSubject = emailTemplate.Subject;        

        List<Messaging.SingleEmailMessage> masterListMails = new List<Messaging.SingleEmailMessage>();

        for(ActionItem__c actDataRecord:actionData)
        { 
            for(String actField:actionItemFields)
            {            
                String actFieldEmail = actField;
                if(actField.right(2) == 'Id' && actField != 'Id')
                {
                    actFieldEmail = actField.replace('Id','');
                }  

                if(newBody.contains(actFieldEmail) == true)
                {
                    String actValue = '';                
                    if(refMap.containsKey(actFieldEmail) == false)
                    {
                        actValue = string.valueof(actDataRecord.get(actField));                                            
                    }
                    else {
                        String fieldMapValue = refMap.get(actFieldEmail);                    
                        List<String> objectNfield = fieldMapValue.split('\\.');                                    
                        if(string.valueof(actDataRecord.get(actField)) != null)
                        {
                            actValue = (String) actDataRecord.getSobject(objectNfield[0]).get(objectNfield[1]);
                        }                    
                                         
                    }                
                    if(actValue == null)
                    {
                        actValue = '';
                    }               
                    newBody = newBody.replace('{!ActionItem__c.'+actFieldEmail+'}',actValue); 
                }            
            }

            String actURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + actDataRecord.Id;
            if(newBody.contains('.Link'))
            {
                newBody = newBody.replace('{!ActionItem__c.Link}',actURL); 
            }

            String subjectField = emailSubject.subStringBetween('{!ActionItem__c.', '}');
            if(subjectField != null)
            {
                String subValue = string.valueof(actDataRecord.get(subjectField));   
                emailSubject = emailSubject.replace('{!ActionItem__c.'+subjectField+'}',subValue); 
            }

            messaging.singleEmailMessage mail = new messaging.singleEmailMessage();
            mail.setHtmlBody(newBody);
            mail.setSubject(emailSubject);
            String[] toAddresses = new String[] {actDataRecord.Ticket_User__r.email__c};
            mail.setToAddresses(toAddresses);            
            List<String> CcAddresses = new List<String>();
            CcAddresses = objCustomSet.NewActionItemEmailCc__c.split(',');             
            if(CcAddresses != null)
            {
                mail.setCcAddresses(CcAddresses);                
            }
            masterListMails.add(mail);
        }

        if(!Test.isRunningTest() && !masterListMails.isEmpty()) 
        {           
            Messaging.sendEmail(masterListMails);
        }
    }
}