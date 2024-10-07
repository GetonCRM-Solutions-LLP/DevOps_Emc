public without sharing class RG_MyMonthlyReimbursment {
    
    List<Employee_Reimbursement__c> ERlist;
    public List<ReimbursementWrapper> wlist   {get; set;}            
    public boolean isDriver                   {get; set;}
    public boolean isOdometer                 {get; set;}
    public boolean me                         {get; set;}
    public boolean EnableReports              {get; set;}
    public boolean manager                    {get; set;}
    public boolean log                        {get; set;}
    public boolean isSuperManager             {get; set;}
    public boolean isManagerDriver            {get; set;}
    public boolean isSuperManagerDriver       {get; set;}
    public boolean isManager                  {get; set;}
    public boolean imDriver                   {get; set;}
    public boolean imSuper                    {get; set;}
    public boolean imSupDr                    {get; set;}
    public boolean imMan                      {get; set;}
    public boolean imManDr                    {get; set;}
    public contact con                        {get; set;}
    public id supid                           {get; set;}
    public id conid                           {get; set;}
    public id dr                              {get; set;}
    public id man                             {get; set;}
    public id cid                             {get; set;}
    public id cd                              {get; set;}
    public list<userwrap> userlist            {get; set;}
    public string conman                      {get; set;}
    public boolean displayPopup               {get; set;}
    public boolean displayPopup1               {get; set;}
    public Blob fileUpload          {get; set;}
    public String fileUploadName              {get; set;}
    public set<String> yearList               {get; set;}
    public String lastYear                    {get; set;}
    public String previousMonthRecord         {get; set;}
    public Date dueDate                       {get; set;}
    public String showPopUpMessage            {get; set;}
    public Boolean isEditable                 {get; set;}
    public Boolean isMVRCheck                 {get; set;}
    public String obj_status {get;set;}
    public String obj_category {get;set;}
    public Decimal totalmileages  {get;set;}
    public String currentuserurl {get;set;}
    public boolean Delta {get;set;}
    //For Driver Status Panel - Variable
    //-------Start ------------//
    
    public String manid{get; set;}
    public String drid{get; set;}   
    
    public id cur{get;set;}
    public String pname {get;set;}
    //------Finish----------------//

   
    public Attachment myattachment {
      get {
          if (myattachment == null)
            myattachment = new Attachment();
          return myattachment;
        }
      set;
      }

    public RG_MyMonthlyReimbursment() {
        Delta = false;
        ERlist = new list<Employee_Reimbursement__c>();
        wlist = new list<ReimbursementWrapper>();
        yearList = new Set<string>();
        lastYear = '';
        //Display Odometer tab
        isOdometer = false;
        if(Date.Today().day() == 2 && Date.Today().month() == 1) {
            isOdometer = true;
        }
        //displayPopUp = true;
        conid = ApexPages.currentPage().getParameters().get('id');
        supid = ApexPages.currentPage().getParameters().get('supid');
        cid = ApexPages.currentPage().getParameters().get('cid');
        cd = ApexPages.currentPage().getParameters().get('cd');
        man = ApexPages.currentPage().getParameters().get('man');
        dr = ApexPages.currentPage().getParameters().get('dr');
        profile profil;
        List<User> user;
       
        /*if(dr != null) {
            user = new List<User>([SELECT Id, ProfileId, ContactId FROM User WHERE ContactId =: dr]);
        }
        if(dr != null && !user.isEmpty()) {
            profil = [select id, Name from profile where Id =: user[0].ProfileId];
            cur = user[0].contactid;
        } else {*/
            profil = [select id, Name from profile where Id=:userinfo.getprofileid()];
            user u1 = [select contactid,contact.account.Name from user where Id =: userinfo.getUserId()]; 
            cur = u1.contactid;
            if(u1.contact.account!=null) {
                if(u1.contact.account.name=='Delta')
                {
                   Delta = true;
                }
            }
            if(ApexPages.currentPage().getParameters().containsKey('dr'))
            {
                currentuserurl = System.Label.communityurl+'adminStatus?manid=none&drid='+ApexPages.currentPage().getParameters().get('dr'); 
            }
            else
            {
                currentuserurl = System.Label.communityurl+'adminStatus?manid=none&drid='+cur; 
            }
            
        /*}*/
        if(profil.Name == 'Customer Community Login User - Driver') isDriver = true;
        if(profil.Name == 'Customer Community Login User - Manager') isManager = true;
        if(profil.Name == 'Customer Community Login User - Manager/Driver') isManagerDriver = true;
        if(profil.Name == 'Customer Community Login User - Super Manager') isSuperManager = true;
        if(profil.Name == 'Customer Community Login User - Super Manager/Driver') isSuperManagerDriver = true;
        log = ApexPages.CurrentPage().getParameters().get('l')=='xyz'?true:false;
        string getid = RG_UnApprovedRecordsClass.getcurrentUserCompanyId();
        userlist = new list<userwrap>();

        for(user u:[select id, 
                     name, 
                     contactid, 
                     contact.Name, 
                     contact.Phone, 
                     contact.Email, 
                     contact.external_email__c from User where contact.Deactivated_Date__c =: null AND (contact.Role__c = 'Manager' OR contact.Role__c = 'Driver/Manager') and (profile.Name=:'Customer Community Login User - Manager' OR profile.Name=:'Customer Community Login User - Manager/Driver') and user.contact.accountid=:getid])
            userlist.add(new userwrap(u.contact.name, u.contact.external_email__c, u.contact.phone, u.contactid));
        if(cur != null)
        EnableReports = [select Enable_Reports__c from contact where id=: cur].Enable_Reports__c;
        System.debug('===>conid ' + conid);
        if(conid != null) {
            System.debug('===>IF Start Conid ' + conid);
            con = [select id,account.Motor_Vehicle_Record_Check_Document__c,accountid,
                        account.Logo_Document_Id__c, 
                        account.Show_Hide_Historical_Allowance__c, 
                        Vehicle_Type__c, 
                        Car_Image__c,
                        Manager__c, 
                        Manager__r.Name, 
                        Monthly_Fuel_Price__c, 
                        Name,
                        Email,
                        LastName,
                        Deactivated_Date__c,
                        Role__c,
                        Employee_ID__c,
                        Driving_States__c,
                        MailingStreet, 
                        MailingState, 
                        MailingCity, 
                        MailingCountry, 
                        MailingPostalCode, 
                        MPG__c, 
                        Vehicle1Odometer__c, 
                        Maintenance_and_Tires__c, 
                        compliancestatus__c, 
                        Vehicle2Odometer__c, 
                        Pre_Auto_Allowance_Amount__c, 
                        Fixed_Amount__c,
                        FirstName,
                        External_Email__c, 
                          (select id, 
                                  Field__c, 
                                  NewValue__c, 
                                  OldValue__c, 
                                  Timestamp__c, 
                                  Modifiedby__c from Audit_Trail__r order by Timestamp__c DESC ) from contact where id =:conid limit 1];
            me = true;
            manager = true;
            pname = [select id, profile.name from user where contactid=:conid].profile.name;
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
        } else if(man != null) {    
            string pname = [select id, profile.name from user where contactid=:man].profile.name;
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
              imSuper = false; imSupDr = false;
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
              imSuper = false; imSupDr = true;
            }
            manager = true;   
            conman = [select name from contact where id=:man].name;
            con = [select id,accountid,
                        Vehicle_Type__c, 
                        account.Show_Hide_Historical_Allowance__c, 
                        account.Logo_Document_Id__c, 
                        Car_Image__c, 
                        Manager__c,
                        Email,
                        Manager__r.Name, 
                        Monthly_Fuel_Price__c, 
                        Name,
                        LastName,
                        Deactivated_Date__c,
                        Role__c,
                        Employee_ID__c,
                        Driving_States__c,
                        MailingStreet, 
                        MailingState, 
                        MailingCity, 
                        MailingCountry, 
                        MailingPostalCode, 
                        MPG__c, 
                        Vehicle1Odometer__c, 
                        Maintenance_and_Tires__c, 
                        compliancestatus__c, 
                        Vehicle2Odometer__c, 
                        Pre_Auto_Allowance_Amount__c, 
                        Fixed_Amount__c,
                        FirstName,
                        External_Email__c,
                          (select id, 
                                  Field__c, 
                                  NewValue__c, 
                                  OldValue__c, 
                                  Timestamp__c, 
                                  Modifiedby__c from Audit_Trail__r order by Timestamp__c DESC ) from contact where id =:dr limit 1];
        } else {
            con = [select id,accountid, 
                        account.Motor_Vehicle_Record_Check_Document__c, 
                        Vehicle_Type__c, 
                        account.Show_Hide_Historical_Allowance__c, 
                        account.Logo_Document_Id__c, 
                        Car_Image__c, 
                        Manager__c,
                        Email,
                        Manager__r.Name, 
                        Monthly_Fuel_Price__c, 
                        Name,
                        LastName,
                        Deactivated_Date__c,
                        Role__c,
                        Employee_ID__c,
                        Driving_States__c,
                        MailingStreet, 
                        MailingCity, 
                        MailingState, 
                        MailingCountry, 
                        MailingPostalCode, 
                        MPG__c, 
                        Vehicle1Odometer__c, 
                        Maintenance_and_Tires__c, 
                        Compliancestatus__c, 
                        Vehicle2Odometer__c, 
                        Pre_Auto_Allowance_Amount__c, 
                        Fixed_Amount__c,
                        FirstName,
                        External_Email__c,
                        Odometer_Editable__c,
                        (select id, 
                                Field__c, 
                                NewValue__c, 
                                OldValue__c, 
                                Timestamp__c, 
                                Modifiedby__c from Audit_Trail__r order by Timestamp__c DESC ) from contact where id =:[select contactid from User where id=:userinfo.getuserid()].contactid limit 1];
            System.debug('in else. con: '+con);
            isEditable = con.Odometer_Editable__c;
            //Display MVR Check button
            isMVRCheck = false;
            System.debug('===>isMVRCheck ' + isMVRCheck);
            System.debug('===>Motor_Vehicle_Record_Check_Document__c == true ' + con.account.Motor_Vehicle_Record_Check_Document__c);
            if(con.account.Motor_Vehicle_Record_Check_Document__c == true) {
                isMVRCheck = true;
            }
            me = false;
            manager = log?false:true;
            imsuper = false;
            }
            Integer totalmonths = Integer.valueof(System.Label.Last_N_Month_Mileages);
  
        list<Gas_Prices__c> gasprice = [select id, 
                                             Fuel_Price__c, 
                                             Month_Year__c, 
                                             State__c, 
                                             City__c from Gas_Prices__c where State__c=:con.MailingState AND City__c=:con.MailingCity ];
        ERlist = [select Variable_Rate__c,
                       Balance__c,
                       Contact_id__r.Accountid, 
                       Monthly_Total_Reimbursement__c, 
                       Total_Monthly_Reimbursement__c, 
                       Total_Monthly_Variable__c, 
                       Total_Monthly_Approved_Variable__c, 
                       Fixed_Amount__c, 
                       Monthly_Variable_Amount__c, 
                       id, 
                       Month__c, 
                       Approved_Date__c, 
                       Status__c, 
                       LastModifiedDate, 
                       Contact_Id__r.MPG__c, 
                       Contact_Id__r.Fixed_Amount__c, 
                       Contact_Id__r.Maintenance_and_Tires__c, 
                       Fuel_Variable_Rate__c, 
                       MPG__c, 
                       Fuel_Price__c, 
                       Monthly_Mileage__c, 
                       Name, 
                       Maintenance_and_Tires__c, 
                       Contact_Id__r.id,
                        (select Trip_Date__c, 
                                id, 
                                Rejected__c, 
                                Fuel_price__c, 
                                Variable__c, 
                                Maintenance_and_Tires__c, 
                                MPG__c, 
                                Approved_Date__c,
                                Trip_Status__c, 
                                Mileage__c, 
                                Trip_Destination__c, 
                                Trip_Origin__c, 
                                EmployeeReimbursement__r.Approved_Date__c,
                                EmployeeReimbursement__r.Status__c,
                                EmployeeReimbursement__r.Fuel_Variable_Rate__c, 
                                CreatedDate, 
                                Reason_for_Rejection__c from Employees_Mileage__r where (Rejected__c=false OR Rejected__c=null) order by Trip_Date__c Desc) 
                from Employee_Reimbursement__c where Contact_Id__c=:con.Id AND Month_Field__c = LAST_N_MONTHS:6 ORDER BY Month_Field__c DESC];  //AND Month_Field__c = LAST_N_MONTHS:6   
         //   ERlist=Database.Query('select Variable_Rate__c,Balance__c,Contact_id__r.Accountid,Monthly_Total_Reimbursement__c,Total_Monthly_Reimbursement__c,Total_Monthly_Variable__c,Total_Monthly_Approved_Variable__c,Fixed_Amount__c,Monthly_Variable_Amount__c,id,Month__c,Approved_Date__c,Status__c,LastModifiedDate,Contact_Id__r.MPG__c,Contact_Id__r.Fixed_Amount__c,Contact_Id__r.Maintenance_and_Tires__c,Fuel_Variable_Rate__c,MPG__c,Fuel_Price__c,Monthly_Mileage__c,Name,Maintenance_and_Tires__c,Contact_Id__r.id,(select Trip_Date__c,id,Rejected__c,Fuel_price__c,Variable__c,Maintenance_and_Tires__c,MPG__c,Approved_Date__c,Trip_Status__c,Mileage__c,Trip_Destination__c,Trip_Origin__c,EmployeeReimbursement__r.Approved_Date__c,EmployeeReimbursement__r.Status__c,EmployeeReimbursement__r.Fuel_Variable_Rate__c,CreatedDate,Reason_for_Rejection__c from Employees_Mileage__r where (Rejected__c=false OR Rejected__c=null) order by Trip_Date__c Desc) from Employee_Reimbursement__c where Contact_Id__c='/''+con.Id+'/'+'AND Month_Field__c = LAST_N_MONTHS:'+totalmonths+'ORDER BY Month_Field__c DESC');  
        string month = '';
        string year = '';
        System.debug('===> ERlist Size ' + ERlist.size());
        System.debug('===> ERlist ' + ERlist);
        for(Employee_Reimbursement__c em : ERlist) {             
            System.debug('===> em.Month__c ' + em.Month__c);
            if(em.Month__c != null) {
                month = em.Month__c.left(2);
                year = em.Month__c.right(4);
            }
            System.debug('===> month ' + month);
            System.debug('===> year ' + year);
            String LastMonthYear = String.valueof(date.today().addmonths(-1).year());
            if(LastMonthYear == year ||(((String.valueof(date.today().year()-1))==year) && month=='12')) {
              string m = (month=='1-')?'January':
                                      (month=='2-')?'February':
                                      (month=='3-')?'March':
                                      (month=='4-')?'April':
                                      (month=='5-')?'May':
                                      (month=='6-')?'June':
                                      (month=='7-')?'July':
                                      (month=='8-')?'August':
                                      (month=='9-')?'September':
                                      (month=='01')?'January':
                                      (month=='02')?'February':
                                      (month=='03')?'March':
                                      (month=='04')?'April':
                                      (month=='05')?'May':
                                      (month=='06')?'June':
                                      (month=='07')?'July':
                                      (month=='08')?'August':
                                      (month=='09')?'September':
                                      (month=='10')?'October':
                                      (month=='11')?'November':
                                      (month=='12')?'December':
                                      'Invalid Month';        
              string y = year!=''?year:'Invalid year';
            
              /*if(m == 'December') {
                  y = String.valueOf(Integer.valueOf(y) + 1);
              }*/
              yearList.add(y);  
              /*if((((String.valueof(date.today().year()-1))==year) && month=='12'))
              {
                m = 'December';
                y=String.valueOf((Integer.valueOf(year)+1));
              }
              else
              {
                yearList.add(y);  
              }*/
              
              wlist.add(new ReimbursementWrapper(Em, m, y, Em.Employees_Mileage__r, false, con, gasprice));
            }
            month = ''; 
            year = '';
        }
            if(!wlist.isEmpty()){
              previousMonthRecord = wlist[0].month+'-'+wlist[0].year;
            }else {
              previousMonthRecord = '';
            }
         
        if(yearList.size() > 0)
            lastYear = (new list<string>(yearList) )[0];


       
    }  

    public PageReference closePopup() {        
        displayPopup = false; 
        return new PageReference(ApexPages.currentPage().getUrl()).setRedirect(true);
    }
    public PageReference closePopup1() {        
        displayPopup1 = false; 
        return new PageReference(ApexPages.currentPage().getUrl()).setRedirect(true);
    }
    
    public void showPopup() {        
        displayPopup = true;    
    }
    public void showPopup1() {        
        displayPopup1 = true; 
        displayPopup=false;   
    }
    
    public pagereference savecontact()
    {
      
       try{
         upsert con;
         PageReference nextpage= new PageReference('/'+con.id);
           return nextpage;
      }
      catch(Exception e){
           String message='Data Base error during saving...';
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, message));
            return null;
        }
    }
    
   public PageReference refreshPage()
   {

      return  new PageReference(ApexPages.currentPage().getUrl()).setRedirect(true);
   }
    public PageReference savePDF() {   
        System.debug('fileUpload: ');
        Attachment attach = new Attachment();
        attach.ParentId = con.id;
        System.debug('fileUpload: '+fileUpload);
       // Blob body = Blob.valueOf('Some Text');
        attach.Body = fileUpload;
        attach.Name = fileUploadName;
        System.debug('attach :- '+attach);
        
        if (attach != NULL) {
                   try {
                insert attach;
                sendConfirmationEmail();
            } catch(Exception e) {
                con.addError(e.getMessage());
                return NULL;
            }
        }
        return  new PageReference(ApexPages.currentPage().getUrl()).setRedirect(true);
    }
   /* public String getdocusignrecords(String Accuontid,String contactemail)
    {
      List<dsfs__DocuSign_Status__c> obj_dsfs__DocuSign_Status =  [Select id,dsfs__Company__c,dsfs__Sender_Email__c,dsfs__Envelope_Status__c from dsfs__DocuSign_Status__c where dsfs__Company__c =:Accuontid AND dsfs__Sender_Email__c = '' limit 1];
      if(obj_dsfs__DocuSign_Status!=null)
      {
          return obj_dsfs__DocuSign_Status[0].dsfs__Envelope_Status__c;
      }
      return '';
    }*/
    public Void sendConfirmationEmail() {
        System.debug('Inside method. con: '+con);
        OrgWideEmailAddress[] owea = [SELECT
            Id, 
            address
        FROM
            OrgWideEmailAddress
        WHERE
            Address = 'driverservices@mburse.com'];
        String htmlBody = 'Hi ' + con.FirstName + ',<br/><br/> We have received your insurance declaration page and will evaluate and notify you of your compliance status within the next three weeks. Your compliance status will not affect your reimbursements during this time. If you submitted an insurance card instead of your insurance declaration page(s), please resubmit your insurance declaration page in the mBursement portal.';
        htmlBody += '<br/><br/> Cheers,';
        /**** Sending Mail ****/
        Messaging.SingleEmailMessage mail = new  Messaging.SingleEmailMessage();
        if(!owea.isEmpty()) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        string[] toAddresses = new string[]{con.External_Email__c};
        mail.setToAddresses(toAddresses);
        /**** Email subject to be changed ****/
        mail.setSubject('Thank you for submitting your insurance');
        /**** Body of email ****/
        mail.setHtmlBody(htmlBody);
        /**** Sending the email ****/
        System.debug('mail: '+mail);
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }
    
    public void updateByMonth() {
        showPopUpMessage = 'Sorry Nothing is Updated..!!';
        List<Employee_Reimbursement__c> rlist = new List<Employee_Reimbursement__c>();
        List<Employee_Mileage__c> mlist = new List<Employee_Mileage__c>();
        Map<Integer,List<Employee_Mileage__c>> getMapMileages;
        for(ReimbursementWrapper rWrapper : wlist) {
          getMapMileages = new Map<Integer,List<Employee_Mileage__c>>();
          if(rWrapper.isEditable) {
            getMapMileages = getMileages(rWrapper.isSelected,rWrapper.milageWrapperList);
            Set<Integer> fianlValue = getMapMileages.keySet();
            List<Integer> listInt = new List<Integer>(fianlValue);
            if(listInt[0] > 0) {
              rWrapper.reimbursement.Status__c = 'Approved';
              rWrapper.reimbursement.Approved_Date__c = Date.today();
              rlist.add(rWrapper.reimbursement);
              mlist.addAll(getMapMileages.get(listInt[0]));
            }else {
              mlist.addAll(getMapMileages.get(listInt[0]));
            }
          }
        }
        /*for(wrap1 w:wlist) {
            boolean bo = false;
            for(wrap2 w2:w.w2list) {
                if(w2.isRejected)
                    bo = true;
            }
            if(w.b) {
                w.ER.Status__c = 'Approved';
                W.ER.Approved_Date__c = date.today(); 
            }
            
            for(wrap2 w2:w.w2list) {
                
                if(w2.isRejected) {
                    w.ER.Status__c = 'Approved';
                    W.ER.Approved_Date__c = date.today();
                    w2.m.Approved_Date__c = date.today();
                    w2.m.Trip_Status__c = 'Rejected';
                    w2.m.Rejected__c = true;
                    mlist.add(w2.m);
                }
                
                else if(bo&&!w2.isRejected) {
                    w.ER.Status__c = 'Approved';
                    w.ER.Approved_Date__c = date.today();
                    w2.m.Approved_Date__c = date.today();
                    w2.m.Trip_Status__c = 'Approved';
                    w2.m.Rejected__c = false;
                    mlist.add(w2.m);
                }
                
                else if(w.b) {
                    w.ER.Status__c = 'Approved';
                    w.ER.Approved_Date__c = date.today();
                    w2.m.Approved_Date__c = date.today();
                    w2.m.Trip_Status__c = 'Approved';
                    w2.m.Rejected__c = false;
                    mlist.add(w2.m);
                }
            }
            w.b = false;
            rlist.add(w.ER);  
        }*/
        
        Savepoint sp = Database.setSavepoint();
        List<sObject> records = new List<sObject>();
        
        try{
            if(!rlist.isEmpty()) {
                //for(Employee_Reimbursement__c er:rlist) {
              records.addAll((List<sObject>) (rlist));
                //}
            }
            if(!mlist.isEmpty()) {
                //for(Employee_Mileage__c em : mlist) {
              records.addAll((List<sObject>) (mlist));
                //}
            }
            if(!records.isEmpty() && (records.size() > 10000)) {
                processRecords pr = new processRecords(records);
                Database.executeBatch(pr);
                showPopUpMessage = 'Reimbursement And Mileage Updated..!!';
            }else if(!records.isEmpty() && (records.size() < 10000)) {
              update rlist;
              update mlist;
              showPopUpMessage = 'Reimbursement And Mileage Updated..!!';  
            }
        } catch (Exception e) {
            showPopUpMessage = e.getMessage();
            Database.rollback(sp);
        }   
    }

    public void userContactSave() {
      showPopUpMessage = '';
      try {
        update con;
        showPopUpMessage = 'Contact Updated Successfully..!!!';
      }catch (DmlException e) {
        System.debug('userContactSave_DmlException:'+e.getMessage());
        showPopUpMessage = e.getMessage();
      }
    }

    public void vehicleOdometer () {
      String vehicleOneValue = ApexPages.currentPage().getParameters().get('vehicleOneValue');
      String vehicleTwoValue = ApexPages.currentPage().getParameters().get('vehicleTwoValue');
      Boolean isVehicleOne = vehicleOneValue.isNumeric();
      Boolean isVehicleTwo = vehicleTwoValue.isNumeric();
      showPopUpMessage = '';
      try {
        con.Vehicle1Odometer__c = (isVehicleOne) ? Decimal.valueOf(vehicleOneValue) : null;
        con.Vehicle2Odometer__c = (isVehicleTwo) ? Decimal.valueOf(vehicleTwoValue) : null;
        update con;
        showPopUpMessage = 'Odometer Updated Successfully...!!!';
      } catch(DmlException e) {
        System.debug('saveVehicleOdometer_DmlException:'+e.getMessage());
        showPopUpMessage = e.getMessage();
      }
    }

    public static Map<Integer, List<Employee_Mileage__c>> getMileages(Boolean isReimbursement,List<MileageWrapper> milageWrappers) {
      Map<Integer, List<Employee_Mileage__c>> mapMileage = new Map<Integer, List<Employee_Mileage__c>>();
      Integer count = 0;
      List<Employee_Mileage__c> addMileage = new List<Employee_Mileage__c>();  
      for(MileageWrapper milageWrapper : milageWrappers) {
        if(isReimbursement == true) {
          milageWrapper.milage.Trip_Status__c = 'Approved';
          milageWrapper.milage.Approved_Date__c = Date.today();
          milageWrapper.milage.Rejected__c = false;
          count++;
          addMileage.add(milageWrapper.milage);
        }else{
          if(milageWrapper.isApproved == true) {
            milageWrapper.milage.Trip_Status__c = 'Approved';
            milageWrapper.milage.Approved_Date__c = Date.today();
            milageWrapper.milage.Rejected__c = false;
            count++;
            addMileage.add(milageWrapper.milage);
          }else if(milageWrapper.isRejected == true){
            milageWrapper.milage.Trip_Status__c = 'Rejected';
            milageWrapper.milage.Rejected__c = true;
            milageWrapper.milage.Approved_Date__c = null;
            addMileage.add(milageWrapper.milage);
          }
        }
      }
      System.debug('addMileage:'+addMileage);
      mapMileage.put(count,addMileage);
      return mapMileage;
    }
    
    public class ReimbursementWrapper {
        public Employee_Reimbursement__c reimbursement  {get;set;}
        public Boolean isSelected                       {get;set;}
        public Boolean isEditable                       {get;set;}
        public string month                             {get;set;}
        public string year                              {get;set;}
        public List<MileageWrapper> milageWrapperList   {get;set;}
        public decimal fuel                             {get;set;}
        public decimal variable                         {get;set;}
        public decimal VariableReimbursement            {get;set;}
        public decimal TotalReimbursement               {get;set;}
        public decimal SM                               {get;set;}
        public decimal AM                               {get;set;}
        public ReimbursementWrapper(Employee_Reimbursement__c reimbursement, string m, string y, List<Employee_Mileage__c> milageWrapperList, Boolean isSelected, contact con, list<Gas_Prices__c> gas)
        {   
            this.reimbursement = new Employee_Reimbursement__c();
            this.month = m;
            this.year = y;
            this.isSelected = isSelected;
            this.milageWrapperList = new List<MileageWrapper>();
            this.reimbursement = reimbursement;
            this.SM = 0;
            this.AM = 0;
            if(reimbursement.Status__c =='Approved' && reimbursement.Approved_Date__c != null) {
              this.isEditable = false;
            } else {
              this.isEditable = true;
            }    
            
            for(Employee_Mileage__c em : milageWrapperList)
            {
                Boolean isApprovedMileage;
                if(em.Mileage__c != null)
                {
                    this.SM+= em.Mileage__c;
                }
                
                if(em.Mileage__c != null && em.Rejected__c != true)
                {
                    this.AM+= em.Mileage__c;
                }
                if((em.Trip_Status__c == 'Approved' && em.Approved_Date__c != null)) {
                  isApprovedMileage = true;
                }else {
                  isApprovedMileage = false;
                }
                this.milageWrapperList.add(new MileageWrapper(em, variable, em.Rejected__c,isApprovedMileage, con, gas));
            }
            
            this.fuel = reimbursement.Fuel_Variable_Rate__c != null ? reimbursement.Fuel_Variable_Rate__c.setScale(4):0.0;
            if(fuel != null && reimbursement.Maintenance_and_Tires__c != null)
                this.variable = (fuel + reimbursement.Maintenance_and_Tires__c).setScale(4);
            this.VariableReimbursement = reimbursement.Monthly_Variable_Amount__c;
            this.TotalReimbursement = reimbursement.Total_Monthly_Reimbursement__c;
        } 
    }
    
    public class MileageWrapper {        
        public Employee_Mileage__c milage        {get;set;}
        public boolean isRejected                {get;set;}
        public Boolean isApproved                {get;set;}
        public Decimal VariableReimbursement     {get;set;}
        public Decimal VariableReimbursement2    {get;set;}
        public Decimal Variable                  {get;set;}
        public Decimal mpg                       {get;set;}
        public Decimal mainttire                 {get;set;}
        public Decimal fuel                      {get;set;}
        public MileageWrapper(Employee_Mileage__c milage, decimal variable1, boolean isRejected,Boolean isApproved, contact con, list<Gas_Prices__c> gas) {
            VariableReimbursement2 = 0.00;
            this.isRejected = isRejected;
            this.isApproved = isApproved;
            this.milage = milage;
            if(milage.Variable__c != null)
                VariableReimbursement2 = milage.Variable__c;
            if(milage.MPG__c != null)
                mpg = milage.MPG__c;
            if(milage.Maintenance_and_Tires__c != null)
                mainttire = milage.Maintenance_and_Tires__c;
            if(milage.MPG__c != 0 && milage.Fuel_price__c != null && milage.MPG__c != null)
                fuel = (milage.Fuel_price__c/milage.MPG__c).setscale(4);
            if(milage.Fuel_price__c != null && milage.MPG__c != null && milage.MPG__c != 0 && mainttire != null)
                Variable = ((milage.Fuel_price__c/milage.MPG__c)+mainttire).setscale(4);
        }       
    }
    
    public class userwrap {
        
        public string name              {get;set;}
        public string email             {get;set;}
        public string phone             {get;set;}
        public string contactid         {get;set;}
        public userwrap(String name, string email, String phone, id contactid) {
            this.name = name;
            this.email = email;
            this.phone = phone;
            this.contactid = contactid;       
        } 
    }

    public pagereference backMethod() {
        Pagereference pg =  new Pagereference('/apex/RG_Create_New_User_Page?man='+man);
        pg.setRedirect(true);
        return pg;
    }

    
}