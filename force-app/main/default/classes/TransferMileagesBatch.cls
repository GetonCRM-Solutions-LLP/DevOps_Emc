/**
 * @Createdby: Sanjay Halpati | 19 May 2020
 * @Description:  Batch to transfer unapproved mileages to last month reimbersments
 */
global class TransferMileagesBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    global String query;
    global final String STATUS_NOTAPPROVEDYET = StaticValues.STATUS_NOTAPPROVEDYET;
    global List<String> months;
    global List<String> accountNames;
    global Map<Id, Employee_Reimbursement__c> reimContactMap;
    global string filebody = '';


    global TransferMileagesBatch(Integer pastNoOfmonths) {
        months = Utils.fetchMonths(pastNoOfmonths, 1);
        query = 'SELECT Id, EmployeeReimbursement__c,EmployeeReimbursement__r.contact_Id__c,' + 
                     'EmployeeReimbursement__r.Name, Maintenance_and_Tires__c,' +
                     'EmployeeReimbursement__r.Month__c, EmployeeReimbursement__r.contact_Id__r.Name, MPG__c ' +
                     ' FROM Employee_Mileage__c ' +
                     ' WHERE EmployeeReimbursement__r.contact_Id__r.accountId != null' + 
                     ' AND EmployeeReimbursement__r.Month__c IN : months' + 
                     ' AND Approved_Date__c = null AND Trip_Status__c =: STATUS_NOTAPPROVEDYET' +
                     ' AND Rejected__c = false ';
        Date lastMonthDate = System.today().addMonths(-1);
        String lastMonth = (lastMonthDate.month() > 9 ? lastMonthDate.month() + '' : '0' + lastMonthDate.month()) + '-' + lastMonthDate.year();
        List<Employee_Reimbursement__c> lastMonthReims = new List<Employee_Reimbursement__c>([SELECT Id, 
                                                                                        Contact_Email__c, 
                                                                                        Contact_Id__r.Maintenance_and_Tires__c, 
                                                                                        Contact_Id__r.MPG__c 
                                                                                    FROM Employee_Reimbursement__c 
                                                                                        WHERE Contact_Id__c != null AND Month__c =: lastMonth]);

        if( Utils.CheckNulls( System.Label.TripstobeLogged) ) {
            accountNames = Utils.SplitStringToList(System.Label.TripstobeLogged, ',');
            query += ' AND EmployeeReimbursement__r.contact_Id__r.account.Name In: accountNames';

            lastMonthReims = new List<Employee_Reimbursement__c>([SELECT Id, 
                                                                        Contact_Id__c,
                                                                        Contact_Email__c, 
                                                                        Contact_Id__r.Maintenance_and_Tires__c, 
                                                                        Contact_Id__r.MPG__c 
                                                                    FROM Employee_Reimbursement__c 
                                                                        WHERE Contact_Id__c != null AND Month__c =: lastMonth
                                                                        AND contact_Id__r.account.Name In: accountNames]);
        }

        reimContactMap = new Map<Id, Employee_Reimbursement__c>();
        for(Employee_Reimbursement__c er : lastMonthReims) {
            reimContactMap.put(er.Contact_Id__c, er);
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Employee_Mileage__c> mileagesToTransfer = new List<Employee_Mileage__c>();
        for(Employee_Mileage__c mil : (List<Employee_Mileage__c>) scope) {
            String key = mil.EmployeeReimbursement__r.contact_Id__c;
            if(reimContactMap.Containskey(key)){
                mil.EmployeeReimbursement__c = reimContactMap.get(key).Id;
                mil.Maintenance_and_Tires__c =  reimContactMap.get(key).Contact_Id__r.Maintenance_and_Tires__c;
                mil.MPG__c = reimContactMap.get(key).Contact_Id__r.MPG__c;
                mileagesToTransfer.add(mil);

                filebody += mil.id + ',' + mil.EmployeeReimbursement__r.Name + ',' + mil.Maintenance_and_Tires__c + ',' + 
                            mil.MPG__c + ',' + mil.EmployeeReimbursement__r.Month__c + ',' + mil.EmployeeReimbursement__r.contact_Id__r.Name + '\n';
            }
            
        }

        if(!mileagesToTransfer.isEmpty()) {
            update mileagesToTransfer;
        }
    }

    global void finish(Database.BatchableContext BC) {
        //Sending Mail
        Messaging.EmailFileAttachment csvFile = new Messaging.EmailFileAttachment();
        csvFile.setFileName('Updated Last to Last Month Mileage.csv');
        csvFile.setBody(Blob.valueOf( 'Mileage ID,Reimbersment Name,Maintenance and Tires,MPG,Month,Contact name\n' + filebody ));
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> { System.Label.TransferMileagesBatchEmail };
        email.setSubject('Mileage Status');
        email.setToAddresses(toAddresses);
        if(filebody == '') {
            email.setPlainTextBody('Hi, All mileages Carryforworded from previous months. Thank you.');
        } else {
            email.setPlainTextBody('Hi, Please Find the CSV for Carryforworded mileage last to last month. Thank you.');
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{ csvFile });    
        }
        if(!Test.isRunningTest()) {
            Messaging.SendEmailResult [] sendSinglemail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }
        
    }

}