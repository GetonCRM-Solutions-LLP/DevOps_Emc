/*
Author : GetonCRM Solutions LLP                                                                     
* Created Date : 09/06/2022                                                                            
* Description : This class is used to create Time & Attendance Detail Report download for 
* ermi part time and full time drivers. 
* 
* VF Page :- TimeandSummaryDetailReport               
* ----------------------------------------------------------------------------------------
* Created By : Paras Dhanani                                                                           
*/


public with sharing class TimeandSummaryDetailReportController {
    public List<mileageWrapper> mileageWrapperList{get;set;}
    public String xlsHeader{
        get{
            String strHeader = '';
            strHeader += '<?xml version="1.0" encoding="UTF-8"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;    
        }
        
    }
    public TimeandSummaryDetailReportController() {
        drivingTime();
    }
    public void drivingTime(){    
        String Id = ApexPages.currentPage().getParameters().get('id');
        String startDate = ApexPages.currentPage().getParameters().get('startDate');
        String endDate = ApexPages.currentPage().getParameters().get('endDate');
        mileageWrapperList = new List<mileageWrapper>();
        Map<String,Datetime> conEmailVsLogin = new Map<String,Datetime>();
        for(User userObj : [Select id, Contact.name, Email,LastLoginDate,ContactId, AccountId, IsPortalEnabled  
                            FROM User 
                            WHERE IsPortalEnabled = true 
                                AND Contact.AccountId =:Id 
                                // AND (Contact.Driver_Type__c = 'Driver - Full Time' or Contact.Driver_Type__c = 'Driver - Part Time')
                                ]){
                                    conEmailVsLogin.put(userObj.ContactId,userObj.LastLoginDate);
                            }
        
        for(Bi_Weekly_Reimbursement__c biweeklyreim : [SELECT Name,Contact__r.Name, Contact__r.External_Email__c,Confirm_Hours__c,Confirm_Hours_Time__c, 
                                                       Actual_Drive_Time__c, Actual_Stay_Time__c, Actual_Hours__c,Contact__r.Driver_Type__c,Sync_3_Mileages__c,Sync_3_Drive_Time__c,
                                                       Actual_Mileages__c, Sync_1_Hours__c, Sync_1_Mileages__c,Sync_1_Drive_Time__c,Sync_1_Stay_Time__c,Sync_3_Stay_Time__c,Sync_3_Hours__c,
                                                       Sync_2_Hours__c, Sync_2_Mileages__c,Sync_2_Drive_Time__c,Sync_2_Stay_Time__c ,Total_Drive_Time__c,Total_Stay_Time__c,Total_Time__c,
                                                       Confirm_Mileages__c,Confirm_Drive_Time__c,Confirm_Stay_Time__c,Confirm_Total_Hours__c
                                                       FROM Bi_Weekly_Reimbursement__c 
                                                       WHERE Start_Date__c =: Date.valueOf(startDate)
                                                           AND End_Date__c =: Date.valueOf(endDate)                                                           
                                                           AND Contact__r.AccountId =: id ]){
                                                           
                                                           mileageWrapper objMileageWrap = new mileageWrapper();
                                                           objMileageWrap.dates =  biweeklyreim.Name;
                                                           objMileageWrap.contactName =  biweeklyreim.Contact__r.Name ;
                                                           objMileageWrap.email =  biweeklyreim.Contact__r.External_Email__c ; 
                                                           objMileageWrap.driverType =  biweeklyreim.Contact__r.Driver_Type__c; 
                                                           objMileageWrap.intialmileage =   biweeklyreim.Actual_Mileages__c != null ? String.valueOf((biweeklyreim.Actual_Mileages__c).setScale(2)) : '';
                                                           objMileageWrap.sync1Mileage =   biweeklyreim.Sync_1_Mileages__c != null ? String.valueOf((biweeklyreim.Sync_1_Mileages__c).setScale(2)) : '';
                                                           objMileageWrap.sync2Mileage =  biweeklyreim.Sync_2_Mileages__c != null ?String.valueOf((biweeklyreim.Sync_2_Mileages__c).setScale(2)) : '';   
                                                           objMileageWrap.sync3Mileage =  biweeklyreim.Sync_3_Mileages__c != null ?String.valueOf((biweeklyreim.Sync_3_Mileages__c).setScale(2)) : '';   
                                                           objMileageWrap.confirmMileage =  biweeklyreim.Confirm_Mileages__c != null ?String.valueOf((biweeklyreim.Confirm_Mileages__c).setScale(2)) : '';   
                                                           
                                                           if(biweeklyreim.Confirm_Hours__c != null && biweeklyreim.Confirm_Hours__c == true ){
                                                               objMileageWrap.confirmTrips = 'Yes';
                                                           } else {
                                                                objMileageWrap.confirmTrips = 'No';
                                                           }                                                       
                                                           if(conEmailVsLogin.containsKey(biweeklyreim.Contact__c)) {
                                                               if(conEmailVsLogin.get(biweeklyreim.Contact__c) != null){
                                                                   DateTime dt = conEmailVsLogin.get(biweeklyreim.Contact__c);
                                                                   String dateTimeStr = dt.format('MM/dd/yyyy hh:mm:ss a');
                                                                   objMileageWrap.loginHours = dateTimeStr;
                                                               }
                                                           }    
                                                           if(biweeklyreim.Confirm_Hours_Time__c != null){
                                                               DateTime dt = biweeklyreim.Confirm_Hours_Time__c;
                                                               String dateTimeStr = dt.format('MM/dd/yyyy hh:mm:ss a');
                                                               objMileageWrap.confirmHours = dateTimeStr;
                                                           } 
                                                           
                                                           if(objMileageWrap.driverType != null && objMileageWrap.driverType == 'Driver - Salary'){
                                                                
                                                           } else {
                                                               objMileageWrap.initialDriveTime = Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Actual_Drive_Time__c)) != '0' ? Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Actual_Drive_Time__c)) : '';
                                                               objMileageWrap.initialStayTime = Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Actual_Stay_Time__c)) != '0' ? Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Actual_Stay_Time__c)) : '';                                                            
                                                               objMileageWrap.initiaTotalTime = Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Actual_Hours__c)) != '0' ? Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Actual_Hours__c)) : '';
                                                               
                                                               objMileageWrap.sync1driveTime = Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Sync_1_Drive_Time__c)) != '0' ? Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Sync_1_Drive_Time__c)) : '';
                                                               objMileageWrap.sync1stayTime = Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Sync_1_Stay_Time__c)) != '0' ? Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Sync_1_Stay_Time__c)) : '';
                                                               objMileageWrap.sync1Hours = Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Sync_1_Hours__c)) != '0' ? Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Sync_1_Hours__c)) : '';
                                                               
                                                               objMileageWrap.sync2driveTime = Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Sync_2_Drive_Time__c)) != '0' ? Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Sync_2_Drive_Time__c)) : '';
                                                               objMileageWrap.sync2stayTime = Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Sync_2_Stay_Time__c )) != '0' ?Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Sync_2_Stay_Time__c )) : '';
                                                               objMileageWrap.sync2Hours = Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Sync_2_Hours__c)) != '0' ? Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Sync_2_Hours__c)) : '';
                                                               
                                                               objMileageWrap.sync3driveTime = Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Sync_3_Drive_Time__c)) != '0' ? Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Sync_3_Drive_Time__c)) : '';
                                                               objMileageWrap.sync3stayTime = Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Sync_3_Stay_Time__c )) != '0' ? Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Sync_3_Stay_Time__c )) : '';
                                                               objMileageWrap.sync3Hours = Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Sync_3_Hours__c)) != '0' ? Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Sync_3_Hours__c)) : '';    
                                                           } 
                                                           objMileageWrap.fnlDriveTime= Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Total_Drive_Time__c)) != '0' ? Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Total_Drive_Time__c)) : '';
                                                           objMileageWrap.fnlStayTime= Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Total_Stay_Time__c)) != '0' ? Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Total_Stay_Time__c)) : '';
                                                           objMileageWrap.fnlTotalTime= Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Total_Time__c)) != '0' ? Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Total_Time__c)) : '';                                                          
                                                           
                                                           objMileageWrap.confirmdriveTime = Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Confirm_Drive_Time__c)) != '0' ? Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Confirm_Drive_Time__c)) : '';
                                                           objMileageWrap.confirmstayTime = Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Confirm_Stay_Time__c)) != '0' ? Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Confirm_Stay_Time__c)) : '';
                                                           objMileageWrap.confirmTotalHours = Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Confirm_Total_Hours__c)) != '0' ? Utils.ConvertMinuteToHours(Integer.valueOf(biweeklyreim.Confirm_Total_Hours__c)) : ''; 
                                                                                                                                                             
                                                           mileageWrapperList.add(objMileageWrap);
                                                       }
    }
    
    public class mileageWrapper{
        public string dates { get; set; }
        public string contactName { get; set; }
        public string email { get; set; }
        public string driverType { get; set; }
        public string initialDriveTime { get; set; }
        public string initialStayTime { get; set; }
        public string initiaTotalTime { get; set; }
        public string intialmileage { get; set; }
        public string sync1driveTime { get; set; }
        public string sync1stayTime { get; set; }
        public string sync1Hours { get; set; }
        public string  sync1Mileage { get; set; }
        public string sync2driveTime { get; set; }
        public string sync2stayTime { get; set; }
        public string sync2Hours { get; set; }
        public string sync2Mileage { get; set; }
        public string sync3driveTime { get; set; }
        public string sync3stayTime { get; set; }
        public string sync3Hours { get; set; }
        public string sync3Mileage { get; set; }
        public string confirmdriveTime { get; set; }
        public string confirmstayTime { get; set; }
        public string confirmTotalHours { get; set; }
        public string confirmMileage { get; set; }
        public string loginHours { get; set; }
        public string confirmTrips{ get; set; }
        public string confirmHours { get; set; }
        public string fnlDriveTime { get; set; }
        public string fnlStayTime { get; set; }
        public string fnlTotalTime { get; set; }
        public mileageWrapper(){
        }
    }
}