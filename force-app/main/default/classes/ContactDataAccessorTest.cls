@isTest
public with sharing class ContactDataAccessorTest {
    private static ContactDataAccessorMock contactDA;
    private static Set<Id> contactIds;

    private static void createData() {
        contactDA = new ContactDataAccessorMock();
        contactIds = new Set<Id>();

        User mockUser = new User(
            Id = MockSObjectBuilder.getMockId(User.getSObjectType()),
            Slack_User_Id__c = 'testid'
        );

        Contact mockContact = new Contact(
            Id = MockSObjectBuilder.getMockId(Contact.getSObjectType()),
            User_Record__c = mockUser.Id,
            FirstName = 'Test',
            LastName = 'User'
        );

        contactIds.add(mockContact.Id);
        contactDA.contacts.add(mockContact);
    }

    @isTest
    public static void getContactUserRecordsByContactIds_shouldReturnContacts() {
        createData();
        Test.startTest();
        List<Contact> c = contactDA.getContactUserRecordsByContactIds(contactIds);
        Test.stopTest();

        System.assertEquals(contactIds.iterator().next(), c[0].Id);
    }
}