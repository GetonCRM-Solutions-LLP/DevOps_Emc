public class RG_AttachmentforContact{
    id conid;
   
   
    public List<Attachment> AttachList{get;set;}
    
    public RG_AttachmentforContact(ApexPages.StandardController stdController){
        AttachList= new List<Attachment>();
        conid= stdController.getId();
         System.debug('conid>>>'+conid);
        if(conid!=null)
        AttachList= [select id, body, name, ContentType, ParentId from Attachment where ParentId=:conid];
        
        else
        if(String.isNotBlank(apexpages.currentpage().getparameters().get('dr')))
        AttachList= [select id, body, name, ContentType, ParentId from Attachment where ParentId=: apexpages.currentpage().getparameters().get('dr')];
       
        
        System.debug('AttachList>>>'+AttachList.size());
        
    
    
    
    }
    
  

}