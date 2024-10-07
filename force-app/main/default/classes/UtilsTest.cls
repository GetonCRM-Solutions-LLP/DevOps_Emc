@isTest
public with sharing class UtilsTest {
    public static testmethod void utilTest() {
        
        Configure_Trigger__c  objSendEmail = new Configure_Trigger__c();
        objSendEmail.Name = 'Default';
        objSendEmail.Enable_Custom_Report__c = true;
        insert objSendEmail;

        String[] toAddresses =  new string[]{'sanket.goc@gmail.com'};
        Utils.fetchMonths(10, 2);
        Utils.fetchCurrentMonth();
        Utils.SplitStringToList('test', ',');
        Utils.RunTrigger('Custom_Report__c');
        Utils.CheckNulls(' ');
        Utils.CreateEmail('subject', 'htmlbody', toAddresses, null, toAddresses, null);
        Utils.CreateEmailLog('subject', 'htmlbody', toAddresses, toAddresses, toAddresses, 'parentId', 'initiatedFrom');
        Utils.getAllFields('contact');
        Utils.weekOfMonth(System.today());
        Utils.FetchStates();
        Utils.ConvertMinuteToHours(4000);
        Utils.ConvertMinuteToDays(3000);
    }
}