public with sharing class UpdateMileageWithReimController {
    public List<SearchCriteriaRow> advcriteriaRows              {get; set;}
    public Map<String, List<SelectOption>> availableFields      {get; set;}
    public Map<string, List<SelectOption>> availableOperators   {get; set;}
    public String cObj                                          {get; set;}
    public String filterCriteria                                {get; set;}
    public String RecPerPage                                    {get; set;}
    public String AlphaFilter                                   {get; set;}
    public String allPRfields;
    public Employee_Mileage__c PRObj                            {get; set;}
    public Employee_Mileage__c PRObjForNotes                    {get; set;}
    private String soql;
    public String queryFieldNames;
    public String queryOperators;
    public String queryValues;
    public Integer size                                         {get; set;}
    public Integer noOfJobRecords                               {get; set;}
    public List<WrapperMainTable> maintableDataList             {get; set;}
    public list<PRfieldWrapper> pRfieldWrapperList              {get; set;}
    public String SelectedOrgnizedOwnerID                       {get; set;}
    public string str                                           {get; set;}
    public boolean isToogleArrow                                {get; set;}
    public String SortFieldSave;
    public List<SelectOption> monthOptions                      {get; set;}
    public String selectedMonth                                 {get; set;}
    public Map<String,WrapperMainTable> obj_map_WrapperMainTable  {get; set;}
    // public Employee_Mileage__c empMilea;
    //public List<SearchCriteriaRow > advcriteriaRows {get;set;}

    /*public ApexPages.StandardSetController setCon {
        
        get{
            if(setCon == null) {
                size = 20;
                string queryString = 'SELECT id,name,Approved_Date__c ,Contact_Email_Id__c,Employee_ID__c,CreatedDate ,LastModifiedDate , Trip_Date__c,Trip_Date_Month__c,Trip_Status__c,Fuel_price__c,EmployeeReimbursement__r.Name,EmployeeReimbursement__r.Month__c,Maintenance_and_Tires__c,Mileage__c,MPG__c FROM Employee_Mileage__c limit 9999';
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCon.setPageSize(size);
                system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'+setCon);
                noOfJobRecords = setCon.getResultSize();
            }
            return setCon;
        }set;
    }*/



    public UpdateMileageWithReimController() {
    
    
        advcriteriaRows = new List<SearchCriteriaRow>{new SearchCriteriaRow(1,null, null, null, null,'String')};
        cObj = 'Employee_Mileage__c';
        //Employee_Mileage__c empMilea = new Employee_Mileage__c();
        availableOperators = new Map<string, List<SelectOption>>();
        availableOperators = availableOperators();
        
        availableFields = new Map<string, List<SelectOption>>();
        availableFields = AddcontactsavailableFields();
        queryFieldNames = '';
        queryOperators = '';
        queryValues = '';
        SelectedOrgnizedOwnerID = '';
        advcriteriaRows = new List<SearchCriteriaRow>{new SearchCriteriaRow (1,null, null, null, null,'String')};
        
        if (apexpages.currentpage().getparameters().get('alpha') == null) {
            AlphaFilter = 'All';
        } else {
            AlphaFilter = apexpages.currentpage().getparameters().get('alpha');
        }
        
        allPRfields = getCreatableFieldslist('Employee_Mileage__c','');
        system.debug('----allPRfields---'+allPRfields);
        
        //list<account> clientAccs = MyContactQueryGenerator.getloggedinUserclientRecord();
        //system.debug('----clientAccs---'+clientAccs);
        String pageSize = System.Label.Page_View_State;
        RecPerPage = (pageSize.isNumeric() && Integer.valueOf(pageSize) > 0) ? pageSize : '200';
        soql = 'SELECT id,name,Approved_Date__c ,Contact_Email_Id__c,Employee_ID__c,CreatedDate ,LastModifiedDate , Trip_Date__c,Trip_Date_Month__c,Trip_Status__c,Fuel_price__c,EmployeeReimbursement__r.Name,EmployeeReimbursement__r.Month__c,Maintenance_and_Tires__c,Mileage__c,MPG__c FROM Employee_Mileage__c limit 9999';
        BuildQuery();
        FillPRFielfsetWrapper();
        getEmployeeMileageRecords();
        fillMainDataList();
    }

    public List<SelectOption> getMonth() {
        monthOptions = new List<SelectOption>();
        Date currentDate = System.today();
        monthOptions.add(new SelectOption('','--None--'));
        for(Integer i=1;i<=12;i++) {
            String addZero = (isBetween(1,i,9)) ? '0'+String.valueOf(i) : String.valueOf(i);
            monthOptions.add(new SelectOption(addZero+'-'+currentDate.year(),addZero+'-'+currentDate.year()));
        }
        return monthOptions;
    }

    public static boolean isBetween(Integer a, Integer b, Integer c) {
        return b <= c ? c > a && c >= b : c > b && c < a;
    }

    public void updateMileage() {
        if(!maintableDataList.isEmpty() && selectedMonth != '' && selectedMonth != null) 
        {
            List<Employee_Mileage__c> updateMileage = new List<Employee_Mileage__c>();
            Set<String> mileageIds = new Set<String>();
            Map<String, Employee_Mileage__c> mapOfMileage = new Map<String, Employee_Mileage__c>();
            for(WrapperMainTable mainTable : maintableDataList) 
            {
                if(mainTable.IsPRSelected) 
                {
                    mileageIds.add(mainTable.Mileage.Contact_Email_Id__c);
                    mapOfMileage.put(mainTable.Mileage.Id+'#'+mainTable.Mileage.Contact_Email_Id__c, mainTable.Mileage);
                }
            }
            System.Debug('========================> mileageIds Set '+mileageIds);
            System.Debug('========================> mapOfMileage Map'+mapOfMileage);
            if(!mileageIds.isEmpty()) 
            {
                System.debug('selectedMonth:'+selectedMonth);
                List<Employee_Reimbursement__c> listOfReim = [SELECT Id,Contact_Email__c,Month__c FROM Employee_Reimbursement__c WHERE Month__c =: selectedMonth AND Contact_Email__c IN: mileageIds];
                Map<String,Id> reimMap = new Map<String,Id>();
                for(Employee_Reimbursement__c singleReim : listOfReim) 
                {
                    reimMap.put(singleReim.Contact_Email__c, singleReim.Id);
                }
                System.Debug(reimMap);
                /*for(String singleString : mapOfMileage.keySet()) {
                    List<String> splitString = singleString.split('#');
                    if(reimMap.containsKey(splitString[1])) {
                        Employee_Mileage__c newMileage = new Employee_Mileage__c();
                        newMileage.Id = splitString[0];
                        newMileage.EmployeeReimbursement__c = reimMap.get(splitString[1]);
                        updateMileage.add(newMileage);
                    }
                }*/
                for(WrapperMainTable mainTableCheck : maintableDataList) 
                {
                    if(mainTableCheck.IsPRSelected && reimMap.containsKey(mainTableCheck.Mileage.Contact_Email_Id__c)) 
                    {
                        mainTableCheck.Mileage.EmployeeReimbursement__c = reimMap.get(mainTableCheck.Mileage.Contact_Email_Id__c);
                        updateMileage.add(mainTableCheck.Mileage);
                        System.debug('updateMileage :-'+updateMileage);
                    }
                }
                if(!updateMileage.isEmpty()) 
                {
                    StdSetControllerPR.save();
                    //update updateMileage;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'All Mileage Updated'));
                }
            }else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Select Mileage'));
            }
        }else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Select Month to Transfer'));
        }
    }

    // pagination using standard set controller using on page load
    Public List<Employee_Mileage__c> getEmployeeMileageRecords(){
        List<Employee_Mileage__c> empMileList = new List<Employee_Mileage__c>();
        
        for(Employee_Mileage__c a : (List<Employee_Mileage__c>)StdSetControllerPR.getRecords()){

            empMileList.add(a);
        }
        return empMileList;
    }
     
    public pageReference refresh() {
        StdSetControllerPR = null;
        getEmployeeMileageRecords();
        StdSetControllerPR.setPageNumber(1);
        return null;
    }
    

    public void FillPRFielfsetWrapper()
    {
        pRfieldWrapperList = new list<PRfieldWrapper>();
        for(Schema.FieldSetMember f : this.getPRFields()) 
        {
            system.debug('---f----'+f);
            pRfieldWrapperList.add(new PRfieldWrapper(f.getLabel(), f.getFieldPath(), f.getRequired(),'asc',false));
        }
    }

    public void previous() {
        StdSetControllerPR.previous();
        fillMainDataList();
    }
     
    public void next() {
    
        StdSetControllerPR.next();
        
        fillMainDataList();
    }

    public List<Schema.FieldSetMember> getPRFields()
    {
        return SObjectType.Employee_Mileage__c.FieldSets.UpdateMileagePageUse.getFields();
    }

    public String SortField {
        get { if (SortField == null) {SortField = 'Createddate'; } return SortField;  }
        set; 
    }

    public String SortDirection {
        get { if (SortDirection == null) {  SortDirection = 'desc'; } return SortDirection;  }
        set;
    }

    public void BuildQuery() {
        try {
            StdSetControllerPR = null;
            String queryWhere = buildQueryforSearch();
            //String QueryWhere = buildQueryforPRSearch(QueryWhere, AlphaFilter, allPRfields, SortField, SortDirection, empMilea);
            Employee_Mileage__c empMilea = new Employee_Mileage__c();
            String newsoql = Generatecontactquery(queryWhere,AlphaFilter,allPRfields,SortField,SortDirection,empMilea);
           //String newsoql = buildQueryforPRSearch(QueryWhere, AlphaFilter, allPRfields, SortField, SortDirection, empMilea);
            System.debug('---newsoql==>' +newsoql);
            soql = newsoql;
            fillMainDataList();
            getPageMsg();
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getmessage()));
        }
    }

   
    public ApexPages.StandardSetController StdSetControllerPR {
        get {
            if(StdSetControllerPR == null)
            {
                try {
                    if(soql != null && soql != '') {
                        StdSetControllerPR = new ApexPages.StandardSetController(Database.getQueryLocator(soql));
                        // sets the number of records in each page set
                        
                        StdSetControllerPR.setPageSize(Integer.valueOf(RecPerPage));
                    }
                } catch(Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getmessage()));
                }
            }
            return StdSetControllerPR;
        }
        set;
    }

    ////// Fill Table wrapper list with checkbox as false after Search /////////////////////
    public list<WrapperMainTable> fillMainDataList()
    {
        obj_map_WrapperMainTable = new Map<String,WrapperMainTable>();
        maintableDataList = new list<WrapperMainTable>();
        system.debug('StdSetControllerPR>>>>>>>>>>>>>>>>>>>>>'+StdSetControllerPR.getResultSize());
        Integer count=0;
        if(soql != null && soql != '')
        {
            for (Employee_Mileage__c PR: (list<Employee_Mileage__c>) StdSetControllerPR.getRecords())
            {
                string bounceColor = 'black';
            
               // String NumericalMemAssementValue = string.ValueOf(PR.id);
               // added  by natavar 25/6
               WrapperMainTable obj_WrapperMainTable = new WrapperMainTable();
               obj_WrapperMainTable.mileage =PR;
               obj_WrapperMainTable.BounseColor =bounceColor;
               obj_WrapperMainTable.IsPRSelected =false;
               obj_WrapperMainTable.idofem=PR.id;
               System.Debug('++ Count :- '+count);
               maintableDataList.add(obj_WrapperMainTable);
               
               
            }
        }
        system.debug('-----MaintableDataList------'+maintableDataList);
        return maintableDataList;
    }

    public static string getCreatableFieldslist(String objectName,String additionalFields)
    {
        system.debug('---objectName---'+objectName);
        system.debug('---additionalFields---'+additionalFields);
        String selects = '';
       
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
 

        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
              //  if (fd.isCreateable()){ // field is creatable                    
                    selectFields.add(fd.getName());
              //  }
            }
        }
        
       if(!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            selects += additionalFields;
                if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
            
        }
        return 'SELECT ' + selects;
    }

    public class WrapperMainTable {
    // added by natavar date 25/6
    public WrapperMainTable()
    {
    }
        
        public Employee_Mileage__c mileage {get;set;}
        public String BounseColor{get;set;}
        //public Integer NumricalAssesmentScore{get;set;}
        public boolean IsPRSelected{get;set;}
        public String idofem{get;set;}
        public WrapperMainTable (Employee_Mileage__c singleMileage,String BounseColor,boolean Isselected)
        {
            this.mileage = singleMileage;
            this.BounseColor = BounseColor;
            this.idofem = singleMileage.id;
            //this.NumricalAssesmentScore = NumricalAssesmentScore;
            this.IsPRSelected = Isselected;
        }
    }

    public class PRfieldWrapper
    {
        public string fieldLabel          {get;set;}
        public string fieldAPIName        {get;set;}
        public boolean isFieldRequired    {get;set;}
        public string fieldsortorder      {get;set;}
        public boolean isToogleArrow      {get;set;}
        
        public PRfieldWrapper(String fieldLabelVal, String fieldAPINameVal, Boolean isRequiredVal,string fieldsortorderval,boolean isToogleArrowval)
        {
            fieldLabel = fieldLabelVal;
            fieldAPIName = fieldAPINameVal;
            isFieldRequired = isRequiredVal;
            fieldsortorder = fieldsortorderval;
            isToogleArrow = isToogleArrowval;
        }
    }


    ////////////// This will save only one contact which was selected for inline-edit /////////
    public void savePRObj()
    {
        try{
            update PRObj;
            BuildQuery();
            PRObj = new Employee_Mileage__c();
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getmessage()));
        }
    }

    public String getPageMsg() {
    System.debug('Here');
        Integer UpperNumber = 1;
        Integer ToNumber = 0;
        Integer OfNumber = StdSetControllerPR.getResultSize();
        System.debug('OfNumber:'+OfNumber);
        Integer PageNumber = StdSetControllerPR.getPageNumber() - 1;
        Integer PageSize = StdSetControllerPR.getPageSize();
        if(StdSetControllerPR.getResultSize() > 0){
            UpperNumber = (PageSize*PageNumber) + 1;
        } else {
            UpperNumber = (PageSize*PageNumber);
        }
        ToNumber = (PageSize*PageNumber) + MaintableDataList.size();
        string PageMsg = 'Showing '+UpperNumber+' to '+ToNumber+' of '+OfNumber+' Records';
        system.debug('-----PageMsg------'+PageMsg);
        return PageMsg;
    }
    
    public void saveCriteriaTurf() {
        try{
            
            
            string whereClause; // = buildQueryforPRSearch(QueryWhere, AlphaFilter, allPRfields, SortField, SortDirection, empMilea);
            System.debug('---whereClause---'+whereClause);
            if(SelectedOrgnizedOwnerID != null && SelectedOrgnizedOwnerID != ''){
                if(whereClause != null && whereClause != '')
                {
                    str = whereClause;
                    //saveCriteriaTurfExternally(string whereClause,Employee_Mileage__c client)
                }
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You have not selected any user yet, Please Select user first and try again'));
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getmessage()));
        }
    }

    public String buildQueryforSearch() {
        System.debug('--advcriteriaRows--'+advcriteriaRows);
        System.debug('--filterCriteria--'+filterCriteria);
        
        boolean isAllValidVal = isValidPickListVal(advcriteriaRows);
        if(!isAllValidVal){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select values by clicking the lookup icon to the right.'));
        }
        System.debug('--isAllValidVal--'+isAllValidVal);
        return buildQueryforPRSearch(advcriteriaRows,filterCriteria);
    }

    public boolean isValidPickListVal(List<SearchCriteriaRow> advcriteriaRows){
        Schema.DescribeSObjectResult objSchema = Employee_Mileage__c.sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objSchema.fields.getmap();
        System.debug('--fieldMap--'+fieldMap);
        map<string,List<Boolean>> StringNameVsIsOkValListMap = new map<string,List<Boolean>>();
        for(SearchCriteriaRow SCR : advcriteriaRows){
            System.debug('----SCR----'+SCR);
            if(SCR.dataType == 'Picklist'){
                
                Schema.DescribeFieldResult fieldResult = fieldMap.get(SCR.name).getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                Boolean isAllSet = false; 
                System.debug('----SCR.value.split.size()----'+SCR.value.split(',').size());
                if(SCR.value.split(',').size() > 1){
                    
                    for(string st : SCR.value.split(',')){
                        Boolean isOneTimeEnteredInLoop = false;
                        for(Schema.PicklistEntry f : ple){
                            System.debug('----st----'+st);
                            System.debug('----f.getValue()----'+f.getValue());
                            if(st == f.getValue()){
                                System.debug('----st == f.getValue()----'+st);
                                isOneTimeEnteredInLoop = true;
                                continue;
                            }
                        }
                        System.debug('----isOneTimeEnteredInLoop----'+isOneTimeEnteredInLoop);
                        if(!isOneTimeEnteredInLoop){
                            return false;
                        }else{
                            continue;
                        }
                    }
                }else{
                    for(Schema.PicklistEntry f : ple){
                        if(SCR.value == f.getValue()){
                            System.debug('---SCR.value>>---'+SCR.value);
                            isAllSet = true;
                            continue;
                        }
                    }
                    if(!isAllSet){
                        return false;
                    }else{
                        continue;
                    }
                }   
            }
        }
        
        return true;
    }
    
    
    public string buildQueryforPRSearch(List<SearchCriteriaRow> advcriteriaRows,string filterCriteria) {
        String criteria ='';
        String filters = ''; 
        queryFieldNames = '';
        queryOperators = '';
        queryValues = '';
        String rowText = '';
        Integer i = 0;

        System.debug('=====> advcriteriaRows: ' + advcriteriaRows);
        for(SearchCriteriaRow row: advcriteriaRows) {
            system.debug('=====> row: ' + row);
            system.debug('=====> row.name ' + row.name);
            if(row.name == null) {
                continue;
            }
            
            rowText += ''+row; 
            if(!String.isBlank(criteria) && String.isBlank(filterCriteria))
                criteria+= ' AND ';

            filters = row.name+' ';
            if(queryFieldNames == '') 
                queryFieldNames += row.name;
            else
               queryFieldNames += ',' + row.name; 

            if(row.operator!=null) {
                if(row.operator.equals('includes') || row.operator.equals('excludes')) {
                    filters+= row.operator+' (';
                    List<String> rValues = row.value.removeEnd(',').split(',');
                    string filtercond = '';
                    for(String r : rValues) {
                        if(filtercond != '' && filtercond != null) {   
                            filtercond += ',';
                            filtercond += '\'' +r+ '\'';
                        } else {
                            filtercond += '\'' +r+ '\'';
                        }   
                    }
                    system.debug('---filtercond----'+filtercond);
                    filters += filtercond + ')';
                } else if(row.operator.equals('=') || row.operator.equals('!=') || row.operator.equals('>=') || row.operator.equals('<=')
                    || row.operator.equals('>') || row.operator.equals('<')) {
                    filters+= row.operator+' ';
                    if(row.dataType == 'Double') 
                    {
                        if(String.isBlank(row.value))
                        {
                            filters += 0;
                        }
                        else
                        {
                            filters+= row.value;
                        }   
                    } 
                    else 
                    {
                        if(String.isBlank(row.value)) 
                        {
                            filters+= null;
                        } 
                        else 
                        {       
                            if((row.dataType == 'Date')||(row.dataType == 'DateTime')) 
                            {
                                system.debug('-------------------------------->>>>>>>>>>>>>>>>>>>>>>>>> '+row.dataType);
                                date mydate = date.parse(row.value);
                                if(row.dataType == 'DateTime')
                                {
                                    
                                    String s =String.valueOf(mydate).replace('/','-');
                                    s=s+'T00:00:00Z';
                                    
                                    filters += s; 
                                }
                                else
                                {
                                    filters +=  String.valueOf(mydate).replace('/','-') ;
                                }
                                                              
                    
                            } 
                            else 
                            {
                                
                                filters += '\'' +row.value + '\'';                                  
                    
                            }   
                        }
                    }
                    
                } else if(row.operator.equals('*%'))
                    filters+= 'LIKE \''+row.value+'%\'';
                else if(row.operator.equals('%*'))
                    filters+= 'LIKE \'%'+row.value+'\'';
                else if(row.operator.equals('*%*'))
                    filters+= 'LIKE \'%'+row.value+'%\'';

                if(queryOperators == '') {
                    queryOperators += row.operator;
                    if(String.isBlank(row.value))
                        queryValues += null;
                    else
                        queryValues += row.value;

                } else {
                   queryOperators += ',' + row.operator; 
                   if(String.isBlank(row.value))
                        queryValues += ',' + null;
                    else
                        queryValues += ',' + row.value;  
                }

            } else 
                return 'null';
            
            system.debug('=====> filterCriteria-->' +filterCriteria);
            system.debug('=====> criteria-->' +criteria);
            system.debug('=====> filters-->' +filters);
            
            if(!String.isBlank(filterCriteria)) {
                if(String.isBlank(criteria)) {
                    criteria= '(' + filterCriteria.replace(String.valueOf(row.idx), filters ) + ')';        
                } else {
                    criteria = criteria.replace('(' + String.valueOf(row.idx) + ' ' ,'(' + filters + ' ');
                    criteria = criteria.replace(' ' + String.valueOf(row.idx)  + ' ', ' ' + filters +' ');
                    criteria = criteria.replace(' ' + String.valueOf(row.idx) + ')',' ' +filters + ')');
                }
            } else { 
                criteria+= ' '+ filters;
            }
        }
        system.debug('=====> criteria-->' +criteria);       
        return criteria;  
    }


    public static string Generatecontactquery(string QueryWhere, string AlphaFilter,string allPRfields,string SortField,string SortDirection,Employee_Mileage__c employeeMileage)
    {
        string soql = '';
          
        system.debug('----QueryWhere---'+QueryWhere);
        if(QueryWhere == 'null' || QueryWhere == null)
        {
            QueryWhere = '';
        }
        
        if (AlphaFilter == null || AlphaFilter.trim().length() == 0) {
            AlphaFilter = 'All';
        }
        system.debug('----allPRfields---'+allPRfields);
        system.debug('----AlphaFilter---'+AlphaFilter);
        system.debug('----employeeMileage---'+employeeMileage);
        
        soql = allPRfields + ' FROM Employee_Mileage__c where (id != null) ';

        system.debug('----soql---'+soql);
        if (AlphaFilter == 'Other')
        {
            QueryWhere = BuildWhere(QueryWhere, ' (' + String.escapeSingleQuotes(SortField) + ' < \'A\' OR ' + 
                                    String.escapeSingleQuotes(SortField) + ' > \'Z\') AND (NOT ' + 
                                    String.escapeSingleQuotes(SortField) + ' LIKE \'Z%\') ');
        }
        else if (AlphaFilter != 'All')
        {
            QueryWhere = BuildWhere(QueryWhere, ' (' + String.escapeSingleQuotes(SortField) + ' LIKE \'' + String.escapeSingleQuotes(AlphaFilter) + '%\')' );
        }
        
        system.debug('----QueryWhere---'+QueryWhere);
        if(QueryWhere != null && QueryWhere != '')
        {
            soql += ' AND ';
            soql += QueryWhere;
        }
        
        soql += ' ORDER BY ' + String.escapeSingleQuotes(SortField) + ' ' + String.escapeSingleQuotes(SortDirection) + ' LIMIT 9999 ';
        
        system.debug('QueryWhere==>' +QueryWhere);
        system.debug('soql==>' +soql);
        //getMainDataList();

        return soql;
    }

    public static string BuildWhere(String QW, String Cond)
    {
        System.Debug('QW  and Cond :- '+QW + ' ----- '+Cond);
        
        if (QW == '') {
            return  Cond;
        } else {
            
            return QW + ' AND ' + Cond;
        }
    }

    public void findFieldType() {
        String fieldType = getFieldType(Apexpages.currentpage().getparameters().get('fieldName'));
        System.debug('----fieldType-------------------------------'+fieldType);
        advcriteriaRows[Integer.valueOf(Apexpages.currentpage().getparameters().get('idx'))-1].fieldType = fieldType;
        advcriteriaRows[Integer.valueOf(Apexpages.currentpage().getparameters().get('idx'))-1].value = '';
        
        if(fieldType == 'Picklist') {
            advcriteriaRows[Integer.valueOf(Apexpages.currentpage().getparameters().get('idx'))-1].dataType = 'Picklist';
        } else if(fieldType == 'TextArea') {
            advcriteriaRows[Integer.valueOf(Apexpages.currentpage().getparameters().get('idx'))-1].dataType = 'String';
        } else if(fieldType == 'Currency' ) {
            advcriteriaRows[Integer.valueOf(Apexpages.currentpage().getparameters().get('idx'))-1].dataType = 'Integer';
        } else if(fieldType == 'DateTime') {
          //  advcriteriaRows[Integer.valueOf(Apexpages.currentpage().getparameters().get('idx'))-1].dataType = 'Date';
            advcriteriaRows[Integer.valueOf(Apexpages.currentpage().getparameters().get('idx'))-1].dataType = 'DateTime';
        } else {
            System.debug('----fieldType to set----'+fieldType);
            advcriteriaRows[Integer.valueOf(Apexpages.currentpage().getparameters().get('idx'))-1].dataType = fieldType;
        }
    }
    
    public String getFieldType(String fieldName) {
        if(String.isBlank(fieldName) || fieldName == 'Owner.Name') 
            return 'String';
        // Assume that "sObjectName" is populated elsewhere
       // if(String.isBlank(fieldName) || fieldName == 'EmployeeReimbursement__r.Month__c') return 'String';
       if(String.isBlank(fieldName)) return 'String';
       
        Schema.SObjectType t = Schema.getGlobalDescribe().get(cObj);
 
        Schema.DescribeSObjectResult r = t.getDescribe();
        Schema.DescribeFieldResult f = r.fields.getMap().get(fieldName).getDescribe();


        system.debug('+++++++++++++++++gettype'+f.getType());
        system.debug('+++++++++++++++++gettype'+f);

        if(f.getType() == Schema.DisplayType.String) {
            return 'String';
        } else if(f.getType() == Schema.DisplayType.Boolean) {
            return 'Boolean';
        } else if(f.getType() == Schema.DisplayType.Integer) {
            return 'Integer';
        } else if(f.getType() == Schema.DisplayType.Picklist) {
            return 'Picklist';
        } else if(f.getType() == Schema.DisplayType.Double) {
            return 'Double';
        } else if(f.getType() == Schema.DisplayType.Date) {
            return 'Date';
        } else if(f.getType() == Schema.DisplayType.DateTime) {
            return 'DateTime';
        } else if(f.getType() == Schema.DisplayType.Currency) {
            return 'Currency';
        } else if(f.getType() == Schema.DisplayType.TextArea) {
            return 'TextArea';
        } else if(f.getType() == Schema.DisplayType.MultiPicklist) {
            return 'MultiPicklist';
        }else if(f.getType() == Schema.DisplayType.EMAIL) {
            return 'EMAIL';
        } else if(f.getType() == Schema.DisplayType.REFERENCE) {
            return 'REFERENCE';
        } else if(f.getType() == Schema.DisplayType.PICKLIST) {
            return 'PICKLIST';
        } else 
            return '??';
    }

    public Map<string,List<SelectOption>> AddcontactsavailableFields() {
        Map<String, List<SelectOption>>  availableFields = new map<String, List<SelectOption>>();
        List<SelectOption> optionFields = new List<SelectOption> {
            new SelectOption('','-None-'),
            new SelectOption('Approved_Date__c','Approved Date'),
            new SelectOption('Contact_Email_Id__c','Contact Email'),
            /*new SelectOption('EmployeeReimbursement__c','Employee Reimbursement'),*/
            new SelectOption('Mileage__c','Mileage'),
            new SelectOption('Fuel_price__c','Fuel price'),
            new SelectOption('Maintenance_and_Tires__c','Maintenance and Tires'),
            new SelectOption('MPG__c','MPG'),
            new SelectOption('Trip_Date__c','Trip Date'),
            new SelectOption('Trip_Status__c','Trip Status'),
            new SelectOption('Createddate','Created Date'),
          //  new SelectOption('EmployeeReimbursement__r.Month__c','Month'),
           new SelectOption('Trip_Date_Month__c','Month'),
          
            new SelectOption('LastModifieddate','LastModified Date')
        };
        availableFields.put('Employee_Mileage__c', optionFields );
        return availableFields;
    }
    
    public PageReference ClearAll()
    {
        AlphaFilter = 'All';
        BuildQuery();
        return null;
    }
    
    public void SortToggle() {
        system.debug('---SortField---'+SortField);
        system.debug('---PRfieldWrapperList BEF---'+PRfieldWrapperList);
        SortDirection = 'asc';
        isToogleArrow = true;
        string clickedrowAPIname = Apexpages.currentpage().getparameters().get('clickedRowAPIname');
        system.debug('---clickedrowAPIname---'+clickedrowAPIname);
        for(PRfieldWrapper PRwrpr: PRfieldWrapperList){
            if(PRwrpr.fieldAPIName == clickedrowAPIname){
                PRwrpr.isToogleArrow = true;
                PRwrpr.fieldsortorder = PRwrpr.fieldsortorder.equals('asc') ? 'desc NULLS LAST' : 'asc';
                
                SortField = clickedrowAPIname;
                SortFieldSave = clickedrowAPIname;
                SortDirection = PRwrpr.fieldsortorder;
                AlphaFilter = 'All';
            }
            else
            {
                PRwrpr.isToogleArrow = false;
                //PRwrpr.fieldsortorder = 'asc';
            }
        }
        system.debug('---PRfieldWrapperList AFT---'+PRfieldWrapperList);
        
        // run the query again
        BuildQuery();
    }
    public List<SelectOption> getripstatus()
    {
       List<SelectOption> options = new List<SelectOption>();
       Schema.DescribeFieldResult fieldResult = Employee_Mileage__c.Trip_Status__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       options.add(new SelectOption('----', '--None--'));
       for( Schema.PicklistEntry f : ple)
       {
               options.add(new SelectOption(f.getLabel(), f.getValue()));
       }     
       return options;
    }
    public static Map<string, List<SelectOption>> availableOperators() {
        Map<string, List<SelectOption>> availableOperators = new Map<string, List<SelectOption>>();
                
        availableOperators.put('String',  
            new List<SelectOption>{
                new SelectOption('','-None-'),
                new SelectOption('=','equals'),
                new SelectOption('!=','not equals'),
                new SelectOption('*%','starts with'),
                new SelectOption('%*','ends with'),
                new SelectOption('*%*','contains')
            }
        );
        
        availableOperators.put('EMAIL',  
            new List<SelectOption>{
                new SelectOption('','-None-'),
                new SelectOption('=','equals'),
                new SelectOption('!=','not equals')
            }
        );

        availableOperators.put('PICKLIST',  
            new List<SelectOption>{
                new SelectOption('','-None-'),
                new SelectOption('=','equals'),
                new SelectOption('!=','not equals')
            }
        );

        availableOperators.put('REFERENCE',  
            new List<SelectOption>{
                new SelectOption('','-None-'),
                new SelectOption('=','equals'),
                new SelectOption('!=','not equals')
            }
        );
        
        availableOperators.put('zip',  
            new List<SelectOption>{
                new SelectOption('','-None-'),
                new SelectOption('=','equals'),
                new SelectOption('!=','not equals')
            }
        );

        availableOperators.put('Boolean', 
            new List<SelectOption>{
                new SelectOption('','-None-'),
                new SelectOption('=','equals'), 
                new SelectOption('!=','not equals')
            }
        );
        
        availableOperators.put('Integer', 
            new List<SelectOption>{
                new SelectOption('','-None-'),
                new SelectOption('=','equals'),
                new SelectOption('!=','not equals'),
                new SelectOption('>=','greater or equal'),
                new SelectOption('<=','less or equal'),
                new SelectOption('>','greater than'),
                new SelectOption('<','less than')
            } 
        );

        availableOperators.put('Date',  
            new List<SelectOption>{
                new SelectOption('','-None-'),
                new SelectOption('=','equals'),
                new SelectOption('!=','not equals'),
                new SelectOption('>=','greater than or equal to'),
                new SelectOption('<=','less than or equal to'),
                new SelectOption('>','greater than'),
                new SelectOption('<','less than')
            }
        );
        availableOperators.put('DateTime',  
            new List<SelectOption>{
                new SelectOption('','-None-'),
                new SelectOption('=','equals'),
                new SelectOption('!=','not equals'),
                new SelectOption('>=','greater than or equal to'),
                new SelectOption('<=','less than or equal to'),
                new SelectOption('>','greater than'),
                new SelectOption('<','less than')
            }
        );
        availableOperators.put('Double',  
            new List<SelectOption>{
                new SelectOption('','-None-'),
                new SelectOption('=','equals'),
                new SelectOption('!=','not equals'),
                new SelectOption('>=','greater than or equal to'),
                new SelectOption('<=','less than or equal to'),
                new SelectOption('>','greater than'),
                new SelectOption('<','less than')
            }
        );

        availableOperators.put('MultiPicklist',  
            new List<SelectOption>{
                new SelectOption('','-None-'),
                new SelectOption('=','equals'),
                new SelectOption('!=','not equals'),
                new SelectOption('includes','includes'),
                new SelectOption('excludes','excludes')
            }
        );
        
        availableOperators.put('Picklist',  
            new List<SelectOption>{
                new SelectOption('','-None-'),
                new SelectOption('=','equals'),
                new SelectOption('!=','not equals')
            }
        );
        
        return availableOperators;
    }

    public void addAdvCriteriaRow() {
    System.Debug('try debug :- '+advcriteriaRows);
        advcriteriaRows.add(new SearchCriteriaRow(advcriteriaRows.size()+1,null, null, null,null,'String'));
    }
    
    public void removeAdvCriteriaRow() {
        String rowNum = Apexpages.currentpage().getparameters().get('rowNum');
        advcriteriaRows.remove(Integer.valueOf(rowNum)-1);
        
        for(Integer i=0;i<advcriteriaRows.size();i++) {
            advcriteriaRows[i].idx = i+1;
        }
    }

    //Wrapper class for filter Search
    public class SearchCriteriaRow {
        public Integer idx        {get; set;}
        public string  name       {get; set;}
        public string  operator   {get; set;}
        public string  value      {get; set;}
        public string  fieldType  {get; set;}
        public string  dataType   {get; set;}
        
        public searchCriteriaRow(Integer idx, String name, String operator, String value, String fieldType, String dataType) {
            this.idx = idx;            
            this.name = name;
            this.operator = operator;
            this.value = value;
            this.fieldType = fieldType;
            this.dataType = dataType;        
        }
    }
}