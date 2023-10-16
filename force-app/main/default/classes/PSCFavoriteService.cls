public without sharing class PSCFavoriteService {
    public static String createFavourite(String targetType,String target,String name){
        String body;
        FavWrap favWrapObj = new FavWrap();
        favWrapObj.target = target;
        favWrapObj.targetType = targetType;
        favWrapObj.name = name;
        
        body = JSON.serialize(favWrapObj);
        
        HttpRequest req = new HttpRequest();
        req= createReqUtility('/services/data/v55.0/ui-api/favorites','POST',body);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();
        return responseBody;
    }
    
    public static String getFavourites(){
        HttpRequest req = new HttpRequest();
        req= createReqUtility('/services/data/v55.0/ui-api/favorites','GET',null);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();
        return responseBody;
    }

    public static Integer deleteFavourites(String favId){
        
        HttpRequest req = new HttpRequest();
        req= createReqUtility('/services/data/v55.0/ui-api/favorites/'+favId,'DELETE',null);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res.getStatusCode();
    }

    private static HttpRequest createReqUtility(String path, String methodName,String body){
        String host = Url.getOrgDomainUrl().toExternalForm();
        String endpoint = host + path;
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + getUserSessionDetail());
        req.setMethod(methodName);
        req.setEndpoint(endpoint);
        if(body!=null){
            req.setBody(body);
        }
        return req;
    }

    private static String getUserSessionDetail(){
        return UserInfo.getSessionId();
    }

    public class FavWrap{
        public String target;
        public String targetType;
        public String name;
    }
}