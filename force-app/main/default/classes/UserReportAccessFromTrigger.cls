/**
 * @Author:  GetonCRM Solutions LLP
 * @Description: Future class use to create a report accessibility record and it is called from User trigger.
 * @Modification logs
 * ========================================================================================================================
 * @Date: 16 June 2020 | Sanket Goswami
 * @description:
 */
public class UserReportAccessFromTrigger {
    public UserReportAccessFromTrigger() { }

    //method to create a report accessibility record for admin and admin/driver.
    @future 
    public static void createReportAccessibility(set<Id> setUserids)
    {
        List<Report_Accessibility__c> reportAccList = new List<Report_Accessibility__c>();
        for(User currentUser : [SELECT ID,Name FROM User WHERE Id IN : setUserids]){           
            Report_Accessibility__c reportObj = new Report_Accessibility__c();
            reportObj.Custom_Report__c = System.Label.EmployeeRosterReportID;
            reportObj.User__c = currentUser.Id;
            reportObj.Name = 'Employee Roster Report '+ currentUser.Name;
            reportAccList.add(reportObj);

            Report_Accessibility__c reportObjReim = new Report_Accessibility__c();
            reportObjReim.Custom_Report__c = System.Label.Onboarding_Status_ReportID;
            reportObjReim.User__c = currentUser.Id;
            reportObjReim.Name = 'Onboarding Status Report '+ currentUser.Name;
            reportAccList.add(reportObjReim);

            Report_Accessibility__c ObjVariableReim = new Report_Accessibility__c();
            ObjVariableReim.Custom_Report__c = System.Label.FixedandVariableReportId;
            ObjVariableReim.User__c = currentUser.Id;
            ObjVariableReim.Name = 'Fixed and Variable Report '+ currentUser.Name;
            reportAccList.add(ObjVariableReim);

            Report_Accessibility__c ObjTerminatedReim = new Report_Accessibility__c();
            ObjTerminatedReim.Custom_Report__c = System.Label.TerminatedDriverReportId;
            ObjTerminatedReim.User__c = currentUser.Id;
            ObjTerminatedReim.Name = 'Final Variable Report for Terminated Drivers '+ currentUser.Name;
            reportAccList.add(ObjTerminatedReim);

            Report_Accessibility__c ObjMilegeReport = new Report_Accessibility__c();
            ObjMilegeReport.Custom_Report__c = System.Label.EmployeeMileageReportId;
            ObjMilegeReport.User__c = currentUser.Id;
            ObjMilegeReport.Name = 'Employee Mileage Report '+ currentUser.Name;
            reportAccList.add(ObjMilegeReport);
        }
        
        if(!reportAccList.isEmpty() && !Test.isRunningTest()){            
            insert reportAccList;
        }

    }
}