global class SendReimbursementEmail {
    WebService static Void sendEmail(String accountId) {
        Reimbursement_Email_Period__c rep = Reimbursement_Email_Period__c.getInstance('Reimbursement Period');
        if(rep != null) {
            String fromMonth = String.valueOf(rep.From_Date__c.month());
            String fromYear = String.valueOf(rep.From_Date__c.year());
            String toMonth = String.valueOf(rep.To_Date__c.month());
            String toYear = String.valueOf(rep.To_Date__c.year());
            Integer monthsBetween = rep.From_Date__c.monthsBetween(rep.To_Date__c);
            String months = '';
            if(fromMonth.length() == 1) {
                fromMonth = '0' + fromMonth;
            }
            if(toMonth.length() == 1) {
                toMonth = '0' + toMonth;
            }
            
            months = fromMonth + '-' + fromYear;
            
            for(Integer i = 0; i < monthsBetween; i++) {
                fromMonth = String.valueOf(Integer.valueOf(fromMonth));
                if(fromMonth == '12') {
                    fromMonth = '01' ;
                    fromYear = String.valueOf(Integer.valueOf(fromYear) + 1);
                }
                else {
                    fromMonth = String.valueOf(Integer.valueOf(fromMonth) + 1);
                }
                if(fromMonth.length() == 1) {
                    fromMonth = '0' + fromMonth;
                    if(fromMonth == '01') {

                        fromYear = String.valueOf(Integer.valueOf(fromYear) + 1);
                    }
                }
                months += ',' + fromMonth + '-' + fromYear;
                if(fromMonth == '12') {
                    fromMonth = '0';
                }
            }
            List<String> allMonths = months.split(',');
            Id batchJobId = Database.executeBatch(new SendReimbursementEmailBatch(allMonths, accountId), 1);
        }
    }
}