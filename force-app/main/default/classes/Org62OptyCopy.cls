global class Org62OptyCopy implements Schedulable {

    global void execute(SchedulableContext SC) {
        
        CopyOpty();
        CopyAccount();
        CopySWE();

    }

/*    public static void CopyCurrencyRates()
        {
  

        List<CurrencyType__x> AllCurrencyRates = [select ExternalId,IsActive__c,IsoCode__c,DecimalPlaces__c,
                                                  ConversionRate__c from CurrencyType__x 
                                                ];
        
        List<CurrencyType> CurrencyUpsert = new List<CurrencyType>();
        
        
        for (integer u=0; u< AllCurrencyRates.size();u++)
        {
 
            CurrencyType CT = new CurrencyType();
            
            CT.IsoCode = AllCurrencyRates[u].IsoCode__c;
            CT.IsActive = AllCurrencyRates[u].IsActive__c;
            CT.DecimalPlaces = AllCurrencyRates[u].DecimalPlaces__c.Intvalue();
            CT.ConversionRate = AllCurrencyRates[u].ConversionRate__c;

               CurrencyUpsert.add(CT);
  
            }

            Insert CurrencyUpsert;

    }*/

   
    @future
    public static void CopyOpty()
    {
  

        DateTime Modifyfilter =  System.today().adddays(-1);
        Date CloseDatefilter =  System.today().adddays(-30);
        System.debug(Modifyfilter);
        List<Opportunity__x> AllOpty = [select ExternalId,Name__c,Amount__c,AccountId__c,CurrencyISOCode__c,
                                        CloseDate__c, Franchise_c__c, pse_Region_c__c,
                                        CFL_Region_c__c,StageName__c,Next_Steps_c__c, 
                                        Push_Counter_c__c,sfquote_Term_c__C,Type__c, Sub_Type_c__c,Probability__c,Fiscal__c,
                                        Discount_c__c,Overall_Bid_Margin_c__c,Dead_Reason_c__c,
                                        ForecastCategoryName__c,Red_Green_c__c,OwnerId__r.Name__c, Related_License_Oppty_c__c
                                        from Opportunity__x 
                                        where
                                        LastModifiedDate__c >= :Modifyfilter
                                        //LastModifiedDate__c >= 2019-02-01T00:00:00Z and LastModifiedDate__c <= 2019-10-04T00:00:00Z
                                        //and type__c in ('Premier Priority')
                                        and (type__c in ('Program Architect', 'BTA','ITC','Envision','Marketing Cloud Programs',
                                                      'Marketing Cloud Projects','Services Projects','Expeditions','Evergreen',
                                                        'TAM','Marketing Architect','Implementation Architect','Proactive Monitoring',
                                                       'Commerce Cloud Architect','Lightning Boost','Commerce Cloud SRA Advisory',
                                                         'B2B Commerce Cloud SRA Advisory','B2B Commerce Cloud Architect', 'Premier Priority','Order Form','SOW')
                                            OR Type__c like 'Commerce Cloud%Services Project')
                                        and closeDate__c > :CloseDatefilter 
                                       // and closeDate__c > 2017-02-01
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
        
        List<Opportunity> PAOptyUpsert = new List<Opportunity>();
        
        
        for (integer u=0; u< AllOpty.size();u++)
        {
           System.debug('In the loop');
 
            Opportunity PAOpty = new Opportunity();
            
            PAOpty.Org62_Id__c = AllOpty[u].ExternalId;
            PAOpty.Name = AllOpty[u].Name__c.abbreviate(80);
            PAOpty.CFL_Region__c = AllOpty[u].CFL_Region_c__c;
            PAOpty.Region__c = RegionMap.get(AllOpty[u].pse_Region_c__c);
            PAOpty.AccountId = AcctMap.get(AllOpty[u].AccountId__c);
            PAOpty.StageName = AllOpty[u].StageName__c;
            PAOpty.NextStep= AllOpty[u].Next_Steps_c__c;
            PAOpty.Push_Counter__c= AllOpty[u].Push_Counter_c__c;
            PAOpty.Term__c= AllOpty[u].sfquote_Term_c__C;
            PAOpty.CloseDate= AllOpty[u].CloseDate__c;
            PAOpty.Type= AllOpty[u].Type__c;
            PAOpty.Sub_Type__c= AllOpty[u].Sub_Type_c__c;
            PAOpty.Amount = AllOpty[u].Amount__c;
            PAOpty.Franchise__c = AllOpty[u].Franchise_c__c;
            PAOpty.Org62_Account__c = AllOpty[u].AccountId__c;
            PAOpty.Probability = AllOpty[u].Probability__c;
            PAOpty.CurrencyIsoCode = AllOpty[u].CurrencyISOCode__c;
            PAOpty.Fiscal_Period__c = AllOpty[u].Fiscal__c;
            PAOpty.ForecastCategoryName = AllOpty[u].ForecastCategoryName__c;
            PAOPty.Red_Green__c = AllOpty[u].Red_Green_c__c;
            PAOpty.Discount__c = AllOpty[u].Discount_c__c;
            PAOpty.Overall_Bid_Margin__c = AllOpty[u].Overall_Bid_Margin_c__c;
            PAOpty.Org62_Owner__c = AllOpty[u].OwnerId__r.Name__c;
            PAOpty.Related_License_Oppty__c = AllOpty[u].Related_License_Oppty_c__c;
            PAOpty.Dead_Reason__c = AllOpty[u].Dead_Reason_c__c;
            

               PAOptyUpsert.add(PAOpty);
  
            }

            Upsert PAOptyUpsert Org62_Id__c;


    }
    
@future
    public static void CopyAccount()
    {
  
        DateTime Modifyfilter =  System.now().addMinutes(-60) ;
        Map<Id,Id> OptywithoutAccount = new Map <Id,Id>();
        Map<Id,Id> GCMap = new Map<Id,Id>();
        for (Opportunity a : [select Org62_Account__c
                                                   from Opportunity where AccountId = ''
                                                ])
        {
            if (!(OptywithoutAccount.containsKey(a.Org62_Account__c)))
                OptywithoutAccount.put(a.Org62_Account__c,a.Id);
        }
        
        for (Global_Company__c gc: [select Id,Org62_Id__c from Global_Company__c])
        {
            GCMap.put(gc.Org62_Id__c,gc.Id);
        }

        List<Account> newAccounts = new List<Account>();
        List<Account__x> AccountList = [select ExternalId,Name__c,BillingState__c,BillingCountry__c, BillingStreet__c,BillingCity__c,
                                     BillingPostalCode__c,SFDC_Sector_c__c, Sub_Sector_c__c,Industry__c,Region_AOV_Band_c__c,
                                        Global_Company_c__r.Name__c,Region_c__c,AccountStatus_c__c,Type__c,AOV_Band_c__c,CSG_Portfolio_c__c,
                                        CSG_Region_formula_c__c,Global_Company_c__c
                                  from Account__x where ExternalId in :OptywithoutAccount.keySet() 
                                                        // OR (AOV_Band_c__c in ('$5M-10M', '$10M-25M','$25M+','$1M-5M')
                                                                       // and LastModifiedDate__c > :Modifyfilter
                                           
                                       ];
            
        
        
        for (integer u=0; u< AccountList.size();u++)
        {
 
            Account NewAcct = new Account();
            
            NewAcct.Name = AccountList[u].Name__c;
            NewAcct.BillingState = AccountList[u].BillingState__c ;
            NewAcct.BillingCountry = AccountList[u].BillingCountry__c;
            NewAcct.BillingStreet = AccountList[u].BillingStreet__c;
            NewAcct.BillingCity = AccountList[u].BillingCity__c;
            NewAcct.BillingPostalCode = AccountList[u].BillingPostalCode__c;
            NewAcct.Org62_Id__c = AccountList[u].Externalid;
            NewAcct.Industry = AccountList[u].Industry__c;
            NewAcct.Sector__c = AccountList[u].SFDC_Sector_c__c;
            NewAcct.Sub_Sector__c = AccountList[u].Sub_Sector_c__c;
            NewAcct.CSG_Region_AOV_Band__c = AccountList[u].Region_AOV_Band_c__c;
            newAcct.Global_Company_Id__c = GCMap.get(AccountList[u].Global_Company_c__c);
            newAcct.Geo__c = AccountList[u].Region_c__c;
            newAcct.AOV_Band__c = AccountList[u].AOV_Band_c__c;
            NewAcct.Account_Status__c= AccountList[u].AccountStatus_c__c;
            newAcct.Type = AccountList[u].Type__c;
            newAcct.CSG_Region__c = AccountList[u].CSG_Region_formula_c__c;
            newAcct.CSG_Portfolio__c =AccountList[u].CSG_Portfolio_c__c;
               newAccounts.add(NewAcct);
  
            }
            
           Database.upsert(newAccounts, Account.Fields.Org62_id__c, false) ;

    }
    
        @future
    public static void CopySWE()
    {
  
        Map<Id,Id> OptyMap = new Map <Id,Id>();
        DateTime Modifyfilter =  System.today().adddays(-30);

        List<Services_Work_Exception_c__x> AllSWE = [Select ExternalId,Name__c,Anticipated_Work_End_Date_c__c,Approval_Date_c__c,
                                        Business_c__c,Case_Reason_c__c,Completion_Date_c__c,    
                                        Estimated_Hours_c__c,Investment_Category_c__c,Justification_Code_Detail_c__c,
                                        Justification_Code_c__c,Non_rebillable_Expenses_c__c,
                                        Services_Opportunity_c__c,Project_Region_c__c,  Progress_c__c,
                                        Requested_Work_Start_Date_c__c,ROI_Type_c__c, Result_c__c,  
                                        Status_c__c,    Subject_c__c,   SWE_Sponsor_c__r.Name__c,Total_Requested_Value_of_Work_c__c 
                                    from    Services_Work_Exception_c__x where 
                                    Business_c__c = 'Advisory Services'
                                    and Progress_c__c in ('Red Account Save', 'Try Before You Buy')
                                       
                                        //LastModifiedDate__c >= 2017-03-21T00:00:00Z and LastModifiedDate__c <= 2017-03-22T00:00:00Z
                        ];

        
       
        for (Opportunity b: [select Id,Org62_Id__c from Opportunity where (not Name like '%Target') and iswon=false and isclosed=false ])
        {
            OptyMap.put(b.Org62_Id__c,b.Id);
        }
        
        List<Services_Work_Exception__c> SWEUpsert = new List<Services_Work_Exception__c>();
        
        
        for (integer u=0; u< AllSWE.size();u++)
        {
            if (OptyMap.get(AllSWE[u].Services_Opportunity_c__c) != null)
            {
                System.debug('Opty-' + AllSWE[u].Services_Opportunity_c__c + 'Service-' + OptyMap.get(AllSWE[u].Services_Opportunity_c__c));
 
            Services_Work_Exception__c newSWE = new Services_Work_Exception__c();
            
            newSWE.Org62_Id__c = AllSWE[u].ExternalId;
            newSWE.Name = AllSWE[u].Name__c.abbreviate(80);
            newSWE.Anticipated_Work_End_Date__c = AllSWE[u].Anticipated_Work_End_Date_c__c;
          
            newSWE.Opportunity__c = OptyMap.get(AllSWE[u].Services_Opportunity_c__c);
            
            newSWE.Approval_Date__c = AllSWE[u].Approval_Date_c__c;
            newSWE.Business__c= AllSWE[u].Business_c__c;
            newSWE.Subject__c= AllSWE[u].Subject_c__c;
            newSWE.Case_Reason__c= AllSWE[u].Case_Reason_c__c;
            newSWE.Completion_Date__c= AllSWE[u].Completion_Date_c__c;
            newSWE.Estimated_Hours__c= AllSWE[u].Estimated_Hours_c__c;
            newSWE.Investment_Category__c= AllSWE[u].Investment_Category_c__c;
            newSWE.Justification_Code_Detail__c = AllSWE[u].Justification_Code_Detail_c__c;
            newSWE.Justification_Code__c = AllSWE[u].Justification_Code_c__c;
            newSWE.Non_rebillable_Expenses__c = AllSWE[u].Non_rebillable_Expenses_c__c;
            newSWE.Progress__c = AllSWE[u].Progress_c__c;
            newSWE.Requested_Work_Start_Date__c = AllSWE[u].Requested_Work_Start_Date_c__c;
            newSWE.ROI_Type__c = AllSWE[u].ROI_Type_c__c;
            newSWE.Status__c = AllSWE[u].Status_c__c;
            newSWE.SWE_Sponsor__c = AllSWE[u].SWE_Sponsor_c__r.Name__c;
            newSWE.Result__c = AllSWE[u].Result_c__c;
            newSWE.Total_Requested_Value_of_Work__c = AllSWE[u].Total_Requested_Value_of_Work_c__c;
            

               SWEUpsert.add(newSWE);
  
            }
        }
            
            Database.upsert(SWEUpsert,Services_Work_Exception__c.Fields.Org62_Id__c, false);


    }
}