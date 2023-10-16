public class MethodSharing {

    public static boolean manualShareWrite(Id recordId, Id userOrGroupId) {
      Method__Share mtdShr  = new Method__Share();
      mtdShr.ParentId = recordId;
      mtdShr.UserOrGroupId = userOrGroupId;
      mtdShr.AccessLevel = 'Edit';
      Database.SaveResult sr = Database.insert(mtdShr,false);
      if(sr.isSuccess()){
         return true;
      }
      else {
         Database.Error err = sr.getErrors()[0]; 
         if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
                  err.getMessage().contains('AccessLevel')){
            return true;
         }
         else{
            return false;
         }
       }
   }
    
   public static void deleteSharing(Id ParentId, Id userOrGroupId, String rowCause) {
       List<Method__Share> sharesToDelete = [SELECT Id 
                                                FROM Method__Share 
                                                WHERE ParentId =:ParentId
                                             	AND userOrGroupId =:userOrGroupId
                                                AND RowCause =:rowCause ];
      if(!sharesToDelete.isEmpty()) {
          try{
              Database.Delete(sharesToDelete,false);
          } catch( Exception ex) {
              System.debug('***Delete Sharing Records Error***' +ex.getMessage());
          }
	  }
   }
}