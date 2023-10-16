@IsTest private class WikiVersionsTest {
    public static testMethod void testWiki() {
        try{
            WikiVersionsController wiki = new WikiVersionsController();
            
            WikiVersionsController.InfoRev infoRev = new WikiVersionsController.InfoRev();
            infoRev.setModifiedBy('Some Name');
            infoRev.getModifiedBy();
            infoRev.setBody('<br />');
            infoRev.getBody();
            infoRev.setRevisionCount(1);
            infoRev.getRevisionCount();
            infoRev.setId('Some Id');
            infoRev.getId();
            infoRev.setName('Some Name');
            infoRev.getName();
            infoRev.setLastModifiedDate(System.now());
            infoRev.getLastModifiedDate();
            
            List<WikiVersionsController.InfoRev> listRevisions = wiki.getRevisionsList(); 
            
            WikiPage__c wp = [select Id from WikiPage__c limit 1];
            WikiVersions__c wv = [select Id from WikiVersions__c limit 1];
            
            wiki.setIdWikiPage(wp.Id);
            wiki.setIdRevL(wv.Id);
            wiki.setIdRevR(wv.Id);
            
            WikiVersionsController.InfoRev infoRev2 = wiki.getRevLeftBody();
            WikiVersionsController.InfoRev infoRev3 = wiki.getRevRightBody();
            wiki.saveLeft ();
            wiki.saveRight ();
            wiki.getWikiInfo();
            wiki.getGoDiff();
            wiki.getGoLeft();
            wiki.getWikiLeft();
        
        }catch(Exception e){
            throw e;
        }   
    }   
}