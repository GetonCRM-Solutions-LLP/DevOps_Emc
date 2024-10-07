/**
 * @description       : 
 * @author            : Vatsal Bhalani
 * @group             : 
 * @last modified on  : 08-02-2024
 * @last modified by  : Vatsal Bhalani
**/


// @Date : 20/05/2024 || Vatsal Bhalani
// Need to Run manully => On the 4th of each month after the batch has been run.
public class updateTenthMsgBatch implements Database.Batchable<sObject> {
    private List<Id> accountIds;
    String monthValue;
    String query;
    // Default constructor - fetches all account IDs
    public updateTenthMsgBatch() {
        
         monthValue = getMonthValue();
        
            query ='SELECT id, Total_Mileage__c, Contact_Id__c  FROM Employee_Reimbursement__c  WHERE month__c = :monthValue';
    }

    // Parameterized constructor - takes a specific list of account IDs
    public updateTenthMsgBatch(List<String> listAccountName) {
             monthValue = getMonthValue();
            query ='SELECT id, Total_Mileage__c, Contact_Id__c  FROM Employee_Reimbursement__c  WHERE month__c = :monthValue AND Contact_Id__r.Account.Name IN:listAccountName';
        }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Employee_Reimbursement__c> lstEmpReim) {
        Map<Id, Decimal> totalMileagemap = new Map<Id, Decimal>();
        String lastMonthString = RecordUtilityClass.getMonthName(monthValue);

        for (Employee_Reimbursement__c objEmpReim : lstEmpReim) {
            totalMileagemap.put(objEmpReim.Contact_Id__c, objEmpReim.Total_Mileage__c);
        }

        List<Message__c> lstMsgToInsert = new List<Message__c>();
        for (Id objContactId : totalMileagemap.keySet()) {
            List<String> args = new String[]{'0', 'number', '###,###,##0.00'};
            String updatedTotalMileage = String.format(totalMileagemap.get(objContactId).format(), args);
            System.debug(updatedTotalMileage);

            Message__c objMsg = new Message__c(
                Unread__c = true,
                Notification_Message__c = 'Your ' + lastMonthString + ' Mileage Was ' + updatedTotalMileage + ' .',
                Contacts__c = objContactId
            );

            lstMsgToInsert.add(objMsg);
        }

        if (!lstMsgToInsert.isEmpty()) {
            try {
                Database.insert(lstMsgToInsert, false);
            } catch (Exception e) {
                System.debug('Insertion Error: ' + e.getMessage());
            }
        }
    }
    private static string getMonthValue(){
       
        date lastMonth = System.today().addmonths(-1);
        return lastMonth.month() > 9 
        ? string.valueOf(lastMonth.month()) + '-' + string.valueOf(lastMonth.Year()) 
        : '0' + string.valueOf(lastMonth.month()) + '-' + string.valueOf(lastMonth.Year());
    }
    public void finish(Database.BatchableContext bc) {
        return;
    }
}