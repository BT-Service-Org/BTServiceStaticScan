/**
 * @Author Mahesh Gunolla - Salesforce.com
 * @Date   October 2021
 * @Group  Services Org
 */
public class GDC_DA_ProjectSetupTriggerHandler {
	
    /**
     *  @name     	 - createDefaultProjectMetrics()
     *  @param    	 - List<GDC_DA_Project_Setup__c> newProjectSetupRecords: GDC_DA Project Setup triggered new values.
     *  @return   	 - N.A.
     *  @description - The method will create default metric.
     **/
    
    public static void createDefaultProjectMetrics(List<GDC_DA_Project_Setup__c> newProjectSetupRecords,Map<Id,GDC_DA_Project_Setup__c> oldMap)
	{
        try{
            List<GDC_DA_Metric__c> metricsRecordsInsert = new List<GDC_DA_Metric__c>();
            Map<Date,Date> metricStartEndDatesMap = new Map<Date,Date>();
            
            for(GDC_DA_Project_Setup__c ps: newProjectSetupRecords){
                if(((oldmap == null && ps.Active__c == true) || (oldmap!=null && ps.Active__c!=oldmap.get(ps.Id).Active__c && ps.Active__c == true)) && String.isNotBlank(ps.Metric_Entry_Interval__c)){
                    Datetime StartDate = DateTime.newInstance(ps.Metric_Entry_Start_Date__c, Time.newInstance(0, 0, 0, 0));
                    Datetime EndDate = DateTime.newInstance(ps.Metric_Entry_End_Date__c, Time.newInstance(0, 0, 0, 0));
                        
                	Integer noOfdays = daysBetweenTwoDatesExcludingWeekends(StartDate, EndDate);
                    Decimal noOfRecords = 0;
                    
                    /*if(ps.Metric_Entry_Interval__c == 'Weekly'){
                    	noOfRecords = ((Decimal)noOfdays/5).round(system.RoundingMode.CEILING);
                        metricStartEndDatesMap = caluclateStartEndDates(StartDate, EndDate, noOfRecords,4);
                    }
                    else*/ if(ps.Metric_Entry_Interval__c == 'Fortnightly'){
                    	noOfRecords = ((Decimal)noOfdays/10).round(system.RoundingMode.CEILING);
                        metricStartEndDatesMap = caluclateStartEndDates(StartDate, EndDate, noOfRecords,9);
				    }
                    /*else if(ps.Metric_Entry_Interval__c == 'Monthly'){
                    	noOfRecords = ((Decimal)noOfdays/22).round(system.RoundingMode.CEILING);
                        metricStartEndDatesMap = caluclateStartEndDates(StartDate, EndDate, noOfRecords,21);
					}*/
                    Integer fr = 01;
                    system.debug('noOfRecords@@@ '+ noOfRecords);
                    system.debug('metricStartEndDatesMap@@@ '+ metricStartEndDatesMap);
                    
                    for(Date strDate : metricStartEndDatesMap.Keyset()){
                        
                        Datetime startDateDT = DateTime.newInstance(strDate, Time.newInstance(0, 0, 0, 0));
                        Datetime enddateDT = DateTime.newInstance(metricStartEndDatesMap.get(strDate), Time.newInstance(0, 0, 0, 0));//date.newinstance(metricStartEndDatesMap.get(strDate).year(), metricStartEndDatesMap.get(strDate).month(), metricStartEndDatesMap.get(strDate).day());
                        
                        String frequency = fr<10 ? String.valueOf(fr).leftPad(2, '0') : String.valueOf(fr);
                    	GDC_DA_Metric__c metric = new GDC_DA_Metric__c();
                        metric.Name = frequency+' | '+ startDateDT.format('dd-MM-yyyy') +' to '+ enddateDT.format('dd-MM-yyyy');
                        metric.ProjectName__c = ps.Id;
                        metric.StartDate__c = strDate;
                        metric.Status__c = 'Draft';
                        metric.EndDate__c = metricStartEndDatesMap.get(strDate);
                        metric.ApprovalUser__c = ps.Project_Owner__c;
                            
                        /*if(ps.Metrics_Required__c.contains('On Time Delivery (OTD%)')) {
                        	metric.IsOnTimeDeliverySelected__c = true;  
                        }
                        if(ps.Metrics_Required__c.contains('Effort Variance%')) {
                        	metric.IsEffortVarianceSelected__c = true;  
                        }*/
                        if(ps.Metrics_Required__c.contains('Apex Test Coverage %')) {
                        	metric.IsApexTestCoverageSelected__c = true;  
                        }
                        //if(ps.Metrics_Required__c.contains('Defect TAT%')) {
                        //	metric.IsDefectTATSelected__c = true;  
                        //}
                        if(ps.Metrics_Required__c.contains('Code Quality%')) {
                        	metric.IsCodeQualitySelected__c = true;  
                        }
                        if(ps.Metrics_Required__c.contains('Rejected Defect%')) {
                        	metric.IsRejectedDefectSelected__c = true;  
                        }
                        /*if(ps.Metrics_Required__c.contains('Passed Test Cases%')) {
                        	metric.IsPassedTestCasesSelected__c = true;  
                        }
                        if(ps.Metrics_Required__c.contains('QA-Effectiveness %')) {
                        	metric.IsQAEffectivenessSelected__c = true;  
                        }*/
                        
                        metricsRecordsInsert.add(metric);
                        fr++;
                    }
                }    
            }
            
            if(!metricsRecordsInsert.isEmpty()){
                insert metricsRecordsInsert;
            }
        }
        catch(Exception ex){
        	system.debug('SFDC GDC_DA_ProjectSetupTriggerHandler createDefaultProjectMetrics Exception Catched ' + ex.getMessage() +' at Line# '+ex.getLineNumber());    
        }
    }
    
