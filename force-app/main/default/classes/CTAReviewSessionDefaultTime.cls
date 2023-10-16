public with sharing class CTAReviewSessionDefaultTime {
    
    public static String AttemptTime(String ScenarioName, String RecordTypeName ) {
        
            String AttemptTime ='';
        
           if (ScenarioName.contains('Long') && RecordTypeName.contains(' with Governance') )
           {
                
                AttemptTime = '120 mins';
           }
           else if (ScenarioName.contains('Long') && RecordTypeName.contains(' without Governance') )
           {
                AttemptTime = '90 mins';
           }
           else if (ScenarioName.contains('Short') && RecordTypeName.contains(' with Governance') )
           {
                System.Debug ('Going in this condition');
                AttemptTime = '75 mins';
           }
           else if (ScenarioName.contains('Short') && RecordTypeName.contains(' without Governance') )
           {
                AttemptTime = '60 mins';
           }
            
            return AttemptTime;
    }
    
        public static String PresentTime(String ScenarioName, String RecordTypeName ) {
        
            String PresentTime ='';
        
           if (ScenarioName.contains('Long') && RecordTypeName.contains(' with Governance') )
           {
                
                PresentTime = '45 mins';
           }
           else 
           {
                PresentTime = '30 mins';
           }
            
            return PresentTime;
    }
}