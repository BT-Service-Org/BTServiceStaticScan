public class ProjectFeedbackSharing {
   
   public static boolean manualShareAll(Id recordId, Id userOrGroupId){
      // Create new sharing object for the custom object Job.
      Project_Feedback__Share projShr = new Project_Feedback__Share();
	  projShr.ParentId = recordId;
	  projShr.UserOrGroupId = userOrGroupId;
	  projShr.AccessLevel = 'Edit';
	  projShr.RowCause = Schema.Project_Feedback__Share.RowCause.Manual;
	  Database.SaveResult sr = Database.insert(projShr,false);
      //NOT NEEDED AND COMMENTED OUT - NEED TO TEST
      //Project_Feedback__Share jobShr  = new Project_Feedback__Share();
         
      // Process the save results.
      if(sr.isSuccess()){
         // Indicates success
         return true;
      }
      else {
         // Get first save result error.
         Database.Error err = sr.getErrors()[0];
         
         // Check if the error is related to trival access level.
         // Access levels equal or more permissive than the object's default 
         // access level are not allowed. 
         // These sharing records are not required and thus an insert exception is acceptable. 
         if(err.getStatusCode() == StatusCode.FIELD_INTEGRITY_EXCEPTION  &&  
                  err.getMessage().contains('AccessLevel')){
            // Indicates success.
            return true;
         }
         else{
            // Indicates failure.
            return false;
         }
       }
   }
}