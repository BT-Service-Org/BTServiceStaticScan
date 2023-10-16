public class weekHoursEntry_Controller {
    // properties -------------------------------------------------------------
    private String strSOWId {private get; private set;}
    private Date dtLastWeekEnding {private get; private set;}
    public List<Resource_Schedule_Week__c> schedWeeks {get; set;}
    public String strLastWeekEnding {get; set;}

    // controller -------------------------------------------------------------
    public weekHoursEntry_Controller() {
        // get the querystring parms
        System.debug('Unpackaging querystring parms...');
        
        if (ApexPages.currentPage().getParameters().containsKey('sowid')) {
            strSOWId = ApexPages.currentPage().getParameters().get('sowid'); 
        } else {
            strSOWId = '';
        }
        System.debug('SOW Id Received: ' + strSOWId);
        
        strLastWeekEnding = Date.today().toStartOfWeek().addDays(-1).format();
        dtLastWeekEnding = Date.today().toStartOfWeek().addDays(-1);
    }
    
    public List<Resource_Schedule_Week__c> getResourceScheduleWeeks() {
        
        // define local vars
        String currentUserId = UserInfo.getUserId();
        
        // query the records
        if (strSOWId != '') {
            schedWeeks = [select Week_Hours__c, SOW__r.Name, SOW_Resource_Assignment__r.Resource_Name__c, Is_Actual__c, Id, Comments__c 
                from Resource_Schedule_Week__c where SOW__r.OwnerId = :currentUserId and Week_Ending__c = :dtLastWeekEnding and Is_Actual__c = false and SOW__c = :strSOWId  
                order by SOW__r.Name asc, SOW_Resource_Assignment__r.Hourly_Rate__c desc];
        } else {
            schedWeeks = [select Week_Hours__c, SOW__r.Name, SOW_Resource_Assignment__r.Resource_Name__c, Is_Actual__c, Id, Comments__c 
                from Resource_Schedule_Week__c where SOW__r.OwnerId = :currentUserId and Week_Ending__c = :dtLastWeekEnding and Is_Actual__c = false  
                order by SOW__r.Name asc, SOW_Resource_Assignment__r.Hourly_Rate__c desc];
        } 
        
        System.debug(schedWeeks);
        
        // return the data
        return schedWeeks;
    }
    
    public PageReference saveAndSubmit() {
        // declare local vars
        PageReference redir;
        
        // mark the time as actual
        if (schedWeeks != null) {
            for (Resource_Schedule_Week__c rec : schedWeeks) {
                rec.Is_Actual__c = true;    
            }
        }
        // debug information
        System.debug('Saving the following records:');
        System.debug(schedWeeks);
        // perform the update
        if (schedWeeks != null) {
            if (!schedWeeks.isEmpty()) {
                update schedWeeks;
            }
        }
        // determine the redirect
        if (strSOWId != '') {
            redir = new PageReference('/' + strSOWId);
        } else {
            redir = new PageReference('/home/home.jsp');
        }
        return redir;
    }
    
    public PageReference save() {
        // declare local vars
        PageReference redir;
        
        // debug information
        System.debug('Saving the following records:');
        System.debug(schedWeeks);
        // perform the update
        if (schedWeeks != null) {
            if (!schedWeeks.isEmpty()) {
                update schedWeeks;
            }
        }
        // determine the redirect
        if (strSOWId != '') {
            redir = new PageReference('/' + strSOWId);
        } else {
            redir = new PageReference('/home/home.jsp');
        }
        return redir;
    }
}