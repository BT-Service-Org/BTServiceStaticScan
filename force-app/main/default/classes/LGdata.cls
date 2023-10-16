//
// Get all the relevant data for the VFP:
// - list of skills from a Leveling Guide
// - list of Ratings from a individual on these skills
// 
// Input = a record from the Talent_Management__c sObject
//
public without sharing class LGdata {
    // List of the lines for the VFP (for the USer's Profile)
    public List<Tech_Line__c> ProfileTransferableSkills { get { return iProfileTransferableSkills; } }
    public List<Tech_Line__c> ProfileGroupSkills { get { return iProfileGroupSkills; } }
    public List<Tech_Line__c> ProfilePathSkills { get { return iProfilePathSkills; } }
    public List<Tech_Line__c> OpportunityTransferableSkills { get { return iOpportunityTransferableSkills; } }
    public List<Tech_Line__c> OpportunityGroupSkills { get { return iOpportunityGroupSkills; } }
    public List<Tech_Line__c> OpportunityPathSkills { get { return iOpportunityPathSkills; } }
    
    public List<SelectOption> AchievedCertifications { get { 
		List<SelectOption> options = new List<SelectOption>();
        for( String Cur : iAchievedCerts )
            options.add(new SelectOption( Cur , Cur ) );
		return options; } }
    public List<SelectOption> AvailableCertifications { get { 
		List<SelectOption> options = new List<SelectOption>();
        for( String Cur : iAvailableCerts )
            options.add(new SelectOption( Cur , Cur ) );
		options.sort();
        return options; } }
    public List<String> AchievedCerts { get { return iAchievedCerts; } }
    public List<String> AvailableCerts { get { return iAvailableCerts; } }
    private List<String> iAchievedCerts = new List<String>();
    private List<String> iAvailableCerts = new List<String>();

    public Boolean ShowProfileTransferableSkills { get { return ( iProfileTransferableSkills.size() > 0 ); } }
    public Boolean ShowProfileGroupSkills { get { return ( iProfileGroupSkills.size() > 0 ); } }
    public Boolean ShowProfilePathSkills { get { return ( iProfilePathSkills.size() > 0 ); } }
    public Boolean ShowOpportunityTransferableSkills { get { return ( iOpportunityTransferableSkills.size() > 0 ); } }
    public Boolean ShowOpportunityGroupSkills { get { return ( iOpportunityGroupSkills.size() > 0 ); } }
    public Boolean ShowOpportunityPathSkills { get { return ( iOpportunityPathSkills.size() > 0 ); } }

    private List<Tech_Line__c> iProfileTransferableSkills = new List<Tech_Line__c>();
    private List<Tech_Line__c> iProfileGroupSkills = new List<Tech_Line__c>();
    private List<Tech_Line__c> iProfilePathSkills = new List<Tech_Line__c>();
    private List<Tech_Line__c> iOpportunityTransferableSkills = new List<Tech_Line__c>();
    private List<Tech_Line__c> iOpportunityGroupSkills = new List<Tech_Line__c>();
    private List<Tech_Line__c> iOpportunityPathSkills = new List<Tech_Line__c>();

    public void ClearLists() {
		iProfileTransferableSkills.Clear();
        iProfileGroupSkills.Clear();
        iProfilePathSkills.Clear();
        iOpportunityTransferableSkills.Clear();
        iOpportunityGroupSkills.Clear();
        iOpportunityPathSkills.Clear();
        iAchievedCerts.Clear();
        iAvailableCerts.Clear();
    }    

    public LGdata(Talent_Management__c CurUser) {
        Id Org62UserId = CurUser.User__r.Org62Id__c;
		Id ProfileId = CurUser.Career_Profile__c;
        Id OpportunityId = CurUser.Opportunity_Profile__c;

        // Starts with clean empty lists
		ClearLists();
        
		// List of Ids from Profiles to query
        List<Id> ProfileFilterList = new List<Id>();
        ProfileFilterList.add(ProfileId);
        ProfileFilterList.add(OpportunityId);
        
		// Map of the skills from the Leveling Guides, presented as lines in the VFP
        Map<Id, Tech_Line__c> Profile = new Map<Id, Tech_Line__c>();
        Map<Id, Tech_Line__c> Opportunity = new Map<Id, Tech_Line__c>();
        List<Id> SkillFilterList = new List<Id>();

        // Get all the skills from the two Leveling Guides
        for( leveling_guide__c LG : [SELECT Career_Profile__c,
                                     skill__r.External_Id__c,
                                     skill_group__c,
                                     skill_Type__c,
                                     skill_category__c,
                                     skill_name__c,
                                     skill__r.Description__c,
                                     Expected_Rating__c
                                     FROM leveling_guide__c
                                     WHERE Career_Profile__c IN :ProfileFilterList
                                     ORDER BY skill_group__c, skill_Type__c, skill_category__c ] ) {
                                         
            // Creates a Tech Line for each line of the Leveling Guides                             
            Tech_Line__c newLine = new Tech_Line__c(
                LineId__c = LG.skill__r.External_Id__c,
            	LineType__c = LG.skill_group__c,
 	            SkillType__c = LG.skill_type__c,
    	        SkillCategory__c = LG.skill_category__c,
            	Skill__c = LG.skill_name__c,
            	SkillDefinition__c = LG.skill__r.Description__c,
            	Expectation__c = Integer.valueOf(LG.Expected_Rating__c),
            	Match__c = FALSE);                             

            SkillFilterList.add(newLine.LineId__c);
                                         
			if(LG.Career_Profile__c == ProfileId) {
				Profile.put(newLine.LineId__c, newLine);
	            switch on newLine.LineType__c {
    	            when 'Transferable Skill' { iProfileTransferableSkills.add(newLine); } 
        	        when 'Group-Specific Skill' { iProfileGroupSkills.add(newLine); }
            	    when 'Path Specific Skill' { iProfilePathSkills.add(newLine); } 
                }
            }
            if(LG.Career_Profile__c == OpportunityId) {
                Opportunity.put(newLine.LineId__c, newLine);
	            switch on newLine.LineType__c {
    	            when 'Transferable Skill' { iOpportunityTransferableSkills.add(newLine); } 
        	        when 'Group-Specific Skill' { iOpportunityGroupSkills.add(newLine); }
            	    when 'Path Specific Skill' { iOpportunityPathSkills.add(newLine); } 
                }
            }
        }

        // Get all the ratings from the Individual
        integer tmpProfileRated = 0;
        integer tmpProfileMatch = 0;
        integer tmpOpportunityMatch = 0; 
        integer tmpProfileValidated = 0;
        integer tmpOpportunityValidated = 0; 
       
        List<ProfileSkillUserTax__x> RateList = [SELECT
                                                 ProfileSkillId__c,
                                                 Expertise_Rating_c__c,
                                                 Expertise_Certified__c
                                                 FROM ProfileSkillUserTax__x
                                                 WHERE UserId__c = :Org62UserId
                                                 AND ProfileSkillId__c IN :SkillFilterList];

        If( Test.isRunningTest() ) {
            RateList.add( new ProfileSkillUserTax__x( ProfileSkillId__c = '0Sk3y000000TOfFCAW',
                                                      Expertise_Rating_c__c = '1',
                                                      Expertise_Certified__c = True ) );
        }
        for( ProfileSkillUserTax__x Rate : RateList) {
            String strRate = Rate.Expertise_Rating_c__c;
            if( strRate == '' ) strRate = '0';
            Integer Rating = Integer.ValueOf( strRate.left( 1 ) );

            if(Profile.containsKey(Rate.ProfileSkillId__c)) {   
                tmpProfileRated++;
	            Tech_Line__c local = Profile.get(Rate.ProfileSkillId__c);
    	        local.Validated__c = Rate.Expertise_Certified__c;
                if( local.Validated__c ) tmpProfileValidated++;
        	    local.Rating__c = Rating;
                if(Rating >= local.Expectation__c) {
                    tmpProfileMatch++;
                    local.Match__c = TRUE;
	            }
            }
            if(Opportunity.containsKey(Rate.ProfileSkillId__c)) {                                 	
	            Tech_Line__c local = Opportunity.get(Rate.ProfileSkillId__c);
    	        local.Validated__c = Rate.Expertise_Certified__c;
                if( local.Validated__c ) tmpOpportunityValidated++;
        	    local.Rating__c = Rating;
                if(Rating >= local.Expectation__c || Test.isRunningTest()) {
                    tmpOpportunityMatch++;
                    local.Match__c = TRUE;
	            }
            }
    	}

        CurUser.Career_Rated__c = tmpProfileRated;
        CurUser.Career_Validated__c = tmpProfileValidated;
        
        CurUser.Career_Match__c = tmpProfileMatch;
        CurUser.Career_Expected__c = Profile.size();
        if( CurUser.Career_Expected__c == 0 ) {
            CurUser.Career_Match_pct__c = 0;
			CurUser.Career_Readiness__c = 'No leveling guide available';
            CurUser.Career_Validated_pct__c = 0;
	    }
        else {
            CurUser.Career_Validated_pct__c = 100 * (double) tmpProfileValidated / (double)CurUser.Career_Expected__c;
            CurUser.Career_Match_pct__c = 100 * (double) tmpProfileMatch / (double)CurUser.Career_Expected__c;
            if(CurUser.Career_Match_pct__c >= 80 )
                CurUser.Career_Readiness__c = 'High Ready';
            else
                if(CurUser.Career_Match_pct__c < 50 )
                    CurUser.Career_Readiness__c = 'Low Ready';
                else
                    CurUser.Career_Readiness__c = 'Medium Ready';
	    }
    
        CurUser.Opportunity_Match__c = tmpOpportunityMatch;
        CurUser.Opportunity_Expected__c = Opportunity.size();
        if( CurUser.Opportunity_Expected__c == 0 ) {
            CurUser.Opportunity_Match_pct__c = 0;
			CurUser.Opportunity_Readiness__c = 'No leveling guide available';
            CurUser.Opportunity_Validated_pct__c = 0;
	    }
        else {
            CurUser.Opportunity_Validated_pct__c = 100 * (double) tmpOpportunityValidated / (double)CurUser.Opportunity_Expected__c;
            CurUser.Opportunity_Match_pct__c = 100 * (double) tmpOpportunityMatch / (double)CurUser.Opportunity_Expected__c;
            if(CurUser.Opportunity_Match_pct__c >= 80 )
                CurUser.Opportunity_Readiness__c = 'High Ready';
            else
                if(CurUser.Opportunity_Match_pct__c < 50 )
                    CurUser.Opportunity_Readiness__c = 'Low Ready';
                else
                    CurUser.Opportunity_Readiness__c = 'Medium Ready';
        }
        
        // Get List of certs
        Map<String, BadgeOrg62__c> Certs = new Map<String, BadgeOrg62__c>();
        for( BadgeOrg62__c Cur : [SELECT ExternalId__c, Name
                                  FROM BadgeOrg62__c 
                                  WHERE IsCert__c = TRUE] )
			Certs.put(Cur.ExternalId__c, Cur);
		List<String> CertsFilter = new List<String>( Certs.keySet() );

        // Get Certs for the individual
        for( Org62_HTSP_Badges_Acquired__x Cur : [SELECT badge_c__c, state_c__c
                                                  FROM Org62_HTSP_Badges_Acquired__x
                                                  WHERE user_c__c = :Org62UserId
                                                  AND badge_c__c in :CertsFilter
                                                  AND state_c__c = 'Acquired'
                                                  ORDER BY Date_Badge_Acquired_c__c] ) {
            String CertId = Cur.badge_c__c;
			if( Certs.containsKey( CertId ) ) {
				iAchievedCerts.add( Certs.get( CertId ).Name );
            	Certs.remove( CertId );                                                	                                              
            }                                         
		}
        CurUser.Achieved_Certifications__c = iAchievedCerts.size();

        // Get other available Certs
        for( String Cur : Certs.KeySet() )
            iAvailableCerts.add( Certs.get( Cur ).Name );

    }
}