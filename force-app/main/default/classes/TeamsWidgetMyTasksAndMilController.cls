public with sharing class TeamsWidgetMyTasksAndMilController {
    
    
    //Constructor
    public TeamsWidgetMyTasksAndMilController()
    {
        
    }
    
    public Boolean displayTitle = false;
    public Integer getOverdueAlreadyShow(){
    	return overdueAlreadyShow;
    }
	public String currentDate = '';
	public Integer overdueAlreadyShow = 0;
	public Integer countTask = 0;
    
    public Integer listSize{ get; set; }
    
    // List Of Task
    public List<ProjectTasks> getAllProjectTasks() 
    {
	    //All Project task
	    List<ProjectTask__c> allProjects = new List<ProjectTask__c>();
	    //5 Project assign to Me
	    List<ProjectTask__c> myProjects = new List<ProjectTask__c>();
	    //All Project assign to me - Inner Class
	    List<ProjectTasks> result = new List<ProjectTasks>(); 
	    
	    //Populate allProjects  
	    allProjects = [Select  p.Id, 
	                        (Select User__c From ProjectAssignee__r) 
	                        From ProjectTask__c  p 
	                        ];
	                          
	    // Set id of Project assign to me
	    Set<Id> projToMe = new Set<Id>();
	    for( ProjectTask__c project : allProjects) {
	        if(project.ProjectAssignee__r.size() > 0 )
	        {
	        	for(Integer i=0; i<project.ProjectAssignee__r.size(); i++)
	        	{
	        		if(project.ProjectAssignee__r[i].User__c == Userinfo.getUserId())
	        		{
	        			projToMe.add(project.Id);
	        		}	        		
	        	}
	            
	        }
	    }

	    //Populate myProjects
	    myProjects = [ Select 
	     				p.Priority__c, 
	     				p.Name, 
	     				p.Milestone__c, 
	     				p.Id, p.EndDate__c,
	     				p.Percent_Completed__c, 
	     				p.Duration__c
	     				From ProjectTask__c  p where p.Id in : projToMe and p.EndDate__c != null  order by p.EndDate__c asc ];
  	    
        for( ProjectTask__c pro : myProjects) 
        {
            if(pro.Percent_Completed__c < 100 || pro.Percent_Completed__c == null)
            	{
                	ProjectTasks myTask = new ProjectTasks();
                	if(pro.EndDate__c < System.now())
	                {
	                	myTask.overDue = true;	                
	                	overdueAlreadyShow = overdueAlreadyShow + 1;	                	
	                } else 
	                {
	                	myTask.overDue = false;
	                }
	                
                	if((currentDate != (pro.EndDate__c).format('MM/dd/yyyy') ))
                	{
                		if(myTask.overDue)
                		{
	                		if(overdueAlreadyShow > 1)
	                		{              		
	                			myTask.displayTitle = false;
	                		} else 
	                		{
	                			myTask.displayTitle = true;
	                		}
                		} 
                		else 
                		{
                			myTask.displayTitle = true;
                		}
                	} 
                	else 
                	{
                		myTask.displayTitle = false;
                	}  
		                        
	                myTask.TaskName = pro.Name;
	                myTask.TaskId = pro.Id;
					myTask.setDaysCount(pro.EndDate__c, pro.Duration__c);
	                if(pro.Priority__c == '' || pro.Priority__c == null)
	                {
	                	myTask.Priority = 'Normal';
	                }
	                else 
	                {
	                	myTask.Priority = pro.Priority__c;
	                }
	                myTask.setEndDate(pro.EndDate__c);            
	                myTask.setIsToLate(pro.EndDate__c);  
	                myTask.isMilestone  = pro.Milestone__c;	
	            	if(countTask < 5 && countTask < myProjects.size())
	            	{
	            		result.add(myTask);
	            		countTask ++;
	            	}        	 
	                currentDate = (pro.EndDate__c).format('MM/dd/yyyy');
               }
     		} 
			listSize = result.size();
	        return result;
    }
    
     public class ProjectTasks {

        public String DaysCount;
        public String UserId;
        public String UserName;
        public String EndDate;
        public String EndDateRight;
        public String isToLate;
        
        DateTime now = System.now();
        
        public String TaskId{ get; set; }
        public String Priority{ get; set; }
        public String TaskName
        { 
        	get; 
        	set
        	{
        		if(value.length() > 22)
        		{
        			TaskName = value.substring(0,20) + '...';
        		}
        		else
        		{
        			TaskName = value;
        		}
        		
        	} 
        }
		public Boolean isMilestone{ get; set; }
		public String taskDateClass{ get; set; }
		public Boolean overDue{ get; set; }
		public Boolean displayTitle{ get; set; }

        public String getEndDate() {
            return EndDate;
        }
        
        public void setEndDate(Datetime endD)
        {           
             
            EndDate =  endD.format('MM/dd/yyyy');
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
        
        public String getDaysCount() {
            return DaysCount;
        }
       
        public void setDaysCount(Datetime endD, Double dur){
            
            Date miToday = Date.today();
            Date endDate = Date.newInstance(endD.year(), endD.month(),endD.day());
            Integer DayDiference = miToday.daysBetween(endDate);   
               
            if(DayDiference < 2)
            {   
                if(DayDiference == 1 )
                {
                    DaysCount = 'Due Tomorrow';
                }
                else if(DayDiference == 0 )
                {
                    DaysCount = 'Due Today';
                }
                else 
                {
                    
                    DaysCount =  (DayDiference*-1) +' days late,';
                }
                
            }
            else 
            {
                 DaysCount = 'Due in ' + DayDiference +' days';
                
            }
        }
     }

}