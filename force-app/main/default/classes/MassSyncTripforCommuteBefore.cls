global with sharing class MassSyncTripforCommuteBefore {
webService static void validate(String accountId,String minDate,String maxDate,String month,String status,Boolean putapi, String activityStatus) {
      List<Account> accList = new List<Account>();
      accList = [Select id from account where id = : accountId];
      if(!Test.isRunningTest()) {
          Database.executeBatch(new MassSyncTripforCommute(accountId,minDate,maxDate,month,status,putapi,activityStatus),1); }   } }