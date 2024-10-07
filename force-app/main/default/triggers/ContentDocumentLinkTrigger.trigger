trigger ContentDocumentLinkTrigger on ContentDocumentLink (After insert) {
    TriggerConfig__c triggerSettings = TriggerConfig__c.getInstance('Defaulttrigger');
    if(triggerSettings.ContentDocumentLinkTrigger__c) {
        if (Trigger.isInsert && Trigger.isAfter) {
            List<ContentDistribution> contentDistributionList = new List<ContentDistribution>();
            List<ContentDocumentLink> updatedContentDocumentLinks = new List<ContentDocumentLink>();

            Set<Id> cdlSet = new set<Id>();
            for (ContentDocumentLink cdl : Trigger.new) {
                cdlSet.add(cdl.Id);
            }
            for (ContentDocumentLink cdl : [Select id,ContentDocument.LatestPublishedVersion.Title,Visibility,ContentDocument.LatestPublishedVersionId from ContentDocumentLink Where Id IN:cdlSet]) {
                System.debug('xx1'+cdl.ContentDocument.LatestPublishedVersion.Title);
                if (cdl.ContentDocument.LatestPublishedVersion.Title == 'Driver Agreement.pdf') {
                    // Update visibility to 'AllUsers'
                    cdl.Visibility = 'AllUsers';
                    updatedContentDocumentLinks.add(cdl);

                    // Create ContentDistribution record
                    ContentDistribution contentDistribution = new ContentDistribution(
                        Name = 'Driver Agreement.pdf',
                        ContentVersionId = cdl.ContentDocument.LatestPublishedVersionId,
                        PreferencesAllowViewInBrowser = true
                    );
                    contentDistributionList.add(contentDistribution);
                }
            }

            // Perform DML operations outside of the loop for better performance
            update updatedContentDocumentLinks;
            insert contentDistributionList;
        }
    }
    
}