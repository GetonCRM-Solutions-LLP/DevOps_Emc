public without sharing class adminLoginController {
    // public static String username {get;set;}
    // public static String password {get;set;}
    public static Boolean popup {get;set;}
    static Integer invalidUsernameCount;
    public static Boolean isUsernameInvalid {get;set;}
    public static Boolean isLimitExeeded {get;set;}
    public static Boolean isPasswordInvalid {get;set;}
    public static PageReference pgRef {get;set;}
  
    public adminLoginController() {
        popup = false;
        invalidUsernameCount = 0;
        String param = ApexPages.currentPage().getParameters().get('param1');
        if ('true'.Equals(param)) {
            popup= true;
        }
    }

    @RemoteAction
    public static vaidationforwrapper login(String username, String password) {
        isUsernameInvalid = false;
        isLimitExeeded = false;
        isPasswordInvalid = false;
        pgRef = Site.login(username, password, null);
        
        vaidationUserwrapper valWrappObj1 = validateUsername(username);
       // System.debug('valWrappObj1 ---'+valWrappObj1);
        vaidationforwrapper valWrappObj = new vaidationforwrapper();
        valWrappObj.id = valWrappObj1.userid;
        valWrappObj.isValid = valWrappObj1.checkValid;
        
        if(pgRef == null){
            valWrappObj.pgReference = null;
        } else {
            valWrappObj.pgReference = pgRef;
        }
        
        String userid = valWrappObj1.userid;
        if(userid != null){
            List<LoginHistory> loginList = [SELECT Id,Status,UserId,LoginTime 
                                            FROM LoginHistory 
                                            WHERE UserId =: userid 
                                            AND LoginTime >: Datetime.now().addMinutes(-15)];      
                System.debug('loginList.size()'+loginList.size());
                valWrappObj.remainingAttempt = 5 - loginList.size();
        }
        System.debug('==='+valWrappObj);
        return valWrappObj;
    }

    @RemoteAction
    public static PageReference redirectToMyVF() {  
        PageReference myVFPage = new PageReference('/app/ForgotPasswordNewUI');
        myVFPage.setRedirect(true);
        return myVFPage;
    }
    
    public static vaidationUserwrapper validateUsername(String username) {
        System.debug('username ---'+username);
        vaidationUserwrapper valWrappObj = new vaidationUserwrapper();
        List<User> userList = [Select Id, Name, Profile.Name From User where Email =: username  OR Username =: username Limit 1];
       
        if(!userList.isEmpty()) {
            System.debug('userList ---'+userList);
            System.debug('users list ---'+userList[0].id);
            valWrappObj.userid = userList[0].Id;
            valWrappObj.checkValid = 'valid';
        } else {
            System.debug('userList ---'+userList);
            valWrappObj.checkValid = 'invalid';
        }
        return valWrappObj;
    }

    public class vaidationforwrapper{
        public String id        {get; set;}
        public String isValid  {get; set;}  
        public PageReference pgReference {get; set;}
        public Integer remainingAttempt {get; set;}
    }
    public class vaidationUserwrapper{
        public String userid        {get; set;}
        public String checkValid  {get; set;}  
    }
}