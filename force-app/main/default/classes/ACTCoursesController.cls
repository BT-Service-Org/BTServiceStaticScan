public without sharing class ACTCoursesController {

    @AuraEnabled
    public static String getMyLearnerProfileId(){
        
        try {
            String runningUserEmail = UserInfo.getUserEmail();

            Org62_User__x org62User = [SELECT ExternalId, Email__c, EmployeeNumber__c FROM Org62_User__x WHERE Email__c = :runningUserEmail ORDER BY EmployeeNumber__c ASC NULLS LAST LIMIT 1];

            slj_Learner_Profile_c__x myProfile;

            myProfile = [SELECT Employee_ID_c__c,
                            ExternalId,
                            Name__c,
                            Org62_User_ID_c__c,
                            slj_User_c__c
                            FROM slj_Learner_Profile_c__x
                            WHERE Org62_User_ID_c__c = :org62User.ExternalId
                            LIMIT 1];

            return myProfile.ExternalId;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<ACTWrapper> getMyAssignedCourses(String userId) {
        
        try {
            List<slj_Assigned_Path_c__x> myCourses;

            myCourses = [SELECT slj_Learning_Path_c__c, 
                            ExternalId, 
                            slj_Learner_Profile_c__c, 
                            slj_User_c__c, 
                            slj_Completed_c__c, 
                            IsDeleted__c, 
                            slj_Due_Date_c__c,
                            slj_Number_of_Assignments_c__c,
                            slj_Number_of_Completed_Assignments_c__c,
                            slj_Number_of_Completed_Required_Assignm__c,
                            slj_Number_of_Required_Assignments_c__c,
                            slj_Order_c__c
                            FROM slj_Assigned_Path_c__x
                            WHERE slj_Learner_Profile_c__c = :userId];
            //for (slj_Assigned_Path_c__x aPath : myCourses) {
            //    System.debug(aPath);
            //}
            
            List<String> courseIds = new List<String>();
            for (slj_Assigned_Path_c__x path : myCourses) {
                courseIds.add(path.slj_Learning_Path_c__c);
            }
            //System.debug(courseIds);
            try {
                List<slj_Learning_Path_c__x> coursesList;
                coursesList= [SELECT Name__c ,
                             slj_Description_c__c,
                             ExternalId 
                     FROM slj_Learning_Path_c__x 
                     WHERE ExternalId IN :courseIds];

                //System.debug(coursesList);
                List<ACTWrapper>wrapped = new List<ACTWrapper>();

                for (slj_Assigned_Path_c__x aPath : myCourses) {
                    for (slj_Learning_Path_c__x lPath: coursesList) {
                        if (lPath.ExternalId == aPath.slj_Learning_Path_c__c) {
                            Decimal progress = aPath.slj_Number_of_Completed_Assignments_c__c / aPath.slj_Number_of_Assignments_c__c;
                            Boolean isCompleted = false;
                            if (aPath.slj_Number_of_Completed_Assignments_c__c == aPath.slj_Number_of_Assignments_c__c) {
                                isCompleted = true;
                            }
                            ACTWrapper wrapper = new ACTWrapper(lPath.Name__c, lPath.slj_Description_c__c, progress, isCompleted, aPath.slj_Due_Date_c__c);
                            //System.debug(wrapper);
                            wrapped.add(wrapper);
                        }
                    }
                }

                // Sort by overdue, then days left, then completed
                wrapped.sort();
                List<ACTWrapper>incompleteWrapped = new List<ACTWrapper>();
                List<ACTWrapper>completedWrapped = new List<ACTWrapper>();
                for (ACTWrapper wrap : wrapped) {
                    if (wrap.isCompleted) {
                        completedWrapped.add(wrap);
                    } else {
                        incompleteWrapped.add(wrap);
                    }
                }
                wrapped.clear();
                wrapped.addAll(incompleteWrapped);
                wrapped.addAll(completedWrapped);

                return wrapped;
            } catch (Exception e1) {
                throw new AuraHandledException(e1.getMessage());
            }
        } catch (Exception e2) {
            throw new AuraHandledException(e2.getMessage());
        }
    }
    /*
@AuraEnabled
    public static List<slj_Learning_Path_c__x> getCourses() {
        // Perform isAccessible() checking first, then
      List<slj_Learning_Path_c__x> coursesList;

       coursesList= [SELECT Name__c ,
                     		slj_Description_c__c 
                     FROM slj_Learning_Path_c__x 
                     where slj_Description_c__c != ''LIMIT 10];
        system.debug('courses List'+coursesList);
        return coursesList;
        
    }
    @AuraEnabled
   public static List<Integer> getLeftDays( ) {
        //     public static List<Integer> getLeftDays(ID ) {

        Date todaysDate = System.today();
//Date todaysDateStr = todaysDate.format('yyyy-MM-dd');
System.debug(todaysDate);
List<Integer> leftDays=new List<Integer>();
List<slj_Assignment_c__x> leftDaysCourses;

     leftDaysCourses= [SELECT slj_Due_Date_c__c
                     FROM slj_Assignment_c__x 
                     where OwnerId__c= '0052E00000LSXVgQAP'LIMIT 10];
        system.debug('left Days Courses'+leftDaysCourses);
        
        for (Integer i=0;i<leftDaysCourses.size();i++) {
            Date dueDate=leftDaysCourses[i].slj_Due_Date_c__c;
            System.debug('dueDate'+dueDate);
			Integer numberDaysDue = todaysDate.daysBetween(dueDate);
            System.debug('numberDaysDue'+numberDaysDue);
			leftDays.add(numberDaysDue);
}
            System.debug('list of integers'+leftDays);
        return leftDays;
        
    }
    */
}