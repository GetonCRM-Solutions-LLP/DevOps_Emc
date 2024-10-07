trigger SetFileVisibility on ContentDocumentLink (before insert) {
    for (ContentDocumentLink cdl : Trigger.new) {
        cdl.visibility = 'AllUsers';
    }
}