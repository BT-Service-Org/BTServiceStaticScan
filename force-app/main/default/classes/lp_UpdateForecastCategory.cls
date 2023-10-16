public with sharing class lp_UpdateForecastCategory
{
    //this method is only when we dont have forecast category set properly in database, else use the one below
    public static void Demo_UpdateForecastCategoryField(List <lp_Consultant_Milestone__c> currentML){
        boolean overallCATStatus = false;
        System.debug('current ML Forecast_Category__c = '+currentML[0].Forecast_Category__c);
        if(currentML[0].Milestone_Complete__c){
           List<lp_Learning_Path_Milestone__c> lpMilestones = [SELECT id, Name, Forecast_Category_Number__c, ForecastCategoryName__c, lp_Forecast_Category__c FROM lp_Learning_Path_Milestone__c where mandatorymilestone__c = true and lp_Forecast_Category__c = :currentML[0].lp_Forecast_Category_New__c];
                
            System.debug('related LP ML list = = '+lpMilestones);

            for(lp_Learning_Path_Milestone__c nextLPML :lpMilestones){
                List<lp_Consultant_Milestone__c> relatedMLList = [SELECT ID, Milestone_Complete__c, Name, Forecast_Category__c FROM lp_Consultant_Milestone__c where Milestone_Name__c = :lpMilestones[0].name AND Consultant__c = :currentML[0].Consultant__c LIMIT 1];
                if(relatedMLList != null){
                    boolean nextMLStatus = relatedMLList[0].Milestone_Complete__c;
                    if(nextMLStatus != null){
                        if(nextMLStatus == true){
                                overallCATStatus = true;        
                        }else{
                                overallCATStatus = false;
                                System.debug('overall CAT status is set to false = '+overallCATStatus);
                                break;
                        }
                        System.debug('overall CAT status is decided to = '+overallCATStatus);
                	}
            	}
            }//end for loop
            List<PA_Onboarding__c> CATItems = [SELECT lp_Current_Category__c,lp_Next_Forecast_Category__c, Id FROM PA_Onboarding__c WHERE lp_Current_Category__c = :currentML[0].lp_Forecast_Category_New__c AND Contact__c = :currentML[0].Consultant__c]; 
            System.debug('CAT line items retrived is = '+CATItems);
            System.debug('overall CAT status before final update = '+overallCATStatus);

            // SD - THIS NEEDS TO BE FIXED BY WHOMEVER WROTE THIS - THIS CAN NOT GO INTO PRODUCTION THIS WAY
            if(overallCATStatus != null){
                if(CATItems != null && CATItems.size()<>0){
                	if(CATItems[0].lp_Current_Category__c != null){
                    if(CATItems[0].lp_Current_Category__c.equals('a24V000000023w9IAA')){
                        CATItems[0].lp_Current_Category__c = 'a24V000000023wAIAQ';
                        CATItems[0].lp_Next_Forecast_Category__c = 'a24V000000023wBIAQ';
                    }else if(CATItems[0].lp_Current_Category__c.equals('a24V000000023wAIAQ')){
                        CATItems[0].lp_Current_Category__c = 'a24V000000023wBIAQ';
                        CATItems[0].lp_Next_Forecast_Category__c = 'a24V000000023wCIAQ';
                    }else if(CATItems[0].lp_Current_Category__c.equals('a24V000000023wBIAQ')){
                        CATItems[0].lp_Current_Category__c = 'a24V000000023wCIAQ';
                        CATItems[0].lp_Next_Forecast_Category__c = 'a24V000000023wDIAQ';
                    }else if(CATItems[0].lp_Current_Category__c.equals('a24V000000023wCIAQ')){
                        CATItems[0].lp_Current_Category__c = 'a24V000000023wDIAQ';
                        CATItems[0].lp_Next_Forecast_Category__c = 'a24V000000023wDIAQ';
                    }
					
                }else{
                    CATItems[0].lp_Current_Category__c = 'a24V000000023w9IAA';
                    CATItems[0].lp_Next_Forecast_Category__c = 'a24V000000023wAIAQ';
                }
                System.debug('overall current CAT status is set to ='+CATItems[0].lp_Current_Category__c);
                update CATItems;
                }
            }
        } 
    }
    
    //this is the method that should be called from trigger
    public static void updateForecastCategoryField(List <lp_Consultant_Milestone__c> currentML){
        boolean overallCATStatus = false;
        System.debug('current ML Forecast_Category__c = '+currentML[0].Forecast_Category__c);
        if(currentML[0].Milestone_Complete__c && currentML[0].Mandatory_Milestone__c){
           List<lp_Learning_Path_Milestone__c> lpMilestones = [SELECT id, Name, Forecast_Category_Number__c, ForecastCategoryName__c, lp_Forecast_Category__c FROM lp_Learning_Path_Milestone__c where mandatorymilestone__c = true and lp_Forecast_Category__c = :currentML[0].lp_Forecast_Category_New__c];
           //List<lp_Learning_Path_Milestone__c> lpMilestones = [SELECT id, Name, Forecast_Category_Number__c, ForecastCategoryName__c, lp_Forecast_Category__c FROM lp_Learning_Path_Milestone__c where mandatorymilestone__c = true and lp_Forecast_Category__c = :currentML[0].lp_Forecast_Category_New__c and name = :currentML[0].Milestone_Name__c];
           System.debug('related LP ML list = = '+lpMilestones);
           for(lp_Learning_Path_Milestone__c nextLPML :lpMilestones){
               //is matching via name ok?
                List<lp_Consultant_Milestone__c> relatedMLList = [SELECT ID, Milestone_Complete__c, Name, Forecast_Category__c FROM lp_Consultant_Milestone__c where Milestone_Name__c = :nextLPML.name AND Consultant__c = :currentML[0].Consultant__c LIMIT 1];
                if(relatedMLList != null){
                    boolean nextMLStatus = relatedMLList[0].Milestone_Complete__c;
                    if(nextMLStatus != null){
                        if(nextMLStatus == true){
                                overallCATStatus = true;        
                                System.debug('overall CAT status is set to = '+overallCATStatus +'for milestone name = '+nextLPML.name);
                        }else{
                                overallCATStatus = false;
                                System.debug('overall CAT status is set to = '+overallCATStatus +'for milestone name = '+nextLPML.name);
                                break;
                        }
                	}
            	}
            }//end for loop

            if(overallCATStatus){
                List<lp_Learning_Path_Milestone__c> lpNextMilestones;
                if(lpMilestones != null && lpMilestones[0] != null){
                    System.debug('lpMilestones[0].Forecast_Category_Number__c+1 ='+lpMilestones[0].Forecast_Category_Number__c+1);
                    integer mlNum = lpMilestones[0].Forecast_Category_Number__c.intValue() + 1;
                    System.debug('mlNum = '+mlNum);
                    lpNextMilestones = [SELECT ID, lp_Forecast_Category__c, ForecastCategoryName__c, Forecast_Category_Number__c FROM lp_Learning_Path_Milestone__c WHERE Forecast_Category_Number__c = :mlNum AND MandatoryMilestone__c = true];
                    if(lpNextMilestones != null && lpNextMilestones.size()>0){
                       System.debug('Next learning path milestone forecast category is ='+lpNextMilestones[0].lp_Forecast_Category__c); 
                    }else{
                        System.debug('No next forecast category set beyond =' + lpMilestones[0].Forecast_Category_Number__c+ '!'); 
                    }
                }else{
                    System.debug('No next learning path milestone found!'); 
                }
    
                //List<PA_Onboarding__c> CATItems = [SELECT lp_Current_Category__c,lp_Next_Forecast_Category__c, Id FROM PA_Onboarding__c WHERE lp_Current_Category__c = :currentML[0].lp_Forecast_Category_New__c AND Candidate_Email__c = :currentML[0].Consultant__c]; 
                List<PA_Onboarding__c> CATItems = [SELECT lp_Current_Category__c,lp_Next_Forecast_Category__c, Id FROM PA_Onboarding__c WHERE Contact__c = :currentML[0].Consultant__c]; 
                System.debug('CAT line items retrived is = '+CATItems);
                System.debug('Overall CAT status before final update = '+overallCATStatus);
    
                if(overallCATStatus != null && lpNextMilestones != null && lpNextMilestones.size()>0){
                    if(CATItems != null && CATItems.size()<>0){
                        //if(CATItems[0].lp_Current_Category__c != null){
                            CATItems[0].lp_Current_Category__c = lpNextMilestones[0].lp_Forecast_Category__c;
                        //}
                    }else{
                        //do nothing
                        System.debug('Could not find next forecast category');
                    }
                    System.debug('overall current CAT status is set to ='+CATItems[0].lp_Current_Category__c);
                    update CATItems;
                }
            }
        } 
    }
    
}