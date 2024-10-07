trigger updateHourstoActionItem on DailyStatus__c (After Insert, After Update) 
{
    Map<String,Decimal> obj_hours_actionitem = new Map<String,Decimal>();
    
    if(Trigger.IsInsert)
    {
        for(DailyStatus__c obj_current_status:Trigger.New)
        {
            if(!obj_hours_actionitem.containsKey(obj_current_status.ActionItem__c))
            {
                // if not exist
                if(obj_current_status.Working_Hours__c!=null)
                {
                    obj_hours_actionitem.put(obj_current_status.ActionItem__c,obj_current_status.Working_Hours__c);
                }
                else
                {
                    obj_hours_actionitem.put(obj_current_status.ActionItem__c,0);
                }               
            }
            else
            {
                //if exist
                Decimal workinghours = obj_hours_actionitem.get(obj_current_status.ActionItem__c);
                if(obj_current_status.Working_Hours__c!=null)
                {                     
                     workinghours = workinghours +obj_current_status.Working_Hours__c;                     
                }
                else
                {                     
                     workinghours = workinghours +0;                     
                }
                obj_hours_actionitem.put(obj_current_status.ActionItem__c,workinghours);
            }
        }
    }
    else if(Trigger.IsUpdate)
    {
        for(DailyStatus__c obj_current_status:Trigger.New)
        {
            if((Trigger.OldMap.get(obj_current_status.id).ActionItem__c==Trigger.NewMap.get(obj_current_status.id).ActionItem__c)&&(Trigger.OldMap.get(obj_current_status.id).Working_Hours__c!=Trigger.NewMap.get(obj_current_status.id).Working_Hours__c))
            {
                if(!obj_hours_actionitem.containsKey(obj_current_status.ActionItem__c))
                {
                    // if not exist
                    if(obj_current_status.Working_Hours__c!=null)
                    {
                         obj_hours_actionitem.put(obj_current_status.ActionItem__c,obj_current_status.Working_Hours__c);
                    }
                    else
                    {
                        obj_hours_actionitem.put(obj_current_status.ActionItem__c,0);
                    }                   
                }
                else
                {
                    //if exist
                    Decimal workinghours = obj_hours_actionitem.get(obj_current_status.ActionItem__c);
                    if(obj_current_status.Working_Hours__c!=null)
                    {                     
                         workinghours = workinghours +obj_current_status.Working_Hours__c;                     
                    }
                    else
                    {                     
                         workinghours = workinghours +0;                     
                    }
                    obj_hours_actionitem.put(obj_current_status.ActionItem__c,workinghours);
                }
            }            
        }
    }
    
    List<ActionItem__c> obj_list_ActionItems = new List<ActionItem__c>();
    if(Trigger.IsUpdate)
    {
        for(ActionItem__c obj:[Select id,Total_Working_Hours__c from ActionItem__c where id=:obj_hours_actionitem.keySet()])
        {
             obj.Total_Working_Hours__c = obj.Total_Working_Hours__c + obj_hours_actionitem.get(obj.id); 
             obj_list_ActionItems.add(obj);     
        }
    }
    else if(Trigger.IsInsert)
    {
        for(ActionItem__c obj:[Select id,Total_Working_Hours__c from ActionItem__c where id=:obj_hours_actionitem.keySet()])
        {
             obj.Total_Working_Hours__c = obj_hours_actionitem.get(obj.id); 
             obj_list_ActionItems.add(obj);     
        }   
    }    
    else if(Trigger.IsDelete)
    {
        for(ActionItem__c obj:[Select id,Total_Working_Hours__c from ActionItem__c where id=:obj_hours_actionitem.keySet()])
        {
             obj.Total_Working_Hours__c = obj_hours_actionitem.get(obj.id); 
             obj_list_ActionItems.add(obj);     
        }   
    }
    if(obj_list_ActionItems.size()>0)
    {
        update obj_list_ActionItems;
    }    
}