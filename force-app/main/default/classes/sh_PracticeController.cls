public without sharing class sh_PracticeController {
   public String practiceName {get; set;}
   
   public sh_Practice__c practice {get; set;}
   public sh_Practice__c practice2 {get; set;}
   public String factSheetId {get; set;}
   public String quickFact1Id {get; set;}
   public String quickFact2Id {get; set;}
   public String quickFact3Id {get; set;}
   public String quickFact4Id {get; set;}
   public String domainVariable{get; set;}

   public List<PracticeInfo> practicesDto {get; set;}
   
   //Constructor
   public sh_PracticeController() {
     
     try{
         domainVariable= sh_URLUtility.GetPrefix();
         System.debug('domainVar is '+ domainVariable);
    
         Map<String, String> UrlParameterMap = ApexPages.currentPage().getParameters();
         
         // Get Practice Name
         if (UrlParameterMap.containsKey('name')){
           practiceName = UrlParameterMap.get('name');
         } else {
           practiceName = 'sh_home';
         }  
         
         System.debug('>>>>> practiceName: ' + practiceName);
         
         if (practiceName != 'sh_home') {
            practice = [select  Hero_Image__c,
                                Org62_Chatter_Group_ID__c,
                                Overview_Video_JS__c,
                                Overview_Video_JS_Function__c,
                                Practice_Info__c,
                                Name,
                                Id,
                                Practice_Name__c,
                                Practice_Title__c, 
                                External_Video_Link__c,
                                Sequence__c,
                                Header_HTML__c,
                                (select id, name from Attachments)
                      from  sh_Practice__c 
                     where  Practice_Name__c = :practiceName
                     order by Sequence__c
                     limit  1]; 
         } else {
            List<sh_Practice__c> homePageInfo = [select     Hero_Image__c,
                                                            Org62_Chatter_Group_ID__c,
                                                            Overview_Video_JS__c,
                                                            Overview_Video_JS_Function__c,
                                                            Practice_Info__c,
                                                            Name,
                                                            Id,
                                                            Practice_Name__c,
                                                            Practice_Title__c, 
                                                            External_Video_Link__c,
                                                            Sequence__c,
                                                            (select id, name from Attachments)
                                                  from  sh_Practice__c 
                                                 where  Practice_Name__c in ('services-1', 'services-2')
                                                 order by Sequence__c
                                                 limit  2];
            for (sh_Practice__c prac : homePageInfo) {
                if (prac.Practice_Name__c == 'services-1') {
                    practice = prac;
                } else if (prac.Practice_Name__c == 'services-2') {
                    practice2 = prac;
                }
            }
            
            List<sh_Practice__c> practices = [select Name, Practice_Name__c 
                                                from sh_Practice__c
                                               where isPractice__c = true
                                            order by Sequence__c];
            practicesDto = new List<PracticeInfo>();
            for (sh_Practice__c prac : practices) {
                PracticeInfo p = new PracticeInfo();
                p.practiceName = prac.Name;
                p.practiceCode = prac.Practice_Name__c;
                practicesDto.add(p);
            }
         }
         
         if (practice != null) {         
             for (Attachment atch : practice.Attachments) {
                if (atch.Name == 'QuickFact1') {
                    quickFact1Id = atch.Id;
                } else if (atch.Name == 'QuickFact2') {
                    quickFact2Id = atch.Id;
                }  else if (atch.Name == 'QuickFact3') {
                    quickFact3Id = atch.Id;
                } else if (atch.Name == 'QuickFact4') {
                    quickFact4Id = atch.Id;
                } else {
                    factSheetId = atch.Id;
                }
             }
         }
     
     }
     catch(Exception ex){
         ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
     }
     
   } 
   
   public class PracticeInfo {
     public String practiceName {get; set;}
     public String practiceCode {get; set;}
   } 
}