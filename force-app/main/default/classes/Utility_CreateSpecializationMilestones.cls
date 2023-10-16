public class Utility_CreateSpecializationMilestones {
    
    //Create new milestone for specialization
    public static void createSpecializationMilestones(String specialization, Learning_Domain__c domainrecord){
        List<CMT_Specialization_Milestone__mdt> milestones = [select MasterLabel, Sequence_Order__c from CMT_Specialization_Milestone__mdt where Specialization__c =: specialization order by Sequence_Order__c ];
        List<Specialization_Milestone__c> newspecmilestones = new List<Specialization_Milestone__c>();
        
        Date todaysdate = Date.today();
        Integer totalnoofdaystocomplete = todaysdate.daysBetween(domainrecord.Target_End_Date__c);
        Integer noofdaystocompletecurrentmilestone;
        try{
            if(milestones.size() > 0){
                for(CMT_Specialization_Milestone__mdt milestone :  milestones){
                    Specialization_Milestone__c newspecmilestone = new Specialization_Milestone__c();
                    newspecmilestone.Name = milestone.MasterLabel;
                    newspecmilestone.User__c = UserInfo.getUserId();
                    Decimal seqorder = milestone.Sequence_Order__c;
                    noofdaystocompletecurrentmilestone = Math.round( ( ( seqorder.divide(milestones.size(), 2) ) * totalnoofdaystocomplete )	);
                    newspecmilestone.Due_Date__c = todaysdate.addDays( noofdaystocompletecurrentmilestone );
                    newspecmilestone.Learning_Domain__c = domainrecord.Id;
                    newspecmilestones.add(newspecmilestone);
                }
                insert newspecmilestones;
            }
        }catch(Exception e){
            throw e;
        }
    }
    
    //Update milestone dates based on the new target date
    public static void updateSpecializationMilestones(String specialization, Learning_Domain__c domainrecord){
       // List<CMT_Specialization_Tracking__mdt> milestones = [select MasterLabel, Sequence_Order__c from CMT_Specialization_Tracking__mdt where Specialization__c =: specialization order by Sequence_Order__c ];
        List<Specialization_Milestone__c> specmilestones = [select Due_Date__c  from Specialization_Milestone__c where Learning_Domain__c =: domainrecord.Id and Completed__c = false order by Due_Date__c asc];
        List<Specialization_Milestone__c> updatedspecmilestones = new List<Specialization_Milestone__c>();
        
        Date todaysdate = Date.today();
        Integer totalnoofdaystocomplete = todaysdate.daysBetween(domainrecord.Target_End_Date__c);
        Integer noofdaystocompletecurrentmilestone;
        try{
            system.debug('no of specmilestones records == ' + specmilestones.size() );
            system.debug('total no of days == ' + totalnoofdaystocomplete );
            if(specmilestones.size() > 0){
                Decimal sequenceorder=1;
                for(Specialization_Milestone__c specmilestone :  specmilestones){
                    noofdaystocompletecurrentmilestone = Math.round( ( (sequenceorder.divide(specmilestones.size(), 2)) * totalnoofdaystocomplete )	);
                    system.debug('noofdaystocompletecurrentmilestone ==' + noofdaystocompletecurrentmilestone);
                    system.debug('sequenceorder ==' + sequenceorder);
                    specmilestone.Due_Date__c = todaysdate.addDays( noofdaystocompletecurrentmilestone );
                    updatedspecmilestones.add(specmilestone);
                    sequenceorder++;
                }  
                update updatedspecmilestones;
            }
        }catch(Exception e){
            throw e;
        }
    }
}