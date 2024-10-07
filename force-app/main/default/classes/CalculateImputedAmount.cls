public class CalculateImputedAmount
{     
    public String taxCalYear;
    public Account acc;

    public CalculateImputedAmount(ApexPages.StandardController stdcontroller)
    {
        if (!Test.isRunningTest()){
            stdController.addFields(new List<String>{'Tax_Calculation_Year__c'}); 
        }     
        acc = (Account)stdcontroller.getRecord();        
        taxCalYear = acc.Tax_Calculation_Year__c;        
    }

    public void contAnnualTaxUpadte(){
        String errorMessage = '';
        Datetime lastDeactivateDate;
        try{
            lastDeactivateDate = datetime.newInstance(Integer.valueOf(taxCalYear)-1, 12, 1);         
            /*
            if(Integer.valueOf(taxCalYear)==System.Today().Year())
            {
                lastDeactivateDate = System.now();                
            }
            else
            {
                lastDeactivateDate = datetime.newInstance(Integer.valueOf(taxCalYear), 12, 31);               
            }
            */

        }catch(Exception ex){
            errorMessage = 'Please enter valid year in Tax Calculation Year';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,errorMessage));
        }

        List<Id> contIdList = new List<Id>();        
        if(errorMessage == ''){
            for(Contact con:[Select id                            
                            From contact
                            Where Account.id =: acc.id and (Deactivated_Date__c >=: lastDeactivateDate OR Deactivated_Date__c= NULL)]){
                contIdList.add(con.Id);
            }
            System.debug('lastDeactivateDate=='+lastDeactivateDate); 
            System.debug('contIdList size=='+contIdList.size());
            System.debug('contIdList=='+contIdList);          
            CalculateImputedIncome.getImputedIncome(contIdList, taxCalYear);
        }      
    }

    public pagereference backMethod()
    {
        Pagereference pg =  new Pagereference('/'+acc.Id);        
        pg.setRedirect(true);
        return pg;
    }
}