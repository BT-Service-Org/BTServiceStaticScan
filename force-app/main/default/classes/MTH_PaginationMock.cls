@isTest
public with sharing class MTH_PaginationMock implements MTH_PaginationInterface {
    
    public Map<Integer, List<SObject>> pageMap = new Map<Integer, List<SObject>>();

    public Map<Integer, List<SObject>> getNextPage(String query, String orderBy, Integer currPage) {
        return pageMap;
    }

    public Map<Integer, List<SObject>> getPreviousPage(String query, String orderBy, Integer currPage) {
        return pageMap;
    }

    public List<Map<String, String>> generatePaginatorViewParam(
        Boolean hasNextPage,
        Boolean hasPreviousPage,
        Integer currPage,
        Integer totalPages
    ) {
        Map<String, String> paginatorMap = new Map<String, String>();
        return new List<Map<String, String>>{paginatorMap};
    }

    public Boolean hasNextPage(String query, String orderBy, Integer currPage) {
        return false;
    }

    public Boolean hasPreviousPage(String query, String orderBy, Integer currPage) {
        return false;
    } 

    public Integer totalPages(String query){
        return 1;
    }
}