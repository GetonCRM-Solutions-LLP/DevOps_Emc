@isTest
public class SingleEmailUtil_Test{
    public static testmethod void singleEmailUtiltestMethod() {
        List<String> toAddresses = new List<String>();
        List<Messaging.singleEmailMessage> singleEmailList = new List<Messaging.singleEmailMessage>();
        SingleEmailUtil seu = new SingleEmailUtil();
        SingleEmailUtil.htmlReplaceText('EMC-Will','-','_'); 
        SingleEmailUtil.buildEmail(toAddresses,'Email','HTML Body');
        SingleEmailUtil.sendSingleEmail(singleEmailList);
    }
}