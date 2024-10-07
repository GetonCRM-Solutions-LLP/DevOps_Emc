public  class RG_Reports_List_Page_Class {
    
     public list<EditClass> reportlist{get;set;}
    public boolean enable{get;set;}
    
    public RG_Reports_List_Page_Class(){
      
    list<Report_Accessibility__c> customReportLIst = new list<Report_Accessibility__c>();
    reportlist= new list<EditClass>();
    user u = [select profile.name,contactid from user where id=:userinfo.getUserid()]; 
    contact c = new contact();
 
   
   customReportLIst = [select Custom_Report__r.ownerid,Custom_Report__r.Name,Custom_Report__c from Report_Accessibility__c where user__c=:userinfo.getUserId()];//apexPages.currentPage().getParameters().get('id')
    if(u.profile.name=='System Administrator'||u.profile.name=='Customer Community Login User - Super Manager'||u.profile.name=='Customer Community Login User - Super Manager/Driver')
    enable=true;
    
    
    if(u.profile.name=='System Administrator')
    {
    for(Report_Accessibility__c r: customReportLIst){
    reportlist.add(new EditClass(r,true));
    }
    }
    else {
    
    for(Report_Accessibility__c r: customReportLIst){
    reportlist.add(new EditClass(r,r.Custom_Report__r.ownerid==userinfo.getUserid()));
    }
    
    }
    
    }
    
    public pageReference goHome(){
        return new PageReference('/apex/RG_DashboardAdmin1');
    }
    
    public class EditClass{
        public boolean enable{get;set;}
        public Report_Accessibility__c access{get;set;}
        
        public EditClass(Report_Accessibility__c access,boolean enable){
            this.enable=enable;
            this.access=access;
        
        }
    
    }
}