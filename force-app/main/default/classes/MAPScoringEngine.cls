public class MAPScoringEngine {
    
    public class ScoringException extends Exception {}
    
    public static Decimal CalculateScore(String level)
    {
        Decimal value;

        if (level == null)
            return 0;
            //throw new ScoringException('Level cannot be null');
            
        if (level.equalsIgnoreCase('Minimal'))
        {
            return 1;
        }
        else if (level.equalsIgnoreCase('Emerging'))
        {
            return 2;
        }
        else if (level.equalsIgnoreCase('Practicing'))
        {
            return 3;
        }
        else if (level.equalsIgnoreCase('Optimized'))
        {
            return 4;
        }
        else if (level.equalsIgnoreCase('Leading'))
        {
            return 5;
        }
        else // N/A
        {
            return 0;
        }
    }

    public static String CalculateLevel(Decimal input, MAPDomain__c domain)
    {
        String value;
        
        Integer score = input.intValue();
        
        if ((score == 0) || ((score >= domain.Tier_1_Min__c) && (score <= domain.Tier_1_Max__c)))
        {
            value = 'Minimal';
        }
        else if ((score >= domain.Tier_2_Min__c) && (score <= domain.Tier_2_Max__c))
        {
            value = 'Emerging';
        }
        else if ((score >= domain.Tier_3_Min__c) && (score <= domain.Tier_3_Max__c))
        {
            value = 'Practicing';
        }
        else if ((score >= domain.Tier_4_Min__c) && (score <= domain.Tier_4_Max__c))
        {
            value = 'Optimized';
        }
        else if ((score >= domain.Tier_5_Min__c))
        {
            value = 'Leading';
        }
        
        return value;
    }
    
    public static MAPInterview__c CalculateLevel(MAPInterview__c interview, MAPDomain__c domain, MAPInterviewDimension__c[] dimensions)
    {
        String value;
        
        Decimal score = 0.0;

        // Score Interview
        for (MAPInterviewDimension__c dim : dimensions)
        {
            score = score + (dim.Score__c + dim.Dimension__r.Weight__c);
        }
        
        score = (dimensions.size() > 0) ? ((score / dimensions.size())).setScale(2) : 0.0;
        
        interview.Score__c = score;
        interview.Level__c = CalculateLevel(score, domain);
        
        return interview;
    }
}