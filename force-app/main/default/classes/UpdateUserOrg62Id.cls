public class UpdateUserOrg62Id {

    public static void UpdateId(){
        
        Map<String,Id> UserMap = new Map<String,Id>();
        List<User> UserList =  new List<User>();
        List<Org62_User__x> AllUser = [select ExternalId,Email__c from Org62_User__x where Department__c in 
        ('3090-Program Architects','3096-BA/ITC','3020-Accelerated PA','3095-Strategic Customers Management')
        and Isactive__c =  true and (not email__c in ('merwin@salesforce.com','mkorhonen@salesforce.com'))
        ];

        for (User u : [select Id,Email from User where Isactive = true])
        {
            if (!UserMap.containskey(u.email))
            UserMap.put(u.email,u.Id);
        }

        for (Integer i=0;i<AllUser.size();i++)
        {
            if (UserMap.containskey(AllUser[i].Email__c))
            {
                User UpdUser = new User();
                UpdUser.Id = UserMap.get(AllUser[i].Email__c);
                UpdUser.Org62Id__c = AllUser[i].ExternalId;
                UserList.add(UpdUser);
            }
        
        }     
        
        Update UserList;
    }
}