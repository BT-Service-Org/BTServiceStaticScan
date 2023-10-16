public with sharing class ContactDataAccessor implements ContactDAI {
    public List<Contact> getContactUserRecordsByContactIds(Set<Id> contactIds) {
        return [
            SELECT
                Id,
                User_Record__c
            FROM Contact
            WHERE Id IN :contactIds
            WITH SECURITY_ENFORCED
        ];
    }
}