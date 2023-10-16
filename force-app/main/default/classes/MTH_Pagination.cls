public with sharing class MTH_Pagination implements MTH_PaginationInterface {
    private Integer itemsPerPage = 20;
    public final String NEXT_PAGE = 'next_page';
    public final String PREVIOUS_PAGE = 'previous_page';

    public MTH_Pagination() {
    }

    public MTH_Pagination(Integer itemsPerPage) {
        this.itemsPerPage = itemsPerPage;
    }

    public Boolean hasNextPage(String query, String orderBy, Integer currPage) {
        Integer targetPage = currPage + 1;
        return hasPage(query, orderBy, targetPage);
    }

    public Boolean hasPreviousPage(String query, String orderBy, Integer currPage) {
        Integer targetPage = currPage - 1;
        return hasPage(query, orderBy, targetPage);
    }

    // Recommend using this method after checking hasNextPage() in calling class
    public Map<Integer, List<SObject>> getNextPage(String query, String orderBy, Integer currPage) {
        Integer targetPage = currPage + 1;
        return getPage(query, orderBy, targetPage);
    }

    // Recommend using this method after checking hasPreviousPage() in calling class
    public Map<Integer, List<SObject>> getPreviousPage(
        String query,
        String orderBy,
        Integer currPage
    ) {
        Integer targetPage = currPage - 1;
        return getPage(query, orderBy, targetPage);
    }

    public Integer totalPages(String query) {
        AggregateResult[] result = Database.query(query);
        Integer count = (Integer) result[0].get('queryCount');
        
        if (count < itemsPerPage) {
            return 1;
        }
        Integer totalPages = (Integer) ((Decimal) count / (Decimal) itemsPerPage).round(system.RoundingMode.CEILING);
        return totalPages;
    }

    public List<Map<String, String>> generatePaginatorViewParam(
        Boolean hasNextPage,
        Boolean hasPreviousPage,
        Integer currPage,
        Integer totalPages
    ) {
        return new List<Map<String, String>>{
            new Map<String, String>{
                'hasNextPage' => String.valueOf(hasNextPage),
                'hasPreviousPage' => String.valueOf(hasPreviousPage),
                'currPage' => String.valueOf(currPage),
                'totalPages' => String.valueOf(totalPages)
            }
        };
    }

    private String calculateQueryLimitAndOffset(String orderBy, Integer pageNum) {
        if (pageNum == 1) {
            return ' ORDER BY ' + orderBy + ' LIMIT ' + String.valueOf(itemsPerPage);
        }

        Integer offset = (pageNum - 1) * itemsPerPage;

        return ' ORDER BY ' +
            orderBy +
            ' LIMIT ' +
            String.valueOf(itemsPerPage) +
            ' OFFSET ' +
            String.valueOf(offset);
    }

    private Boolean hasPage(String query, String orderBy, Integer targetPage) {
        if (targetPage == 0) {
            return false;
        }

        String limitAndOffset = calculateQueryLimitAndOffset(orderBy, targetPage);
        List<SObject> results = Database.query(query + limitAndOffset);

        if (results.size() == 0) {
            return false;
        }

        return true;
    }

    private Map<Integer, List<SObject>> getPage(String query, String orderBy, Integer targetPage) {
        Map<Integer, List<SObject>> page = new Map<Integer, List<SObject>>();
        String limitAndOffset = calculateQueryLimitAndOffset(orderBy, targetPage);
        List<SObject> results = Database.query(query + limitAndOffset);
        page.put(targetPage, results);
        return page;
    }
}