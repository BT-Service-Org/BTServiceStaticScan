@istest
public class Talent_Management_Test {

    private Static testmethod void Test_IC_Talent_Management_Batch_Launcher() {
        Id UsrId = UserInfo.getUserId();
        Id U2;
        Id U3;
        Id U4;
        Id U5;
        Id U6;
        List<User> Lst = [SELECT Id,
                    Mgmt_Chain_Hierarchy_Level_02__c, 
                    Mgmt_Chain_Hierarchy_Level_03__c,
                    Mgmt_Chain_Hierarchy_Level_04__c,
                    Mgmt_Chain_Hierarchy_Level_05__c,
                    Mgmt_Chain_Hierarchy_Level_06__c, 
                    Mgmt_Chain_Hierarchy_Level_07__c, 
                    Mgmt_Chain_Hierarchy_Level_08__c, 
                    Mgmt_Chain_Hierarchy_Level_09__c, 
                    Mgmt_Chain_Hierarchy_Level_10__c, 
                    Mgmt_Chain_Hierarchy_Level_11__c, 
                    Mgmt_Chain_Hierarchy_Level_12__c 
                    FROM user 
                    WHERE isactive = true AND Mgmt_Chain_Hierarchy_Level_06__c != Null LIMIT 10];
        for( User Usr : Lst ) {
            U2 = Usr.Mgmt_Chain_Hierarchy_Level_02__c;
            U3 = Usr.Mgmt_Chain_Hierarchy_Level_03__c;
            U4 = Usr.Mgmt_Chain_Hierarchy_Level_04__c;
            U5 = Usr.Mgmt_Chain_Hierarchy_Level_05__c;
            U6 = Usr.Mgmt_Chain_Hierarchy_Level_06__c;
            Usr.Mgmt_Chain_Hierarchy_Level_02__c = UsrId;
            Usr.Mgmt_Chain_Hierarchy_Level_03__c = UsrId;
            Usr.Mgmt_Chain_Hierarchy_Level_04__c = UsrId;
            Usr.Mgmt_Chain_Hierarchy_Level_05__c = UsrId;
            Usr.Mgmt_Chain_Hierarchy_Level_06__c = UsrId;
            Usr.Mgmt_Chain_Hierarchy_Level_07__c = UsrId;
            Usr.Mgmt_Chain_Hierarchy_Level_08__c = UsrId;
            Usr.Mgmt_Chain_Hierarchy_Level_09__c = UsrId;
            Usr.Mgmt_Chain_Hierarchy_Level_10__c = UsrId;
            Usr.Mgmt_Chain_Hierarchy_Level_11__c = UsrId;
            Usr.Mgmt_Chain_Hierarchy_Level_12__c = UsrId;
        }
        User Usr = [SELECT Id,
                    Mgmt_Chain_Hierarchy_Level_02__c, 
                    Mgmt_Chain_Hierarchy_Level_03__c,
                    Mgmt_Chain_Hierarchy_Level_04__c,
                    Mgmt_Chain_Hierarchy_Level_05__c,
                    Mgmt_Chain_Hierarchy_Level_06__c
                    FROM User WHERE Id = :UsrId];
        Usr.Mgmt_Chain_Hierarchy_Level_02__c = U2;
        Usr.Mgmt_Chain_Hierarchy_Level_03__c = U3;
        Usr.Mgmt_Chain_Hierarchy_Level_04__c = U4;
        Usr.Mgmt_Chain_Hierarchy_Level_05__c = U5;
        Usr.Mgmt_Chain_Hierarchy_Level_06__c = U6;
        Lst.add(Usr);
	    update Lst;
        
        Test.startTest();
        TM_Tech_Batch__c TB = new TM_Tech_Batch__c( Leader__c = UsrId );
        insert TB;

        TM_Tech_Batch__c TB2 = [SELECT Id, Name, Leader__r.Id FROM TM_Tech_Batch__c WHERE Id = :TB.Id];

		ApexPages.StandardController stdCtlr = new ApexPages.StandardController( TB2 );
        IC_Talent_Management_Batch_Launcher myCtlr = new IC_Talent_Management_Batch_Launcher( stdCtlr );
        myCtlr.UpdateNumbers();
        myCtlr.LaunchCreations();
        Test.stopTest();
	}
    
