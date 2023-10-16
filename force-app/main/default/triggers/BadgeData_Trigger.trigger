trigger BadgeData_Trigger on Badge_Data__c (before update, before insert) {
/*
    Update the contact with the onboarding records contact
*/
    if (trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) {
        
        // query the parent pa onboarding and populate contact
        Set<Id> paOnboardIdSet = new Set<Id>();
        
        for (Badge_Data__c bd : trigger.new) {
            if (bd.PA_Onboarding__c != null)  
                paOnboardIdSet.add(bd.PA_Onboarding__c);
        
        
            if (trigger.isUpdate) {
                // Access the "old" record by its ID in Trigger.oldMap
                Badge_Data__c oldBd = Trigger.oldMap.get(bd.Id);
                System.debug('oldBd ' + oldBd);
                // Trigger.new records are conveniently the "new" versions!
                Boolean oldRequired = oldBd.X90_day_learning_path__c;
                Boolean newRequired = bd.X90_day_learning_path__c;
                System.debug('old ' + oldRequired + ' new ' + newRequired);
                // Check that the field was changed to the correct value
                if (!oldRequired && newRequired) {
                    bd.Date_Assigned__c = System.Today();
                } 
                
                  
            }
        }
        
        Map<Id, PA_Onboarding__c> paMap = new Map<ID, PA_Onboarding__c>([SELECT Id, Contact__c 
                                                    FROM PA_Onboarding__c
                                                    WHERE Id in :paOnboardIdSet]);
        system.debug('<== paMap');
        system.debug(paMap);                                            
        for (Badge_Data__c bd : trigger.new) {              
            PA_Onboarding__c pa = paMap.get(bd.PA_Onboarding__c);
            if (pa != null)
                bd.Contact__c = paMap.get(bd.PA_Onboarding__c).Contact__c;
        }
        
    }

}