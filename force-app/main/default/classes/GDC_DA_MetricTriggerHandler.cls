/**
 * @Date   October 2021
 * @Group  Services Org
 * @Description - This class gets called from GDC_DA_Metric Object Trigger.
 */
public class GDC_DA_MetricTriggerHandler {
	
    // Method called from GDC_DA_Metric Object trigger to check access to submit metric record for approval
     /*public static void checkTeamMemberAccessInProject(Map<Id,GDC_DA_Metric__c> oldMap,Map<Id,GDC_DA_Metric__c> newMap)
    {
        try
        {
            Map<String,set<String>> mapProjectAndCurrentUser = new Map<String,set<String>>();
            List<GDC_DA_Metric__c> gdMetricList = new List<GDC_DA_Metric__c>();
            Set<String> projectIds = new Set<String>();
            for(GDC_DA_Metric__c rec :newMap.values())
            {
                if(oldMap.get(rec.Id).Status__c != rec.Status__c  && newMap.get(rec.Id).Status__c=='Submitted for Review')
                {
                    projectIds.add(rec.ProjectName__c);
                }
            }
            
            //get all Team Members related to project
            Set<String> associateTeamMembers = new Set<String>();
            if(projectIds.size()>0)
            {
                for(GDC_DA_Project_Setup__c proj : [select Id, Project_Owner__c from GDC_DA_Project_Setup__c where ID In : projectIds])
                {
                    mapProjectAndCurrentUser.put(proj.Id, new set<String>{proj.Project_Owner__c});
                }
                
                List< GDC_DA_Team_Member__c> teamMemberList  = [Select Id, Project__c, Name__c  from GDC_DA_Team_Member__c where Project__c IN: projectIds];
                for(GDC_DA_Team_Member__c member :teamMemberList)
                {
                 	if(mapProjectAndCurrentUser.containsKey(member.Project__c))
                    {
                       set<string> existValues = mapProjectAndCurrentUser.get(member.Project__c);
                        existValues.add(member.Name__c);
                       mapProjectAndCurrentUser.put(member.Project__c,existValues);                       
                    }
                    else {
                        mapProjectAndCurrentUser.put(member.Project__c, new set<String>{member.Name__c});
                    }
                }
            }
            
             for(GDC_DA_Metric__c rec :newMap.values())
            {
               if(mapProjectAndCurrentUser.containsKey(rec.ProjectName__c))
               {
                   //if(!mapProjectAndCurrentUser.get(rec.ProjectName__c).contains(UserInfo.getUserId()))
                       //rec.addError('Current User Not a part of team member');
               }
            } 
            
        }
        
        catch(Exception e)
        {
            System.debug('Exception Caught-->'+e.getMessage()+' line Number -> '+e.getLineNumber());
        }
        
    }
    */
    
