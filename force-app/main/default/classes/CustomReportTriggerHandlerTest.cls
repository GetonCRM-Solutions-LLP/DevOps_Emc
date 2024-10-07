/**
 * @File Name          : CustomReportTriggerHandlerTest.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 27/2/2020, 4:12:27 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    27/2/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
public with sharing class CustomReportTriggerHandlerTest {
    static testMethod void test1() {
        List<String> fieldList = new List<String>();
        fieldList.add('Report_Soql__c');
        
        Custom_Report__c currentReport = new Custom_Report__c();
        currentReport.Name = 'Variable Reimbursement Report';
        currentReport.Sort_By__c = 'asc';
        currentReport.Report_For__c = 'Frank Saverino Accessibility';
        currentReport.Report_Category__c = 'Reimbursement Reports	';
        currentReport.Report_Type__c = 'Reimbursements Between 2 Dates For Month Range';
        currentReport.Use_Manager_List__c = true;
        currentReport.Report_Header__c = 'Month,Employee ID,Name,E-mail,Monthly Approved Variable Amount';
        currentReport.Report_Soql__c = 'select Month__c,Contact_Id_Employee_ID__c,Contact_Id_Name__c,Contact_Id_External_Email__c,Monthly_Approved_Variable_Amount__c from Employee_Reimbursement__c where Contact_Id_Deactivated_Date__c =null';
        currentReport.Numeric_Fields__c = 'Monthly_Approved_Variable_Amount__c';
        currentReport.Date_Time_Fields__c = 'Contact_Id_Name__c';
        currentReport.Date_Fields__c = 'Contact_Id_External_Email__c';
        insert currentReport ; 

        CustomReportTriggerHandler.checkField(fieldList,'Numeric_Fields__c','Hello',currentReport);
    }
    static testMethod void test2() {
        Custom_Report__c currentReport = new Custom_Report__c();
        currentReport.Name = 'Variable Reimbursement Report';
        currentReport.Sort_By__c = 'asc';
        currentReport.Report_For__c = 'Frank Saverino Accessibility';
        currentReport.Report_Category__c = 'Reimbursement Reports	';
        currentReport.Report_Type__c = 'Reimbursements Between 2 Dates For Month Range';
        currentReport.Use_Manager_List__c = true;
        currentReport.Report_Header__c = 'Month,Employee ID,Name,E-mail,Monthly Approved Variable Amount';
        currentReport.Report_Soql__c = 'select Month__c,Contact_Id_Employee_ID__c,Contact_Id_Name__c,Contact_Id_External_Email__c,Monthly_Approved_Variable_Amount__c from Employee_Reimbursement__c where Contact_Id_Deactivated_Date__c =null';
        currentReport.Numeric_Fields__c = 'Monthly_Approved_Variable_Amount__c';
        currentReport.Date_Time_Fields__c = 'Contact_Id_Name__c';
        currentReport.Date_Fields__c = 'Contact_Id_External_Email__c';
        insert currentReport ; 

        Custom_Report__c currentReport1 = new Custom_Report__c();
        currentReport1.Name = 'Variable Reimbursement Report1';
        currentReport1.Sort_By__c = 'asc';
        currentReport1.Report_For__c = 'Frank Saverino Accessibility';
        currentReport1.Report_Category__c = 'Reimbursement Reports	';
        currentReport1.Report_Type__c = 'Reimbursements Between 2 Dates For Month Range';
        currentReport1.Use_Manager_List__c = true;
        currentReport1.Report_Header__c = 'Month,Employee ID,Name,E-mail,Monthly Approved Variable Amount';
        currentReport1.Report_Soql__c = 'select Month__c,Contact_Id_Employee_ID__c,Contact_Id_Name__c,Contact_Id_External_Email__c,Monthly_Approved_Variable_Amount__c from Employee_Reimbursement__c where Contact_Id_Deactivated_Date__c =null';
        currentReport1.Numeric_Fields__c = 'Monthly_Approved_Variable_Amount__c,Month__c';
        currentReport1.Date_Time_Fields__c = 'Contact_Id_Name__c,Contact_Id_External_Email__c';
        currentReport1.Date_Fields__c = 'Contact_Id_External_Email__c';
        insert currentReport1 ; 
    }
}