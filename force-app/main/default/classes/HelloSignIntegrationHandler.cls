global class HelloSignIntegrationHandler{
    @future(callout=true)
    //global static void sendSignatureRequestForDriver(){
        //System.debug('Hello World');
    global static void sendSignatureRequestForDriver(Set<String> newUserEmail){
        String emailNew ;
        try{
            List<Contact> contactList = [Select id,Role__c,AccountId,Name,email,Hello_Sign_Request_Id__c,Hello_Sign_Status__c,
                                            Admin__c,Admin__r.Name,Admin__r.Email,Account.Admin_Contact__r.Name, 
                                            Account.Admin_Contact__r.External_Email__c,Account.Admin_Contact__c,Account.Hello_Sign_Admin_Sign__c 
                                            FROM contact 
                                            WHERE email in : newUserEmail 
                                            AND Role__c  in ('Driver','Driver/Manager','Driver/Admin')];
            Hello_Sign__c helloSignCustomSetting = Hello_Sign__c.getValues(Constants.apiOwnerName);
            Map<String, Contact> contactMap = new Map<String, Contact>();
            Set<Id> contactIds = new Set<Id>();
            for(Contact conObj : contactList){
                if(!contactMap.containskey(conObj.Email)){
                    contactMap.put(conObj.Email, conObj);
                }
                contactIds.add(conObj.Id);
            }
            Map<Id,Id> docAndAccountId = new Map<Id,Id>();
            if(!contactIds.isEmpty()){
                for( ContentDocumentLink contentDocLink : [SELECT ContentDocumentId,LinkedEntityId ,ContentDocument.LatestPublishedVersion.Title
                                                            FROM ContentDocumentLink 
                                                            where LinkedEntityId in : contactIds 
                                                            and ContentDocument.LatestPublishedVersion.Title =: Constants.driverAgreement]){
                                                            System.debug('contentDocLink -->'+contentDocLink );
                                docAndAccountId.put(contentDocLink.LinkedEntityId, contentDocLink.ContentDocumentId);
                }
            }
            HelloSign.SignatureRequestService sigReq;
            for(Contact conObj : contactList){
                sigReq = new HelloSign.SignatureRequestService();
              
                String adminName;
                String adminEmail;
               
                if(conObj.Admin__c != null){
                    adminName = conObj.Admin__r?.Name;
                    adminEmail = conObj.Admin__r?.Email;
                } else if( conObj.Account.Admin_Contact__c != null){                                      
                    adminName = conObj.Account.Admin_Contact__r.Name != null ? conObj.Account.Admin_Contact__r.Name : null;
                    adminEmail = conObj.Account.Admin_Contact__r.External_Email__c != null ? conObj.Account.Admin_Contact__r.External_Email__c : null;                    
                } else {                    
                    adminName = helloSignCustomSetting.Admin_Name__c;
                    adminEmail = helloSignCustomSetting.Admin_Email__c;
                }  
                sigReq.fileIds = new List<Id>{ docAndAccountId.containsKey(conObj.Id) ? docAndAccountId.get(conObj.Id) : null };

                Map<String, HelloSign.ServiceObjects.Signer> signerMap = new Map<String, HelloSign.ServiceObjects.Signer>();
                HelloSign.ServiceObjects.Signer signer0 = new HelloSign.ServiceObjects.Signer(conObj.Email, conObj.Name);
                signer0.order = 0;
                signerMap.put('0', signer0);
                if(conObj.Account.Hello_Sign_Admin_Sign__c == true){
                    HelloSign.ServiceObjects.Signer signer1 = new HelloSign.ServiceObjects.Signer(adminEmail, adminName);
                    signer1.order = 1;
                    signerMap.put('1', signer1);
                }                
                sigReq.signers = signerMap;

                sigReq.test_mode = helloSignCustomSetting.TestMode__c;
                sigReq.use_text_tags = true;
                sigReq.hide_text_tags = true;
                sigReq.subject = Constants.signatureRequest;
                HelloSign.ServiceObjects.SignatureRequestResponse responseJSON;
                System.debug('sigReq-->'+sigReq);
                if(!Test.isRunningTest()){  responseJSON = sigReq.send(false);    
                }else{
                    responseJSON = new HelloSign.ServiceObjects.SignatureRequestResponse();
                }
                
                System.debug('responseJSON-->'+String.valueOf(responseJSON));
                String emailString = '';
                if(responseJSON != null){
                    for(HelloSign.ServiceObjects.Signature signatureObj : responseJSON.signature_request.signatures){
                        System.debug('signature obj:'+signatureObj);
                        System.debug('signature obj === :'+signatureObj.status_code);
                        if(contactMap.containskey(signatureObj.signer_email_address)){contactMap.get(signatureObj.signer_email_address).Hello_Sign_Request_Id__c = responseJSON.signature_request.signature_request_id;contactMap.get(signatureObj.signer_email_address).Packet__c = Constants.sentForSignature;ContactMap.get(signatureObj.signer_email_address).Document_Sent_Date__c = System.today();ContactMap.get(signatureObj.signer_email_address).Driver_Sign_Date__c = '';ContactMap.get(signatureObj.signer_email_address).Admin_Sign_Date__c = '';ContactMap.get(signatureObj.signer_email_address).Hello_Sign_Admin_Status__c = '';
                            if(conObj.Account.Hello_Sign_Admin_Sign__c == false || signatureObj.order == 0){emailString = signatureObj.signer_email_address;contactMap.get(signatureObj.signer_email_address).Hello_Sign_Status__c = signatureObj.status_code;}
                        }
                        if(conObj.Account.Hello_Sign_Admin_Sign__c == true && signatureObj.order == 1){contactMap.get(emailString).Hello_Sign_Admin_Status__c = signatureObj.status_code;}
                    }
                }
                //time delay
                Long startingTime = System.now().getTime();long delayInMilliseconds = 200;while (System.now().getTime() - startingTime < delayInMilliseconds){}
            }
            if(!contactMap.values().isEmpty()){ Database.update(contactMap.values(), false);
                System.debug('contactMap.values()-->'+contactMap.values());
            }
            emailNew = new List<String> (newUserEmail).get(0);
            // String emailNew = newUserEmail[0];
    
            Datetime start = System.Now();
            while(System.Now()< start.addSeconds(4)){}
        
        if(!Test.isRunningTest()){
            ID jobID = System.enqueueJob(new HelloSignIntegrationHandlerQueueable(emailNew));
            System.debug('call queable : '+jobID);
        }
        
        }catch(Exception e){
            System.debug('Exception Occur:- '+e.getmessage()+' - Line:-'+e.getLineNumber());
        }
    }
}