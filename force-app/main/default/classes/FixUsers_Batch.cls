global without sharing class FixUsers_Batch implements Database.Batchable<sObject> {
	//
	final private String myEmailAddress;
    final private Map<Id, Id> Org62UsersMap = new Map<Id, Id>();
    private static final Id ProServLeaderId = '0053A00000Fa2wqQAB';
	//
    // Store Email address for sending messages
    //
    // Prepare a mapping from UserId(from Org62) to UserId (from Services Org)
    //  
    public FixUsers_Batch() {
        myEmailAddress = UserInfo.getUserEmail();
        for( User Cur : [SELECT Id, Org62Id__c
                         FROM User
                         WHERE Org62Id__c != Null
                         AND Mgmt_Chain_Hierarchy_Level_03__c = :ProServLeaderId] )
        	Org62UsersMap.put( Cur.Org62Id__c, Cur.Id );

        User ProServLeader = [SELECT Id, Org62Id__c, Mgmt_Chain_Hierarchy_Level_02__c
                              FROM User
                              WHERE Id = :ProServLeaderId][0];
        Org62UsersMap.put( ProServLeader.Org62Id__c, ProServLeader.Id );

		Id CSGLeaderId = ProServLeader.Mgmt_Chain_Hierarchy_Level_02__c;
        User CSGLeader = [SELECT Id, Org62Id__c
                          FROM User
                          WHERE Id = :CSGLeaderId][0];
        Org62UsersMap.put( CSGLeader.Org62Id__c, CSGLeader.Id );
    }
	//
	// Loop of the Active Users reporting to Marl Wakelin (in Services Org)
	// 
    global Database.QueryLocator start( Database.BatchableContext BC ) {
        return Database.getQueryLocator( [SELECT Id, Name, ManagerId, Org62Id__c,
                                          		 Business_Unit__c,
                                          		 BU__c,
                                          		 JobFamily__c,
                                          		 JobCode__c,
                                          		 JobProfile__c,
                                          		 JobGrade__c,
                                          		 EmployeeNumber,
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
                                          FROM User
                                          WHERE IsActive = TRUE
                                            AND Org62Id__c != Null
                                            AND Mgmt_Chain_Hierarchy_Level_03__c = :ProServLeaderId] );
    }
	//
    // Execute
    //    
    global void execute(Database.BatchableContext BC, List<User> Scope){
		//
		// Get list of User Ids (for filtering)
		//
        List<Id> Org62IdList = new List<Id>();
        for( User curUser : Scope )
            Org62IdList.add( curUser.Org62Id__c );
		//
		// Get the data from Org62 for the Users in the Scope
		//
        Map<Id, User__x> Org62Map = new Map<Id, User__x>();
        for( User__x Cur : [ SELECT Id, Name__c, ManagerId__c, ExternalId, IsActive__c,
                            		Business_Unit_c__c,
                                    BU_c__c,
                                    JobFamily_c__c,
                                    JobCode_c__c,
                                    JobProfile_c__c,
                                    JobGrade_c__c,
                            		EmployeeNumber__c,
                            		Mgmt_Chain_Level_02_c__c, 
                            		Mgmt_Chain_Level_03_c__c, 
                            		Mgmt_Chain_Level_04_c__c, 
                            		Mgmt_Chain_Level_05_c__c, 
                            		Mgmt_Chain_Level_06_c__c, 
                            		Mgmt_Chain_Level_07_c__c, 
                            		Mgmt_Chain_Level_08_c__c, 
                            		Mgmt_Chain_Level_09_c__c, 
                            		Mgmt_Chain_Level_10_c__c, 
                            		Mgmt_Chain_Level_11_c__c, 
                            		Mgmt_Chain_Level_12_c__c 
                            FROM User__x  
                            WHERE ExternalId IN :Org62IdList ] )
            Org62Map.put( Cur.ExternalId, Cur );
        //
        // Update the Users that are part of the Scope
        // Copy the Hierarchy from Org62
        //
        for( User CurUser : Scope )
        	if( Org62Map.containsKey( CurUser.Org62Id__c ) ) {

                User__x Org62User = Org62Map.get( CurUser.Org62Id__c );

                CurUser.Business_Unit__c = Org62User.Business_Unit_c__c;
                CurUser.BU__c = Org62User.BU_c__c;
                CurUser.JobFamily__c = Org62User.JobFamily_c__c;
                CurUser.JobCode__c = Org62User.JobCode_c__c;
                CurUser.JobProfile__c = Org62User.JobProfile_c__c;
                CurUser.JobGrade__c = Org62User.JobGrade_c__c;
                CurUser.EmployeeNumber = Org62User.EmployeeNumber__c;
                if( Org62User.IsActive__c ) {
                    CurUser.ManagerId = GetUserId(Org62User.ManagerId__c);
                    CurUser.Mgmt_Chain_Hierarchy_Level_02__c = GetUserId(Org62User.Mgmt_Chain_Level_02_c__c);
                    CurUser.Mgmt_Chain_Hierarchy_Level_03__c = GetUserId(Org62User.Mgmt_Chain_Level_03_c__c);
                    CurUser.Mgmt_Chain_Hierarchy_Level_04__c = GetUserId(Org62User.Mgmt_Chain_Level_04_c__c);
                    CurUser.Mgmt_Chain_Hierarchy_Level_05__c = GetUserId(Org62User.Mgmt_Chain_Level_05_c__c);
                    CurUser.Mgmt_Chain_Hierarchy_Level_06__c = GetUserId(Org62User.Mgmt_Chain_Level_06_c__c);
                    CurUser.Mgmt_Chain_Hierarchy_Level_07__c = GetUserId(Org62User.Mgmt_Chain_Level_07_c__c);
                    CurUser.Mgmt_Chain_Hierarchy_Level_08__c = GetUserId(Org62User.Mgmt_Chain_Level_08_c__c);
                    CurUser.Mgmt_Chain_Hierarchy_Level_09__c = GetUserId(Org62User.Mgmt_Chain_Level_09_c__c);
                    CurUser.Mgmt_Chain_Hierarchy_Level_10__c = GetUserId(Org62User.Mgmt_Chain_Level_10_c__c);
                    CurUser.Mgmt_Chain_Hierarchy_Level_11__c = GetUserId(Org62User.Mgmt_Chain_Level_11_c__c);
                    CurUser.Mgmt_Chain_Hierarchy_Level_12__c = GetUserId(Org62User.Mgmt_Chain_Level_12_c__c);
                }
                else {
                    CurUser.ManagerId = null;
                    CurUser.Mgmt_Chain_Hierarchy_Level_02__c = null;
                    CurUser.Mgmt_Chain_Hierarchy_Level_03__c = null;
                    CurUser.Mgmt_Chain_Hierarchy_Level_04__c = null;
                    CurUser.Mgmt_Chain_Hierarchy_Level_05__c = null;
                    CurUser.Mgmt_Chain_Hierarchy_Level_06__c = null;
                    CurUser.Mgmt_Chain_Hierarchy_Level_07__c = null;
                    CurUser.Mgmt_Chain_Hierarchy_Level_08__c = null;
                    CurUser.Mgmt_Chain_Hierarchy_Level_09__c = null;
                    CurUser.Mgmt_Chain_Hierarchy_Level_10__c = null;
                    CurUser.Mgmt_Chain_Hierarchy_Level_11__c = null;
                    CurUser.Mgmt_Chain_Hierarchy_Level_12__c = null;
                }
            }
        //
        // Apply updates
        //         
        UserContactUtil.doNotExecuteTrigger = True;
        try {
            update Scope;
        } catch(Exception e) {
            SendEmail( 'Fix User Records Error',
                       'The batch threw the following exception: ' + 
                        e.getMessage() );
        }
    }    
    //
    // Get a Services User Id from a Org62 User Id
    // 
    private Id GetUserId( Id Org62UserId ) {
		Id Tmp;
        if( Org62UsersMap.containsKey( Org62UserId ) )
            Tmp = Org62UsersMap.get( Org62UserId );
        else
            Tmp = Null;
        return Tmp;
    }
    //
    // End of the process
    //
    global void finish(Database.BatchableContext BC){  
        SendEmail( 'Fix User Records - END',
                   'Batch ended' );
    }
	//
	// Sending Email
	//
    private void SendEmail( String Subject, String Message ) {
        Messaging.SingleEmailMessage newMail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] { myEmailAddress }; 
        newMail.setToAddresses( toAddresses ); 
        newMail.setSubject( Subject );
        newMail.setPlainTextBody( Message );
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { newMail } );
    }
}