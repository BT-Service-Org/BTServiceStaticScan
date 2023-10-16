public class PeopleHeaderSearchController {
	//####################################//
	// People Keyword Search 
	//####################################//
	
	//Search Result Page 
    private static String PEOPLE_SEARCH_RESULTS_PAGE = '/apex/PeopleKeywordSearchResults';
    
    //Search Object Initialization
    PeopleSearch peopleSearchObj = new PeopleSearch();    
    
    public PeopleHeaderSearchController(){    
    	
    }
    
    public PeopleSearch getPeopleSearchObj (){    	
    	  return peopleSearchObj;
   	}
        
    public PageReference findPeople() {
    		PageReference pageRef = new PageReference(PEOPLE_SEARCH_RESULTS_PAGE + '?keyword=' + peopleSearchObj.Keyword);
            pageRef.setRedirect(true);
            return pageRef;
    }
          
	public class PeopleSearch {
		public String Keyword{ get; set; }
	}
}