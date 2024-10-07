public class RG_Charting_MyRecordsClass {
    public string getdata {get;set;}
    public RG_Charting_MyRecordsClass() {
        //Getting Current User Contatct ID
        id coid = ApexPages.currentPage().getParameters().get('id');
        id cd = ApexPages.currentPage().getParameters().get('cd');
        id cpid = ApexPages.currentPage().getParameters().get('p');
        id cid = ApexPages.currentPage().getParameters().get('cid');
        id dr = ApexPages.currentPage().getParameters().get('dr');
        id conid = (coid == null) ? (cd == null) ? (cpid == null) ? (dr == null) ? cid : dr : cpid : cd : coid;
        if(conid == null) {
            conid = [SELECT contactid FROM User WHERE id = : userinfo.getuserid()].contactid;
        }
        list<Employee_Reimbursement__c> EmReimList = new  list<Employee_Reimbursement__c>();
        if(cpid != null) {
            EmReimList = [SELECT id, 
                                 Fuel_Price__c, 
                                 Month__c, 
                                 Contact_Id__r.lastName, 
                                 Contact_Id__r.Monthly_Mileage_Limit__c, 
                                 name, 
                                (SELECT id, 
                                        Mileage__c
                                FROM Employees_Mileage__r
                                WHERE Approved_Date__c = : null AND rejected__c !=: true)
                          FROM Employee_Reimbursement__c
                          WHERE Contact_Id__c =: conid AND Approved_date__c =: null AND Status__c !=: 'Approved'ORDER BY
                          Month_Field__c
                          DESC];
        } else {
            string temp1 = Date.today().addMonths(-1).month() + '-' + Date.today().addmonths(-1).year();
            string temp2 = Date.today().addMonths(-2).month() + '-' + Date.today().addmonths(-2).year();
            string temp3 = Date.today().addMonths(-3).month() + '-' + Date.today().addmonths(-3).year();
            string temp4 = Date.today().addMonths(-4).month() + '-' + Date.today().addmonths(-4).year();
            string temp5 = Date.today().addMonths(-5).month() + '-' + Date.today().addmonths(-5).year();
            string temp6 = Date.today().addMonths(-6).month() + '-' + Date.today().addmonths(-5).year();
            string lastmonth1 = temp1.left(2);
            if(lastmonth1.contains('-')) {
                lastmonth1 = '0' + temp1;
            } else {
                lastmonth1 = temp1;
            }
            string lastmonth2 = temp2.left(2);
            if(lastmonth2.contains('-')) {
                lastmonth2 = '0' + temp2;
            }
            else {
                lastmonth2 = temp2;
            }
            string lastmonth3 = temp3.left(2);
            if(lastmonth3.contains('-')) {
                lastmonth3 = '0' + temp3;
            }
            else {
                lastmonth3 = temp3;
            }
            string lastmonth4 = temp4.left(2);
            if(lastmonth4.contains('-')) {
                lastmonth4 = '0' + temp4;
            } else {
                lastmonth4 = temp4;
            }
            string lastmonth5 = temp5.left(2);
            if(lastmonth5.contains('-')) {
                lastmonth5 = '0' + temp5;
            } else {
                lastmonth5 = temp5;
            }
            string lastmonth6 = temp6.left(2);
            if(lastmonth6.contains('-')) {
                lastmonth6 = '0' + temp6;
            } else {
                lastmonth6 = temp6;
            }
            EmReimList = [SELECT
                          id, 
                          Fuel_Price__c, 
                          Month__c, 
                          Contact_Id__r.lastName, 
                          Contact_Id__r.Monthly_Mileage_Limit__c, 
                          name, 
                          (SELECT
                           id, 
                           Mileage__c
                           FROM
                           Employees_Mileage__r)
                          FROM
                          Employee_Reimbursement__c
                          WHERE
                          Contact_Id__c = : conid AND (month__c = : lastmonth1 OR month__c = : lastmonth2 OR month__c = : lastmonth3 OR month__c = : lastmonth4 OR month__c = : lastmonth5 OR month__c = : lastmonth6)
                          ORDER BY
                          Month_Field__c
                          DESC];
        }
        getdata = '';
        for(Employee_Reimbursement__c r: EmReimList) {
            string month = '';
            if(r.Month__c != null) {
                month = r.Month__c.left(2);
            }
            string m = RG_Charting.getMonthName(month);
            decimal temp = 0;
            if(!getdata.contains(m)) {
                getdata += '{"year": "' + m + '",';
                for(Employee_Mileage__c d: r.Employees_Mileage__r) {
                    if(d.Mileage__c != null) {
                        temp += d.Mileage__c;
                    }
                }
                decimal fuelrate = r.Fuel_Price__c != null ? r.Fuel_Price__c.setScale(2) : 0;
                getdata += '"Mileage": ' + temp + ',' + '"Fuel Price": ' + fuelrate + ',},';
            }
            month = '';
        }
    }
}