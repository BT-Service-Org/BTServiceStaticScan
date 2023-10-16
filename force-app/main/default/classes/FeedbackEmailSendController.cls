public class FeedbackEmailSendController {
	@InvocableMethod
    public static void SendEmail(List<List<String>> sendEmailParams) {
     // Step 1: Create a new Email
     system.debug('TESt'+sendEmailParams);
      Messaging.SingleEmailMessage mail = 
      new Messaging.SingleEmailMessage();
      EmailTemplate et = [select id from EmailTemplate where developername='CSG_Project_Feedback_Email_Template_VF']; 
    
      // Step 2: Set list of people who should get the email
      List<String> sendTo = new List<String>();
        for(Integer i=0;i<sendEmailParams.size();i++){
            system.debug('1'+sendEmailParams[i]);
            for(Integer j=0;j<sendEmailParams[i].size();j++){
                system.debug('2'+sendEmailParams[i][j]);
                if(String.isNotBlank(sendEmailParams[i][j]) && sendEmailParams[i][j].startsWith('005'))
                    mail.setTargetObjectId(sendEmailParams[i][j]);
                else if(String.isNotBlank(sendEmailParams[i][j]) && sendEmailParams[i][j].contains('@')){
                    sendTo.add(sendEmailParams[i][j]);
                    mail.setToAddresses(sendTo);
                }
                else {
                     // for general skill feedback and performance related feedback, there will be no assignment record, so make sure we check for that before setting the whatId
                    if(String.isNotBlank(sendEmailParams[i][j])) {
                        mail.setWhatId(sendEmailParams[i][j]);
                    }
                }
                    
            }
        }
    
      // Step 3: Set who the email is sent from
      //mail.setReplyTo('sirdavid@bankofnigeria.com');
      //mail.setSenderDisplayName('Official Bank of Nigeria');
    
      

      // Step 4. Set email contents - you can use variables!
      mail.setTemplateId(et.Id);
        mail.setSaveAsActivity(false);
    mail.setUseSignature(false);
        // (Optional) Set list of people who should be CC'ed
      List<String> ccTo = new List<String>();
      ccTo.add(UserInfo.getUserEmail());
      mail.setCcAddresses(ccTo);
    
      
 Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
}
}