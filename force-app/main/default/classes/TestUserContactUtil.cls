@IsTest
private class TestUserContactUtil {


	static testMethod void testNewUser(){
		
		Profile p = [select id from Profile where name = 'System Administrator'];
		List<User> luser = new List<User>();
		
		for(Integer x=0; x<100; x++){
			User u = new User();
			u.Alias = 'newUser';
			u.Email = 'newuser@testorg.com';
			u.EmailEncodingKey = 'UTF-8';
			u.LastName = 'Testing';
			u.Username = 'newuser' + x + '@testorgsf.com';
			u.ProfileId = p.Id;
			u.LanguageLocaleKey = 'en_US';
			u.LocaleSidKey = 'en_US';
			u.TimeZoneSidKey = 'America/Los_Angeles';
			
			luser.add(u);
		}
		
		Test.startTest();
		
			insert luser;
			
		Test.stopTest();
		
	}
	
	
	static testMethod void testUpdateUser(){
		
		Profile p = [select id from Profile where name = 'System Administrator'];
		List<User> luser = new List<User>();
		
		for(Integer x=0; x<100; x++){
			User u = new User();
			u.Alias = 'newUser';
			u.Email = 'newuser@testorg.com';
			u.EmailEncodingKey = 'UTF-8';
			u.LastName = 'Testing';
			u.Username = 'newuser' + x + '@testorgsf.com';
			u.ProfileId = p.Id;
			u.LanguageLocaleKey = 'en_US';
			u.LocaleSidKey = 'en_US';
			u.TimeZoneSidKey = 'America/Los_Angeles';
			
			luser.add(u);
		}
		
		Test.startTest();
		
			insert luser;
			
		Test.stopTest();
		
		for(User user : luser){
			user.FirstName = 'Tester';
		}
		update luser;
	}
	
	
	static testMethod void testNewContact(){
		
	}
	
	
	static testMethod void testUpdateContact(){
		
		List<Contact> lcontact = new List<Contact>();
		
		for(Integer x=0; x<100; x++){
			Contact c = new Contact();
			c.FirstName = 'Test';
			c.LastName = 'User';
			c.Email = 'test.user@testorg.com';
			c.Title__c = 'test title';
			c.Role__c = 'test role';
			c.Organization__c = 'test organization';
			
			lcontact.add(c);
		}
		insert lcontact;
		
		
		for(Contact updateContact : lcontact){
			updateContact.FirstName = 'Tester';
		}
		update lcontact;
		
		//---------------
		Profile p = [select id from Profile where name = 'System Administrator'];
		List<User> luser = new List<User>();
		
		for(Integer y=0; y<100; y++){
			User u = new User();
			u.Alias = 'newUser';
			u.Email = 'newuser@testorg.com';
			u.EmailEncodingKey = 'UTF-8';
			u.LastName = 'Testing';
			u.Username = 'newuser' + y + '@testorgsf.com';
			u.ProfileId = p.Id;
			u.LanguageLocaleKey = 'en_US';
			u.LocaleSidKey = 'en_US';
			u.TimeZoneSidKey = 'America/Los_Angeles';
			
			luser.add(u);
		}
		
		Test.startTest();
			insert luser;
		Test.stopTest();
		
		List<String> uId = new List<String>();
		for(User user : luser){
			uId.add(user.Id);
		}
		
		List<Contact> lcreatedContacts = new List<Contact>();
		lcreatedContacts = [select id,FirstName from Contact where UserId__c in :uId];
		
		for(Contact contact : lcreatedContacts){
			contact.FirstName = 'Tester';
		}
		update lcreatedContacts;
		
	}

}


















/**
* 
* Name: User to Contact Sync
*
* About User to Contact Sync:
*   	Upon a new User being created in the application an associated 
*		Contact record will be created. From that point forward specific 
*		fields updated on either record will update the other respective record.
*
* Author: Nathan Crosby (ncrosby@salesforce.com)
*
* Description:
*   Test class for:
*		UserContactUtil
*		ContacttoUserTrigger
*		UsertoContactTrigger
*
* Dependancies:
*		1 - custom field UserId Text(18)(Unique Case Sensitive) must be configured on the Contact object
*
* History:
* 	07/08/2009 - Original Creation
*
*/