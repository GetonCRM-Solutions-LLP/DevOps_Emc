global class RG_ContactBatchEmail implements Database.Batchable<sObject> 
{
    
    list<contact> cont = new list<contact>();
    
    //Start Method
    global list<contact> start(Database.BatchableContext BC) {
        
        cont = [select id,
                       FirstName,
                       email,
                       External_Email__c,
                       (select id,
                               Month__c,
                               Fuel_Price__c,
                               Total_Mileage__c,
                               Fuel_Variable_Rate__c,
                               Monthly_Variable_Amount__c,
                               Fixed_Amount__c,
                               Monthly_Total_Reimbursement__c,
                               Contact_Id__c,
                               Status__c 
                        from Employee_Reimbursements__r) 
                from contact ];
        return cont;
        
    }
    
    //Execute Method
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        
        OrgWideEmailAddress[] owea = [select Id ,address from OrgWideEmailAddress where Address = 'driverservices@mburse.com'];
        for(contact c : scope)
        {
            Decimal Mileage1 = 0;
            Decimal VariableAmount1 = 0;
            Decimal FixedAmount1 = 0;
            Decimal Total1 = 0;
            string htmlBody = 'Hi '+c.FirstName+'<br/><br/>'
                +'Your reimbursement statement below reflects all approved mileage last month. <br/><br/> Cheers <br/><br/>'
                +'<div style = "border:2px border-radius:15px;">'
                +'<table style = "border:3px solid black; border-collapse:collapse;">'
                +'<tr  bgcolor = "#d4d4d4">'
                +'<th style = "border:2px solid black;" width = "5%">Month</th>'
                +'<th style = "border:2px solid black;" width = "5%">Gas Price</th>'
                +'<th style = "border:2px solid black;" width = "5%">Mileage</th>'
                +'<th style = "border:2px solid black;" width = "5%">Variable Rate</th>'
                +'<th style = "border:2px solid black;" width = "5%">Variable Amount</th>'
                +'<th style = "border:2px solid black;" width = "5%">Fixed Amount</th>'
                +'<th style = "border:2px solid black;" width = "5%">Total Reimbursement</th>'
                +'<th style = "border:2px solid black;" width = "5%">Status</th>'
                +'</tr>';
            
            for(Employee_Reimbursement__c r:c.Employee_Reimbursements__r) {
                String Month;
                Decimal FuelPrice;
                Integer Mileage;
                Decimal VariableRate;
                Decimal VariableAmount;
                Decimal FixedAmount;
                Decimal Total;
                
                if(r.Month__c != '' && r.Month__c != null ) {
                    Month = r.Month__c;
                } else {
                    Month = '0';
                }
                
                if(r.Fuel_Price__c != null) {
                    FuelPrice = r.Fuel_Price__c;
                } else {
                    FuelPrice = 0;
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
                } else  {
                    Total  =  0;
                }
                
                
                string status = String.isnotBlank(r.status__c)?r.status__c:'';
                htmlBody = htmlBody+'<tr align = "center">'
                    +'<td  style = "border:2px solid black;">'+Month+'</td>'
                    +'<td  style = "border:2px solid black;">'+FuelPrice+'</td>'
                    +'<td  style = "border:2px solid black;">'+Mileage+'</td>'
                    +'<td  style = "border:2px solid black;">'+'$'+VariableRate+'</td>'
                    +'<td  style = "border:2px solid black;">'+'$'+VariableAmount+'</td>'
                    +'<td  style = "border:2px solid black;">'+'$'+FixedAmount+'</td>'
                    +'<td  style = "border:2px solid black;">'+'$'+Total+'</td>'
                    +'<td  style = "border:2px solid black;">'+''+status+'</td>'
                    +'</tr>';
                
                
                Mileage1 += Mileage;
                VariableAmount1 += VariableAmount;
                FixedAmount1 += FixedAmount;  
                Total1 += Total;                
                
            }
            htmlBody = htmlBody+'<tr align = "center" bgcolor = "#d4d4d4">'
                +'<td  style = "border:2px solid black;">'+'<b>Total</b>'+'</td>'
                +'<td  style = "border:2px solid black;"></td>'
                +'<td  style = "border:2px solid black;"><b>'+Mileage1+'</b></td>'
                +'<td  style = "border:2px solid black;"></td>'
                +'<td  style = "border:2px solid black;">'+'<b>$'+VariableAmount1+'</b></td>'
                +'<td  style = "border:2px solid black;">'+'<b>$'+FixedAmount1+'</b></td>'
                +'<td  style = "border:2px solid black;">'+'<b>$'+Total1+'</b></td>'
                +'<td  style = "border:2px solid black;">&nbsp;</td>'
                +'</tr>'
                +'</table>'
                +'</div>';
            
            //Sending Mail          
            messaging.singleEmailMessage mail = new messaging.singleEmailMessage();
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            //Setting user email in to address
            String[] toAddresses = new String[] {c.External_Email__c} ;
            // Assign the addresses for the To and CC lists to the mail object
            mail.setToAddresses(toAddresses) ;
            //Email subject to be changed
            mail.setSubject('Your Monthly Reimbursement Statement');
            //Body of email
            mail.setHtmlBody(htmlBody);
            //Sending the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });          
        }
    }

    global void finish(Database.BatchableContext BC) {
    }
}