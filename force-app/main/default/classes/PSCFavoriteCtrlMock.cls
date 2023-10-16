@isTest
public with sharing class PSCFavoriteCtrlMock {
    public class GetFavoriteSuccess implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
           	String successRes= '{"favorites":[{"accessCount":1,"iconColor":"F2CF5B","iconUrl":"https://sfservices--dighqdev.sandbox.my.site.com/img/icon/t4v35/standard/article_120.png","id":"0MV3C000000LahSWAS","lastAccessDate":"2022-11-01T13:42:22.000Z","name":"Ethical Use of Data","objectType":"Knowledge__kav","sortOrder":1,"subtitle":"Knowledge","target":"ka13C0000009gLAQAY","targetType":"Record"}]}';
            res.setBody(successRes);
            res.setStatusCode(204);
            return res;  
        }
    }
}