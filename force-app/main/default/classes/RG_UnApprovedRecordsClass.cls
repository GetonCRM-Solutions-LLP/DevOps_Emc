public class RG_UnApprovedRecordsClass {
  public boolean isSuperManager {get; set;}
  public boolean isSuperManagerDriver {get; set;}
  public id conid {get; set;}
  public list<RembWrap> wraplist {get; set;}
  public boolean EnableReports {get; set;}
  public String pageMsg {get; set;}
  public boolean isSuccess {get; set;}
  public Boolean isManager {get; set;}
  public User u {get; set;}
  public List<contact> obj_contact_list {get; set;}
  public List<String> obj_adminemailids_list {get; set;}
  list<Employee_Reimbursement__c> templist;
  list<Employee_Mileage__c> temilist;
  public Set<id> drsIDs {get; set;}
  public Set<string> emailAddress {get; set;}
  public map<string, map<string, string>> managerToDriverMonthNames {get; set;}
  public boolean showTeamRecord {get; set;}
  public List<String> contactids {get; set;}

  public RG_UnApprovedRecordsClass() {
    drsIDs = new  Set<id>();
    contactids = new List<String>();
    emailAddress = new  Set<string>();
    managerToDriverMonthNames = new  map<string, map<string, string>>();
    obj_contact_list = new List<contact>();
    obj_adminemailids_list = new List<String>();
    set<id> conidlist = new  set<id>();
    wraplist = new  list<RembWrap>();

    pageMsg = '';
    u = [SELECT
         Id,
         Name,
         profile.name,
         contactid,
         Contact.AccountId,
         Contact.showTeamRecord__c,
         Contact.Role__c
         FROM
         user
         WHERE
         Id = : userinfo.getuserid()]; // '005e0000004oxjC'];
    contactids.add(u.contact.id);
    if (u.profile.name == 'Customer Community Login User - Super Manager') {
      isSuperManager = true;
      // admin
      if (u.contact.Role__c == 'Admin' && u.contact.showTeamRecord__c == true) {
        for (Contact c : [select id from contact where Account.id = :u.Contact.AccountId and Role__c = 'Admin' AND Deactivated_Date__c = null]) {
          contactids.add(c.id);
        }
      }
    }
    if (u.profile.name == 'Customer Community Login User - Manager' || u.profile.name == 'Customer Community Login User - Manager/Driver') {
      isManager = true;
    }
    if (u.profile.name == 'Customer Community Login User - Super Manager/Driver') {
      isSuperManagerDriver = true;
      conid = u.contactid;
    }
    if (u.contactid != null) {
      EnableReports = [SELECT
                       Enable_Reports__c
                       FROM
                       contact
                       WHERE
                       Id = : u.contactid].Enable_Reports__c;
    }
    /* COMMENTED BY GOC
    list<Gas_Prices__c> gasprice = [SELECT
        Id,
        Fuel_Price__c,
        Month_Year__c,
        State__c,
        City__c
    FROM
        Gas_Prices__c];*/
    id compid = u.Contact.AccountId;
    obj_contact_list = [select id, name, External_Email__c from contact where Role__c = 'Admin' and Accountid = :compid];
    if ((obj_contact_list != null) && (obj_contact_list.size() > 0)) {
      for (Contact obj_currentcontact : obj_contact_list) {
        obj_adminemailids_list.add(obj_currentcontact.External_Email__c);
      }

    }
    System.debug('compid: ' + compid);
    System.debug('getcurrentUserCompanyId: ' + getcurrentUserCompanyId());
    list<Employee_Reimbursement__c> remblist = [SELECT
        ID,
        Name,
        Maintenance_and_Tires__c,
        Status__c,
        MPG__c,
        Contact_Id__r.Manager__r.Email,
        Contact_Id__r.Manager__c,
        Fuel_Variable_Rate__c,
        Contact_Id__r.MailingStreet,
        Contact_Id__r.Pre_Auto_Allowance_Amount__c,
        Contact_Id__r.compliancestatus__c,
        Contact_Id__r.Vehicle_Type__c,
        Contact_Id__r.Vehicle2Odometer__c,
        Contact_Id__r.Vehicle1Odometer__c,
        Contact_Id__r.MailingCountry,
        Contact_Id__r.MailingPostalCode,
        Contact_Id__r.MailingCity,
        Contact_Id__r.MailingState,
        Contact_Id__r.Monthly_Fuel_Price__c,
        Month__c,
        Contact_Id__r.manager__r.Name,
        Fuel_Price__c,
        Contact_Id__c,
        Contact_Id__r.Fixed_Amount__c,
        Contact_Id__r.Name,
        Contact_Id__r.Monthly_Mileage_Limit__c,
        Approved_Date__c,
        (SELECT
         Id,
         Reason_for_Rejection__c,
         EmployeeReimbursement__r.Contact_Id__c,
         CreatedDate,
         Approved_Date__c,
         EmployeeReimbursement__r.Contact_Id__r.MPG__c,
         EmployeeReimbursement__r.Contact_Id__r.Maintenance_and_Tires__c,
         Name,
         Mileage__c,
         Trip_Destination__c,
         Trip_Date__c,
         Trip_Origin__c,
         Rejected__c
         FROM
         Employees_Mileage__r
         WHERE
         Approved_Date__c = : null AND Rejected__c != true
                            LIMIT 5000)
        FROM
        Employee_Reimbursement__c
        WHERE
        Approved_Date__c = : null AND Contact_id__r.Accountid = : compid AND
                           (Contact_id__r.Manager__c = : contactids OR Contact_id__r.Manager__r.Manager__c = : contactids OR Contact_id__r.Manager__r.Manager__r.Manager__c = : contactids OR Contact_id__r.Manager__r.Manager__r.Manager__r.Manager__c = : contactids OR Contact_id__r.Manager__r.Manager__r.Manager__r.Manager__r.Manager__c = : contactids) AND (Contact_id__r.Role__c ='Driver' OR Contact_id__r.Role__c ='Driver/Manager')
                           ORDER BY
                           contact_id__r.name];
    map<id, list<Employee_Reimbursement__c>> conidtoemplistmap = new  map<id, list<Employee_Reimbursement__c>>();
    for (Employee_Reimbursement__c r : remblist) {
      if (conidtoemplistmap.containsKey(r.Contact_Id__c)) {
        conidtoemplistmap.get(r.Contact_Id__c).add(r);
      } else {
        conidtoemplistmap.put(r.Contact_Id__c, new List<Employee_Reimbursement__c> {r});
      }
    }
    list<Employee_Reimbursement__c> rmlist;
    map<id, list<Employee_Reimbursement__c>> conmap = new  map<id, list<Employee_Reimbursement__c>>();
    /* COMMENTED BY GOC
    list<AuditTrail__c> AuditTrail = [SELECT
        id,
        Contact__c,
        Field__c,
        NewValue__c,
        OldValue__c,
        Timestamp__c,
        Modifiedby__c
    FROM
        AuditTrail__c
    WHERE
        Contact__c in: conidlist
    ORDER BY
        Timestamp__c limit 5000];*/
    Integer maxcount = 1000;
    for (id i : conidtoemplistmap.keyset()) {
      System.debug('maxcount before: ' + maxcount);
      if (maxcount > 0) {
        RembWrap r = new  RembWrap(conidtoemplistmap.get(i), false, false, null);
        if ((r.Email != '' && r.Email != null)) {
          wraplist.add(r);
          System.debug('wraplist: ' + wraplist);
        }
        maxcount--;
      }
    }
  }

  /**** Send Email mathod ****/
  public void sendEmail() {
    pageMsg = '';
    emailAddress = new  Set<string>();
    OrgWideEmailAddress[] owea = [SELECT
                                  Id,
                                  address
                                  FROM
                                  OrgWideEmailAddress
                                  WHERE
                                  Address = 'driverservices@mburse.com'];
    Map<string, string> managerNameToEmail = new  Map<string, string>();
    Set<String> selectedConIds = new Set<String>();
    /**** Get Set Of manager's email id ****/
    for (RembWrap w : wraplist) {
      System.debug('w.isCheck----' + w.isCheck);
      if (w.isCheck == true) {
        emailAddress.add(w.Email);
        selectedConIds.add(w.conid);
      }
    }
    /**** Get Manager's Driver Records ****/
    for (Contact managers : [SELECT
                             id,
                             Name,
                             (SELECT
                              id,
                              Name
                              FROM
                              Drivers__r)
                             FROM
                             Contact
                             WHERE
                             External_Email__c in: emailAddress]) {
      for (Contact drsRecord : managers.Drivers__r) {
        drsIDs.add(managers.id);
      }
    }
    /**** Get Driver's Employee Reimbursements Month which is null ****/

    for (Contact drCon : [SELECT
                          id,
                          Name,
                          Manager__r.External_Email__c,
                          Manager__r.FirstName,
                          Manager__r.name,
                          (SELECT
                           Id,
                           Month__c,
                           Contact_Id__c
                           FROM
                           Employee_Reimbursements__r
                           WHERE
                           Approved_Date__c = null
                               ORDER BY
                               Month__c
                               LIMIT 1)
                          FROM
                          Contact
                          WHERE
                          Manager__c in: drsIDs and Id In: selectedConIds]) {
      string reimbursementMonth = '';
      if (!drCon.Employee_Reimbursements__r.isEMpty()) {
        reimbursementMonth = drCon.Employee_Reimbursements__r[0].Month__c;

        if (!managerToDriverMonthNames.containsKey(drCon.Manager__r.External_Email__c)) {
          managerToDriverMonthNames.put(drCon.Manager__r.External_Email__c, new Map<string, string> {
            drCon.Name => reimbursementMonth
          });
        } else {
          managerToDriverMonthNames.get(drCon.Manager__r.External_Email__c).put(drCon.Manager__r.Name, reimbursementMonth);
        }
      }

      managerNameToEmail.put(drCon.Manager__r.External_Email__c, drCon.Manager__r.FirstName);
    }
    List<Messaging.SingleEmailMessage> mail_list = new List<Messaging.SingleEmailMessage>();

    if (!managerToDriverMonthNames.isEmpty()) {
      for (string managerEmail : managerToDriverMonthNames.keySet()) {
        string htmlBody = 'Hi ' + managerNameToEmail.get(managerEmail) + ',<br/><br/>' + 'We are approaching the mileage approval deadline. Please do not forget to approve your employees mileage.' + '<br/><br/>' + '<div style="border:2px border-radius:15px;">' + '<table style="border:3px solid black; border-collapse:collapse;">' + '<tr bgcolor="#d4d4d4">' + '<th style="border:2px solid black;" width="5%">Driver Name</th>' + '<th style="border:2px solid black;" width="5%">Month</th>' + '</tr>';
        Map<string, string> driverMonthnames = managerToDriverMonthNames.get(managerEmail);
        for (string driverName : driverMonthnames.keySet()) {
          htmlBody = htmlBody + '<tr bgcolor="#d4d4d4">' + '<td style="border:2px solid black;padding-left : 10px;" width="5%">' + driverName + '</td>' + '<td style="border:2px solid black;padding-left : 10px;" width="5%">' + driverMonthnames.get(driverName) + '</td>' + '</tr>';
        }
        htmlBody = htmlBody + '</table> <br/> <br/>If you would like us to approve the mileage, please respond to this email.' + '<br/><br/>Thank you,<br/><br/>Driver Services';
        /**** Sending Mail ****/
        Messaging.SingleEmailMessage mail = new  Messaging.SingleEmailMessage();
        if (!owea.isEmpty()) {
          mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        string[] toAddresses = new string[] {managerEmail};
        if (obj_adminemailids_list.size() > 0) {
          toAddresses.addAll(obj_adminemailids_list);

        }
        List<string> toAddresses1 = new List<string>();
        //      toAddresses1.add('sanjayh.goc@gmail.com');
        //     mail.setToAddresses(toAddresses1);
        mail.setToAddresses(toAddresses);
        //       mail.setBccAddresses(new string[]{'minkesh.patel@getoncrm.com'});
        /**** Email subject to be changed ****/
        mail.setSubject('Your Monthly Reimbursement Statement');
        /**** Body of email ****/
        mail.setHtmlBody(htmlBody);
        mail_list.add(mail);
        /**** Sending the email ****/
        if (mail_list.size() > 0) {
          System.debug(mail_list.Size());
          System.debug(mail_list);
          try {
            // Messaging.sendEmail(mail_list);
            ApexPages.addmessage(new  ApexPages.message(ApexPages.severity.CONFIRM, 'Your email has been sent'));
            isSuccess = true;
            pageMsg = 'Your email has been sent.';
            mail_list.clear();
          } catch (Exception e) {
            ApexPages.addMessage(new  ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            isSuccess = false;
            pageMsg = e.getMessage();
          }
        }
      }
    }
  }
  public void UpdateRecord() {
    pageMsg = '';
    Id Compid = getcurrentUserCompanyId();
    list<Employee_Reimbursement__c> remblist = [SELECT
        id,
        Name,
        Maintenance_and_Tires__c,
        Status__c,
        MPG__c,
        Fuel_Variable_Rate__c,
        Contact_Id__r.MailingStreet,
        Contact_Id__r.Manager__r.Email,
        Contact_Id__r.Pre_Auto_Allowance_Amount__c,
        Contact_Id__r.compliancestatus__c,
        Contact_Id__r.Vehicle_Type__c,
        Contact_Id__r.Vehicle2Odometer__c,
        Contact_Id__r.Vehicle1Odometer__c,
        Contact_Id__r.MailingCountry,
        Contact_Id__r.MailingPostalCode,
        Contact_Id__r.MailingCity,
        Contact_Id__r.MailingState,
        Contact_Id__r.Monthly_Fuel_Price__c,
        Month__c,
        Fuel_Price__c,
        Contact_Id__c,
        Contact_Id__r.Fixed_Amount__c,
        Contact_Id__r.Name,
        Contact_Id__r.Monthly_Mileage_Limit__c,
        Approved_Date__c,
        (SELECT
         id,
         Reason_for_Rejection__c,
         EmployeeReimbursement__r.Contact_Id__c,
         CreatedDate,
         Approved_Date__c,
         EmployeeReimbursement__r.Contact_Id__r.MPG__c,
         EmployeeReimbursement__r.Contact_Id__r.Maintenance_and_Tires__c,
         Name,
         Mileage__c,
         Trip_Destination__c,
         Trip_Date__c,
         Trip_Origin__c,
         Rejected__c
         FROM
         Employees_Mileage__r
         WHERE
         Approved_Date__c = : null AND Rejected__c != true
                            LIMIT 5000)
        FROM
        Employee_Reimbursement__c
        WHERE
        Approved_Date__c = : null AND Contact_id__r.Accountid = : compid AND
                           (Contact_id__r.Manager__c = : u.contactid OR Contact_id__r.Manager__r.Manager__c = : u.contactid OR Contact_id__r.Manager__r.Manager__r.Manager__c = : u.contactid OR Contact_id__r.Manager__r.Manager__r.Manager__r.Manager__c = : u.contactid OR Contact_id__r.Manager__r.Manager__r.Manager__r.Manager__r.Manager__c = : u.contactid)
                           ORDER BY
                           contact_id__r.name];
    map<id, list<Employee_Reimbursement__c>> conidtoemplistmap = new  map<id, list<Employee_Reimbursement__c>>();
    for (Employee_Reimbursement__c r : remblist) {
      if (conidtoemplistmap.containsKey(r.Contact_Id__c)) {
        conidtoemplistmap.get(r.Contact_Id__c).add(r);
      } else {
        conidtoemplistmap.put(r.Contact_Id__c, new List<Employee_Reimbursement__c> {r});
      }
    }
    templist = new  list<Employee_Reimbursement__c>();
    temilist = new  list<Employee_Mileage__c>();
    Map<Id, Contact> idToContact = new  Map<Id, Contact>();
    for (RembWrap w : wraplist) {
      if (w.b) {
        for (Employee_Reimbursement__c r : conidtoemplistmap.get(w.conid)) {
          r.Status__c = 'Approved';
          r.Approved_Date__c = date.today();
          templist.add(r);
          if (r.Employees_Mileage__r != null) {
            for (Employee_Mileage__c m : r.Employees_Mileage__r) {
              m.Approved_Date__c = Date.today();
              temilist.add(m);
            }
          }

        }
      }
      if (!string.isBlank(w.monthlythershold)) {
        idToContact.put(w.conid, new  Contact(Id = w.conid, Monthly_Mileage_Limit__c = decimal.valueOf(w.monthlythershold)));
      }
    }
    if (templist.size() > 0) {
      Update templist;
    }
    if (temilist.size() > 0) {
      Update temilist;
    }
    if (!idToContact.isEmpty()) {
      Update idToContact.values();
    }
  }
  public class RembWrap {
    public String Name                                  {get; set;}
    public String Email                                 {get; set;}
    public boolean b                                    {get; set;}
    public boolean isCheck                              {get; set;}
    public string conid                                 {get; set;}
    public decimal submil                               {get; set;}
    public String monthlythershold                      {get; set;}
    transient list<Employee_Reimbursement__c> rmlist    {get; set;}

    public RembWrap(list<Employee_Reimbursement__c> rmlist, boolean b, Boolean isCheck, list<Gas_Prices__c> gas) {
      this.rmlist = new  list<Employee_Reimbursement__c>(rmlist);
      this.submil = 0;
      conid = rmlist[0].Contact_Id__c;
      if (rmlist[0].Contact_Id__r.Monthly_Mileage_Limit__c != null) {
        this.monthlythershold = string.valueof(rmlist[0].contact_id__r.Monthly_Mileage_Limit__c);
      }
      if (rmlist[0].contact_id__r.Name != null) {
        this.Name = rmlist[0].contact_id__r.Name;
      }
      this.Email = rmlist[0].Contact_Id__c != null ? (rmlist[0].Contact_Id__r.Manager__c != null ? (rmlist[0].Contact_Id__r.Manager__r.Email != null ? rmlist[0].Contact_Id__r.Manager__r.Email : '') : '') : '';
      this.b = b;
      this.isCheck = isCheck;
      for (Employee_Reimbursement__c r : rmlist) {
        if (r.Employees_Mileage__r != null) {
          for (Employee_Mileage__c m : r.Employees_Mileage__r) {
            if (m.mileage__c != null && !m.rejected__c && m.Approved_Date__c == null) {
              submil += m.mileage__c.setScale(2);
            }
          }
        } else {
          submil = 0;
        }

      }
    }
  }
  public static Id getcurrentUserCompanyId() {
    id UserId = userinfo.getUserId();
    return [SELECT
            contact.accountid
            FROM
            user
            WHERE
            Id = : UserId].contact.accountid;
  }
}