@isTest
public class RasicComponentHandlerTest {
    @testSetup static void setup() {
        //Method data insertion
        Method__c mt=new Method__c(Name='TestRasicMethod');
        insert mt;
        
        //Activity Data insertion
        Activity__c act=new Activity__c(Name='TestRasicAct',Related_Method__c=mt.Id);
        insert act;
        
        //Role data insertion
        Role__c role=new Role__c(Name='TestRasicRole');
        insert role;
        
        //Activity Onwership data insertion
        Activity_Ownership__c aown=new Activity_Ownership__c(Activity__c=act.Id,Role__c=role.Id,Method__c=mt.Id,
                                                             Responsible__c='Yes',Accountable__c='No');
        insert aown;
        
        //Method By Activity insertion
        Method_By_Activity__c mtByAct=new Method_By_Activity__c(Activity__c=act.Id,Method__c=mt.Id);
        insert mtByAct;
        
    }
    
    @isTest static void testRasicData() {
        List<Method__c> methodList=[SELECT Id FROM Method__c Where Name='TestRasicMethod'];
        List<Activity__c> actList=[SELECT Id FROM Activity__c Where Name='TestRasicAct'];
        List<Method_By_Activity__c> methodByActivityLst = [SELECT Id FROM Method_By_Activity__c 
                                                            WHERE Method__r.Name='TestRasicMethod' 
                                                            AND Activity__r.Name='TestRasicAct'];
        List<Activity_Ownership__c> actOwnerLst = [SELECT Id FROM Activity_Ownership__c LIMIT 1];
        Test.startTest();
        System.assertEquals(RasicComponentHandler.getActivityByMethod(methodList[0].Id).size(),1);
        System.assertEquals(RasicComponentHandler.getMethodByActivity(actList[0].Id,methodList[0].Id).size(),1);
        System.assertEquals(RasicComponentHandler.getActivity(actList[0].Id).size(),1);
        System.assertEquals(RasicComponentHandler.getActivityList(methodList[0].Id).size(),1);
        System.assertEquals(RasicComponentHandler.activityOwnerList(methodList[0].Id).size(),1);
        System.assertEquals(RasicComponentHandler.getActivityRecords(new List<Id>{actList[0].Id}).size(),1);
        Test.stopTest();
        
    }
    
}