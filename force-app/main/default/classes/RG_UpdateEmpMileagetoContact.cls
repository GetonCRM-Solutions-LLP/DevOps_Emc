/**********************************************
Author - Nitesh K.(ApplikonTech IT Solution)
Date - 08 Sept 2016
Requirement - 
**********************************************/
global class RG_UpdateEmpMileagetoContact implements Database.Batchable<Employee_Mileage__c> {
    global list<Employee_Mileage__c> start(Database.BatchableContext BC) {
        string emp = label.defaultreimbursementid;
        Set<Date> lockDateList = new Set<Date>();
        
        list<Account> accList = [select id,Lock_date__c FROM Account Where Lock_date__c != null]; 
        string tempDate = date.today().addMonths(-2).Month()+'-'+date.today().addMonths(-2).Year();
        string lastmonth = tempDate.left(2);
        if(lastmonth.contains('-')) {
            lastmonth ='0'+tempDate;
        }
        else {
            lastmonth = tempDate;
        }
        list<Employee_Mileage__c> approvedMileageList = [select id,Trip_Date__c,Contact_Email_Id__c,EmployeeReimbursement__r.contact_Id__r.account.Lock_date__c,EmployeeReimbursement__r.contact_Id__r.accountId,approved_date__c from Employee_Mileage__c where approved_Date__c!=null AND EmployeeReimbursement__r.contact_Id__r.accountId!=null AND EmployeeReimbursement__r.month__c=:lastmonth AND EmployeeReimbursement__c!=:emp];
        System.debug('approvedMileageList>> '+approvedMileageList);
      
        String query = 'Select id, Name, Contact_Email_Id__c, Trip_Date__c,EmployeeReimbursement__r.Contact_Id__r.Account.Lock_date__c ,EmployeeReimbursement__r.Status__c, Rejected__c,Approved_Date__c,Mileage__c from Employee_Mileage__c where EmployeeReimbursement__c=null OR EmployeeReimbursement__c=:emp OR (Rejected__c=False AND Approved_Date__c=null)';
        list<Employee_Mileage__c> mileageList = Database.Query(query); 
        
        for(Employee_Mileage__c mil : approvedMileageList) {
            if((mil.EmployeeReimbursement__r.contact_Id__r.account.Lock_date__c!=null && mil.Approved_Date__c.day()>mil.EmployeeReimbursement__r.contact_Id__r.account.Lock_date__c.day() && mil.Approved_Date__c.month() == date.today().addMonths(-1).month()) || (mil.EmployeeReimbursement__r.contact_Id__r.account.Lock_date__c == null && mil.Approved_Date__c.day()>8 && mil.Approved_Date__c.month() == date.today().addMonths(-1).month())) {
                mil.From_Previous_Months__c=true;
                mileageList.add(mil);
                System.debug('mileage>> '+mil);
            }
            
        }
        
        System.debug(mileageList.size());
        return mileageList;
    }
   
    global void execute(Database.BatchableContext BC, List<Employee_Mileage__c> empMileage) {
        list<string> emailList=new list<string>();

        for(Employee_Mileage__c empMil:empMileage){
            if(string.isNotBlank(empMil.Contact_Email_Id__c)) {
                emailList.add(empMil.Contact_Email_Id__c);
            }
        }
        System.debug(emailList);
        String temp1 = Date.today().addMonths(-1).month()+'-'+Date.today().addmonths(-1).year();
        string lastmonth= temp1.left(2);
        if(lastmonth.contains('-')) {
            lastmonth='0'+temp1;
        } else {
            lastmonth=temp1;
        }
        
        list<Contact> con = [Select id, Monthly_Mileage_Limit__c,Maintenance_and_Tires__c,MPG__c,Fixed_Amount__c, mailingcity, mailingState, Name, (select id, Field__c,NewValue__c,OldValue__c,Timestamp__c,Modifiedby__c from Audit_Trail__r order by Timestamp__c DESC ),External_Email__c,(Select id,Name, Month__c,status__c from Employee_Reimbursements__r where Month__c=:lastmonth) from Contact where External_Email__c In:emailList AND (Deactivated_Date__c=:null OR (Deactivated_Date__c>=:date.today().addDays(-30)))];     
        map<id,contact> conIdToContactMap = new map<id,contact>(con);
        map<String, Decimal> gpfuelmap = new map<String,Decimal>();
        map<String, Decimal> gpfuelmapForMileage = new map<String,Decimal>();
        for(Gas_Prices__c gplist :[select Fuel_Price__c, Month_State_City__c,Month_Year__c,State__c, City__c from Gas_Prices__c where
            Month_Year__c=:Date.today().addmonths(-1).tostartofmonth() or Month_Year__c=:Date.today().addmonths(-2).tostartofmonth() or
            Month_Year__c=:Date.today().addmonths(-3).tostartofmonth() or Month_Year__c=:Date.today().addmonths(-4).tostartofmonth()]) {
            String temp = gplist.city__c+'-'+gplist.State__c;
            System.debug('gplist: '+gplist);
            if(gplist.Month_Year__c == Date.today().addmonths(-1).tostartofmonth()) {
                gpfuelmap.put(temp.touppercase(),gplist.Fuel_Price__c);
            }
            gpfuelmapForMileage.put(gplist.Month_State_City__c.touppercase(),gplist.Fuel_Price__c);
        }
        System.debug('gpfuelmap: '+gpfuelmap);
        System.debug('con.size===>> '+con.size()); 
        //----------------------------------------------------------------------
        //Contact id and Employee Mileage Map if both have same email id
        Map<id,list<Employee_Mileage__c>> ConIdEmpListMap = new Map<id,list<Employee_Mileage__c>>();
        //forContact id Mileage Mapping
        decimal totalEmployeeMileage;
        //Contact id and employee total mileage
        map<id,string> conIdToCityStateMap = new map<id,string>();
        for(contact c: con) {
            totalEmployeeMileage = 0;
            list<Employee_Mileage__c> empMList=new list<Employee_Mileage__c>();
            for(Employee_Mileage__c m:empMileage) {
                if(c.External_Email__c == m.Contact_Email_Id__c) {
                    empMList.add(m);
                }
            }
            ConIdEmpListMap.put(c.id,empMList);
            if(string.isNotBlank(c.mailingCity) && string.isNotBlank(c.mailingState)) {
                conIdToCityStateMap.put(c.id,c.mailingCity+c.mailingState);
            }
        }
               
        //------------------------------------------------------------------------
        //Contact id and Rimbursement Month Map
        Map<id, Employee_Reimbursement__c> contoEmpReim = new map<id,Employee_Reimbursement__c>();
        list<Employee_Mileage__c>  newempMList=new list<Employee_Mileage__c>();
        //for Contact id and Rimbursement Month Mapping
        for(Contact c:con) {
            System.debug('c: '+c);
            System.debug('c.Employee_Reimbursements__r.isEmpty(): '+c.Employee_Reimbursements__r.isEmpty());
            String Status ='Pending';
            date ApprovedDate=null;
            String constring = c.Mailingcity+'-'+c.MailingState;
            constring = constring.toUpperCase();
            Decimal FuelPrice = 0.0;
            if(gpfuelmap.containsKey(constring)) {
                FuelPrice = gpfuelmap.get(constring);
            }
            if(c.Employee_Reimbursements__r!=null && c.Employee_Reimbursements__r.size()>0) {
                c.Employee_Reimbursements__r[0].Fuel_Price__c = FuelPrice;
                c.Employee_Reimbursements__r[0].Fixed_Amount__c = c.Fixed_Amount__c;
                contoEmpReim.put(c.id,c.Employee_Reimbursements__r[0]);
            }
            else if(c.Employee_Reimbursements__r.isEmpty()) {
                System.debug('FuelPrice: '+FuelPrice);
                System.debug('gpfuelmap: '+gpfuelmap);
                contoEmpReim.put(c.id,new Employee_Reimbursement__c(Fixed_Amount__c=c.Fixed_Amount__c,status__c=Status,Maintenance_and_Tires__c=c.Maintenance_and_Tires__c,MPG__c=c.MPG__c,Contact_Id__c=c.id,Name=c.Name+':'+lastmonth,Month__c=lastmonth, Fuel_Price__c=fuelprice));
                //System.debug('contoEmpReim===> '+contoEmpReim);
                System.debug('contoEmpReim: '+contoEmpReim);
            }
        }
        try {
            System.debug('before contoEmpReim.values(): '+contoEmpReim.values());
            upsert contoEmpReim.values();
            System.debug('after contoEmpReim.values(): '+contoEmpReim.values());
            //if(newempMList!=null&&newempMList.size()>0){
            //update newempMList;
            // }
        } catch(DMLException e) {
            system.debug('Exception==='+e);
        }
       
        //----------------------------------------------------------------------------
        // Employee Mileage assign to Reimbursement     
        for(id cid:ConIdEmpListMap.keyset()) {   
            Decimal mainttire = 0;
            Decimal mpg = 0;
            Id Empid = contoEmpReim.get(cid).id;
            string contactCityState= conIdToCityStateMap.containsKey(cid)?conIdToCityStateMap.get(cid):null;
            for(Employee_Mileage__c mileage:ConIdEmpListMap.get(cid)) {
                system.debug('Exception==='+mileage); 
                if(mileage.approved_Date__c==null) {
                    string tripDate = mileage.Trip_Date__c!=null?mileage.Trip_Date__c.month()+''+mileage.Trip_Date__c.year():null;
                    if (string.isNotBlank(tripDate) && string.isNotBlank(contactCityState)) {
                        tripDate = contactCityState + tripDate;
                    }
                    if(string.isNotBlank(tripDate)) {
                        mileage.Fuel_Price__c = gpfuelmapForMileage.containsKey(tripDate.toUpperCase())?gpfuelmapForMileage.get(tripDate.toUpperCase()):0.00;
                    } else {
                        mileage.Fuel_Price__c=0.00;
                    }
                    mileage.EmployeeReimbursement__c=Empid;
                    //if(contoEmpReim.get(cid).status__c=='Approved')
                    mileage.Trip_Status__c='No Approved Yet';
                    for(AuditTrail__c a:conIdToContactMap.get(cid).Audit_Trail__r) {
                        if(mileage.Trip_Date__c != null&&a.Timestamp__c != null&&a.Field__c == 'Maintenance and Tires' && (a.Timestamp__c <= mileage.Trip_Date__c)) {
                            mainttire = decimal.valueof(a.NewValue__c).setscale(4);
                            system.debug('Exception==='+mainttire);
                            break;
                         }
                    }
                    if((mainttire==null || mainttire==0)&&conIdToContactMap.get(cid).Maintenance_and_Tires__c!=null) {
                        mainttire=conIdToContactMap.get(cid).Maintenance_and_Tires__c.setScale(4);
                        system.debug('Exception==='+mainttire); 
                    }
                    for(AuditTrail__c a : conIdToContactMap.get(cid).Audit_Trail__r) {
                        if(mileage.Trip_Date__c != null&&a.Timestamp__c != null&&a.Field__c == 'Miles per Gallon' && (a.Timestamp__c <= mileage.Trip_Date__c)) {
                            mpg = decimal.valueof(a.NewValue__c).setscale(4);
                            system.debug('Exception==='+mpg); 
                            //System.debug('mpg==>> '+mpg);   
                            break;
                        }
                    }
               
                    if((mpg == null || mpg == 0) && conIdToContactMap.get(cid).MPG__c != null) {
                        mpg = conIdToContactMap.get(cid).MPG__c.setScale(4);
                        system.debug('Exception==='+mpg); 
                    }
                    system.debug('Exception==='+mpg);    
                    system.debug('Exception==='+mainttire);              
                    mileage.MPG__c = mpg;
                    mileage.Maintenance_and_Tires__c = mainttire;       
                } else {
                    mileage.EmployeeReimbursement__c=Empid;
                }
            }
        }
        list<Employee_Mileage__c> empmileagetoupdate = new list<Employee_Mileage__c>();
        try {
            for(list<Employee_Mileage__c> temp : ConIdEmpListMap.values()) {
                empmileagetoupdate.addAll(temp);
            }
            update empmileagetoupdate;
        } catch(DMLException e){
            system.debug('exception==='+e);
        }  
    }
    global void finish(Database.BatchableContext BC) {
        list<Employee_Reimbursement__c> empReimlist = new list<Employee_Reimbursement__c>();
        String temp = Date.today().addMonths(-1).month()+'-'+Date.today().addmonths(-1).year();
        string lastmonth= temp.left(2);
        if(lastmonth.contains('-')) {
            lastmonth='0'+temp;
        } else {
            lastmonth=temp;
        }
        list<Contact> con=[Select id, Monthly_Mileage_Limit__c,Maintenance_and_Tires__c,MPG__c, mailingcity, mailingState, Name, External_Email__c,(Select id,Name, Month__c from Employee_Reimbursements__r where Month__c=:lastmonth) from Contact where  (Deactivated_Date__c=:null OR (Deactivated_Date__c>=:date.today().addDays(-30)))];
        for(contact c:con) {
            string status='Approved';
            if(c.Employee_Reimbursements__r.isEmpty()) {
                empReimlist.add(new Employee_Reimbursement__c(Contact_Id__c=c.id,Approved_Date__c=date.today(),Status__c=status,Name=c.Name+':'+lastmonth,Month__c=lastmonth,Maintenance_and_Tires__c=c.Maintenance_and_Tires__c,MPG__c=c.MPG__c));
            }
        }
        if(empReimlist.size()>0) {
            insert empReimlist;
        }        
        RG_BatchForApprovingReimburse att = new RG_BatchForApprovingReimburse();
        if(!Test.isRunningTest()) {
            database.executeBatch(att,50);
        }
    
    }
    
}