/****************************************************************************************************
 * Create By : Dhanraj Khatri
 * Create Date : 06/07//2022
 * Description :  Mockout class for Generating Difference Response according to End Point
               
 * Modification Log:
 *  -------------------------------------------------------------------------------------------------
 *  * Developer                         Date                   Description
 *  *------------------------------------------------------------------------------------------------
 *  *   -                                -                         -
*****************************************************************************************************/

@isTest
global class TrueDialogMockCallout implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {

        String endpoint = req.getEndpoint(); 

        HttpResponse res = new HttpResponse();
        
        res.setHeader('Content-Type', 'application/json');

        if(endpoint.contains('contact')){
            res.setBody('{ "id": 81527500, "accountId": 18409, "statusId": 0, "phoneNumber": "+12408030144", "email": "test@gmail.cpm", "assignedId": null, "firstName": "Test ", "lastName": null, "subscriptions": [ { "subscriptionId": 22639, "smsEnabled": true, "mmsEnabled": false, "emailEnabled": false, "voiceEnabled": false } ], "attributes": [], "phoneStatusId": 0, "created": "2022-07-03T16:40:18.8110975Z", "createdBy": null, "modified": "2022-07-03T16:40:18.8110975Z", "modifiedBy": null }');
        }else if(endpoint.contains('media')){
            res.setBody('{}');
        }else if(endpoint.contains('image')){
            res.setBody('[{ "Channels":[22], "Targets":["723832"], "MediaId":44, "Execute":true }]');
        }
        else{
           res.setBody('{ "channels": [], "targets": [ "81071892" ], "targetsUrl": null, "targetsColumn": null, "contactListIds": [], "excludeListIds": [], "campaignId": 119410, "mediaId": null, "message": "Test 01-07 2", "from": null, "subject": null, "ignoreSingleUse": false, "forceOptIn": false, "statusId": 0, "roundRobinById": false, "globalRoundRobin": false, "status": "Active", "id": 117958665, "accountId": 18409, "created": "2022-07-04T08:57:15.9178524Z", "modified": "2022-07-04T08:57:15.9178524Z", "createdBy": "1ab59fe33353401b8fd8da05716caaf5", "modifiedBy": null, "schedules": [] }'); 
        }  
        res.setStatusCode(201);
        return res;
    }
}