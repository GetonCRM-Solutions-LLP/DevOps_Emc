public with sharing class ReportPageClass 
{
    public list<string> soqlfield{get;set;}//This list is use to stroe the field from the basic soql query
    public custom_report__c cr {get;set;}
    public list<sobject> q{get;set;}//This list is use to store the soql query data
    public map<String,string> labelmap{get;set;}//This list is use to show the label on the page
    list<user> user;
    list<user> user1;
    public list<String> selectedManager{get;set;}//This list is use to get the list of selected managers form the page
    public list<string> selectedbv{get;set;}//This list is use to get the list of selected Business Units form the page
    string soql;
    public string sortby{get;set;}
    public string sortfrom{get;set;}
    public Date todate {get;set;}
    public Date fromdate {get;set;}
    list<profile> Managerprofile;
    public boolean showHide{get;set;}
    list<contact> bvlist;//This list is use to store the business units of the contacts 
    public string reportname{get;set;}
    public Boolean isShowButton   {get; set;}
    user currentuser;
    public string renderAsExcel{get;set;}
    public string renderAsdoc{get;set;}
    public Employee_Reimbursement__c fromDateEmpR{get;set;}
    public Employee_Reimbursement__c toDateEmpR{get;set;}
    
    

    //Constructor Begin
    public ReportPageClass()
    {
        try {

            fromdate = Date.Today().addMonths(-1).toStartOfMonth();

            fromDateEmpR = new Employee_Reimbursement__c(Approved_Date__c = fromdate);
            todate = Date.Today().toStartOfMonth().addDays(-1);
            toDateEmpR = new Employee_Reimbursement__c(Approved_Date__c = todate);
            System.debug('fromdate -->' + fromdate);
            System.debug('todate -->' + todate);
            
            Managerprofile=new list<profile>();
            user=new list<user>();
            user1=new list<user>();
            bvlist=new list<contact>();
            selectedbv=new list<string>();
            selectedManager=new list<String>();
            
            currentuser=[select id, Contactid, Contact.AccountId from user where id=:UserInfo.getUserId()];
            //isDelta=currentuser.contact!=null&&currentuser.contact.accountid!=null&&currentuser.contact.accountid=='0014C00000B7zPK'?true:false;
            managerprofile=[select id from profile where name='Customer Community Login User - Manager' or name='Customer Community Login User - Manager/Driver'];
            user=[SELECT Id, contactid,FirstName,LastName FROM User WHERE (profileid=:Managerprofile[0].id OR profileid=:Managerprofile[1].id) And contact.accountid=:currentuser.contact.accountid AND IsActive=true];
            //user1=[SELECT Id, contactid,FirstName,LastName FROM User WHERE (profileid=:Managerprofile[0].id OR profileid=:Managerprofile[1].id) And Email LIKE:'%valetWaste.com'];
            system.debug('list of users------>>'+user.size());
            //system.debug('list of users------>>'+user1.size());
            bvlist=[select Business_Unit__c from contact];
            soqlfield=new list<string>();
            q=new list<sobject>(); 
            labelmap=new map<String,string>(); 
            
            //Query on the custom report object to get the soql query.
            cr = [select Name,Report_Soql__c,Sort_By__c,Sort_From__c,Show_Lock_Date__c from custom_report__c WHERE id =: ApexPages.currentPage().getParameters().get('id') limit 1];
            reportname=cr.Name;
            isShowButton = cr.Show_Lock_Date__c;
            sortby=cr.Sort_By__c;
            sortfrom=cr.Sort_From__c;
            system.debug('order by--------'+sortby);
            system.debug('order from--------'+sortfrom);
            if(cr!=null)
            {
                soql=cr.Report_Soql__c;
                string soqlstring=soql.remove('select');
                
                //remove all the words after from in the string.
                String regex = '(?<=from)(?s)(.*$)';
                soqlstring=soqlstring.replaceAll(regex,'');
                
                soqlstring=soqlstring.removeend('from');
                system.debug('selectedfieldsss--->>'+soqlstring);
                
                //split the string and all the values in the list of soqlfield.
                for(String temps :soqlstring.split(','))
                {
                    soqlfield.add(temps.trim());
                }
                system.debug('list of selected fieldsssss-->>'+soqlfield[0]);
                system.debug('soql query-=----->>'+soql);
                
                //put the value in the map for showning label
                for(string s:soqlfield)
                {           
                    system.debug('value of ssss--->>'+s);   
                    string s1=s.remove('__r');
                    s1=s1.remove('__c');
                    s1=s1.replace('Code_Variable','Code');
                    s1=s1.replace('Code_Fixed','Code');
                    s1=s1.replace('_ID_Fixed',' ID');
                    s1=s1.replace('_Variable_ID',' ID');
                    s1=s1.replace('_Id',' ');
                    s1=s1.replace('_',' ');
                    s1=s1.replace('.',' ');
                    s1=s1.remove('Contact');
                    s1=s1.remove('External');
                    //s1=s1.remove('Total');
                    labelmap.put(s,s1);
                }
                
                system.debug('test class soqwll--->>'+soql);
            
                //q=Database.query(soql+' order BY CreatedDate DESC');
                if(soql.contains('from contact'))
                {   dateTime date1 = dateTime.now().addMonths(-1);
                    id accid=currentuser.contact.accountid;
                    string driver='Driver';
                    string Manager='Driver/Manager';
                    q=Database.query(soql+' where accountid=:accid and (role__c=:Driver or role__c=:Manager) limit 999');       
                }
                else if(soql.contains('from Employee_Reimbursement__c'))
                {   dateTime date1 = dateTime.now().addMonths(-1);
                    id emprimid=currentuser.contact.accountid;
                    string driver='Driver';
                    string Manager='Driver/Manager';
                    q=Database.query(soql+' where Contact_Id__r.accountid=:emprimid and ( Contact_Id__r.Deactivated_Date__c>=:date1 or Contact_Id__r.Deactivated_Date__c=null) and (Contact_Id__r.role__c=:Driver or Contact_Id__r.role__c=:Manager) limit 999');
                    system.debug('Limits.getQueries(): '+Limits.getQueries());
                    system.debug('Limits.getQueryRows(): '+Limits.getQueryRows());
                }
                else if(soql.contains('from Employee_Mileage__c'))
                {   dateTime date1 = dateTime.now().addMonths(-1);
                    id empmileageid=currentuser.contact.accountid;
                    string driver='Driver';
                    string Manager='Driver/Manager';
                    q=Database.query(soql+' where EmployeeReimbursement__r.Contact_Id__r.accountid=:empmileageid and (EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c>=:date1 or EmployeeReimbursement__r.Contact_Id__r.Deactivated_Date__c=null) and (EmployeeReimbursement__r.Contact_Id__r.role__c=Driver or EmployeeReimbursement__r.Contact_Id__r.role__c=Manager) limit 999');
                
                }
                //q=Database.query(soql);
            }
            run();
        } catch(exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            //System.debug('===>'+e.getStackTraceString());
            //ApexPages.addMessage(e);
            //apexpages.addmessages(e);
        }
    }

    //pdf generate
    public PageReference SaveAspdf() {
        
        renderAsdoc='pdf';
        renderAsExcel = '';
        //setup a default file name
        string fileName = '' + reportname + '_' + date.today() +'.pdf';
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachemnt; filename='+fileName);
        return null;
    }

    //Save as Excel
    public PageReference SaveAsExcel() {
        renderAsdoc= '';
        renderAsExcel='application/vnd.ms-excel#' + reportname + '_' + date.today()  + '.xls';
        return null;
    }

    //Manager picklist   
    public List<SelectOption> getManagerNames() 
    {
      
      List<SelectOption> ManagerOptions = new List<SelectOption>();
      ManagerOptions.add(new SelectOption('','-None-'));
      for(user s:user)
      {
            //check contact id on user record, if contact id exist then insert in selectoption otherwise not
            if(s.contactid!=null)
            {
                ManagerOptions.add(new SelectOption(s.contactid,s.FirstName+' '+s.LastName));
            }
      }
      return ManagerOptions;
    }
      //Business unit picklist
      public List<SelectOption> getBusinessunit()
      {
          List<SelectOption> BVOptions = new List<SelectOption>();
          BVOptions.add(new SelectOption('','-None-'));
          for(Contact s:bvlist)
          {
            if(s.Business_Unit__c!=null)
            {
                BVOptions.add(new SelectOption(s.Business_Unit__c,s.Business_Unit__c));
            }
          }
            return BVOptions;
      }
   
   //This method is use to modifed the soql suery according to the filters and run that query
    public void run()
    {
        try {
            string modifiedsoql='';
            system.debug('list of manager--->>'+selectedManager);
            //list<user> userdetail=[select Name from user where id IN:selectedManager];
            //system.debug('user details---->>'+userdetail);
            list<contact> contactlist = new list<Contact>();
            if(!selectedManager.isEmpty())
            {
                contactlist=[select id from contact where Manager__r.id IN:selectedManager  or Id IN :selectedManager];
            }
            list<Date> finaldatestring = new list<Date>();
            system.debug('list of contact---->>>'+contactlist);
            //Manager query
            if(soql.contains('from contact'))
            {               
                boolean andfilter = false;
                if(!soql.contains(' where '))
                {
                    modifiedsoql=soql+' where ';
                }
                else
                {
                    modifiedsoql=soql;
                    andfilter = true;
                }
                
                if(!contactlist.isEmpty())
                {
                    if(andfilter)
                    modifiedsoql+=' And ';
                    andfilter = true;
                    modifiedsoql+=' Manager__c IN :contactlist ';
                }
                if(selectedbv.size()>0)
                {
                    if(andfilter)
                    modifiedsoql+=' And ';
                    modifiedsoql+=' Business_Unit__c IN :selectedbv AND';
                    andfilter = true;
                }
                
                if( toDateEmpR.Approved_Date__c == null)
                {
                    toDateEmpR.Approved_Date__c = date.today();
                }
                
                finaldatestring = new list<Date>();
                
                system.debug('value of from date--->>'+fromdate);
                if(fromDateEmpR!=null)
                {
                    /*if(andfilter)
                    modifiedsoql+=' And ';
                    modifiedsoql+=' Activation_Date__c >=: fromdate and Activation_Date__c<: todate';*/
                }
            } 
            else
            {
                system.debug('inside reimbursement--->>>');
                boolean andfilter = false;
                if(!soql.contains(' where '))
                {
                    modifiedsoql=soql+' where ';
                }
                else
                {
                    modifiedsoql=soql;
                    andfilter = true;
                }
                
                if(!contactlist.isEmpty())
                {
                    if(andfilter)
                    modifiedsoql+=' And ';
                    andfilter = true;
                    modifiedsoql+=' Contact_Id__c IN :contactlist ';
                }
                if(selectedbv.size()>0)
                {
                    if(andfilter)
                    modifiedsoql+=' And ';
                    modifiedsoql+=' contact_Id__r.Business_Unit__c IN :selectedbv';
                    andfilter = true;
                }
                if( toDateEmpR.Approved_Date__c ==null)
                {
                    toDateEmpR.Approved_Date__c = date.today();
                }
                list<String> finaldatestring1 = new list<String>();
                for(Date i = fromDateEmpR.Approved_Date__c ; i <= toDateEmpR.Approved_Date__c;)
                {   integer mon = integer.valueOf(i.month());
                        String dtformat='';
                         if(mon<10)               
                         dtformat= '0'+i.month()+'-'+i.year();
                         else
                         dtformat= i.month()+'-'+i.year();
                        System.debug('dtformat==> '+dtformat);
                        
                //  String dtformat = i.month()+'-'+i.year();
                    //dtformat = dtformat.removeStart('0');
                    finaldatestring1.add(dtformat);              
                    i=i.addmonths(1);
                }
                    system.debug(finaldatestring1);
                    if(fromDateEmpR.Approved_Date__c !=null)
                    {
                        if(andfilter)
                        modifiedsoql+=' And ';
                        modifiedsoql+=' Month__c IN : finaldatestring1 ';
                    }   
                    
                }
            system.debug('value of bffff---->>'+selectedbv);
            system.debug('date soql---->>>'+modifiedsoql);
            //selectedbv.clear();
            //modifiedsoql+=' order BY CreatedDate DESC';
            system.debug('Limits.getQueries(): '+Limits.getQueries());
            system.debug('Limits.getQueryRows(): '+Limits.getQueryRows());
            if(modifiedsoql.contains('from contact'))
            {   
                Time myTime = Time.newInstance(3, 3, 3, 0);
                DateTime fromdate2 = DateTime.newInstance( fromDateEmpR.Approved_Date__c , myTime);
                System.debug('fromdate2==> '+fromdate2);
                id accid = currentuser.contact.accountid;
                string driver='Driver';
                string Manager='Driver/Manager';
                q = Database.query(modifiedsoql+' And accountid=:accid and (role__c=:Driver or role__c=:Manager) limit 999');
            }
            else if(soql.contains('from Employee_Reimbursement__c'))
            {   
                Time myTime = Time.newInstance(3, 3, 3, 0);
                DateTime fromdate2 = DateTime.newInstance(fromDateEmpR.Approved_Date__c , myTime);
                System.debug('fromdate2==> '+fromdate2);
                id emprimid = currentuser.contact.accountid;
                string driver='Driver';
                string Manager='Driver/Manager';
                
                q = Database.query(modifiedsoql+' AND Contact_Id__r.accountid=:emprimid and ( contact_Id__r.Deactivated_Date__c>=:fromdate2 or contact_Id__r.Deactivated_Date__c=null ) and (contact_Id__r.role__c=:Driver or contact_Id__r.role__c=:Manager) limit 999');//
                //system.debug('===>Query Size modifiedsoql'+modifiedsoql.size());
                system.debug('===>Query Size'+q.size());
                system.debug('Limits.getQueries(): '+Limits.getQueries());
                system.debug('Limits.getQueryRows(): '+Limits.getQueryRows());
            }
            else if(soql.contains('from Employee_Mileage__c'))
            {    
                Time myTime = Time.newInstance(3, 3, 3, 0);
                DateTime fromdate2 = DateTime.newInstance(fromDateEmpR.Approved_Date__c , myTime);
                System.debug('fromdate2==> '+fromdate2);
                id empmileageid=currentuser.contact.accountid;
                string driver='Driver';
                string Manager='Driver/Manager';
                q = Database.query(modifiedsoql+' AND EmployeeReimbursement__r.Contact_Id__r.accountid=:empmileageid and ( EmployeeReimbursement__r.contact_Id__r.Deactivated_Date__c>=:fromdate2 or EmployeeReimbursement__r.contact_Id__r.Deactivated_Date__c=null ) and (EmployeeReimbursement__r.contact_Id__r.role__c=:Driver or EmployeeReimbursement__r.contact_Id__r.role__c=:Manager) limit 999');
            }
            
        } catch (exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
    
    public PageReference home()
    {       
        PageReference redirect = new PageReference('/apex/RG_DashboardAdmin1');
        redirect.setRedirect(true);
        return redirect;    
    }
    public PageReference back()
    {       
        PageReference pageBack = new PageReference('/apex/Comm/RG_Reports_List_Page');
        pageBack.setRedirect(true); 
        return pageBack;    
    }

    public void updateAccount() {
        Account singleAccount = new Account();
        singleAccount.Id = currentuser.Contact.AccountId;
        singleAccount.Lock_date__c = System.today();
        try {
            update singleAccount;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,System.Label.Report_Lock_Date_Message));
        } catch(DmlException e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
    }
}