    Public static Integer daysBetweenTwoDatesExcludingWeekends(Datetime startdate, Datetime endDate){
        Integer noOfdays =1;
        
        while(startDate < endDate){
            if(startDate.format('EEEE') != 'Saturday' && startDate.format('EEEE') != 'Sunday'){
            	noOfdays = noOfdays +1;     
            }
            startDate = startDate.addDays(1);
        }
        
        system.debug('noOfdays@@@ '+ noOfdays);
        
        return noOfdays;
    }
    
    Public static Map<Date,Date> caluclateStartEndDates(Datetime startdate, Datetime endDate,Decimal nofRecords,Integer frequency){
        
        Map<Date,Date> startEndDatesMap = new Map<Date, Date>();
        Datetime mStartDate;
        Datetime mEndDate ;
        mStartDate = startdate;
        mEndDate = startdate;
        
        system.debug('mStartDate Initial@@ '+ mStartDate);
        system.debug('mStartDate EEE Initial@@ '+ mStartDate.format('EEEE'));
        
        for(Integer i=0; i< nofRecords; i++){
        
            Date sDate;
            Date eDate;
            
            Integer j = 1;
            while(j <= frequency){
                
                system.debug('j Value@@ '+ j);
                system.debug('mStartDate Loop@@ '+ mStartDate);
                system.debug('mStartDate EEE Loop@@ '+ mStartDate.format('EEEE'));
                system.debug('mEndDate Loop@@ '+ mEndDate);
                system.debug('mEndDate Loop@@ '+ mEndDate.format('EEEE'));
                
                if(mEndDate.format('EEEE') == 'Saturday'){
                    mEndDate = mEndDate.addDays(2); 
                    if(mEndDate > endDate){
                    	mEndDate = mEndDate.addDays(-3);     
                    }
                    system.debug('mEndDate sat@@ '+ mEndDate);
                    system.debug('mEndDate EEE Sat@@ '+ mEndDate.format('EEEE'));  
                }else if(mEndDate.format('EEEE') == 'Sunday'){
                    mEndDate = mEndDate.addDays(1); 
                     if(mEndDate > endDate){
                    	mEndDate = mEndDate.addDays(-3);     
                    }
                    system.debug('mEndDate sun@@ '+ mEndDate);
                    system.debug('mEndDate EEE Sun@@ '+ mEndDate.format('EEEE'));
                }
                else{
                    mEndDate = mEndDate.addDays(1);
                    if(mEndDate.format('EEEE') == 'Saturday'){
                    	mEndDate = mEndDate.addDays(2);    
                    }
                    if(mEndDate > endDate){
                       mEndDate = endDate;//mEndDate.addDays(-1);    
                    }
                    system.debug('mEndDate WEEKDAY@@ '+ mEndDate);
                    system.debug('mEndDate EEE WEEKDAY@@ '+ mEndDate.format('EEEE'));
                }
                j++;
            }
            
            sDate = Date.ValueOf(mStartDate);
            eDate = Date.ValueOf(mEndDate);
            
            system.debug('mStartDate sDate@@ '+ mStartDate);
            system.debug('mEndDate eDate@@ '+ mEndDate);
            system.debug('mEndDate eDate@@ '+ eDate);
            
            startEndDatesMap.put(sDate, Date.ValueOf(getTheWeekEndDate(eDate)));
            
            mStartDate = getTheWeekStartDate(eDate.addDays(1));
            system.debug('mStartDate After@@ '+ mStartDate);
            
            mEndDate = getTheWeekEndDate(mStartDate);
            system.debug('mStartDate After@@ '+ mStartDate);
            
            system.debug('mStartDate mEndDate After@@ '+ mEndDate);
        }
        
        system.debug('startEndDatesMap@@@ '+ startEndDatesMap);
        
        return startEndDatesMap;
    }
    
