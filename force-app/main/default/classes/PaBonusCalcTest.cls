////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Class Name       : PaBonusCalcTest
// Purpose/Overview : Test class for all the PA spot bonus calc functionality. Touches PABonusCalcUtils, 
//                    PABonusCalcControllerExt, PABonusCalcResult 
// Author           : Troy Hedges
//
// Change History   : Date Modified | Developer Name  | Method/Section Modified/Added  | Purpose of Changes
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@isTest
private class PaBonusCalcTest
{

	/*
  @isTest static void testSpotBonus()
  {
  	String tmpStr;

  	/////////////////////////
    // Create test records //
    /////////////////////////

    List<PA_Onboarding_Property__c> propList = new List<PA_Onboarding_Property__c>();
    PA_Onboarding_Property__c custSetting = new PA_Onboarding_Property__c();
    custSetting.Name = 'Template PA Onboarding Id';
    custSetting.Key__c = 'Template PA Onboarding Id';
    custSetting.Value__c = 'a1YQ0000000bLdP';     
    propList.add(custSetting);

    custSetting = new PA_Onboarding_Property__c();
    custSetting.Name = 'Bonus CTA Target';
    custSetting.Key__c = 'Bonus CTA Target';
    custSetting.Value__c = '25000';    
    propList.add(custSetting);

    custSetting = new PA_Onboarding_Property__c();
    custSetting.Name = 'Bonus Non CTA Target';
    custSetting.Key__c = 'Bonus Non CTA Target';
    custSetting.Value__c = '15000';    
    propList.add(custSetting);

    insert propList;

    Account acct = new Account();
    acct.Name = 'Test Account';
    insert acct;

    Contact testContact = new Contact();
    testContact.FirstName = 'John';
    testContact.LastName = 'Doe';
    insert testContact;

    PA_Onboarding__c paOnboard = new PA_Onboarding__c();
    paOnboard.Name = 'PA-John Doe';
    paOnboard.Contact__c = testContact.Id;
    paOnboard.Program_Start_Date__c = Date.valueOf('2013-05-13');
    insert paOnboard;

    Certification_Data__c cert = new Certification_Data__c();
    cert.Contact__c = testContact.Id;
    cert.Original_Certification_Date__c	 = Date.valueOf('2013-02-14');
    cert.Certification_Status__c = 'CURRENT';
    cert.Certification_Type_Name__c = 'Certified Technical Architect';
    cert.Mentor_Email__c = 'dbrasco@salesforce.com';
    insert cert;

    PA_Onboarding_Project__c proj = new PA_Onboarding_Project__c();
    proj.Type__c = 'Billable';
    proj.Consultant__c = testContact.Id;
    proj.Project_Start_Date__c = Date.valueOf('2013-02-01');
    proj.Project_End_date__c = Date.valueOf('2013-08-31');
    proj.Project_Name__c = 'Test Project 1';
    proj.PA_Onboarding__c = paOnboard.Id;
    proj.Project_Role__c = 'Program Architect';
    proj.PSE_Project_ID__c = 'xxx';
    insert proj;

    proj = new PA_Onboarding_Project__c();
    proj.Type__c = 'Billable';
    proj.Consultant__c = testContact.Id;
    proj.Project_Start_Date__c = Date.valueOf('2013-09-01');
    proj.Project_End_date__c = Date.valueOf('2014-05-31');
    proj.Project_Name__c = 'Test Project 2';
    proj.PA_Onboarding__c = paOnboard.Id;
    proj.Project_Role__c = 'Program Architect';
    proj.PSE_Project_ID__c = 'xxx';
    insert proj;

    proj = new PA_Onboarding_Project__c();
    proj.Type__c = 'Billable';
    proj.Consultant__c = testContact.Id;
    proj.Project_Start_Date__c = Date.valueOf('2014-06-01');
    proj.Project_End_date__c = Date.valueOf('2015-05-31');
    proj.Project_Name__c = 'Test Project 3';
    proj.PA_Onboarding__c = paOnboard.Id;
    proj.Project_Role__c = 'Program Architect';
    proj.PSE_Project_ID__c = 'xxx';
    insert proj;

    PA_Customer_Survey__c custSurvey = new PA_Customer_Survey__c();
    //custSurvey.Name = 'Test Survey';
    custSurvey.Contact__c = testContact.Id;
    custSurvey.Account_Id__c = acct.Id;
    custSurvey.Account_Name__c = 'Test Account Name';
    custSurvey.Org62_Survey_Id__c = 'xyz123';
    custSurvey.Overall_Score__c = 9.00;
    custSurvey.Survey_Completed_Date__c = Date.valueOf('2013-10-10');
    insert custSurvey;

    custSurvey = new PA_Customer_Survey__c();
    //custSurvey.Name = 'Test Survey';
    custSurvey.Contact__c = testContact.Id;
    custSurvey.Account_Id__c = acct.Id;
    custSurvey.Account_Name__c = 'Test Account Name';
    custSurvey.Org62_Survey_Id__c = 'xyz1234';
    custSurvey.Overall_Score__c = 8.00;
    custSurvey.Survey_Completed_Date__c = Date.valueOf('2014-02-15');
    insert custSurvey;

    custSurvey = new PA_Customer_Survey__c();
    //custSurvey.Name = 'Test Survey';
    custSurvey.Contact__c = testContact.Id;
    custSurvey.Account_Id__c = acct.Id;
    custSurvey.Account_Name__c = 'Test Account Name';
    custSurvey.Org62_Survey_Id__c = 'xyz12345';
    custSurvey.Overall_Score__c = 10.00;
    custSurvey.Survey_Completed_Date__c = Date.valueOf('2014-05-21');
    insert custSurvey;

    custSurvey = new PA_Customer_Survey__c();
    //custSurvey.Name = 'Test Survey';
    custSurvey.Contact__c = testContact.Id;
    custSurvey.Account_Id__c = acct.Id;
    custSurvey.Account_Name__c = 'Test Account Name';
    custSurvey.Org62_Survey_Id__c = 'xyz123456';
    custSurvey.Overall_Score__c = 10.00;
    custSurvey.Survey_Completed_Date__c = Date.valueOf('2014-07-28');
    insert custSurvey;

    Spot_Bonus__c spotBonus = new Spot_Bonus__c();
    spotBonus.Contact__c = testContact.Id;
    spotBonus.Payment_2_Period_End_Date__c = Date.valueOf('2013-07-01');
    insert spotBonus;            


    /////////////////////
    // Test controller //
    /////////////////////
    ApexPages.StandardController sc = new ApexPages.StandardController(testContact);
    PABonusCalcControllerExt scExt = new PABonusCalcControllerExt(sc);

    // this is just needed to test some back code for calendar popup issue
    scExt.setTestContact(testContact);
    scExt.getTestContact();

    //////////////////////////////////
    // calculate bonus and validate //
    //////////////////////////////////
    //PageReference pageRef = scExt.calcBonusEligibility(Date.valueOf('2014-07-31'));
    scExt.setBonusCalcDate(Date.valueOf('2014-07-31'));
    tmpStr = scExt.getBonusCalcDate();
    System.assertEquals(tmpStr, '7/31/2014');
    PageReference pageRef = scExt.calcBonusForTargetDate();

    
    List<PA_Onboarding_Project__c> projList = scExt.bonusResults.getProjList();
    System.assertEquals(projList.size(), 3);

    List<PA_Customer_Survey__c> surveyList = scExt.bonusResults.getSurveyList();
    System.assertEquals(surveyList.size(), 4);

    System.assertEquals(scExt.bonusResults.bonusEligible, true);

    tmpStr = scExt.bonusResults.getFormattedStartDate();
    System.assertEquals(tmpStr, '8/1/2013');
    tmpStr = scExt.bonusResults.getFormattedEndDate();
    System.assertEquals(tmpStr, '7/31/2014');
    tmpStr = scExt.bonusResults.getFormattedLastBonusDate();
    System.assertEquals(tmpStr, '7/1/2013');
    tmpStr = scExt.bonusResults.getFormattedCTAAcquireDate();
    System.assertEquals(tmpStr, '2/14/2013');
    tmpStr = scExt.bonusResults.getFormattedBonusAmount();
    System.assertEquals(tmpStr, '25,000');    // 0 value
    tmpStr = scExt.bonusResults.getFormattedUtilPercentage();
    System.assertEquals(tmpStr, '99');
    tmpStr = scExt.bonusResults.getFormattedCTAPercentage();
    System.assertEquals(tmpStr, '100');
    tmpStr = scExt.bonusResults.getFormattedAvgCSAT();
    System.assertEquals(tmpStr, '9.25');

    //////////////////////////////
    // check spot bonus records //
    //////////////////////////////
    pageRef = scExt.createSpotBonusRecs();
    System.assert(pageRef != null);

    Spot_Bonus__c sb = [SELECT Payment_1_Payout_Date__c, Payment_1_Period_Start_Date__c, Payment_1_Period_End_Date__c, 
                               Payment_1_Expected_Amount__c, Payment_2_Payout_Date__c, Payment_2_Period_Start_Date__c, 
                               Payment_2_Period_End_Date__c, Payment_2_Expected_Amount__c
                          FROM Spot_Bonus__c
                         WHERE Contact__c = :testContact.Id and Payment_1_Status__c = 'Draft'];

    


    System.assertEquals(sb.Payment_1_Expected_Amount__c, 12500.0);
    System.assertEquals(sb.Payment_1_Payout_Date__c, Date.valueOf('2014-08-01'));

    System.assertEquals(sb.Payment_2_Expected_Amount__c, 12500.0);
    System.assertEquals(sb.Payment_2_Payout_Date__c, Date.valueOf('2015-02-01'));


  }
  */

}