public class RG_UnApprovedRecordsByNameClass {

    public list<RembWrap> wraplist{get;set;}
    public boolean isSuperManager{get;set;}
    public boolean isSuperManagerDriver{get;set;}
    public id conid{get;set;}
    public boolean EnableReports{get;set;}
    public Boolean isCurrentMonth {get;set;}
    public String message         {get;set;}

    public RG_UnApprovedRecordsByNameClass() {
        set<id> conidlist = new set<id>(); 
        wraplist = new list<RembWrap>();  
        Id coid = ApexPages.currentPage().getParameters().get('p');
        //   System.debug('coid-test============'+coid);

        User user= [SELECT Id,Name,Profile.Name,ContactId,Contact.Account.Lock_date__c FROM USER WHERE Id=:Userinfo.GetUserId()];
        /*Date currentDate = System.today();
        isCurrentMonth = dateChecker(currentDate,user.Contact.Account.Lock_date__c);*/
        isCurrentMonth = false;
        if(user.profile.name=='Customer Community Login User - Super Manager') isSuperManager=true;

        if(user.profile.name=='Customer Community Login User - Super Manager/Driver'){
            isSuperManagerDriver=true;
            conid=user.contactid;
        }                       
        if(user.contactid!=null) 
            EnableReports = [select Enable_Reports__c from Contact where Id=:user.contactid].Enable_Reports__c;

        List<Gas_Prices__c> gasprice = new list<Gas_Prices__c>();
        for (Gas_Prices__c gp:[select id,Fuel_Price__c,Month_Year__c,State__c,City__c from Gas_Prices__c  ]) {
            gasprice.add(gp);
        }

        //emilist=[select id,Reason_for_Rejection__c,Approved_Date__c,EmployeeReimbursement__r.Month__c,EmployeeReimbursement__r.Approved_Date__c, Name,Mileage__c,Trip_Date__c,Trip_Destination__c,Trip_Origin__c,Rejected__c from Employee_Mileage__c];
        List<Employee_Reimbursement__c> remblist = new List<Employee_Reimbursement__c>();
        for (Employee_Reimbursement__c er:[SELECT Variable_Rate__c,Contact_Id__r.account.Show_Hide_Historical_Allowance__c, Fixed_Amount__c,Contact_Id__r.account.Logo_Document_Id__c, 
                                                    Total_Monthly_Approved_Variable__c,Monthly_Total_Reimbursement__c, Monthly_Variable_Amount__c,id,Name,Maintenance_and_Tires__c,Status__c,MPG__c,Fuel_Variable_Rate__c,
                                                    Total_Monthly_Upapproved_Variable__c,Total_Monthly_Reimbursement__c,Contact_Id__r.Car_Image__c,Contact_Id__r.MailingStreet,Contact_Id__r.Pre_Auto_Allowance_Amount__c,Contact_Id__r.compliancestatus__c,
                                                    Total_Monthly_Unapproved_Reimbursement__c,Contact_Id__r.Vehicle_Type__c,Contact_Id__r.Vehicle2Odometer__c,Contact_Id__r.Vehicle1Odometer__c,Contact_Id__r.MailingCountry,
                                                    Contact_Id__r.MailingPostalCode,Contact_Id__r.MailingCity,Contact_Id__r.MailingState,Contact_Id__r.Monthly_Fuel_Price__c,Month__c,
                                                    Contact_Id__r.manager__r.Name,Fuel_Price__c,Contact_Id__c,Contact_Id__r.Fixed_Amount__c,Contact_Id__r.Name,
                                                    Contact_Id__r.Monthly_Mileage_Limit__c,Approved_Date__c,Contact_Id__r.Account.Lock_date__c from Employee_Reimbursement__c 
                                                    WHERE Approved_Date__c=:null AND Contact_Id__c=:coid ORDER BY Month_Field__c DESC]) 
        {
            remblist.add(er);
        }
        
        map<id,List<Employee_Mileage__c>> reimbursementIdToMileageListMap = new map<id,List<Employee_Mileage__c>>();
       /* for (Employee_Mileage__c em:[SELECT Trip_Date__c,id,Reason_for_Rejection__c,EmployeeReimbursement__r.Contact_Id__c,
                                            Variable__c,Maintenance_and_Tires__c,MPG__c,Fuel_price__c,CreatedDate,Approved_Date__c, EmployeeReimbursement__r.Contact_Id__r.MPG__c,EmployeeReimbursement__r.Contact_Id__r.Maintenance_and_Tires__c, 
                                            Name,EmployeeReimbursement__r.Contact_Id__r.MailingState,EmployeeReimbursement__r.Contact_Id__r.MailingCity,Mileage__c,Trip_Destination__c,
                                            Trip_Origin__c,Rejected__c,Carry_Forward_Mileage__c FROM Employee_Mileage__c where Approved_Date__c=:null AND Rejected__c!=true AND EmployeeReimbursement__c IN :remblist]) */
         for (Employee_Mileage__c em:[SELECT Trip_Date__c,id,Reason_for_Rejection__c,EmployeeReimbursement__r.Contact_Id__c,
                                            Variable__c,Maintenance_and_Tires__c,MPG__c,Fuel_price__c,CreatedDate,Approved_Date__c, EmployeeReimbursement__r.Contact_Id__r.MPG__c,EmployeeReimbursement__r.Contact_Id__r.Maintenance_and_Tires__c, 
                                            Name,EmployeeReimbursement__r.Contact_Id__r.MailingState,EmployeeReimbursement__r.Contact_Id__r.MailingCity,Mileage__c,Trip_Destination__c,
                                            Trip_Origin__c,Rejected__c,Carry_Forward_Mileage__c FROM Employee_Mileage__c where Approved_Date__c=:null AND EmployeeReimbursement__c IN :remblist]) 
        {
            List<Employee_Mileage__c> templist = new List<Employee_Mileage__c>();

            if(reimbursementIdToMileageListMap.containsKey(em.EmployeeReimbursement__c))
                templist = reimbursementIdToMileageListMap.get(em.EmployeeReimbursement__c);

            templist.add(em);

            if (em.EmployeeReimbursement__c != NULL)
                reimbursementIdToMileageListMap.put(em.EmployeeReimbursement__c,templist);
        }

        // from above query    
        list<AuditTrail__c> auditTrail= new list<AuditTrail__c>();
        for (AuditTrail__c at:[SELECT id,Contact__c,Field__c,NewValue__c,OldValue__c,Timestamp__c,Modifiedby__c from AuditTrail__c where Contact__c =:coid order by Timestamp__c DESC]) 
        {
            auditTrail.add(at);
        }

        for(Employee_Reimbursement__c r:remblist)
        {
            wraplist.add(new RembWrap(r,reimbursementIdToMileageListMap.get(r.id),gasprice,auditTrail));
        }

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

    public void updateByMonth(){
        List<Employee_Reimbursement__c> templist = new List<Employee_Reimbursement__c>();
        List<Employee_Mileage__c> mlist=new List<Employee_Mileage__c>();
        Map<Integer,List<Employee_Mileage__c>> getMapMileages;
        List<RembWrap> tempRemWrapList = new List<RembWrap>();
        
        for(RembWrap rWrapper : wraplist) 
        {
            getMapMileages = new Map<Integer,List<Employee_Mileage__c>>();
            getMapMileages = getMileages(rWrapper.isSelected,rWrapper.mlist,isCurrentMonth);
            Set<Integer> fianlValue = getMapMileages.keySet();
            List<Integer> listInt = new List<Integer>(fianlValue);
            if(listInt[0] > 0) {

                if(rWrapper.isSelected || rWrapper.mlist.size() == listInt[0])
                {
                    rWrapper.remb.Status__c = 'Approved';
                    rWrapper.remb.Approved_Date__c = Date.today();
                    templist.add(rWrapper.remb);
                } else {
                    RembWrap tempwrap = rWrapper;
                    system.debug('before ' +rWrapper.mlist.size());
                    tempwrap.mlist = getunSelectedmileages(rWrapper.mlist);
                    system.debug(tempwrap);
                    system.debug('after ' + tempwrap.mlist.size());
                    tempRemWrapList.add(tempwrap);
                }
                mlist.addAll(getMapMileages.get(listInt[0]));



            } else {
                mlist.addAll(getMapMileages.get(listInt[0]));
                tempRemWrapList.add(rWrapper);
            }
            /*for(Integer totalApprove : getMapMileages.keySet()) {

                for(Employee_Mileage__c singleMilage : getMapMileages.get(totalApprove)) {

                }
                }*/
                /*if(fianlValue[0] > 0) {

                }*/
                /*if(rWrapper.isSelected == true) {
                    rWrapper.remb.Status__c = 'Approved';
                    rWrapper.remb.Approved_Date__c = Date.today();
                    for(MileWrap mWrapper : rWrapper.mlist) {
                    mWrapper.mil.Trip_Status__c = 'Approved';
                    mWrapper.mil.Approved_Date__c = Date.today();
                    mWrapper.mil.Rejected__c = false;
                }
                } else {
                    Integer count = 0;
                    for(MileWrap mileageWrapper : rWrapper.mlist) {
                    if(mileageWrapper.isApproved == true) {
                    mileageWrapper.mil.Trip_Status__c = 'Approved';
                    mileageWrapper.mil.Approved_Date__c = Date.today();
                    mileageWrapper.mil.Rejected__c = false;   
                    count++;
                }else {
                    mileageWrapper.mil.Trip_Status__c = 'Rejected';
                    mileageWrapper.mil.Rejected__c = true;
                }
                }
                if(count>0){
                    rWrapper.remb.Status__c = 'Approved';
                    rWrapper.remb.Approved_Date__c = Date.today();
                }
            }  */

        }

        /*for(RembWrap w:wraplist){
            boolean bo=false;
            for(MileWrap w2:w.mlist){
                if(w2.boo)
                bo=true;
            }

            if(w.b) {
                w.remb.Status__c='Approved';
                W.remb.Approved_Date__c=date.today(); 
            }

            for(MileWrap w2:w.mlist){
                if(w2.boo){
                    w.remb.Status__c='Approved';
                    W.remb.Approved_Date__c=date.today();
                    w2.mil.Approved_Date__c=date.today();
                    w2.mil.Trip_Status__c = 'Rejected';
                    w2.mil.Rejected__c=true;
                    mlist.add(w2.mil);
                }       
                else if(bo&&!w2.boo){ 
                    w.remb.Status__c='Approved';
                    w.remb.Approved_Date__c=date.today();
                    w2.mil.Approved_Date__c=date.today();
                    w2.mil.Trip_Status__c = 'Approved';
                    w2.mil.Rejected__c=false;
                    mlist.add(w2.mil);
                } else if(w.b){
                    w.remb.Status__c='Approved';
                    w.remb.Approved_Date__c=date.today();
                    w2.mil.Approved_Date__c=date.today();
                    w2.mil.Trip_Status__c = 'Approved';
                    w2.mil.Rejected__c=false;
                    mlist.add(w2.mil);
                }
            }
            w.b=false;
            templist.add(w.remb);

        }*/

        // Create a savepoint
        Savepoint sp = Database.setSavepoint();
        List<sObject> records = new List<sObject>();
        try{

            if(!templist.isEmpty()){
                //update templist;
                //for(Employee_Reimbursement__c er:templist){
                records.addAll((List<sObject>)(templist));
                //}
            }
            if(!mlist.isEmpty()){
                //update mlist;
                //for(Employee_Mileage__c em:mlist){
                records.addAll((List<sObject>)(mlist));
                //}
            }
            if(!records.isEmpty() && (records.size() > 10000)) {
                processRecords process = new processRecords(records);
                Database.executeBatch(process,200);
                wraplist = tempRemWrapList;
            }else if(!records.isEmpty() && (records.size() < 10000)) {
                system.debug(records);
                update records;
                message = System.Label.UnApproved_Page_Message;
                wraplist = tempRemWrapList;

            }else if(records.isEmpty()) {
                message = 'Please Select Record';
            }
        }catch(Exception e)
        {
            System.debug('Exception -->' + e);
            // Rollback to the previous null value
            message = e.getMessage();
            Database.rollback(sp);
        }

        //return null;//new PageReference('/apex/RG_UnApprovedRecords?un=ap');

    }

    public static Map<Integer, List<Employee_Mileage__c>> getMileages(Boolean isReimbursement,List<MileWrap> milageWrappers,Boolean isCurrent) {
        Map<Integer, List<Employee_Mileage__c>> mapMileage = new Map<Integer, List<Employee_Mileage__c>>();
        Integer count = 0;
        List<Employee_Mileage__c> addMileage = new List<Employee_Mileage__c>();
        //System.debug('isReimbursement:'+isReimbursement);
        //System.debug('milageWrappers:'+milageWrappers);
        for(MileWrap milageWrapper : milageWrappers) {
            if(isReimbursement == true) {
                milageWrapper.mil.Trip_Status__c = 'Approved';
                milageWrapper.mil.Approved_Date__c = Date.today();
                milageWrapper.mil.Rejected__c = false;
                milageWrapper.mil.Carry_Forward_Mileage__c = isCurrent;
                count++;
                addMileage.add(milageWrapper.mil);
            }else{
                if(milageWrapper.isApproved == true) {
                    milageWrapper.mil.Trip_Status__c = 'Approved';
                    milageWrapper.mil.Approved_Date__c = Date.today();
                    milageWrapper.mil.Rejected__c = false;
                    milageWrapper.mil.Carry_Forward_Mileage__c = isCurrent;
                    count++;
                    addMileage.add(milageWrapper.mil);
                }else if(milageWrapper.isRejected == true){
                    milageWrapper.mil.Trip_Status__c = 'Rejected';
                    milageWrapper.mil.Rejected__c = true;
                    milageWrapper.mil.Approved_Date__c = null;
                    milageWrapper.mil.Carry_Forward_Mileage__c = isCurrent;
                    addMileage.add(milageWrapper.mil);
                }
            }
        }
        mapMileage.put(count,addMileage);
        //System.debug('mapMileage:'+mapMileage);
        return mapMileage;
    }

    public List<MileWrap> getunSelectedmileages(List<MileWrap> milageWrappers)
    {
        List<MileWrap> unselectedMileage = new List<MileWrap>();
        for(MileWrap milageWrapper : milageWrappers) {
            
            if(!milageWrapper.isApproved){
                unselectedMileage.add(milageWrapper);
            }
        }

        return unselectedMileage;
    }

    public class RembWrap{
        public Employee_Reimbursement__c remb {get;set;}
        public boolean isSelected{get;set;}
        public Boolean isEditable {get; set;}
        public String month{get;set;}
        public decimal Variable{get;set;}
        public decimal submil{get;set;}
        public list<MileWrap> mlist{get;set;}
        public decimal VariableReimbursement{get;set;}
        public decimal TotalReimbursement{get;set;}
        public RembWrap(Employee_Reimbursement__c remb, list<Employee_Mileage__c> mlist,list<Gas_Prices__c> gas,list<AuditTrail__c> AuditTrail){
            string mon='';
            if(remb.Month__c!=null)
                mon=remb.Month__c.left(2);
            
            this.month=(mon=='1-')?'January':(mon=='2-')?'February':(mon=='3-')?'March':(mon=='4-')?'April':(mon=='5-')?'May':(mon=='6-')?'June':
            (mon=='7-')?'July':(mon=='8-')?'August':(mon=='9-')?'September':(mon=='01')?'January':(mon=='02')?'February':(mon=='03')?'March':(mon=='04')?'April':(mon=='05')?'May':(mon=='06')?'June':
            (mon=='07')?'July':(mon=='08')?'August':(mon=='09')?'September':(mon=='10')?'October':(mon=='11')?'November':(mon=='12')?'December':'Invalid Month';         
            this.submil=0;
            //this.remb=new Employee_Reimbursement__c();
            this.isSelected=false;
            this.mlist= new list<MileWrap>();
            this.remb=remb;
            if(mlist!=null && !mlist.isEmpty())
                for(Employee_Mileage__c m:mlist){
                    this.mlist.add(new MileWrap(m,AuditTrail,gas));
                    if(m.mileage__c!=null)
                        this.submil+=m.mileage__c;
                    if(remb.Status__c == 'Approved' && remb.Approved_Date__c != null) {
                        System.debug('remb.Status__c:'+remb.Status__c);
                        System.debug('remb.Approved_Date__c:'+remb.Approved_Date__c);
                        this.isEditable = true;
                    }else {
                        System.debug('remb.Status__c:'+remb.Status__c);
                        System.debug('remb.Approved_Date__c:'+remb.Approved_Date__c);
                        this.isEditable = false;
                    }
                }
            
            decimal fuelrate; 

            /*
            for(Gas_Prices__c g:gas){
            if(g.State__c==remb.Contact_Id__r.MailingState&&mon==string.valueof(g.Month_Year__c.month())&&g.City__c==remb.Contact_Id__r.MailingCity&&g.Fuel_Price__c!=null&&remb.MPG__c!=null)
            fuelrate=(g.Fuel_Price__c/remb.MPG__c).setScale(2);
            }

            */

            fuelrate= remb.Fuel_Variable_Rate__c!=null?remb.Fuel_Variable_Rate__c.setScale(4):0.0;
            if(fuelrate!=null&&remb.Maintenance_and_Tires__c!=null)
                this.variable=(fuelrate+remb.Maintenance_and_Tires__c).setScale(4);

            // if(variable!=null)    
            //this.VariableReimbursement=(variable*submil).setScale(2);
            this.VariableReimbursement = remb.Total_Monthly_Upapproved_Variable__c;

            //if(VariableReimbursement!=null&&submil!=null&&remb.Contact_Id__r.Fixed_Amount__c!=null)
            // this.TotalReimbursement=(remb.Contact_Id__r.Fixed_Amount__c+VariableReimbursement).setScale(2);
            this.TotalReimbursement=remb.Total_Monthly_Unapproved_Reimbursement__c;
        }
    }

    public class MileWrap{
        public Employee_Mileage__c mil        {get; set;}
        public boolean isRejected             {get; set;}
        public Boolean isApproved             {get; set;}
        public decimal VariableReimbursement2 {get; set;}
        public decimal Variable{get;set;}
        public decimal mainttire{get;set;}
        public decimal fuelrate{get;set;}   
        public MileWrap(Employee_Mileage__c mil,list<AuditTrail__c> AuditTrail,list<Gas_Prices__c> gas){
            this.mil=new Employee_Mileage__c();
            this.isRejected = false;
            this.isApproved = false;
            this.mil=mil;
            decimal mpg;

            if(mil.Variable__c!=null)
                VariableReimbursement2 = mil.Variable__c;
            if(mil.MPG__c!=null)
                mpg = mil.MPG__c;
            if(mil.Maintenance_and_Tires__c!=null)
                mainttire = mil.Maintenance_and_Tires__c;
            if(mil.Fuel_price__c!=null && mil.MPG__c!=null)
                fuelrate = (mil.Fuel_price__c/mil.MPG__c).setscale(2);
            if(fuelrate!=null && mainttire!=null)
                Variable = fuelrate+mainttire;

            //  System.debug('{!mil.m.Reason_for_Rejection__c}===>>'+m.Reason_for_Rejection__c);
            /*    for(AuditTrail__c a:AuditTrail){
            // System.debug('mainttire2==>> '+mainttire);  from below if condition and also from below if condition afte maint and tire string 
            if(a.contact__c==mil.EmployeeReimbursement__r.Contact_Id__c&&a.NewValue__c!=null&&mil.Trip_Date__c!=null&&a.Timestamp__c!=null&&a.Field__c=='Maintenance and Tires'&&(a.Timestamp__c<=mil.Trip_Date__c)){
            mainttire=decimal.valueof(a.NewValue__c).setscale(4);
            // System.debug('mainttire==>> '+mainttire); 
            break;
            } 
            }
            if(mainttire==null&&mil.EmployeeReimbursement__r.Contact_Id__r.Maintenance_and_Tires__c!=null){
            mainttire=mil.EmployeeReimbursement__r.Contact_Id__r.Maintenance_and_Tires__c.setScale(4);
            }

            for(AuditTrail__c a:AuditTrail){
            if(a.contact__c==mil.EmployeeReimbursement__r.Contact_Id__c&&a.NewValue__c!=null&&mil.Trip_Date__c!=null&&a.Timestamp__c!=null&&a.Field__c=='Miles per Gallon'&&(a.Timestamp__c<=mil.Trip_Date__c)){
            // from above if condition and also from above if condition  afte miles per gallon string 
            mpg=decimal.valueof(a.NewValue__c).setscale(2);
            //  System.debug('mpg==>> '+mpg);
            break;
            } 

            }

            if(mpg==null&&mil.EmployeeReimbursement__r.Contact_Id__r.MPG__c!=null){
            mpg=mil.EmployeeReimbursement__r.Contact_Id__r.MPG__c.setScale(2);
            }



            for(Gas_Prices__c g:gas){
            if(mil.Trip_Date__c!=null&&mil.EmployeeReimbursement__r.Contact_Id__r.MailingState==g.state__c&&mil.EmployeeReimbursement__r.Contact_Id__r.MailingCity==g.city__c&&g.Month_Year__c!=null&&g.Fuel_Price__c!=null&&mpg!=null&&mil.Trip_Date__c.month()==g.Month_Year__c.month()){
            // from above if condition  and also from above if condiotn 
            //  System.debug('month from gas=>> '+g.Month_Year__c.month());
            // System.debug('month from mil=>> '+mil.Trip_Date__c.month());
            //    System.debug('Fuel_Price__c=>> '+g.Fuel_Price__c);
            this.fuelrate=(g.Fuel_Price__c.setscale(2)/mpg).setscale(2);
            } 
            }
            //  System.debug('fuelrate=>> '+fuelrate);
            if(fuelrate!=null&&mainttire!=null)
            this.variable=(fuelrate+mainttire).setScale(2);


            if(mil.mileage__c!=null&& variable!=null){ 

            VariableReimbursement2 = (variable*mil.mileage__c).setScale(2);
            //System.debug('VariableReimbursement2==> '+VariableReimbursement2);

            }
            //system.debug('milige'+m.mileage__c);

            this.mil=new Employee_Mileage__c();*/
            this.mil=mil;
        }

    }
}