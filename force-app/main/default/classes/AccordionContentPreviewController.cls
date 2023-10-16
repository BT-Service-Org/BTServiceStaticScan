public class AccordionContentPreviewController {
	
    @AuraEnabled
    public static String getPreview(String pContentDocumentId){
        
        String contentDocumentId;
        
        if( pContentDocumentId == null ){
            
            contentDocumentId = '0691b000000PIsBAAW';
        }else{
            contentDocumentId = pContentDocumentId;
        }
        HTTPRequest feedRequest = new HTTPRequest();
        //0580M0000009NMmQAM
        //connect/content-hub/repositories/repositoryId/files/repositoryFileId/previews/formatType
		//feedRequest.setEndpoint('callout:Org62APIUser/services/data/v44.0/connect/files/'+contentDocumentId+'/previews/jpg');
		feedRequest.setEndpoint('callout:Org62APIUser/services/data/v44.0/connect/content-hub/repositories/0XC30000000KzGhGAK/files/'+contentDocumentId+'/previews/svg');
		//feedRequest.setEndpoint('callout:Org62APIUser/services/data/v44.0/connect/content-hub/repositories');
        feedRequest.setMethod('GET');
		HTTP http = new HTTP();
		HTTPResponse feedResponse = http.send(feedRequest);
		
        return feedResponse.getBody();
    }
}