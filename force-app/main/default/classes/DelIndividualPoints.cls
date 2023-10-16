global class DelIndividualPoints implements Schedulable {

    global void execute(SchedulableContext SC) {
		
       DelRecds();
    }

    public static void DelRecds()
    {
 		List<Individual_Point__c> deleterecds = [select id from Individual_Point__c limit 50000] ;
		if(deleterecds.size() > 0)
		delete deleterecds ;
    }
}