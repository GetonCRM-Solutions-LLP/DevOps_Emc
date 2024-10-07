public without sharing class ManageGasPriceController {

    public String selectedGasPrice { get; set; }
    public String selectedMonth { get; set; }

    public ManageGasPriceController() {
        selectedGasPrice = '';
        selectedMonth = '';
    }

    public String GetGasPriceOptions() {
        List<String> options = new List<String>();
        for(String m : Utils.fetchMonths(1, -1)) {
            options.add( m);
        }
        
        return JSON.serialize(options);
    }

    public String GetMailingStates() {
        List<String> options = Utils.FetchStates();
        return JSON.serialize(options);
    }

    @RemoteAction
    public static String SaveAllGasPrice(String items, String info) {
        
        List<Gas_Price_LineItem__c> gsItms = (List<Gas_Price_LineItem__c>) JSON.deserialize(items, List<Gas_Price_LineItem__c>.class);
        
        if(!gsItms.isEmpty()) {
            upsert gsItms;
        }
        return GetWeeksOfMonth(info);
    }

    @RemoteAction
    public static String GetWeeksOfMonth(String info) {
        searchInfo s = (searchInfo) JSON.deserialize(info, searchInfo.class);
        Date monthYear = Date.newInstance(Integer.valueOf(s.selectedMonth.split('-')[1]), Integer.valueOf(s.selectedMonth.split('-')[0]), 1);

        List<String> cities = new List<String>();
        for(AggregateResult ar : [SELECT Count(Id), 
                                        MailingCity 
                                    FROM Contact 
                                        WHERE MailingCity != null
                                        AND (Role__c = 'Driver' OR Role__c = 'Driver/Manager' OR Role__c = 'Admin/Driver')
                                        AND MailingState =: s.selectedState
                                        Group By MailingCity LIMIT 999]) {
            cities.add((String)ar.get('MailingCity'));
        }

        Map<String, Gas_Prices__c> gasPriceVsCityMap = new Map<String, Gas_Prices__c>();
        For(Gas_Prices__c gs : [SELECT Id,
                                        City__c
                                    FROM Gas_Prices__c
                                        WHERE Month_Year__c =: monthYear
                                        AND City__c In: cities
                                        AND State__c =: s.selectedState]) {
            gasPriceVsCityMap.put(gs.City__c, gs);
        }

        for(String city : cities) {
            if(!gasPriceVsCityMap.containsKey(city)) {
                Gas_Prices__c gasPrice = new Gas_Prices__c(Month_Year__c = monthYear,  City__c = city, State__c = s.selectedState);
                gasPriceVsCityMap.put(city, gasPrice);
            }
        }
        System.debug('========'+gasPriceVsCityMap.values());
        if(!gasPriceVsCityMap.isEmpty()) {            
            upsert gasPriceVsCityMap.values();

            List<Gas_Price_LineItem__c> gsList = new List<Gas_Price_LineItem__c>();
            Map<string,Gas_Price_LineItem__c>  gsItmsMap = new Map<string,Gas_Price_LineItem__c>();
            for(Gas_Price_LineItem__c gsitem : [SELECT Id,
                                                        Fuel_Price__c,
                                                        Date__c,
                                                        City__c,
                                                        Gas_Price__c,
                                                        Gas_Price__r.City__c
                                                    FROM Gas_Price_LineItem__c
                                                        WHERE Gas_Price__r.Month_Year__c =: monthYear
                                                        AND Gas_Price__r.City__c In: cities
                                                        AND Gas_Price__r.State__c =: s.selectedState
                                                        ORDER BY Date__c DESC])
            {
                gsItmsMap.put(gsItem.Gas_Price__r.City__c + '-' + gsItem.Date__c.format(), gsItem);
            }


            Integer weekCount = Utils.weekOfMonth(monthYear.addMonths(1).addDays(-1));
            Date startadate = monthYear;
            Date enddate;
            WeekWrapper ww;
            List<WeekWrapper> weekList = new List<WeekWrapper>();
            Integer loopWeekCount = weekCount;

            Integer currentWeek = Utils.weekOfMonth(System.today());
            if(monthYear.month() != System.today().month()) {
                currentWeek = 1;
            }
            if(currentWeek < weekCount && monthYear.month() == System.today().month()) {
                loopWeekCount = currentWeek;
            }
            for(Integer w = 1; w <= loopWeekCount; w++) {
                enddate = startadate.toStartOfWeek().addDays(6);
                if(w == weekCount)
                    enddate = monthYear.addMonths(1).addDays(-1);
               
                ww = new WeekWrapper();
                ww.title = 'Week ' + w + ' (' +  FormatDate(startadate) + ' - ' + FormatDate(enddate) + ')';
                ww.startOfWeek = startadate;
                ww.gasPrices =  new List<Gas_Price_LineItem__c>();
                ww.collapse = currentWeek == w ? false : true;
                ww.enableEdit = currentWeek == w && monthYear.month() == System.today().month() ? true : false;
                ww.weekCount = w;

                for(String city : cities) {
                    if(gsItmsMap.containskey(city + '-' + startadate.format())) {
                        ww.gasPrices.add(gsItmsMap.get(city + '-' + startadate.format()));
                    } else {
                        ww.gasPrices.add( new Gas_Price_LineItem__c( 
                                                                    City__c = city,
                                                                    Gas_Price__c = gasPriceVsCityMap.get(city).Id, 
                                                                    Fuel_Price__c = 0.0,
                                                                    Date__c = startadate));
                    }
                    
                }
                weekList.add(ww);
                startadate = enddate.addDays(1);
            }

            return JSON.serialize(weekList);

        }
        return null;
    }

    public static String FormatDate(Date dt) {
        return Datetime.newInstance( dt, Time.newInstance(0, 0, 0, 0)).format('MMM dd');
    }

    public Pagereference ValidateUser() {
        // if(UserInfo.getUserType() != 'Guest') {
        //     User userDetails = [SELECT Id, Contact.Role__c FROM User WHERE Id=: UserInfo.getUserId() ];
        //     if(userDetails.Contact.Role__c != StaticValues.ROLE_GASMANAGER)
        //         return new Pagereference('/app/adminlogin');
        // } else {
        //     return new Pagereference('/app/adminlogin');
        // }
        return null;
    }

    public Class searchInfo {
        public String selectedMonth;
        public String selectedState;
    }

    public Class WeekWrapper {
        public String title;
        public Date startOfWeek;
        public Boolean collapse;
        public Integer weekCount;
        public Boolean enableEdit;
        public List<Gas_Price_LineItem__c> gasPrices;
    }

}