    // Method called from GDC_DA_Metric Object trigger to send rejection mail to teamMembers and geoLead
    /*public static void sendingMail(Map<Id,GDC_DA_Metric__c> oldMap,Map<Id,GDC_DA_Metric__c> newMap) {
        
        try
        {
            Map<String,set<String>> mapProjectAndCurrentUser = new Map<String,set<String>>();
            List<GDC_DA_Metric__c> gdMetricList = new List<GDC_DA_Metric__c>();
            Set<String> projectIds = new Set<String>();
            for(GDC_DA_Metric__c rec :newMap.values())
            {
                if(oldMap.get(rec.Id).Status__c != rec.Status__c  && newMap.get(rec.Id).Status__c=='Approval Rejected')
                {
                    projectIds.add(rec.ProjectName__c);
                }
            }
            
            //get all Team Members related to project
            Set<String> associateTeamMembers = new Set<String>();
            if(projectIds.size()>0)
            {
                for(GDC_DA_Project_Setup__c proj : [select Id, Project_Owner__c,Project_Owner__r.Email
                                                    from GDC_DA_Project_Setup__c where ID In : projectIds])
                {
                    mapProjectAndCurrentUser.put(proj.Id, new set<String>{proj.Project_Owner__r.Email});
                }
                
                List< GDC_DA_Team_Member__c> teamMemberList  = [Select Id, Project__c, Email__c  from GDC_DA_Team_Member__c where Project__c IN: projectIds];
                for(GDC_DA_Team_Member__c member :teamMemberList)
                {
                    if(mapProjectAndCurrentUser.containsKey(member.Project__c))
                    {
                        set<string> existValues = mapProjectAndCurrentUser.get(member.Project__c);
                        existValues.add(member.Email__c);
                        mapProjectAndCurrentUser.put(member.Project__c,existValues);                       
                    }
                    else {
                        mapProjectAndCurrentUser.put(member.Project__c, new set<String>{member.Email__c});
                    }
                }
            }
            
           // List<OrgWideEmailAddress> lstEmailAddress=[select Id,Address from OrgWideEmailAddress 
                                                      // WHERE Address=:label.ApprovalRejectionToAddress];
            
            //Get the Email Template Name
            List<EmailTemplate> template = [SELECT Id, Name, DeveloperName FROM EmailTemplate where DeveloperName ='GDC_DA_RejectionMailTemplateHtml'];
            for(GDC_DA_Metric__c rec :newMap.values())
            {
                if(mapProjectAndCurrentUser.containsKey(rec.ProjectName__c) && mapProjectAndCurrentUser.get(rec.ProjectName__c).size()>0)
                {
                    //if(!mapProjectAndCurrentUser.get(rec.ProjectName__c).contains(UserInfo.getUserId()))
					//	rec.addError('Current User Not a part of team member'); 
                    List<String> allEmails = new List<String>(mapProjectAndCurrentUser.get(rec.ProjectName__c));
                    
                    Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(template[0].Id, UserInfo.getUserId(), rec.Id);
                    String emailSubject = email.getSubject();
                    String emailTextBody = email.getPlainTextBody();
                    email.setTargetObjectId(UserInfo.getUserId());
                    email.setSubject(emailSubject);
                    email.setPlainTextBody(emailTextBody);
                    email.setToAddresses(allEmails);
                    //if(!lstEmailAddress.isEmpty())
                     //email.setOrgWideEmailAddressId(lstEmailAddress[0].Id);
                    email.setTreatTargetObjectAsRecipient(false);
                    Messaging.sendEmail(new List<Messaging.Email>{email});
                }
            } 
        }
        
        catch(Exception e)
        {
            System.debug('Exception Caught-->'+e.getMessage()+' line Number -> '+e.getLineNumber());
        }
        
    }*/
    
    public static void updateProjectStatus(Map<Id,GDC_DA_Metric__c> oldMap,Map<Id,GDC_DA_Metric__c> newMap){
        try{
        List<GDC_DA_Project_Setup__c> lstProjects = new List<GDC_DA_Project_Setup__c>();
        Map<Id,String> mapOfProjectStatus = new Map<Id,String>();
        Map<Id,Date> mapOfMetricStartDate = new Map<Id,Date>();    
         for(GDC_DA_Metric__c rec :newMap.values())
            {
                if(oldMap.get(rec.Id).Status__c != rec.Status__c  && rec.Status__c=='Review Completed')
                {
                    if(rec.ProjectName__c!=null && !mapOfProjectStatus.containsKey(rec.ProjectName__c)){
                        mapOfProjectStatus.put(rec.ProjectName__c,rec.DeliveryAssuranceOverAllCode__c);
                        mapOfMetricStartDate.put(rec.ProjectName__c,rec.StartDate__c);
                    }else{
                        if(rec.StartDate__c!=null && rec.ProjectName__c!=null && mapOfMetricStartDate.containsKey(rec.ProjectName__c) && mapOfMetricStartDate.get(rec.ProjectName__c)<rec.StartDate__c){
                            mapOfProjectStatus.put(rec.ProjectName__c,rec.DeliveryAssuranceOverAllCode__c);
                        	mapOfMetricStartDate.put(rec.ProjectName__c,rec.StartDate__c);
                        }
                    }
                }
            }
            
            for(Id projectId : mapOfProjectStatus.keyset()){
                GDC_DA_Project_Setup__c project = new GDC_DA_Project_Setup__c();
                project.Id = projectId;
                project.ProjectStatusCode__c = mapOfProjectStatus.get(projectId);
                lstProjects.add(project);
            }
            
            update lstProjects;  
        }
        catch(Exception e){
            System.debug('Exception Caught-->'+e.getMessage()+' line Number -> '+e.getLineNumber());
        }
    }
}