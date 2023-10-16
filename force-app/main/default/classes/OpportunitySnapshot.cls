global class OpportunitySnapshot implements schedulable {
    
        global void execute(SchedulableContext SC) {
		
		insertcurrtmonthsnapshot();
//        insertnextmonthsnapshot();

    }
    
   global static void insertcurrtmonthsnapshot() {
    	
         List  <Opportunity_Snapshot__c> OptySnapList = new List <Opportunity_Snapshot__c>();

            AggregateResult[] OptySnapshot = [select count(Id),sum(Amount), Type, Region__c,ForecastCategoryName,
                                              max(CloseDate)
                                            from Opportunity
                                            where CloseDate = THIS_MONTH
                                            and ForecastCategoryName != 'Omitted'
                                              and (not Account.Name like 'Salesforce Services%')
                                            group by Type, Region__c,ForecastCategoryName];
        
            for (AggregateResult ar : OptySnapshot)  {
                Opportunity_Snapshot__c newRecd = new Opportunity_Snapshot__c();
                newRecd.Forecast_Category__c = (String)ar.get('ForecastCategoryName');
                newRecd.Opportunity__c = (Integer)ar.get('expr0');
                newRecd.Org62_Regions__c = (Id)ar.get('Region__c');
                newRecd.Type__c = (String)ar.get('Type');
                newRecd.Amount__c = (Decimal)ar.get('expr1');
                newRecd.Close_Date__c = (Date)ar.get('expr2');
                
                OptySnapList.add(newRecd);
        }
     
            
		insert OptySnapList;
        
    }
    global static void insertnextmonthsnapshot() {
    	
         List  <Opportunity_Snapshot__c> OptySnapList = new List <Opportunity_Snapshot__c>();
        


            AggregateResult[] OptySnapshot = [select count(Id),sum(Amount), Type, Region__c,ForecastCategoryName,
                                              max(CloseDate)
                                    from Opportunity
                                    where CloseDate = NEXT_MONTH
                                    and ForecastCategoryName != 'Omitted'
                                    and (not Account.Name like 'Salesforce Services%')
                                    group by Type, Region__c,ForecastCategoryName];
     
           
        
            for (AggregateResult ar : OptySnapshot)  {
                Opportunity_Snapshot__c newRecd = new Opportunity_Snapshot__c();
                newRecd.Forecast_Category__c = (String)ar.get('ForecastCategoryName');
                newRecd.Opportunity__c = (Integer)ar.get('expr0');
                newRecd.Org62_Regions__c = (Id)ar.get('Region__c');
                newRecd.Type__c = (String)ar.get('Type');
                newRecd.Amount__c = (Decimal)ar.get('expr1');
                newRecd.Close_Date__c = (Date)ar.get('expr2');
                
                OptySnapList.add(newRecd);
        }
      
		insert OptySnapList;
        
    }
}