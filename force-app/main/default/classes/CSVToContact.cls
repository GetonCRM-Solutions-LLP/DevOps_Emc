/**
 * @description       : 
 * @author            : Vatsal Bhalani
 * @group             : 
 * @last modified on  : 09-13-2024
 * @last modified by  : Vatsal Bhalani
**/
public class CSVToContact {

	public String Role {get;set;} 
	public String FirstName {get;set;} 
	public String LastName {get;set;} 
	public String EmailAddress {get;set;} 
	public String CellPhone {get;set;} 
	public String City {get;set;} 
	public String State {get;set;} 
	public String ZipCode {get;set;} 
	public String Department {get;set;} 
	public String JobTitle {get;set;} 
	public String ManagersFirstName {get;set;} 	
	public String ManagersLastName {get;set;} 
	public String ManagersEmail {get;set;} 
	public Integer InsuranceRate {get;set;} 
	public Integer LicenseandRegistration {get;set;} 
	public Integer PersonalPropertyTax {get;set;} 
	public Integer Depreciation {get;set;} 
	public Integer AnnualFixedCost {get;set;} 
	public Double FixedAmount {get;set;} 
	public Integer FCA {get;set;} 
	public Double TotalFixedAmount {get;set;} 
	public String Meeting {get;set;} 
	public String Packet {get;set;} 
	public String DateAdded {get;set;} 
	public String ActivationDate {get;set;} 
	public Double MPG {get;set;} 
	public Double Maint {get;set;} 
	public Double Tires {get;set;} 
	public Double MaintTires {get;set;} 
	public String StandardVehicle {get;set;} 
	public Integer ComplianceMileage {get;set;} 
	public String VehicleURL {get;set;} 
	public String DrivingState{get;set;}

	public CSVToContact(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'Role') {
						Role = parser.getText();
					} else if (text == 'FirstName') {
						FirstName = parser.getText();
					} else if (text == 'LastName') {
						LastName = parser.getText();
					} else if (text == 'EmailAddress') {
						EmailAddress = parser.getText();
					} else if (text == 'CellPhone') {
						CellPhone = parser.getText();
					} else if (text == 'City') {
						City = parser.getText();
					} else if (text == 'State') {
						State = parser.getText();
					} else if (text == 'ZipCode') {
						ZipCode = parser.getText();
					} else if (text == 'Department') {
						Department = parser.getText();
					} else if (text == 'JobTitle') {
						JobTitle = parser.getText();
					} else if (text == 'ManagersFirstName') {
						ManagersFirstName = parser.getText();
					} else if (text == 'ManagersLastName') {
						ManagersLastName = parser.getText();
					} else if (text == 'ManagersEmail') {
						ManagersEmail = parser.getText();
					} else if (text == 'InsuranceRate') {
						InsuranceRate = parser.getIntegerValue();
					} else if (text == 'LicenseandRegistration') {
						LicenseandRegistration = parser.getIntegerValue();
					} else if (text == 'PersonalPropertyTax') {
						PersonalPropertyTax = parser.getIntegerValue();
					} else if (text == 'Depreciation') {
						Depreciation = parser.getIntegerValue();
					} else if (text == 'AnnualFixedCost') {
						AnnualFixedCost = parser.getIntegerValue();
					} else if (text == 'FixedAmount') {
						FixedAmount = parser.getDoubleValue();
					} else if (text == 'FCA') {
						FCA = parser.getIntegerValue();
					} else if (text == 'TotalFixedAmount') {
						TotalFixedAmount = parser.getDoubleValue();
					} else if (text == 'Meeting') {
						Meeting = parser.getText();
					} else if (text == 'Packet') {
						Packet = parser.getText();
					} else if (text == 'DateAdded') {
						DateAdded = parser.getText();
					} else if (text == 'ActivationDate') {
						ActivationDate = parser.getText();
					} else if (text == 'MPG') {
						MPG = parser.getDoubleValue();
					} else if (text == 'Maint') {
						Maint = parser.getDoubleValue();
					} else if (text == 'Tires') {
						Tires = parser.getDoubleValue();
					} else if (text == 'MaintTires') {
						MaintTires = parser.getDoubleValue();
					} else if (text == 'StandardVehicle') {
						StandardVehicle = parser.getText();
					} else if (text == 'ComplianceMileage') {
						ComplianceMileage = parser.getIntegerValue();
					} else if (text == 'VehicleURL') {
						VehicleURL = parser.getText();
					} else if (text == 'DrivingState') {
						DrivingState = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'CSVToContact consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	public static List<CSVToContact> parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return arrayOfCSVToContact(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	





    private static List<CSVToContact> arrayOfCSVToContact(System.JSONParser p) {
        List<CSVToContact> res = new List<CSVToContact>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new CSVToContact(p));
        }
        return res;
    }


}