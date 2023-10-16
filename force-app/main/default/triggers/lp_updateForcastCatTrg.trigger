trigger lp_updateForcastCatTrg on lp_Consultant_Milestone__c (after update) {
    
    List<lp_Consultant_Milestone__c> currentML = trigger.new;
    //if(currentML[0].Milestone_Complete__c && currentML[0].Mandatory_Milestone__c){
      //  lp_UpdateForecastCategory.updateForecastCategoryField(currentML);
    //}
    //if(currentML[0].Milestone_Complete__c){
      //  lp_DemoUpdateForecastCategory.updateForecastCategoryField(currentML);
    //}
    //
    if(currentML[0].Milestone_Complete__c){
        lp_ForecastCategoryCalculation.updateForecastCategoryField(currentML);
    }
}