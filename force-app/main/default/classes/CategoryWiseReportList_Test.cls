@isTest(SeeAllData='true')
public class CategoryWiseReportList_Test{
    
    Public static testmethod void categoryList(){
        CategoryWiseReportList obj = new CategoryWiseReportList();
        obj.categoryName = 'test';
        CategoryWiseReportList.Reports obj1 = new CategoryWiseReportList.Reports();
        obj1.reportId = 'test';
        obj1.reportName = 'test';
        obj1.lockDate = false;    
    }
}