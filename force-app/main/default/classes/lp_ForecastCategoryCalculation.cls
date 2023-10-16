/*
 About: This class is used for calculating forecast category

 Modification History
 ------------------  
 2014-08-11:Parag Phanasgaonkar (PP) - 
Modified updateForecastCategoryField for following requirements:
1. Check for all milestones that have a forecast category instead of checking just for mandatory milestones.
2. Update the current forecast category of PA Onboarding record with forecast category of last completed milestone.


 */
public with sharing  class lp_ForecastCategoryCalculation {

    public static void updateForecastCategoryField(List <lp_Consultant_Milestone__c> currentML){
    
    	//get all forecast categories from Forecast Category table
    	LIST<lp_Forecast_Category__c> allForecastCategories = [SELECT Name, lp_Forecast_Category_Number__c, lp_Forecast_Description__c, Id FROM lp_Forecast_Category__c order by lp_Forecast_Category_Number__c];
        ID suggestedFC = null;
        ID intrimFC;
        boolean overallStatus = true;
        Double lpmOrderUsed = 0;
        Double currentLPMOrder = 0;
        
		System.debug('updateForecastCategoryField: Current milestone '+ currentML);
        
        for(lp_Forecast_Category__c lpFC :allForecastCategories)
        {        
            //get all LP milestones from LP Milestone table for each forecast cagetory
            LIST<lp_Learning_Path_Milestone__c> lpMilestones = [SELECT id, Name, Forecast_Category_Number__c, 
                                                                ForecastCategoryName__c, lp_Forecast_Category__c, Order__c 
                                                                FROM lp_Learning_Path_Milestone__c 
                                                                WHERE lp_Forecast_Category__c = :lpFC.id]; 
            
            System.debug('updateForecastCategoryField: LPM retrived as '+ lpMilestones);
        
            //for each LP milestone check consultant milestone completion status
            for(lp_Learning_Path_Milestone__c lpML :lpMilestones){
                currentLPMOrder = lpML.Order__c;
                System.debug('updateForecastCategoryField: currentLPMOrder' + String.valueOf(currentLPMOrder));
                
                LIST<lp_Consultant_Milestone__c> cMilestones = [SELECT Name, Forecast_Category__c, lp_Forecast_Category_New__c, 
                                                                Milestone_Name__c, Learning_Path_Milestone__c, Milestone_Complete__c, 
                                                                Mandatory_Milestone__c, Id 
                                                                FROM lp_Consultant_Milestone__c 
                                                                WHERE Consultant__c = :currentML[0].Consultant__c 
                                                                AND Milestone_Name__c = :lpML.Name
                                                                AND Milestone_Complete__c = TRUE];
                
                System.debug('updateForecastCategoryField: consultant milestones retrived as '+cMilestones);
                
                //check completion status of each milestone from Consultant Milestone table
                for(lp_Consultant_Milestone__c cML :cMilestones)
                {
                    System.debug('updateForecastCategoryField: lpmOrderUsed' + String.valueOf(lpmOrderUsed));
                
                    if (currentLPMOrder > lpmOrderUsed)
                    {
                        suggestedFC = lpFC.id;        
                        lpmOrderUsed = currentLPMOrder;
                    }
                }
            }   
	        intrimFC = lpFC.id;
        }
    

        if(suggestedFC == null){
            System.debug('All milestones for all Forecast Categories complete, final FC as -'+intrimFC);
            suggestedFC = intrimFC;
        }
        
        System.debug('updateForecastCategoryField: Forecast category to be updated' + suggestedFC);
    	//update PA Onboarding record with noted forecast category
        List<PA_Onboarding__c> paOnboard = [SELECT lp_Current_Category__c,lp_Next_Forecast_Category__c, Id FROM PA_Onboarding__c WHERE Contact__c = :currentML[0].Consultant__c]; 

        if(paOnboard != null && paOnboard.size()<>0){
            paOnboard[0].lp_Current_Category__c = suggestedFC;
            update paOnboard;
		}else{
            System.debug('PA Onboarding record not found due to consultant email mismatch');
        }
		
    }
}