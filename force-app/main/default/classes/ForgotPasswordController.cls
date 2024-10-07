/**
 * An apex page controller that exposes the site forgot password functionality
 */
public without sharing class ForgotPasswordController {
    public String username {get; set;}
    public static String userID {get; set;}
    public static string value = 'true';
    public static string url;

    /**
    * Constructor
    */  
    public ForgotPasswordController() {}

    /**
    * Check UserName in community regarding forgot password
    */

    @RemoteAction
    public static string checkUserNameForCommunity(String username){
   
     system.debug('username'+username); 
        if(username != null && username != ''){
           List<User> userObj = [Select Id, Name, Profile.Name From User where Email =: username  OR Username =: username Limit 1];
           system.debug('userobject'+ userObj.size()); 
           if(userObj.size() > 0){
                userID = userObj[0].Id;
                system.debug('userID2---'+userID); 
              return 'valid';
           } 
        
        } 
        return 'invalid';
    }
    
    /**
    * reset password for community
    */
    @RemoteAction
    public static PageReference resetPasswordForCommunity(String username) {
        //boolean success = Site.forgotPassword(username)
        system.debug(''+username);
        List<User> userObj = [Select Id, Name, Profile.Name From User where Email =: username  OR Username =: username Limit 1];
        system.debug('userObj'+userObj);
        if(!userObj.isEmpty()){
            system.debug('userObj[0].Id'+userObj[0].Id);
            System.ResetPasswordResult currectUserResult = System.resetPassword(userObj[0].Id, true); 
        }
          
        url = '/app/adminlogin?param1=' + value;
        system.debug('url---'+url); 
        PageReference pr = new PageReference(url);
        pr.setRedirect(true);
        return pr;
    }
    
  
     public PageReference resetPassword() {
      String username;
      system.debug('username2'+username); 
      boolean success = Site.forgotPassword(username);
        //PageReference pr = Page.ForgotPasswordConfirm;
        url = '/Comm/RG_CommunitiesLogin?param1=' + value;
        //PageReference pr = Page.RG_Login;
        PageReference pr = new PageReference(url);
        pr.setRedirect(true);
        
        if (success) {
            return pr;
        }
        return null;
    }
}