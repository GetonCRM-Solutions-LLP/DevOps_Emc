public with sharing class goToWebinarNewUIController {
    
    public static string registerWebinar(String firstName,String lastName,String email){
        goToWrapper wb = new goToWrapper();
        wb.firstName = firstName;
        wb.lastName = lastName;
        wb.email = email;

        return JSON.serialize(wb);
    }

    @AuraEnabled
    public static string registerWebinarCallout(String firstName,String lastName,String email,String accid){

        System.debug('firstName:== '+firstName);
        System.debug('lastName:== '+lastName);
        System.debug('accid:== '+accid);
        List<Account> accList = [Select Id,Name,Webinar_Key__c from Account where Id =: accid];
        System.debug('accList:== '+accList);
        String webinarKey = accList[0].Webinar_Key__c;
        System.debug('webinar:== '+webinarKey);

        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();    

        String requestBody = goToWebinarNewUIController.registerWebinar(firstName,lastName,email);
        System.debug('requestBody: '+requestBody);

        //4th is Webinarkey
        httpRes = GoToWebinarNewUICallout.executeCallout('POST','registrants',requestBody,webinarKey);

        System.debug('Webianr create Response Body');
        System.debug('httpRes.getBody()--------'+httpRes.getBody());
        System.debug('httpRes.getStatusCode():'+httpRes.getStatusCode());

        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());
        system.debug('result==' + result);
        String registrantKey = String.valueOf(result.get('registrantKey'));
        system.debug('registrantKey==' + registrantKey);
        String joinUrl = String.valueOf(result.get('joinUrl'));
        system.debug('joinUrl==' + joinUrl);
        String status = String.valueOf(result.get('status'));
		 system.debug('status==' + status);
        registrantDetails details = new registrantDetails();
        details.registrantKey = registrantKey;
        details.joinUrl = joinUrl;
        details.status = status;
        details.webinarKey = webinarKey;
         system.debug('webinarKey==' + webinarKey);

        if(httpRes.getStatusCode() == 201){
            return JSON.serialize(details);
        } else if (httpRes.getStatusCode() == 403){
            return 'Webinar is Ended';
            // return httpRes.getBody();
        } else {
            return 'Error';
        }
    }

    @AuraEnabled
    public static String recordingURL(String accid){
        Account acc = [Select Id,Name,Webinar_Key__c from Account where Id =: accId];
        String webinarKey = acc.Webinar_Key__c;

        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();

        httpRes = GoToWebinarNewUICallout.executeCalloutForRecordingURL('GET',webinarKey);
        System.debug('httpRes.getBody()--------'+httpRes.getBody());
        System.debug('httpRes.getStatusCode():'+httpRes.getStatusCode());

        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());
        List<Object> newob = (List<Object>)result.get('data');
        System.debug('result:'+result);
        System.debug('newob:'+newob);

        String recordingurl = '';
        if(newob != null){
            for(Object objNew : newob){
                Map<String,Object> rMap = (Map<String,Object>)objNew;
                if(rMap.get('mp4DownloadUrl') != null){
                    recordingurl = String.valueOf(rMap.get('mp4DownloadUrl'));
                    // endDateOriginal = endDate;
                }
            }
        } else{
            recordingurl = null;
        }
        System.debug('recordingurl:'+recordingurl);
        if(recordingurl != null){
            return recordingurl;
        } else {
            return 'Recording is Not Available';
        }
    }   

    @AuraEnabled(cacheable=true)
    public static string getWebinarName(String accId){
        Account acc = [Select Id,Name,Webinar_Key__c from Account where Id =: accId];
        String webinarKey = acc.Webinar_Key__c;

        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();

        httpRes = GoToWebinarNewUICallout.executeCalloutForName('GET',webinarKey);
       	Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());
        // List<Object> newob = (List<Object>)result.get('name');
        String webinarName = String.valueOf(result.get('name'));
        String description = String.valueOf(result.get('description'));
        // String times = String.valueOf(result.get('times'));
        List<Object> newob = (List<Object>)result.get('times');
        System.debug('newob'+newob);
        String endDate;
        String startDate;
        // String startDateOriginal;
        // String endDateOriginal;
        for(Object objNew : newob){
            Map<String,Object> rMap = (Map<String,Object>)objNew;
            if(rMap.get('endTime') != null){
                endDate = String.valueOf(rMap.get('endTime'));
                // endDateOriginal = endDate;
            }
            if(rMap.get('startTime') != null){
                startDate = String.valueOf(rMap.get('startTime'));
                // startDateOriginal = startDate;
            }
        }

        // startDate = dates(startDate);
        // endDate = dates(endDate);
        String timeZone = String.valueOf(result.get('timeZone'));
        meetingDetails details = new meetingDetails();
        details.webinarName = webinarName;
        details.description = description;
        details.endDate = endDate;
        details.startDate = startDate;
        details.timeZone = timeZone;
        // details.endDateOriginal = endDateOriginal;
        // details.startDateOriginal = startDateOriginal;

        System.debug('json'+JSON.serialize(details));

        if(httpRes.getStatusCode() < 300){
            return JSON.serialize(details);
        } else{
            return 'Error';
        }

    }

    public static String dates(String str){

        str = str.replace('-','');
        str = str.replace(':','');

        str = str.Substring(0,str.length()-1);
        return str;
    }

    @AuraEnabled(cacheable=true)
    public static String urlMaking(String webinarName,String startDate,String endDate,String timeZone,String registrantKey,String joinUrl,String status,String webinarKey){
        List<String> res = webinarName.split(' ');
        String strFull='';
        String url = 'https://calendar.google.com/calendar/u/0/r/eventedit?text=GoTo+-+';
        System.debug('res: '+res);
        System.debug('res-size: '+res.size());
        for(String str: res){
            strFull = strFull + str +'+';
        }
        System.debug('strFull: '+strFull);
        strFull = strFull.Substring(0,strFull.length()-1);
        System.debug('strFull==: '+url+''+strFull);
        strFull = url+''+strFull;

        // startDateOriginal = startDateOriginal.replace(':','');
        // endDateOriginal = endDateOriginal.replace(':','');

        // String[] startDates = startDate.split('T');
        // startDate = startDates[0] + 'T' + startDateOriginal;

        // String[] endtDates = endDate.split('T');
        // endDate = endtDates[0] + 'T' + endDateOriginal;
        
        
        String dates = '&dates='+startDate+'/'+endDate;
        strFull = strFull + dates + '&ctz=' +timeZone;
        String url1 = '&details=1.+Click+and+join+at+the+specified+time+and+date:+%0A'+joinUrl;
        String url2 = '+%0ANote:+This+link+should+be+not+shared+with+others+it+is+unique+to+you.+%0A%0A2.+More+webinar+details:+%0Ahttps://attendee.gotowebinar.com/additionalInfo.tmpl?duplicate%3Dfalse%26webinar%3D'+webinarKey;
        url2 = url2 + '%26aregistrantConfirmation%3D'+registrantKey;
        String url3 = '&location=GoTo+Webinar+-+See+conference+call+information+below&pli=1&sf=true&output=xml';
        strFull = strFull + url1 + url2 + url3;
        return strFull;
    }

    @AuraEnabled(cacheable=true)
    public static String urlMakingforOutlook(String webinarName,String timeZone,String registrantKey,String joinUrl,String status,String webinarKey,String startDateOutlook,String endDateOutlook){
        
        System.debug('Url for outlook');
        System.debug('Start: '+startDateOutlook);
        System.debug('End: '+endDateOutlook);
        string dt = startDateOutlook;
        String[] strStart   = dt.split(' ');
        String startDate = strStart[0];
        String startTime = strStart[1];

        string dtEnd = endDateOutlook;
        String[] strEnd   = dtEnd.split(' ');
        String endDate = strEnd[0];
        String endTime = strEnd[1];

        String basicComm = 'https://www.addevent.com/dir/?client=aub5jjpffz08eqvgwmj1482&start='+startDate+'&starttime='+startTime+'&end='+endDate+'&endtime='+endTime+'&title=GoTo%20-%20'+webinarName;
        String descriptionURL = '&description=1.%20Click%20and%20join%20at%20the%20specified%20time%20and%20date%3A%3Cbr%3E'+joinUrl+'%3Cbr%3ENote%3A%20This%20link%20should%20be%20not%20shared%20with%20others%20it%20is%20unique%20to%20you.%3Cbr%3E%3Cbr%3E2.%20More%20webinar%20details%3A%3Cbr%3Ehttps%3A%2F%2Fattendee.gotowebinar.com%2FadditionalInfo.tmpl%3Fduplicate%3Dfalse%26webinar%3D'+webinarKey+'%26aregistrantConfirmation%3D'+registrantKey+'';
        String locationURL = '&location=GoTo%20Webinar%20-%20See%20conference%20call%20information%20below';
        String timeZoneURL = '&timezone='+timeZone+'&service=outlookcom&date_format=MM%2FDD%2FYYYY&all_day_event=false&template=sp2015k910u2232p30&alarm=15';

        String fullURL = basicComm + descriptionURL + locationURL + timeZoneURL;
        System.debug('Full URL: '+fullURL);
        return fullURL;
    }

    public class registrantDetails{
        public String registrantKey;
        public String joinUrl;
        public String status;
        public String webinarKey;
    }

    public class meetingDetails{
        public String webinarName;
        public String description;
        public String startDate;
        public String endDate;
        public String timeZone;
        // public String startDateOriginal;
        // public String endDateOriginal;
    }

    public class goToWrapper{
        public String firstName;
        public String lastName;
        public String email;
    }
}