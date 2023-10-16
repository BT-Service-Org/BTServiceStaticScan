public class lpForecastController{
 /*
   Editors:
	Sandip Dhara (SD)
	Parag Phanasgaonkar (PP) 

*/
  map <String, list <string>> forecastLaunchpadMap = new map<String, list <string>>();
  
  public List<lp_PAForecastSummary> forecastSummaryMatrix = new List<lp_PAForecastSummary>();
    
  public List<PA_Onboarding__c> launchPadRecs {get;set;}
  
  public List<lpForecastBean> lpForecastList {get;set;}
  
  public String selectedForecastSection {get;set;}
   
   public lpForecastController()
   {
       /* Modified by SD */
       //populateDummyValues();
       doSearchForecast();
   }
   
    /* 
	PP - This function is called from visual force page when forecast details
     are needed.
	*/
   public PageReference populateLaunchPadRecs(){
    Map<String, Id> existingForeCastCategoriesMap = new Map<String, Id>();    
      for (lp_Forecast_Category__c c : [select Id, Name from lp_Forecast_Category__c]) {
            existingForeCastCategoriesMap.put(c.Name, c.Id);
        } 
     
      System.debug('existingForeCastCategoriesMap : ' + existingForeCastCategoriesMap);
      System.debug('selectedForecastSection :' + selectedForecastSection);
       
     Id selectedForecastCategory;
     String[] selectedInputs  = selectedForecastSection.split('-');
     if (selectedInputs[1] == '1' )
         selectedForecastCategory = existingForeCastCategoriesMap.get('Ramp');
     if (selectedInputs[1] == '2' )
         selectedForecastCategory = existingForeCastCategoriesMap.get('Foundation');
     if (selectedInputs[1] == '3' )
         selectedForecastCategory = existingForeCastCategoriesMap.get('Billable Ready');
     if (selectedInputs[1] == '4' )
         selectedForecastCategory = existingForeCastCategoriesMap.get('PA Ready');
     if (selectedInputs[1] == '5' )
         selectedForecastCategory = existingForeCastCategoriesMap.get('PA Available');
       
       
    
     System.debug('selectedInputs :' + selectedInputs);
//Get all the detail records from PA Onboarding for month and forecast category
       
        launchPadRecs=[select   Contact__r.FirstName
                              , Contact__r.LastName
                              , Contact__r.MailingCity
                              , Contact__c
                              , Learning_Path__c
                              , Learning_Path__r.Name
                              //, Current_Category__c
                              , Forecast_Graduation_Date__c
                              , Days_in_Program__c
                              , Velocity_Status_p__c
                              , Status__c
                              , Contact__r.AccountId
                              , lp_Next_Forecast_Category__c
                       from PA_Onboarding__c
                       where lp_Next_Forecast_Category__c = :selectedForecastCategory
                       and Forecast_Month_Year_Displayed__c = :selectedInputs[0]];
     

     
    return null;
     
   }
   
   
   // New method add by SD to get launchpad data and summarize in wrapper classes - this will replace the dummy data above
   public PageReference doSearchForecast()
   {
       // New Code added by SD     
      Map<String, lpForecastCategory> forecastMap = new Map<String, lpForecastCategory>(); 
	  
      Map<String, Id> existingForeCastCategoriesMap = new Map<String, Id>();    
      for (lp_Forecast_Category__c c : [select Id, Name from lp_Forecast_Category__c]) {
            existingForeCastCategoriesMap.put(c.Name, c.Id);
        } 
       
      //List<Launchpad__c> listLaunchPad = new List<Launchpad__c>();
      List<PA_Onboarding__c> listLaunchPad = [SELECT Id, Name, lp_Next_Forecast_Category__c, Graduation_Month_Year__c, 
                                          Forecast_Month_Year_Displayed__c, Forecast_Graduation_Date__c
                                          FROM PA_Onboarding__c];
		//PP: Commented as there is no field include_in_forecast__c on PA_Onboarding__c object.
       //PP: The above query returns all the records from PA_Onboarding__c object. 
       //This is not ideal and needs to be modified to return records with some kind of filter.
       // 
       //WHERE include_in_forecast__c = 1];
      for (PA_Onboarding__c l : listLaunchPad)
      {
            String monthYear = l.Graduation_Month_Year__c;
            if (forecastMap.get(MonthYear) == null)
            {
                // Add to map
                lpForecastCategory fc = new lpForecastCategory();
                fc.monthYearDisplay = l.Forecast_Month_Year_Displayed__c;
                fc.forecastCategoryId = l.lp_Next_Forecast_Category__c;
                
                if (l.lp_Next_Forecast_Category__c == existingForeCastCategoriesMap.get('Ramp'))
                	fc.baseCerts = 1;
                if (l.lp_Next_Forecast_Category__c == existingForeCastCategoriesMap.get('Foundation'))
                	fc.foundation = 1;    
                if (l.lp_Next_Forecast_Category__c == existingForeCastCategoriesMap.get('Billable Ready'))
                	fc.certified = 1;    
                if (l.lp_Next_Forecast_Category__c == existingForeCastCategoriesMap.get('PA Ready'))
                    fc.projectRole = 1;
                if (l.lp_Next_Forecast_Category__c == existingForeCastCategoriesMap.get('PA Available'))
                    fc.roleReady = 1;
                forecastMap.put(MonthYear, fc);
            }
            else
            {
                // Update map
                lpForecastCategory fc = new lpForecastCategory();
                fc = forecastMap.get(MonthYear);
                 if (l.lp_Next_Forecast_Category__c == existingForeCastCategoriesMap.get('Ramp'))
  					fc.baseCerts = fc.baseCerts + 1; 
                if (l.lp_Next_Forecast_Category__c == existingForeCastCategoriesMap.get('Foundation'))
                    fc.foundation = fc.foundation + 1;
                if (l.lp_Next_Forecast_Category__c == existingForeCastCategoriesMap.get('Billable Ready'))
                    fc.certified = fc.certified + 1;
                if (l.lp_Next_Forecast_Category__c == existingForeCastCategoriesMap.get('PA Ready'))
                    fc.projectRole = fc.projectRole + 1;
                if (l.lp_Next_Forecast_Category__c == existingForeCastCategoriesMap.get('PA Available'))
                    fc.roleReady = fc.roleReady + 1;
                forecastMap.put(MonthYear, fc);
            }
          
           
      }
      
      System.Debug('LaunchPad size: ' + String.valueOf(listLaunchPad.size()));
      System.Debug('Forecast Map: ' + forecastMap);
     
      
      lpForecastList=new List<lpForecastBean>();
      
      // Add to forecast bean for now
      if (!forecastMap.isEmpty())
      {
          Integer i = 0;
          // Sort By Month/Year
          List<String> monthYear = new List<String>();
          monthYear.addAll(forecastMap.keySet());
          monthYear.sort();
          System.Debug('Month/Year: ' + monthYear);
          // Add to forecast bean
          for (String key : monthYear)
          {
              i = i + 1;
              lpForecastBean lpForecastBeanInstance=new lpForecastBean();
              
              // -- May Data --
              //Month string hardcoded     
              lpForecastBeanInstance.rowIndex=string.valueOf(i);
              //lpForecastBeanInstance.month=key;
               lpForecastBeanInstance.month=forecastMap.get(key).monthYearDisplay;
              
              //populate forecast category values
              lpForecastCategory forecastCategoryInstance=new lpForecastCategory();
              forecastCategoryInstance.baseCerts = (forecastMap.get(key).baseCerts == 0) ? null : forecastMap.get(key).baseCerts;
              forecastCategoryInstance.foundation = (forecastMap.get(key).foundation == 0) ? null : forecastMap.get(key).foundation;
              forecastCategoryInstance.certified = (forecastMap.get(key).certified == 0) ? null : forecastMap.get(key).certified;
              forecastCategoryInstance.projectRole = (forecastMap.get(key).projectRole == 0) ? null : forecastMap.get(key).projectRole;
              forecastCategoryInstance.roleReady = (forecastMap.get(key).roleReady == 0) ? null : forecastMap.get(key).roleReady;
               
              //assign the forecast category values to the bean
              lpForecastBeanInstance.lpForecastCategory=forecastCategoryInstance;
              //add the bean to the list.
              lpForecastList.add(lpForecastBeanInstance);
              
          }
      }
      
        System.Debug('Forecast List: ' + lpForecastList);
      //return lpForecastList;
      return null;
   
   }
   
   public boolean getIsSF1()
   {
        if ((ApexPages.currentPage().getParameters().get('sfdcIFrameHost')!=null && ApexPages.currentPage().getParameters().get('sfdcIFrameHost')!='') 
                ||
                (ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')!=null && ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')!='')
                ||
                ApexPages.currentPage().getParameters().get('isdtp') == 'p1' 
                ||
                (ApexPages.currentPage().getParameters().get('retURL') != null && ApexPages.currentPage().getParameters().get('retURL').contains('projectone') ))
        {
            return true;
        }else{
            return false;
        }
   }
   
   // New Class to store PA Forecast Data
   public class lp_PAForecastSummary
   {
      public String cellIndex {get;set;}
      public string monthyear {get;set;}
      public Id forecastCategoryId {get;set;}
  
   }
    
   // New class to store PA Forecast Detail Data
   public class lp_PAForecastDetail
   {
       public String consultant{get;set;}
       public String learningPath{get;set;}
       public String forecastCategory{get;set;}
       public String expectedGradDate{get;set;}
       public String actualGradDate{get;set;}
       public String daysInProgram{get;set;}
       public String currentMilestone{get;set;}
       public String status{get;set;}
       public String availability{get;set;}
       public String link{get;set;}
   }
   
   
}