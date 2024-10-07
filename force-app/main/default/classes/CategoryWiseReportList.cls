/**
@author Natavar Ghodasara
@date 26th Feb 2019
@group Wrapper
@group-content WrapperDetails.html
@description CategoryWiseReportList is wrapper for report List shown to admin. 
*/
public with sharing class CategoryWiseReportList 
{
	/*******************************************************************************************************
    * @description categoryName is Custom Report (Custom_Report__c) Object's Report_Category__c Field.
    */
	public String categoryName {get;set;}
	/*******************************************************************************************************
    * @description currentReports is List of Custom Report (Custom_Report__c) Object's.
    */
	public List<Reports> currentReports {get;set;}
	/**
	@author Natavar Ghodasara
	@date 26th Feb 2019
	@description Default Constructor.
	*/
	public CategoryWiseReportList()
	{

	}
	/**
	@author Natavar Ghodasara
	@date 26th Feb 2019
	@group Wrapper
	@group-content WrapperDetails.html
	@description Reports is wrapper for Single report shown to admin. 
	*/
	public class Reports
	{
		/**
		@author Natavar Ghodasara
		@date 26th Feb 2019
		@description Default Constructor.
		*/
		public Reports()
		{
			
		}
		/*******************************************************************************************************
	    * @description reportId is ID of Custom Report (Custom_Report__c) Object's.
	    */
		public String reportId{get;set;}
		/*******************************************************************************************************
	    * @description reportName is Single Custom Report (Custom_Report__c) Object's.
	    */
		public String reportName{get;set;}
		public Boolean lockDate{get; set;}
		public String mileageLockDate {get; set;}
	}
}