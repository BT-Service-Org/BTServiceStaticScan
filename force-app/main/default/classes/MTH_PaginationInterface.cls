public interface MTH_PaginationInterface {
    // Retrieves next page in query given a query string and current page
    Map<Integer, List<SObject>> getNextPage(String query, String orderBy, Integer currPage);

    // Retrieves previous page in query given a query string and current page
    Map<Integer, List<SObject>> getPreviousPage(String query, String orderBy, Integer currPage);

    // Generates a view parameter as a map to pass into view reference
    List<Map<String, String>> generatePaginatorViewParam(
        Boolean hasNextPage,
        Boolean hasPreviousPage,
        Integer currPage,
        Integer totalPages
    );

    // Checks if next page exists given a query string and current page
    Boolean hasNextPage(String query, String orderBy, Integer currPage);

    // Checks if previous page exists given a query string and current page
    Boolean hasPreviousPage(String query, String orderBy, Integer currPage);

    // Gets the total number of pages given a query string
    // Recommended use: Use when view is opened, when updating modal,
    // pass the total pages as a parameter to avoid an extra query.
    // Total pages is available from generatePaginatorViewParam()
    // Use only if you know for certain that the number of items is subject to
    // change on view updates
    Integer totalPages(String query);
}