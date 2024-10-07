public with sharing class SingleEmailUtil 
{
	public SingleEmailUtil() 
	{
		
	}
	public static string htmlReplaceText(string htmlvalue,string toReplace,string actualValue)
    {
        if(htmlvalue.contains(toReplace) && (actualValue!=null))
        {
            htmlvalue = htmlvalue.replace(toReplace,actualValue);
        }
     	return htmlvalue;   
    }
    public static void sendSingleEmail(List<Messaging.singleEmailMessage> singleEmailList)
    {
        if(singleEmailList!=null && singleEmailList.size()>0 && !Test.isRunningTest())
        {
            try
            {
                Messaging.sendEmail(singleEmailList);
            }
            catch(EmcException e)
            {
                
            }
        }
    }
    public static Messaging.singleEmailMessage buildEmail(List<String> toAddresses,String subject,String html)
    {
        OrgWideEmailAddress[] owea = [SELECT Id ,Address from OrgWideEmailAddress where Address =:System.Label.DriverServicesEmail];
        messaging.singleEmailMessage mail = new messaging.singleEmailMessage();
        mail.setOrgWideEmailAddressId(owea.get(0).Id);
        if(toAddresses.size()==0)
        {
        	if(Label.Email_To_Address.contains(','))
        	{
        		for(String obj_single_email_address: Label.Email_To_Address.split(','))
        		{
    				if(obj_single_email_address.contains(','))
    				{
    					obj_single_email_address = obj_single_email_address.remove(',');
    				}
        			toAddresses.add(obj_single_email_address.trim());
        		}
        	}
        	else
        	{
        		toAddresses.add('minkesh.patel@getoncrm.com');
        	}
        }              
        mail.setToAddresses(toAddresses);        
        mail.setSubject(subject);
        mail.setHtmlBody(html);
        return mail;
    }
}