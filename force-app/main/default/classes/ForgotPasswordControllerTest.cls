/**
 * An apex page controller that exposes the site forgot password functionality
 */
@IsTest(SeeAlldata = true)
 public with sharing class ForgotPasswordControllerTest {
     public static testmethod void ForgotPasswordTestMethod() {
        Account a = new Account(Name = 'Company Internal');
        insert a;
    
        User u = new User();
        u.Firstname = 'kumarmike';
        u.LastName = 'Viharikumarjustin';
        u.email = 'kumarbhaimsmith@company.com';
        u.Alias = 'alias';
        u.CommunityNickname = 'commnick';
        u.EmailEncodingKey = 'UTF-8';
        u.Username = 'kumarbhaimsmith@company.com';
        u.TimeZoneSidKey = 'America/Denver';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.ProfileId = [SELECT id FROM profile where Name = 'System Administrator'].Id;
    
       insert u;
        
        ForgotPasswordController controller = new ForgotPasswordController();
        controller.username = 'kumarbhaimsmith@company.com';  
        //controller.userID = u.Id;
        ForgotPasswordController.resetPasswordForCommunity(u.name);
        ForgotPasswordController.checkUserNameForCommunity(u.Username);
        controller.resetPassword();
    }
}