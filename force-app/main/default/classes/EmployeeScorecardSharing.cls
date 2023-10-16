public class EmployeeScorecardSharing {

	public static boolean manualShareAll(Id recordId, Id userOrGroupId){
      // Create new sharing object for the custom object Job.
      Employee_Scorecard__Share esShr = new Employee_Scorecard__Share();
	  esShr.ParentId = recordId;
	  esShr.UserOrGroupId = userOrGroupId;
	  esShr.AccessLevel = 'Edit';
	  esShr.RowCause = Schema.Employee_Scorecard__Share.RowCause.Manual;
	  Database.SaveResult sr = Database.insert(esShr,false);
         
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