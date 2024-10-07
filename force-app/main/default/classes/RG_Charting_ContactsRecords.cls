public with sharing class RG_Charting_ContactsRecords {
 public string getdata{get;set;}
	
   public RG_Charting_ContactsRecords(apexPages.standardController con){
   	
        String temp1 = Date.today().addMonths(-1).month()+'-'+Date.today().addmonths(-1).year();
        String temp2 = Date.today().addMonths(-2).month()+'-'+Date.today().addmonths(-2).year();
        String temp3 = Date.today().addMonths(-3).month()+'-'+Date.today().addmonths(-3).year();
        String temp4 = Date.today().addMonths(-4).month()+'-'+Date.today().addmonths(-4).year();
        String temp5 = Date.today().addMonths(-5).month()+'-'+Date.today().addmonths(-5).year();
        String temp6 = Date.today().addMonths(-6).month()+'-'+Date.today().addmonths(-5).year();
       
        string lastmonth1= temp1.left(2);
        if(lastmonth1.contains('-'))
        lastmonth1='0'+temp1;
        else
   		lastmonth1=temp1;
        
        string lastmonth2= temp2.left(2);
        if(lastmonth2.contains('-'))
        lastmonth2='0'+temp2;
        else
   		lastmonth2=temp2;
   		
        string lastmonth3= temp3.left(2);
        if(lastmonth3.contains('-'))
        lastmonth3='0'+temp3;
        else
   		lastmonth3=temp3;
   		
        string lastmonth4= temp4.left(2);
        if(lastmonth4.contains('-'))
        lastmonth4='0'+temp4;
        else
   		lastmonth4=temp4;
   		
        string lastmonth5= temp5.left(2);
        if(lastmonth5.contains('-'))
        lastmonth5='0'+temp5;
        else
   		lastmonth5=temp5;
   		
        string lastmonth6= temp6.left(2);
        if(lastmonth6.contains('-'))
        lastmonth6='0'+temp6;
		else
   		lastmonth6=temp6;
   		
       // id conid = [select id from contact where name='rohit'].id;
        id conid = ApexPages.currentPage().getParameters().get('id');
       // list<Employee_Reimbursement__c> EmReimList = [select id,Month__c,Contact_Id__r.lastName,Contact_Id__r.Monthly_Mileage_Limit__c,name,(select id, Mileage__c from Employees_Mileage__r) from Employee_Reimbursement__c where month__c=:lastmonth AND Contact_Id__r.lastname='Arpit' ];
          list<Employee_Reimbursement__c> rlist = [select id,month__c,Fuel_Price__c,( select name,mileage__c from Employees_Mileage__r )from Employee_Reimbursement__c where(month__c=:lastmonth1 OR month__c=:lastmonth2 OR month__c=:lastmonth3 OR month__c=:lastmonth4 OR month__c=:lastmonth4 OR month__c=:lastmonth6) AND Contact_Id__c=:conid ];   
       getdata='';
    // Trip_Date__c from inner query
  System.debug('rlist==>'+rlist);
   
         
       for(Employee_Reimbursement__c r:rlist ){  
       	decimal temp=0.00;
       	string month='';
       if(r.month__c!=null)
        month=r.Month__c.left(2);
       string m=(month=='1-')?'January':(month=='2-')?'February':(month=='3-')?'March':(month=='4-')?'April':(month=='5-')?'May':(month=='6-')?'June':
	      (month=='7-')?'July':(month=='8-')?'August':(month=='9-')?'September':(month=='01')?'January':(month=='02')?'February':(month=='03')?'March':(month=='04')?'April':(month=='05')?'May':(month=='06')?'June':
	      (month=='07')?'July':(month=='08')?'August':(month=='09')?'September':(month=='10')?'October':(month=='11')?'November':(month=='12')?'December':'Invalid Month';       
      // system.debug('Month-->'+m);
       getdata +='{"Month": "'+m+'",';
       
       for(Employee_Mileage__c l:r.Employees_Mileage__r){
           if(l.mileage__c!=null)
            temp +=l.mileage__c;
       }
       getdata +='"Mileage": '+temp +', '+'"Fuel Price": '+r.Fuel_Price__c+',},';
       month='';
       }
     
      System.debug('getdata==> '+getdata);
     
    }    
}