/**
 * @Author: GetonCRM Solutions LLP
 * @Description: This class is use for delete a data from netchex.
 * @Modification logs
 * ========================================================================================================================
 * @Date: 17 Auguest 2020 | Sanket Goswami
 * @description: 
 * AI-000443
 */
global class NetchexDeleteCallout {
    
    public NetchexDeleteCallout() {
       
    }
    Webservice static void DeletedataFromNetchex(String startDate, String endDate, DateTime runningTime) 
    {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        String endPoint = StaticValues.Netchex_Timesheet_Connect + '?start=' + startDate + '&end='+endDate ;
        req.setEndpoint(endPoint);
        req.setMethod('GET');
        req.setTimeout(120000);
        req.setHeader('Authorization', 'Basic ' + StaticValues.Netchex_APIKey);

        HttpResponse res;
            res = h.send(req);
            System.debug('res'+res.getBody());
        List<Tripslog__c> obj_Tripslog_list = new List<Tripslog__c>();
        Tripslog__c obj = new Tripslog__c();
        obj.Body__c = JSON.serialize(res.getBody());
        obj.Endpoint__c = StaticValues.Netchex_Timesheet_Connect;
        obj.Total_Trips__c = 0;
        obj.Total_Mileages__c = 0;
        obj.Log_Time__c = runningTime;
        obj.Response__c = 'NetchexDeleteCallout';
        if(res.getBody() != null && res.getStatusCode() == 200) { 
            try {
                HttpResponse resp;
                if(!Test.isRunningTest()) {
                    resp = ApiCalloutUtility.executeCallout(StaticValues.Netchex_APIKey,'DELETE',StaticValues.Netchex_Timesheet_Connect,'HeaderBasic',res.getBody());
                    System.debug('resp'+resp);
                    obj.Response_Data__c = resp.getBody();
                    obj.Status__c = resp.getStatusCode() == 200 ? 'Success' : 'Fail';
                }
                obj_Tripslog_list.add(obj);

                if(!obj_Tripslog_list.isEmpty()) {
                    insert obj_Tripslog_list;
                }
            }
            catch(System.CalloutException er) {

            }
        }
    }
}