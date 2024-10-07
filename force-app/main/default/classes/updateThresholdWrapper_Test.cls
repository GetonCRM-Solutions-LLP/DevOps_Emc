@IsTest
public with sharing class updateThresholdWrapper_Test {
	public updateThresholdWrapper_Test() {
		
	}
	static testMethod void testParse() {
		String json = '[  '+
		'   {  '+
		'      \"contactid\":\"0033100003BvW5CAAV\",'+
		'      \"threshold\":\"34.00\"'+
		'   },'+
		'   {  '+
		'      \"contactid\":\"0033100003BvW5IAAV\",'+
		'      \"threshold\":\"23.00\"'+
		'   }'+
		']';
		List<UpdateThresholdWrapper> r = updateThresholdWrapper.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		updateThresholdWrapper objUpdateThresholdWrapper = new updateThresholdWrapper(System.JSON.createParser(json));
		System.assert(objUpdateThresholdWrapper != null);
		System.assert(objUpdateThresholdWrapper.contactid == null);
		System.assert(objUpdateThresholdWrapper.threshold == null);
	}
}