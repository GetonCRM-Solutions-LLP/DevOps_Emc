/**
 * Author: Sanjay Halpati
 * Created Date: 24 June 2020
 * Description: Batch class to send email with missing fule price file for Current Month.
 * Dependent classes: 
 * 1. AggregateResult.cls
 * 2. AggregateResultIterable.cls
 */
global class SendMissingFuelPriceBatch implements Database.Batchable<AggregateResult>, Database.Stateful {

    global List<Date> WeeksDates = new List<Date>();
    global Date startOfMonth = System.today().toStartOfMonth();
    global Integer weeksInMonths = Utils.weekOfMonth(startOfMonth.addMonths(1).addDays(-1));
    global List<String> states = Utils.FetchStates();
    global String csvColumnHeader;
    global List<String> csvRowValues = new List<String>();

    global SendMissingFuelPriceBatch() {
        Date startadate = startOfMonth;
        Date enddate;
        for(Integer w = 1; w <= weeksInMonths; w++) {
            WeeksDates.add(startadate);
            enddate = startadate.toStartOfWeek().addDays(6);
            if(w == weeksInMonths)
                enddate = startOfMonth.addMonths(1).addDays(-1);

            startadate = enddate.addDays(1);
        }
    }
    global Iterable<AggregateResult> start(Database.BatchableContext BC) {
        String query = 'SELECT Count(Id), MailingState FROM Contact WHERE MailingState != null AND' +
                     ' (Role__c = \'Driver\' OR Role__c = \'Driver/Manager\' OR Role__c = \'Admin/Driver\') ' +
                     ' Group By MailingState LIMIT 999';
        return new AggregateResultIterable(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) { 
        
        String state = (String) scope.get(0).get('MailingState');
        List<String> cities = new List<String>();
        for(AggregateResult ar : [SELECT Count(Id), 
                                        MailingCity 
                                    FROM Contact 
                                        WHERE MailingCity != null
                                        AND (Role__c = 'Driver' OR Role__c = 'Driver/Manager' OR Role__c = 'Admin/Driver')
                                        AND MailingState =: state
                                        Group By MailingCity LIMIT 999]) {
            cities.add((String)ar.get('MailingCity'));
        }

        Map<String, Gas_Prices__c> gasPriceVsCityMap = new Map<String, Gas_Prices__c>();
        For(Gas_Prices__c gs : [SELECT Id,
                                        City__c
                                    FROM Gas_Prices__c
                                        WHERE Month_Year__c =: startOfMonth
                                        AND City__c In: cities
                                        AND State__c =: state]) {
            gasPriceVsCityMap.put(gs.City__c, gs);
        }

        for(String city : cities) {
            if(!gasPriceVsCityMap.containsKey(city)) {
                Gas_Prices__c gasPrice = new Gas_Prices__c(Month_Year__c = startOfMonth,  City__c = city, State__c = state);
                gasPriceVsCityMap.put(city, gasPrice);
            }
        }
        
        if(!gasPriceVsCityMap.isEmpty()) {
            upsert gasPriceVsCityMap.values();

            List<Gas_Price_LineItem__c> gsList = new List<Gas_Price_LineItem__c>();
            Map<string,Id>  gsItmsMap = new Map<string,Id>();
            Map<string,Id>  gsItmsWithZeroPriceMap = new Map<string,Id>();
            List<Gas_Price_LineItem__c> gasPrices = new List<Gas_Price_LineItem__c>();
            
            for(Gas_Price_LineItem__c gsitem : [SELECT Id,
                                                        Date__c,
                                                        Fuel_Price__c,
                                                        Gas_Price__r.City__c
                                                    FROM Gas_Price_LineItem__c
                                                        WHERE Gas_Price__r.Month_Year__c =: startOfMonth
                                                        AND Gas_Price__r.City__c In: cities
                                                        AND Gas_Price__r.State__c =: state
                                                        AND Fuel_Price__c > 0
                                                        ORDER BY Date__c DESC])
            {
                if(gsitem.Fuel_Price__c > 0) {
                    gsItmsMap.put(gsItem.Gas_Price__r.City__c + '-' + gsItem.Date__c.format(), gsItem.Id);
                } else {
                    gsItmsWithZeroPriceMap.put(gsItem.Gas_Price__r.City__c + '-' + gsItem.Date__c.format(), gsItem.Id);
                }
                
            }

            for(Date stDate : WeeksDates) {

                for(String city : cities) {
                    if(!gsItmsMap.containskey(city + '-' + stDate.format())) {

                        if(!gsItmsWithZeroPriceMap.containskey(city + '-' + stDate.format())) {
                            gasPrices.add(new Gas_Price_LineItem__c( 
                                                        City__c = city,
                                                        Gas_Price__c = gasPriceVsCityMap.get(city).Id, 
                                                        Fuel_Price__c = 0.0,
                                                        Date__c = stDate)
                                    );
                        }
                        String rowStr = State.escapeCsv() + ',' + city.escapeCsv() + ',' + stDate.format() + ',' + '';
                        csvRowValues.add(rowStr);
                    }
                    
                }
            }

            if(!gasPrices.isEmpty()) {
                upsert gasPrices;
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        csvColumnHeader = 'State, City, Start of Week, Fuel Price\n';
        String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');
        String subject = 'Missing Fuel Prices for month ' + System.Now().format('MMM-YYYY');
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        
        if(!csvRowValues.isEmpty()) {
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(subject + '.csv');
            efa.setBody(Blob.valueOf(csvFile));
            efa.setContentType('application/csv');
            attachments.add(efa);
        }

        String htmlBody = 'Hey there,<br><br>';

        if(csvRowValues.isEmpty()) {
            htmlBody += 'Please find attachment of ' + subject + '.<br><br>';
        } else {
            htmlBody += 'Fuel price is up-to-dated.';
        }
                        
        htmlBody += 'Regards,<br>' + 
                    'MBurse Team';
        Messaging.SingleEmailMessage email = Utils.CreateEmail( subject, htmlBody, new String[]{'minkeshp@askemc.com'}, null, null, !csvRowValues.isEmpty() ? null : attachments );
        if(!Test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ email }, true);
        }
        
    }
}