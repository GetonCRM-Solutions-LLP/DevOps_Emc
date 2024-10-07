public class RG_Contact_Attachment {
    public static void contactAttachment (List<Attachment> attachNewList) {
        
        List<Contact> conUpdateList = new List<Contact>();
        Set<id> attachIdSet = new Set<id>();
        
        //Loop on attachments to get their parent Id
        for (Attachment attach:attachNewList) {
            attachIdSet.add(attach.parentId);
        }
        
        if (!attachIdSet.isEmpty()) { //Checking condition attachment id set is not empty
        //Query on contacts having attachment
        List<Contact> conList = [Select id, name, Jan__c, July__c, X15Jan__c  FROM Contact WHERE id IN:attachIdSet];
        if (conList.size() > 0) { //Checking condition contact list size should not be zero
            Date d1 = Date.today();
            Date Jan14 = Date.newInstance(d1.Year(), 1, 14);
            Date July15 = Date.newInstance(d1.year(), 7, 15);
            Date July14 = Date.newInstance(d1.Year(), 7, 14);
            Date Jan15 = Date.newInstance(d1.year(), 1, 15).addYears(1);
            System.debug('d1 -->' + d1);
            System.debug('Jan14 -->' + Jan14);
            System.debug('July15 -->' + July15);
            System.debug('July14 -->' + July14);
            System.debug('Jan15 -->' + Jan15);
            System.debug('d1 > Jan14 -->' + (d1 > Jan14));
            System.debug('d1 < July15 -->' + (d1 < July15));
            System.debug('d1 > July14 -->' + (d1 > July14));
            System.debug('d1 < Jan15 -->' + (d1 < Jan15));
            for (Contact con:conList) { // Loop to iterate contacts to update fields
                //if (Date.newInstance(d1.Year(), 1, 15).addDays(21) > con.X15Jan__c && d1 < Date.newInstance(d1.year(), 7, 15))
                if (d1 > Jan14 && d1 < July15) {
                    System.debug('jan if');
                    con.Jan__c = true;
                }
                if (d1 > July14 && d1 < Jan15) {
                    System.debug('july if');
                    con.July__c = true;
                }
                System.debug('Jan__c -->' + con.Jan__c);
                System.debug('July__c -->' + con.July__c);
                conUpdateList.add(con);
            }
        }
        }
        
        if (!conUpdateList.isEmpty()) // Checking whether list size is not zero
            update conUpdateList;
    }
}