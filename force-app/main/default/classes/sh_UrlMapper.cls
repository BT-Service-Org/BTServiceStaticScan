global with sharing class sh_UrlMapper implements Site.UrlRewriter {
    //Variables to represent the user-friendly URLs 
    String PRACTICE_PAGE = '/practices/';
    
    //Variables to represent custom Visualforce pages
    String PRACTICE_VF_PAGE = '/sh_practice?name=';

    global PageReference mapRequestUrl(PageReference friendlyUrl) {
		String url = friendlyUrl.getUrl();

        if(url.startsWith(PRACTICE_PAGE)){
            //Extract the practice name from the friendly URL
            String name = url.substring(PRACTICE_PAGE.length(),
                    url.length());
                    
            if (name.endsWith('/')) {
            	name = name.substring(0, name.length() - 1);
            }

            //Construct a new page reference in the form Visualforce page
            return new PageReference(PRACTICE_VF_PAGE + name);
        }
    	return null;     
    }
    global PageReference[] generateUrlFor(PageReference[]
            yourSalesforceUrls) {
    	return null;	
    }
}