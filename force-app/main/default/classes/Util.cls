public class Util
{
    public static boolean inFutureContext = false;

    //return custom settings values
    public Static String getValue(String key)
    {
        string returnStr = '';
        Map<String, Community_Rewards_Config__c> config = Community_Rewards_Config__c.getAll();
        if (config != null)
        {
            Community_Rewards_Config__c c = config.get(key);
            if (c != null)
            {
                returnStr = c.Value__c;
            } else
            {
                returnStr = '';
            }
        }
        return returnStr;
    }

    @future
    public static void createContributors(Set<Id> uset, String prgId)
    {
        List<Community_Contributor__c> ccls = new List<Community_Contributor__c>();
        for (User u : [select Id, Name, FirstName, LastName from User where Id in: uset])
        {
            System.debug('u name:' + u.Name + u);
            ccls.add(new Community_Contributor__c(User__c=u.Id, Name=u.FirstName + ' ' + u.LastName, Community_Rewards_Program__c=prgId));
        }

        if (ccls.size() > 0)
        {
            insert ccls;
        }
    }

    // Get a Map of RecordType for a given object
    public static Map<Id, RecordType> GetRecordTypes(string sObjectName)
    {
        return new Map<Id, RecordType>([select Id, Name, DeveloperName from RecordType where SObjectType =: sObjectname]);
    }

    //Get a Map of RecordType by Developer Name for a given object
    public static Map<string, RecordType> GetRecordTypesByDeveloperName(string sObjectName)
    {
        Map<string, RecordType> results = new Map<string, RecordType>();
        for(RecordType rt: [select Id, Name, DeveloperName from RecordType where SObjectType =: sObjectName])
        {
            results.put(rt.DeveloperName, rt);
        }
        return results;
    }
}