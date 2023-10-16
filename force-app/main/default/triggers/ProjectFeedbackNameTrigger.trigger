/*
* Name:     ProjectFeedbackNameTrigger
* Author:   Nathan Crosby
*           ncrosby@salesforce.com
*           732-768-3945
* Description:
*       1)  Provide an override of the Project Feedback Name to follow a set standard.
*               Standard = Resource Name - Project Name
*           Trigger will execute both before new records are created, and on existing
*               records when they are updated to correct any past data corruption 
*
*
* History:
*           09/26/2008 - Original creation
*
*/


trigger ProjectFeedbackNameTrigger on Project_Feedback__c (before insert, before update) {
    For (Project_Feedback__c p:Trigger.New){
        
        //RETRIEVE THE PROPER IDS FOR THE RESOURCE AND PROJECT LOOKUPS      
        Id rId = p.Resource_Name__c;
        Id pId = p.Project__c;
        Id userId = UserInfo.getUserId();
        
        //RETRIEVE RESOURCE NAME
        String rName = [select Name from User where Id = :rId].name;
        
        //RETRIEVE PROJECT NAME
        String pName = [select Name from Project_Detail__c where Id = :pId].name;
        
        //SET THE PROJECT FEEDBACK NAME TO THE CORRECT FORMAT
        p.Name = rName + ' - ' + pName;
        //p.Employee_Responsibilities__c = userId;
        
        /*CHANGE THE RECORD OWNER IF THE STATUS EQUALS SUBMITTED TO PM-EM*/
        if((p.Status__c == 'Submitted to PM/EM' || p.Status__c == 'PM/EM Approved') && p.Project_Manager__c == userId){
            //RETRIEVE THE PROPER ID FOR THE PM/EM
            Id pmId = p.Project_Manager__c;
            
            //CHANGE THE RECORD OWNER
            p.OwnerId = pmId;
        }
        /*CHANGE THE RECORD OWNER IF THE STATUS EQUALS COMPLETED*/
        else if (p.Status__c == 'Completed' || p.Status__c == 'Draft'){
            //USE THE SAME RESOURCE NAME ID CAPTURED ABOVE AND UPDATE RECORD OWNER
            p.OwnerId = rId;
            
            //SHARE THE RECORD BACK WITH THE PM/EM
            //Boolean sharingResult = ProjectFeedbackSharing.manualShareAll(p.Id, p.Project_Manager__c);
            //if(sharingResult){
            //  p.Employee_Responsibilities__c = 'Success';
            //}
            //else{
            //  p.Employee_Responsibilities__c = 'Failure';
            //}
            ProjectFeedbackSharing.manualShareAll(p.Id, p.Project_Manager__c);
        }
    }
}