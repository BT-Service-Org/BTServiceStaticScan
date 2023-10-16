public class GDCDATeamMemberTriggerHandler {
    
    public static void createIndividualMetricItems(List<GDC_DA_Team_Member__c> newTeamMemberRecords)
    {
        Set<Id> projectIds = new Set<Id>();
        Map<Id, List<GDC_DA_Team_Member__c>> teamMembersPerProjectMap = new Map<Id, List<GDC_DA_Team_Member__c>>();
        
        Set<Id> teamMemberIds = new Set<Id>();
        for(GDC_DA_Team_Member__c tm: newTeamMemberRecords){
            if(tm.Project__c != null){
                projectIds.add(tm.Project__c);
                teamMemberIds.add(tm.Id);
            }
        } 
        
        List<GDC_DA_Team_Member__c> teamMembersList = new List<GDC_DA_Team_Member__c>();
        
        if(!teamMemberIds.isEmpty()){
            teamMembersList = [Select Id, Project__c, Name__r.Name, Active__c  from GDC_DA_Team_Member__c Where Id IN:teamMemberIds];    
        }
        List<GDC_DA_Metric__c> metricsList = [Select id, Name, ProjectName__c, ProjectName__r.Metrics_Required__c from GDC_DA_Metric__c where ProjectName__c IN: projectIds];
        
        List<GDC_DA_Metric_Line_Items__c> metricLineItemsList = new List<GDC_DA_Metric_Line_Items__c>();
        if(!metricsList.isEmpty()){
            for(GDC_DA_Team_Member__c tm: teamMembersList){
                if(tm.Active__c == true){
                    for(GDC_DA_Metric__c metric: metricsList){
                        if(tm.Project__c == metric.ProjectName__c){
                            GDC_DA_Metric_Line_Items__c mli = new GDC_DA_Metric_Line_Items__c();
                            mli.GDC_DA_Metric__c = metric.Id;
                            mli.GDC_DA_Team_Member__c = tm.Id;
                            mli.Name = tm.Name__r.Name +' | '+metric.Name;
                            
                            /*if(metric.ProjectName__r.Metrics_Required__c.contains('On Time Delivery (OTD%)')) {
                                mli.IsOnTimeDeliverySelected__c = true;  
                            }
                            if(metric.ProjectName__r.Metrics_Required__c.contains('Effort Variance%')) {
                                mli.IsEffortVarianceSelected__c = true;  
                            }*/
                            if(metric.ProjectName__r.Metrics_Required__c.contains('Apex Test Coverage %')) {
                                mli.IsApexTestCoverageSelected__c = true;  
                            }
                            //if(metric.ProjectName__r.Metrics_Required__c.contains('Defect TAT%')) {
                            //    mli.IsDefectTATSelected__c = true;  
                            //}
                            if(metric.ProjectName__r.Metrics_Required__c.contains('Code Quality%')) {
                                mli.IsCodeQualitySelected__c = true;  
                            }
                            if(metric.ProjectName__r.Metrics_Required__c.contains('Rejected Defect%')) {
                                mli.IsRejectedDefectSelected__c = true;  
                            }
                            /*if(metric.ProjectName__r.Metrics_Required__c.contains('Passed Test Cases%')) {
                                mli.IsPassedTestCasesSelected__c = true;  
                            }
                            if(metric.ProjectName__r.Metrics_Required__c.contains('QA-Effectiveness %')) {
                                mli.IsQAEffectivenessSelected__c = true;  
                            }*/
                            metricLineItemsList.add(mli);
                        }    
                    } 
                }
            }
            
            if(!metricLineItemsList.isEmpty()){
                insert metricLineItemsList;
            }
        }
    }
    
    public static void deleteIndividualMetricItems(List<GDC_DA_Team_Member__c> newTeamMemberRecords, Map<Id, GDC_DA_Team_Member__c> oldRecordsMap)
    {
        Map<Id, Set<String>> projectUsersMap = new Map<Id, Set<String>>();
        Set<Id> usersList = new Set<Id>();
        
        for(GDC_DA_Team_Member__c tm: newTeamMemberRecords){
            GDC_DA_Team_Member__c oldRecord = oldRecordsMap != null ? oldRecordsMap.get(tm.Id) : null;
            if(oldRecord.Active__c != tm.Active__c 
               && tm.Active__c == false){
                   usersList.add(tm.Name__c);
                   if(projectUsersMap.containsKey(tm.Name__c)){
                       Set<String> userIds = projectUsersMap.get(tm.Name__c);
                       userIds.add(tm.Name__c);
                       projectUsersMap.put(tm.Project__c , userIds);
                   }
                   else{
                       projectUsersMap.put(tm.Project__c , new Set<String>{tm.Name__c});    
                   }
               }
        }
        system.debug('projectUsersMap@@@'+ projectUsersMap);
        system.debug('projectUsersMap values@@@'+ projectUsersMap.values());
        system.debug('usersList@@@'+ usersList);
        
        if(!projectUsersMap.values().isEmpty()){
            List<GDC_DA_Metric_Line_Items__c> deleteMetricLineItems = new List<GDC_DA_Metric_Line_Items__c>();
            
            List<GDC_DA_Metric__c> metricsList = [Select Id, StartDate__c, (Select Id, GDC_DA_Team_Member__r.Active__c from GDC_DA_Metric_Line_Items__r 
                                                                            WHERE GDC_DA_Team_Member__r.Name__c IN: usersList
                                                                            AND Start_Date__c >=: System.today()) 
                                                  FROM GDC_DA_Metric__c WHERE ProjectName__c IN: projectUsersMap.keySet()];
            system.debug('metricsList@@@'+ metricsList);
            for(GDC_DA_Metric__c gdm: metricsList){
                system.debug('gdm@@@'+ gdm);
                system.debug('gdm.GDC_DA_Metric_Line_Items__r@@@'+ gdm.GDC_DA_Metric_Line_Items__r);
                
                for(GDC_DA_Metric_Line_Items__c mli: gdm.GDC_DA_Metric_Line_Items__r){
                    system.debug('gdm.StartDate__c@@@'+ gdm.StartDate__c);
                    system.debug('TODAY@@@'+ System.today());
                    if(gdm.StartDate__c > System.today()){
                        deleteMetricLineItems.add(mli);    
                    }  
                }    
            }
            system.debug('deleteMetricLineItems@@@'+ deleteMetricLineItems);
            if(!deleteMetricLineItems.isEmpty()){
                delete deleteMetricLineItems;
            }
            
        }
    }
    
    public static void addIndividualMetricItems(List<GDC_DA_Team_Member__c> newTeamMemberRecords, Map<Id, GDC_DA_Team_Member__c> oldRecordsMap)
    {
        Map<Id, Set<String>> projectUsersMap = new Map<Id, Set<String>>();
        Set<Id> UsersList = new Set<Id>();
        List<GDC_DA_Team_Member__c> qualifiedTMsList = new List<GDC_DA_Team_Member__c>();
        Set<Id> teamMemberIds = new Set<Id>();
        
        for(GDC_DA_Team_Member__c tm: newTeamMemberRecords){
            GDC_DA_Team_Member__c oldRecord = oldRecordsMap != null ? oldRecordsMap.get(tm.Id) : null;
            if(oldRecord.Active__c != tm.Active__c 
               && tm.Active__c == true){
                   qualifiedTMsList.add(tm);
                   UsersList.add(tm.Name__c);
                   teamMemberIds.add(tm.Id);
                   if(projectUsersMap.containsKey(tm.Name__c)){
                       Set<String> userIds = projectUsersMap.get(tm.Name__c);
                       userIds.add(tm.Name__c);
                       projectUsersMap.put(tm.Project__c , userIds);
                   }
                   else{
                       projectUsersMap.put(tm.Project__c , new Set<String>{tm.Name__c});    
                   }
               }
        }
        
        System.debug('qualifiedTMsList@@@' + qualifiedTMsList);
        System.debug('UsersList@@@' + UsersList);
        System.debug('projectUsersMap@@@' + projectUsersMap);
        
        List<GDC_DA_Team_Member__c> teamMembersList = new List<GDC_DA_Team_Member__c>();
        Map<String, String> teamMemberNamesMap = new Map<String, String>();
        
        if(!teamMemberIds.isEmpty()){
            for(GDC_DA_Team_Member__c dtm : [Select Id, Project__c, Name__r.Name 
                                             from GDC_DA_Team_Member__c Where Id IN:teamMemberIds]){
                                                 teamMemberNamesMap.put(dtm.Id, dtm.Name__r.Name);                                     
                                             }    
        }
        
        if(!projectUsersMap.values().isEmpty()){
           
            List<GDC_DA_Metric__c> metricsList = [Select Id, Name, ProjectName__c, 
                                                  ProjectName__r.Metrics_Required__c ,StartDate__c, EndDate__c, 
                                                  (Select Id, GDC_DA_Team_Member__c from GDC_DA_Metric_Line_Items__r 
                                                   WHERE GDC_DA_Team_Member__r.Name__c IN: UsersList 
                                                   AND End_Date__c >=: System.today()) 
                                                  FROM GDC_DA_Metric__c WHERE ProjectName__c IN: projectUsersMap.keySet()
                                                  AND EndDate__c >=: System.today()];
            
            System.debug('metricsList@@@' + metricsList);
            
            Map<String, String> projectTMMap = new Map<String, String>();
            
            for(GDC_DA_Metric__c gdm: metricsList){
                System.debug('gdm.GDC_DA_Metric_Line_Items__r@@@' + gdm.GDC_DA_Metric_Line_Items__r);
                for(GDC_DA_Metric_Line_Items__c mli: gdm.GDC_DA_Metric_Line_Items__r){
                    projectTMMap.put(mli.GDC_DA_Team_Member__c+''+gdm.Id , gdm.ProjectName__c);      
                }    
            }
            
            System.debug('projectTMMap@@@' + projectTMMap);
            
            List<GDC_DA_Metric_Line_Items__c> metricLineItemsList = new List<GDC_DA_Metric_Line_Items__c>();
            
            for(GDC_DA_Team_Member__c tm: qualifiedTMsList){
                for(GDC_DA_Metric__c metric: metricsList){
                    System.debug('tm.Project__c@@@' + tm.Project__c);
                    System.debug('tm.Id@@@' + tm.Id);
                    System.debug('projectTMMap.containsKey(tm.Id)@@@' + projectTMMap.containsKey(tm.Id+''+metric.Id));
                    System.debug('projectTMMap.containsKey(tm.Id)111@@@' + !projectTMMap.containsKey(tm.Id+''+metric.Id));
                    
                    if(tm.Project__c == metric.ProjectName__c && !projectTMMap.containsKey(tm.Id+''+metric.Id)){
                        GDC_DA_Metric_Line_Items__c mli = new GDC_DA_Metric_Line_Items__c();
                        mli.GDC_DA_Metric__c = metric.Id;
                        mli.GDC_DA_Team_Member__c = tm.Id;
                        mli.Name = teamMemberNamesMap.get(tm.Id) +' | '+metric.Name;
                        
                        /*if(metric.ProjectName__r.Metrics_Required__c.contains('On Time Delivery (OTD%)')) {
                            mli.IsOnTimeDeliverySelected__c = true;  
                        }
                        if(metric.ProjectName__r.Metrics_Required__c.contains('Effort Variance%')) {
                            mli.IsEffortVarianceSelected__c = true;  
                        }*/
                        if(metric.ProjectName__r.Metrics_Required__c.contains('Apex Test Coverage %')) {
                            mli.IsApexTestCoverageSelected__c = true;  
                        }
                        //if(metric.ProjectName__r.Metrics_Required__c.contains('Defect TAT%')) {
                        //    mli.IsDefectTATSelected__c = true;  
                        //}
                        if(metric.ProjectName__r.Metrics_Required__c.contains('Code Quality%')) {
                            mli.IsCodeQualitySelected__c = true;  
                        }
                        if(metric.ProjectName__r.Metrics_Required__c.contains('Rejected Defect%')) {
                            mli.IsRejectedDefectSelected__c = true;  
                        }
                        /*if(metric.ProjectName__r.Metrics_Required__c.contains('Passed Test Cases%')) {
                            mli.IsPassedTestCasesSelected__c = true;  
                        }
                        if(metric.ProjectName__r.Metrics_Required__c.contains('QA-Effectiveness %')) {
                            mli.IsQAEffectivenessSelected__c = true;  
                        }*/
                        metricLineItemsList.add(mli);
                    }    
                } 
            }
            System.debug('metricLineItemsList@@@' + metricLineItemsList);
            if(!metricLineItemsList.isEmpty()){
                insert metricLineItemsList;
            }
        }
    }
}