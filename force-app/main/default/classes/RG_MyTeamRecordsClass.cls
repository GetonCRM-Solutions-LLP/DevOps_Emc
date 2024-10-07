public  class RG_MyTeamRecordsClass {    
    public String rejection                                    {get;set;}
    public list<ConWrapper> cwraplist                          {get;set;}      
    public string Name                                         {get;set;} 
    public Boolean EnableReports                               {get;set;}
    public id manaid                                           {get;set;}
    public boolean isDriver                                    {get;set;}
    public boolean isManager                                   {get;set;}
    public boolean isManagerDriver                             {get;set;}
    public boolean isSuperManager                              {get;set;}
    public boolean isSuperManagerDriver                        {get;set;}
    public boolean imDriver                                    {get;set;}
    public boolean imSuper                                     {get;set;}
    public boolean imSupDr                                     {get;set;}
    public boolean imMan                                       {get;set;}
    public boolean imManDr                                     {get;set;}
    public boolean showTeamRecord;
    public list<Contact> clist;
    public id supid                                            {get;set;}
    public id contid                                           {get;set;}
    public Boolean isDr                                        {get;set;}   
    public Boolean isCurrentMonth                              {get;set;}
    public String message                                      {get;set;}
     public String newmessage  {get;set;}
    
    public RG_MyTeamRecordsClass() {
        isDr = false;
        
        User u = [select ProfileId, ContactId, Contact.AccountId,Contact.Account.Lock_date__c from User where id =: userinfo.getuserid()];
        isCurrentMonth = false;
        /*Date currentDate = System.today();
        isCurrentMonth = dateChecker(currentDate,u.Contact.Account.Lock_date__c);*/
        manaId = ApexPages.currentPage().getParameters().get('man');
        Id dr = ApexPages.currentPage().getParameters().get('dr');
        System.debug('manaId================>'+manaId);
        System.debug('dr================>'+dr);
        cwraplist = new list<ConWrapper>();
        isDriver = false;
        /************* Set User Profile when Logged in Admin ************/
        profile profil;
        Id cur;
        List<User> user;
        if(dr != null) {
            user = new List<User>([SELECT Id, ProfileId, ContactId,Contact.AccountId FROM User WHERE ContactId =: dr]);
            isDr = true;
        }
        if(dr != null && !user.isEmpty()) {
            profil = [select id, Name from profile where id =: user[0].ProfileId];
            cur = user[0].contactid;
        } else {
            profil = [select id, Name from profile where id =: userinfo.getprofileid()];
            cur = [select contactid from user where id =: userinfo.getUserId()].contactid;
        }
        System.debug('cur================>'+cur);
        System.debug('profil================>'+profil);

        /*************************************************************/
        if(cur != null)
            EnableReports = [select Enable_Reports__c from contact where id =: cur].Enable_Reports__c;
        
        if(profil.Name == 'Customer Community Login User - Driver') isDriver = true;
        if(profil.Name == 'Customer Community Login User - Manager') isManager = true;
        if(profil.Name == 'Customer Community Login User - Manager/Driver') isManagerDriver = true;
        if(profil.Name == 'Customer Community Login User - Super Manager') isSuperManager = true;
        if(profil.Name == 'Customer Community Login User - Super Manager/Driver') isSuperManagerDriver = true;
        
        supid = ApexPages.currentPage().getParameters().get('supid');
        if(supid != null) {
            contid = supid;  
            try {
                string pname = [select id, profile.name from user where contactid =: contid].profile.name;
                contact c = [select name, id,showTeamRecord__c from contact where id =: contid];
                showTeamRecord = c.showTeamRecord__c;
                System.debug('showTeamRecord if===========>'+showTeamRecord);
                name = c.name;
                manaid = c.id;
                
                if(pName == 'Customer Community Login User - Driver') {
                    imDriver = true;
                    imManDr = false; 
                    imMan = false;
                    imSuper = false;
                    imSupDr = false;
                }
                if(pName == 'Customer Community Login User - Manager') {
                    imDriver = false;
                    imManDr = false; 
                    imMan = true;
                    imSuper = false;
                    imSupDr = false;
                }
                if(pName == 'Customer Community Login User - Manager/Driver') {
                    imDriver = false;
                    imManDr = true; 
                    imMan = false;
                    imSuper = false;
                    imSupDr = false;
                }
                if(pName == 'Customer Community Login User - Super Manager') {
                    imDriver = false;
                    imManDr = false; 
                    imMan = false;
                    imSuper = true;
                    imSupDr = false;
                }
                if(pName == 'Customer Community Login User - Super Manager/Driver') {
                    imDriver = false;
                    imManDr = false; 
                    imMan = false;
                    imSuper = false;
                    imSupDr = true;
                }
            } catch(exception e) {
            }     
        } else {
            id profileid;
            if(dr != null) {
              u = user[0];
              contid = user[0].ContactId;
              profileid = user[0].ProfileId;
              system.debug('===>contid ' + contid);
              system.debug('===>profileid ' + profileid);
            } else {
              contid = u.contactid;
              System.debug('contid================>'+contid);
              profileid = u.profileid;
            }
            contact c = [select name,showTeamRecord__c from contact where id =: contid];    
            manaid = c.id;
            name = c.name; 
            showTeamRecord = c.showTeamRecord__c;
            System.debug('showTeamRecord else===========>'+showTeamRecord);
        }
        System.debug('showTeamRecord===========>'+showTeamRecord);
        
        
        List<Contact> adminlist = [select Id from Contact where Role__c = 'Admin' AND AccountId =: u.Contact.AccountId];
        System.debug('adminlist===========>'+adminlist);

        if(showTeamRecord == True){
            system.debug('===> adminlist ' + adminlist);
            clist = [select id from Contact where manager__c in :adminlist];
            System.debug('clist===========>'+clist);
        } else {
            clist = [select id from Contact where manager__c =: contid];
        }
        list<Contact> clist2 = [select id from Contact where manager__c in :clist];
        list<Contact> clist3 = [select id from Contact where manager__c in :clist2];
        list<Contact> clist4 = [select id from Contact where manager__c in :clist3];
        clist.addall(clist2);
        clist.addall(clist3);
        clist.addall(clist4);
               
        init();
        
    }

    public void init()
    {   
        set<id> conid = new set<id>();
        for(Contact c : clist) {
            conid.add(c.id);  
        }

        list<Employee_Reimbursement__c> reimbursement = new list< Employee_Reimbursement__c>();
        String temp1 = Date.today().addMonths(-1).month() + '-' + Date.today().addmonths(-1).year();
        String temp2 = Date.today().addMonths(-2).month() + '-' + Date.today().addmonths(-2).year();
        
        string lastmonth = temp1.left(2);
        if(lastmonth.contains('-'))
            lastmonth = '0' + temp1;
        else
            lastmonth = temp1; 
        
        string lastToLastmonth = temp2.left(2);
        if(lastToLastmonth.contains('-'))
            lastToLastmonth = '0' + temp2;
        else
            lastToLastmonth = temp2; 

        reimbursement = [select id,
                         Name,
                         Total_Approved__c,
                         Total_Mileage__c,
                         Status__c,
                         Fuel_Variable_Rate__c,
                         Contact_Id__r.manager__r.Name,
                         contact_Id__r.role__c,
                         Fuel_Price__c,
                         Contact_Id__c,
                         Contact_Id__r.Name,
                         Contact_Id__r.Monthly_Mileage_Limit__c,
                         Approved_Date__c from Employee_Reimbursement__c
                         where Contact_Id__c IN : conid AND (Contact_Id__r.Deactivated_Date__c >=: System.today() OR 
                                                             Contact_Id__r.Deactivated_Date__c = null) 
                                                            and (contact_Id__r.Role__c = 'Driver' OR contact_Id__r.Role__c = 'Driver/Manager') 
                                                            and month__c =: lastmonth order by name limit 999];

        //Commented due to issue after loading previous month data it is still showing last to last month data. 
        if(reimbursement.size() == 0){
            reimbursement = [select id,
                             Name,
                             Total_Approved__c,
                             Total_Mileage__c,
                             Status__c,
                             Fuel_Variable_Rate__c,
                             Contact_Id__r.manager__r.Name,
                             contact_Id__r.role__c,
                             Fuel_Price__c,
                             Contact_Id__c,
                             Contact_Id__r.Name,
                             Contact_Id__r.Monthly_Mileage_Limit__c,
                             Approved_Date__c from Employee_Reimbursement__c
                             where Contact_Id__c IN : conid AND (Contact_Id__r.Deactivated_Date__c >=: System.today() OR 
                                                                 Contact_Id__r.Deactivated_Date__c = null) 
                                                            and contact_Id__r.Role__c = 'Driver' 
                                                            and month__c =: lastToLastmonth order by name limit 999];      
        } 
        cwraplist = new list<ConWrapper>();
        if(reimbursement.size() > 0) {  
            for(Employee_Reimbursement__c empReimb : reimbursement) {    
                cwraplist.add(new ConWrapper(empReimb.Contact_Id__c,
                                             empReimb.Contact_Id__r.Name,
                                             empReimb.Contact_Id__r.Monthly_Mileage_Limit__c,
                                             empReimb.Status__c,
                                             empReimb.Approved_Date__c,
                                             false,
                                             empReimb.Total_Mileage__c,
                                             empReimb.Total_Approved__c,
                                             empReimb));
                
            }
          
        }
    }
    
    list<Employee_Reimbursement__c> templist;
    list<Employee_Mileage__c> tempMileagelist;
    
    public void UpdateRecord() {
        list<Employee_Reimbursement__c> reimblist = new list<Employee_Reimbursement__c>();
        map<id, list<Employee_Mileage__c>> reimbursementIdToListOfEmployeeMileageMap = new map<id, list<Employee_Mileage__c>>();
        list<Contact> conList = new list<Contact>();
        tempMileagelist = new list<Employee_Mileage__c>();
        set<id> reimbursementIdSet = new set<id>();
        for(ConWrapper n: cwraplist) {
            if(n.empReimbb != null)
                reimbursementIdSet.add(n.empReimbb.id);
        }
        for(Employee_Mileage__c mil:[select Trip_Date__c,
                                     id,
                                     Reason_for_Rejection__c,
                                     Approved_Date__c,
                                     EmployeeReimbursement__c, 
                                     Name,
                                     Mileage__c,
                                     Trip_Destination__c,
                                     Trip_Origin__c,
                                     Rejected__c from Employee_Mileage__c where EmployeeReimbursement__c IN : reimbursementIdSet and Approved_Date__c=null and Rejected__c!=true]) {
            list<Employee_Mileage__c> templist = new list<Employee_Mileage__c>();
            if(reimbursementIdToListOfEmployeeMileageMap.containsKey(mil.EmployeeReimbursement__c))
                templist = reimbursementIdToListOfEmployeeMileageMap.get(mil.EmployeeReimbursement__c);
            templist.add(mil);
            reimbursementIdToListOfEmployeeMileageMap.put(mil.EmployeeReimbursement__c,templist);
        } 
        for(ConWrapper n: cwraplist) {
            conList.add(new Contact(id = n.con, 
                                    Monthly_Mileage_Limit__c = n.monthlyMileageLimit));
            if(n.conb == true) {    
                reimblist.add(new Employee_Reimbursement__c(id = n.empReimbb != null ? n.empReimbb.id : null,
                                                            Status__c = 'Approved',
                                                            Approved_Date__c = date.today()));
                if(reimbursementIdToListOfEmployeeMileageMap.containsKey(n.empReimbb.id)) {
                    for(Employee_Mileage__c m : reimbursementIdToListOfEmployeeMileageMap.get(n.empReimbb.id)) {
                        tempMileagelist.add(new Employee_Mileage__c(id = m.id,
                                                                    Rejected__c = false,
                                                                    Trip_Status__c = 'Approved',
                                                                    Approved_Date__c = date.today(),Carry_Forward_Mileage__c =isCurrentMonth) );
                    }
                } 

                n.conb = false;
            }
        }        
       // Savepoint sp = Database.setSavepoint();
        List<sObject> records = new List<sObject>();       
        try{
            //update reimblist;
            //update conList;
            if(!conlist.isEmpty()) {
                //for(Contact c : conList) {
                    records.addAll((List<sObject>)(conList));
                //}
            }
            if(!reimblist.isEmpty()) {
                //for(Employee_Reimbursement__c er : reimblist) {
                    records.addALl((List<sObject>)(reimblist));
                //}
            } 
            if(!tempMileagelist.isEmpty()) {
                //for(Employee_Mileage__c em : tempMileagelist) {
                    records.addAll((List<sObject>)(tempMileagelist));
                //}
            }
            if(!records.isEmpty() && (records.size() > 10000)) {
                processRecords pr = new processRecords(records);
                Database.executeBatch(pr);
            }else if(!records.isEmpty() && (records.size() < 10000)) {
                //update reimblist;
                //update conList;
                //update tempMileagelist;
                update records;
                message = System.Label.Dashboard_Page_Message;
            }else if(records.isEmpty()) {
                message = 'Please Select Record';
            }

            init();
        } catch (Exception e) {
            message = e.getMessage();
            //Database.rollback(sp);
        }
    }
    public void oncompletecall()
    {

    }
    public PageReference pageredirect() {
        if(UserInfo.getUserType() == 'Guest')
            return new PageReference('/apex/RG_CommunitiesLogin'); 
        if(isDriver)
            return new PageReference('/apex/RG_MonthlyReimbursementSummary'); 
        else
            return null; 
    }
    
    public pagereference backMethod() {
        Pagereference pg =  new Pagereference('/apex/RG_Create_New_User_Page?man='+manaId);
        pg.setRedirect(true);
        return pg;
    }

    /*private static Boolean dateChecker (Date currentDateValue, Date accountLockDate) {
      if(currentDateValue >= accountLockDate) {
        if(currentDateValue.month() == accountLockDate.month() && currentDateValue.year() == accountLockDate.year()) {
          return true;
        }else {
          return false;
        }
        
      }else {
        return false;
      }
    }*/

    /*public Pagereference openKnowledge(){
        Pagereference page = new PageReference('/apex/Knowledge_Home');
        page.setRedirect(true);
        return page;
    }*/

    public class ConWrapper {       
        public id con                                        {get;set;}
        public string lastName                               {get;set;}
        public decimal monthlyMileageLimit                   {get;set;}
        public string status                                 {get;set;}
        public date ApprovedDate                             {get;set;}
        public Boolean conb                                  {get;set;}
        public decimal totalmileage                          {get;set;}
        public decimal totalMileageApproved                  {get;set;}
        public Employee_Reimbursement__c empReimbb           {get;set;}
        
        public ConWrapper(id c, string lastName, decimal monthlyMileageLimit, string status, 
                          date ApprovedDate, boolean b, decimal totalmileage, decimal totalMileageApproved,
                          Employee_Reimbursement__c empReimbb) {
                              
        if(c != null)
            this.con = c;
        if(lastName != null) 
            this.lastName = lastName;
        if(monthlyMileageLimit != null)
            this.monthlyMileageLimit = monthlyMileageLimit;
        if(status != null)       
            this.status = status;
        if(ApprovedDate != null)
            this.ApprovedDate = ApprovedDate;
            this.conb = b;
        if(totalmileage != null)
            this.totalmileage = totalmileage;
        if(totalMileageApproved != null)
            this.totalMileageApproved = totalMileageApproved;
        if(empReimbb != null)
            this.empReimbb = empReimbb;
        }
    }
}