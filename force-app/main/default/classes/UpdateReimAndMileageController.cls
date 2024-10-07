public class UpdateReimAndMileageController 
{
    public List<SelectOption> obj_contact_options {get;set;}
    public List<SelectOption> obj_account_options                       {get; set;}
    public String selected_account_id                                   {get; set;}
    public String Selected_contact_id {get;set;}
    public Boolean flagtoshow{get;set;}
    public Boolean contactflagtoshow{get;set;}
    public Boolean flagtoshowdetails{get;set;}
    public List<SelectOption> obj_reimbersments{get;set;}
    public String Selected_reimbersments {get;set;}
    public Map<String,Employee_Reimbursement__c> obj_reimbersment_map {get;set;}
    public Date selectedApprovedDate {get;set;}
    public List<SelectOption> obj_reimbersments_status {get;set;}
    public String Status {get;set;}
    public Boolean flagforerror {get;set;}
    public Boolean flagforsuccess {get;set;}
    public String errormsg {get;set;}
    
    
    public String Selectedcontactid_mileages {get;set;}
    public String Selectedaccountid_mileages {get;set;}
    public Boolean flagtoshow_mileages{get;set;}  
    public Boolean flagtoshow_contact_mileages{get;set;}  
    public Boolean flagtoshowdetails_mileages{get;set;}
    public String Selected_reimbersments_mileages {get;set;}
    public Boolean flagforerror_mileages {get;set;}
    public Boolean flagforsuccess_mileages {get;set;}
    public String errormsg_mileages {get;set;}
    public Map<String,Employee_Reimbursement__c> obj_reimbersments_map {get;set;}
    public List<SelectOption> obj_contact_mileages{get;set;}
    public List<SelectOption> obj_reimbersments_mileages{get;set;}
    public Map<String,List<Employee_Mileage__c>> obj_Employee_Mileage_map {get;set;}
    public List<Employee_Mileage__c> obj_mileage_to_update{get;set;}
    public List<SelectOption> obj_trip_status {get;set;}
    public String selectedTripStatus {get;set;}
    public Date selectedmileageApprovedDate {get;set;}
    public String selectedmileagempg {get;set;}
    public String selectedmileagetiers {get;set;}
    public boolean showModal {get; set;}     
    
    public UpdateReimAndMileageController() 
    {
        showModal = false;
        flagforerror = false;
        flagtoshow = false;
        flagtoshowdetails=false;
        flagforsuccess = false;
        contactflagtoshow = false;
        flagtoshow_mileages = false;
        flagtoshowdetails_mileages = false;
        flagforerror_mileages = false;
        flagforsuccess_mileages = false; 
        flagtoshow_contact_mileages = false;
        getAccounts();
        
    }
    public void getAccounts()
    {
        obj_account_options = null; 
        obj_account_options = new List<SelectOption>();
        SelectOption obj_null = new SelectOption('',' -- None -- ');
        obj_account_options.add(obj_null);
        for(Account currentAccount : [Select id,Name from Account where isUsingTriplog__c= true])
        {
            SelectOption obj_current_option = new SelectOption(currentAccount.id,currentAccount.Name);
            obj_account_options.add(obj_current_option);
        }
        System.debug(obj_account_options);                       
    }
    /*public void closePopup() {        
        displayPopup = false;    
    } */
    
    public void getContacts()
    {
        flagtoshow = false;
       obj_contact_options = null; 
       obj_contact_options = new List<SelectOption>();
       SelectOption obj_null = new SelectOption('','None');
       obj_contact_options.add(obj_null);
       if(selected_account_id!=null)
       {
            

            flagtoshowdetails = false;
           flagtoshow = true;
           contactflagtoshow= true;
           flagforerror = false;
           flagforsuccess= false;
            for(contact obj_current_contact:[SELECT id,FirstName,LastName FROM Contact WHERE (Role__c = 'Driver' OR Role__c =: StaticValues.roleAdminDriver OR Role__c = 'Manager/Driver') and Account.id=:selected_account_id ORDER BY FirstName])
            {
                SelectOption obj_current_option = new SelectOption(obj_current_contact.id,obj_current_contact.FirstName+' '+obj_current_contact.LastName);
                obj_contact_options.add(obj_current_option);
            }
       }
       else
       {
            contactflagtoshow = false;
            flagtoshow = false;
            flagtoshowdetails = false;
       }
    }
    public void getReimbersments()
    {
        
        // reimbersment
        obj_reimbersments = null;
        obj_reimbersments = new List<SelectOption>();
        obj_reimbersment_map = new Map<String,Employee_Reimbursement__c>();
        if((Selected_contact_id!=null)&&(Selected_contact_id!=''))
        {
            // query for Reimbersments
           flagtoshowdetails = false;
           flagtoshow = true;
           contactflagtoshow= true;
           flagforerror = false;
           flagforsuccess= false;
           SelectOption obj_null = new SelectOption('','None');
           obj_reimbersments.add(obj_null);
           for(Employee_Reimbursement__c obj_current_Employee_Reimbursement :[SELECT id,Name,Approved_Date__c,Status__c FROM Employee_Reimbursement__c WHERE Contact_Id__c =: Selected_contact_id])
           {
               SelectOption obj_current_option = new SelectOption(obj_current_Employee_Reimbursement.id,obj_current_Employee_Reimbursement.Name);
               obj_reimbersments.add(obj_current_option);
               obj_reimbersment_map.put(obj_current_Employee_Reimbursement.id,obj_current_Employee_Reimbursement);
               
           }
           getStatus(); 
        }
        else if((Selected_contact_id==null)||(Selected_contact_id==''))
        {
            // show error Message                
            flagtoshow = false;
            contactflagtoshow = true;
            flagtoshowdetails = false;
        } 
        
    }
    public void getReimbersmentDetails()
    {
        
        if((Selected_reimbersments!=null)&&(Selected_reimbersments!=''))
        {
            flagforerror = false;
            flagforsuccess= false;
            flagtoshowdetails=true;
            if(obj_reimbersment_map.containsKey(Selected_reimbersments))
            {
                
                if(obj_reimbersment_map.get(Selected_reimbersments).Approved_Date__c==null)
                {
                    selectedApprovedDate = null;
                }
                else
                {
                    selectedApprovedDate = obj_reimbersment_map.get(Selected_reimbersments).Approved_Date__c;
                }
                if(obj_reimbersment_map.get(Selected_reimbersments).Status__c==null)
                {
                    Status =null;
                }
                else
                {
                    Status =obj_reimbersment_map.get(Selected_reimbersments).Status__c;                    
                }               
            }
            
        }
        else if((Selected_reimbersments==null)||(Selected_reimbersments==''))
        {
            flagtoshowdetails=false;
        }
    }
    public void getStatus()
    {
        obj_reimbersments_status = new List<SelectOption>();
        SelectOption obj_null = new SelectOption('','None');
        obj_reimbersments_status.add(obj_null);
        Schema.DescribeFieldResult fieldResult = Employee_Reimbursement__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            obj_reimbersments_status.add(new SelectOption(f.getLabel(), f.getValue()));
        }
    }
    public void updateReimbersment()
    {
        if((Selected_contact_id!=null)&&(Selected_contact_id!='')&&(Selected_reimbersments!=null)&&(Selected_reimbersments!='')&&(obj_reimbersment_map.containsKey(Selected_reimbersments)))
        {  
           //showModal = True;   
           Employee_Reimbursement__c obj_Employee_Reimbursement_toupdate = obj_reimbersment_map.get(Selected_reimbersments);
           obj_Employee_Reimbursement_toupdate.Approved_Date__c = selectedApprovedDate;
           obj_Employee_Reimbursement_toupdate.Status__c = Status;
           update obj_Employee_Reimbursement_toupdate;
           
           flagforerror = false;
           flagforsuccess = true;
           errormsg =obj_Employee_Reimbursement_toupdate.name;
        }
        else
        {
            // add message please select reimbersments
            //showModal = false;
            flagforerror = true;
            flagforsuccess = false;
            errormsg ='Please Select Contact and Reimbersment !!';
        }
    }
    public void getReimbersmentsmileages()
    {
        
        // reimbersment
        obj_reimbersments_mileages = null;
        obj_reimbersments_mileages= new List<SelectOption>();
        obj_reimbersments_map = null;
        obj_reimbersments_map = new Map<String,Employee_Reimbursement__c>();
        
        obj_Employee_Mileage_map  = null;
        obj_Employee_Mileage_map = new Map<String,List<Employee_Mileage__c>>();
        
        if((Selectedcontactid_mileages!=null)&&(Selectedcontactid_mileages!=''))
        {
            // query for Reimbersments
           flagtoshow_mileages = true;
           flagforerror_mileages = false;
           flagforsuccess_mileages = false;
           flagtoshowdetails_mileages = false; 
           SelectOption obj_null = new SelectOption('','None');
           obj_reimbersments_mileages.add(obj_null);
           for(Employee_Reimbursement__c obj_current_Employee_Reimbursement :[SELECT id,Name,Maintenance_and_Tires__c,MPG__c,Approved_Date__c,Status__c,(SELECT id,EmployeeReimbursement__c,Maintenance_and_Tires__c,Approved_Date__c,MPG__c,Rejected__c FROM Employees_Mileage__r) FROM Employee_Reimbursement__c WHERE Contact_Id__c=:Selectedcontactid_mileages])
           {
               SelectOption obj_current_option = new SelectOption(obj_current_Employee_Reimbursement.id,obj_current_Employee_Reimbursement.Name);
               obj_reimbersments_mileages.add(obj_current_option);
               obj_reimbersments_map.put(obj_current_Employee_Reimbursement.id,obj_current_Employee_Reimbursement);
               for(Employee_Mileage__c obj_current_mileage:obj_current_Employee_Reimbursement.Employees_Mileage__r)
               {
                   if(obj_Employee_Mileage_map.containsKey(obj_current_Employee_Reimbursement.id))
                   {
                       obj_Employee_Mileage_map.get(obj_current_Employee_Reimbursement.id).add(obj_current_mileage);
                   }
                   else
                   {
                       List<Employee_Mileage__c> obj_temp_mileage_list = new List<Employee_Mileage__c>();
                       obj_temp_mileage_list.add(obj_current_mileage);
                       obj_Employee_Mileage_map.put(obj_current_Employee_Reimbursement.id,obj_temp_mileage_list);
                   }
                  
               }
           }
           getTripStatus(); 
        }
        else if((Selectedcontactid_mileages==null)||(Selectedcontactid_mileages==''))
        {
            // show error Message                
            flagtoshow_mileages = false;
        } 
        
    }
    public void showDetailofMileages()
    {
        
        if((Selected_reimbersments_mileages!=null)&&(Selected_reimbersments_mileages!=''))
        {            
            if(!obj_Employee_Mileage_map.containsKey(Selected_reimbersments_mileages))
            {
               flagtoshowdetails_mileages = false;
               selectedmileagempg = null;
               selectedmileagetiers= null;
               selectedTripStatus = null;
               selectedmileageApprovedDate = null;
                // add error msg No Mileages to Update
                
                flagforerror_mileages = true;
                errormsg_mileages ='No Mileages Found for this Reimbersment !!';
                flagforsuccess_mileages = false;
            }
            else
            {
                flagforerror_mileages = false;
                flagtoshowdetails_mileages = true;
                selectedmileagempg = String.valueOf(obj_reimbersments_map.get(Selected_reimbersments_mileages).MPG__c);
                selectedmileagetiers = String.valueOf(obj_reimbersments_map.get(Selected_reimbersments_mileages).Maintenance_and_Tires__c);
            }            
        }
        else
        {
            flagtoshowdetails_mileages = false;
        }
    }
    public void getTripStatus()
    {
        obj_trip_status = new List<SelectOption>();
        
        SelectOption obj_null = new SelectOption('','None');
        obj_trip_status.add(obj_null);
        Schema.DescribeFieldResult fieldResult = Employee_Mileage__c.Trip_Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            obj_trip_status.add(new SelectOption(f.getLabel(), f.getValue()));
        }
            
        
    }
    public void updatemileages()
    {
       if(((Selected_reimbersments_mileages!=null)&&(Selected_reimbersments_mileages!=''))&&(obj_Employee_Mileage_map.containsKey(Selected_reimbersments_mileages)))
        {
            flagforerror_mileages = false;
            flagforsuccess_mileages = false;
            obj_mileage_to_update = null;
            obj_mileage_to_update = new List<Employee_Mileage__c>();
            for(Employee_Mileage__c obj_current_mileage:obj_Employee_Mileage_map.get(Selected_reimbersments_mileages))
            {
                if(selectedTripStatus != null){
                    obj_current_mileage.Trip_Status__c = selectedTripStatus;
                    if(selectedTripStatus == 'Not Approved Yet'){
                        obj_current_mileage.Rejected__c = false ;
                        obj_current_mileage.Approved_Date__c = null ;
                    }
                    else if(selectedTripStatus == 'Rejected'){
                        obj_current_mileage.Rejected__c = true ;
                    }
                    else if(selectedTripStatus == 'Approved'){
                        obj_current_mileage.Rejected__c = false ;
                    }
                }
                else{
                    obj_current_mileage.Trip_Status__c = null;
                    //displayPopup = true;
                }
                
                if(selectedmileageApprovedDate != null){
                    obj_current_mileage.Approved_Date__c =selectedmileageApprovedDate;
                }
                // else{
                //     obj_current_mileage.Approved_Date__c = null;
                // }

                if(selectedmileagempg != null && selectedmileagempg != '') 
                { 
                    obj_current_mileage.MPG__c = Double.valueOf(selectedmileagempg);
                }
                else
                {
                    obj_current_mileage.MPG__c = null;
                    //displayPopup = true;
                    //system.debug('displayPopup-----' + displayPopup);
                    
                }
                if(selectedmileagetiers != null && selectedmileagetiers != '') 
                { 
                    obj_current_mileage.Maintenance_and_Tires__c = Double.valueOf(selectedmileagetiers);
                }
                else
                {
                    obj_current_mileage.Maintenance_and_Tires__c = Null;
                    //displayPopup = true;
                }
                obj_mileage_to_update.add(obj_current_mileage);
            }  
        }
        else if((Selected_reimbersments_mileages==null)||(Selected_reimbersments_mileages==''))
        {
            // add error please select Reimbersment
            errormsg_mileages ='Please Select Reimbersment !!';
            flagforerror_mileages = true;
            flagforsuccess_mileages = false;
        }
        else
        {
            // No mileages found
            flagforerror_mileages = true;
            errormsg_mileages ='No Mileages Found for this Reimbersment !!';
            flagforsuccess_mileages = false;
        }
        if(obj_mileage_to_update!=null)
        {
            flagforerror_mileages = false;
            flagforsuccess_mileages = true;
            errormsg_mileages = obj_reimbersments_map.get(Selected_reimbersments_mileages).name;
            update obj_mileage_to_update;
        }
    }
    public void getContactsMileages()
    {
        
        obj_contact_mileages = null; 
        obj_contact_mileages = new List<SelectOption>();
       SelectOption obj_null = new SelectOption('','None');
       obj_contact_mileages.add(obj_null);
        flagtoshow_mileages = false;
        flagforerror_mileages = false;
        flagforsuccess_mileages = false;
        flagtoshowdetails_mileages = false;
        flagtoshow_contact_mileages = true; 
       if(Selectedaccountid_mileages!=null)
       {
            for(contact obj_current_contact:[SELECT id,FirstName,LastName FROM Contact WHERE (Role__c = 'Driver' OR Role__c =: StaticValues.roleAdminDriver OR Role__c = 'Manager/Driver') and Account.id=:Selectedaccountid_mileages ORDER BY FirstName])
            {
                SelectOption obj_current_option = new SelectOption(obj_current_contact.id,obj_current_contact.FirstName+' '+obj_current_contact.LastName);
                obj_contact_mileages.add(obj_current_option);
            }
       }
       else
       {
            flagtoshow_contact_mileages = false; 
       }
    }
    public void cancelall()
    {
        flagtoshow=false;
        flagtoshowdetails=false;
        flagforerror =false;
        flagforsuccess =false;
        errormsg ='';
        flagtoshow_mileages=false;
        flagtoshowdetails_mileages=false;        
        flagforerror_mileages =false;
        flagforsuccess_mileages=false;
        flagtoshow_contact_mileages = false;

        Selected_contact_id=null;
        Selected_reimbersments=null;
        Selectedcontactid_mileages=null;
        Selected_reimbersments_mileages = null;
        
    }
}