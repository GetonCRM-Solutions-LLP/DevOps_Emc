public class FindMissingFuelPriceController { 

    public List<SelectOption> options {get; set;}
    public String selectedValue {get; set;}
    public String emailTo {get; set;}
    public String message {get; set;}

    public List<SelectOption> getdateMonthList() {
        options = new List<SelectOption>();
        for(integer i = 0; i >= -3; i--){
            String monthValue = '';
            if(date.today().addMonths(i).month() < 10){
                monthValue = '0' + string.valueOf(date.today().addMonths(i).month());
            }
            else {
                monthValue = string.valueOf(date.today().addMonths(i).month());
            }
            String monthYear = monthValue + '-'+ date.today().addMonths(i).year();
            options.add(new SelectOption(monthYear,monthYear));
        }
        System.debug('options=='+options);              
        return options;
    }

    public PageReference submit(){
        System.debug('emailTo=='+emailTo);

        if(!String.isBlank(emailTo))
        {
            RG_InsertLastMonthReimbursement reimbursementtobecreated= new RG_InsertLastMonthReimbursement(selectedValue,emailTo);
            Database.executeBatch(reimbursementtobecreated, 200);
            message = 'Please check on email id '+emailTo + ' for missing fuel price.'; 
        }

        if(String.isBlank(emailTo))
        {
            RG_InsertLastMonthReimbursement reimbursementtobecreated= new RG_InsertLastMonthReimbursement(selectedValue);
            Database.executeBatch(reimbursementtobecreated, 200);
            message = 'Please check on email id '+Label.Email_To_Address + ' for missing fuel price.';             
        }        
        return null;
    }
}