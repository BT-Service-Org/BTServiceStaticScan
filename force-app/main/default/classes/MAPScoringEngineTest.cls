@isTest
public class MAPScoringEngineTest {
    
    public static MAPDomain__c CreateDomain()
    {
        // setup
        MAPDomain__c domain = new MAPDomain__c();
        domain.Name = 'Test Domain';
        domain.Tier_1_Min__c = 0;
        domain.Tier_1_Max__c = 19;
        domain.Tier_2_Min__c = 20;
        domain.Tier_2_Max__c = 39;
        domain.Tier_3_Min__c = 40;
        domain.Tier_3_Max__c = 59;
        domain.Tier_4_Min__c = 60;
        domain.Tier_4_Max__c = 79;
        domain.Tier_5_Min__c = 80;
        domain.Tier_5_Max__c = 99;
        
        return domain;
    }
    
    private static testMethod void CalculateLabel()
    {
        // setup
        MAPDomain__c domain = CreateDomain();
        
        integer score;
        decimal level;
        
        // Check out of bounds
        System.assert(String.isEmpty(MAPScoringEngine.CalculateLevel(-1, domain)), '-1 failed');
        //System.assert(String.isEmpty(MAPScoringEngine.CalculateLevel(100, domain)), '100 failed');
        
        // Check boundaries
        System.assertEquals('Minimal', MAPScoringEngine.CalculateLevel(domain.Tier_1_Min__c, domain), domain.Tier_1_Min__c + ' failed');
        System.assertEquals('Leading', MAPScoringEngine.CalculateLevel(domain.Tier_5_Max__c, domain), domain.Tier_5_Max__c + ' failed');
        
        // Check Valid Ranges
        System.assertEquals('Minimal', MAPScoringEngine.CalculateLevel(10, domain), 'Minimal failed');
        System.assertEquals('Emerging', MAPScoringEngine.CalculateLevel(20, domain), 'Emerging failed');
        System.assertEquals('Practicing', MAPScoringEngine.CalculateLevel(40, domain), 'Practicing failed');
        System.assertEquals('Optimized', MAPScoringEngine.CalculateLevel(60, domain), 'Optimized failed');
        System.assertEquals('Leading', MAPScoringEngine.CalculateLevel(80, domain), 'Leading failed');
    }
    
    private static testMethod void CalculateLevel()
    {
        MAPDomain__c domain = CreateDomain();
        MAPInterview__c interview = new MAPInterview__c();
        
        MAPInterviewDimension__c dim = new MAPInterviewDimension__c();
        dim.Score__c = 10;
        dim.Dimension__r = new MAPDimension__c();
        dim.Dimension__r.Weight__c = 0;
        
        List<MAPInterviewDimension__c> dimensions = new List<MAPInterviewDimension__c>();
        dimensions.Add(dim);
   
        object output = MAPScoringEngine.CalculateLevel(interview, domain, dimensions);
        
        System.assertEquals(output, interview);
    }

    private static testMethod void CalculateScore() {
        System.assertEquals(1, MAPScoringEngine.CalculateScore('Minimal'));
        System.assertEquals(2, MAPScoringEngine.CalculateScore('Emerging'));
        System.assertEquals(3, MAPScoringEngine.CalculateScore('Practicing'));
        System.assertEquals(4, MAPScoringEngine.CalculateScore('Optimized'));
        System.assertEquals(5, MAPScoringEngine.CalculateScore('Leading'));
    }
}