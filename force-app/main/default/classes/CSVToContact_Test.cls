@IsTest
public class CSVToContact_Test {
	static testMethod void testParse() {
		String json = '[{\"Role\":\"Driver\",\"FirstName\":\"wo\",\"LastName\":\"pas\",\"EmailAddress\":\"wopas601856@yubua.com\",\"CellPhone\":1234565432,\"City\":\"Villa Rica\",\"State\":\"GA\",\"ZipCode\":30180,\"Department\":\"ENV\",\"JobTitle\":\"Inspector/Consultant\",\"ManagersFirstName\":\"ceni\",\"ManagersLastName\":\"pi\",\"ManagersEmail\":\"cenipi2424@zfobo.com\",\"InsuranceRate\":3134,\"LicenseandRegistration\":102,\"PersonalPropertyTax\":733,\"Depreciation\":4435,\"AnnualFixedCost\":8404,\"FixedAmount\":500.04,\"FCA\":1,\"TotalFixedAmount\":500.04,\"Meeting\":\"Attended\",\"Packet\":\"Sent\",\"DateAdded\":\"2021-10-19T18:30:00.000Z\",\"ActivationDate\":\"2022-01-31T18:30:00.000Z\",\"MPG\":25.5,\"Maint\":0.0738,\"Tires\":0.0689,\"MaintTires\":0.1427,\"StandardVehicle\":\"2022 Volkswagen Atlas\",\"ComplianceMileage\":5000,\"VehicleURL\":\"https://f.hubspotusercontent40.net/hubfs/2511299/2022-Chevy-Silverado.jpeg\"},{\"Role\":\"Driver\",\"FirstName\":\"yu\",\"LastName\":\"bua\",\"EmailAddress\":\"wopas60185@yubua.com\",\"CellPhone\":1334565432,\"City\":\"Wilmington\",\"State\":\"NC\",\"ZipCode\":28412,\"Department\":\"ENV\",\"JobTitle\":\"Inspector/Consultant\",\"ManagersFirstName\":\"ceni\",\"ManagersLastName\":\"pi\",\"ManagersEmail\":\"cenipi2424@zfobo.com\",\"InsuranceRate\":2122,\"LicenseandRegistration\":177,\"PersonalPropertyTax\":262,\"Depreciation\":3844,\"AnnualFixedCost\":6405,\"FixedAmount\":381.1,\"FCA\":2,\"TotalFixedAmount\":381.1,\"Meeting\":\"Attended\",\"Packet\":\"Sent\",\"DateAdded\":\"2021-06-14T18:30:00.000Z\",\"ActivationDate\":\"2022-05-18T18:30:00.000Z\",\"MPG\":26,\"Maint\":0.0495,\"Tires\":0.0408,\"MaintTires\":0.0903,\"StandardVehicle\":\"2022 Ford F-150\",\"ComplianceMileage\":5000,\"VehicleURL\":\"https://f.hubspotusercontent40.net/hubfs/2511299/2022-Chevy-Silverado.jpeg\"}]';
		List<CSVToContact> r = CSVToContact.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		CSVToContact objCSVToContact = new CSVToContact(System.JSON.createParser(json));
		System.assert(objCSVToContact != null);
		System.assert(objCSVToContact.Role == null);
		System.assert(objCSVToContact.FirstName == null);
		System.assert(objCSVToContact.LastName == null);
		System.assert(objCSVToContact.EmailAddress == null);
		System.assert(objCSVToContact.CellPhone == null);
		System.assert(objCSVToContact.City == null);
		System.assert(objCSVToContact.State == null);
		System.assert(objCSVToContact.ZipCode == null);
		System.assert(objCSVToContact.Department == null);
		System.assert(objCSVToContact.JobTitle == null);
		System.assert(objCSVToContact.ManagersFirstName == null);
		System.assert(objCSVToContact.ManagersLastName == null);
		System.assert(objCSVToContact.ManagersEmail == null);
		System.assert(objCSVToContact.InsuranceRate == null);
		System.assert(objCSVToContact.LicenseandRegistration == null);
		System.assert(objCSVToContact.PersonalPropertyTax == null);
		System.assert(objCSVToContact.Depreciation == null);
		System.assert(objCSVToContact.AnnualFixedCost == null);
		System.assert(objCSVToContact.FixedAmount == null);
		System.assert(objCSVToContact.FCA == null);
		System.assert(objCSVToContact.TotalFixedAmount == null);
		System.assert(objCSVToContact.Meeting == null);
		System.assert(objCSVToContact.Packet == null);
		System.assert(objCSVToContact.DateAdded == null);
		System.assert(objCSVToContact.ActivationDate == null);
		System.assert(objCSVToContact.MPG == null);
		System.assert(objCSVToContact.Maint == null);
		System.assert(objCSVToContact.Tires == null);
		System.assert(objCSVToContact.MaintTires == null);
		System.assert(objCSVToContact.StandardVehicle == null);
		System.assert(objCSVToContact.ComplianceMileage == null);
		System.assert(objCSVToContact.VehicleURL == null);
	}
}