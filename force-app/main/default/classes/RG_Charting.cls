public class RG_Charting {

  public string getdata {get; set;}
  public Id supid {get; set;}
  public String un {get; set;}
  public Id contid {get; set;}
  public Id conid {get; set;}
  public Boolean Showteamrecord {get; set;}
  // constructor for the class
  public rg_charting() {

    //Getting the last six month in format
    String temp1 = Date.today().addMonths(-1).month() + '-' + Date.today().addmonths(-1).year();
    String temp2 = Date.today().addMonths(-2).month() + '-' + Date.today().addmonths(-2).year();
    String temp3 = Date.today().addMonths(-3).month() + '-' + Date.today().addmonths(-3).year();
    String temp4 = Date.today().addMonths(-4).month() + '-' + Date.today().addmonths(-4).year();
    String temp5 = Date.today().addMonths(-5).month() + '-' + Date.today().addmonths(-5).year();
    String temp6 = Date.today().addMonths(-6).month() + '-' + Date.today().addmonths(-5).year();
    string lastmonth1 = temp1.left(2);
    if (lastmonth1.contains('-'))
      lastmonth1 = '0' + temp1;
    else
      lastmonth1 = temp1;

    string lastmonth2 = temp2.left(2);
    if (lastmonth2.contains('-'))
      lastmonth2 = '0' + temp2;
    else
      lastmonth2 = temp2;

    string lastmonth3 = temp3.left(2);
    if (lastmonth3.contains('-'))
      lastmonth3 = '0' + temp3;
    else
      lastmonth3 = temp3;

    string lastmonth4 = temp4.left(2);
    if (lastmonth4.contains('-'))
      lastmonth4 = '0' + temp4;
    else
      lastmonth4 = temp4;

    string lastmonth5 = temp5.left(2);
    if (lastmonth5.contains('-'))
      lastmonth5 = '0' + temp5;
    else
      lastmonth5 = temp5;

    string lastmonth6 = temp6.left(2);
    if (lastmonth6.contains('-'))
      lastmonth6 = '0' + temp6;
    else
      lastmonth6 = temp6;

    List<String> allMonths = new List<String> {getMonthName(temp1.left(2)), getMonthName(temp2.left(2)), getMonthName(temp3.left(2)), getMonthName(temp4.left(2)), getMonthName(temp5.left(2)), getMonthName(temp6.left(2))};
    // getting the page parameter
    supid = ApexPages.currentPage().getParameters().get('supid');
    un = ApexPages.currentPage().getParameters().get('un');
    contid = ApexPages.currentPage().getParameters().get('id');
    conid = (supid == null) ? contid : supid;
    if (conid == null /*&& un == null*/)
      conid = [select contactid from User where id = : userinfo.getuserid()].contactid;
    Contact obj_current_contact = new Contact();
    obj_current_contact = [Select id, Role__c, showTeamRecord__c, AccountId  from contact where id = :conid limit 1];
    if (obj_current_contact.Role__c == 'Admin') {
      Showteamrecord = obj_current_contact.showTeamRecord__c;
    }
    // added now
    list<Contact> clist = new List<Contact>();
    list<Contact> conlist = new list<contact>();
    List<Contact> adminlist = [select Id, AccountId from Contact where Role__c = 'Admin' AND AccountId = : obj_current_contact.AccountId];
    System.debug('adminlist===========>' + adminlist);

    if (Showteamrecord == True) {
      clist = [select id, AccountId from Contact where (manager__c in :adminlist OR Manager__r.Manager__c in :adminlist OR Manager__r.Manager__r.Manager__c in :adminlist OR Manager__r.Manager__r.Manager__r.Manager__c in :adminlist) AND Deactivated_Date__c = null];
      System.debug('clist===========>' + clist);
    } else {
      clist = [select id, AccountId from Contact where (manager__c = :conid OR Manager__r.Manager__c  = :conid OR Manager__r.Manager__r.Manager__c  = :conid OR Manager__r.Manager__r.Manager__r.Manager__c  = :conid) AND Deactivated_Date__c = null];
    }
    // list<Contact> clist2 = [select id,AccountId  from Contact where manager__c in :clist];
    //list<Contact> clist3 = [select id,AccountId  from Contact where manager__c in :clist2];
    // list<Contact> clist4 = [select id,AccountId  from Contact where manager__c in :clist3];
    //Contact_id__r.Manager__c = : u.contactid OR Contact_id__r.Manager__r.Manager__c = : u.contactid OR Contact_id__r.Manager__r.Manager__r.Manager__c = : u.contactid OR Contact_id__r.Manager__r.Manager__r.Manager__r.Manager__c = : u.contactid OR Contact_id__r.Manager__r.Manager__r.Manager__r.Manager__r.Manager__c = : u.contactid
    conlist.addall(clist);
    // conlist.addall(clist2);
    //   conlist.addall(clist3);
    //   conlist.addall(clist4);
    // completed added
    /* list<Contact> conlist = new list<contact>();
     list<Contact> clist1 =  [select id,AccountId from contact where manager__c =: conid ];
     conlist.addAll(clist1);
     if(!clist1.isEmpty()) {
         list<Contact> clist2 = [select id from contact where manager__c IN: clist1 And AccountId =: clist1[0].AccountId];
         conlist.addAll(clist2);

         if(!clist2.isEmpty()) {
             list<Contact> clist3 = [select id from contact where manager__c IN: clist2 And AccountId =: clist1[0].AccountId];
             conlist.addAll(clist3);
         }
     }*/

    list<Employee_Reimbursement__c> rmlist = new list<Employee_Reimbursement__c>();

    // getting the reimbursement reocords

    if (un != null)
      rmlist = [select id,
                name,
                month__c,
                Fuel_Price__c,
                (select id,
                 mileage__c,
                 Rejected__c,
                 EmployeeReimbursement__r.Month__c,
                 EmployeeReimbursement__c,
                 EmployeeReimbursement__r.Contact_Id__c
                 from Employees_Mileage__r
                 where Approved_Date__c = : null
                                          And Rejected__c != true
                                          LIMIT 5000)
                from Employee_Reimbursement__c
                where Approved_Date__c = : null AND
                                         (month__c = : lastmonth1 OR /*ADDED BY GOC*/
                                             month__c = : lastmonth2 OR
                                                 month__c = : lastmonth3 OR
                                                     month__c = : lastmonth4 OR
                                                         month__c = : lastmonth5 OR
                                                             month__c = : lastmonth6) And Contact_Id__c IN: conlist order BY Month__c Asc];
    else
      rmlist = [select id,
                name,
                month__c,
                Fuel_Price__c,
                (select id,
                 mileage__c,
                 Rejected__c,
                 EmployeeReimbursement__r.Month__c,
                 EmployeeReimbursement__c,
                 EmployeeReimbursement__r.Contact_Id__c
                 from Employees_Mileage__r  )
                from Employee_Reimbursement__c
                where (month__c = : lastmonth1 OR
                                  month__c = : lastmonth2 OR
                                             month__c = : lastmonth3 OR
                                                 month__c = : lastmonth4 OR
                                                     month__c = : lastmonth5 OR
                                                         month__c = : lastmonth6)
                AND Contact_Id__c IN: conlist order BY Month__c Asc];

    getdata = '';

    map<string, list<Employee_Reimbursement__c>> monthmap = new map<string, list<Employee_Reimbursement__c>>();
    set<string> mset = new set<string>();
    list<Employee_Reimbursement__c> rlist;
    list<Employee_Mileage__c> millist =  new list<Employee_Mileage__c>();

    // Creating the map of month to reimbursement
    for (Employee_Reimbursement__c r : rmlist) {
      rlist = new list<Employee_Reimbursement__c>();
      millist.addAll(r.Employees_Mileage__r);
      string m;
      if (r.Month__c != null) {
        string month = r.Month__c.left(2);
        m = getMonthName(month);
      }

      if (monthmap.get(m) != null)
        rlist.addAll(monthmap.get(m));
      rlist.add(r);

      monthmap.put(m, rlist);

    }

    map<string, decimal> reimToTotalMileageMap = new map<string, decimal>();
    // creating map of reimbursement and total mileage
    for (Employee_Mileage__c mil : millist) {
      decimal mileage = 0;
      string m;
      if (mil.EmployeeReimbursement__r.Month__c != null) {
        string month = mil.EmployeeReimbursement__r.Month__c.left(2);
        m = getMonthName(month);
      }
      if (reimToTotalMileageMap.get(m) != null)
        mileage += reimToTotalMileageMap.get(m);
      if (mil.mileage__c != null)
        mileage += mil.mileage__c;

      reimToTotalMileageMap.put(m, mileage);

    }
    // creating the json format for graph
    monthmap.clear();
    for (string m : allMonths) {
      decimal temp = 0.0;
      getdata += '{"Month": "' + m + '",';

      if (reimToTotalMileageMap.get(m) != null)
        temp += reimToTotalMileageMap.get(m);
      getdata += '"Mileage": ' + temp + ', },' ;
    }
  }
  public static String getMonthName(String monthNumber) {
    return (monthNumber == '1-') ? 'January' :
           (monthNumber == '2-') ? 'February' :
           (monthNumber == '3-') ? 'March' :
           (monthNumber == '4-') ? 'April' :
           (monthNumber == '5-') ? 'May' :
           (monthNumber == '6-') ? 'June' :
           (monthNumber == '7-') ? 'July' :
           (monthNumber == '8-') ? 'August' :
           (monthNumber == '9-') ? 'September' :
           (monthNumber == '01') ? 'January' :
           (monthNumber == '02') ? 'February' :
           (monthNumber == '03') ? 'March' :
           (monthNumber == '04') ? 'April' :
           (monthNumber == '05') ? 'May' :
           (monthNumber == '06') ? 'June' :
           (monthNumber == '07') ? 'July' :
           (monthNumber == '08') ? 'August' :
           (monthNumber == '09') ? 'September' :
           (monthNumber == '10') ? 'October' :
           (monthNumber == '11') ? 'November' :
           (monthNumber == '12') ? 'December' :
           'Invalid Month';
  }
}