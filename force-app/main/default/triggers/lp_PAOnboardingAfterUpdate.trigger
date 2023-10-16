trigger lp_PAOnboardingAfterUpdate on PA_Onboarding__c (after update, after insert) 
{

/**
    About
    -----
    Description: After Update Trigger on Launchpad__c
    Create date: April 2014
    
    Author
    ---------------
    Allan Hasgard Olesen Høybye
    Sandip Dhara
    
    
    Actions/Filters
    ---------------  
    When LaunchPad LearningPath is changed update Consultant Milestones accordingly
    
    Modification History
    --------------------
    06/11/2014 - [SD] Moved this code from Launchpad so that it works off of PA Onboarding
    
    Notes
    -----
    - Using Program Start Date, instead of Learning Path Start Date
    
*/
  
  System.debug(loggingLevel.INFO,'$$ START LaunchPadAfterUpdate ' + trigger.old);
  System.debug(logginglevel.info,'$$ DML getDMLStatements '+Limits.getDMLStatements());
  System.debug(logginglevel.info,'$$ DML getQueries '+Limits.getQueries());
  
  // Container for the updated LaunchPads 
  List<PA_Onboarding__c> lpads = new List<PA_Onboarding__c>();
  
  // Iterate over each Campaign object 
  for (PA_Onboarding__c newlpad : Trigger.new) 
  {    
    System.debug(loggingLevel.INFO,'$$ Examining LaunchPad: ' + newlpad);
    
    if (Trigger.isInsert)
    {
      lpads.add(newlpad);
    }
    else
    {
    
      for (PA_Onboarding__c oldlpad : Trigger.old) 
      {
        if (oldlpad.Id==newlpad.Id && oldlpad.Learning_Path__c!=newlpad.Learning_Path__c)
        {
          System.debug(loggingLevel.INFO,'$$ Changed Learning path for '+newlpad.Name+', '+oldlpad.Learning_Path__c+'->'+newlpad.Learning_Path__c);
          lpads.add(newlpad);
        } else if (oldlpad.Id==newlpad.Id && oldlpad.Program_Start_Date__c!=newlpad.Program_Start_Date__c)
        {
          System.debug(loggingLevel.INFO,'$$ Changed Learning path start date for '+newlpad.Name);
          lpads.add(newlpad);
        }
        break;
      }
    }
  }
     
  if(lpads.size() > 0) {
    System.debug('$$ '+lpads.size()+' Launchpad records sent to service');
    lp_PAOnboarding_SVC.checkForChangedLearningPath(lpads);
  }

}