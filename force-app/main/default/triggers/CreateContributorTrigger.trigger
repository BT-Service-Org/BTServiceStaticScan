trigger CreateContributorTrigger on User (after insert, after update) {
    
    //get current rewards program id from custom settings
    String prgId = Util.getValue('CURRENT_REWARDS_PROGRAM');

    Set<Id> ccset = new Set<Id>();
    for (Community_Contributor__c cc : [select Id, User__c from Community_Contributor__c where User__c in: Trigger.new and Community_Rewards_Program__c=:prgId]) {
        ccset.add(cc.User__c);
    }
    
    //List<Community_Contributor__c> ccls = new List<Community_Contributor__c>();
    Set<Id> uset = new Set<Id>();
    for (User u : Trigger.new) {
        System.debug('u name:' + u.Name + u);
        if (!ccset.contains(u.Id)) {
            //ccls.add(new Community_Contributor__c(User__c=u.Id, Name=u.FirstName + ' ' + u.LastName, Community_Rewards_Program__c=prgId));
            uset.add(u.Id);
        }   
    }
    if (uset.size() > 0) {
        //insert ccls;
        Util.createContributors(uset, prgId); 
    }

}