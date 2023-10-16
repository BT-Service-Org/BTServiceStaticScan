public with sharing class ShareButtonController {

    @AuraEnabled(cacheable=true)
    public static String getUrlSubstring(String Url) {
        String urlSubstring = Url.substringAfter('/thestation/s/');
        return urlSubstring;
    }

    @AuraEnabled(cacheable=true)
    public static String getLexOriginUrl() {
        return URL.getSalesforceBaseURL().toExternalForm();
    }

    @AuraEnabled 
    public static void sendMailMethod(String mMail ,String mSubject ,String mbody){
        User u = [SELECT Email, Name FROM User WHERE Id=:UserInfo.getUserId()];

        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();     
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        sendTo.add(mMail);

        mail.setToAddresses(sendTo);
        mail.setReplyTo(u.Email); 
        mail.setSenderDisplayName(u.Name); 
        mail.setSubject(mSubject);
        mail.setHtmlBody(mbody);
        
        mails.add(mail);
        Messaging.sendEmail(mails);
    }
    
}