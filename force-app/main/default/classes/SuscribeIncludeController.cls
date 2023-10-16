public class SuscribeIncludeController {
	
	public String USERID = System.currentPageReference().getParameters().get('id');
	
	public String getId(){
		return USERID;
	}
	
	public User p = new User();
	
	public SuscribeIncludeController(){
		p = [SELECT Id,
		 						
		 						Name,
		                        FirstName,
		                        LastName,
		                        Title,
		                        Division,
		                        Department,
		                        Phone,
		                        MobilePhone,
		                        Fax,
		                        Email	                                                           
		                        FROM User
		                        WHERE Id =: USERID];
		System.Debug('\n ///////////////////////////////// \n ' + p);
		
	}
	
	public User getMan(){
		
		return p;
	}
	
}