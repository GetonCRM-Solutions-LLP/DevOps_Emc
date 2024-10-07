public class adminstatuscontroller 
{
  public Boolean isMVRCheck{get; set;}
    public boolean isDriver{get; set;}
    public boolean isManager{get; set;}
    public boolean isSuperManager{get; set;}
    public boolean displayPopup {get; set;}
    public boolean displayPopup1 {get; set;}
    public String manid{get; set;}
    public String drid{get; set;}
    public contact manager {get; set;}
    public contact driver {get; set;}
   // public List<Attendee__c> obj_Attendee {get; set;}
    public String obj_status {get;set;}
    public String obj_driver_meeting_status {get;set;}
    public String obj_category {get;set;}
    public List<Attachment> obj_driver_insurance {get;set;}
    public List<Attachment> obj_reciption_docs {get;set;}   
    public Integer obj_attachementsize  {get;set;} 
    public Integer obj_reciptsize  {get;set;} 
    //public List<dsfs__DocuSign_Status__c> obj_docusignstatus {get;set;} 
   // public List<dsfs__DocuSign_Recipient_Status__c> obj_dsfs_DocuSign_Reciption_Status{get; set;}
    public Date currentdate {get;set;}    
    public List<IRS_Mileage_Rate__c> irsrate {get;set;}
    public List<wrapppertax> wrapppertaxList{get;set;}
    public Integer quarters {get;set;}
    public Map<integer,wrapppertax> obj_map{get;set;}
    public Map<String,Double> obj_irsrate {get;set;}
    public String accesstoken {get;set;}
    public List<String> listofmonths {get;set;}
    public Double TotalActualReimbursements {get;set;}
    public Double MaximumAllowable{get;set;}
    public Double AnnualTaxLiability{get;set;}
    public String compliancestatus{get;set;}
    public Decimal totalmileages  {get;set;}
    public List<wrapperTaxReport> obj_wrapperTaxReport {get;set;}
    public List<wrapperTaxReport> obj_wrapperTaxReport2 {get;set;}
    public wrapperTaxReport obj_wrapperTaxReport_driver {get;set;}
    public Map<Integer,wrapperTaxReport> obj_map_wrapperTaxReport {get;set;}
    public adminstatuscontroller() 
   {
      isMVRCheck = false;
      quarters = 0;
      totalmileages =0;
      TotalActualReimbursements=0;
      MaximumAllowable=0;
      AnnualTaxLiability=0;
      
      obj_wrapperTaxReport = new List<wrapperTaxReport>();
      obj_map_wrapperTaxReport = new Map<Integer,wrapperTaxReport>();
      obj_wrapperTaxReport2 = new List<wrapperTaxReport>();
      obj_wrapperTaxReport_driver = new wrapperTaxReport();

      wrapppertaxList = new List<wrapppertax>();
      obj_map = new map<integer,wrapppertax>();
    //  obj_Attendee = new List<Attendee__c>();
      irsrate = new List<IRS_Mileage_Rate__c>();
      obj_irsrate = new Map<String,Double>();
        
      obj_driver_insurance = new List<Attachment>();
      obj_reciption_docs = new List<Attachment>();
      
      List<String> obj_date = Label.dateofIRS.split('-');
      currentdate = date.newinstance(Integer.valueOf(obj_date[2]),Integer.valueOf(obj_date[1]), Integer.valueOf(obj_date[0]));
      listofmonths = new List<String>();
      if(currentdate.month()!=12)
      {
          
          listofmonths.add(String.valueOf((currentdate.year())-1));             
      }
      listofmonths.add(String.valueOf(currentdate.year()));
     
     // obj_dsfs_DocuSign_Reciption_Status = new List<dsfs__DocuSign_Recipient_Status__c>();
     // obj_docusignstatus = new List<dsfs__DocuSign_Status__c>();
      irsrate = [select id,year__c,IRS_Rate__c from IRS_Mileage_Rate__c where year__c =: listofmonths];
      for(IRS_Mileage_Rate__c rate:irsrate)
      {
        obj_irsrate.put(rate.year__c,Double.valueOf(rate.IRS_Rate__c));
      }
      
      if(ApexPages.currentPage().getParameters().containsKey('manid'))
       {
           manid= ApexPages.currentPage().getParameters().get('manid'); 
         //  manager =[select id,name,email from contact where id=:manid limit 1];
       }
       if(ApexPages.currentPage().getParameters().containsKey('drid'))
       {
           drid= ApexPages.currentPage().getParameters().get('drid');
           driver=[select id,name,account.Motor_Vehicle_Record_Check_Document__c,email,Insurance_Attachment_Id__c,MVR_Attachment_Id__c,compliancestatus__c  from contact where id=:drid limit 1];
           obj_driver_insurance = [select id,Body,Name from Attachment where ParentId=:drid];
           obj_attachementsize = obj_driver_insurance.size();
       }
       if(driver.account.Motor_Vehicle_Record_Check_Document__c == true) 
       {
          isMVRCheck = true;
       }
       compliancestatus ='Please Set the Compliance Status';
       if(driver.compliancestatus__c!=null)
       {
           compliancestatus =driver.compliancestatus__c;
       }        
     // getstatus();
     // getdocusignreciptionrecords();
     // getdocusignrecords();
      compliancestatus();
      // obj_reciption_docs = [select id,Body,Name from Attachment where parentid='a090m000001OU5E'];        
      // obj_reciptsize= obj_reciption_docs.size();
   }
   public void compliancestatus()
   {
      List<String> listcomplincemonth =  new List<String>();
      wrapppertax wrapppertax1 = new wrapppertax();
      wrapppertax wrapppertax2 = new wrapppertax();
      wrapppertax wrapppertax3 = new wrapppertax();
      wrapppertax wrapppertax4 = new wrapppertax();

      if((driver.compliancestatus__c=='Yes'))
      {
          Integer month = currentdate.month();
          if(month==12)
          {
              listcomplincemonth.add(String.valueOf(month)+'-'+currentdate.year());              
          }
          else
          {
              listcomplincemonth.add(String.valueOf(12)+'-'+(currentdate.year()-1));
              for(Integer i=1;i<=month;i++)
              {
                  if(i<10)
                  {
                     listcomplincemonth.add('0'+String.valueOf(i)+'-'+currentdate.year()); 
                  } 
                  else if((i==10)||(i==11))
                  {
                      listcomplincemonth.add(String.valueOf(i)+'-'+(currentdate.year()));
                  }          
              }
          }  
          
          List<Employee_Reimbursement__c> listEmployeeReimbursement= new List<Employee_Reimbursement__c>();
          listEmployeeReimbursement=[select id,Total_Mileage__c,Total_Monthly_Reimbursement__c,Contact_Id__c,Contact_Id__r.Name,Contact_Id__r.Employee_ID__c,Contact_Id__r.External_Email__c,Month__c,Approved_Date__c  from Employee_Reimbursement__c where Contact_Id__c=:driver.id and Month__c =:listcomplincemonth and Approved_Date__c!=null];
            
          for(Employee_Reimbursement__c obj:listEmployeeReimbursement)
          {

              List<String> months = new List<String>();
              if((obj.Month__c!=null)&&(obj.Month__c.contains('-')))
              {
                  months = obj.Month__c.split('-');
                  if((Integer.valueOf(months[0])==12)||(Integer.valueOf(months[0])<=2))
                  {
                     if(obj_map.containsKey(1))
                     {
                        wrapppertax1 =  obj_map.get(1);
                     }
                      wrapppertax1.quarterno = 1;
                      if((wrapppertax1.Mileages!=null))
                      {
                        Double dd = wrapppertax1.Mileages;
                        if(obj.Total_Mileage__c!=null)
                        {
                            dd = dd + obj.Total_Mileage__c;
                        }                                                   
                        Decimal ddf= Decimal.valueOf(dd);
                        dd = ddf.setScale(2);
                        wrapppertax1.Mileages = dd; 
                      }
                      else
                      {  
                          if(obj.Total_Mileage__c!=null)
                          {
                              wrapppertax1.Mileages = obj.Total_Mileage__c.setScale(2);
                          }                      
                        
                      }
                      if((wrapppertax1.Reimbursements!=null))
                      {
                          Double dd = wrapppertax1.Reimbursements;
                          if(obj.Total_Monthly_Reimbursement__c!=null)
                          {
                              dd = dd + obj.Total_Monthly_Reimbursement__c;    
                          }                          
                          Decimal ddf= Decimal.valueOf(dd);
                          dd = ddf.setScale(2);
                          wrapppertax1.Reimbursements = dd; 
                      }
                      else
                      {    
                        if(obj.Total_Monthly_Reimbursement__c!=null)
                        {
                            wrapppertax1.Reimbursements= obj.Total_Monthly_Reimbursement__c.setScale(2);
                        }                                            
                        
                      }
                      if((wrapppertax1.MaxIRSrate!=null))
                      {
                          Decimal dd = wrapppertax1.MaxIRSrate;
                          if(obj_irsrate.containsKey(String.valueOf(months[1]))&&(obj.Total_Mileage__c!=null))
                          {
                              dd = dd + (((obj.Total_Mileage__c)*(obj_irsrate.get(String.valueOf(months[1])))));                         
                          }                          
                          dd = dd.setScale(2);                          
                          wrapppertax1.MaxIRSrate = dd; 

                      }
                      else
                      {
                        if((obj.Total_Mileage__c!=null) && obj_irsrate.containsKey(String.valueOf(months[1])))
                        {
                            wrapppertax1.MaxIRSrate = ((obj.Total_Mileage__c)*obj_irsrate.get(String.valueOf(months[1])));
                        }
                        
                      }

                      Double dd1 = 0;
                      if(wrapppertax1.ImputedAmount!=null)
                      {
                          dd1 =wrapppertax1.ImputedAmount;                      
                      }
                      if((obj.Total_Monthly_Reimbursement__c!=null) && (obj.Total_Mileage__c!=null) && (obj_irsrate.containsKey(String.valueOf(months[1]))))
                      {
                          dd1 = dd1+ obj.Total_Monthly_Reimbursement__c-((obj.Total_Mileage__c)*obj_irsrate.get(String.valueOf(months[1])));                          
                      }                      
                      Decimal ddf2= Decimal.valueOf(dd1);
                      dd1 = ddf2.setScale(2);
                      wrapppertax1.ImputedAmount = dd1;                       
                      obj_map.put(1,wrapppertax1);
                       
                      
                     // obj_wrapperTaxReport.add(objw);
                                             
                  }
                  else if((Integer.valueOf(months[0])>=3)&&(Integer.valueOf(months[0])<=5))
                  {
                     if(obj_map.containsKey(2))
                     {
                        wrapppertax2 =  obj_map.get(2);
                     }
                      wrapppertax2.quarterno = 2;                      
                      if((wrapppertax2.Mileages!=null))
                      {
                          Double dd = wrapppertax2.Mileages;
                          if(obj.Total_Mileage__c!=null)
                            {
                                dd = dd + obj.Total_Mileage__c;
                            } 
                          Decimal ddf= Decimal.valueOf(dd);
                          dd = ddf.setScale(2);
                          wrapppertax2.Mileages = dd;  
                      }
                      else
                      {
                        if(obj.Total_Mileage__c!=null)
                          {
                              wrapppertax2.Mileages = obj.Total_Mileage__c.setScale(2);
                          }
                      }
                      if((wrapppertax2.Reimbursements!=null))
                      {
                          Double dd = wrapppertax2.Reimbursements;
                          if(obj.Total_Monthly_Reimbursement__c!=null)
                          {
                              dd = dd + obj.Total_Monthly_Reimbursement__c;    
                          }
                          Decimal ddf= Decimal.valueOf(dd);
                          dd = ddf.setScale(2);
                          wrapppertax2.Reimbursements = dd; 
                      }
                      else
                      {
                         if(obj.Total_Monthly_Reimbursement__c!=null)
                        {
                            wrapppertax2.Reimbursements= obj.Total_Monthly_Reimbursement__c.setScale(2);
                        }
                      }
                      if((wrapppertax2.MaxIRSrate!=null))
                      {
                          Decimal dd =wrapppertax2.MaxIRSrate;
                          if(obj_irsrate.containsKey(String.valueOf(months[1]))&&(obj.Total_Mileage__c!=null))
                          {
                              dd = dd + (((obj.Total_Mileage__c)*(obj_irsrate.get(String.valueOf(months[1])))));                         
                          }
                          dd = dd.setScale(2);                          
                          wrapppertax2.MaxIRSrate = dd; 
                      }
                      else
                      {
                        wrapppertax2.MaxIRSrate = ((obj.Total_Mileage__c)*obj_irsrate.get(String.valueOf(months[1])));
                      }
                      Double dd1 = 0;
                      if(wrapppertax2.ImputedAmount!=null)
                      {
                          dd1 =wrapppertax2.ImputedAmount;                      
                      }
                      if((obj.Total_Monthly_Reimbursement__c!=null) && (obj.Total_Mileage__c!=null) && (obj_irsrate.containsKey(String.valueOf(months[1]))))
                      {
                          dd1 = dd1+ obj.Total_Monthly_Reimbursement__c-((obj.Total_Mileage__c)*obj_irsrate.get(String.valueOf(months[1])));                          
                      }
                      Decimal ddf2= Decimal.valueOf(dd1);
                      dd1 = ddf2.setScale(2);
                      wrapppertax2.ImputedAmount = dd1;
                      obj_map.put(2,wrapppertax2);
                  }
                  else if((Integer.valueOf(months[0])>=6)&&(Integer.valueOf(months[0])<=8))
                  {
                      if(obj_map.containsKey(3))
                     {
                        wrapppertax3 =  obj_map.get(3);
                     }
                      wrapppertax3.quarterno = 3;                      
                      if((wrapppertax3.Mileages!=null))
                      {
                          Double dd = wrapppertax3.Mileages;
                          if(obj.Total_Mileage__c!=null)
                            {
                                dd = dd + obj.Total_Mileage__c;
                            } 
                          Decimal ddf= Decimal.valueOf(dd);
                          dd = ddf.setScale(2);
                          wrapppertax3.Mileages = dd; 
                      }
                      else
                      {
                        if(obj.Total_Mileage__c!=null)
                          {
                              wrapppertax3.Mileages = obj.Total_Mileage__c.setScale(2);
                          }
                      }
                      if((wrapppertax3.Reimbursements!=null))
                      {
                          Double dd = wrapppertax3.Reimbursements;
                          if(obj.Total_Monthly_Reimbursement__c!=null)
                          {
                              dd = dd + obj.Total_Monthly_Reimbursement__c;    
                          }
                          Decimal ddf= Decimal.valueOf(dd);
                          dd = ddf.setScale(2);
                          wrapppertax3.Reimbursements = dd; 
                      }
                      else
                      {
                        if(obj.Total_Monthly_Reimbursement__c!=null)
                        {
                            wrapppertax3.Reimbursements= obj.Total_Monthly_Reimbursement__c.setScale(2);
                        }
                      }
                      if((wrapppertax3.MaxIRSrate!=null))
                      {
                          Decimal dd =wrapppertax3.MaxIRSrate;
                          if(obj_irsrate.containsKey(String.valueOf(months[1]))&&(obj.Total_Mileage__c!=null))
                          {
                              dd = dd + (((obj.Total_Mileage__c)*(obj_irsrate.get(String.valueOf(months[1])))));                         
                          }
                          dd = dd.setScale(2);                          
                          wrapppertax3.MaxIRSrate = dd;  
                      }
                      else
                      {
                        wrapppertax3.MaxIRSrate = ((obj.Total_Mileage__c)*obj_irsrate.get(String.valueOf(months[1])));
                      }
                      Double dd1 = 0;
                      if(wrapppertax3.ImputedAmount!=null)
                      {
                          dd1 =wrapppertax3.ImputedAmount;                      
                      }
                      if((obj.Total_Monthly_Reimbursement__c!=null) && (obj.Total_Mileage__c!=null) && (obj_irsrate.containsKey(String.valueOf(months[1]))))
                      {
                          dd1 = dd1+ obj.Total_Monthly_Reimbursement__c-((obj.Total_Mileage__c)*obj_irsrate.get(String.valueOf(months[1])));                          
                      }
                      Decimal ddf2= Decimal.valueOf(dd1);
                      dd1 = ddf2.setScale(2);
                      wrapppertax3.ImputedAmount = dd1;
                      obj_map.put(3,wrapppertax3);
                  }
                  else if((Integer.valueOf(months[0])>=9)&&(Integer.valueOf(months[0])<=11))
                  {
                      if(obj_map.containsKey(4))
                     {
                        wrapppertax4 =  obj_map.get(4);
                     }
                      wrapppertax4.quarterno = 4;                      
                      if((wrapppertax4.Mileages!=null))
                      {
                          Double dd = wrapppertax4.Mileages;
                         if(obj.Total_Mileage__c!=null)
                            {
                                dd = dd + obj.Total_Mileage__c;
                            } 
                          Decimal ddf= Decimal.valueOf(dd);
                          dd = ddf.setScale(2);
                          wrapppertax4.Mileages = dd; 
                      }
                      else
                      {
                        if(obj.Total_Mileage__c!=null)
                          {
                              wrapppertax4.Mileages = obj.Total_Mileage__c.setScale(2);
                          }
                      }
                      if((wrapppertax4.Reimbursements!=null))
                      {
                          Double dd = wrapppertax4.Reimbursements;
                          if(obj.Total_Monthly_Reimbursement__c!=null)
                          {
                              dd = dd + obj.Total_Monthly_Reimbursement__c;    
                          }
                          Decimal ddf= Decimal.valueOf(dd);
                          dd = ddf.setScale(2);
                          wrapppertax4.Reimbursements = dd; 
                      }
                      else
                      {
                        if(obj.Total_Monthly_Reimbursement__c!=null)
                        {
                            wrapppertax4.Reimbursements= obj.Total_Monthly_Reimbursement__c.setScale(2);
                        }
                      }
                      if((wrapppertax4.MaxIRSrate!=null))
                      {
                          Decimal dd =wrapppertax4.MaxIRSrate;
                          if(obj_irsrate.containsKey(String.valueOf(months[1]))&&(obj.Total_Mileage__c!=null))
                          {
                              dd = dd + (((obj.Total_Mileage__c)*(obj_irsrate.get(String.valueOf(months[1])))));                         
                          }  
                          dd = dd.setScale(2);                          
                          wrapppertax4.MaxIRSrate = dd; 
                      }
                      else
                      {
                        wrapppertax4.MaxIRSrate = ((obj.Total_Mileage__c)*obj_irsrate.get(String.valueOf(months[1])));
                      }
                      Double dd1 = 0;
                      if(wrapppertax4.ImputedAmount!=null)
                      {
                          dd1 =wrapppertax4.ImputedAmount;                      
                      }
                      if((obj.Total_Monthly_Reimbursement__c!=null) && (obj.Total_Mileage__c!=null) && (obj_irsrate.containsKey(String.valueOf(months[1]))))
                      {
                          dd1 = dd1+ obj.Total_Monthly_Reimbursement__c-((obj.Total_Mileage__c)*obj_irsrate.get(String.valueOf(months[1])));                          
                      }
                      Decimal ddf2= Decimal.valueOf(dd1);
                      dd1 = ddf2.setScale(2);
                      wrapppertax4.ImputedAmount = dd1;
                      obj_map.put(4,wrapppertax4);
                      
                  }
                  if(obj.Approved_Date__c!=null)
                  {
                      wrapperTaxReport objw = new wrapperTaxReport();
                      objw.drivername = obj.Contact_Id__r.Name;
                      objw.employeeid =obj.Contact_Id__r.Employee_ID__c;
                      objw.emailid = obj.Contact_Id__r.External_Email__c;
                      if(obj.Total_Mileage__c!=null)
                      {
                          objw.approvedmileages = obj.Total_Mileage__c.setScale(2);
                      }
                      else
                      {
                           objw.approvedmileages = 0;
                      }
                      if(obj.Total_Monthly_Reimbursement__c!=null)
                      {
                          objw.totalreim = obj.Total_Monthly_Reimbursement__c.setScale(2);
                      }
                      else
                      {
                           objw.totalreim = 0;
                      }
                      if((obj.Total_Mileage__c!=null)&&(obj_irsrate.containsKey(String.valueOf(months[1]))))
                      {
                          objw.iRSallowable =(((obj.Total_Mileage__c.setScale(2))*(obj_irsrate.get(String.valueOf(months[1])))));
                      }                      
                      if((obj.Total_Monthly_Reimbursement__c !=null)&&(obj.Total_Mileage__c!=null)&&(obj_irsrate.containsKey(String.valueOf(months[1]))))
                      {
                          objw.imputedincome=(obj.Total_Monthly_Reimbursement__c.setScale(2))-((obj.Total_Mileage__c.setScale(2))*obj_irsrate.get(String.valueOf(months[1])));
                      }
                      objw.month =Integer.valueOf(months[0]);
                      objw.year =String.valueOf(months[1]);
                      obj_map_wrapperTaxReport.put(Integer.valueOf(months[0]),objw);
                      //obj_wrapperTaxReport.add(objw);  

                      obj_wrapperTaxReport_driver.drivername = obj.Contact_Id__r.Name;
                      if(obj.Contact_Id__r.Employee_ID__c!=null)
                      {
                          obj_wrapperTaxReport_driver.employeeid = obj.Contact_Id__r.Employee_ID__c;
                      }
                      if(obj.Contact_Id__r.External_Email__c!=null)
                      {
                          obj_wrapperTaxReport_driver.emailid = obj.Contact_Id__r.External_Email__c;
                      }
                      

                  }

                  
              }
          }
          
          if(obj_map.containsKey(1))
          {

              /*if(obj_map.get(1).Mileages >1250)
              {
                wrapppertax1 = obj_map.get(1);
                wrapppertax1.ImputedAmount = 0;
                obj_map.put(1,wrapppertax1);
              }*/ 
                          
               
             // wrapppertaxList.add(obj_map.get(1));
              TotalActualReimbursements =obj_map.get(1).Reimbursements;
              MaximumAllowable =  obj_map.get(1).MaxIRSrate;
              AnnualTaxLiability =obj_map.get(1).ImputedAmount; 
              if(obj_map.get(1).Mileages!=null)
              {
                 totalmileages =obj_map.get(1).Mileages;
              } 
              if(totalmileages>5000)
              {
                
                wrapppertax1 = obj_map.get(1);
                wrapppertax1.ImputedAmount = 0;
                obj_map.put(1,wrapppertax1);
                AnnualTaxLiability =0;
                if(obj_map_wrapperTaxReport.containsKey(12))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(12);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(12,obj);

                }
                if(obj_map_wrapperTaxReport.containsKey(1))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(1);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(1,obj);
                }
                if(obj_map_wrapperTaxReport.containsKey(2))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(2);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(2,obj);
                }
              }
          }
          /*else
          {
              wrapppertax1.Reimbursements = 0;
              wrapppertax1.MaxIRSrate =0;
              wrapppertax1.ImputedAmount =0;
              wrapppertax1.Mileages =0;
              wrapppertax1.quarterno = 1;
              wrapppertaxList.add(wrapppertax1);
              obj_map.put(1,wrapppertax1);
          }*/
          if(obj_map.containsKey(2))
          {
            /*if(obj_map.get(2).Mileages >1250)
              {
                wrapppertax2 = obj_map.get(2);
                wrapppertax2.ImputedAmount = 0;
                obj_map.put(2,wrapppertax2);
              } */ 
                            
              
             // wrapppertaxList.add(obj_map.get(2));
             
              TotalActualReimbursements =TotalActualReimbursements+obj_map.get(2).Reimbursements;
              MaximumAllowable = MaximumAllowable  +obj_map.get(2).MaxIRSrate;
              AnnualTaxLiability =AnnualTaxLiability+obj_map.get(2).ImputedAmount;
              if(obj_map.get(2).Mileages!=null)
              {
                 totalmileages =totalmileages+obj_map.get(2).Mileages;
              }
              if(totalmileages>5000)
              {
                if(obj_map.containsKey(1))
                {
                  wrapppertax1 = obj_map.get(1);
                  wrapppertax1.ImputedAmount = 0;
                  obj_map.put(1,wrapppertax1);
                }
               
                wrapppertax2 = obj_map.get(2);
                wrapppertax2.ImputedAmount = 0;
                obj_map.put(2,wrapppertax2);
                AnnualTaxLiability =0;

                if(obj_map_wrapperTaxReport.containsKey(12))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(12);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(12,obj);

                }
                if(obj_map_wrapperTaxReport.containsKey(1))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(1);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(1,obj);
                }
                if(obj_map_wrapperTaxReport.containsKey(2))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(2);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(2,obj);
                }

                if(obj_map_wrapperTaxReport.containsKey(3))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(3);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(3,obj);

                }
                if(obj_map_wrapperTaxReport.containsKey(4))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(4);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(4,obj);
                }
                if(obj_map_wrapperTaxReport.containsKey(5))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(5);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(5,obj);
                }
              }  
          }
          /*else
          {
              wrapppertax2.Reimbursements = 0;
              wrapppertax2.MaxIRSrate =0;
              wrapppertax2.ImputedAmount =0;
              wrapppertax2.Mileages =0;
              wrapppertax2.quarterno = 2;
              wrapppertaxList.add(wrapppertax2);
              obj_map.put(2,wrapppertax2);
          }*/
          if(obj_map.containsKey(3))
          {
              /*if(obj_map.get(3).Mileages >1250)
              {
                wrapppertax3 = obj_map.get(3);
                wrapppertax3.ImputedAmount = 0;
                obj_map.put(3,wrapppertax3);
              }*/ 
              TotalActualReimbursements =TotalActualReimbursements+obj_map.get(3).Reimbursements;
              MaximumAllowable = MaximumAllowable  +obj_map.get(3).MaxIRSrate;
              AnnualTaxLiability =AnnualTaxLiability+obj_map.get(3).ImputedAmount; 
              if(obj_map.get(3).Mileages!=null)
              {
                totalmileages =totalmileages+obj_map.get(3).Mileages; 
              }
              
              if(totalmileages>5000)
              {
               if(obj_map.containsKey(1))
               {
                 wrapppertax1 = obj_map.get(1);
                wrapppertax1.ImputedAmount = 0;
                obj_map.put(1,wrapppertax1);
               }
               
                
             if(obj_map.containsKey(2))
               {
                wrapppertax2 = obj_map.get(2);
                wrapppertax2.ImputedAmount = 0;
                obj_map.put(2,wrapppertax2);
              }
                
                wrapppertax3 = obj_map.get(3);
                wrapppertax3.ImputedAmount = 0;
                obj_map.put(3,wrapppertax3);
                AnnualTaxLiability =0;

                if(obj_map_wrapperTaxReport.containsKey(12))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(12);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(12,obj);

                }
                if(obj_map_wrapperTaxReport.containsKey(1))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(1);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(1,obj);
                }
                if(obj_map_wrapperTaxReport.containsKey(2))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(2);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(2,obj);
                }

                if(obj_map_wrapperTaxReport.containsKey(3))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(3);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(3,obj);

                }
                if(obj_map_wrapperTaxReport.containsKey(4))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(4);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(4,obj);
                }
                if(obj_map_wrapperTaxReport.containsKey(5))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(5);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(5,obj);
                }

                 if(obj_map_wrapperTaxReport.containsKey(6))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(6);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(6,obj);

                }
                if(obj_map_wrapperTaxReport.containsKey(7))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(7);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(7,obj);
                }
                if(obj_map_wrapperTaxReport.containsKey(8))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(8);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(8,obj);
                }

              }
             // wrapppertaxList.add(obj_map.get(3));
              
          }
         /* else
          {
              wrapppertax3.Reimbursements = 0;
              wrapppertax3.MaxIRSrate =0;
              wrapppertax3.ImputedAmount =0;
              wrapppertax3.Mileages =0;
              wrapppertax3.quarterno =3;
              wrapppertaxList.add(wrapppertax3);
              obj_map.put(3,wrapppertax3);
          }*/
          if(obj_map.containsKey(4))
          {
              /*if(obj_map.get(4).Mileages >1250)
              {
                wrapppertax4 = obj_map.get(4);
                wrapppertax4.ImputedAmount = 0;
                obj_map.put(4,wrapppertax4);
              } */
              TotalActualReimbursements =TotalActualReimbursements+obj_map.get(4).Reimbursements;
              MaximumAllowable = MaximumAllowable  +obj_map.get(4).MaxIRSrate;
              AnnualTaxLiability =AnnualTaxLiability+obj_map.get(4).ImputedAmount;
              if(obj_map.get(4).Mileages!=null)
              {
                totalmileages =totalmileages+obj_map.get(4).Mileages; 
              } 
              if(totalmileages>5000)
              {
                 if(obj_map.containsKey(1))
               {        
                wrapppertax1 = obj_map.get(1);
                wrapppertax1.ImputedAmount = 0;
                obj_map.put(1,wrapppertax1);
                }
               if(obj_map.containsKey(2))
               {
                wrapppertax2 = obj_map.get(2);
                wrapppertax2.ImputedAmount = 0;
                obj_map.put(2,wrapppertax2);
                }
               if(obj_map.containsKey(3))
               {
                wrapppertax3 = obj_map.get(3);
                wrapppertax3.ImputedAmount = 0;
                obj_map.put(3,wrapppertax3);
              }
                
                wrapppertax4 = obj_map.get(4);
                wrapppertax4.ImputedAmount = 0;
                obj_map.put(4,wrapppertax4);
                AnnualTaxLiability =0;

                if(obj_map_wrapperTaxReport.containsKey(12))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(12);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(12,obj);

                }
                if(obj_map_wrapperTaxReport.containsKey(1))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(1);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(1,obj);
                }
                if(obj_map_wrapperTaxReport.containsKey(2))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(2);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(2,obj);
                }

                if(obj_map_wrapperTaxReport.containsKey(3))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(3);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(3,obj);

                }
                if(obj_map_wrapperTaxReport.containsKey(4))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(4);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(4,obj);
                }
                if(obj_map_wrapperTaxReport.containsKey(5))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(5);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(5,obj);
                }

                if(obj_map_wrapperTaxReport.containsKey(6))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(6);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(6,obj);

                }
                if(obj_map_wrapperTaxReport.containsKey(7))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(7);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(7,obj);
                }
                if(obj_map_wrapperTaxReport.containsKey(8))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(8);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(8,obj);
                }

                if(obj_map_wrapperTaxReport.containsKey(9))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(9);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(9,obj);

                }
                if(obj_map_wrapperTaxReport.containsKey(10))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(10);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(10,obj);
                }
                if(obj_map_wrapperTaxReport.containsKey(11))
                {
                    wrapperTaxReport obj = obj_map_wrapperTaxReport.get(11);
                    obj.imputedincome = 0;
                    obj_map_wrapperTaxReport.put(11,obj);
                }

              }              
             // wrapppertaxList.add(obj_map.get(4));
              
          }
          /*else
          {
              wrapppertax4.Reimbursements = 0;
              wrapppertax4.MaxIRSrate =0;
              wrapppertax4.ImputedAmount =0;
              wrapppertax4.Mileages =0;
              wrapppertax4.quarterno = 4;
              wrapppertaxList.add(wrapppertax4);
              obj_map.put(4,wrapppertax4);
          }*/  
          if(obj_map.containsKey(1))
          { 
            wrapppertaxList.add(obj_map.get(1));
          }
          if(obj_map.containsKey(2))
          {
            wrapppertaxList.add(obj_map.get(2));
          }
          if(obj_map.containsKey(3))
          {
             wrapppertaxList.add(obj_map.get(3));
          }
          if(obj_map.containsKey(4))
          {             
             wrapppertaxList.add(obj_map.get(4));
          }
          if(obj_map_wrapperTaxReport.containsKey(12))
          {
              wrapperTaxReport objs = obj_map_wrapperTaxReport.get(12);              
              objs.approvedmileages = Decimal.valueOf(obj_map_wrapperTaxReport.get(12).approvedmileages).setScale(2);
              objs.totalreim = Decimal.valueOf(obj_map_wrapperTaxReport.get(12).totalreim).setScale(2);
              objs.iRSallowable= Decimal.valueOf(obj_map_wrapperTaxReport.get(12).iRSallowable).setScale(2);
              objs.imputedincome = Decimal.valueOf(obj_map_wrapperTaxReport.get(12).imputedincome).setScale(2);
              obj_map_wrapperTaxReport.put(12,objs);
              obj_wrapperTaxReport.add(obj_map_wrapperTaxReport.get(12));
          }
          Set<Integer> obj_set = new Set<Integer>();
          List<Integer> obj_list = new List<Integer>();
          if(obj_map_wrapperTaxReport.size()>0)
          {
            obj_set = obj_map_wrapperTaxReport.keySet();
            obj_list.addAll(obj_set);
            obj_list.sort();
          }
          for(Integer i : obj_list)
          {
              if(i!=12)
              {
                wrapperTaxReport objs = obj_map_wrapperTaxReport.get(i);              
                objs.approvedmileages = Decimal.valueOf(obj_map_wrapperTaxReport.get(i).approvedmileages).setScale(2);
                objs.totalreim = Decimal.valueOf(obj_map_wrapperTaxReport.get(i).totalreim).setScale(2);
                objs.iRSallowable= Decimal.valueOf(obj_map_wrapperTaxReport.get(i).iRSallowable).setScale(2);
                objs.imputedincome = Decimal.valueOf(obj_map_wrapperTaxReport.get(i).imputedincome).setScale(2);
                obj_map_wrapperTaxReport.put(i,objs);
                obj_wrapperTaxReport.add(obj_map_wrapperTaxReport.get(i));
              }
          }
          
          obj_wrapperTaxReport_driver.imputedincome=AnnualTaxLiability;
          obj_wrapperTaxReport2.add(obj_wrapperTaxReport_driver);
          quarters = wrapppertaxList.size(); 
      }

   }
 /*  public PageReference updateWebinarecord()
   {
      accesstoken = WebinarToken.getAccessTokenfromGotoWebinar('natavar.goc@gmail.com');
      if((accesstoken!='')&&(accesstoken!=null)&&(accesstoken!=' '))
        {   
            // update
            PageReference  pg = new PageReference(System.Label.communityurl+'WebinarRequestOrigin?manid='+manid+'&drid='+drid);                     
            pg.setRedirect(true);
            return pg;
        }
        else
        {                               
            return null;  
        }
     
   }
    public void getstatus()
    {
         obj_Attendee = [select id,Contact__c, Email__c, First_name__c, Join_Url__c, Last_name__c, Registrant_key__c, Registration_date__c, Status__c, Webinar__c from Attendee__c where Contact__c=:drid limit 1];
         if(obj_Attendee.size()>0)
         {
             obj_driver_meeting_status = obj_Attendee[0].Status__c;
         }
         
    }*/
    public PageReference updatestatus()
    {
      // updates the status in various places like docusign
        
        if(obj_category=='Driver Meeting')
        {
           // updateMeetingStatus();
        }
        else if(obj_category=='Signed Packet')
        {
            // updatesignedpacketstatus();
        }
        else if(obj_category=='Driver Packet')
        {
         // updatesignedstatus();
        }
        
        return null;
    }
   /* public void updateMeetingStatus()
    {
        obj_Attendee[0].Status__c = obj_status;
        update obj_Attendee;
    }*/
    public void updatesignedpacketstatus()
    {
       // obj_dsfs_DocuSign_Reciption_Status.dsfs__Recipient_Status__c= obj_status;
       // update obj_dsfs_DocuSign_Reciption_Status;
    }
    public void updatesignedstatus()
    {
       // obj_docusignstatus.dsfs__Envelope_Status__c= obj_status;
       // update obj_docusignstatus;
    }
    public void showPopup() 
    {        
        displayPopup = true;    
    }
    public void closePopup() 
    {        
        displayPopup = false;        
    }
    public void showPopup1() 
    {        
        displayPopup1 = true;    
    }
    public void closePopup1() 
    {        
        displayPopup1 = false;        
    }
    /*public void getdocusignreciptionrecords()
    {
      obj_dsfs_DocuSign_Reciption_Status =  [select id,dsfs__DocuSign_Recipient_Email__c,dsfs__Contact__c,dsfs__Recipient_Status__c  from dsfs__DocuSign_Recipient_Status__c where dsfs__DocuSign_Recipient_Email__c='ghodasaranatavar2011@gmail.com' limit 1];
            
    }
    public void getdocusignrecords()
    {
      obj_docusignstatus= [select id,dsfs__Sender_Email__c,dsfs__Envelope_Status__c from dsfs__DocuSign_Status__c where dsfs__Sender_Email__c='natavar.goc@gmail.com' limit 1];
    } */
    public class wrapppertax
    {
      public integer quarterno {get;set;}
      public Double Mileages {get;set;}
      public Double Reimbursements {get;set;}
      public Double MaxIRSrate {get;set;}
      public Double ImputedAmount {get;set;}
      public wrapppertax()
      {
        this.quarterno = null; 
        this.Mileages = null; 
        this.Reimbursements =null;
        this.MaxIRSrate = null;
        this.ImputedAmount =null;      
      }
      public wrapppertax(integer quarterno,Double Mileages,Double Reimbursements,Double MaxIRSrate,Double ImputedAmount)
      {
        this.quarterno = quarterno;
        this.Mileages = Mileages;
        this.Reimbursements =Reimbursements;
        this.MaxIRSrate = MaxIRSrate;
        this.ImputedAmount =ImputedAmount;
      }
    }
    public class wrapperTaxReport
    {
      public String drivername {get;set;}
      public String employeeid {get;set;}
      public String emailid {get;set;}
      public Double approvedmileages {get;set;}
      public Double totalreim {get;set;}
      public Double iRSallowable {get;set;}
      public Double imputedincome {get;set;}
      public Integer month {get;set;}
      public String year {get;set;}
      public wrapperTaxReport()
      {

      }
    }
}