public with sharing class TeamsWidgetTasksMainController {
	
	String teamId;
	
	// Setter method for Team Id variable
	public void setTeamId(String id) {
		teamId = id;		
	}
	// Getter Team Id variable
	public String getTeamId(){
		return teamId;
	}
	 

	public List<ProjectTask> getTaskResults(){
		return taskResults;
	}
	
	public void setTaskResults(List<ProjectTask> pt){
		taskResults = pt;
	}
	
	Integer listSize = 0;
	public Integer getListSize (){
		return listSize;
	}
	
	/* ---------------------------- */
   	/*   	 SHARING RULES			*/
   	/* ---------------------------- */	
	public UserPermissions userPermissions = null;
	
	public void genPermissions () {
		userPermissions = new UserPermissions();
		userPermissions.setId(UserInfo.getUserId());
		userPermissions.setTeam(teamId);
		userPermissions.setObjectType('Project');
		userPermissions.setPermissions();		
	}
	
	public UserPermissions getUserPermissions () {
		if(userPermissions == null) genPermissions();
		return userPermissions;
	}

	/* ---------------------------- */	
	
	public TeamsWidgetTasksMainController(){
		if(getTeamId()== null) teamId = System.currentPageReference().getParameters().get('id');  
		getAllProjectTasks();
	}
	
	
	
	List<ProjectTask__c> tasks = new List<ProjectTask__c>();
	List<ProjectTask> taskResults = new List<ProjectTask>();
	
	
	public void getAllProjectTasks() {
		
		System.debug('///////////////////////////// teamId: ' + teamId);

		tasks.clear(); 
		tasks = [Select p.Priority__c, 
	 					p.Percent_Completed__c, 
	 					p.Name, 
	 					p.Id, 
	 					p.EndDate__c, 
	 					p.Duration__c, 
	 					p.Team__c,
	 					p.Milestone__c,
	 					p.Description__c, 
	 					(Select User__c, User__r.Name From ProjectAssignee__r) 
	 					From ProjectTask__c  p where  p.Milestone__c = false and p.Team__c =: teamId order by p.EndDate__c asc limit 5
	 					];
	 	
		listSize = 0;
		getProjectTaskbuild();				
	} 
	
	
	public void getMyProjectTasks() {
		
		tasks.clear();
		
		Set<Id> assignedTasks = new Set<Id>();
		for(ProjectAssignee__c p: [SELECT Id,
									      ProjectTask__c
								   FROM ProjectAssignee__c
								   Where ProjectTask__r.Milestone__c = false 
								   AND User__c =: UserInfo.getUserId()
								   Order By ProjectTask__r.EndDate__c asc Limit 5]) {
			assignedTasks.add(p.ProjectTask__c);						   	
		}
		
		tasks = [Select p.Priority__c, 
	 					p.Percent_Completed__c, 
	 					p.Name, 
	 					p.Id, 
	 					p.EndDate__c, 
	 					p.Duration__c, 
	 					p.Description__c, 
	 					(Select User__c, User__r.Name From ProjectAssignee__r ) 
	 					From ProjectTask__c p 
	 					where  Id IN: assignedTasks 
	 					order by p.EndDate__c asc ];
			 		
		listSize = 0;
		getProjectTaskbuild();		
	} 
	
	
	public void getProjectTaskbuild(){
		
		// Retrieve Users Image info
		Set<Id> users = new Set<Id>();		
	 	for( ProjectTask__c task : tasks) {
	 		if(task.ProjectAssignee__r.size() > 0){
				users.add(task.ProjectAssignee__r[0].User__c);
	 		}
	 	}
	 	
	 	Map<Id, User> userMap = new Map<Id,User>();
		for(User u: [SELECT Id, 
							Name, 
							(Select Name, Picture__c From People__r) 
							FROM User u 
							WHERE u.id IN: users]){
			userMap.put(u.Id, u);							
		}
			 	
	 	taskResults.clear();
	 	if(tasks.size() > 0)
	 	{
		 	for( Integer i = 0; i < tasks.size() ; i++){
				ProjectTask miTasks = new ProjectTask();
				miTasks.setTaskName(tasks[i].Name);
				miTasks.setPriority(tasks[i].Priority__c);
				miTasks.setPercent(tasks[i].Percent_Completed__c);
				miTasks.setTaskId(tasks[i].Id);
				if(tasks[i].ProjectAssignee__r.size() > 0){
					miTasks.setUser(userMap.get(tasks[i].ProjectAssignee__r[0].User__c));					
				}
				
				if(tasks[i].EndDate__c != null){
					miTasks.setEndDate(tasks[i].EndDate__c);
					miTasks.setIsToLate(tasks[i].EndDate__c);  
				}
				taskResults.add(miTasks);
		 	}
	 	} 
	 	listSize = taskResults.size();
	 	
	 }
	 
	 public class ProjectTask {
		
        public String TaskId;
        public String Priority;
        public String TaskName;
        public Integer Percent;
        public String UserId;
		public String UserName;
		public String EndDate;
        public String Picture = 'nopicture';
        public String isToLate;
      	DateTime now = System.now();
	
      	public ProjectTask(){		
      	}
      	
      	public void setUser(User user){
        	
        	if(user != null){
       		     UserName = user.name;
	            UserId = user.Id;
	        	
	            if(user.People__r.size() > 0 &&
	               user.People__r[0].Picture__c != null &&
	               user.People__r[0].Picture__c != ''){
	           		Picture = user.People__r[0].Picture__c;
	            } else {
	            	Picture = 'nopicture';
	            }
        	}
        }
      	
      	public String getPicture() {
      		return Picture;
        }
      	
      	public String getEndDate() {
      		return EndDate;
        }
        
        public void setEndDate(Datetime endD){
        	Date miToday = Date.today();
			Date myEndDate = Date.newInstance(endD.year(), endD.month(),endD.day());
			Integer DayDiference = miToday.daysBetween(myEndDate); 		
			if(DayDiference < 2)
        	{	
        		
        		if(DayDiference == 0 )
        		{
        			EndDate = 'Today';
        		}
        		else if(DayDiference == 1 )
        		{
        			EndDate = 'Tomorrow';
        		}
        		else 
        		{
        			EndDate = (DayDiference*-1) +' days late, due ' + endD.format('MM/dd/yy');
        			
        		}
        		
        	}
        	else 
        	{
        		 EndDate =  'Due ' + endD.format('MMMM dd');
           	 	
        	}
        }
        
  		public String getIsToLate() {
      		return isToLate;
        }
        
        public void setIsToLate(Datetime endD){
        	Date miToday = Date.today();
			Date myEndDate = Date.newInstance(endD.year(), endD.month(),endD.day());
			Integer DayDiference = miToday.daysBetween(myEndDate); 	
        	
        	if(DayDiference < 1){
        		isToLate = 'latter';	
        	}
            else {
            	isToLate = '';
            }
        }
        
        public String getUserId() 
        {
      		return UserId;
        }
        
    	public String getUserName() 
    	{
       		return UserName;
        }
      	
      	public String getTaskId() 
      	{
            return TaskId;
        }
        public void setTaskId(String idTask)
        {
            TaskId = idTask;
        }
        
        public String getPriority() 
        {
            return Priority;
        }
        public void setPriority(String pr)
        {
            Priority = pr;
        }
        
        public Integer getPercent() 
        {
            return Percent;
        }
        
        public void setPercent(Double per)
        {
        	if(per == null)
        	{
        		 Percent = 0;
        	}
        	else
        	{
        		 Percent = per.intValue();
        	}
        }
        
      	public String getTaskName() 
      	{
            return TaskName;
        }
        public void setTaskName(String sName)
        {
            TaskName = sName;
        }
	        

	       
	}	
}