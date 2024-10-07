@isTest
public class SendMonthlyMileageReminder_test
{
        testmethod public static void deactivatedemailMethod()
        {
                Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
                veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
                veh.vehicle__c = 'Full-Size Sedan';
                veh.Year__c = '2019';
                insert veh;

                SendEmail__c sendemail = new SendEmail__c();
                sendemail.Name = 'Send Email For Compliance';
                sendemail.Send_email_from_code__c = true;
                insert sendemail;

                SendEmail__c customSetting2 =  new SendEmail__c();
                customSetting2.Name = 'SendMonthlyMileageReminder';
                customSetting2.Send_email_from_code__c= true;
                insert customSetting2;

                SendEmailonDeactivation__c customSetting3 = new SendEmailonDeactivation__c();
                customSetting3.Name = 'SendMonthlyMileageReminder';
                customSetting3.Send_to_Driver__c = true;
                insert customSetting3 ;
                
                TriggerConfig__c customSetting =  new TriggerConfig__c();
                customSetting.Name = 'Defaulttrigger';
                customSetting.MappingGasPriceTrigger__c = true;
                insert customSetting;

                Account obj_Account = new Account();
                obj_Account.name='Community Account';
                insert obj_Account;

                List<Contact> conList = new List<Contact>();
                Contact co = new Contact();
                co.FirstName = 'Test';
                co.LastName = 'Contact Admin';
                co.AccountId = obj_Account.Id;
                co.MailingStreet = 'Test Street';
                co.MailingCity = 'Test City';
                co.MailingState = 'ON';
                co.MailingPostalCode = '123';
                co.MailingCountry = 'CA';
                co.Phone = '1232434445';
                co.External_Email__c = 'minkesh.patelmanager01@gmail.com';
                co.Deactivated_Date__c = null;
                co.IsCommunityUser__c = true;        
                co.Role__c = 'Admin';
                co.Monthly_Mileage_Limit__c = 210;
                //insert co;
                conList.add(co);
                Contact co1 = new Contact();
                co1.FirstName = 'Test1';
                co1.LastName = 'Contact Admin1';
                co1.AccountId = obj_Account.Id;
                co1.MailingStreet = 'Test Street1';
                co1.MailingCity = 'Test City';
                co1.MailingState = 'ON';
                co1.MailingPostalCode = '123';
                co1.MailingCountry = 'CA';
                co1.Phone = '1232434445';
                co1.External_Email__c = 'minkesh.patelmanager011@gmail.com';
                co1.Deactivated_Date__c = null;
                co1.IsCommunityUser__c = true;        
                co1.Role__c = 'Driver';
                co1.Vehicle_Type__c = '2019 Full-Size Sedan' ;
                co1.Monthly_Mileage_Limit__c = 210;
                //insert co1;
                conList.add(co1);
                insert conList;
                SendMonthlyMileageReminder objSendMileageReminderforDelta= new SendMonthlyMileageReminder();
                Database.executeBatch(objSendMileageReminderforDelta);
     }

     testmethod public static void deactivatedemailMethod2()
        {
                Vehicle_URL_Mapping__c veh = new Vehicle_URL_Mapping__c();
                veh.URL__c = 'https://cdn2.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
                veh.vehicle__c = 'Full-Size Sedan';
                veh.Year__c = '2019';
                insert veh;

                SendEmail__c customSetting2 =  new SendEmail__c();
                customSetting2.Name = 'SendMonthlyMileageReminder';
                customSetting2.Send_email_from_code__c= true;
                insert customSetting2;

                SendEmailonDeactivation__c customSetting3 = new SendEmailonDeactivation__c();
                customSetting3.Name = 'SendMonthlyMileageReminder';
                customSetting3.Send_to_Admin__c = true;
                customSetting3.Send_to_Driver__c = true;
                customSetting3.Send_to_Manager__c = true;
                customSetting3.BCCEmailaddresses__c = 'test223@gmail.com,test4@gmail.com';
                insert customSetting3 ;

                Account obj_Account = new Account();
                obj_Account.name='Community Account';
                insert obj_Account;

                List<Contact> conList = new List<Contact>();
                Contact co = new Contact();
                co.FirstName = 'Test';
                co.LastName = 'Contact Admin';
                co.AccountId = obj_Account.Id;
                co.MailingStreet = 'Test Street';
                co.MailingCity = 'Test City';
                co.MailingState = 'ON';
                co.MailingPostalCode = '123';
                co.MailingCountry = 'CA';
                co.Phone = '1232434445';
                co.External_Email__c = 'minkesh.patelmanager01@gmail.com';
                co.Deactivated_Date__c = null;
                co.IsCommunityUser__c = true;        
                co.Role__c = 'Admin';
                co.Monthly_Mileage_Limit__c = 210;
                //insert co;
                conList.add(co);
                Contact co1 = new Contact();
                co1.FirstName = 'Test1';
                co1.LastName = 'Contact Admin1';
                co1.AccountId = obj_Account.Id;
                co1.MailingStreet = 'Test Street1';
                co1.MailingCity = 'Test City';
                co1.MailingState = 'ON';
                co1.MailingPostalCode = '123';
                co1.MailingCountry = 'CA';
                co1.Phone = '1232434445';
                co1.External_Email__c = 'minkesh.patelmanager011@gmail.com';
                co1.Deactivated_Date__c = null;
                co1.IsCommunityUser__c = true;        
                co1.Role__c = 'Driver';
                co1.Vehicle_Type__c = '2019 Full-Size Sedan' ;
                co1.Monthly_Mileage_Limit__c = 210;
                //insert co1;
                conList.add(co1);
                insert conList;
                SendMonthlyMileageReminder objSendMileageReminderforDelta= new SendMonthlyMileageReminder();
                Database.executeBatch(objSendMileageReminderforDelta);
                
            
     }
}