/**
 * Interface that out lines the key methods for a data fetch from an external org
 */
public interface OrgRefresh_FetchInterface {
     
     /*
      * Method to construct a query string for a given org and application combination
      */
      string constructQuery(String orgAppName, boolean fullRefresh);

     /**
      * Method to fetch from source org , transform and update data in the target org for a given org and app combination
      */
      void fetchAndUpdateData(String accessToken,String orgAppName);
}