    private static testMethod void Test_Sharing_Caculation() {
		Career_Profile__c sProfile = Talent_Management_Test.CreateTestData();
		List<Talent_Management__c> lst = new List<Talent_Management__c>();
        
        for( User Usr : [SELECT Id FROM user 
                    	 WHERE isactive = true
                           AND Mgmt_Chain_Hierarchy_Level_06__c != Null LIMIT 50] ) {
			Talent_Management__c newTM = new Talent_Management__c();
			newTM.Career_Profile__c = sProfile.Id;
            newTM.Opportunity_Profile__c = sProfile.Id;
            newTM.ownerId = Usr.Id;
            newTM.User__c = Usr.Id;
			lst.add(newTM);
		}
        insert lst;
        
        TM_Tech_Batch__c TB = new TM_Tech_Batch__c( Leader__c = UserInfo.getUserId() );
        insert TB;
        
        Test.startTest();
		ApexPages.StandardController stdCtlr = new ApexPages.StandardController( TB );
        IC_Talent_Management_Batch_Launcher myCtlr = new IC_Talent_Management_Batch_Launcher( stdCtlr );
        myCtlr.RecalculateSharing();
        myCtlr.RecalculateSharing();
        Test.stopTest();
    }
    
    
	private static testMethod void Test_IC_Talent_Management() {
		Test.startTest();
        IC_Talent_Management myCtlr = new IC_Talent_Management();
        myCtlr.CheckRecordExist();
        myCtlr.UpdateOpportunity();
        myCtlr.SelectDirect();
        myCtlr.UpdateDirect();

        Boolean B1 = myCtlr.initialised;
        Boolean B2 = myCtlr.ShowMyTeam;
        Boolean B3 = myCtlr.ShowDirect;
		Talent_Management__c T1 = myCtlr.Individual;
        LGData T2 = myCtlr.Data;
        List<Talent_Management__c> T3 = myCtlr.MyDirects;
        Talent_Management__c T4 = myCtlr.Direct;
        LGData T5 = myCtlr.DirectLG;
        
        List<Tech_Line__c> L1=T2.ProfileTransferableSkills;
        List<Tech_Line__c> L2=T2.ProfileGroupSkills;
        List<Tech_Line__c> L3=T2.ProfilePathSkills;
        List<Tech_Line__c> L4=T2.OpportunityTransferableSkills;
        List<Tech_Line__c> L5=T2.OpportunityGroupSkills;
        List<Tech_Line__c> L6=T2.OpportunityPathSkills;
        
        Boolean B4=T2.ShowProfileTransferableSkills;
        Boolean B5=T2.ShowProfileGroupSkills;
        Boolean B6=T2.ShowProfilePathSkills;
        Boolean B7=T2.ShowOpportunityTransferableSkills;
        Boolean B8=T2.ShowOpportunityGroupSkills;
        Boolean B9=T2.ShowOpportunityPathSkills;
        Test.stopTest();
    }
        
    public static testMethod Career_Profile__c CreateTestData() {
        List<CSGProfileSkill__c> LstSk = [SELECT Id,
                                          		 Category__c,
                                          		 External_Id__c,
                                          		 Name,
                                          		 Type__c
                                          FROM CSGProfileSkill__c WHERE External_Id__c = '0Sk3y000000TOfFCAW'];
        CSGProfileSkill__c Sk;
        if( LstSk.size() == 0 ) {
            Sk = new CSGProfileSkill__c(Category__c = 'Category',
                                        External_Id__c = '0Sk3y000000TOfFCAW',
                                        Name = 'Skill',
                                        Type__c = 'Type');
        	insert Sk;
        } else {
            Sk = LstSk[0];
        }

		Career_Profile__c CP;
        List<Career_Profile__c> LstCP = [SELECT Career_Path__c,
                                         		Career_Path_Group__c,
                                         		Name,
                                         		Job_Grade__c,
                                         		Job_Families__c
                                         FROM Career_Profile__c WHERE Name = 'Profile'];
        if( LstCP.size() == 0 ) {
            CP = new Career_Profile__c(Career_Path__c = 'Path',
                                       Career_Path_Group__c = 'Group',
                                       Name = 'Profile',
                                       Job_Grade__c = '07',
                                       Job_Families__c = '450');
			insert CP;
       
            Leveling_Guide__c LG = new Leveling_Guide__c(Career_Profile__c = CP.id,
                                                         Expected_Rating__c = '3',
                                                         Skill__c = Sk.Id,
                                                         Skill_Group__c = 'Group-Specific Skill');
	        insert LG;
        } else {
            CP = LstCP[0];
        }
        return CP;
    }
}