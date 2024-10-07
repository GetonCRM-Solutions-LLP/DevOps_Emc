public with sharing class TestUtilities {
	
	public Contact 		aContac			{get; set;}
	public Attachment 	aAttachment		{get; set;}
	
	public void generateContact(){
		Account a=new Account(Name='test');
        insert a;
        
	    this.aContac 				= new Contact();
	    this.aContac.firstName 		= 'Test';
	    this.aContac.LastName 		= 'Test'; 
	    this.aContac.External_Email__c='test@test.com';
	    this.aContac.Accountid=a.id;
        insert this.aContac; 

	    this.aAttachment = new Attachment(); 
	    this.aAttachment.Body = Blob.valueOf('String');
	}
	
	public static TestUtilities generateTest(){
		TestUtilities e = new TestUtilities();
		e.generateContact();
		return e;
	}
}