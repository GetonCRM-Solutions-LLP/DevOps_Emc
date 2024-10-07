@isTest
public class ContactDetailsTest {
    public static testmethod void employeeTest(){
        ContactDetails empDetail = new ContactDetails();
        empDetail.accountName = 'test';
        empDetail.contactName  = 'EmployeeDetail';
        empDetail.zipCode  = '382225';
        empDetail.city      = 'Cincinnati';
        empDetail.state     = 'Ohio';
        empDetail.vehicalType     = '00B310000065iFf';
        List<String> listDrivingStates = new List<String> {'CA','LA','OH','NY'};
        empDetail.drivingStates  = listDrivingStates;
        empDetail.fixedamount = '500';
        empDetail.compliancestatus ='';
        empDetail.insuranceAttchId      = 'a001h000001swsP';
        empDetail.driverType = 'asc';
        empDetail.annualReim = '50';
        empDetail.annualMileages = '57';
        empDetail.planInsurance = '1200';
        empDetail.complianceMileage = '1200';
        empDetail.planYears = '1200';
        empDetail.vehicleValue = '1200';
        empDetail.insuranceDate = System.today();
        empDetail.notimessage= 'abc';
        empDetail.vehicleage = 'abc';
        empDetail.vehiclevaluecheck = 'abc';
        empDetail.mileagemeet = 'abc';
        empDetail.insurance = 'asc';
        
    }
}