public with sharing class sh_BioController {
   public String consultantName {get; set;}
   
   public String practiceCode {get; set;}
   public String projectCode {get; set;}
   public String domainVariable{get; set;}
   
   public sh_Bio__c bio {get; set;}
   
   //For Indiv Bio Page
   public String bioDcoumentId {get; set;}
   public String bioImageId {get; set;}
   
   
   //public prac
   public sh_BioController() {
       domainVariable= sh_URLUtility.GetPrefix();
       getBio();
   } 
   
   public void getBio() {
     Map<String, String> UrlParameterMap = ApexPages.currentPage().getParameters();
     
     // Get Practice Name
     if (UrlParameterMap.containsKey('name')){
       consultantName = UrlParameterMap.get('name');
     } else {
       consultantName = 'justin-waite';
     }  
     
     try {
     		bio = [select   Bio_Content__c,Id,
                            Name,
                            Hero_Image__c,
                            Org62_Chatter_Profile_ID__c,
                            Bio_Link__c,
                            Bio_Name__c,
                            Bio_Picture__c,
                            Bio_Title__c,
                            Bio_Main_Content__c,
                            Vimeo_Video_1__c,
                            Vimeo_Video_2__c,
                             (
                                   SELECT id, Name
                                   FROM Attachments
                             )
                  from  sh_Bio__c 
                 where  Bio_Name__c = :consultantName
                 limit  1]; 
                 
     	if(bio.Attachments.size() > 0) {
          for (Integer i = 0; i < bio.Attachments.size(); i++ ) {  
             if(bio.Attachments[i].Name.Contains('BioPicture')) {
                 bioImageId = bio.Attachments[i].Id; 
             }
             
             if(bio.Attachments[i].Name.Contains('BioDocument')){
                 bioDcoumentId = bio.Attachments[i].Id; 
             }
          }
        }
     
     } catch(Exception e) {
     } 
   }  
   
   public List<PersonInfo> getPracticeLeaders() {
     List<sh_Practice_Leader__c> bios = [select sh_Leader__r.Name,  
                                                sh_Leader__r.Bio_Title__c, 
                                                sh_Leader__r.Bio_Name__c, 
                                                sh_Leader__r.Id
                                           from sh_Practice_Leader__c 
                                          where sh_Practice__r.Practice_Name__c = :practiceCode 
                                          order by Sequence__c];
     Map<Id, PersonInfo> plMap = new Map<Id, PersonInfo>();
     List<Id> bioIDs = new List<Id>();
     for (sh_Practice_Leader__c practiceLeader : bios) {
        PersonInfo pl  = new PersonInfo();
        pl.personName  = practiceLeader.sh_Leader__r.Name;
        pl.personCode  = practiceLeader.sh_Leader__r.Bio_Name__c;
        pl.personTitle = practiceLeader.sh_Leader__r.Bio_Title__c;
        bioIDs.add(practiceLeader.sh_Leader__r.Id);
        plMap.put(practiceLeader.sh_Leader__r.Id, pl);
     }
     
     //Get attachment data
     List<Attachment> attachments = [select id, name, parentid
                                        from Attachment 
                                       where parentid in :bioIDs];
                         
     for (Attachment atch : attachments) {
        if (atch.name == 'BioPicture') {
            plMap.get(atch.parentid).personImageId = atch.id;
        } else if (atch.name == 'BioDocument') {
            plMap.get(atch.parentid).personBioId = atch.id;
        } 
     }
     
     List<PersonInfo> plDto = new List<PersonInfo>();
     for (Id plId : bioIDs) {
        plDto.add(plMap.get(plId));
     }
     
     return (plDto);
   }
   public List<PersonInfo> getProjectTeam() {
     return (null);
   }
   
   public class PersonInfo {
     public String personName {get; set;}
     public String personCode {get; set;}
     public String personTitle {get; set;}
     public String personImageId {get; set;}
     public String personBioId {get; set;}
   }
}