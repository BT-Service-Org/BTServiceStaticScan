@isTest
public with sharing class ContactDataAccessorMock implements ContactDAI {
    public List<Contact> contacts = new List<Contact>();

    public List<Contact> getContactUserRecordsByContactIds(Set<Id> contactIds) {
        return contacts;
    }
}