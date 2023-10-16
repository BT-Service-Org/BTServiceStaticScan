@isTest
public with sharing class TagTriggerHandlerTest {
    @TestSetup
    static void createData(){
        Product_Custom__c pc = new Product_Custom__c();
        pc.Name= 'Test';
        insert pc;
        
    }
    @isTest
    static void preventProductinTagtest(){
        try{
            Tag__c tc = new Tag__c();
            tc.Name='Test';
            insert tc;
        }
        catch(Exception e){
            System.assertEquals(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), true);
        }
        
    }
}