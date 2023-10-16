public with sharing class PreworkTemplateController{

    public List<Academy_Prework__c> preworkTopics {get; set;}
    
    
    public PreworkTemplateController(){
    
        this.preworkTopics = [select Id,Name,Subject_Area__c,Pct_Complete__c from Academy_Prework__c];
        System.debug(this.preworkTopics);
    }

}