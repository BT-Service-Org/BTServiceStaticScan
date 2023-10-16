global class Org62RegionSync implements Schedulable{
    
    global void execute(SchedulableContext SC) {
        
        CopyRegion();
    }
         @future
    public static void CopyRegion()
    	{
  

        List<org62_pse_Region_c__x> AllRegions = [select ExternalId,Name__c,Status_c__c,pse_Parent_Region_c__c
                                                  from org62_pse_Region_c__x 
                                        where LastModifiedDate__c = LAST_N_DAYS:180];
        
        List<Org62_Regions__c> RegionUpsert = new List<Org62_Regions__c>();
            Map<Id,Id> ParentRegionMap = new Map <Id,Id>();
        
        for (Org62_Regions__c a: [select Id,Org62_Id__c from Org62_Regions__c])
        {
            ParentRegionMap.put(a.Org62_Id__c,a.Id);
  
         }
            
            
        for (integer u=0; u< AllRegions.size();u++)
        {
           System.debug('In the loop');
 
            Org62_Regions__c Reg = new Org62_Regions__c();
            
            Reg.Org62_Id__c = AllRegions[u].ExternalId;
            Reg.Name = AllRegions[u].Name__c.abbreviate(80);
            Reg.Status__c = AllRegions[u].Status_c__c;
            Reg.Parent_Region__c = ParentRegionMap.get(AllRegions[u].pse_Parent_Region_c__c);

               RegionUpsert.add(Reg);
  
         }

            Upsert RegionUpsert Org62_Id__c;

    }

}