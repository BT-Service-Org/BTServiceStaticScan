public class AccordionContentController {
	@AuraEnabled
    public static List<Org62_ContentVersion__x> getContentVersionList( 
        String pContentVersionIdList
    ){
        
        if( pContentVersionIdList != null ){
            List<String> idList = pContentVersionIdList.split(',');
            
            List<Org62_ContentVersion__x> contentVersionList = new List<Org62_ContentVersion__x>(
                [
                    SELECT 
                        Id,
                        ContentUrl__c,
                        ContentDocumentId__c,
                        Description__c,
                        Title__c,
                        Next_Review_Date_c__c,
                    	ExternalId,
                    	Asset_Type_c__c,
                    	LastModifiedDate__c,
                    	Visibility_c__c,
                    	ExternalDocumentInfo1__c,
                    	ExternalDocumentInfo2__c
                    FROM 
                        Org62_ContentVersion__x 
                    WHERE 
                        ContentDocumentId__c IN :idList AND
                    	IsLatest__c = true
                ]
            );
        	
            Map<Id, Org62_ContentVersion__x> cvxMap = new Map<Id, Org62_ContentVersion__x>();
            
            for( Org62_ContentVersion__x cvx : contentVersionList ){
                
                cvxMap.put(cvx.ContentDocumentId__c, cvx);
            }
            
            List<Org62_ContentVersion__x> cvxList = new List<Org62_ContentVersion__x>();
            
            for( String s: idList ){
                
                if( cvxMap.get(s) != null ){
                    
                    cvxList.add(cvxMap.get(s));
                }
            }
            
            return cvxList;
        }else{
            return null;
        }
    }
}