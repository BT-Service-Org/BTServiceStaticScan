public with sharing class ConsultantSkillsExtension_VG2{
    private final Contact consultant;
    private Map<String, Integer> categoryScores;
    private List<Consultant_Skill__c> topSkills;
    private List<Consultant_Skill__c> lowSkills;
    private ConsultantSkillsHierarchyModel_VG skillsHierarchy;
    private List<Project_Assignment__c> consultantProjects;
    private Map<String, Decimal> categoryAverages;
    private Map<String, Map<String, Decimal>> AverageScores;
    private Map<String, Map<String, Decimal>> AverageScoresMgr;
    private List<Architect_Learning_Path__c> consultantALP;
    private Map<String, String> BadgeImageMap;
    
    
    
    public ConsultantSkillsExtension_VG2(ApexPages.StandardController con) {
        this.consultant = (Contact)con.getRecord();
    }
    
    
    
    // return the Skills hierarchy for this Consultant
    public ConsultantSkillsHierarchyModel_VG getSkills() {
        if(skillsHierarchy == null) {
            this.skillsHierarchy = new ConsultantSkillsHierarchyModel_VG();
            this.skillsHierarchy.initializeHierarchy(consultant);
        }
        return skillsHierarchy;
    }


    // return a map of {Skill__c.id, Score} for this Consultant
    public Map<String, Integer> getSkillSelfRating() {
            return getSkills().getSkillSelfRating(this.consultant);
    }

    // return a map of badges and their associated image location
    public Map<String, String> getBadgeImageMap() {
            return getSkills().getBadgeImageMap();
    }

    // return a map of {Skill__c.id, Manager Rating} for this Consultant
    public Map<String, Integer> getSkillManagerRating() {
        return getSkills().getSkillManagerRating(this.consultant);
    }
    
   
    // update the Self Rating in the map SkillsSelfRating
    public void updateSelfRating() {
        String theId = Apexpages.currentPage().getParameters().get('theID');
        String rating = Apexpages.currentPage().getParameters().get('theRating'); 
        Integer intRating = integer.valueof(rating);
        skillsHierarchy.updateSelfRating(this.consultant, theID, intRating);
        
        Consultant_Skill__c cs = null;
        try {
             List<Consultant_Skill__c> csList = [SELECT id, Skill__r.id, Rating__c FROM Consultant_Skill__c WHERE Contact__r.id = :consultant.id and Skill__r.id = :theId limit 1];
             if(csList.size() > 0)
             {
               cs = csList.get(0); 
               cs.Rating__c = String.valueOf(skillsHierarchy.getSkillSelfRating(this.consultant).get(cs.Skill__r.id));
               update cs;
             }
            } catch (DmlException e) {
                                    // Process exception here
                                    System.debug('***************@@@@@@@@@@@@@@@@@@@@ FAILED');
                                    }
        }

    
    // update the Self Rating in the map SkillsSelfRating
    public void updateManagerRating() {
        String theId = Apexpages.currentPage().getParameters().get('theID');
        String rating = Apexpages.currentPage().getParameters().get('theRating'); 
        Integer intRating = integer.valueof(rating);
        skillsHierarchy.updateManagerRating(this.consultant, theID, intRating);
        
        Consultant_Skill__c cs = null;
        try {
             List<Consultant_Skill__c> csList = [SELECT id, Skill__r.id, Manager_Rating__c FROM Consultant_Skill__c WHERE Contact__r.id = :consultant.id and Skill__r.id = :theId limit 1];
             if(csList.size() > 0)
             {
               cs = csList.get(0); 
               cs.Manager_Rating__c = String.valueOf(skillsHierarchy.getSkillManagerRating(this.consultant).get(cs.Skill__r.id));
               update cs;
             }
            } catch (DmlException e) {
                                    // Process exception here
                                    System.debug('***************@@@@@@@@@@@@@@@@@@@@ FAILED');
                                    }
        }

 
    
    
    // read edited values from the skillsSelfRating map and persist into the underlying objects
    public PageReference saveEdits() {
    
      Map<String, Integer> theSelfRatings = skillsHierarchy.getSkillSelfRating(this.consultant);
            
      for(Consultant_Skill__c cs : [SELECT id, Skill__r.id, Rating__c FROM Consultant_Skill__c WHERE Contact__r.id = :consultant.id]) {
                cs.Rating__c = String.valueOf(theSelfRatings.get(cs.Skill__r.id));
                try {
                     update cs;
                    } catch (DmlException e) {
                                    // Process exception here
                                             }
      }
      PageReference saveEditPage= Page.ConsultantSkills_VG4;
      saveEditPage.getParameters().put('id',consultant.id);
      saveEditPage.setRedirect(true);
      return saveEditPage;
    }



    // Cancel and navigate back to the main page
    public PageReference cancel() {
        PageReference mainPage= Page.ConsultantSkills_VG4;
        mainPage.getParameters().put('id',consultant.id);
        mainPage.setRedirect(true);
        return mainPage;
    }
    


    // Navigate to the edit page
    public PageReference goToEdit() {
        PageReference editPage= Page.ConsultantSkillsEdit2;
        editPage.getParameters().put('id',consultant.id);
        editPage.setRedirect(true);
        return editPage;
    }
    
    
    
    
    
    
    // Return the top 5 skills for the consultant
    public List<Consultant_Skill__c> getTopSkills() {
        if(topSkills == null) {
            topSkills = [SELECT id, Skill__r.Skill_Category__c, Skill__r.Skill_Type__c, Skill__r.Skill__c, Rating__c 
                         FROM Consultant_Skill__c 
                         WHERE Contact__r.id = :consultant.id 
                         ORDER BY Rating__c DESC, Skill__r.Skill_Type__c, Skill__r.Skill__c NULLS LAST LIMIT 5];
        }
        return topSkills;
    }
    
    // Return the lowest 5 skills for the consultant
    public List<Consultant_Skill__c> getlowSkills() {
        if(lowSkills == null) {
            lowSkills = [SELECT id, Skill__r.Skill_Category__c, Skill__r.Skill_Type__c, Skill__r.Skill__c, Rating__c 
                         FROM Consultant_Skill__c 
                         WHERE Contact__r.id = :consultant.id 
                         ORDER BY Rating__c ASC, Skill__r.Skill_Type__c, Skill__r.Skill__c NULLS LAST LIMIT 5];
        }
        return lowSkills;
    }
     // Return the 5 most recent projects for the consultant
    public List<Project_Assignment__c> getConsultantProjects() {
        if(consultantProjects == null) {
            consultantProjects = [SELECT id, Name, Project_Role__c, Start_Date__c, End_Date__c, Billable_Hours_Submitted__c, Cloud_Type__c, Project_Feedback__r.Name
                         FROM Project_Assignment__c 
                         WHERE Resource__r.id = :consultant.id 
                         ORDER BY Start_Date__c DESC, Project_Assignment__c.Project_Role__c, Project_Assignment__c.Start_Date__c, Project_Assignment__c.End_Date__c, Project_Assignment__c.Billable_Hours_Submitted__c NULLS LAST LIMIT 5];
        }
        return consultantProjects;
    }
    
    
         // Return the Architect Learning Path Objects for the consultant
    public List<Architect_Learning_Path__c> getConsultantALP() {
        if(consultantALP == null) {
            consultantALP =  [SELECT id, Badge__r.Name, Date_Earned__c FROM Architect_Learning_Path__c WHERE Contact__r.id = :consultant.id];
        }
        return consultantALP;
    }
    


    // Return the scores for the skill categories
    public Map<String, Integer> getCategoryScores() {
        if(categoryScores == null) {
            categoryScores = new Map<String, Integer>();
            for(Skill__c s : getCategories()) {
                categoryScores.put(s.Skill_Category__c, 0);
            }

            for(AggregateResult r : [SELECT Skill__r.Skill_Category__c, AVG(score__c) FROM Consultant_Skill__c WHERE Contact__r.id = :consultant.id GROUP BY Skill__r.Skill_Category__c]) {
              categoryScores.put((String)r.get('Skill_Category__c'), Integer.valueOf((Decimal)r.get('expr0')));
            }
        }
        return categoryScores;
    }
    
    
    // Return the scores for the skill categories
 public Map<String, Decimal> getCategoryAverages() {
        if(categoryAverages == null) {
            categoryAverages = new Map<String, Decimal>();
            for(Skill__c s : getCategories()) {
                categoryAverages.put(s.Skill_Category__c, 0);
            }

            for(AggregateResult r : [SELECT Skill__r.Skill_Category__c, AVG(score__c) FROM Consultant_Skill__c WHERE Contact__r.id = :consultant.id GROUP BY Skill__r.Skill_Category__c]) 
            {
              Integer theScore = Integer.valueOf((Decimal)r.get('expr0'));
              Double dblscore = theScore;
              Double dblaverage = dblScore / 20; 
              Decimal average = 0;
              average.setScale(2,roundingMode.CEILING);
              average = dblaverage;
              categoryAverages.put((String)r.get('Skill_Category__c'),average );
            }
        }
         return categoryAverages;
    }
    
    
    
       // Return the Average scores for each Skill Type within each category (Self)
  public Map<String, Map<String, Decimal>> getAverageScores() {
        if(AverageScores == null) 
        {
            AverageScores = new Map<String, Map<String,Decimal>>();
            
            Map<String, Decimal> skillTypeAverage = new Map<String, Decimal>();
            
            // this FOR loop creates an entry for each SkillType in the 
            for(Skill__c s : getCategories()) //getCategories returns the full LIST of Skill objects
            {              
              for(Skill__c r : [SELECT Skill__c, Skill_Category__c, Skill_Type__c FROM Skill__c WHERE Skill_Category__c = :s.Skill_Category__c])
              {
               skillTypeAverage.put((String)r.get('Skill_Type__c'),0);
              }
             AverageScores.put(s.Skill_Category__c, skillTypeAverage);       
            }
            
            for(Skill__c s : getCategories()) //getCategories returns the full LIST of Skill objects
                for(AggregateResult r : [SELECT Skill__r.Skill_Type__c, AVG(score__c) FROM Consultant_Skill__c WHERE Contact__r.id = :consultant.id and Skill__r.Skill_Category__c = :s.Skill_Category__c GROUP BY Skill__r.Skill_Type__c]) 
                {
                  Integer theScore = Integer.valueOf((Decimal)r.get('expr0'));
                  Double dblscore = theScore;
                  Double dblaverage = dblScore / 20; 
                  Decimal average = 0;
                  average.setScale(2,roundingMode.CEILING);
                  average = dblaverage;
                  skillTypeAverage.put((String)r.get('Skill_Type__c'),average );
                  AverageScores.put(s.Skill_Category__c, skillTypeAverage);
                 }   
            }//if 
        return AverageScores;
    }
    
    


       // Return the Average scores for each Skill Type within each category (Manager)
  public Map<String, Map<String, Decimal>> getAverageScoresMgr() {
        if(AverageScoresMgr == null) 
        {
            AverageScoresMgr = new Map<String, Map<String,Decimal>>();
            
            Map<String, Decimal> skillTypeAverageMgr = new Map<String, Decimal>();
            
            // this FOR loop creates an entry for each SkillType in the 
            for(Skill__c s : getCategories()) //getCategories returns the full LIST of Skill objects
            {
              
              for(Skill__c r : [SELECT Skill__c, Skill_Category__c, Skill_Type__c FROM Skill__c WHERE Skill_Category__c = :s.Skill_Category__c])
              {
               skillTypeAverageMgr.put((String)r.get('Skill_Type__c'),0);
              }
             AverageScoresMgr.put(s.Skill_Category__c, skillTypeAverageMgr);       
            }
            
            for(Skill__c s : getCategories()) //getCategories returns the full LIST of Skill objects
                for(AggregateResult r : [SELECT Skill__r.Skill_Type__c, AVG(Manager_Score__c) FROM Consultant_Skill__c WHERE Contact__r.id = :consultant.id and Skill__r.Skill_Category__c = :s.Skill_Category__c GROUP BY Skill__r.Skill_Type__c]) 
                {
                  Integer theScore = Integer.valueOf((Decimal)r.get('expr0'));
                  Double dblscore = theScore;
                  Double dblaverage = dblScore / 20; 
                  Decimal average = 0;
                  average.setScale(2,roundingMode.CEILING);
                  average = dblaverage;
                  skillTypeAverageMgr.put((String)r.get('Skill_Type__c'),average );
                  AverageScoresMgr.put(s.Skill_Category__c, skillTypeAverageMgr);
                 }   
            }//if 
        return AverageScoresMgr;
    }


    
    
    
    public List<Skill__c> getCategories() {
        return getSkills().getCategories();
    }
    

    

}