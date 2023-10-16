@isTest
public class FeedbackEmailSendControllerTest {
    
    public static testmethod void testvalidate(){
    
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'test1', Email='test222@gamil.com',FirstName = 'Test', 
            EmailEncodingKey='UTF-8', LastName='Testlast', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test111@gmail.cominvalids');
            UserContactUtil.doNotExecuteTrigger = true;
            insert u;

        // ID candidate;
        // ID recipient;

        Contact con=new Contact();
        con.lastname='Testing';
        con.email='test@test.com';
        insert con;

        Account newAcc = new Account();
        newAcc.name='test';
        insert newAcc;
        
        
        
        List<String> params = new List<String>();
        params.add(con.email);
        params.add(u.id);
        params.add(con.id);

        List<List<String>> listToInsert = new List<List<String>>();

        listToInsert.add(params);
        test.startTest();
        FeedbackEmailSendController.sendEmail(listToInsert);
        test.stopTest();
    }

    // public static User createUser() {
    //     String hostname = '@sfservices.com.onboarding';
    //     Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
    //     Blob b = Crypto.GenerateAESKey(128);
    //     String h = EncodingUtil.ConvertTohex(b);
    //     String uid = h.SubString(0,8);
    //     User testUser = new User(
    //         Alias = uid,
    //         Email= uid + hostname, 
    //         EmailEncodingKey='UTF-8',
    //         LastName='Testing',
    //         LanguageLocaleKey='en_US', 
    //         LocaleSidKey='en_US',
    //         ProfileId = p.Id, 
    //         TimeZoneSidKey='America/New_York',
    //         UserName= uid + hostname
    //     );
    //     insert testUser;
    //     return testUser;
    // }


    // public static testmethod void testvalidate(){

    //     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    //     List<List<String>> listToInsert = new List<List<String>>();
        

        
    //     Account newAcc1 = new Account();
    //     newAcc1.name='test1';
    //     insert newAcc1;
    //     params.add(newAcc1.id);

        

    //     // Contact con2=new Contact();
    //     // con2.lastname='Testing2';
    //     // con2.email='test2@test.com';
    //     // insert con2;
    //     // params2.add(con2.email);

    //     // Account newAcc3 = new Account();
    //     // newAcc3.name='test3';
    //     // insert newAcc3;
    //     // params2.add(newAcc3.id);

    //     // Account newAcc4 = new Account();
    //     // newAcc4.name='test4';
    //     // insert newAcc4;
    //     // params2.add(newAcc4.ID);
    //     // listToInsert.add(params2);
        
        
        
    //     //insert listToInsert;

        
        
        
        
        
    //     test.starttest();
    //    // mail.setTargetObjectId(recipient);
    //     mail.setPlainTextBody('');
    //     FeedbackEmailSendController.SendEmail(listToInsert );
    //     test.stoptest();
    // }
}