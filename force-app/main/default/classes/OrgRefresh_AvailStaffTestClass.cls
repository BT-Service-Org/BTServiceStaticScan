@isTest
public class OrgRefresh_AvailStaffTestClass {
    
    @istest static void testAvailStaffBeanGetField() {
        Test.startTest();
        OrgRefresh_org62AvailStaffBean newbean = new OrgRefresh_org62AvailStaffBean();
        newbean.id = '12345';
        newbean.email = 'abc@isi.com';

        String idres = newbean.getField('Id');
        String emailres = newbean.getField('Email');

        test.stopTest();
        System.assertequals(idres, '12345');
        System.assertEquals(emailres, 'abc@isi.com');

    }

    @istest static void testmakejson() {
        
    }
    
    @isTest static void testfetchandupdatedata() {
        //list, token, appname, refresh
    }
}