    Public static Datetime getTheWeekStartDate(Datetime startdate){
        system.debug('getTheWeekStartDate EEE@@@ '+ startDate.format('EEEE'));
        if(startDate.format('EEEE') == 'Sunday'){
            startDate = startDate.addDays(1);   
        }
        if(startDate.format('EEEE') == 'Saturday'){
        	startDate = startDate.addDays(2);    
        } 
        
        system.debug('startDate getTheWeekStartDate@@@ '+ startDate);
        
        return startDate;
    }
    
    Public static Datetime getTheWeekEndDate(Datetime endDate){
        system.debug('getTheWeekendDate EEE@@@ '+ endDate.format('EEEE'));
        if(endDate.format('EEEE') == 'Sunday'){
            endDate = endDate.addDays(-2);   
        }
        if(endDate.format('EEEE') == 'Saturday'){
        	endDate = endDate.addDays(-1);    
        } 
        
        system.debug('endDate getTheWeekStartDate@@@ '+ endDate);
        
        return endDate;
    }
    
    /* create project metrics when end date is updated */
    public static void createNewProjectMetrics(Map<Id,GDC_DA_Project_Setup__c> oldRecMap,List<GDC_DA_Project_Setup__c> newProjectSetupRecords)
	{
        try{
            List<GDC_DA_Metric__c> metricsRecordsInsert = new List<GDC_DA_Metric__c>();
            Map<Date,Date> metricStartEndDatesMap = new Map<Date,Date>();
            List<Id> projectIds = new List<Id>();
            
            for(GDC_DA_Project_Setup__c ps: newProjectSetupRecords){
                if(String.isNotBlank(ps.Metric_Entry_Interval__c) && oldRecMap.get(ps.Id).Metric_Entry_End_Date__c!=ps.Metric_Entry_End_Date__c){
                    Datetime StartDate = DateTime.newInstance(oldRecMap.get(ps.Id).Metric_Entry_End_Date__c, Time.newInstance(0, 0, 0, 0));
                    Datetime EndDate = DateTime.newInstance(ps.Metric_Entry_End_Date__c, Time.newInstance(0, 0, 0, 0));
                    projectIds.add(ps.Id);    
                	Integer noOfdays = daysBetweenTwoDatesExcludingWeekends(StartDate, EndDate);
                    Decimal noOfRecords = 0;
                    
                    /*if(ps.Metric_Entry_Interval__c == 'Weekly'){
                    	noOfRecords = ((Decimal)noOfdays/5).round(system.RoundingMode.CEILING);
                        metricStartEndDatesMap = caluclateStartEndDates(StartDate, EndDate, noOfRecords,4);
                    }
                    else*/ if(ps.Metric_Entry_Interval__c == 'Fortnightly'){
                    	noOfRecords = ((Decimal)noOfdays/10).round(system.RoundingMode.CEILING);
                        metricStartEndDatesMap = caluclateStartEndDates(StartDate, EndDate, noOfRecords,9);
				    }
                    /*else if(ps.Metric_Entry_Interval__c == 'Monthly'){
                    	noOfRecords = ((Decimal)noOfdays/22).round(system.RoundingMode.CEILING);
                        metricStartEndDatesMap = caluclateStartEndDates(StartDate, EndDate, noOfRecords,21);
					}*/
                    Integer fr = 01;
                    system.debug('noOfRecords@@@ '+ noOfRecords);
                    system.debug('metricStartEndDatesMap@@@ '+ metricStartEndDatesMap);
                    
                    for(Date strDate : metricStartEndDatesMap.Keyset()){
                        
                        Datetime startDateDT = DateTime.newInstance(strDate, Time.newInstance(0, 0, 0, 0));
                        Datetime enddateDT = DateTime.newInstance(metricStartEndDatesMap.get(strDate), Time.newInstance(0, 0, 0, 0));//date.newinstance(metricStartEndDatesMap.get(strDate).year(), metricStartEndDatesMap.get(strDate).month(), metricStartEndDatesMap.get(strDate).day());
                        
                        String frequency = fr<10 ? String.valueOf(fr).leftPad(2, '0') : String.valueOf(fr);
                    	GDC_DA_Metric__c metric = new GDC_DA_Metric__c();
                        metric.Name = frequency+' | '+ startDateDT.format('dd-MM-yyyy') +' to '+ enddateDT.format('dd-MM-yyyy');
                        metric.ProjectName__c = ps.Id;
                        metric.StartDate__c = strDate;
                        metric.Status__c = 'Draft';
                        metric.EndDate__c = metricStartEndDatesMap.get(strDate);
                        metric.ApprovalUser__c = ps.Project_Owner__c;
                            
                        /*if(ps.Metrics_Required__c.contains('On Time Delivery (OTD%)')) {
                        	metric.IsOnTimeDeliverySelected__c = true;  
                        }
                        if(ps.Metrics_Required__c.contains('Effort Variance%')) {
                        	metric.IsEffortVarianceSelected__c = true;  
                        }*/
                        if(ps.Metrics_Required__c.contains('Apex Test Coverage %')) {
                        	metric.IsApexTestCoverageSelected__c = true;  
                        }
                       // if(ps.Metrics_Required__c.contains('Defect TAT%')) {
                        //	metric.IsDefectTATSelected__c = true;  
                        //}
                        if(ps.Metrics_Required__c.contains('Code Quality%')) {
                        	metric.IsCodeQualitySelected__c = true;  
                        }
                        if(ps.Metrics_Required__c.contains('Rejected Defect%')) {
                        	metric.IsRejectedDefectSelected__c = true;  
                        }
                        /*if(ps.Metrics_Required__c.contains('Passed Test Cases%')) {
                        	metric.IsPassedTestCasesSelected__c = true;  
                        }
                        if(ps.Metrics_Required__c.contains('QA-Effectiveness %')) {
                        	metric.IsQAEffectivenessSelected__c = true;  
                        }*/
                        
                        metricsRecordsInsert.add(metric);
                        fr++;
                    }
                }    
            }
            
            if(!metricsRecordsInsert.isEmpty()){
                insert metricsRecordsInsert;
                List<GDC_DA_Metric__c> metricsList = [Select id, Name, ProjectName__c, ProjectName__r.Metrics_Required__c from GDC_DA_Metric__c where ID IN: metricsRecordsInsert];
                List<GDC_DA_Team_Member__c> lstTeamMembers = [SELECT id, Project__c,Name__r.Name  from GDC_DA_Team_Member__c where Project__c in: projectIds and Active__c=true ];
                createIndividualMetrics(lstTeamMembers,metricsList);
            }
        }
        catch(Exception ex){
        	system.debug('SFDC GDC_DA_ProjectSetupTriggerHandler createDefaultProjectMetrics Exception Catched ' + ex.getMessage() +' at Line# '+ex.getLineNumber());    
        }
    }
    
