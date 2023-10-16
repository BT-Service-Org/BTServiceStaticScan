public with sharing class ActivityGroupsTemplateController {
    @AuraEnabled(cacheable=false)
    public static List<ActivityGroupWrapper> getActivityGroups(String actGroupId) {
        List<ActivityGroupWrapper> wrapperList = new List<ActivityGroupWrapper>();
        Enablement_Activity_Group__c actGroup = [ SELECT Id, Enablement_Journey__c FROM Enablement_Activity_Group__c WHERE Id = :actGroupId];
        
        List< Enablement_Activity_Group__c > actGrpList =  
            [SELECT  Id, Name, Description__c,Start_Date__c,End_Date__c, LastModifiedById,LastModifiedBy.Name,LastModifiedDate, Hours_Left__c, Order__c,
            Days_Until_Start__c, Days_To_Complete__c
            FROM Enablement_Activity_Group__c
            WHERE Enablement_Journey__c =:actGroup.Enablement_Journey__c order by Order__c 
       ];

        System.debug('actGrpList='+actGrpList);
       if(!actGrpList.isEmpty()){
            for(Enablement_Activity_Group__c temp : actGrpList ) {
                Integer notStartedCount = 0;
                Integer inProgressCount = 0;
                Integer completedCount = 0;
                Integer enableActivityCount = 0;
                Decimal completedHours = 0;
                Decimal hoursRequired = 0;
                Decimal totalHoursRequired = 0;

                ActivityGroupWrapper wrapper = new ActivityGroupWrapper();
                wrapper.Id = temp.Id;
                wrapper.name = temp.Name;

                wrapper.nameUrl = '/' + wrapper.Id;
                wrapper.startDays = Integer.valueOf(temp.Days_Until_Start__c);
                wrapper.duration = Integer.valueOf(temp.Days_To_Complete__c);
                wrapper.order = Integer.valueOf(temp.Order__c);
                wrapperList.add(wrapper); 
            }
       }
        System.debug('wrapperList='+wrapperList);
       return wrapperList;
    }

    public class ActivityGroupWrapper{

        @AuraEnabled public Id Id {get;set;}
        @AuraEnabled public String name{get;set;}
        @AuraEnabled public Integer startDays {get;set;}
        @AuraEnabled public Integer duration {get;set;}
        @AuraEnabled public Integer order {get;set;}

        @AuraEnabled public String nameUrl {get;set;}

    }
}