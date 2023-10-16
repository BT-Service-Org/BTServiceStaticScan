@IsTest private class SearchResultControllerTest {
 /* ******************/
     /*  TEST CLASS      */
     /* ******************/
    
    public static testMethod void SearchResultController()
    {
        SearchResultController n = new SearchResultController();
        String resultTypeOfAction = n.getTypeAction();
        if(resultTypeOfAction == '')
        {
                System.assert(false, 'No type of action'); 
        }

        n.setSizeList(12);
        List<PeopleProfile__c> people = n.getPeople();
        if(people == null)
        {
            System.assert(false, 'no List'); 
        }
        PaginatorController ins = n.getPaginator();
        if(ins == null)
        {
                System.assert(false, 'No Instance'); 
        }
        Integer listSize = n.getSizeList();
        
        if(listSize == null)
        {
                System.assert(false, 'No List size'); 
        }
        String userId = '005300000019Z9bAAE';
        String miType2 = 'SubscribesToMe';
        n.ResultCore(miType2);
        n.setTypeAction(miType2);
        String titleMy = n.getTitle();
        
        if(titleMy == null)
        {
                System.assert(false, 'No Title'); 
        }
        
        

    }
}