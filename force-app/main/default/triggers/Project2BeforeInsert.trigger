trigger Project2BeforeInsert on Project2__c (before insert) {
    
    if (!TeamUtil.currentlyExeTrigger) {
        try {   
            
            List<String> queueNames = new List<String>();
            for (Project2__c t : Trigger.new) {
                if(t.Team__c != null) queueNames.add('Project' + t.Team__c);
            }
            
            Map<String, Id> queueMap = new Map<String, Id>();
            for(Group g: [select id, Name from Group where name in: queueNames and type = 'Queue']) {
                
                queueMap.put(g.Name, g.Id);
            }
                
            for (Project2__c t : Trigger.new) {
                if(t.Team__c != null) t.OwnerId = queueMap.get('Project'+ t.Team__c);
            }
            
        } finally {
            TeamUtil.currentlyExeTrigger = false;
        }
    }           
}