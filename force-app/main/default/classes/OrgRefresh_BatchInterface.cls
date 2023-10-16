/**
 * Interface that out lines the key methods for a batch fetch from an external org
 */
public interface OrgRefresh_BatchInterface {

     /*
      * Method to construct a query string for a given org and application combination
      */
      string constructSourceQuery();

     /**
      * Method to fetch from source org , transform and update data in the target org for a given org and app combination
      */
      List<OrgRefresh_BatchResult> fetchAndUpdateData(List<SObject> candidateList, String accessToken,String orgAppName, boolean fullRefresh);
}