    public static void createIndividualMetrics(List<GDC_DA_Team_Member__c> teamMembersList,List<GDC_DA_Metric__c> metricsList){
        List<GDC_DA_Metric_Line_Items__c> metricLineItemsList = new List<GDC_DA_Metric_Line_Items__c>();
        
        for(GDC_DA_Team_Member__c tm: teamMembersList){
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
            
            if(!metricLineItemsList.isEmpty()){
                insert metricLineItemsList;
            }
    }
    
    public static void activateTeamMembers(List<GDC_DA_Project_Setup__c> newRecords,Map<Id,GDC_DA_Project_Setup__c> oldMap)
	{	
        try{
            List<Id> projectIds = new List<Id>();
            for(GDC_DA_Project_Setup__c project: newRecords){
                if((oldMap==null && project.Active__c == true) || (oldMap!=null && project.Active__c!=oldMap.get(project.Id).Active__c && project.Active__c == true)){
                    projectIds.add(project.Id);
                }
                    
            }
            
            List<GDC_DA_Team_Member__c> teamMembersList = [Select Id, Project__c,Start_Date__c ,End_Date__c,Active__c  from GDC_DA_Team_Member__c Where Project__c =:projectIds and Active__c = false]; 
            
            if(teamMembersList.size()>0){
                for(GDC_DA_Team_Member__c member: teamMembersList){
                    if(member.Start_Date__c <= System.today() && member.End_Date__c > System.today()){
                        member.Active__c = true;
                    }            
                }
                
                update teamMembersList;
            }
        }
        catch(Exception ex){
        	system.debug('SFDC GDC_DA_ProjectSetupTriggerHandler activateTeamMembers Exception Catched ' + ex.getMessage() +' at Line# '+ex.getLineNumber());    
        }
        
    }
    
    public static void deactivateTeamMembers(List<GDC_DA_Project_Setup__c> newRecords,Map<Id,GDC_DA_Project_Setup__c> oldMap)
	{
        try{            
            List<Id> projectIds = new List<Id>();
            for(GDC_DA_Project_Setup__c project: newRecords){
                if(oldMap!=null && project.Active__c!=oldMap.get(project.Id).Active__c && project.Active__c == false){
                    projectIds.add(project.Id);
                }
                    
            }
            
            List<GDC_DA_Team_Member__c> teamMembersList = [Select Id,Active__c  from GDC_DA_Team_Member__c Where Project__c =:projectIds and Active__c = true]; 
            
            if(teamMembersList.size()>0){
                
                for(GDC_DA_Team_Member__c member: teamMembersList){
                        member.Active__c = false;
                }
                
                update teamMembersList;
            }
        }
        catch(Exception ex){
        	system.debug('SFDC GDC_DA_ProjectSetupTriggerHandler deactivateTeamMembers Exception Catched ' + ex.getMessage() +' at Line# '+ex.getLineNumber());    
        }
        
    }
    
}