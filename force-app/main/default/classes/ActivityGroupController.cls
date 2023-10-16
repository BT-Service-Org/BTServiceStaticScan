/*  10/08/2021 - VH - This class gets Activity Group and
                    Enablement Activities (EA) tied to it for a
                    specific onboarding Id. Based on EA information,
                    overall status of activity group, percentage is
                    determined and returned in a wrapper class. the
                    wrapper class is used as a foundation to display info
                    in a lightning datatable.
*/
public with sharing class ActivityGroupController {
    @AuraEnabled(cacheable=false)
    public static List<ActivityGroupWrapper> getActivityGroups(String onboardingId) {
        List<ActivityGroupWrapper> wrapperList = new List<ActivityGroupWrapper>();
        System.debug('onboardingId='+onboardingId);
        List< Enablement_Activity_Group__c > actGrpList =  [
            SELECT  Id, Name, Description__c,Start_Date__c,End_Date__c, LastModifiedById,LastModifiedBy.Name,LastModifiedDate, Hours_Left__c,
                    (SELECT Id, Name,Status__c, Actual_Hours_Spent__c,  Hours_Required__c 
                    FROM Enablement_Activities__r )
            FROM Enablement_Activity_Group__c
            WHERE Enablement_Journey__c =: onboardingId order by Order__c 
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
                wrapper.actGrpId = temp.Id;
                wrapper.name = temp.Name;
                wrapper.description = temp.Description__c;
                wrapper.startDate = temp.Start_Date__c;
                wrapper.endDate = temp.End_Date__c;
                wrapper.lastModfiedBy = temp.LastModifiedBy.Name;
                wrapper.lastModifiedDate = temp.LastModifiedDate;
                wrapper.enableActivities = temp.Enablement_Activities__r;
                wrapper.nameUrl = '/' + wrapper.actGrpId;

                if(!wrapper.enableActivities.isEmpty() ){
                    enableActivityCount = wrapper.enableActivities.size();
                    for(Enablement_Activity__c tempEnbAct : wrapper.enableActivities ){

                        //total hours required for each enablement activity
                        if(tempEnbAct.Hours_Required__c != null) {
                            totalHoursRequired += tempEnbAct.Hours_Required__c ;
                        }

                        if( tempEnbAct.Status__c == 'In Progress' ){
                            inProgressCount+= 1;
                        }else if( tempEnbAct.Status__c == 'Not Started' ){
                            notStartedCount+= 1;
                        }else if( tempEnbAct.Status__c == 'Completed' || 
                                  tempEnbAct.Status__c == 'Canceled'  ||
                                  tempEnbAct.Status__c == 'Not Required' )
                        {
                            completedCount+= 1;
                            if(tempEnbAct.Hours_Required__c != null) {
                                completedHours+= tempEnbAct.Hours_Required__c;
                            }
                        }
                    }

                    if(enableActivityCount == completedCount ){
                        wrapper.status = 'Completed';
                    }else if(enableActivityCount == notStartedCount ){
                        wrapper.status = 'Not Started';
                    }else {
                        wrapper.status = 'In Progress';
                    }
                }

                //roll up values to the activity group for display
                wrapper.completedHours = completedHours;
                wrapper.totalHours = totalHoursRequired;

                //calculate percentage
                if( wrapper.totalHours > 0){
                    Decimal percentageBefore = wrapper.completedHours/wrapper.totalHours ;
                    Decimal percentageAfter = percentageBefore.setScale(2) ;
                    wrapper.percentage = percentageAfter * 100 ;
                    if( wrapper.percentage > 75 ){
                        wrapper.style='width:'+wrapper.percentage+'%;background:green;';
                    }
                    else if( wrapper.percentage < 25 ){
                        wrapper.style='width:'+wrapper.percentage+'%;background:#F76F4F;';
                    }
                    else {
                        wrapper.style='width:'+wrapper.percentage+'%;background:gold;';
                    }
                }else{
                    wrapper.percentage = 0;
                    wrapper.style='width:'+wrapper.percentage+'%;background:gold;';
                }
                wrapper.percentageString = 'Hours Left: ' + temp.Hours_Left__c;

                wrapperList.add(wrapper); 
            }
       }
        System.debug('wrapperList='+wrapperList);
       return wrapperList;
    }

    public class ActivityGroupWrapper{

        @AuraEnabled
        public Id actGrpId {get;set;}
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public String description{get;set;}
        @AuraEnabled
        public Date startDate{get;set;}
        @AuraEnabled
        public Date endDate{get;set;}
        @AuraEnabled
        public String lastModfiedBy{get;set;}
        @AuraEnabled
        public Datetime lastModifiedDate{get;set;}
        @AuraEnabled
        public List<Enablement_Activity__c> enableActivities {get;set;}
        @AuraEnabled
        public String status {get;set;}
        @AuraEnabled
        public Integer progress {get;set;}
        @AuraEnabled
        public Decimal totalHours {get;set;}
        @AuraEnabled
        public Decimal completedHours {get;set;}
        @AuraEnabled
        public Decimal percentage {get;set;}
        @AuraEnabled
        public String percentageString {get;set;}
        @AuraEnabled
        public String style {get;set;}
        @AuraEnabled
        public String nameUrl {get;set;}

    }
}