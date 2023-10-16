global class PeopleforceSyncRecruit implements schedulable {

      global void execute(SchedulableContext SC) {
        
        CopyRecruits();
        CopyInterviews();

    }
    
    @future
    public static void CopyRecruits()
        {
  
            List<Interview_Candidate__c> RecruitUpsert = new List<Interview_Candidate__c>();

            DateTime Modifyfilter =  System.today().adddays(-10);
            List<IFB_Interview_Candidate_c__x> AllRecruits = [select ExternalId,
                                                                Accepted_Offer_c__c,City_c__c,Name__c,
                                                              Consulting_Interview_Score_c__c,
                                                         First_Screen_Date_c__c,First_Name_c__c,
                                                          First_Screen_to_Hire_c__c,Hire_Date_c__c,Last_Name_c__c,
                                                           Made_Panel_c__c, Panel_Interview_Date_c__c,Passed_Consulting_c__c,
                                                           Passed_Panel_c__c,Passed_Technical_c__c,SIFT_Position_c__C,
                                                           Projected_Start_Date_c__c, Region_c__c,Rejected_c__c,
                                                              Rejected_Offer_c__c,State_c__c, Technical_Interview_Score_c__c,
                                                              Withdrawn_c__c, Years_of_Experience_c__c,Zone_c__c
                                                         from IFB_Interview_Candidate_c__x
                                                        where LastModifiedDate__c >= :Modifyfilter
                                                             ];


        for (integer u=0; u< AllRecruits.size();u++)
        {
           System.debug(u +'---'+ AllRecruits[u].Name__c);
 
            Interview_Candidate__c  newRecruit = new Interview_Candidate__c();         
            newRecruit.Peopleforce_Id__c = AllRecruits[u].ExternalId;
            newRecruit.Accepted_Offer__c= AllRecruits[u].Accepted_Offer_c__c;
            newRecruit.Passed_Consulting__c =AllRecruits[u].Passed_Consulting_c__c;
            newRecruit.Passed_Panel__c =AllRecruits[u].Passed_Panel_c__c;
            newRecruit.Passed_Technical__c=AllRecruits[u].Passed_Technical_c__c;
            newRecruit.Made_Panel__c=AllRecruits[u].Made_Panel_c__c;
            newRecruit.Rejected__c=AllRecruits[u].Rejected_c__c;
            newRecruit.Rejected_Offer__c=AllRecruits[u].Rejected_Offer_c__c;
            newRecruit.Withdrawn__c=AllRecruits[u].Withdrawn_c__c;
            newRecruit.Name = AllRecruits[u].Name__c;
            newRecruit.Position__c = AllRecruits[u].SIFT_Position_c__c;
            newRecruit.First_Screen_Date__c = AllRecruits[u].First_Screen_Date_c__c;
            newRecruit.First_Name__c = AllRecruits[u].First_Name_c__c;
            newRecruit.Last_Name__c = AllRecruits[u].Last_Name_c__c;
            newRecruit.City__c = AllRecruits[u].City_c__c;
            newRecruit.State__c =AllRecruits[u].State_c__c;
            newRecruit.Region__c = AllRecruits[u].Region_c__c;
            newRecruit.Technical_Interview_Score__c =AllRecruits[u].Technical_Interview_Score_c__c;
            newRecruit.Consulting_Interview_Score__c = AllRecruits[u].Consulting_Interview_Score_c__c;
            newRecruit.Panel_Interview_Date__c =AllRecruits[u].Panel_Interview_Date_c__c;
            newRecruit.Hire_Date__c = AllRecruits[u].Hire_Date_c__c;
            newRecruit.Projected_Start_Date__c = AllRecruits[u].Projected_Start_Date_c__c;
            newRecruit.Zone__c =AllRecruits[u].Zone_c__c;
            newRecruit.Years_of_Experience__c = AllRecruits[u].Years_of_Experience_c__c;
            RecruitUpsert.add(newRecruit);
  
         }

            Database.UpsertResult[] results = Database.upsert(RecruitUpsert, Interview_Candidate__c.fields.Peopleforce_Id__c,false);
          
           for (Database.UpsertResult result : results) {
               if (!result.issuccess())
               {
                   Database.Error[] errs = result.getErrors();
                    for (Database.error err : errs)
                   System.debug(err.getStatusCode() + '--' + err.getMessage());
               }
        }


    }
    
         @future
    public static void CopyInterviews()
    {   
        List<Interview__c> InterviewUpsert = new List<Interview__c>();
        DateTime Modifyfilter =  System.today().adddays(-10);
        List<IFB_Interview_c__x> AllInterviews = [select ExternalId,Interview_Type_c__c,Interviewer_c__r.Email__c,
                                                      Actual_Interview_Date_c__c,Candidate_c__c,
                                                               Overall_Interview_Score_c__c, Recommendation_c__c,
                                                               No_Show_c__c,Interview_Format_c__c
                                                  from IFB_Interview_c__x
                                             where LastModifiedDate__c >= :Modifyfilter limit 1000
                                                  ];
        
        //Map<String, schema.RecordTypeInfo> RecordTypeMap=  Interview__c.getSobjectType().getDescribe().getRecordTypeInfosbyName();
        //System.Debug ('MapDetails' + RecordTypeMap);
        
        
        for (integer m=0; m< AllInterviews.size();m++)
        {
 
            Interview__c  newInterview = new Interview__c();
            //String IncomingRecdTypeName =  AllInterviews[m].RecordTypeId__r.Name__c.remove('CSG - ') ;
            //System.debug(IncomingRecdTypeName);
            Interview_Candidate__c ParentRecruit = new Interview_Candidate__c(Peopleforce_Id__c = AllInterviews[m].Candidate_c__c);
            User Interviewer1 = new User(Email = AllInterviews[m].Interviewer_c__r.Email__c);
            
  
           newInterview.Peopleforce_Id__c = AllInterviews[m].ExternalId;
            NewInterview.RecordTypeId = AllInterviews[m].Interview_Type_c__c; //RecordTypeMap.get(IncomingRecdTypeName).getRecordTypeId();
            newInterview.Actual_Interview_Date__c= AllInterviews[m].Actual_Interview_Date_c__c;
            newInterview.Candidate__r = ParentRecruit;
             newInterview.Interviewer__r =Interviewer1;
            newInterview.Overall_Interview_Score__c = AllInterviews[m].Overall_Interview_Score_c__c;
            newInterview.Recommendation__c = AllInterviews[m].Recommendation_c__c;
            newInterview.No_Show__c = AllInterviews[m].No_Show_c__c;
               InterviewUpsert.add(newInterview);
  
         }   
        Database.upsert(InterviewUpsert, Interview__c.fields.Peopleforce_Id__c,false);
            
    }
}