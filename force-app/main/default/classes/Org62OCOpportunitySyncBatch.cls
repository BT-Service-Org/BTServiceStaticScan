/*
* Description: This Class is used to run sync of Offering Contribution Opportunity.
* Date: 04-14-2023
* */
global class Org62OCOpportunitySyncBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        
        String query = 'SELECT Id, Org62_Opportunity_Id__c, Opportunity__c ' +
            'from Practice_Contribution__c WHERE Opportunity__c = \'\' ' ;
           
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Practice_Contribution__c> offContrList) {
        
        // process each batch of project records 
        try {
            List<Id> acctIds = new List<Id>();
            List<Id> regionOrg62Ids = new List<Id>();
            Map<Id,Id> ocWithoutOpty = new Map <Id,Id>();
            Map<Id,Id> GCMap = new Map<Id,Id>();
            List<Opportunity> newOpportunity = new List<Opportunity>();
            Map<Id,Id> RegionMap = new Map<Id,Id>();
            Map<Id,Id> AcctMap =  new Map <Id, Id>();
            
            for(Practice_Contribution__c ofCon :offContrList){
                if (!(ocWithoutOpty.containsKey(ofCon.Org62_Opportunity_Id__c)) && ofCon.Opportunity__c ==null)
                    ocWithoutOpty.put(ofCon.Org62_Opportunity_Id__c,ofCon.Id);
              
            }
            
            for (Global_Company__c gc: [select Id,Org62_Id__c from Global_Company__c])
            {
                GCMap.put(gc.Org62_Id__c,gc.Id);
            }
            
            List<Opportunity__x> AllOpty = [select ExternalId,Name__c,Amount__c,AccountId__c,CurrencyISOCode__c,Targeted_Clouds_c__c,
                                            CloseDate__c, Franchise_c__c, pse_Region_c__c,
                                            CFL_Region_c__c,StageName__c,Next_Steps_c__c, 
                                            Push_Counter_c__c,sfquote_Term_c__C,Type__c, Sub_Type_c__c,Probability__c,Fiscal__c,
                                            Discount_c__c,Overall_Bid_Margin_c__c,Dead_Reason_c__c,
                                            ForecastCategoryName__c,Red_Green_c__c,OwnerId__r.Name__c, Related_License_Oppty_c__c
                                            from Opportunity__x 
                                            where ExternalId in :ocWithoutOpty.keySet() 
                                            
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
            
            
            Database.upsert(newOpportunity, Opportunity.Fields.Org62_Id__c, false) ;
           
            
        } catch(Exception e) {
            System.debug(e);
        }
    }
    
    
    global void finish(Database.BatchableContext BC) {
        
    }
}