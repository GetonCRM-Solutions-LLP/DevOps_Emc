/**
 * @Author:      Sanjay Halpati (GetOnCRM Solutions LLP)
 * @Description: Controller class for CustomReportConfihuration page
 *               - Create query for custom report
 */
public with sharing class CustomReportConfigurationController {

    public String reportName { get; set; }
    public String selectedAccountId { get; set; }
    public String selectedRecordCategory { get; set; }
    public String selectedRecordType { get; set; }
    public String selectedFilter { get; set; }
    public SelectOption[] selectedContacts { get; set; }
    public SelectOption[] allContacts { get; set; }
    public Integer step { get; set; }
    public Integer hireachylevel { get; set; }
    public String selectedField { get; set; }
    public String selectedField_1 { get; set; }
    public String selectedField_2 { get; set; }
    public String selectedField_3 { get; set; }
    public String fieldToAdd { get; set; }
    public SelectOption[] selectedFields { get; set; }
    public Set<String> selectedFieldsSet { get; set; }
    public String fieldtoRemove { get; set; }
    public String reportHeader { get; set; }
    public List<Schema.SObjectType> sObjects;
    public Set<String> dateTimefields { get; set; } 
    public Set<String> numberfields { get; set; } 
    public Boolean summarize { get; set; }
    //********* Variable for step 3 ***** */
    public List<SearchCriteriaRow> advcriteriaRows {get;set;} 
    public Map<string, List<SelectOption>> availableOperators{get;set;}
    public String filterCriteria { get; set; }
    public String finalQuery { get; set; }

    //********Step 4 variables */
    public Boolean showModal { get; set; }
    public List<fieldsWrapper> fieldsWrapperList { get; set; }
    public String selectedDateTimefields { get; set; }
    public String selectedDatefields { get; set; }
    public String selectedTimefields { get; set; }
    public String selectType { get; set; }
    public Boolean ShowAllFields { get; set; }

    public List<SummarizeFieldWrapper> aggregatefields { get; set; }


    public String sObjectNameApi {
        get {
            return GetPrimaryObjectName().getDescribe().getName();
        }
        set;
    }

    /**
     * Constructor
     */
    public CustomReportConfigurationController() {
        selectedContacts = new List<SelectOption>();
        allContacts = new List<SelectOption>();
        selectedFields = new List<SelectOption>();
        selectedFieldsSet = new Set<String>();
        advcriteriaRows = new List<SearchCriteriaRow>();
        selectedFilter = 'driver';
        fieldtoRemove = '';
        step = 1;
        hireachylevel = 0;
        selectedField = '';
        selectedField_1 = '';
        selectedField_2 = '';
        selectedField_3 = '';
        reportHeader = '';
        selectedRecordType = '';

        filterCriteria = '';
        availableOperators = new Map<string, List<SelectOption>>();
        availableOperators = availableOperators();
        addAdvCriteriaRow();
        finalQuery = '';
        showModal = false;
        fieldsWrapperList = new List<fieldsWrapper>();
        dateTimefields = new Set<String>();
        numberfields = new Set<String>(); 
        selectedDateTimefields = '';
        selectedDatefields = '';
        selectedTimefields = '';
        selectType = '';
        ShowAllFields = false;
        summarize = False;
        aggregatefields = new List<SummarizeFieldWrapper>();
    }

    /**
     * Method to save custom report record.
     */
    public Pagereference SaveCustomReport() {
        try {
            BuildQuery();
            Custom_Report__c customReport = new Custom_Report__c(
                Name = reportName,
                Account__c = selectedAccountId,
                Report_Category__c = selectedRecordCategory,
                Report_Type__c = selectedRecordType,
                Use_Driver_List__c = false,
                Use_Manager_List__c = false,
                Report_Soql__c = finalQuery.replaceAll('<b>', '').replaceAll('</b>', '').replaceAll(', ', ',').toLowerCase(),
                Numeric_Fields__c = !summarize ? String.join(new List<String>(numberfields),',').toLowerCase() : null,
                Date_Fields__c = !summarize ? String.ValueOf(selectedDatefields).toLowerCase() : null,
                Date_Time_Fields__c = !summarize ? String.ValueOf(selectedDateTimefields).toLowerCase() : null,
                Date_Time_To_Time__c = !summarize ? String.ValueOf(selectedTimefields).toLowerCase() : null,
                Report_Header__c = reportHeader
            );
            if(selectedFilter == 'driver')
                customReport.Use_Driver_List__c = true;
            else
                customReport.Use_Manager_List__c = true;

            insert customReport;

            List<Report_Accessibility__c> reportAccessibilities = new List<Report_Accessibility__c>();
            for(SelectOption so : selectedContacts) {
                reportAccessibilities.add( 
                    new Report_Accessibility__c(
                        Name = so.getLabel() + '_' + customReport.Id,
                        Custom_Report__c = customReport.Id,
                        User__c = so.getValue()
                    )
                );
            }

            if(!reportAccessibilities.isEmpty()) {
                insert reportAccessibilities;
            }
            return new Pagereference('/' + customReport.Id);

        } catch (Exception e ) {
            System.debug('Error: ' + e.getMessage());
        }
        
        return null;
        
    }

    /**
     * Get triplog Accounts 
     */
    public List<SelectOption> GetAccountOptions() {
        List<selectOption> options = new List<selectOption>();
        options.add( new SelectOption('none','-- Select --'));

        for(Account acc : [SELECT Id, Name FROM Account WHERE isUsingTriplog__c = true ORDER BY Name Limit 999]) {
            options.add(new selectOption( acc.Id, acc.Name));
        }
        return options;   
    }

    /**
     * Get triplog contacts for selected Account 
     */
    public void LoadContacts() {
        selectedContacts = new List<SelectOption>();
        allContacts = new List<SelectOption>();
        
        if(selectedAccountId != 'none') {
            List<Contact> contacts = [SELECT Name, Id FROM Contact WHERE AccountId =: selectedAccountId];  
            List<User> users = [SELECT Id, Contact.Id, Contact.Name 
                                    FROM User 
                                    WHERE Contact.AccountID =: selectedAccountId
                                        AND Contact.Role__c IN ('Admin', 'Driver/Admin')
                                        AND IsActive = true];
        
            for ( User u : users ) {
                allContacts.add(new SelectOption(u.Id, u.Contact.Name ));
            }
        }
        
    }

    /**
     * Get report categories 
     */
    public List<selectOption> GetReportCategories() {   
        List<selectoption> options = new List<selectoption>();
        options.add(new SelectOption('none','-- Select --'));
        Schema.DescribeFieldResult fieldResult = Custom_Report__c.Report_Category__c.getDescribe();
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry v : values) {
            options.add(new selectOption(v.getValue(), v.getLabel()));
        }
        return options;
    }

    /**
     * Get Report types
     */
    public List<selectOption> GetReportTypes() {   
        List<selectoption> options=new List<selectoption>();
        options.add(new SelectOption('none','-- Select --'));
        Schema.DescribeFieldResult fieldResult = Custom_Report__c.Report_Type__c.getDescribe();
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry v : values) {
            options.add(new selectOption(v.getValue(), v.getLabel()));
        }
        return options;
    }

    /**
     * Go to Next Step
     */
    public void NextStep() {
        if(( Step == 3 && !summarize) || (step == 4 && summarize))
            BuildQuery();

        if(step == 1) {
            aggregatefields = new List<SummarizeFieldWrapper>();
            for(Schema.sObjectField sfield : GetPrimaryObjectName().getDescribe().fields.getMap().values()) {
                schema.describefieldresult dfield = sfield.getDescribe();
                if(dfield.getType() == Schema.DisplayType.Integer || 
                dfield.getType() == Schema.DisplayType.Double || 
                dfield.getType() == Schema.DisplayType.Currency ) {
                    aggregatefields.add(new SummarizeFieldWrapper(dfield.getLabel(), dfield.getName()));
                }    
            }
        }
        step ++;
    }

    /**
     * Go to previous step
     */
    public void PreviousStep() {
        step --;
    }

    /**
     * Get Master object fields
     */
    public List<SelectOption> GetObjectFields() {
        
        Schema.SObjectType objectName;
        if(sObjects == null)
            sObjects = new List<Schema.SObjectType>();
        if(selectedRecordType != null && selectedRecordType != 'none') {

            objectName = GetPrimaryObjectName();
            if(!sObjects.isEmpty())
                sObjects.add(objectName);
            
            return GetFieldOptions(objectName, 0);
        }
        return new List<selectOption>();
    }

    /**
     * Get First level object fields
     */
    public List<SelectOption> GetObjectFields_1() {
        if(selectedField.contains(' >')) {
            String fieldName = selectedField.replace(' >', '');
            Schema.SObjectType objectName = GetReferenceObjectName(0, fieldName);
            //SObjectType objectName = Schema.getGlobalDescribe().get(fieldName);
            return GetFieldOptions(objectName, 1);
        } 
        return new List<selectOption>();
    }

    /**
     * Get Second level object fields
     */
    public List<SelectOption> GetObjectFields_2() {
        if(selectedField_1.contains(' >')) {
            String fieldName = selectedField_1.replace(' >', '');
            Schema.SObjectType objectName = GetReferenceObjectName(1, fieldName);
            //SObjectType objectName = Schema.getGlobalDescribe().get(fieldName);
            return GetFieldOptions(objectName, 2);
        } 
        return new List<selectOption>();
    }

    /**
     * Get Third level object fields
     */
    public List<SelectOption> GetObjectFields_3() {
        if(selectedField_2.contains(' >')) {
            String fieldName = selectedField_2.replace(' >', '');
            Schema.SObjectType objectName = GetReferenceObjectName(2, fieldName);
            //SObjectType objectName = Schema.getGlobalDescribe().get(fieldName);
            return GetFieldOptions(objectName, 3);
        } 
        return new List<selectOption>();
    }

    /**
     * Get Primary object
     */
    private Schema.SObjectType GetPrimaryObjectName() {
        return selectedRecordType.contains('Reimbursements') ? 
                            Employee_Reimbursement__c.sObjectType :
                            ( 
                                selectedRecordType.contains('Mileages') ?
                                Employee_Mileage__c.sObjectType :
                                Contact.sObjectType
                            );
    }

    /**
     * Build query String for choosen field & where Clauses
     */
    public String GetbuildQueryString() {
        
        String primaryObject = GetPrimaryObjectName().getDescribe().getName();
        List<String> aggFields =  new List<String>();
        for(SummarizeFieldWrapper s :  aggregatefields) {
            if(s.doSum)
                aggFields.add('SUM(' + s.fName + ')');
            if(s.doAvG)
                aggFields.add('AVG(' + s.fName + ')');
        }
        
        if(!summarize) {
            if(selectedFieldsSet.isEmpty()){
                return '<b>SELECT</b> Id <b>FROM</b> ' + primaryObject;
            } else {
                return '<b>SELECT</b> ' + String.join(new List<String> (selectedFieldsSet) , ', ') + ' <b>FROM</b> ' + primaryObject;
            }
        } else {
            if(selectedFieldsSet.isEmpty()){
                return '';
            } else {
                return '<b>SELECT</b> ' + String.join(new List<String> (selectedFieldsSet) , ', ') + ', ' + String.join(new List<String> (aggFields) , ', ') +  ' <b>FROM</b> ' + primaryObject + ' <b>GROUP BY</b> ' + String.join(new List<String> (selectedFieldsSet) , ', ');
            }
        }
    }

    /**
     * On Field change Method
     */
    public void OnChangeField() {
        String selectedFieldName = hireachylevel == 0 ? 
                                    selectedField :
                                    ( hireachylevel == 1 ? 
                                      selectedField_1 :
                                      ( hireachylevel == 2 ? 
                                        selectedField_2 : '' )
                                    ) ;
        sObjects.clear();
        Schema.SObjectType objectName = GetPrimaryObjectName();
        sObjects.add(objectName);
        for(Integer i = 0; i < hireachylevel; i++) {
            String f = i == 0 ? selectedField.replace(' >', '') : 
                     ( i == 1 ? selectedField_1.replace(' >', '') : 
                     selectedField_2.replace(' >', ''));
            sObjects.add(GetReferenceObjectName(i , f));
        }
        if(selectedFieldName.contains(' >')) {
            hireachylevel ++;
        } else {
            fieldToAdd = BuildFieldAPIName(selectedField);
            if(hireachylevel >= 1)
                fieldToAdd += BuildFieldAPIName(selectedField_1);
            if(hireachylevel >= 2)
                fieldToAdd += BuildFieldAPIName(selectedField_2);
            if(hireachylevel >= 3)
                fieldToAdd += BuildFieldAPIName(selectedField_3);

            if(selectedFieldsSet.add(fieldToAdd)){
                selectedFields.add(new SelectOption(fieldToAdd , fieldToAdd));

                String dataType = GetFieldSType(fieldToAdd);
                if(dataType == 'Date' || dataType == 'DateTime')
                    dateTimefields.add(fieldToAdd);
                else if(dataType == 'Integer' || dataType == 'Double' || dataType == 'Currency')
                    numberfields.add(fieldToAdd);
            }
                
        }
    }

    /**
     * Get Field dataType
     */
    public String GetFieldSType(String fldName) {
        Schema.SObjectType objectName = GetPrimaryObjectName();
        if(fldName.contains('.')) {
            String[] fields = fldName.split('\\.');
            if(fields.size() == 4 ) {
                objectName = objectName.getDescribe().fields.getMap().get(FormatFieldName(fields[0])).getDescribe().getReferenceTo()[0]
                                                .getDescribe().fields.getMap().get( FormatFieldName(fields[1]))
                                                .getDescribe().getReferenceTo()[0];

                objectName = objectName.getDescribe().fields.getMap().get( FormatFieldName(fields[2]))
                            .getDescribe().getReferenceTo()[0];
            } else if(fields.size() == 3){
                objectName = objectName.getDescribe().fields.getMap().get(FormatFieldName(fields[0])).getDescribe().getReferenceTo()[0]
                                                .getDescribe().fields.getMap().get( FormatFieldName(fields[1]))
                                                .getDescribe().getReferenceTo()[0];
            } else {
                objectName = objectName.getDescribe().fields.getMap().get(FormatFieldName(fields[0])).getDescribe().getReferenceTo()[0];
            }

            fldName = fields[fields.size() - 1];
        } 

        return getFieldType(fldName, objectName);
    }

    /**
     * Build relational field API
     */
    public String BuildFieldAPIName(String fName) {
        
        if(fName.contains(' >') ) {
            fName = fName.replace(' >', '').replace('__c', '__r');
            fName = ( fName.endsWith('Id') ? fName.removeEnd('Id') : fName ) + '.';
        }
        return fName; 
    }

    /**
     * Get Reference Object name of lookup field 
     */
    private Schema.SObjectType GetReferenceObjectName(Integer level, String fieldName) {
        String objApi = sObjects[level].getDescribe().getName();
        Schema.DescribeFieldResult f = Schema.getGlobalDescribe().get(objApi).getDescribe().fields.getMap().get(fieldName).getDescribe();
        return f.getReferenceTo()[0];
    }

    /**
     * Remove selected field
     */
    public void RemoveSelectField() {
        selectedFields.clear();
        Set<String> fieldsToremoveSet = new Set<String>{ fieldtoRemove};
        selectedFieldsSet.removeAll(fieldsToremoveSet);
        for(String f : selectedFieldsSet) {
            selectedFields.add(new SelectOption(f , f));
        }
    }

    /**
     * Get fields of selected lookup field object
     */
    public List<SelectOption> GetFieldOptions(Schema.SObjectType objectName, Integer level ) {
        List<selectOption> fieldsoptions = new List<selectOption>();
        for(Schema.sObjectField sfield : objectName.getDescribe().fields.getMap().values()) {
            schema.describefieldresult dfield = sfield.getDescribe();

            fieldsoptions.add( new selectOption(sfield.getDescribe().getName(), sfield.getDescribe().getLabel()));

            if(dfield.getType() == Schema.DisplayType.Reference && level < 3) {
                fieldsoptions.add( new selectOption(sfield.getDescribe().getName() + ' >', sfield.getDescribe().getLabel() + ' >'));
            }    
        }  

        if(!fieldsoptions.isEmpty())
            fieldsoptions.sort();

        return fieldsoptions;
    }

    /**
     * Load available Fields based on Selection
     */
    public void LoadFieldSelection() {
        fieldsWrapperList.clear();
        if(selectType == 'DateTime') {
            for(String fName : dateTimefields) {
                if(!selectedDatefields.contains(fName) && !selectedTimefields.contains(fName)) {
                    if(selectedDateTimefields.contains(fName) ) {
                        fieldsWrapperList.add(new fieldsWrapper(true, fName));
                    } else {
                        fieldsWrapperList.add(new fieldsWrapper(false, fName));
                    }
                }
                
            }
        } else if(selectType == 'Date'){
            for(String fName : dateTimefields) {
                if(!selectedDateTimefields.contains(fName) && !selectedTimefields.contains(fName)) {
                    if(selectedDatefields.contains(fName)) {
                        fieldsWrapperList.add(new fieldsWrapper(true, fName));
                    } else {
                        fieldsWrapperList.add(new fieldsWrapper(false, fName));
                    }
                }
            }
        } else {
            for(String fName : dateTimefields) {
                if(!selectedDateTimefields.contains(fName) && !selectedDatefields.contains(fName)) {
                    if(selectedTimefields.contains(fName)) {
                        fieldsWrapperList.add(new fieldsWrapper(true, fName));
                    } else {
                        fieldsWrapperList.add(new fieldsWrapper(false, fName));
                    }
                }
            }
        }
    }

    /**
     * Save Selected Fields based on Selection
     */
    public void SaveFieldSelection() {
        if(selectType == 'DateTime') {
            selectedDateTimefields = '';
            for(fieldsWrapper fw : fieldsWrapperList) {
                if(fw.selected) {
                    selectedDateTimefields += fw.fieldName + ',';
                }
            }
            selectedDateTimefields = selectedDateTimefields.removeEnd(',');
        } else if(selectType == 'Date'){
            selectedDatefields = '';
            for(fieldsWrapper fw : fieldsWrapperList) {
                if(fw.selected) {
                    selectedDatefields += fw.fieldName + ',';
                }
            }
            selectedDatefields = selectedDatefields.removeEnd(',');
        } else {
            selectedTimefields = '';
            for(fieldsWrapper fw : fieldsWrapperList) {
                if(fw.selected) {
                    selectedTimefields += fw.fieldName + ',';
                }
            }
            selectedTimefields = selectedTimefields.removeEnd(',');
        }
    }

    public class fieldsWrapper {
        public Boolean selected { get; set; }
        public String fieldName { get; set; }
        public fieldsWrapper(Boolean isSelected, String fname) {
            this.selected = isSelected;
            this.fieldName = fname;
        }
    }

    public class SummarizeFieldWrapper {
        public String fLabel { get; set; }
        public String fName { get; set; }
        public Boolean doSum { get; set; }
        public Boolean doAvG { get; set; }
        public SummarizeFieldWrapper(String fL, String fName) {
            this.fLabel = fl;
            this.fName = fName;
            this.doSum = false;
            this.doAvG = false;
        }
    }

    
    // ************************** Code for WHERE Filters START************************************//
    public class SearchCriteriaRow {
        public Integer idx        {get;set;}
        public string  name       {get;set;}
        public string  operator   {get;set;}
        public string  value      {get;set;}
        public string  fieldType  {get;set;}
        public string  dataType   {get;set;}
        public string  valueLabel {get;set;}
        
        public searchCriteriaRow(integer idx, string name, string operator, string value, string fieldType, string dataType) {
        
            this.idx = idx;            
            this.name = name;
            this.operator = operator;
            this.value = value;
            this.fieldType = fieldType;
            this.dataType = dataType; 
            this.valueLabel = '';       
        }
    }

    /**
     * Available Operators
     */
    public static Map<string, List<SelectOption>> availableOperators(){
        Map<string, List<SelectOption>> availableOperators = new Map<string, List<SelectOption>>();
                
        availableOperators.put('String',  
            new List<SelectOption>{
                new SelectOption('','-- Select --'),
                new SelectOption('=','equals'),
                new SelectOption('!=','not equals'),
                new SelectOption('*%','starts with'),
                new SelectOption('%*','ends with'),
                new SelectOption('*%*','contains')
            }
        );
        
        availableOperators.put('zip',  
            new List<SelectOption>{
                new SelectOption('','-- Select --'),
                new SelectOption('=','equals'),
                new SelectOption('!=','not equals')
            }
        );
        
        availableOperators.put('Boolean', 
            new List<SelectOption>{
                new SelectOption('','-- Select --'),
                new SelectOption('=','equals'), 
                new SelectOption('!=','not equals')
            }
        );
        
        availableOperators.put('Integer', 
            new List<SelectOption>{
                new SelectOption('','-- Select --'),
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
                new SelectOption('','-- Select --'),
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
                new SelectOption('','-- Select --'),
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
                new SelectOption('','-- Select --'),
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
                new SelectOption('','-- Select --'),
                new SelectOption('=','equals'),
                new SelectOption('!=','not equals'),
                new SelectOption('includes','includes'),
                new SelectOption('excludes','excludes')
            }
        );
        
        availableOperators.put('Picklist',  
            new List<SelectOption>{
                new SelectOption('','-- Select --'),
                new SelectOption('=','equals'),
                new SelectOption('!=','not equals')
            }
        );

        availableOperators.put('Reference',  
            new List<SelectOption>{
                new SelectOption('','-- Select --'),
                new SelectOption('=','equals'),
                new SelectOption('!=','not equals')
            }
        );
        
        return availableOperators;
    }

    /**
     * build Query
     */
    public string buildQueryforSearch() {
        return buildQueryforSearchall(advcriteriaRows,filterCriteria);
    }

    /**
     * convert To Roman Number
     */
    public static string convertToRoman(String filterCriteria) {
        for(integer i = 10; i < 70 ; i++) {
            filterCriteria = filterCriteria.replaceFirst('' + i, RomanConverter(i));
        }
        return filterCriteria;
    }

    /**
     * build Query for SearchCriteriaRow
     */
    public static string buildQueryforSearchall(List<SearchCriteriaRow> advcriteriaRows,string filterCriteria) {
        string criteria ='';
        string filters = ''; 
        string queryFieldNames = '';
        string queryOperators = '';
        string queryValues = '';
        string rowText = '';
        Integer i = 0;

        filterCriteria = convertToRoman(filterCriteria);
        
        for(SearchCriteriaRow row: advcriteriaRows) {    

            if(row.name==null){ continue; }
            
            // rowText += ''+row; 
            if(!String.isBlank(criteria) && String.isBlank(filterCriteria))
                   criteria+= ' AND ';
            
           filters = row.name + ' ';

            if(row.operator!=null) {
                if(row.operator.equals('includes') || row.operator.equals('excludes')) {
                    filters += row.operator+' (';
                    List<String> rValues = row.value.removeEnd(',').split(',');
                    string filtercond = '';
                    for(String r : rValues) {
                        if(filtercond != '' && filtercond != null) {
                            filtercond += ',';
                            filtercond += '\'' +String.escapeSingleQuotes(r)+ '\''; 
                        } else {
                            filtercond += '\'' +String.escapeSingleQuotes(r)+ '\'';
                        }
                    }
                    filters += filtercond + ')';
                }
                else if(row.operator.equals('=') || row.operator.equals('!=') || row.operator.equals('>=') || row.operator.equals('<=') || row.operator.equals('>') || row.operator.equals('<')) {
                    
                    filters+= row.operator+' ';
                    if(row.dataType != 'Double' && row.dataType != 'Integer' && row.dataType != 'Currency') {
                        if(String.isBlank(row.value)) {
                            filters+= null;
                        } else {        
                            if(row.dataType != 'Date' && row.dataType != 'DateTime' && row.dataType != 'Boolean') {
                                filters += '\'' +String.escapeSingleQuotes(row.value)+ '\'';
                            } else if(row.dataType == 'DateTime' ) {   
                                filters += row.value + 'T00:00:00.000Z';
                            } else {
                                filters += row.value;
                            }
                        }
                    } 
                    else {
                        if(row.value.isNumeric()){
                            if(String.isBlank(row.value)){ filters += 0;
                            }else{ filters+= row.value; }
                        }
                        else{ 
                            row.value = '';
                            if(String.isBlank(row.value)){
                                 filters += 0;
                            }
                            else{ 
                                filters+= row.value; 
                            }
                        }
                        
                    }
                    
                }else if(row.operator.equals('*%')) filters+= 'LIKE \''+String.escapeSingleQuotes(row.value)+'%\'';
                else if(row.operator.equals('%*')) filters+= 'LIKE \'%'+String.escapeSingleQuotes(row.value)+'\'';
                else if(row.operator.equals('*%*')) filters+= 'LIKE \'%'+String.escapeSingleQuotes(row.value)+'%\'';


                if(queryOperators == '') {
                    queryOperators += row.operator;
                    if(String.isBlank(row.value)) queryValues += null;
                    else queryValues += row.value;

                } else {
                   queryOperators += ',' + row.operator; 
                    if(String.isBlank(row.value)) queryValues += ',' + null;
                    else queryValues += ',' + row.value;  
                }

            }
            else 
                return 'null';
            
            if(!String.isBlank(filterCriteria)) {
                
                
                if(String.isBlank(criteria))
                { 
                    criteria= '(' + filterCriteria.replace(String.valueOf(row.idx), filters ) + ')';
                }
                else 
                {
                    String backslash = '\\';
                    criteria = criteria.replace('(' + ( row.idx > 9 ? RomanConverter(row.idx) : string.valueof(row.idx )) + ' ' ,'(' + filters + ' ');
                    criteria = criteria.replace(' ' + ( row.idx > 9 ? RomanConverter(row.idx) : string.valueof(row.idx )) + ' ', ' ' + filters +' ');
                    criteria = criteria.replace(' ' + ( row.idx > 9 ? RomanConverter(row.idx) : string.valueof(row.idx )) + ')',' ' +filters + ')');
                }
            }
            else
            { 
                criteria+= ' '+ filters; 
            }
            
        }
        return criteria;  
    }

    /**
     * build final Query 
     */
    public void BuildQuery() {
        try {          
        
            String QueryWhere = buildQueryforSearch();
           
            if(!summarize) {
                finalQuery = GetbuildQueryString();
            } else {
                String primaryObject = GetPrimaryObjectName().getDescribe().getName();
                List<String> aggFields =  new List<String>();
                for(SummarizeFieldWrapper s :  aggregatefields) {
                    if(s.doSum)
                        aggFields.add('SUM(' + s.fName + ')');
                    if(s.doAvG)
                        aggFields.add('AVG(' + s.fName + ')');
                }

                finalQuery = '<b>SELECT</b> ' + String.join(new List<String> (selectedFieldsSet) , ', ') + ', ' + String.join(new List<String> (aggFields) , ', ') +  ' <b>FROM</b> ' + primaryObject;
            }
            if(QueryWhere != 'null')
                finalQuery += ' <b>WHERE</b> ' + QueryWhere;
            if(summarize)
                finalQuery += ' <b>GROUP BY</b> ' + String.join(new List<String> (selectedFieldsSet) , ', ');
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getmessage()));
        }
    }

    /**
     * convert To Roman Number
     */
    public static String RomanConverter(Integer input) {
        String s = '';
        while (input >= 40) {
            s += 'XL';
            input -= 40;
        }
        while (input >= 10) {
            s += 'X';
            input -= 10;
        }
        while (input >= 9) {
            s += 'IX';
            input -= 9;
        }
        while (input >= 5) {
            s += 'V';
            input -= 5;
        }
        while (input >= 4) {
            s += 'IV';
            input -= 4;
        }
        while (input >= 1) {
            s += 'I';
            input -= 1;
        }    
        return s;

    }

    /**
     * Get Fields for selected primary object
     */
    public List<SelectOption> GetavailableFields() {
        List<SelectOption> fieldsoptions = new List<SelectOption>();
        List<SelectOption> relationalfieldsoptions = new List<SelectOption>();
        fieldsoptions.add(new SelectOption('none','-- Select --'));
        Schema.SObjectType objectName = GetPrimaryObjectName();
        for(Schema.sObjectField sfield : objectName.getDescribe().fields.getMap().values()) {
            schema.describefieldresult dfield = sfield.getDescribe();
            fieldsoptions.add( new selectOption(sfield.getDescribe().getName(), sfield.getDescribe().getLabel()));

            if(dfield.getType() == Schema.DisplayType.Reference && 
                ( dfield.getReferenceTo()[0].getDescribe().getName() == 'Contact' 
                    || dfield.getReferenceTo()[0].getDescribe().getName() == 'Account' 
                    || dfield.getReferenceTo()[0].getDescribe().getName() == 'Employee_Reimbursement__c'
                )
            ) {
                relationalfieldsoptions.add( new selectOption(sfield.getDescribe().getName() + 'Fields', sfield.getDescribe().getLabel() + ' Fields', true));
                HireachicalFields(dfield.getReferenceTo()[0], relationalfieldsoptions, sfield.getDescribe().getName());
            }    
        } 

        fieldsoptions.addAll(relationalfieldsoptions);
        
        return fieldsoptions;
    }

    /**
     * Get Hireachical Fields for selected object
     */
    private void HireachicalFields(Schema.SObjectType objectName, List<SelectOption> fieldsoptions, String parentLookup) {
        if(parentLookup.contains('__c')) {
            parentLookup = parentLookup.replace('__c', '__r');
        } else {
            parentLookup = parentLookup.removeEnd('Id');
        }
        for(Schema.sObjectField sfield : objectName.getDescribe().fields.getMap().values()) {
            schema.describefieldresult dfield = sfield.getDescribe();
            fieldsoptions.add( new selectOption(parentLookup + '.' + sfield.getDescribe().getName(), sfield.getDescribe().getLabel()));   
        } 

        if(objectName.getDescribe().getName() == 'Contact') {
            fieldsoptions.add( new selectOption( '', 'Account Fields', true));
            HireachicalFields(Account.sObjectType, fieldsoptions, parentLookup + '.AccountId');
        } else if(objectName.getDescribe().getName() == 'Employee_Reimbursement__c'){
            fieldsoptions.add( new selectOption( '', 'Contact Fields', true));
            HireachicalFields(Contact.sObjectType, fieldsoptions, parentLookup + '.Contact_Id__c');
        }
    }

    /**
     * Find Field dataType 
     */
    public void findFieldType() {
        String fldName = Apexpages.currentpage().getparameters().get('fieldName');

        System.debug(fldName);
        if( fldName != null )
        {
            string fieldType = GetFieldSType(fldName);
            advcriteriaRows[Integer.valueOf(Apexpages.currentpage().getparameters().get('idx'))-1].fieldType = fieldType;
            
            advcriteriaRows[Integer.valueOf(Apexpages.currentpage().getparameters().get('idx'))-1].value = '';
            if(fieldType == 'Picklist'){ advcriteriaRows[Integer.valueOf(Apexpages.currentpage().getparameters().get('idx'))-1].dataType = 'Picklist';
            }else if(fieldType == 'TextArea'){ advcriteriaRows[Integer.valueOf(Apexpages.currentpage().getparameters().get('idx'))-1].dataType = 'String';
            }else if(fieldType == 'Currency' ){ advcriteriaRows[Integer.valueOf(Apexpages.currentpage().getparameters().get('idx'))-1].dataType = 'Double';
            }else if(fieldType == 'DateTime'){ advcriteriaRows[Integer.valueOf(Apexpages.currentpage().getparameters().get('idx'))-1].dataType = 'DateTime';
            }else{ advcriteriaRows[Integer.valueOf(Apexpages.currentpage().getparameters().get('idx'))-1].dataType = fieldType;
            }
        }
        
    }

    /**
     * Format Field Name
     */
    public String FormatFieldName(String fname) {
        if(fname.contains('__r')) {
           return fname.replace('__r', '__c'); 
        }
        return fname + 'Id';
    }

    /**
     * Get Field dataType 
     */
    public String getFieldType(String fieldName, Schema.SObjectType objectName) {
        
        Schema.DescribeSObjectResult r = objectName.getDescribe();
        Schema.DescribeFieldResult f = r.fields.getMap().get(fieldName).getDescribe();
        
        if (f.getType() == Schema.DisplayType.String){ return 'String';
        }else if(f.getType() == Schema.DisplayType.Boolean){ return 'Boolean';
        }else if(f.getType() == Schema.DisplayType.Integer){ return 'Integer';
        }else if(f.getType() == Schema.DisplayType.Picklist){ return 'Picklist';
        }else if(f.getType() == Schema.DisplayType.Double){ return 'Double';
        }else if(f.getType() == Schema.DisplayType.Date){ return 'Date';
        }else if(f.getType() == Schema.DisplayType.DateTime){ return 'DateTime';
        }else if(f.getType() == Schema.DisplayType.Currency){ return 'Currency';
        }else if(f.getType() == Schema.DisplayType.TextArea){ return 'TextArea';
        }else if(f.getType() == Schema.DisplayType.MultiPicklist){ return 'MultiPicklist'; 
        }else if(f.getType() == Schema.DisplayType.REFERENCE){ return 'Reference'; }
        else
            return '??';

    }

    /**
     * Add Filter row 
     */
    public void addAdvCriteriaRow() {
        advcriteriaRows.add(new SearchCriteriaRow(advcriteriaRows.size() + 1, null, null, null, null, 'String'));
    }
    
    /**
     * remove Filter row 
     */
    public void removeAdvCriteriaRow() {
        String rowNum = Apexpages.currentpage().getparameters().get('rowNum');
        if(rowNum != null)
            advcriteriaRows.remove(Integer.valueOf(rowNum)-1);
        
        for(Integer i=0; i<advcriteriaRows.size(); i++) {
            advcriteriaRows[i].idx = i+1;
        }
    }

    // ************************** Code for WHERE Filters END************************************//

}