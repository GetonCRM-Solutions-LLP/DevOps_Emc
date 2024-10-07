public with sharing class LookupFinderController {

    public String searchString { get; set; }
    public String fType { get; set; }
    public List<OptionWrapper> records { get; set; }
    public String sObj;
    public String field;
    public Integer maxlimit;

    public LookupFinderController() {
        this.searchString = Apexpages.currentPage().getParameters().get('searchString');
        this.sObj = Apexpages.currentpage().getParameters().get('sObj');
        this.field = Apexpages.currentpage().getParameters().get('field');
        this.fType = Apexpages.currentpage().getParameters().get('fType');
        string lookupField = field;

        if(fType == 'Reference') {

            Schema.SObjectType objectName = Schema.getGlobalDescribe().get(sObj);
            if(field.contains('.')) {
                String[] fields = field.split('\\.');
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
                lookupField = fields[fields.size() - 1];
            }
            
            for(Schema.SObjectType s : objectName.getDescribe().fields
                                            .getMap().get(lookupField).getDescribe()
                                            .getReferenceTo()) {
                if(s.getDescribe().getName() != 'Group') {
                    this.sObj = s.getDescribe().getName();
                    break;
                }
            }
        }
                        
        this.records = new List<OptionWrapper>();
        this.maxlimit = 10;
        this.performSearch();
    }

    public void LoadMore() {
        maxlimit += 10;
        if(maxlimit < 1000) {
            performSearch();
        }
    }
    public String FormatFieldName(String fname) {
        if(fname.contains('__r')) {
           return fname.replace('__r', '__c'); 
        }
        return fname + 'Id';
    }

    public void performSearch(){  
        if(fType == 'Reference') {
            String query = 'SELECT Id, Name FROM ' + this.sObj;
            if(this.searchString != null && this.searchString != ''){  
                query += ' WHERE (Name LIKE \'%' + String.escapeSingleQuotes(this.searchString) + '%\')';  
            }       
            query += ' ORDER BY Name ASC';  
            query += ' LIMIT ' + this.maxlimit;
            this.records.clear();
            for (SObject s :  database.query(query) ) {
                OptionWrapper op = new OptionWrapper();
                op.rLabel = (String)s.get('Name') ;
                op.rValue = (String)s.get('Id');
                this.records.add (op);
            }
        } else {
            string lookupField = field.contains('.') ? 
                                 field.split('\\.')[1]:
                                 field;
            sObj = field.contains('.') ? 
                    field.split('\\.')[0]:
                    sObj;
            this.records.clear();
            Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(sObj).getDescribe().fields.getMap()
                                                    .get(lookupField).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

            for( Schema.PicklistEntry f : ple){
                OptionWrapper op = new OptionWrapper();
                op.rLabel = f.getValue();
                op.rValue = f.getValue();
                this.records.add(op);
            }
        }
         
   } 

   public class OptionWrapper {
       public String rValue { get; set; }
       public String rLabel { get; set; }
   }

}