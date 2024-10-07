trigger checkPayPeriodValues on Account (before insert, before update) {
    if(Trigger.isBefore ){
        if(Trigger.IsInsert || Trigger.IsUpdate){
            for(Account accList:Trigger.new){
                if(accList.Pay_Period_Start_Date__c == null){
                    accList.Pay_Period_Start_Date__c = System.today();
                }
                if(accList.Pay_Period_Days__c == null){
                    accList.Pay_Period_Days__c = 13;
                }
            }
        }
    }
    
}