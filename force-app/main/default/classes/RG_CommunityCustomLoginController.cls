public with sharing class RG_CommunityCustomLoginController {
    public String username {get;set;}
    public String password {get;set;}
    public Boolean popup {get;set;}
    Integer invalidUsernameCount;
    public Boolean isUsernameInvalid {get;set;}
    public Boolean isLimitExeeded {get;set;}
    public Boolean isPasswordInvalid {get;set;}
    
    public RG_CommunityCustomLoginController () {
        popup = false;
        invalidUsernameCount = 0;
        String param = ApexPages.currentPage().getParameters().get('param1');
        if ('true'.Equals(param)) {
            popup= true;
        }
    }
    
    public PageReference login() {
        isUsernameInvalid = false;
        isLimitExeeded = false;
        isPasswordInvalid = false;
        PageReference pgRef = Site.login(username, password, null);
        Boolean isValidUsername = validateUsername(username);
        if(!isValidUsername && invalidUsernameCount < 3) {
            invalidUsernameCount++;
            isUsernameInvalid = true;
            isPasswordInvalid = false;
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
    
    public Boolean validateUsername(String username) {
        Boolean isValid = false;
        List<User> users = new List<User>([SELECT Id, Email FROM User WHERE IsPortalEnabled = true AND Email =: username]);
        if(!users.isEmpty()) {
            isValid = true;
        }
        return isValid;
    }
}