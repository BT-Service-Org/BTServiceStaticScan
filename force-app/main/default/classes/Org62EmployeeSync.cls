global class Org62EmployeeSync implements Schedulable{

     global void execute(SchedulableContext SC) {
     
     	TravelPref();
     }
    
    @future
    public static void TravelPref()
    	{
  

        List<Org62_User__x> AdvisoryEmp = [select ExternalId,Email__c,(select Id,Willingness_to_travel_c__c,
                                                                       	Willingness_to_relocate_c__c from Employees__r) 
                                           from Org62_User__x
											where department__c in ('3090-Program Architects','3096-BA/ITC','3020-Accelerated PA','3095-Strategic Customers Management') 
											and Isactive__c = true
                                           //and Email__c = 'anurodh.agarwal@salesforce.com'
											];
        
        List<PA_Onboarding__c> PAUpsert = new List<PA_Onboarding__c>();
        Map<String,Id> PAMap = new Map <String,Id>();
        
        for (PA_Onboarding__c a: [select Id,Contact__r.Email from PA_Onboarding__c])
        {
            PAMap.put(a.Contact__r.Email,a.Id);
  
         }
            
            
        for (integer u=0; u< AdvisoryEmp.size();u++)
        {
           
 			if (PAMap.containsKey(AdvisoryEmp[u].Email__c))
            {
                if (AdvisoryEmp[u].Employees__r.size() > 0)
                {
                    PA_Onboarding__c PA = new PA_Onboarding__c();
                    PA.Id = PAMap.get(AdvisoryEmp[u].Email__c);
                    PA.Willingness_to_Travel__c = AdvisoryEmp[u].Employees__r[0].Willingness_to_travel_c__c;
                    PA.Willingness_to_Relocate__c = AdvisoryEmp[u].Employees__r[0].Willingness_to_relocate_c__c;
                    PAUpsert.add(PA);
                    
                 }
                
            }
            
  
         }

            Upsert PAUpsert Id;

    }
    
}