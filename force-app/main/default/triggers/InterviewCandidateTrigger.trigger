trigger InterviewCandidateTrigger on Interview_Candidate__c (before insert, before update) 
{
	if (Trigger.isBefore) 
	{
		Map<string, Interview_Candidate__c> candidateMap = new Map<string, Interview_Candidate__c>();
    	if(Trigger.isInsert)
    	{
    		for(Interview_Candidate__c ic: Trigger.new)
    		{
    			// Name field won't be set yet since workflow sets it
    			string newName = ic.First_Name__c + ' ' + ic.Last_Name__c;
    			if(candidateMap.containsKey(newName))
    			{
    				ic.First_Name__c.addError('A new PA Recruit with the name ' + newName + ' already exists');
    			}
    			else
    			{
    				candidateMap.put(newName, ic);
    			}
    		}
    	}
    	else if(Trigger.isUpdate)
    	{
    		for(Interview_Candidate__c ic: Trigger.new)
    		{
    			Interview_Candidate__c oldIC = Trigger.oldMap.get(ic.Id);
    			if((ic.First_Name__c != oldIC.First_Name__c) || (ic.Last_Name__c != oldIC.Last_Name__c))
    			{
					// Name field won't be set yet since workflow sets it
	    			string newName = ic.First_Name__c + ' ' + ic.Last_Name__c;
	    			if(candidateMap.containsKey(newName))
	    			{
	    				ic.First_Name__c.addError('A new PA Recruit with the name ' + newName + ' already exists');
	    			}
	    			else
	    			{
	    				candidateMap.put(newName, ic);
	    			}
    			}
    		}
    	}
    	if(!candidateMap.isEmpty())
    	{
    		InterviewCandidateUtilities.DetectDuplicates(candidateMap);
    	}
	}
}