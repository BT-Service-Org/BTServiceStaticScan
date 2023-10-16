global class MatrixSummary implements Database.Batchable<sObject>,Schedulable{
    private String Query='select Id,Wks_to_3_Certs__c,' + 
        'Cert_Tech_Arch_Stg_2__c,Cert_Tech_Arch_Stg_3__c,Cert_Admin__c,' + 
        'Cert_Dev__c,Cert_Adv_Admin__c,Cert_Sales_Cloud__c, Cert_Service_Cloud__c,' + 
        'Wks_to_5_Certs__c,Badges_Achieved__c,Current_FY_Util__c,Contact__c,Contact__r.UserId__c,Contact__r.Name,' +
        'Program_Start_Date__c,First_Billable_Date__c ' +
        'from PA_Onboarding__c where Status__c not in (\'External Attrition\',\'Internal Attrition\') and Program__c not in (\'Observer\',\'CTA Prep\')';
        //+ ' and Id = \'a1Y30000000scNe\'';
        //(select Name from Certification_Data__r) 

    global void execute(schedulableContext sc)
    {
        Database.executebatch(this,20);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC,List<sObject> scope)
    {

        System.Debug('Started');
        System.Debug(scope);
        List<PA_Onboarding__c> PAList = (list<PA_Onboarding__c>)scope;        
        List<Individual_Point__c> PointsRecords = new List<Individual_Point__c>();

        Map<String,Performance_Matrix__c> PerfMatrix = new Map<String,Performance_Matrix__c>();

        Map<Id,Id> UserIdMap = new Map <Id,Id>();
            
        Map<Id,Integer> InterviewMap = new Map<Id,Integer>();
        Map<Id,Integer> CsatMap = new Map <Id,Integer> ();
        Map <Id,Double> AvgCSATMap = new Map <Id,Double>();
        Map<Id,Integer> PrimaryCoachMap = new Map <Id,Integer>();

        Map<Id,Integer> CTASessionMap = new Map <Id,Integer>();
        Map<Id,Integer> AddnlCertMap = new Map<Id,Integer> ();
        Map<Id,Integer> cta2certsMap = new Map<Id,Integer> ();
        Map<Id,Datetime> Wks5CertMap = new Map<Id,Datetime> ();

        Map<Id,Integer> NewMentormap = new Map <Id,Integer>();

        Map<Id,Integer> BadgeJudgeMap = new Map <Id,Integer>();
        Map <Id,Integer> BadgeMap = new Map <Id,Integer>();
        Map <Id,Datetime> BadgeTimeMap = new Map <Id,Datetime>();
        

        
        //Loading all the Performance Matrix data in the Map        
        for ( Performance_Matrix__c pf : [select Id,Name,Points__c,
                                          Additional_Parameter__c,Category__c,
                                          Points_Developer_Name__c
                                          from Performance_Matrix__c] ){
             PerfMatrix.put(pf.Points_Developer_Name__c, pf);
            }
        
        //Load Map with Badges Data for time taken to complete badges
        for (AggregateResult badgetime : [select PA_Onboarding__c, Max(Rubric_Pass_Date__c) from 
                                                     Learning_Domain__c where Status__c ='Badged'
                                          and Rubric_Pass_Date__c != null
                                          group by PA_Onboarding__c
                                            ])
        {
      
            BadgeTimeMap.put((Id)badgetime.get('PA_Onboarding__c'), (Datetime)badgetime.get('expr0'));
        }
         
        //Wks to 5 Certs
            for (AggregateResult wks5cert : [select PA_Onboarding__c,max(Original_Certification_Date__c) from Certification_Data__c 
                                                    where Certification_Type_Name__c in 
                                                   ('Certified Administrator','Certified Developer','Certified Advanced Administrator',
                                                   'Certified Service Consultant','Certified Sales Consultant','Certified App Builder')
                                             and Original_Certification_Date__c != null
                                                   group by PA_Onboarding__c])
            {
                Wks5CertMap.put((Id)wks5cert.get('PA_Onboarding__c'),(Datetime)wks5cert.get('expr0'));
            }
        
		for (Matrix_Year__c Yearcalc : [select Start_DateTime__c,End_DateTime__c from Matrix_Year__c])
        {
                DateTime StartDateTime = Yearcalc.Start_DateTime__c;
            	DateTime EndDateTime = Yearcalc.End_DateTime__c;
            	Date StartDate = StartDateTime.Date(); //Yearcalc.Start_Date__c;
        		Date EndDate =  EndDateTime.Date(); // Yearcalc.End_Date__c;

            //Finding Avg to do 5 Certs
            Aggregateresult avg5wkscert =  [select avg(Wks_to_5_Certs__c) from PA_Onboarding__c 
                                                    where Program_Start_Date__c >= :StartDate
                                                and Program_Start_Date__c <= :EndDate
                                            and Wks_to_5_Certs__c > 0
                                                   ];

            //Loading Map with Interview Data
        for (Aggregateresult inter :[select count(Id), Interviewer__c
                                 from Interview__c
                                  where Actual_Interview_Date__c <= :EndDateTime
                                      and Actual_Interview_Date__c >= :StartDateTime
                                     and Interviewer__r.IsActive = true
                                 group by Interviewer__c]
       		)
            
        {
            InterviewMap.put((Id)inter.get('Interviewer__c'),(Integer)inter.get('expr0'));
        }
       
        //Loading Map with Avg CSAT data
        for (AggregateResult avgcsat : [select PA_Onboarding__c , avg (Overall_Score__c) from PA_Customer_Survey__c
                                       where Survey_Completed_Date__c <= :EndDateTime
                                         and Survey_Completed_Date__c >= :StartDateTime
                                       group by PA_Onboarding__c]) 
        {
            AvgCSATMap.put((Id)avgcsat.get('PA_Onboarding__C'),(Double)avgcsat.get('expr0'));
        }
        //Loading Map with 10 CSAT data 
        for (AggregateResult csat10 : [ Select count(Id),PA_Onboarding__c from PA_Customer_Survey__c
                                         where Survey_Completed_Date__c <= :EndDateTime
                                         and Survey_Completed_Date__c >= :StartDateTime
                                         and Overall_Score__c = 10.0
                                     group by PA_Onboarding__c
                            ])
        {
            CsatMap.put((Id)csat10.get('PA_Onboarding__c'),(Integer)csat10.get('expr0'));
        }
        
                        // 9 Domain/CTA 2 Certs
            for (AggregateResult cta2certs : [select PA_Onboarding__c,count(Id) from Certification_Data__c 
                                                    where Certification_Type_Name__c in 
                                                   ('Certified Community Cloud Consultant','Certified Mobile Solutions Architecture Designer',
                                                   'Certified Sharing and Visibility Designer','Certified Identity and Access Management Designer',
                                                   'Certified Development Lifecycle and Deployment Specialist','Certified Integration Architecture Specialist',
                                                   'Certified Data Architecture and Management Specialist','Certified Programmer I')
                                                   and 	Original_Certification_Date__c >=:StartDateTime
                                                   and Original_Certification_Date__c <=:EndDateTime
                                              and Certification_Status__c !='NOT_CERTIFIED'
                                                   group by PA_Onboarding__c])
            {
                cta2certsMap.put((Id)cta2certs.get('PA_Onboarding__c'),(Integer)cta2certs.get('expr0'));
            }
            
            // Additional Certs
            for (AggregateResult addlcerts : [select PA_Onboarding__c,count(Id) from Certification_Data__c 
                                                    where Certification_Type_Name__c in 
                                                   ('Certified Marketing Cloud Email Specialist','Certified Marketing Cloud Social Specialist',
                                                   'Certified Pardot Consultant','Certified Pardot User','Certified Marketing Cloud Consultant',
                                                   'Certified Programmer II')
                                                   and 	Original_Certification_Date__c >=:StartDateTime
                                                   and Original_Certification_Date__c <=:EndDateTime
                                              		and Certification_Status__c !='NOT_CERTIFIED'
                                                   group by PA_Onboarding__c])
            {
                AddnlCertMap.put((Id)addlcerts.get('PA_Onboarding__c'),(Integer)addlcerts.get('expr0'));
            }
            
        //Loading Map for Primary coaches
         for (AggregateResult primarycoach : [select count(Id),Coach__c from CTA_Board_Candidate__c
                                     where Pass_Status__c in('Pass','Pass with Retake')
                                              and Board_Date__c <= :EndDate and Board_Date__c >= :StartDate 
                                              group by Coach__c
                                    	])
        {

                PrimaryCoachMap.put((Id)primarycoach.get('Coach__c'), (Integer)primarycoach.get('expr0'));
        }
        
        //Loading Map with CTA Review Sessions
        for (AggregateResult ctasess : [select count(Id),Evaluator__c from CTA_Review_Session__c
                            where Evaluation_Date__c <= :EndDate and Evaluation_Date__c >= :StartDate
                                        and Status__c = 'Completed'
                                        group by Evaluator__c
                           				])
        
        {
            CTASessionMap.put((Id)ctasess.get('Evaluator__c'),(Integer)ctasess.get('expr0'));
        }
        
        //Load Map with New Mentee data
        for (AggregateResult NewMentors : [select count(id),Mentor__c from PA_Onboarding__c 
                                         where Program_start_date__c >= :StartDate
                                        and Program_Start_Date__c <= :EndDate
                                           and Mentor__c != null
                                           group by Mentor__c
                            ])
        {
            NewMentormap.put((Id)NewMentors.get('Mentor__c'),(Integer)NewMentors.get('expr0') );
        }

        //Load Map with Badge Judge data 

        for (Aggregateresult badgejudge : [select count(Id),Primary_Evaluator__c from Rubric__c
                                      where Evaluation_Date__c <= :EndDate and Evaluation_Date__c >= :StartDate
                           group by Primary_Evaluator__c
                          ])
            {
                BadgeJudgeMap.put((Id)badgejudge.get('Primary_Evaluator__c'),(Integer)badgejudge.get('expr0'));
            }
        
       //Load Map with Badges Data 
        for (AggregateResult badges : [select count(Id),PA_Onboarding__c from 
                                                     Learning_Domain__c where Status__c ='Badged'
                                                   and Rubric_Pass_Date__c > = :StartDateTime 
                                          and Rubric_Pass_Date__c <= :EndDateTime
                                          group by PA_Onboarding__c
                                            ])
        {
            BadgeMap.put((Id)badges.get('PA_Onboarding__c'), (Integer)badges.get('expr0'));
        }
 
        for (PA_Onboarding__c a : PAList)
        {

            if(a.Program_Start_Date__c <= EndDate)
            {
            
                 if (a.Cert_Tech_Arch_Stg_3__c >= StartDate && a.Cert_Tech_Arch_Stg_3__c <= EndDate)
                {
                    Individual_Point__c PointsAdd = new Individual_Point__c();
                    PointsAdd.Value__c= 1;
                    PointsAdd.Advisory_Point_Matrix__c = PerfMatrix.get('CTA Stage 3').Id;
                    PointsAdd.PA_Onboarding__c = a.Id;
                    PointsAdd.Summary_Date__c =  EndDate;
                    PointsRecords.add(PointsAdd);
  
                }
            
                if  (a.Cert_Tech_Arch_Stg_2__c >=StartDate && a.Cert_Tech_Arch_Stg_2__c <= EndDate) 
                {
                   	Individual_Point__c PointsAdd = new Individual_Point__c();
                    PointsAdd.Value__c = 1;
                    PointsAdd.Advisory_Point_Matrix__c =PerfMatrix.get('CTA Stage 2').Id;
                    PointsAdd.PA_Onboarding__c = a.Id;
                    PointsAdd.Summary_Date__c =  EndDate;
                    PointsRecords.add(PointsAdd);
                
            	}     
            	
				if (Wks5CertMap.containsKey(a.Id))
                {
                    Date MaxCertDate =  (Wks5CertMap.get(a.Id)).date();
                    if (a.Wks_to_5_Certs__c <=  (decimal)(avg5wkscert.get('expr0')) && a.Wks_to_5_Certs__c > 0 && MaxCertDate >= StartDate && MaxCertDate <= EndDate )
                        
                    {         
                        Individual_Point__c PointsAdd = new Individual_Point__c();
                        PointsAdd.Value__c = a.Wks_to_5_Certs__c;
                        PointsAdd.Advisory_Point_Matrix__c = PerfMatrix.get('Wks to 5 Certs').Id;
                        PointsAdd.PA_Onboarding__c = a.Id;
                        PointsAdd.Summary_Date__c =  EndDate;
                        PointsRecords.add(PointsAdd);
                    }
                }

                
             	if (BadgeMap.containsKey(a.Id))
            	{
                	Individual_Point__c PointsAdd = new Individual_Point__c();
                    PointsAdd.Value__c =  BadgeMap.get(a.Id);
                    PointsAdd.Advisory_Point_Matrix__c = (PerfMatrix.get('9D Badges').Id);
                    PointsAdd.PA_Onboarding__c = a.Id;
                    PointsAdd.Summary_Date__c =  EndDate;
                    PointsRecords.add(PointsAdd);
            	}       
               
                 if (BadgeTimeMap.containsKey(a.Id) && a.Badges_Achieved__c == 9)
            	{
                	System.debug(BadgeTimeMap.get(a.Id));
                    Date MaxBadgeDate = BadgeTimeMap.get(a.Id).date();
                    System.debug(MaxBadgeDate);
                    if (a.Program_Start_Date__c.MonthsBetween(MaxBadgeDate) <= 9 && MaxBadgeDate > StartDate)
                    {
                    	Individual_Point__c PointsAdd = new Individual_Point__c();
                        PointsAdd.Value__c =  a.Program_Start_Date__c.MonthsBetween(MaxBadgeDate);
                    	PointsAdd.Advisory_Point_Matrix__c = (PerfMatrix.get('9D Badges Quick Complete').Id);
                        PointsAdd.PA_Onboarding__c = a.Id;
                        PointsAdd.Summary_Date__c =  EndDate;
                    	PointsRecords.add(PointsAdd);
                    }
            	}  
                

            	if (a.Cert_Tech_Arch_Stg_3__c !=null && a.Cert_Tech_Arch_Stg_3__c >= StartDate && a.Cert_Tech_Arch_Stg_3__c <= EndDate )
                {
                    Individual_Point__c PointsAdd = new Individual_Point__c();
                    if (a.Program_Start_Date__c.MonthsBetween(a.Cert_Tech_Arch_Stg_3__c) <= PerfMatrix.get('CTA Quick Complete').Additional_Parameter__c && a.Program_Start_Date__c.MonthsBetween(a.Cert_Tech_Arch_Stg_3__c) > 0)
                    {
                        PointsAdd.Value__c = a.Program_Start_Date__c.MonthsBetween(a.Cert_Tech_Arch_Stg_3__c);
                        PointsAdd.CTA_Completed_in_Months__c = a.Program_Start_Date__c.MonthsBetween(a.Cert_Tech_Arch_Stg_3__c);
                        PointsAdd.Advisory_Point_Matrix__c = PerfMatrix.get('CTA Quick Complete').Id;
                        PointsAdd.PA_Onboarding__c = a.Id;
                        PointsAdd.Summary_Date__c =  EndDate;
                        PointsRecords.add(PointsAdd);
                    }
                }

            //Additional Certs    
                
				if (AddnlCertMap.containskey(a.Id))
                {
                                       
                    Individual_Point__c PointsAdd = new Individual_Point__c();
                    PointsAdd.Value__c = AddnlCertMap.get(a.Id);
                    PointsAdd.PA_Onboarding__c = a.Id;
                    PointsAdd.Summary_Date__c =  EndDate;
                	PointsAdd.Advisory_Point_Matrix__c = PerfMatrix.get('Additional Certs').Id;
                    PointsRecords.add(PointsAdd);
 
                }

                       //CTA2 Certs   
                
				if (Cta2CertsMap.containskey(a.Id))
                {
                                       
                    Individual_Point__c PointsAdd = new Individual_Point__c();
                    PointsAdd.Value__c = CTA2CertsMap.get(a.Id);
                    PointsAdd.PA_Onboarding__c = a.Id;
                    PointsAdd.Summary_Date__c =  EndDate;
                	PointsAdd.Advisory_Point_Matrix__c = PerfMatrix.get('CTA2 Certs').Id;
                    PointsRecords.add(PointsAdd);
 
                }
                
        // Customer Success              
           if (CSATMap.containskey(a.Id))
           {
              
				Individual_Point__c PointsAdd = new Individual_Point__c();
				PointsAdd.Value__c= CSATMap.get(a.Id) <=4 ? CSATMap.get(a.Id) : 4;                    
				PointsAdd.PA_Onboarding__c = a.Id;
				PointsAdd.Summary_Date__c =  EndDate;
				PointsAdd.Advisory_Point_Matrix__c = PerfMatrix.get('CSAT=10').Id;
				PointsRecords.add(PointsAdd);
   
           }
           
           //Avg CSAT
           if (AvgCSATMap.containskey(a.Id))
           {
              if (AvgCSATMap.get(a.Id) >= 9)
              {
				Individual_Point__c PointsAdd = new Individual_Point__c();
				PointsAdd.Value__c=AvgCSATMap.get(a.Id);                    
				PointsAdd.PA_Onboarding__c = a.Id;
				PointsAdd.Summary_Date__c =  EndDate;
				PointsAdd.Advisory_Point_Matrix__c = PerfMatrix.get('Above Avg CSAT').Id;
				PointsRecords.add(PointsAdd);
              }
           }

            //Interviews
            
            if (InterviewMap.containsKey(a.Contact__r.userId__c))
            {

                if (InterviewMap.get(a.Contact__r.userId__c) <= 25 )
                {
                	 Individual_Point__c PointsAdd = new Individual_Point__c();
                    PointsAdd.Value__c = InterviewMap.get(a.Contact__r.userId__c);
                	PointsAdd.Advisory_Point_Matrix__c = PerfMatrix.get('Interviews Tier 1').Id;
                    PointsAdd.PA_Onboarding__c = a.Id;
                    PointsAdd.Summary_Date__c =  EndDate;
                    PointsRecords.add(PointsAdd);
				}
                else if(InterviewMap.get(a.Contact__r.userId__c) > 25 )
                {
                    Individual_Point__c PointsAdd = new Individual_Point__c();
                    PointsAdd.Value__c = 25;
                	PointsAdd.Advisory_Point_Matrix__c = PerfMatrix.get('Interviews Tier 1').Id;
                    PointsAdd.PA_Onboarding__c = a.Id;
                    PointsAdd.Summary_Date__c =  EndDate;
                    PointsRecords.add(PointsAdd);
                    
                    Individual_Point__c PointsAdd2 = new Individual_Point__c();
                    PointsAdd2.Value__c = InterviewMap.get(a.Contact__r.userId__c) - 25;
                	PointsAdd2.Advisory_Point_Matrix__c = PerfMatrix.get('Interviews Tier 2').Id;
                    PointsAdd2.PA_Onboarding__c = a.Id;
                    PointsAdd2.Summary_Date__c =  EndDate;
                    PointsRecords.add(PointsAdd2);
                }
   
            }
            
            if (PrimaryCoachMap.containsKey(a.Contact__r.UserId__c))
            {
                Individual_Point__c PointsAdd = new Individual_Point__c();
                PointsAdd.Value__c = PrimaryCoachMap.get(a.Contact__r.UserId__c);
                PointsAdd.Advisory_Point_Matrix__c = PerfMatrix.get('CTA - Primary Coach').Id;    
                PointsAdd.PA_Onboarding__c = a.Id;
                PointsAdd.Summary_Date__c =  EndDate;
                PointsRecords.add(PointsAdd);
    
            }

            if (CTASessionMap.containsKey(a.Contact__r.UserId__c))
            {
                Individual_Point__c PointsAdd = new Individual_Point__c();
				PointsAdd.Value__c = CTASessionMap.get(a.Contact__r.UserId__c);
                PointsAdd.Advisory_Point_Matrix__c= PerfMatrix.get('CTA Review Sessions').Id;
                PointsAdd.PA_Onboarding__c = a.Id;
                PointsAdd.Summary_Date__c =  EndDate;
                PointsRecords.add(PointsAdd);
            }

			//New Mentees
            if (NewMentormap.containskey(a.Contact__r.UserId__c))
            {

				Individual_Point__c PointsAdd = new Individual_Point__c();
                PointsAdd.Value__c = NewMentormap.get(a.Contact__r.UserId__c) ;
            	PointsAdd.Advisory_Point_Matrix__c = PerfMatrix.get('New Mentee').Id;                
                PointsAdd.PA_Onboarding__c = a.Id;
                PointsAdd.Summary_Date__c =  EndDate;
                PointsRecords.add(PointsAdd);
            } 

           //9D Badge Judge points
            if (BadgeJudgeMap.containskey(a.Contact__r.userId__c))
            {
                Individual_Point__c PointsAdd = new Individual_Point__c();
                PointsAdd.Value__c=BadgeJudgeMap.get(a.Contact__r.userId__c);
                PointsAdd.Advisory_Point_Matrix__c = PerfMatrix.get('9D Badges Judge').Id;    
                PointsAdd.PA_Onboarding__c = a.Id;
                PointsAdd.Summary_Date__c =  EndDate;
                PointsRecords.add(PointsAdd);    
            }
            
          } 
       }
        InterviewMap.clear();
        CsatMap.clear();
        AvgCsatMap.clear();
        PrimaryCoachMap.clear();
        CTASessionMap.clear(); 
        NewMentorMap.clear();
        BadgeJudgeMap.clear();
        BadgeMap.clear();
        AddnlCertMap.clear();
        CTA2CertsMap.clear();
            BadgeTimeMap.clear();
            Wks5CertMap.clear();
 
     }
     insert PointsRecords;
}
   
 
global void finish(Database.BatchableContext BC)
    {

    }
}