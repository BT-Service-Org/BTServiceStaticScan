global class Org62GlobalCompanySync implements Schedulable{

    
    global void execute(SchedulableContext SC) {
        
        Copy360Company();

    }

@future
    public static void Copy360Company()
    {

    List<Company_c__x> AllCompany = [select ExternalId,Name__c,Region_c__c,HQ_Country_c__c,
                                    AE_c__r.Name__c, Success_Lead_c__r.Name__c, AOV_Band_c__c,Rank_c__c,CSM_c__r.Name__c,   
                                    FY17_HT_Region_c__c,FY17_HT_Secondary_Region_c__c,Program_Architects_c__c,
                                    CSE_c__c,   ITC_c__c,PA_CSE_AOV_USD_c__c,ITC_Resources_Count_c__c,
                                     PA_CSE_Pipeline_c__c,CSG_Portfolio_c__c
                                    from Company_c__x
                                    where AOV_Band_c__c in ('$10M-25M',
                                                            '$1M-5M',
                                                            '$25M+',
                                                            '$5M-10M',
                                                            '$200k-600k' ,'$600k-1M')
                                    and RecordTypeId__c ='01230000000ANlGAAW'
                                     
                                    // RecordTypeId__r.DeveloperName__c ='Global'
                                       ];    
    
     List<Global_Company__c> CompUpsert = new List<Global_Company__c>();
        
        
        for (integer u=0; u< AllCompany.size();u++)
        {
           System.debug('In the loop');
 
            Global_Company__c Comp = new Global_Company__c();
            
            Comp.Org62_Id__c = AllCompany[u].ExternalId;
            Comp.Name = AllCompany[u].Name__c.abbreviate(80);
            Comp.Geo__c = AllCompany[u].Region_c__c;
            Comp.HQ_Country__c = AllCompany[u].HQ_Country_c__c;
            Comp.Account_Executive__c = AllCompany[u].AE_c__r.Name__c;
            Comp.Success_Lead__c = AllCompany[u].Success_Lead_c__r.Name__c;
            Comp.Total_Company_AOV_Band__c = AllCompany[u].AOV_Band_c__c;
            Comp.CSM__c= AllCompany[u].CSM_c__r.Name__c;
            Comp.FY17_HT_Region__c= AllCompany[u].FY17_HT_Region_c__c;
            Comp.FY17_HT_Secondary_Region__c= AllCompany[u].FY17_HT_Secondary_Region_c__c;
            Comp.Program_Architects__c= AllCompany[u].Program_Architects_c__c;
            Comp.Business_Architects__c= AllCompany[u].CSE_c__c;
            Comp.ITC_Resources__c = AllCompany[u].ITC_Resources_Count_c__c;
            Comp.Advisory_AOV_USD__c = AllCompany[u].PA_CSE_AOV_USD_c__c;
           Comp.Advisory_Pipeline_USD__c = AllCompany[u].PA_CSE_Pipeline_c__c;
            Comp.CSG_Portfolio__c = AllCompany[u].CSG_Portfolio_c__c;
            
               CompUpsert.add(Comp);
  
            }

            Upsert CompUpsert Org62_Id__c;
            
        delete [select Id from Global_Company__c
        where LastModifiedDate < today];


    }
    
    
}