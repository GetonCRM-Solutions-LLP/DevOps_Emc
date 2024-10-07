public class UpdateMileageByContactController {
    public List<SelectOption> obj_contact_options                       {get; set;}
    public List<SelectOption> obj_account_options                       {get; set;}
    public List<SelectOption> obj_reimbersments                         {get; set;}
    public List<SelectOption> transfer_obj_reimbersments                {get; set;}
    public String selected_contact_id                                   {get; set;}
    public String selected_account_id                                   {get; set;}
    public String selected_reimbersments                                {get; set;}
    public String transfer_reimbersment                                 {get; set;}
    public Boolean flagtoshow                                           {get; set;}
    public Boolean flagtoshowforToReim                                  {get; set;}
    public Boolean myTablePanelShow                                     {get; set;}
    public Boolean buttonShow                                           {get; set;}
    public List<WrapperMainTable> maintableDataList                     {get; set;}
    public List<Employee_Mileage__c> empList;
    public Integer size;
    public String id, recPerPage;
    private String soql;
    
    public UpdateMileageByContactController() {
        empList = new List<Employee_Mileage__c>();
        myTablePanelShow = false;
        buttonShow = false;
        flagtoshow = false;
        flagtoshowforToReim = false;
        size = 10;
        String pageSize = '2000';
        recPerPage = (pageSize.isNumeric() && Integer.valueOf(pageSize) > 0) ? pageSize : '2000';
        getAccounts();
       // getContacts();
    } 
    
   /* public void getContacts() {
        obj_contact_options = null; 
        obj_contact_options = new List<SelectOption>();
        SelectOption obj_null = new SelectOption('',' -- None -- ');
        obj_contact_options.add(obj_null);
        for(contact obj_current_contact:[SELECT id, FirstName, 
                                            LastName FROM Contact 
                                            WHERE (Role__c = 'Driver' OR Role__c =: StaticValues.roleAdminDriver OR Role__c = 'Manager/Driver') ORDER BY Firstname]) {
            SelectOption obj_current_option = new SelectOption(obj_current_contact.id,obj_current_contact.firstname+' '+obj_current_contact.Lastname);
            obj_contact_options.add(obj_current_option);
        }
    }*/
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
    public void getReimbersments() {
        obj_reimbersments = null;
        obj_reimbersments = new List<SelectOption>();
        String month='';
        if(system.today().month()<10)
        {
            month ='0'+String.valueOf(system.today().month())+'-'+String.valueOf(system.today().year());
        }
        else
        {
            month = String.valueOf(system.today().month())+'-'+String.valueOf(system.today().year());
        }
        if((selected_account_id!=null) && (selected_account_id!='')) {
            // query for Reimbersments
            flagtoshow = true;
            system.debug('flagtoshow--' + true);
            SelectOption obj_null = new SelectOption('',' -- None --');
            obj_reimbersments.add(obj_null);
            for(Employee_Reimbursement__c obj_current_Employee_Reimbursement :[SELECT id, Name, 
                                                                                Approved_Date__c, Status__c,Month__c 
                                                                                FROM Employee_Reimbursement__c 
                                                                                WHERE Contact_Id__r.Accountid =: selected_account_id and Total_Pending__c > 0 and Month__c !=: month]) {
                SelectOption obj_current_option = new SelectOption(obj_current_Employee_Reimbursement.id,obj_current_Employee_Reimbursement.Name);
                obj_reimbersments.add(obj_current_option);
            }
        }
        else if((selected_account_id == null) || (selected_account_id=='')) {
            flagtoshow = false;
        } 
    } 
    
    public String sortDir {
        get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir; }
        set;
    }

    public String sortField {
        get  { if (sortField == null) {sortField = 'Name'; } return sortField; }
        set;
    } 
    
    //fill list
    public List<WrapperMainTable> fillMainDataList() {
        myTablePanelShow = True;
        maintableDataList = new List<WrapperMainTable>();
        Integer count=0;
        id = '';
        String serializeString = '';
        if(Selected_reimbersments != null && Selected_reimbersments != '') {
            soql = 'SELECT id,name,Approved_Date__c ,Rejected__c ,Contact_Email_Id__c,Employee_ID__c,CreatedDate ,LastModifiedDate , Trip_Date__c,Trip_Destination__c,Trip_Origin__c,Trip_Date_Month__c,Trip_Status__c,Fuel_price__c,EmployeeReimbursement__r.Name,EmployeeReimbursement__r.Status__c,EmployeeReimbursement__r.Month__c,EmployeeReimbursement__r.Approved_Date__c,Maintenance_and_Tires__c,Mileage__c,MPG__c FROM Employee_Mileage__c where (EmployeeReimbursement__r.id =: Selected_reimbersments and Trip_Status__c = \'Not Approved Yet\' and Approved_Date__c = null and Rejected__c = false) LIMIT 10001';
        } 
        if(soql != null && soql != '') {
            for(Employee_Mileage__c wrapEmp: (List<Employee_Mileage__c>) Database.Query(soql)) {
                if(count > 1000) {
                    if(id != '') {
                        id = id.substring(0,id.length() -1) + ',';    
                    }
                    serializeString = json.serialize(maintableDataList);
                    id += serializeString.substring(1);
                    count = 0;
                    maintableDataList = new List<WrapperMainTable>();
                }
                WrapperMainTable obj_WrapperMainTable = new WrapperMainTable(false,wrapEmp.id,wrapEmp.name,wrapEmp.EmployeeReimbursement__r.Name,wrapEmp.EmployeeReimbursement__r.Status__c,wrapEmp.Fuel_price__c,wrapEmp.Maintenance_and_Tires__c,wrapEmp.Mileage__c,wrapEmp.MPG__c,wrapEmp.EmployeeReimbursement__r.Approved_Date__c,wrapEmp.Trip_Date__c,wrapEmp.Trip_Destination__c,wrapEmp.Trip_Origin__c);
                obj_WrapperMainTable.mil = wrapEmp;
                count ++;
                maintableDataList.add(obj_WrapperMainTable);   
            }
        }
        return maintableDataList;
    }
    
    public void getMileages() {
        flagtoshowforToReim = false;
        buttonShow = false;
        fillMainDataList();
    }
    
    public PageReference getIsPRSelected() {
        if(maintableDataList.size() > 0) {
            for(WrapperMainTable obj_WrapperMainTable : maintableDataList) {   
                if(obj_WrapperMainTable.isPRSelected == true) {
                    flagtoshowforToReim = true;
                    buttonShow = true; 
                    empList.add(obj_WrapperMainTable.mil);
                }
            }   
        }
        if(empList.size()==0) {
            flagtoshowforToReim = false;
            buttonShow = false;  
        }
        transfer_obj_reimbersments = null;
        transfer_obj_reimbersments = new List<SelectOption>();
        if((Selected_reimbersments!=null) && (Selected_reimbersments!='')) {
            // query for Reimbersments
            SelectOption transfer_obj_null = new SelectOption('',' -- None --');
            transfer_obj_reimbersments.add(transfer_obj_null);
            Employee_Reimbursement__c empReim = [SELECT id, Month__c,Contact_Id__c FROM Employee_Reimbursement__c WHERE id =: Selected_reimbersments LIMIT 1];
            String[] monthYear = empReim.Month__c.split('-');
            for(Employee_Reimbursement__c obj_current_Emp_Reim : [SELECT id, Name, 
                                                                    Approved_Date__c, Status__c, 
                                                                    Month__c FROM Employee_Reimbursement__c 
                                                                    WHERE Contact_Id__c =: empReim.Contact_Id__c]) {   
                String[] month_year = obj_current_Emp_Reim.Month__c.split('-');
                if(Integer.valueof(month_year[1]) > Integer.valueof(monthYear[1])) {
                    SelectOption transfer_obj_current = new SelectOption(obj_current_Emp_Reim.id, obj_current_Emp_Reim.Name);
                    transfer_obj_reimbersments.add(transfer_obj_current);
                } else if(Integer.valueof(month_year[1]) == Integer.valueof(monthYear[1])) {
                    if(Integer.valueof(month_year[0]) > Integer.valueof(monthYear[0])) {
                        SelectOption transfer_obj_current = new SelectOption(obj_current_Emp_Reim.id, obj_current_Emp_Reim.Name);
                        transfer_obj_reimbersments.add(transfer_obj_current);
                    }
                }
            }
        }
        return null; 
    }

    //Update
    public void updateMileage() {
        if(Transfer_reimbersment != null && Transfer_reimbersment != '') {
            List<Employee_Mileage__c> updatedMileageList = new List<Employee_Mileage__c>();
            for(WrapperMainTable wrp : maintableDataList) {
                if(wrp.isPRSelected == true) {
                    Employee_Mileage__c empMileage = wrp.mil;
                    empMileage.EmployeeReimbursement__c = Transfer_reimbersment;
                    updatedMileageList.add(empMileage);
                }
            }
            update updatedMileageList;
            getMileages();
        }
    }
   public class WrapReimbursement
   {
       public WrapReimbursement()
       {
           
       }
       public String Id {get; set;}
       public String contactFirstName {get; set;}
       public String contactLastName {get; set;}
       public String Name {get; set;}
       public String Month {get; set;}
       public Integer monthNo {get; set;}
       public Integer monthYear {get; set;}
   }
    // Wrapper Class
    public class WrapperMainTable {
        public boolean isPRSelected                     {get; set;}
        public Employee_Mileage__c mil                  {get; set;}
        public String Id                                {get; set;}
        public String employeeName                      {get; set;}
        public String reimbursementStatus               {get; set;}
        public String name                              {get; set;}
        public Decimal fuelPrice                        {get; set;}
        public Decimal maintenanceAndTires              {get; set;}
        public Decimal mileage                          {get; set;}
        public Decimal MPG                              {get; set;}
        public Date approvedDate                        {get; set;}
        public Date tripDate                            {get; set;}
        public String tripDestination                   {get; set;}
        public String tripOrigin                        {get; set;}
        public WrapperMainTable(Boolean isSelected, String Id, 
                                    String name, String employeeName,String reimbursementStatus,
                                    Decimal fuelPrice, Decimal maintenanceAndTires, 
                                    Decimal mileage, Decimal MPG, Date approvedDate, Date tripDate,String tripDestination,String tripOrigin) {
            this.isPRSelected = isSelected;
            this.mil = mil;
            this.id = id;
            this.name = name;
            this.employeeName = employeeName;
            this.reimbursementStatus = reimbursementStatus;
            this.fuelPrice = fuelPrice;
            this.maintenanceAndTires = maintenanceAndTires;
            this.mileage = mileage;
            this.MPG = MPG;
            this.approvedDate = approvedDate;
            this.tripDate = tripDate;
            this.tripDestination = tripDestination;
            this.tripOrigin = tripOrigin;
            
        }
    }
}