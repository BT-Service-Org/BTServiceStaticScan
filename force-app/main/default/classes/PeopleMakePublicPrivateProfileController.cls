public with sharing class PeopleMakePublicPrivateProfileController 
{
	private PeopleProfile__c PP;
	
	//Default Constructor
	public PeopleMakePublicPrivateProfileController()
	{
		//set Current user Id
		CurrentId = UserInfo.getUserId();
		//Current Usert Profile
		PP = [Select p.isPrivate__c From PeopleProfile__c p where p.User__c =: CurrentId limit 1];
		isPrivate = PP.isPrivate__c;
	}
	
	/***********
	** UPDATE **
	************/
	public void updateProfile()
	{
		//Check the current value to toggle this
		boolean nowValue = PP.isPrivate__c;
		if(nowValue)
		{
			PP.isPrivate__c = false;
		}
		else
		{
			PP.isPrivate__c = true;
		}
		update PP;
		//set a new value
		isPrivate = PP.isPrivate__c;
	}
	
	//Current userId
	public String CurrentId { get; set;	}
	
	//Is Private profile
	public boolean isPrivate { get; set; }
}