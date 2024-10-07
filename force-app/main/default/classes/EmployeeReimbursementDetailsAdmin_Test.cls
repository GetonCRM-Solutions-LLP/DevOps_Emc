@isTest
Public class EmployeeReimbursementDetailsAdmin_Test{
    Public static testmethod void empDetail(){
        EmployeeReimbursementDetailsAdmin obj = new EmployeeReimbursementDetailsAdmin();
        obj.id = '0031h00000MFZA8';
        obj.name = 'divya';
        obj.month = 'jan';
        obj.threshold = 'test';
        obj.totalMileages = '10';
        obj.approvedMileages = '10';
        obj.status = 'Approve';
        obj.approvedDate = '3/21/2019';
        obj.isSelected = true;
        obj.managerName = 'Doris';
        obj.isSelectedEmailReminder = true;
        obj.reimbursementApproval = true;
        obj.mileageApproval = 'Minkesh';
        obj.managerEmail = 'test@gmail.com';
    }
}