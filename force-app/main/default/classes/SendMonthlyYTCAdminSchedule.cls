/******************************************************************
Description:   Schedule class for SendMonthlyYTCAdmin class
Functionality: Schedule for every month and send mail to YTC Admin
******************************************************************/
global class SendMonthlyYTCAdminSchedule implements Schedulable {
   global void execute(SchedulableContext sc) {
      SendMonthlyYTCAdmin sendAdmin = new SendMonthlyYTCAdmin(); 
      sendAdmin.sendMailAdim();
   }
}