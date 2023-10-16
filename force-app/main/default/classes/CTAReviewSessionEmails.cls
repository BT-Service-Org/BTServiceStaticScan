public class CTAReviewSessionEmails {

public static void SendEmail(List<Document> scenariodoc, 
                                  String CoachEmail, String SecCoachEmail, String CandidateEmail,
                                 String SubAdd,String Attempttime,String PresentTime){
     
 
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      mail.setUseSignature(false);

      if (SecCoachEmail != null && CandidateEmail == null)
      {
           mail.setToAddresses(new String[] {CoachEmail});
          mail.setCCAddresses(new String[] {SecCoachEmail}); //only for sending solution
          System.debug ('If 1');
      }
      else if (SecCoachEmail == null && CandidateEmail == null)
      {
           mail.setToAddresses(new String[] {CoachEmail});   //only for sending solution
          
          System.debug ('If 2');
      }
      else if (SecCoachEmail == null && CandidateEmail != null)
      {
           mail.setToAddresses(new String[] {CandidateEmail});  
           mail.setCCAddresses(new String[] {CoachEmail});
          
          System.debug ('If 3');
      }
       else    
      {
          mail.setToAddresses(new String[] {CandidateEmail}); 
          String[] CCEmail = new String[] {CoachEmail,SecCoachEmail};
          mail.setCCAddresses(CCEmail); 
        //  mail.setCCAddresses(SecCoachEmail);
          System.debug ('If 4');
      }   
             
          Messaging.EmailFileAttachment attachcase = new Messaging.EmailFileAttachment();
          attachcase.setContentType(scenariodoc[0].contentType);
          attachcase.setFileName(scenariodoc[0].developerName+'.'+scenariodoc[0].type);
          attachcase.setInline(false);
          attachcase.Body = scenariodoc[0].Body;
          mail.setSubject('CTA Mock ' +SubAdd + ':' + scenariodoc[0].name);
          mail.setHtmlBody('<html><body>Attached is the CTA Mock '+SubAdd + 
          		'. <br><br><b> Attempt Time: ' + Attempttime + '</b> <br><b> Presentation Time: ' + PresentTime + 
          		'</b> <br><b> Q/A Time: ' + PresentTime + ' </body></html>');
          mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachcase });                             
                                     
          // Send the email
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  }
    
}