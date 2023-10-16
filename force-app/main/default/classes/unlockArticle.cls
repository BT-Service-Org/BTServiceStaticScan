/*******************************************************************************************************
Name          : unlockArticle
:
@description  : Unlock the Knowledge record once submitted to Review.
:
Revision Log  : 
:


********************************************************************************************************/
public class unlockArticle {
    
    @InvocableMethod
    public static void unlockArticleMethod(List<Id> RecordIds)   {
        
        for(Id articleId :RecordIds){
            if(Approval.isLocked(articleId)){
                Approval.unlock(articleId);
            }
        }
    }
}