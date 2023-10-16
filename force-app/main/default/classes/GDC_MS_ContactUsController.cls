/**
 * Class Name: GDC_MS_ContactUsController
 * Descrption: Will send an email to the GDC Common Mailbox. This class will run in Guest User Context. Send Email Permission must be enabled on Guest User's Profile
 */
public with sharing class GDC_MS_ContactUsController {
	
	@AuraEnabled(cacheable = false)
	public static string sendEmailMessage(String firstName, String emailAddress, String description,String queryType) {

		List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
		Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
		
		OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :System.Label.gdcms_contactus_email];
		
		if ( owea.size() > 0 ) {
			mail.setOrgWideEmailAddressId(owea.get(0).Id);
		}
		//Email Body
		string body = '';
		body = '<p>Hi All,\n\n</p>';
		body += '<p>Name : ' + firstName + '\n</p>';
		body += '<p>Email : ' + emailAddress + '\n</p>' ;
		body += '<p>Query Type : ' + queryType + '\n</p>' ;
		body += '<p>Description : ' + description + '<br></p>' ;
		body += '<p>Thank you<br>Team GDC</p>';

		mail.setToAddresses(new List<String> {System.Label.gdcms_contactus_email});
		mail.setSubject('GDC MicroSite - Contact Us form submission - '+ firstName);
		mail.setHTMLBody(body);
		mails.add(mail);

		Messaging.sendEmail(mails);

		return 'Email Sent';
	}
}