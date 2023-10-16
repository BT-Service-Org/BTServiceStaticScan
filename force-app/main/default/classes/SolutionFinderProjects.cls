public with sharing class SolutionFinderProjects {

    @AuraEnabled
    public static List<SolutionFinderProject> getProjects(){
        List<SolutionFinderProject> projects = new List<SolutionFinderProject>();
        for (Solution_Finder_Project__c record :
                [SELECT Id, Name
                 FROM Solution_Finder_Project__c
                 WITH SECURITY_ENFORCED
                 LIMIT 100]) {
            projects.add(new SolutionFinderProject(record));
        }
        return projects;
    }

    @AuraEnabled
    public static SolutionFinderProject createProject(String name) {
        
        Solution_Finder_Project__c record = new Solution_Finder_Project__c();
        record.Name = name;
        insert record;

        return new SolutionFinderProject(record);
    }
}