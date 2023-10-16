public with sharing class OrgRefresh_org62CSATBean {
    
    public String Id {get; set;}
    public PSEProjectInfo pse_Project {get; set;}
    public DateTime CompletionTime {get; set;}
    public Date Survey_Sent_Date {get; set;}
    public Decimal US_Overall_Satisfaction {get; set;}
    public Decimal Services_Team_s_Professionalism_Knowle {get; set;}
    public Decimal Value_Achieved {get; set;}
    public Decimal Likelihood_to_Recommend_to_Others {get; set;}
    public Decimal Timeliness {get; set;}
    public String Survey_Status {get; set;}
    public ResourceInfo Resource_Name {get; set;}
    public String Name {get;set;}
    
    
    public Class PSEProjectInfo{
        public String Id {get;set;}
        public PSEAccountInfo pseAccount {get;set;}
        public Date pseStart_Date {get; set;}
        public Date pseEnd_Date {get; set;}
        public PSERegionInfo pseRegion {get;set;}
     }
     
    public Class PSERegionInfo{
        public String Name {get;set;}
     }
    
    public Class PSEAccountInfo{
        public Id id {get;set;}
        public String Name {get; set;}
     }
   
    public Class ResourceInfo {
        public String Email {get; set;}
    }
}