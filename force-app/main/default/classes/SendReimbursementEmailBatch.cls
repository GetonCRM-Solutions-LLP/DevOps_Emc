global class SendReimbursementEmailBatch implements Database.Batchable<sObject> {
    global final List<String> allMonths;
    global final String accountId;
    
    public SendReimbursementEmailBatch(List<String> allMonths, String accountId) {
        this.allMonths = allMonths;
        this.accountId = accountId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,FirstName,Email,External_Email__c, (SELECT Id, Month__c, Fuel_Price__c, Total_Mileage__c, Fuel_Variable_Rate__c, Monthly_Variable_Amount__c, Fixed_Amount__c, Monthly_Total_Reimbursement__c, Contact_Id__c, Status__c FROM Employee_Reimbursements__r WHERE Month__c IN : allMonths) FROM Contact WHERE AccountId =: accountId';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        OrgWideEmailAddress[] owea = [select Id, address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
        for(Contact contact : (List<Contact>) scope) {
            decimal Mileage1 = 0;
            decimal VariableAmount1 = 0;
            decimal FixedAmount1 = 0;
            decimal Total1 = 0;
            string htmlBody = 'Hi ' + contact.FirstName + '<br/><br/>' + 'Your reimbursement statement below reflects all approved mileage last month. <br/><br/> Cheers <br/><br/>' + '<div style="border:2px border-radius:15px;">' + '<table style="border:3px solid black; border-collapse:collapse;">' + '<tr  bgcolor="#d4d4d4">' + '<th style="border:2px solid black;" width="5%">Month</th>' + '<th style="border:2px solid black;" width="5%">Mileage</th>' + '<th style="border:2px solid black;" width="5%">Variable Rate</th>' + '<th style="border:2px solid black;" width="5%">Variable Amount</th>' + '<th style="border:2px solid black;" width="5%">Fixed Amount</th>' + '<th style="border:2px solid black;" width="5%">Total Reimbursement</th>' + '</tr>';
            for(Employee_Reimbursement__c r: contact.Employee_Reimbursements__r) {
                string Month;
                decimal FuelPrice;
                Integer Mileage;
                decimal VariableRate;
                decimal VariableAmount;
                decimal FixedAmount;
                decimal Total;
                
                if(r.Month__c != '' && r.Month__c != null) {
                    Month = r.Month__c;
                } else {
                    Month = '0';
                }
                
                if(r.Total_Mileage__c != null) {
                    Mileage = Integer.valueof(r.Total_Mileage__c);
                } else {
                    Mileage = 0;
                }
                
                if(r.Fuel_Variable_Rate__c != null) {
                    VariableRate = r.Fuel_Variable_Rate__c;
                } else {
                    VariableRate = 0;
                }
                
                if(r.Monthly_Variable_Amount__c != null) {
                    VariableAmount = r.Monthly_Variable_Amount__c;
                } else {
                    VariableAmount = 0;
                }
                
                if(r.Fixed_Amount__c != null) {
                    FixedAmount = r.Fixed_Amount__c;
                } else {
                    FixedAmount = 0;
                }
                
                if(r.Monthly_Total_Reimbursement__c != null) {
                    Total = r.Monthly_Total_Reimbursement__c;
                } else {
                    Total = 0;
                }
                string status = string.isnotBlank(r.status__c) ? r.status__c : '';
                htmlBody = htmlBody + '<tr align="center">' + '<td  style="border:2px solid black;">' + Month + '</td>' + '<td  style="border:2px solid black;">' + Mileage + '</td>' + '<td  style="border:2px solid black;">' + '$' + VariableRate + '</td>' + '<td  style="border:2px solid black;">' + '$' + VariableAmount + '</td>' + '<td  style="border:2px solid black;">' + '$' + FixedAmount + '</td>' + '<td  style="border:2px solid black;">' + '$' + Total + '</td>' + '</tr>';
                Mileage1 += Mileage;
                VariableAmount1 += VariableAmount;
                FixedAmount1 += FixedAmount;
                Total1 += Total;
            }
            if(contact.Employee_Reimbursements__r.size()>0) {
                htmlBody = htmlBody + '<tr align="center" bgcolor="#d4d4d4">' + '<td  style="border:2px solid black;">' + '<b>Total</b>' + '</td>' + '<td  style="border:2px solid black;"><b>' + Mileage1 + '</b></td>' + '<td  style="border:2px solid black;"></td>' + '<td  style="border:2px solid black;">' + '<b>$' + VariableAmount1 + '</b></td>' + '<td  style="border:2px solid black;">' + '<b>$' + FixedAmount1 + '</b></td>' + '<td  style="border:2px solid black;">' + '<b>$' + Total1 + '</b></td>' + '</tr>' + '</table>' + '</div>';
                //Sending Mail          
                messaging.singleEmailMessage mail = new  messaging.singleEmailMessage();
                if(owea.size() > 0) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                System.debug('contact.External_Email__c: '+contact.External_Email__c);
                //Setting user email in to address
                string[] toAddresses = new string[]{contact.External_Email__c};
                // Assign the addresses for the To and CC lists to the mail object
                mail.setToAddresses(toAddresses);
                //Email subject to be changed
                mail.setSubject('Your Monthly Reimbursement Statement');
                //Body of email
                mail.setHtmlBody(htmlBody);
                //Sending the email
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}