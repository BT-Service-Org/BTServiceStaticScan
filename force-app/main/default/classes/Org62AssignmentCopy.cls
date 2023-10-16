global class Org62AssignmentCopy implements Schedulable {
    
    global void execute(SchedulableContext SC) {
        
        CopyAssignment();
        CopyProject();
       
    }
    

    @future
    public static void CopyAssignment()
    {
        
        
        DateTime Modifyfilter =  System.today().adddays(-1);
      
        System.debug(Modifyfilter);
        List<pse_Assignment_c__x> org62AssignmentList = [Select id,pse_Billable_Hours_Submitted_c__c,pse_Description_c__c,pse_End_Date_c__c,Name__c,Project_Name_c__c,	Project_Region_c__c,
                                                         pse_Project_c__c,pse_Resource_c__c,pse_Start_Date_c__c,pse_Status_c__c,ExternalId,pse_Project_c__r.ExternalId,pse_Resource_c__r.ExternalId
                                                         from pse_Assignment_c__x 
                                                         where
                                                         LastModifiedDate__c >= :Modifyfilter
                                                        ];
        
        Map<Id,Id> RegionMap = new Map<Id,Id>();
        Map<Id,Id> AcctMap =  new Map <Id, Id>();
        Map<Id,Id> OpportunityMap = new Map<Id,Id>();
        Map<Id,Id> projectMap = new Map<Id,Id>();
         Map<Id,Id> org62ContactMap = new Map<Id,Id>();
        for (PSA_Project__c proj: [select Id,Org62_Id__c from PSA_Project__c])
        {
            projectMap.put(proj.Org62_Id__c,proj.Id);
        }
        
        for (Account b: [select Id,Org62_Id__c from Account])
        {
            AcctMap.put(b.Org62_Id__c,b.Id);
        }
        
        for (Opportunity opty :[SELECT Id,Org62_Id__c FROM Opportunity WHERE Org62_Id__c != null ]){
            
            OpportunityMap.put(opty.Org62_Id__c, opty.Id);
        }
         for(Contact con :[SELECT Id,Org62_Contact_ID__c from Contact WHERE Org62_Contact_ID__c != null ]){
             org62ContactMap.put(con.Org62_Contact_ID__c,con.Id);
        }
        
        List<Project_Assignment__c> psaAssignmentUpsert = new List<Project_Assignment__c>();
        
        
        for (pse_Assignment_c__x assignmentExternal :org62AssignmentList)
        {
            System.debug('In the loop');
            
            Project_Assignment__c psaAssignment = new Project_Assignment__c();
            
            psaAssignment.Billable_Hours_Submitted__c = assignmentExternal.pse_Billable_Hours_Submitted_c__c;
            psaAssignment.Description__c = assignmentExternal.pse_Description_c__c;
            psaAssignment.End_Date__c =assignmentExternal.pse_End_Date_c__c;
            psaAssignment.Name = assignmentExternal.Name__c;
            //  psaAssignment.End_Date__c = assignmentExternal.End_Date__c;
            psaAssignment.Project_Name__c = assignmentExternal.Project_Name_c__c;
            psaAssignment.Project_Region__c = assignmentExternal.Project_Region_c__c;
            psaAssignment.Start_Date__c = assignmentExternal.pse_Start_Date_c__c;
            psaAssignment.PSA_Project__c = projectMap.get(assignmentExternal.pse_Project_c__r.ExternalId);
            psaAssignment.Resource__c = org62ContactMap.get(assignmentExternal.pse_Resource_c__r.ExternalId);
            psaAssignment.Status__c = assignmentExternal.pse_Status_c__c;
            psaAssignment.Org62_Id__c = assignmentExternal.ExternalId;
             psaAssignment.Org62_Project_Id__c = assignmentExternal.pse_Project_c__r.ExternalId;
            
            psaAssignmentUpsert.add(psaAssignment);
            
        }
        
        Upsert psaAssignmentUpsert Org62_Id__c;
        
        
    }
    
    @future
    public static void CopyProject()
    {
        Map<Id,Id> assignmentWithoutProject = new Map <Id,Id>();
        for (Project_Assignment__c a : [select Id, Org62_Project_Id__c
                                        from Project_Assignment__c where PSA_Project__c = ''
                                       ])
        {
            if (!(assignmentWithoutProject.containsKey(a.Org62_Project_Id__c)))
                assignmentWithoutProject.put(a.Org62_Project_Id__c,a.Id);
        }
        
        List<pse_Proj_c__x> org62ProjectList = [Select id,pse_Account_c__c,pse_Is_Active_c__c,pse_Billing_Type_c__c, pse_Bookings_c__c,pse_Start_Date_c__c, OwnerId__c,ExternalId, 
                                                pse_End_Date_c__c,pse_Opportunity_c__c, pse_Project_Manager_c__c,pse_Project_Manager_c__r.Name__c, ProjectManagerUser_c__c,ProjectManagerUser_c__r.Name__c,LastModifiedDate__c 
                                                from pse_Proj_c__x 
                                                where
                                                ExternalId in :assignmentWithoutProject.keySet() 
                                               ];
        
        Map<Id,Id> RegionMap = new Map<Id,Id>();
        Map<Id,Id> AcctMap =  new Map <Id, Id>();
        Map<Id,Id> OpportunityMap = new Map<Id,Id>();
         Map<Id,Id> org62ContactMap = new Map<Id,Id>();
        Map<Id,Id> org62UserMap = new Map<Id,Id>();
        for (Org62_Regions__c a: [select Id,Org62_Id__c from Org62_Regions__c])
        {
            RegionMap.put(a.Org62_Id__c,a.Id);
        }
        
        for (Account b: [select Id,Org62_Id__c from Account])
        {
            AcctMap.put(b.Org62_Id__c,b.Id);
        }
        
        for (Opportunity opty :[SELECT Id,Org62_Id__c FROM Opportunity WHERE Org62_Id__c != null ]){
            
            OpportunityMap.put(opty.Org62_Id__c, opty.Id);
        }
         for(Contact con :[SELECT Id,Org62_Contact_ID__c from Contact WHERE Org62_Contact_ID__c != null ]){
             org62ContactMap.put(con.Org62_Contact_ID__c,con.Id);
        }
        
        for(User usr :[SELECT Id,Org62Id__c from User WHERE Org62Id__c != null]){
             org62UserMap.put(usr.Org62Id__c,usr.Id);
        }
        
        List<PSA_Project__c> PSAProjectUpsert = new List<PSA_Project__c>();
        
        
        for (pse_Proj_c__x projExternal :org62ProjectList)
        {
            System.debug('In the loop');
            
            PSA_Project__c PsaProj = new PSA_Project__c();
            
           PsaProj.Name = projExternal.Name__c;
            PsaProj.Account__c = AcctMap.get(projExternal.pse_Account_c__c);
            PsaProj.Active__c = projExternal.pse_Is_Active_c__c;
            PsaProj.Billing_Type__c =projExternal.pse_Billing_Type_c__c;
            PsaProj.Bookings__c = projExternal.pse_Bookings_c__c;
            PsaProj.End_Date__c = projExternal.pse_End_Date_c__c;
            PsaProj.Org62_Id__c = projExternal.ExternalId;
            PsaProj.Org62_Project_ID__c = projExternal.Project_ID__c;
            PSaProj.Project_Manager__c = org62ContactMap.get(projExternal.pse_Project_Manager_c__r.ExternalId);
            // PSaProj.Project_Setup_Status__c = projExternal.
            PSaProj.ProjectManagerUser__c = org62UserMap.get(projExternal.ProjectManagerUser_c__r.ExternalId);
            //  PSaProj.Regional_Services_Manager__c = projExternal.
            PsaProj.Start_Date__c = projExternal.pse_Start_Date_c__c;
            PsaProj.Project_Manager_Name__c = projExternal.pse_Project_Manager_c__r.Name__c;
            PsaProj.Project_Manager_Name_User__c = projExternal.ProjectManagerUser_c__r.Name__c;
            PsaProj.Opportunity__c = OpportunityMap.get(projExternal.pse_Opportunity_c__c);
            PsaProj.Org62_Account_Id__c = projExternal.pse_Account_c__c;
            PsaProj.Org62_Opportunity_Id__c = projExternal.pse_Opportunity_c__c;
            
            
            PSAProjectUpsert.add(PSaProj);
            
        }
        
        // Upsert PSAProjectUpsert Org62_Id__c;
        Database.upsert(PSAProjectUpsert, PSA_Project__c.Fields.Org62_Id__c, false);
        
        
    }
    
 /*   @future
    public static void CopyOpportunity()
    {
        
        Map<Id,Id> ProjWithoutOpty = new Map <Id,Id>();
        Map<Id,Id> GCMap = new Map<Id,Id>();
        for (PSA_Project__c a : [select Opportunity__c
                                 from PSA_Project__c where Opportunity__c = ''
                                ])
        {
            if (!(ProjWithoutOpty.containsKey(a.Opportunity__c)))
                ProjWithoutOpty.put(a.Opportunity__c,a.Id);
        }
        
        for (Global_Company__c gc: [select Id,Org62_Id__c from Global_Company__c])
        {
            GCMap.put(gc.Org62_Id__c,gc.Id);
        }
        
        List<Opportunity> newOpportunity = new List<Opportunity>();
        List<Opportunity__x> AllOpty = [select ExternalId,Name__c,Amount__c,AccountId__c,CurrencyISOCode__c,
                                        CloseDate__c, Franchise_c__c, pse_Region_c__c,
                                        CFL_Region_c__c,StageName__c,Next_Steps_c__c, 
                                        Push_Counter_c__c,sfquote_Term_c__C,Type__c, Sub_Type_c__c,Probability__c,Fiscal__c,
                                        Discount_c__c,Overall_Bid_Margin_c__c,Dead_Reason_c__c,
                                        ForecastCategoryName__c,Red_Green_c__c,OwnerId__r.Name__c, Related_License_Oppty_c__c
                                        from Opportunity__x 
                                        where ExternalId in :ProjWithoutOpty.keySet() 
                                        
                                       ];
        
        Map<Id,Id> RegionMap = new Map<Id,Id>();
        Map<Id,Id> AcctMap =  new Map <Id, Id>();
        for (Org62_Regions__c a: [select Id,Org62_Id__c from Org62_Regions__c])
        {
            RegionMap.put(a.Org62_Id__c,a.Id);
        }
        
        for (Account b: [select Id,Org62_Id__c from Account])
        {
            AcctMap.put(b.Org62_Id__c,b.Id);
        }
        
        
        
        for (Opportunity__x OptyExternal :AllOpty)
        {
            
            Opportunity PAOpty = new Opportunity();
            
            PAOpty.Org62_Id__c = OptyExternal.ExternalId;
            PAOpty.Name = OptyExternal.Name__c.abbreviate(80);
            PAOpty.CFL_Region__c = OptyExternal.CFL_Region_c__c;
            PAOpty.Region__c = RegionMap.get(OptyExternal.pse_Region_c__c);
            PAOpty.AccountId = AcctMap.get(OptyExternal.AccountId__c);
            PAOpty.StageName = OptyExternal.StageName__c;
            PAOpty.NextStep= OptyExternal.Next_Steps_c__c;
            PAOpty.Push_Counter__c= OptyExternal.Push_Counter_c__c;
            PAOpty.Term__c= OptyExternal.sfquote_Term_c__C;
            PAOpty.CloseDate= OptyExternal.CloseDate__c;
            PAOpty.Type= OptyExternal.Type__c;
            PAOpty.Sub_Type__c= OptyExternal.Sub_Type_c__c;
            PAOpty.Amount = OptyExternal.Amount__c;
            PAOpty.Franchise__c = OptyExternal.Franchise_c__c;
            PAOpty.Org62_Account__c = OptyExternal.AccountId__c;
            PAOpty.Probability = OptyExternal.Probability__c;
            PAOpty.CurrencyIsoCode = OptyExternal.CurrencyISOCode__c;
            PAOpty.Fiscal_Period__c = OptyExternal.Fiscal__c;
            PAOpty.ForecastCategoryName = OptyExternal.ForecastCategoryName__c;
            PAOPty.Red_Green__c = OptyExternal.Red_Green_c__c;
            PAOpty.Discount__c = OptyExternal.Discount_c__c;
            PAOpty.Overall_Bid_Margin__c = OptyExternal.Overall_Bid_Margin_c__c;
            PAOpty.Org62_Owner__c = OptyExternal.OwnerId__r.Name__c;
            PAOpty.Related_License_Oppty__c = OptyExternal.Related_License_Oppty_c__c;
            PAOpty.Dead_Reason__c = OptyExternal.Dead_Reason_c__c;
            newOpportunity.add(PAOpty);
            
        }
        
        Database.upsert(newOpportunity, Opportunity.Fields.Org62_Id__c, false) ;
        
    }  */
    
}