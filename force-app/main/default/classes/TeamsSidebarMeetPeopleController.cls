public class TeamsSidebarMeetPeopleController {
	
	//Constructor
	public TeamsSidebarMeetPeopleController()
	{
		UsersList();
	}	
	
	//UsersList
	public void UsersList()
	{
		//List of Users
		List<User> users = new List<User>();
		users = [SELECT Id, 
				Name, 
				(Select Name, Picture__c From People__r) 
				FROM User u where IsActive = true LIMIT 500];
		
		//Random Index of List
		List<Integer> index = new List<Integer>();
		//Ensures unique ID
		Set<Integer> uniqueId = new Set<Integer>();
		//6 users or less -  Show ALL
		if(users.size() < 6)
		{
			for(Integer i = 0; i <users.size(); i++ ) 
			{
				index.add(i);	
			}
		}
		else 
		{
			//6 result
			while(index.size() < 6)
			{	
				Boolean big = false;
				while(!big)
				{
					//Random Double
					Double rnd =  Math.random();
					String subS = String.valueOf(rnd);
					//Last two digits
					if (subs.length() > 8 && subs.indexOf('E') == -1) {
						subS = subS.substring(subS.length() - 5, subS.length());
						Integer ran  = Math.mod(Integer.valueOf(subS), users.size());
						//if random match in the list and unique, add to index
						if( ran < users.size() && !uniqueId.contains(ran) && ran >= 0)
						{
							index.add(ran);
							uniqueId.add(ran) ;
							big = true;
						}
					}
				}	
			}
		}
		
		//Populate the list of Users Random
		if(users.size() > 0)
		{
			for(Integer i=0; i<index.size(); i++) 
			{
				RandomUsers t = new RandomUsers();
				
				t.name = users[index[i]].Name;
				t.id = users[index[i]].Id;
				
				if(users[index[i]].People__r.size() > 0 && users[index[i]].People__r[0].Picture__c != null)
				{
					t.picture = users[index[i]].People__r[0].Picture__c;
				}
				else 
				{
					t.picture = '';
				}
				
				userList.add(t);
			}
		}
	}
	
	List<RandomUsers> UserList = new List<RandomUsers>();
	
	//GET List
	public List<RandomUsers> getUserList()
	{
		return UserList;
	}
	
	//Inner Class for Users
	public class RandomUsers
	{
		//Getters and Setters
		public String id { get; set; }
		public String name 
		{ 
			get; 
			set
			{
				if(value.length() > 15)
				{
					name = value.substring(0,13) + '...';
				}
				else
				{
					name = value;	
				}
			} 
		}
		public String picture 
		{ 	
    		set
    		{
	        	if(value == '')
	        	{
	        		picture = 'null';
	        	}
	        	else
	        	{					
	        		picture = '/servlet/servlet.FileDownload?file=' + value;
	        	}
    		} 
    		get; 
    	
    	}
	}
}