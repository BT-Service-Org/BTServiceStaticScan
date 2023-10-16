global without sharing class sh_SearchController {
    public Static String domainVariable{get; set;}
    public List<SearchResult> searchResults {get; set;}
    public List<SearchResult> fullResults {get; set;}
    public Integer numResults {get; set;}
    public Static List<SearchCriteria> criteria {get; set;}
    public NavigationInfo nav {get; set;}
    
    public sh_SearchController() {
        String searchString = null;
        String projectType = null;
        String client = null;
        String industry = null;
        String year = null;
        String page = null;
        criteria = new List<SearchCriteria>();
        
        domainVariable= sh_URLUtility.GetPrefix();
        
        Map<String, String> UrlParameterMap = ApexPages.currentPage().getParameters();
     
        searchString = UrlParameterMap.get('searchString');
        projectType = UrlParameterMap.get('projectType');
        client = UrlParameterMap.get('client');
        industry = UrlParameterMap.get('industry');
        year = UrlParameterMap.get('year');
        page = UrlParameterMap.get('page');
        
        fullResults = executeSearch(searchString, projectType, client, industry, year);
        //searchResults = fullResults;
        setNavInfo(page);
    }
    
    
    @remoteAction 
    public static List<SearchResult> search(string searchString){
      return searchComplete(searchString,Null,Null,Null,Null);
        
    }
    
    private static List<SearchResult> searchComplete(String searchString, String projectType, String client, String industry, String year) {
        criteria = new List<SearchCriteria>();
        Map<Id, SearchResult> searchResults = new Map<Id, SearchResult>();
        Boolean performedSearch = false;
        Boolean haveBios = false;
        List<sh_Project__c>  projects = null;
        List<sh_Bio__c>  bios = null;
        
        String whereClause = getProjectWhereClause(projectType, client, industry, year);
        
        //Check if we have a valid search string and perform a search
        if (searchString != null && searchString.length() > 1) {
            performedSearch = true;
            String searchQuery = '      FIND \'' + searchString + '*\' IN ALL FIELDS '
                              +  ' RETURNING sh_Project__c(id, name, Project_Name__c, Year__c ';
    
            //We want to search for Bios only when there is no where clause since 
            //where clause is only applicable to projects
            if (whereClause != '') {
                searchQuery += whereClause + ')';
            } else {
                haveBios = true;
                searchQuery +=  '), sh_Bio__c(id, name, Bio_Name__c, Bio_Title__c)';
            }   
    
            System.debug('>>>>> Search Query: ' + searchQuery);
            
            List<List<SObject>> searchList = Search.query(searchquery);
            projects = (List<sh_Project__c>)searchList[0];
            if (haveBios) {
                bios = (List<sh_Bio__c>)searchList[1];
            }
            
            criteria.add(getSearchCriteria('searchString', searchString));
        }
        
        //If we did not do search, do a simple query 
        if (!performedSearch) {
            projects = (List<sh_Project__c>)Database.query('SELECT id, name, Project_Name__c, Year__c '
                                                        +  '  FROM sh_Project__c ' + whereClause);
            
            //Get bios
            if (whereClause == '') {
                haveBios = true;
                bios = [SELECT id, name, Bio_Name__c, Bio_Title__c from sh_Bio__c];
            }
        }
        
        //numResults = 0;
        
        for (sh_Project__c project : projects) {
            SearchResult sr = new SearchResult();
            sr.resultType = 'Project';
            sr.id = project.id;
            sr.name = project.name;
            sr.code = project.Project_Name__c;
            sr.projectYear = project.Year__c;
            
            searchResults.put(sr.id, sr);
            
            //numResults++;
        }
        
        //Use Bios object only if we queried for bios
        if (haveBios) {
            for (sh_Bio__c bio : bios) {
                SearchResult sr = new SearchResult();
                sr.resultType = 'Bio';
                sr.id = bio.id;
                sr.name = bio.name;
                sr.code = bio.Bio_Name__c;
                sr.bioTitle = bio.Bio_Title__c;
                
                searchResults.put(sr.id, sr);
                
                //numResults++;
            }
        }
        
        List<Attachment> thumbnailImages = [select id, ParentId, name 
                                              from Attachment 
                                             where ParentId in :searchResults.keySet() 
                                               and name in ('ThumbnailImage', 'BioPicture')];
        
        for (Attachment img : thumbnailImages) {
            searchResults.get(img.ParentId).imageAttachmentId = img.id;
        }
        
        return searchResults.values();
    
    }

    public List<SearchResult> executeSearch(String searchString, String projectType, String client, String industry, String year) {
       List<SearchResult>  results =  searchComplete(searchString,projectType,client,industry,year);
       numResults = results.size();
       return results;
        
    }
    
    private Static String getProjectWhereClause(String projectType, String client, String industry, String year) {
        String whereClause = '';
        
        if (projectType != null && projectType != '') {
            whereClause += 'Type__c includes (:projectType)';
            
            criteria.add(getSearchCriteria('projectType', projectType));
        }
        if (industry != null && industry != '') {
            if (whereClause != '') {
                whereClause += ' and ';
            }
            whereClause += 'Industry__c includes (:industry)';

            criteria.add(getSearchCriteria('industry', industry));
        }
        if (client != null && client != '') {
            if (whereClause != '') {
                whereClause += ' and ';
            }
            whereClause += 'Client__c = :client';

            criteria.add(getSearchCriteria('client', client));
        }
        if (year != null && year != '') {
            if (whereClause != '') {
                whereClause += ' and ';
            }
            whereClause += 'Year__c = :year';

            criteria.add(getSearchCriteria('year', year));
        }
        
        if (whereClause != '') {
            whereClause = ' where ' + whereClause;
        }
        
        return (whereClause);
    }
    
    private Static SearchCriteria getSearchCriteria(String criteriaName, String criteriaValue) {
        SearchCriteria sc = new SearchCriteria();
        sc.display = criteriaValue;
        
        sc.url = domainVariable + '/sh_search?' + criteriaName + '=' + criteriaValue;
        
        return (sc);
    }
    
    private void setNavInfo(String page) {
        Integer resultsCount = fullResults.size();
        //If number of items is less than or equal to 10, there is no need to show navigation. 
        if (resultsCount <= 10) {
            nav = new NavigationInfo();
            nav.showNavigation = false;
            searchResults = fullResults;
            return;
        }
        
        //We need to show navigation
        nav = new NavigationInfo();
        nav.showNavigation = true;
        
        Integer currentPage = 1;
        
        //Set correct value of current page
        if (page != null && page != '') {
            currentPage = Integer.valueOf(page);
            
            //Check if we have less results than the page being requested
            //if yes, then use currentPage as 1
            if (resultsCount <= (currentPage - 1) * 10) {
                currentPage = 1;
            }
        }
        
        nav.currentPage = currentPage;
        
        //Set prev page
        if (currentPage == 1) {
            nav.showPrev = false;
            nav.showCurrent = false;
        } else {
            nav.showCurrent = true;
            nav.showPrev = true;
            nav.prevPage = currentPage - 1;
        }
        
        //Set last page
        Integer lastPage = resultsCount / 10;
        if (Math.mod(resultsCount, 10) != 0) {
            lastPage++;
        }
        nav.lastPage = lastPage;
        
        if (currentPage == lastPage) {
            nav.showNext = false;
            nav.showCurrent = false;
        } else {
            nav.showCurrent = true;
            nav.showNext = true;
            nav.nextPage = currentPage + 1;
        }
        
        //Set whether ellipsis should be shown or not
        if (Math.abs(nav.currentPage - 1) > 1) {
            nav.showFirstEllipsis = true;
        } else {
            nav.showFirstEllipsis = false;
        }
        if (Math.abs(nav.currentPage - nav.lastPage) > 1) {
            nav.showSecondEllipsis = true;
        } else {
            nav.showSecondEllipsis = false;
        }
        
        //Populate results list from full list based on page number
        Integer startIndex = (currentPage - 1) * 10;
        Integer endIndex = (currentPage * 10) - 1;
        if (endIndex > (resultsCount - 1)) {
            endIndex = resultsCount - 1;
        }
        searchResults = new List<SearchResult>();
        
        for (Integer i = startIndex; i <= endIndex;  i++) {
            searchResults.add(fullResults.get(i));
        }
        
        //Set search parameters to be used on navigation links
        nav.allSearchParms = '';
        for (SearchCriteria sc : criteria) {
            if (nav.allSearchParms != '') {
                nav.allSearchParms += '&';
            } 
            
            Integer startPos = sc.url.indexOf('sh_search?') + 10;
            nav.allSearchParms += sc.url.subString(startPos);
        }
    }
    
    public class SearchResult {
        public String id {get; set;}
        public String resultType {get; set;}
        public String name {get; set;}
        public String code {get; set;}
        public String imageAttachmentId {get; set;}
        public String bioTitle {get; set;}
        public String projectYear {get; set;}
    }
    
    public class SearchCriteria {
        public String display {get; set;}
        public String url {get; set;}
    }
    
    public class NavigationInfo {
        public Boolean showPrev {get; set;}
        public Boolean showCurrent {get; set;}
        public Boolean showNext {get; set;}
        public Boolean showNavigation {get; set;}
        public Boolean showFirstEllipsis {get; set;}
        public Boolean showSecondEllipsis {get; set;}
        public Integer prevPage {get; set;}
        public Integer currentPage {get; set;}
        public Integer nextPage {get; set;}
        public Integer lastPage {get; set;}
        public String  allSearchParms {get; set;}
    }
}