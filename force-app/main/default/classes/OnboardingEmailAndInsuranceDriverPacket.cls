/**
* @File Name          : OnboardingEmailAndInsuranceDriverPacket
* @Description        : sending email to driver by the status of insurance and driver package 
* @Author             : khuman singh 
**/
public with sharing class OnboardingEmailAndInsuranceDriverPacket implements Schedulable {
    public void execute(SchedulableContext Ctx){
        List<Contact> contacts = [SELECT Id,Name,Packet__c,Insurance__c,Admin__r.Email,Manager__r.Email FROM Contact WHERE (Role__c='Driver' OR Role__c='Driver/Admin'OR Role__c='Driver/Manager')AND  Deactivated_Date__c = null AND Account.Insurance_Email__c =true AND Account.isUsingTriplog__c =true ];
       //List<Contact> contacts = [SELECT Id,Name,Packet__c,Insurance__c,Admin__r.Email,Manager__r.Email FROM Contact WHERE AccountId ='0010Z00001ygUen'];
        sendEmails(contacts);
    }
    private void sendEmails(List<Contact> contacts) {
        SendEmailonDeactivation__c AddCC = SendEmailonDeactivation__c.getValues('OnboardingEmail');//custom setting
        List<Messaging.SingleEmailMessage> singleEmailList = new List<Messaging.SingleEmailMessage>();
        for (contact con : contacts) {

            Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();

            singleEmail.setTargetObjectId(con.Id);
            singleEmail.setSenderDisplayName('Admin');
            
            List<String> ccAddresses = new List<String>();
            if (con.Manager__r.Email != null && AddCC.Send_to_Manager__c==true) {
                ccAddresses.add(con.Manager__r.Email);
            }
            if (con.Admin__r.Email != null && AddCC.Send_to_Admin__c==true) {
                ccAddresses.add(con.Admin__r.Email);
            }
            singleEmail.setCcAddresses(ccAddresses);
        

            if(con.packet__c !='Completed' && con.insurance__c=='Not Submitted' ){
                EmailTemplate emailTemp = [SELECT Id,Name FROM EmailTemplate WHERE Name='No Driver Package Or Insurance'];
                singleEmail.setTemplateID(emailTemp.Id);
                singleEmailList.add(singleEmail);
            }
            else if(con.packet__c !='Completed' && con.insurance__c=='Not Meeting Plan Minimum'){
                EmailTemplate emailTemp = [SELECT Id,Name FROM EmailTemplate WHERE Name='Did Not Sign Packet And Insurance Not Meeting Minimum'];
                singleEmail.setTemplateID(emailTemp.Id);
                singleEmailList.add(singleEmail);
            }
            else if(con.packet__c !='Completed' && con.insurance__c=='Insurance Card'){
                EmailTemplate emailTemp = [SELECT Id,Name FROM EmailTemplate WHERE Name='Did Not Sign Packet And Insurance Card'];
                singleEmail.setTemplateID(emailTemp.Id);
                singleEmailList.add(singleEmail);
            }
            else if(con.packet__c !='Completed' && con.insurance__c=='Expired'){
                EmailTemplate emailTemp = [SELECT Id,Name FROM EmailTemplate WHERE Name='Did Not Sign Packet And Expired Insurance'];
                singleEmail.setTemplateID(emailTemp.Id);
                singleEmailList.add(singleEmail);
            }
            else if(con.packet__c!='Completed' && con.insurance__c=='No Expiration Date'){
                EmailTemplate emailTemp = [SELECT Id,Name FROM EmailTemplate WHERE Name='Did Not Sign Packet And No Coverage Dates'];
                singleEmail.setTemplateID(emailTemp.Id);
                singleEmailList.add(singleEmail);
            }

            else if(con.packet__c=='Completed' && con.insurance__c=='Not Submitted'){
                EmailTemplate emailTemp = [SELECT Id,Name FROM EmailTemplate WHERE Name='Signed Packet And No Insurance'];
                singleEmail.setTemplateID(emailTemp.Id);
                singleEmailList.add(singleEmail);
            }
            else if(con.packet__c=='Completed' && con.insurance__c=='Not Meeting Plan Minimum'){
                EmailTemplate emailTemp = [SELECT Id,Name FROM EmailTemplate WHERE Name='Signed Packet And Insurance not meeting minimum'];
                singleEmail.setTemplateID(emailTemp.Id);
                singleEmailList.add(singleEmail);
            }
            else if(con.packet__c=='Completed' && con.insurance__c=='Insurance Card'){
                EmailTemplate emailTemp = [SELECT Id,Name FROM EmailTemplate WHERE Name='Signed Packet And Insurance Card'];
                singleEmail.setTemplateID(emailTemp.Id);
                singleEmailList.add(singleEmail);
            }
            else if(con.packet__c=='Completed' && con.insurance__c=='Expired'){
                EmailTemplate emailTemp = [SELECT Id,Name FROM EmailTemplate WHERE Name='Signed Packet And Expired Insurance'];
                singleEmail.setTemplateID(emailTemp.Id);
                singleEmailList.add(singleEmail);
            }
            else if(con.packet__c=='Completed' &&  con.insurance__c=='No Expiration Date'){
                EmailTemplate emailTemp = [SELECT Id,Name FROM EmailTemplate WHERE Name='Signed Packet And No Coverage Dates'];
                singleEmail.setTemplateID(emailTemp.Id);
                singleEmailList.add(singleEmail);
            }
            
        }

        if(singleEmailList.size() > 0){
            Messaging.SendEmailResult[] result = Messaging.sendEmail(singleEmailList,false);
            if(result[0].success){
                System.debug('Email sent successfully');
            }
            else{
                System.debug('Email has failed to send : '+result[0].errors[0].message);
            }
        }
    } 
}