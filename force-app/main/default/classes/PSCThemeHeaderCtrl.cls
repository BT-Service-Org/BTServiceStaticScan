public class PSCThemeHeaderCtrl {
	@AuraEnabled
	public static String getHeaderNavigationId(String menuName) {
		String setMenuName ;
		if(FeatureManagement.checkPermission('Services_Central_Methodology')){
		   setMenuName  =PSCSettingService.getValue('Navigation_Menu_Name_Methodology'); 
		  }
		else{  
		   setMenuName  =PSCSettingService.getValue('Navigation_Menu_Name');  
		  }
		if(menuName==null ||menuName=='')
		  menuName =setMenuName;
  
			return [SELECT Id
				 FROM ccnavmenus__Menu__c 
				 WHERE Name =:menuName]?.Id;
		}
		
		@AuraEnabled
		public static List<UserCompetencies__c> getUserAchievementData() {
			List<UserCompetencies__c> userachievements = [SELECT Badge_Count__c, Level__r.Name,User__r.FirstName, User__r.LastName, Total_Points__c, Level__c,Current_Level_Completion_Percent__c  
														  FROM UserCompetencies__c 
														  WHERE User__c =: UserInfo.getUserId()
														  LIMIT 1 ];
			return userachievements;                                                                                              
		}
}