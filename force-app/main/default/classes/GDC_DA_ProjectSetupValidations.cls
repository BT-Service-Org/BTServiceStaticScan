/**
* @date   October 2021
* @group  Services Org
* class to handle validations for GDC_AD_ProjectSetup
*/
public class GDC_DA_ProjectSetupValidations {
    public static void handleProjectSetupValidations(Map<Id,GDC_DA_Project_Setup__c> oldRecMap, 
                                                     List<GDC_DA_Project_Setup__c> newRec)
    {
        try
        {
            List<GDC_DA_Project_Setup__c> projList = new List<GDC_DA_Project_Setup__c>();
            Set<String> oldMetricValues = new Set<String>();
            Set<String> newMetricValues = new Set<String>();
            for(GDC_DA_Project_Setup__c rec :newRec)
            {
                system.debug('>>>>' +oldRecMap.get(rec.Id).Metrics_Required__c);
                                system.debug('>>>>' +rec.Metrics_Required__c);
                // Metric Required Previous Values cannot be removed
                if(oldRecMap.get(rec.Id).Metrics_Required__c != rec.Metrics_Required__c && oldRecMap.get(rec.Id).Metrics_Required__c!=null )
                {
                    
                    if(String.isNotBlank(rec.Metrics_Required__c)){
                        if(oldRecMap.get(rec.Id).Metrics_Required__c.contains(';')){
                            oldMetricValues.addAll(oldRecMap.get(rec.Id).Metrics_Required__c.split(';'));  
                        }
                        else{
                            oldMetricValues.add(oldRecMap.get(rec.Id).Metrics_Required__c);    
                        }
                        if(rec.Metrics_Required__c.contains(';')){
                            newMetricValues.addAll(rec.Metrics_Required__c.split(';'));
                        }
                        else{
                            newMetricValues.add(rec.Metrics_Required__c);     
                        }
                        
                        if(!newMetricValues.containsAll(oldMetricValues))
                        {
                            rec.Metrics_Required__c.addError('Previous Metric Values cannot be removed');
                        }
                    }
                    else{
                        rec.Metrics_Required__c.addError('Previous Metric Values cannot be removed');    
                    }
                }
            }
        }
        
        catch(Exception ex){
            system.debug('SFDC GDC_DA_ProjectSetupValidations Exception Catched ' + ex.getMessage() +' at Line# '+ex.getLineNumber());    
        }
        
    }
    
    public static void handleProjectCompletionMetricChanges(Map<Id,GDC_DA_Project_Setup__c> oldRecMap, 
                                                            List<GDC_DA_Project_Setup__c> newRec)
    {
        try
        {
            List<GDC_DA_Metric__c> gdMetricList = new List<GDC_DA_Metric__c>();
            Set<String> projIds = new Set<String>();
            for(GDC_DA_Project_Setup__c rec :newRec)
            {
                if(oldRecMap.get(rec.Id).Is_Project_Completed__c  != rec.Is_Project_Completed__c && oldRecMap.get(rec.Id).Is_Project_Completed__c!=true )
                {
                    projIds.add(rec.Id);
                }
            }
            
            for(GDC_DA_Metric__c gda : [Select Id,ProjectName__c, Status__c,EndDate__c from GDC_DA_Metric__c 
                                        where ProjectName__c in: projIds and EndDate__c >TODAY ])
            {
                gda.Status__c ='Project Completed';
                gdMetricList.add(gda);
            }
            
            if(gdMetricList.size()>0)
                update gdMetricList; 
        }
        catch (Exception ex)
        {
            system.debug('SFDC GDC_DA_ProjectSetupValidations Exception Catched ' + ex.getMessage() +' at Line# '+ex.getLineNumber()); 
        }
    }
    
    //Method created to update GeoLead User in all metric Records
    public static void handleGeoMemberChange(Map<Id,GDC_DA_Project_Setup__c> oldRecMap, 
                                             List<GDC_DA_Project_Setup__c> newRec)
    {
        try
        {
            List<GDC_DA_Metric__c> gdMetricList = new List<GDC_DA_Metric__c>();
            Map<String,String> ProjectAndGeoLeadMap = new Map<String,String>();
            for(GDC_DA_Project_Setup__c rec :newRec)
            {
                if(oldRecMap.get(rec.Id).Project_Owner__c != rec.Project_Owner__c)
                {
                    ProjectAndGeoLeadMap.put(rec.Id,rec.Project_Owner__c);
                }
            }
            
            if(ProjectAndGeoLeadMap.values().size()>0)
            {
                for(GDC_DA_Metric__c gda : [Select Id,ProjectName__c, Status__c,EndDate__c from GDC_DA_Metric__c 
                                            where ProjectName__c in: ProjectAndGeoLeadMap.keySet()])
                {
                    gda.ApprovalUser__c = ProjectAndGeoLeadMap.get(gda.ProjectName__c);
                    gdMetricList.add(gda);
                }
                if(gdMetricList.size()>0)
                    update gdMetricList; 
            }
            
        }
        catch (Exception ex)
        {
            system.debug('GDC_DA_ProjectSetupValidations  Exception Catched ' + ex.getMessage() +' at Line# '+ex.getLineNumber()); 
        }
    }
    
    public static void handleMetricsChanges(Map<Id,GDC_DA_Project_Setup__c> oldRecMap, List<GDC_DA_Project_Setup__c> newRec){
        Map<Id, Set<String>> mapProjectMetrics = new Map<Id, set<String>>();
        for(GDC_DA_Project_Setup__c project : newRec){
            if(project.Metrics_Required__c  != oldRecMap.get(project.Id).Metrics_Required__c){
                Set<String> setMetrics = new Set<String>();
                if(project.Metrics_Required__c != null){
                    if(project.Metrics_Required__c.contains(';')){
                        setMetrics.addAll(project.Metrics_Required__c.split(';'));    
                    }
                    else{
                        setMetrics.add(project.Metrics_Required__c);     
                    }
                }
                mapProjectMetrics.put(project.Id , setMetrics);    
            }
        }
        
        Map<String,String> metricsMap = new Map<String,String>();
        for(GDCDAMetricsRequired__mdt metricrequired : [SELECT Id,MasterLabel, MetricCheckboxField__c from GDCDAMetricsRequired__mdt]){
            metricsMap.put(metricrequired.MasterLabel , metricrequired.MetricCheckboxField__c);
        }
        List<GDC_DA_Metric__c> updateMetrics = new List<GDC_DA_Metric__c>();
        for(GDC_DA_Metric__c  metric : [Select Id,ProjectName__c, ProjectName__r.Metrics_Required__c, Status__c, IsApexTestCoverageSelected__c, IsCodeQualitySelected__c,IsDefectTATSelected__c, IsEffortVarianceSelected__c, 
                                        IsOnTimeDeliverySelected__c,IsPassedTestCasesSelected__c, IsQAEffectivenessSelected__c , 
                                        IsRejectedDefectSelected__c from GDC_DA_Metric__c where ProjectName__c in: mapProjectMetrics.keyset() and Status__c != 'Approved' and EndDate__c > TODAY ]){
                                            for(String str : metricsMap.keyset()){
                                                if(mapProjectMetrics.get(metric.ProjectName__c).contains(str) && metric.get(metricsMap.get(str)) == false){
                                                    metric.put(metricsMap.get(str) , true);  
                                                }
                                            }
                                            updateMetrics.add(metric);
                                        }
        
        if(!updateMetrics.isEmpty()){
            try{
                update updateMetrics;
            }
            catch(Exception e){
                
            }
        }
        
        
        
    }
}