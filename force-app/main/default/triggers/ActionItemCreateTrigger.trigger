trigger ActionItemCreateTrigger on ActionItem__c (after insert,after update) { 

    if (trigger.isAfter ){
        ActionItemCreateCustom__c objCustomSet = ActionItemCreateCustom__c.getValues('CustomData');        

        if(objCustomSet.IsInsertExecution__c && trigger.isInsert)
        {            
            ActionItemCreateTriggerHandler.sendEmail(trigger.new,objCustomSet.InsertEmailTemplate__c);            
        }

        if(objCustomSet.IsUpdateExecution__c && trigger.isUpdate)
        {  
            List<ActionItem__c> actList = new List<ActionItem__c>();
            Set<ActionItem__c> actSet = new Set<ActionItem__c>();
            for(ActionItem__c act : Trigger.new) 
            {                
                ActionItem__c oldAct = Trigger.oldMap.get(act.Id);
                List<string> compareFieldsList = objCustomSet.Compare_Fields__c.split(','); 
                for(string comp:compareFieldsList)
                {                     
                    if(act.get(comp) != oldAct.get(comp))
                    {                        
                        actSet.add(Trigger.newmap.get(act.Id));                        
                    }
                }
            }               
            actList.addAll(actSet);
            
            if(actList != null && actList.size() > 0 )
            {   
                ActionItemCreateTriggerHandler.sendEmail(actList,objCustomSet.UpdateEmailTemplate__c);
            }
        }
    }
}