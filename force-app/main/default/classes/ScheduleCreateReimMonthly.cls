public class ScheduleCreateReimMonthly implements schedulable{
    public void execute (SchedulableContext SC) {
        createReim();
    }
    public void createReim(){
        Integer currentMonth = date.today().Month();
        string tempYear = String.valueOf(date.today().Year());
       /* Comment by paras 05-01-2021
        if(currentMonth == 1){
            tempYear = String.valueOf(date.today().addMonths(-1).Year());
        }
	*/
        IRS_Mileage_Rate__c objIRSRate = [SELECT id,year__c,IRS_Rate__c FROM IRS_Mileage_Rate__c Where year__c =: tempYear Limit 1];
        String lastMonth = Utils.fetchMonths(1, -1)[0];
        List<Employee_Reimbursement__c> reimToInsert   = new List<Employee_Reimbursement__c>();
        Date myDate = system.today();
        for(contact contact : [SELECT Id,name,Role__c,Fixed_Amount__c, Maintenance_and_Tires__c, MPG__c 
                                FROM contact 
                                WHERE Role__c != 'Admin' 
                                    AND Role__c != 'Manager' 
                                    AND Deactivated_Date__c = NULL 
                                    AND Account.isUsingTriplog__c = true 
                                    AND Activation_Date__c <= : myDate ]) {
            Employee_Reimbursement__c er = new Employee_Reimbursement__c();
            er.Fixed_Amount__c = contact.Fixed_Amount__c;
            er.Status__c = 'Pending';
            er.Maintenance_and_Tires__c = contact.Maintenance_and_Tires__c;
            er.MPG__c = contact.MPG__c;
            er.Contact_Id__c = contact.id;
            er.Name = contact.Name + ':' + lastMonth;
            er.Month__c = lastMonth;
            er.Fuel_Price__c = 0;
            er.IRS_Mileage_Rate__c = objIRSRate.ID;
            reimToInsert.add(er);
        }
        if(!reimToInsert.isEmpty()) {
            insert reimToInsert;
        }
    }
}