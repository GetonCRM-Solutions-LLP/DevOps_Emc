@isTest
    global class HelloSignCalloutMock implements HttpCalloutMock{
      global HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody('{"signature_request": {"signatures": [{"signature_id": "9b8ddf0d8debf6d449405bbb861661dd","has_pin": false,"has_sms_auth": false,"has_sms_delivery": false,"sms_phone_number": null,"signer_email_address": "niraj.sahedani@getoncrm.com","error": null}]}}');
        //res.setBody('Test');
        return res;
      }
    }