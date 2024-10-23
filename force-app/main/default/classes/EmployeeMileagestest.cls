/**
 * @description       : 
 * @author            : Harsita
 * @group             : 
 * @last modified on  : 23-10-2024
 * @last modified by  : Harsita
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   23-10-2024   Harsita   Initial Version
**/
@isTest
public class EmployeeMileagestest {

    public static testmethod void employeeMileagesTestMethod() {
        Test.startTest();
        
        // Initialize and assign values to the EmployeeMileages object
        EmployeeMileages em = new EmployeeMileages();
        em.isSelected = false;           // Boolean field
        em.isChecked = false;            // Boolean field
        em.tripdate = '';                // String field
        em.status = '';                  // String field
        em.origin = '';                  // String field
        em.destination = '';             // String field
        em.mileage = '';                 // String field
        em.variableamount = '';          // String field
        em.variablerate = '';            // String field
        em.approveddate = null;          // Datetime field, use null instead of ''
        em.submitteddate = null;         // Datetime field, use null instead of ''
        em.reimbursementid = '';         // String field
        em.month = '';                   // String field
        em.driverid = '';                // String field
        em.id = '';                      // String field
        em.dayofweek = '';               // String field
        em.endtime = '';                 // String field
        em.tracingstyle = '';            // String field
        em.emailaddress = '';            // String field
        em.totalpending = '';            // String field
        em.totalrejected = '';           // String field
        em.destinationname = '';         // String field
        em.originname = '';              // String field
        em.starttime = '';               // String field
        em.fuelRate = '';                // String field
        em.maintTyre = '';               // String field
        em.totalMileages = '';           // String field
        em.lockdate = null;              // Datetime field, use null instead of ''
        em.isLockDate = false;           // Boolean field, use false instead of ''
        em.staytime = '';                // String field
        em.drivingtime = '';             // String field
        em.totaltime = '';               // String field
        em.tripActivity = '';            // String field
        em.halfFixedAmount = '';         // String field
        em.fuelVariableRate = '';        // String field
        em.approvalName = '';            // String field
        em.toLocation = '';              // String field
        em.startdatetime = null;         // Datetime field, use null instead of ''
        em.enddatetime = null;           // Datetime field, use null instead of ''
        em.highRiskMileage = false;      // String field, use false instead of ''
        em.originalReimbursementid = ''; // String field
        em.notes = '';                   // String field
        em.tag = '';                     // String field
        em.totalMonthlyApproveVariable = '';  // String field
        em.originalOriginName = '';      // String field
        em.originalDestinationName = ''; // String field
        em.isUnapprove = false;          // Boolean field, use false instead of ''
        em.fromLocation = '';			// String field

        // Add system asserts to validate the values
        System.assertEquals(false, em.isSelected, 'isSelected should be false');
        System.assertEquals(false, em.isChecked, 'isChecked should be false');
        System.assertEquals('', em.tripdate, 'tripdate should be an empty string');
        System.assertEquals('', em.status, 'status should be an empty string');
        System.assertEquals('', em.origin, 'origin should be an empty string');
        System.assertEquals('', em.destination, 'destination should be an empty string');
        System.assertEquals('', em.mileage, 'mileage should be an empty string');
        System.assertEquals('', em.variableamount, 'variableamount should be an empty string');
        System.assertEquals('', em.variablerate, 'variablerate should be an empty string');
        System.assertEquals(null, em.approveddate, 'approveddate should be null');
        System.assertEquals(null, em.submitteddate, 'submitteddate should be null');
        System.assertEquals('', em.reimbursementid, 'reimbursementid should be an empty string');
        System.assertEquals('', em.month, 'month should be an empty string');
        System.assertEquals('', em.driverid, 'driverid should be an empty string');
        System.assertEquals('', em.dayofweek, 'dayofweek should be an empty string');
        System.assertEquals('', em.endtime, 'endtime should be an empty string');
        System.assertEquals('', em.tracingstyle, 'tracingstyle should be an empty string');
        System.assertEquals('', em.emailaddress, 'emailaddress should be an empty string');
        System.assertEquals('', em.totalpending, 'totalpending should be an empty string');
        System.assertEquals('', em.totalrejected, 'totalrejected should be an empty string');
        System.assertEquals('', em.destinationname, 'destinationname should be an empty string');
        System.assertEquals('', em.originname, 'originname should be an empty string');
        System.assertEquals('', em.starttime, 'starttime should be an empty string');
        System.assertEquals('', em.fuelRate, 'fuelRate should be an empty string');
        System.assertEquals('', em.maintTyre, 'maintTyre should be an empty string');
        System.assertEquals('', em.totalMileages, 'totalMileages should be an empty string');
        System.assertEquals(null, em.lockdate, 'lockdate should be null');
        System.assertEquals(false, em.isLockDate, 'isLockDate should be false');
        System.assertEquals('', em.staytime, 'staytime should be an empty string');
        System.assertEquals('', em.drivingtime, 'drivingtime should be an empty string');
        System.assertEquals('', em.totaltime, 'totaltime should be an empty string');
        System.assertEquals('', em.tripActivity, 'tripActivity should be an empty string');
        System.assertEquals('', em.halfFixedAmount, 'halfFixedAmount should be an empty string');
        System.assertEquals('', em.fuelVariableRate, 'fuelVariableRate should be an empty string');
        System.assertEquals('', em.approvalName, 'approvalName should be an empty string');
        System.assertEquals('', em.toLocation, 'toLocation should be an empty string');
        System.assertEquals(null, em.startdatetime, 'startdatetime should be null');
        System.assertEquals(null, em.enddatetime, 'enddatetime should be null');
        System.assertEquals(false, em.highRiskMileage, 'highRiskMileage should be an empty string');
        System.assertEquals('', em.originalReimbursementid, 'originalReimbursementid should be an empty string');
        System.assertEquals('', em.notes, 'notes should be an empty string');
        System.assertEquals('', em.tag, 'tag should be an empty string');
        System.assertEquals('', em.totalMonthlyApproveVariable, 'totalMonthlyApproveVariable should be an empty string');
        System.assertEquals('', em.originalOriginName, 'originalOriginName should be an empty string');
        System.assertEquals('', em.originalDestinationName, 'originalDestinationName should be an empty string');
        System.assertEquals(false, em.isUnapprove, 'isUnapprove should be false');
        System.assertEquals('', em.fromLocation, 'fromLocation should be an empty string');

        Test.stopTest();
    }
}