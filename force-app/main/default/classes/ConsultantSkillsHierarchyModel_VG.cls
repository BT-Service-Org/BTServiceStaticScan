// Provides a hierarchical model of the Consultant Skills object

public with sharing class ConsultantSkillsHierarchyModel_VG{
    private Map<String, Skill__c> skills;
    private Map<String, Skill__c> types;
    private List<Skill__c> categories;
    private Map<String, Integer> categoryScores;
    private Map<String, Integer> categoryAverages;


    private Map<String, Integer> SkillSelfRating;
    private Map<String, Integer> SkillManagerRating;
    private Map<String, String> BadgeImageMap;

         
    private Map<String, Map<String, List<String>>> hierarchy;
    private Map<String, Map<String, String>> typeIds;
    private Map<String, Map<String, Map<String, String>>> skillIds;
    
    // Return the nested-map hierarchy to retrieve skill record Ids
    // [category name][type name][skill name]->skill ID
    public Map<String, Map<String, Map<String, String>>> getSkillIds() {
        return skillIds;
    }
    
    // Return the nested-map hierarchy to retrieve type record Ids
    // [category name][type name]->type ID
    public  Map<String, Map<String, String>> getTypeIds() {
        return typeIds;
    }
    
    
    // Return the nested-map hierarchy of [category][type][skill]
    public Map<String, Map<String, List<String>>> getHierarchy() {
        if(hierarchy == null) {
            generateHierarchySkeleton();
        }//https:sfservices--perfconfig.cs3.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage#
        return hierarchy;
    }
    
    
    
    public void initializeHierarchy(Contact consultant) {
        // populate skeleton first
        generateHierarchySkeleton();
        
        // populate consultant hierarchy
        //getCategoryScores(consultant);
        getSkillSelfRating(consultant);
        getSkillManagerRating(consultant);
    }
    
    private void generateHierarchySkeleton() {
        hierarchy = new Map<String, Map<String, List<String>>>();
        skillIds = new Map<String, Map<String, Map<String, String>>>();
        skills = new Map<String, Skill__c>();
        typeIds =  new Map<String, Map<String, String>>();
        types = new Map<String, Skill__c>();
        categories = new List<Skill__c>();
        
        // fetch the list of skills and populate the data structures
        for(Skill__c skill : [SELECT id, Name, Skill_Category__c, Skill_Type__c, Skill__c FROM Skill__c ORDER BY Skill__c, Skill_Type__c, Skill_Category__c])
         {
         
            // add the skill to the list of skills       
            skills.put(skill.id, skill);

            // check if skill's category is already added to the hierarchy. Add if it hasn't been, add to the list of categories
            Map<String, List<String>> catMap = hierarchy.get(skill.Skill_Category__c);
            if(catMap == null) {
                catMap = new Map<String, List<String>>();
                categories.add(skill);
            }
            
            
            // populate the hierarchy data structure
            //     check if skill's type is already added to the hierarchy. Add if hasn't been, add to the list of skill types
            //     Note: typeSkills is the list of skills for the skill type
            List<String> typeSkills = catMap.get(skill.Skill_Type__c);
            if(typeSkills == null) {
                typeSkills = new List<String>();
                types.put(skill.id, skill);
            }
            
            // add the skill to the list of skills for the skills type.
            typeSkills.add(skill.Skill__c);
            
            // add the list of skills to the map of skill category and skill types
            catMap.put(skill.Skill_Type__c, typeSkills);
            
            // add the category to the hierarchy along with the associated list of skill types and associated skills
            hierarchy.put(skill.Skill_Category__c, catMap);
                       
            // Now, do the same for the SkillIds data structure....
            // populate skill ID lookup Map
            Map<String, Map<String, String>> catIdMap_SkillId = skillIds.get(skill.Skill_Category__c);
            if(catIdMap_SkillId == null) {
                catIdMap_SkillId = new Map<String, Map<String, String>>();
            }
            
            Map<String, String> typeIdMap_SkillId = catIdMap_SkillId.get(skill.Skill_Type__c);
            if(typeIdMap_SkillId == null) {
                typeIdMap_SkillId = new Map<String, String>();
            }
            
            typeIdMap_SkillId.put(skill.Skill__c, skill.id);
            catIdMap_SkillId.put(skill.Skill_Type__c, typeIdMap_SkillId);
            skillIds.put(skill.Skill_Category__c, catIdMap_SkillId);
            
            // Also, add the category and types to the typeIds data structure...
            // populate type ID lookup Map
            Map<String, String> catIdMap_TypeId = typeIds.get(skill.Skill_Category__c);
            if(catIdMap_TypeId == null) {
                catIdMap_TypeId = new Map<String, String>();
            }
            catIdMap_TypeId.put(skill.Skill_Type__c, skill.id);
                
            typeIds.put(skill.Skill_Category__c, catIdMap_TypeId);
        }
    }
    


    // get the SkillSelfRating map. Initialize from underlying objects if it doesnt exist already    
    public Map<String, Integer> getSkillSelfRating(Contact consultant) {
    
        if(skillSelfRating == null) {
            skillSelfRating = new Map<String, Integer>();
            
            //populate with all the skill IDs and initialize rating values to zero
            for(String skillId : skills.keySet()) {
                skillSelfRating.put(skillId, 0);
            }
            
            //fetch all the ratings and update the skillSelfRating map
            for(Consultant_Skill__c cs : [SELECT id, Skill__r.id, Rating__c FROM Consultant_Skill__c WHERE Contact__r.id = :consultant.id]) {
                Integer rating = (cs.Rating__c != null && cs.Rating__c.isNumeric()) ? Integer.valueOf(cs.Rating__c) : 0;
                System.debug('>>> '+cs.Skill__r.id + ' ' + cs.Rating__c); 
                skillSelfRating.put(cs.Skill__r.id, rating);
            }
        }
        return skillSelfRating;
    }
    

    // get the map of badges and their associated images   
    public Map<String, String> getBadgeImageMap() {
    
        if(BadgeImageMap == null) {
            BadgeImageMap  = new Map<String, String>();
                        
            //fetch all the badges and their image location map
            for(Badge__c b : [SELECT id, Name, Image_Location__c  FROM Badge__c]) {
                BadgeImageMap.put(b.Name, b.Image_Location__c);
            }
        }
        return BadgeImageMap;
    }


   
    // method to update the rating value in the SkillsSelfRating map
    public void updateSelfRating(Contact theConsultant, String theId, Integer theRating) {
    
                System.debug('@@@@@@@@@ Inside Model:updateSelfRating. Recieved values are ID :' + theId + ' Rating: ' + theRating); 
                skillSelfRating.put(theId, theRating);
                return;
    }
            
    
        // method to update the rating value in the SkillsManagerRating map
    public void updateManagerRating(Contact theConsultant, String theId, Integer theRating) {
    
                System.debug('@@@@@@@@@ Inside Model:updateManagerRating. Recieved values are ID :' + theId + ' Rating: ' + theRating); 
                skillManagerRating.put(theId, theRating);
                return;
    }
    
    public Map<String, Integer> getSkillManagerRating(Contact consultant) {
        if(SkillManagerRating == null) {
            SkillManagerRating = new Map<String, Integer>();
            for(String skillId : skills.keySet()) {
                SkillManagerRating.put(skillId, 0);
            }
            
            for(Consultant_Skill__c cs : [SELECT id, Skill__r.id, Manager_Rating__c FROM Consultant_Skill__c WHERE Contact__r.id = :consultant.id]) {
                Integer rating = (cs.Manager_Rating__c != null && cs.Manager_Rating__c.isNumeric()) ? Integer.valueOf(cs.Manager_Rating__c) : 0;
                System.debug('>>> '+cs.Skill__r.id + ' ' + cs.Manager_Rating__c); 
                SkillManagerRating.put(cs.Skill__r.id, rating);
            }
        }
        return SkillManagerRating;
    }



     
    public List<Skill__c> getCategories() {
        if(categories == null) {
            generateHierarchySkeleton();
        }
        return categories;
    }


    // Return the sorted type names by category name remove all whitespace from key
    public Map<String, List<String>> getTypeMap() {
        Map<String, List<String>> typeMap = new Map<String, List<String>>();
        for(String cat : hierarchy.keySet()) {
            List<String> types = new List<String>();
            types.addAll(hierarchy.get(cat).keySet());
            types.sort();
            typeMap.put(cat, types);
        }
        return typeMap;
    }
    
    

        
}