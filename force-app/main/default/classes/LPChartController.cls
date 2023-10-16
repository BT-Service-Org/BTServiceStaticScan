global with sharing class LPChartController {

    public static PA_Onboarding__c record;
    public static String resname {get;set;}
    
    global LPChartController(ApexPages.StandardController controller) {
        record = [SELECT Id, Name, Program_Start_Date__c, (SELECT Name,Cert__c,Expected_Completion_Date__c,Acquired_Date__c,
            Planned_Completion_Date__c,X90_day_learning_path__c,Reqd_PA_Path__c FROM Badge_Data__r WHERE X90_day_learning_path__c=true ORDER BY Acquired_Date__c ASC ) 
            FROM PA_Onboarding__c WHERE id =:ApexPages.currentPage().getParameters().get('id')]; 
            resname = record.Name;
    }
    
    
    private static Integer findWeeks(Date stDate, Date endDate) {
        if (stDate != null && endDate != null) {
            return (stDate.daysBetween(endDate)/7);
        } else {
            return 0;
        }
    }
    
    private static Integer getBadgeCount(Integer week, Boolean actual) {
        List<Badge_Data__c> bd = record.Badge_Data__r;
        Date endDt = record.Program_Start_Date__c.addDays(week*7);
        Integer badgeCount = 0;
        for (Badge_Data__c b: bd) { 
            if (actual) {
                if (b.Acquired_Date__c != null && b.Acquired_Date__c <= endDt) {
                    badgeCount++;
                }
            } else {
                if (b.Planned_Completion_Date__c != null && b.Planned_Completion_Date__c <= endDt) {
                    badgeCount++;
                }
            }
        }
        return badgeCount;
        
    }
    
    // Return a list of data points for a chart
    global static List<Data> getData() {
        return LPChartController.getChartData();
    }
    
    // Make the chart data available via JavaScript remoting
    @RemoteAction
    global static List<Data> getRemoteData() {
        return LPChartController.getChartData();
    }

    // The actual chart data; needs to be static to be
    // called by a @RemoteAction method
    global static List<Data> getChartData() {
        System.debug(record);
        
        Integer noOfWeeks = findWeeks(record.Program_Start_Date__c, Date.today());
       
        List<Data> data = new List<Data>();
        for (Integer i=0; i<= 25; i++) {
            Date hiredate = record.Program_Start_Date__c;
            Integer days = i*7;
            Date wk = hiredate.addDays(days);
            String dt = DateTime.newInstance(wk.year(),wk.month(),wk.day()).format('d/MM');
            data.add(new Data('Wk '+ i + ' : ' + dt ,getBadgeCount(i,true), getBadgeCount(i,false),0));
        }
        /*data.add(new Data('1', 1, 0, 55));
        data.add(new Data('2', 2, 1, 65));
        data.add(new Data('3', 2, 2, 75));
        data.add(new Data('4', 3, 2, 85));
        data.add(new Data('5', 4, 2, 95));
        data.add(new Data('6', 4, 2, 99));
        data.add(new Data('7', 5, 2, 30));
        data.add(new Data('8', 7, 3, 45));
        data.add(new Data('9', 7, 3, 55));
        data.add(new Data('10', 7, 3, 56));
        data.add(new Data('11', 8, 3, 53));
        data.add(new Data('12', 8, 3, 70));*/
        return data;
    }
    
    // Wrapper class
    global class Data {
        public String name { get; set; }
        public Integer actual { get; set; }
        public Integer planned { get; set; }
        public Integer estimated { get; set; }
        public Data(String name, Integer actual, Integer planned, Integer estimated) {
            this.name = name;
            this.actual = actual; 
            this.planned = planned;
            this.estimated = estimated;
        }
    }
    
}