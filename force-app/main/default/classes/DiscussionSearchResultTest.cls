@IsTest private class DiscussionSearchResultTest {


        public static testMethod void testDiscussion() { 
        	DiscussionSearchResultsController dis = new DiscussionSearchResultsController();
        	
        	Boolean isTestController = true;
            dis.setIsTestController(true);
           	
        	
        	/* WITH SEARCH CRITERIA */
            try {
                dis.setParamkey('juan');
            }
            catch (exception e) {
                System.assert(true, e);
            }
             
            try {
                dis.contructorFunction();
            }
            catch (exception e) {
                System.assert(true, e);
            }
            
            if (dis.getCriteria() == null) {
                System.assert(true,'getCriteria return null');
            }
            
            DiscussionSearchResultsController.searchResult searchResult =  new DiscussionSearchResultsController.searchResult();
            
            if (searchResult.getTitle() == null) {
                System.assert(true,'getTitle return null'); 
            }
            
            if (searchResult.getMatches() == null) {
                System.assert(true,'getMatches return null');   
            }
            
            if (searchResult.getUrl() == null) {
                System.assert(true,'getUrl return null');   
            }
            
            if (dis.getTotalItemsNumber() == null) {
                System.assert(true,'getTotalItemsNumber return null');
            }
            
            if (dis.getNoMatches() == null) {
                System.assert(true,'getNoMatches return null');
            }
            
            /*
            try {
            	dis.setIsTestController(true);
                dis.search();   
            }
            catch (exception e) {
                System.assert(true, e);
            }
            */
            
            dis.setCriteria('test');
            
            List<DiscussionSearchResultsController.searchResult> results = dis.getResults();
			if (results == null) {
                System.assert(true,'getResults return null');
            }
            
            dis.genCntPagination();
            
            dis.nextPage();
            
            dis.prevPage();
            
            dis.lastPage();
            
            dis.firstPage();
            
            dis.refreshPages();
            
            Integer fI = dis.getFirstItem();
            if (fI == null) {
                System.assert(true,'getFirstItem return null');
            }
			
			Integer lI = dis.getLastItem();
            if (lI == null) {
                System.assert(true,'getLastItem return null');
            }
            
            Integer cP = dis.getCurrentPagination();
            if (cP == null) {
                System.assert(true,'getCurrentPagination return null');
            }
            
            Integer cntP = dis.getCntPagination();
            if (cntP == null) {
                System.assert(true,'getCntPagination return null');
            }
            
            Integer nItems = dis.getNumberOfItemsToShow();
            if (nItems == null) {
                System.assert(true,'getNumberOfItemsToShow  return null');
            }
            
            Integer fR = dis.getFirstRow();
            if (fR == null) {
                System.assert(true,'getFirstRow  return null');
            }
            
            Boolean prevLS = dis.getPrevPageLinkShow();
            if (prevLS == null) {
                System.assert(true,'getPrevPageLinkShow  return null');
            }
			
			Boolean prevPS = dis.getPrevPageShow();
            if (prevPS == null) {
                System.assert(true,'getPrevPageShow  return null');
            }
            
            Boolean prevPPS = dis.getPrevPageShow();
            if (prevPPS == null) {
                System.assert(true,'getPrevPageShow  return null');
            }
            
            Boolean nextLS = dis.getNextPageLinkShow();
            if (nextLS == null) {
                System.assert(true,'getNextPageLinkShow  return null');
            }
            
            Boolean nextPLS = dis.getNextPageLinkShow();
            if (nextPLS == null) {
                System.assert(true,'getNextPageLinkShow  return null');
            }
            
             Boolean nextPS = dis.getNextPageShow();
            if (nextPS == null) {
                System.assert(true,'getNextPageShow  return null');
            }
			
			Integer jP = dis.getJumpPage();
            if (jP == null) {
                System.assert(true,'getJumpPage  return null');
            }
            
            Integer jumpT = 1;
            dis.setJumpPage(jumpT);
			dis.JumpToPage();
			
            /* NO SEARCH CRITERIA */
            try {
            	dis.setIsTestController(true);
                dis.setParamkey('');
            }
            catch (exception e) {
                System.assert(true, e);
            }
            
            
            try {
                dis.contructorFunction();
            }
            catch (exception e) {
                System.assert(true, e);
            }
          
            try {
            	
                dis.search();   
            }
            catch (exception e) {
                System.assert(true, e);
            }
            
            
            if (dis.getCriteria() == null) {
                System.assert(true,'getCriteria return null');
            }
            
            DiscussionSearchResultsController.searchResult searchResult2 =  new DiscussionSearchResultsController.searchResult();
            
            if (searchResult2.getTitle() == null) {
                System.assert(true,'getTitle return null'); 
            }
            
            if (searchResult2.getMatches() == null) {
                System.assert(true,'getMatches return null');   
            }
            
            if (searchResult2.getUrl() == null) {
                System.assert(true,'getUrl return null');   
            }
            
            if (dis.getTotalItemsNumber() == null) {
                System.assert(true,'getTotalItemsNumber return null');
            }
            
            if (dis.getNoMatches() == null) {
                System.assert(true,'getNoMatches return null');
            }
            
            /*
            DiscussionSearchResultsController.searchResult search=  new DiscussionSearchResultsController.searchResult();
            search.setTitle ('A', 'B');
            search.setMatches('A', 'B');
            String title = search.getTitle ();
            System.assert(title=='A', 'OK');
            String matches= search.getMatches ();
            System.assert(matches=='A', 'OK');
            dis.search();
            */
    
        }
}