@isTest
    global class GoToWebinarSetUpControllerMock implements HttpCalloutMock{
      global HttpResponse respond(HTTPRequest req){
        if (req.getEndpoint().endsWith('webhooks?product=g2w')) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"_embedded":{"webhooks":[{"eventName":"registrant.joined","eventVersion":"1.0.0","callbackUrl":"https://mburse--fullcopy.sandbox.my.salesforce-sites.com/GoToWebinar","product":"g2w","webhookKey":"75f7d0d0-18c9-4c96-9b73-7a8e236427f6","state":"ACTIVE","createTime":"2022-10-23T09:23:45.647Z"},{"eventName":"registrant.added","eventVersion":"1.0.0","callbackUrl":"https://mburse--fullcopy.sandbox.my.salesforce-sites.com/GoToWebinar","product":"g2w","webhookKey":"e2bb5579-536b-41e8-a574-e34c30c26536","state":"ACTIVE","createTime":"2022-10-23T09:23:45.647Z"}]}}');
            res.setStatusCode(200);
            return res;
        } else if (req.getEndpoint().endsWith('userSubscriptions?product=g2w')) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"_embedded":{"userSubscriptions":[{"webhookKey":"75f7d0d0-18c9-4c96-9b73-7a8e236427f6","callbackUrl":"https://mburse--fullcopy.sandbox.my.salesforce-sites.com/GoToWebinar","userSubscriptionState":"ACTIVE","activationState":"ACTIVE","userSubscriptionKey":"ede22aa8-39f6-4d4e-855e-270d8725a891","eventName":"registrant.joined","product":"g2w","eventVersion":"1.0.0","createTime":"2022-10-23T09:33:01.026Z"},{"webhookKey":"e2bb5579-536b-41e8-a574-e34c30c26536","callbackUrl":"https://mburse--fullcopy.sandbox.my.salesforce-sites.com/GoToWebinar","userSubscriptionState":"ACTIVE","activationState":"ACTIVE","userSubscriptionKey":"9f28028b-e268-4ade-9828-35c182b06bc7","eventName":"registrant.added","product":"g2w","eventVersion":"1.0.0","createTime":"2022-10-23T09:33:01.026Z"}]}}');
            res.setStatusCode(200);
            return res;
        } else {
            System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
            return null;
        }
    }
}