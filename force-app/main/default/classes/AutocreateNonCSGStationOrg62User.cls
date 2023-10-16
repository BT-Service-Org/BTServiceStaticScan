/**
 *  @description Handles Org62 external objet query for JIT Handler AutocreateNonCSGStationUsersExternal
 *  @author      Anshul Gupta
 *  @date        09/07/2020
 */
public without sharing class AutocreateNonCSGStationOrg62User{

    @TestVisible private static List<Org62_User__x> mockedRequests = new List<Org62_User__x>();
    /**
     *  @description Find a single request by email
     *  @author      Anshul Gupta
     *  @date        09/07/2020
     */
     
    public static Org62_User__x findBySSOEmail(string ssoEmail) {
        
        String selectString = 'select Alias__c,CommunityNickname__c,LanguageLocaleKey__c,LocaleSidKey__c,TimeZoneSidKey__c,'+
                        'FirstName__c, LastName__c,Title__c,Username__c,Email__c,EmailEncodingKey__c,ExternalId,' +
                        'Street__c, City__c, State__c, PostalCode__c, Country__c,Phone__c,Business_Unit_c__c,Cost_Center_c__c,' +
                        'Department__c,IsActive__c,Mgmt_Chain_Level_02_c__c,Mgmt_Chain_Level_03_c__c,Mgmt_Chain_Level_04_c__c,Mgmt_Chain_Level_05_c__c, ' +
                        'Mgmt_Chain_Level_06_c__c,Mgmt_Chain_Level_07_c__c, Mgmt_Chain_Level_08_c__c, Mgmt_Chain_Level_09_c__c,' +
                        'FederationIdentifier__c,' +
                        'ManagerId__c,BU_c__c, Hire_Date_c__c,JobCode_c__c,JobFamily_c__c,JobGrade_c__c,JobProfile_c__c ' +
                        'from Org62_User__x WHERE Email__c =:'+ 'ssoEmail';
        
           List<Org62_User__x> userXList =  Database.query(selectString);
        
        if(Test.isRunningTest()) {
            return (mockedRequests.size() > 0) ? mockedRequests[0] : null;
        }
        
         

        return (userXList.size() > 0) ? userXList[0] : null;
    }
}