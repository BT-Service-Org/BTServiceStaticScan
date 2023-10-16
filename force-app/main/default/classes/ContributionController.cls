public class ContributionController {
    
    public String contributorId {    get;set;    }

    public String contributorName  {    get;set;    }
    
    public String currencyCode  {    get;set;    }
    
    public ContributionController(ApexPages.StandardController ctlr)
    {
        //get current rewards program id from custom settings
        String prgId = Util.getValue('CURRENT_REWARDS_PROGRAM');
    
        Community_Contributor__c c = [select Id, Name, CurrencyIsoCode, Total_Points_Earned__c,Points_Redeemed__c, Points_Available__c from Community_Contributor__c 
                where User__c =: UserInfo.getUserId() and Community_Rewards_Program__c =: prgId];
        contributorId = c.Id;       
        contributorName = c.Name;
        currencyCode = c.CurrencyIsoCode;
    }
 
    public PageReference redirect() {
        return new PageReference('/a0x/e?CF00N3000000A7QyZ='+contributorName+'&CF00N3000000A7QyZ_lkid='+contributorId+'&CurrencyIsoCode='+currencyCode+'&nooverride=1');
        //return new PageReference('/a0Y/e?CF00N30000009RLre='+contributorName+'&CF00N30000009RLre_lkid='+contributorId+'&CurrencyIsoCode='+currencyCode+'&nooverride=1');
        //return new PageReference('/a0y/e?CF00NQ00000011iZ3='+contributorName+'&CF00NQ00000011iZ3_lkid='+contributorId+'&CurrencyIsoCode='+currencyCode+'&nooverride=1');
    }

}