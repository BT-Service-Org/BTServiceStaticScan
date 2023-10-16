public without sharing class InterviewCandidateUtilities 
{
    // prevent duplicate names
    public static void DetectDuplicates(Map<string, Interview_Candidate__c> candidateMap)
    {
        if(!candidateMap.isEmpty())
        {
            for(Interview_Candidate__c ic: [select Name from Interview_Candidate__c where Name in: candidateMap.KeySet()])
            {
                Interview_Candidate__c newIC = candidateMap.get(ic.Name);
                if (newIC != null) {
                    newIC.First_Name__c.addError('A PA Recruit with the name ' + ic.Name + ' already exists');
                }
            }
        }
    }   
}