/*
* Description: This Class is used to run sync of Project Opportunity and Account.
* Date: 01-03-2023
* */
global class Org62ProjectOpportunityAccountSyncBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        
        String query = 'select Id, Org62_Opportunity_Id__c,Org62_Account_Id__c,Opportunity__c, Account__c ' +
            'from PSA_Project__c where Opportunity__c = \'\' ' +
            'OR Account__c = \'\'';
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<PSA_Project__c> ProjList) {
        
        // process each batch of project records 
        try {
            List<Id> acctIds = new List<Id>();
            List<Id> regionOrg62Ids = new List<Id>();
            List<Id> gcIds = new List<Id>();
            Map<Id,Id> ProjWithoutOpty = new Map <Id,Id>();
            Map<Id,Id> projectWithoutAccount = new Map <Id,Id>();
            Map<Id,Id> GCMap = new Map<Id,Id>();
            List<Opportunity> newOpportunity = new List<Opportunity>();
            List<Account> newAccounts = new List<Account>();
            Map<Id,Id> RegionMap = new Map<Id,Id>();
            Map<Id,Id> AcctMap =  new Map <Id, Id>();
            
            for(PSA_Project__c proj :ProjList){
                if (!(ProjWithoutOpty.containsKey(proj.Org62_Opportunity_Id__c)) && proj.Opportunity__c ==null)
                    ProjWithoutOpty.put(proj.Org62_Opportunity_Id__c,proj.Id);
                if (!(projectWithoutAccount.containsKey(proj.Org62_Account_Id__c)) && proj.Account__c == null)
                    projectWithoutAccount.put(proj.Org62_Account_Id__c,proj.Id);
            }
            
            
            List<Opportunity__x> AllOpty = [select ExternalId,Name__c,Amount__c,AccountId__c,CurrencyISOCode__c,Targeted_Clouds_c__c,
                                            CloseDate__c, Franchise_c__c, pse_Region_c__c,
                                            CFL_Region_c__c,StageName__c,Next_Steps_c__c, 
                                            Push_Counter_c__c,sfquote_Term_c__C,Type__c, Sub_Type_c__c,Probability__c,Fiscal__c,
                                            Discount_c__c,Overall_Bid_Margin_c__c,Dead_Reason_c__c,
                                            ForecastCategoryName__c,Red_Green_c__c,OwnerId__r.Name__c, Related_License_Oppty_c__c
                                            from Opportunity__x 
                                            where ExternalId in :ProjWithoutOpty.keySet() 
                                            
                                           ];

            for(Opportunity__x opptRec : AllOpty)
            {
                acctIds.add(opptRec.AccountId__c);
                regionOrg62Ids.add(opptRec.pse_Region_c__c);
            }

            for (Org62_Regions__c a: [select Id,Org62_Id__c from Org62_Regions__c WHERE Org62_Id__c IN:regionOrg62Ids])
            {
                RegionMap.put(a.Org62_Id__c,a.Id);
            }
            
            for (Account b: [select Id,Org62_Id__c from Account WHERE Org62_Id__c IN:acctIds])
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
                PAOpty.Targeted_Clouds__c = OptyExternal.Targeted_Clouds_c__c;
                newOpportunity.add(PAOpty);
                
            }
            
            List<Account__x> AccountList = [select ExternalId,Name__c,BillingState__c,BillingCountry__c, BillingStreet__c,BillingCity__c,
                                            BillingPostalCode__c,SFDC_Sector_c__c, Sub_Sector_c__c,Industry__c,Region_AOV_Band_c__c,
                                            Global_Company_c__r.Name__c,Region_c__c,AccountStatus_c__c,Type__c,AOV_Band_c__c,CSG_Portfolio_c__c,
                                            CSG_Region_formula_c__c,Global_Company_c__c
                                            from Account__x where ExternalId in :projectWithoutAccount.keySet()];

            
            for(Account__x accRec : AccountList)
            {
                gcIds.add(accRec.Global_Company_c__c);
            }

            for (Global_Company__c gc: [select Id,Org62_Id__c from Global_Company__c WHERE Org62_Id__c IN:gcIds])
            {
                GCMap.put(gc.Org62_Id__c,gc.Id);
            }
            for (integer u=0; u< AccountList.size();u++)
            {
                Account newAcct = new Account();
                
                newAcct.Name = AccountList[u].Name__c;
                newAcct.BillingState = AccountList[u].BillingState__c ;
                newAcct.BillingCountry = AccountList[u].BillingCountry__c;
                newAcct.BillingStreet = AccountList[u].BillingStreet__c;
                newAcct.BillingCity = AccountList[u].BillingCity__c;
                newAcct.BillingPostalCode = AccountList[u].BillingPostalCode__c;
                newAcct.Org62_Id__c = AccountList[u].Externalid;
                newAcct.Industry = AccountList[u].Industry__c;
                newAcct.Sector__c = AccountList[u].SFDC_Sector_c__c;
                newAcct.Sub_Sector__c = AccountList[u].Sub_Sector_c__c;
                newAcct.CSG_Region_AOV_Band__c = AccountList[u].Region_AOV_Band_c__c;
                newAcct.Global_Company_Id__c = GCMap.get(AccountList[u].Global_Company_c__c);
                newAcct.Geo__c = AccountList[u].Region_c__c;
                newAcct.AOV_Band__c = AccountList[u].AOV_Band_c__c;
                newAcct.Account_Status__c= AccountList[u].AccountStatus_c__c;
                newAcct.Type = AccountList[u].Type__c;
                newAcct.CSG_Region__c = AccountList[u].CSG_Region_formula_c__c;
                newAcct.CSG_Portfolio__c =AccountList[u].CSG_Portfolio_c__c;
                newAccounts.add(newAcct);
                
            }
            Database.upsert(newOpportunity, Opportunity.Fields.Org62_Id__c, false) ;
            Database.upsert(newAccounts, Account.Fields.Org62_id__c, false) ;
            // ProjectMethodCalculationsBatchHandler.processMethodforProjectRecCreation(projIds,extProjList);
            
        } catch(Exception e) {
            System.debug(e);
        }
    }
    
    
    global void finish(Database.BatchableContext BC) {
        
    }
}