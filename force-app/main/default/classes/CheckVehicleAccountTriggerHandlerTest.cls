@isTest
public class CheckVehicleAccountTriggerHandlerTest
{
    public static testmethod void CheckVehicleAccountTriggerTest1()
    {
        Vehicle_URL_Mapping__c veh2 = new Vehicle_URL_Mapping__c();
        veh2.URL__c = 'https://cdn3.hubspot.net/hubfs/2511299/iStock-494093356.jpg';
        veh2.vehicle__c = 'Dodge Charger';
        veh2.Year__c = '2020';
        insert veh2;
        
        Account acc = new Account();
        
        acc.Name = 'Test Account';
        acc.BillingStreet = 'Test Street';
        acc.BillingCity = 'Test City';
        acc.BillingState = 'ON';
        acc.BillingPostalCode = '123';
        acc.BillingCountry = 'CA';
        acc.Type='Analyst';
        acc.isUsingTriplog__c = True;
        acc.Triplog_API__c= 'abc123';
        acc.Enable_Email_For_Managers__c = True;
        acc.Vehicle_Types__c = '2020 Dodge Charger';
        insert acc;
    }
}