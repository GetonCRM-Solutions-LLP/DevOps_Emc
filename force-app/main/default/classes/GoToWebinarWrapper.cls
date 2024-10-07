public class GoToWebinarWrapper {

    public Embedded x_embedded ;// in json: _embedded

    public class Embedded {
    public List<Webinars> webinars ;
    }
    //public Page page ;

    public class Webinars {
        public String conferenceUuid;
        public String webinarKey ;
        public String webinarID ;
        public String organizerKey ;
        public String accountKey ;
        public String locale ;
        public String approvalType ;
        public String registrationUrl ;
        public Boolean impromptu ;
        public String recurrenceType ;
        public String experienceType ;

        public String subject;
        public String description;
        public List<Times> times;
        public String timeZone;
        public String type;
        public Boolean isPasswordProtected;
        public String recordingAssetKey;
        public Boolean isOndemand;
        public EmailSettings emailSettings;
        public Integer numberOfRegistrants;

        public String requestBodyForPostGoToWebinar(String accountId,String subject,String description,
                                                    DateTime startTime,DateTime endTime){

            Webinars wb = new Webinars();
            wb.subject = subject;
            wb.description = description;
            
            Times timeSingle = new Times();
            timeSingle.startTime = startTime;
            timeSingle.endTime = endTime;
    
            List<Times> lstTime = new List<Times>();
            lstTime.add(timeSingle);
    
            wb.times = lstTime;

            return JSON.serialize(wb);
        }

        public Webinars parse(String json) {
            return (Webinars) System.JSON.deserialize(json, Webinars.class);
        }   
    }

    public class AttendeeFollowUpEmail {
        public Boolean enabled;
        public Boolean includeCertificate;
    }

    public class Times {
        public DateTime startTime;
        public DateTime endTime;
    }

    public class EmailSettings {
        public ConfirmationEmail confirmationEmail;
        public ConfirmationEmail reminderEmail;
        public ConfirmationEmail absenteeFollowUpEmail;
        public AttendeeFollowUpEmail attendeeFollowUpEmail;
    }

    public class ConfirmationEmail {
        public Boolean enabled;
    }

    public GoToWebinarWrapper parse(String json) {
        return (GoToWebinarWrapper) System.JSON.deserialize(json, GoToWebinarWrapper.class);
    }    

    public class ErrorResponse {
    
        public String errorCode;
        public String description;
        public String Details;
        public String incident;
        public List<ValidationErrorCodes> validationErrorCodes;
    
        public  ErrorResponse parse(String json) {
            return (ErrorResponse) System.JSON.deserialize(json, ErrorResponse.class);
        }
    }

    public class ValidationErrorCodes {
        public String code;
        public String field;
        public String description;
    }
}