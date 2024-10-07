/**
@author Natavar Ghodasara
@date 26th Feb 2019
@group Wrapper
@group-content WrapperDetails.html
@description ExecuteQueryUtil is used to Execute Query in sObject. 
*/
public with sharing class ExecuteQueryUtil 
{
    /**
    @author Natavar Ghodasara
    @date 26th Feb 2019
    @description Default Constructor.
    */
    public ExecuteQueryUtil() 
    {
        
    }   
    /**
    @author Natavar Ghodasara
    @date 22nd Jan 2019
    @description getIDListFromsObject is used to Retrive Id's List from sObject.
    @param Query Query which you want to fire. 
    @return List of id which is retrived from query fired.  
    */
    public static List<String> getIDListFromsObject(String query)
    {

        if(query!=null && query !='')
        {
            List<String> obj_idlist = new list<String>();
            for(sObject s:Database.query(query))
            {
                obj_idlist.add(s.id);
            }
            return obj_idlist;
        }
        else
        {
            return null;
        }
    }
    /**
    @author Natavar Ghodasara
    @date 22nd Jan 2019
    @description getRecordListFromsObject is used to retrive List from sObject.
    @param Query Query which you want to fire. 
    @return List of sObject which is retrived from query fired.  
    */
    public static List<sObject> getRecordListFromsObject(String query)
    {

        if(query!=null && query !='')
        {
            return Database.query(query);
        }
        else
        {
            return null;
        }
    }
    /**
    @author Natavar Ghodasara
    @date 22nd Jan 2019
    @description getListFromMap is used to retrive List from map passed in parameter.
    @param obj_map_sobject obj_map_sobject of sObject Map. 
    @return List of sObject which is retrived by Map.  
    */ 
    public static List<sObject> getListFromMap(Map<id,sObject> obj_map_sobject)
    {
        List<sObject> obj_list_sobject = new List<sObject>();
        for(sObject obj_sObject:obj_map_sobject.values())
        {
            obj_list_sobject.add(obj_sObject);
        }
        return obj_list_sobject;
    }
    /**
    @author Natavar Ghodasara
    @date 22nd Jan 2019
    @description getRecordMapWithSinglesObject is used to retrive Map.
    @param query query is fired. 
    @return Map of sObject which is retrived by Query fired.  
    */ 
    public static Map<id,sObject> getRecordMapWithSinglesObject(String query)
    {
        Map<id,sObject> obj_map_sobject = new Map<id,sObject>();
        for(sObject obj_sObject:getRecordListFromsObject(query))
        {
            obj_map_sobject.put(obj_sObject.id,obj_sObject);
        }
        return obj_map_sobject;
    }
    /**
    @author Natavar Ghodasara
    @date 22nd Jan 2019
    @description getRecordMapWithMultiplesObject is used to retrive Map with ID and .
    @param query query is fired. 
    @return Map of sObject which is retrived by Query fired.  
    */ 
    public static Map<id,List<sObject>> getRecordMapWithMultiplesObject(String query)
    {
        Map<id,List<sObject>> obj_map_sobject = new Map<id,List<sObject>>();
        for(sObject obj_sObject:getRecordListFromsObject(query))
        {
            if(obj_map_sobject.containsKey(obj_sObject.id))
            {
                List<sObject> obj_sobject_list = new List<sObject>();
                obj_sobject_list = obj_map_sobject.get(obj_sObject.id);
                obj_sobject_list.add(obj_sObject);
                obj_map_sobject.put(obj_sObject.id,obj_sobject_list);
            }
            else
            {
                List<sObject> obj_sobject_list = new List<sObject>();
                obj_sobject_list.add(obj_sObject);
                obj_map_sobject.put(obj_sObject.id,obj_sobject_list);
            }
            
        }
        return obj_map_sobject;
    }
}