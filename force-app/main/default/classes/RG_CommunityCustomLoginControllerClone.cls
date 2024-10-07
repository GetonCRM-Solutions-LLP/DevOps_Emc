public with sharing class RG_CommunityCustomLoginControllerClone {
    public static String username {get;set;}
    public static String password {get;set;}
    public static Boolean popup {get;set;}
    static Integer invalidUsernameCount;
    public static Boolean isUsernameInvalid {get;set;}
    public static Boolean isLimitExeeded {get;set;}
    public static Boolean isPasswordInvalid {get;set;}
    public RG_CommunityCustomLoginControllerClone() {
        popup = false;
        invalidUsernameCount = 0;
        String param = ApexPages.currentPage().getParameters().get('param1');
        System.debug('param:-'+param);
        if ('true'.Equals(param)) {
            popup= true;
        }
    }
    public static PageReference login() {
        isUsernameInvalid = false;
        isLimitExeeded = false;
        isPasswordInvalid = false;
        System.debug('username:--'+username);
        System.debug('password:--'+password);
        PageReference pgRef = Site.login(username, password, null);
        Boolean isValidUsername =false;
        vaidationforwrapper obj_vaidationforwrapper = validateUsername(username);
        System.debug(obj_vaidationforwrapper);
        isValidUsername = obj_vaidationforwrapper.isValid;
        String userid = obj_vaidationforwrapper.id;
       // PageReference pgRef = new PageReference('/app/loginredirector');
        
        System.debug('pgRef:--'+pgRef);
        
        System.debug('isValidUsername:--'+isValidUsername);
        if(!isValidUsername && invalidUsernameCount < 3) {
            invalidUsernameCount++;
            isUsernameInvalid = true;
            isPasswordInvalid = false;
            pgRef = null;
        }
        if(!isValidUsername && invalidUsernameCount >= 3) {
            isLimitExeeded = true;
            isUsernameInvalid = false;
            isPasswordInvalid = false;
        }
        if(isValidUsername && pgRef == null) {
            isPasswordInvalid = true;
            isLimitExeeded = false;
            isUsernameInvalid = false;
        }
        return pgRef;
    }
    
    public static vaidationforwrapper validateUsername(String username) {
        //Boolean isValid = false;
        
        
        vaidationforwrapper obj_vaidationforwrapper = new vaidationforwrapper();
        //'IsPortalEnabled = true AND' add where condition
        List<User> users = new List<User>([SELECT Id, Email,ContactID FROM User WHERE Email =: username limit 1]);
System.debug('users:--'+users);
        if(!users.isEmpty()) {
            obj_vaidationforwrapper.Id = users[0].Id;
            obj_vaidationforwrapper.isValid = true;

        }
        else
        {
            obj_vaidationforwrapper.isValid = false;
        }
        System.debug('obj_vaidationforwrapper:--'+obj_vaidationforwrapper);
        return obj_vaidationforwrapper;
    }


    public class vaidationforwrapper{
        public String id {get;set;}
        public Boolean isValid {get;set;}
        
    }
}