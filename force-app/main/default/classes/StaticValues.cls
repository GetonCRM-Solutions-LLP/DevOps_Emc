global class StaticValues
{
    public final static String noApprovedYet = Label.Not_Approved_Yet_Mileage_Status;
    public final static String adminEmails = Label.Email_To_Address;
    
    // Triglog base BaseURL
    public final static String TRIPLOG_BASEURL = 'https://triplogmileage.com/web';
    // Updated MLog BaseURL
    public final static String MLOG_BASEURL = 'https://app.mburse.com/web';
    // Get Trip
    public final static String GETTRIP_SUFFIX = '/api/trips?';
    //Trip Status
    public final static String STATUS_SUFFIX = '/api/tripStatus';
    //Deactivate user
    public final static String DEACTIVATE_USER_SUFFIX = '/api/users';
    // Get Trips
    public final static String TRIPS_SUFFIX =  '/api/trips?';
    //Welcome API
    public final static String WELCOME_SUFFIX = '/api/sendEmail/welcome';
    //
    public final static String GETTRIPLOCATION_SUFFIX = '/api/locations/';
    //VARIBLE FOR ROLES
    //Use in UploadConcurQuickExpenseTriplog class for post call in triplog and send total mileages.
    public final static String Concer_Quick_Expense = 'https://triplogmileage.com/web/api/uploadConcurQuickExpense';

    public final static String Concer_Quick_Connect = 'https://triplogmileage.com/web/api/sendEmail/concurConnect';
    
    public final static String Netchex_Timesheet_Connect = 'https://api.netchexonline.net/api/TimesheetImport';
    
    public final static String Netchex_APIKey = 'YXBpbWJ1cnNlOnZ1RURGRGQ5aDFUSUQh';
    //ADMINDRIVER
    public final static String roleAdminDriver = Label.RoleAdminDriver;
    //ADMINDRIVER
    public final static String ROLE_DRIVERMANAGER = 'Driver/Manager';
    //ADMINDRIVER
    public final static String ROLE_DRIVER = 'Driver';
    //ADMIN
    public final static String ROLE_GASMANAGER = 'Gas Manager';
    //
    public final static String ROLE_ADMIN = 'Admin';
    //Status of trips
    //Not Approved Yet
    public final static String STATUS_NOTAPPROVEDYET = 'Not Approved Yet';

    //EMAIL STATUS
    public final static String EMAIL_SENT = 'Sent';
    public final static String EMAIL_FAIL = 'Failed';

    public static Boolean isFirstTime = true;
    public static Boolean isFirTime = true;
    // This Value used EmployeeReimbursementTriggerHandler class Line No:- 77
    //This value is used in MappingGasPriceTrigger for check the reimbursement status Approved or not in EmployeeReimbursementTriggerHandler class.
    public static Boolean isCalledFromReimTri = true;
    public static Boolean isCalledFromBiWeekReimTri = true;
    // turning on this field will turn off the contact trigger 
    public static Boolean disableContactTrigger = false;


    // Google Distancematrix Base URL || 25/06/2024
    public final static String GOOGLEMAP_DISTANCEMATRIX_BASEURL = 'https://maps.googleapis.com/maps/api/distancematrix/json?origins=';
    // Google geocode Base URL || 25/06/2024
    public final static String GOOGLEMAP_GEOCODE_BASEURL = 'https://maps.googleapis.com/maps/api/geocode/json?address=';

}