public class TeamsWidgetAttachmentsController {
	
	String teamId;
	public List<AttachmentInfo> attachs = new List<AttachmentInfo>();
	
	// Setter method for Team Id variable
	public void setTeamId(String id) {
		teamId = id;
		currentTeam();
		genPermissions();
		getAttachments();
	}
	
	// Getter Team Id variable
	public String getTeamId(){
		return teamId;
	}
	
	/**
	*@return List<AttachmentInfo
	*/
	public List<AttachmentInfo> getAttachs(){
		return attachs;
	}
	
	public void refresh() {
		getAttachments();
	} 
	
	//Constructor
	public TeamsWidgetAttachmentsController(){
	}
	
	//set the current team Picture
	public void currentTeam() {
		teamInfo = [Select 
	                t.Picture__c, CreatedById
	                From Team__c t Where t.Id =:teamId];
	    PictureIDSet();	
	}
	
	public String PictureID{get; set;}

	//set Id of current Picture inside Team__c.Picture__c 
	public void PictureIDSet () {
		if(teamInfo.Picture__c != null){
			PictureID = teamInfo.Picture__c;	    	
        }
	}
	
	public Team__c teamInfo = new Team__c();
	
	public Team__c getTeamInfo () {
		return teamInfo;
	}
	
	public void setTeamInfo (Team__c teamInfo) {
		this.teamInfo = teamInfo;
	}
	
    public void getAttachments() {
    	
    	List<Attachment> Attachments = [select name, 
    											id, 
    											parentid, 
    											ContentType, 
    											BodyLength, 
    											LastModifiedDate, 
    											LastModifiedBy.Name
    									from attachment 
    									where parentid=:teamId 
    									order by name];		
    									
		List<AttachmentInfo> infos = new List<AttachmentInfo>();

		for (Attachment item: Attachments){	
            AttachmentInfo info = new AttachmentInfo();
            info.setId(item.Id);
            info.setName(item.Name);
            info.setAttachment(item);
            
            String ContentType = item.ContentType;
            String image = '';
            
            //Exclude current team avatar
            if(PictureID == item.Id)
            	continue;
            
            if (ContentType == null || ContentType == '') {
            	// LO HAGO POR LA EXTENSION
            	Integer extPos = item.Name.lastIndexOf('.') + 1;
            	String extension = item.Name.substring(extPos);	
           		Map<String, String> typesExt = new Map<String, String>{'rar' => 'rar.gif', 'xls' => 'xls.gif', 'ppt' => 'ppt.gif', 'avi' => 'video.gif', 'mpeg' => 'video.gif', 'flv' => 'video.gif','mpg' => 'video.gif', 'mp3' => 'audio.gif' , 'wav' => 'audio.gif'};	
           		if(typesExt.containsKey(extension)) {
           			image = typesExt.get(extension);
           		}
           		else {
           			image = 'generic.gif';
           		}
            }
            else {
           		// LO HAGO POR EL MIME TYPE
           		Map<String, String> typesMime = new Map<String, String>{'image/jpeg' => 'images.gif', 'image/png' => 'images.gif', 'image/gif' => 'images.gif', 'image/bmp' => 'images.gif', 'application/pdf' => 'pdf.gif', 'text/plain' => 'txt.gif','application/msword' => 'doc.gif', 'application/x-zip-compressed' => 'zip.gif'};	
           		if(typesMime.containsKey(ContentType)) {
           			image = typesMime.get(ContentType);
           		}
           		else {
           			image = 'generic.gif';
           		}
            }
            
            info.setAttachImage(image);
            infos.add(info);
        }	
		attachs = infos;   	    									
    }     
    
    public Integer getAttachCount () {
    	return attachs.size();
    }
    
    
    /* ---------------------------- */
   	/*   	 SHARING RULES			*/
   	/* ---------------------------- */	
	public UserPermissions userPermissions = new UserPermissions();
	
	public void genPermissions () {
		userPermissions.setId(UserInfo.getUserId());
		userPermissions.setTeam(teamId);
		userPermissions.setOwnerId(teamInfo.CreatedById);
		userPermissions.setObjectType('Team');
		userPermissions.setPermissions();
	}
	
	public UserPermissions getUserPermissions () {
		if(userPermissions == null) genPermissions();
		return userPermissions;
	}
    
    

   	/* ---------------------------- */
   	/*   	  DELETE ATTACH			*/
   	/* ---------------------------- */  
   	
   	public void DeleteAttach () { 
   		String idAttach = System.currentPageReference().getParameters().get('idAttach');
   		Attachment delAttach;
   		if(idAttach != null && idAttach!= '')
   		{
   			try{
	   			delAttach = [select Id, Name from Attachment where id =:idAttach ];
	   			delete delAttach; 
   				//update attachments list
   				getAttachments();
   			}catch(Exception e){
   				throw e;
   			}
   		}
   		
   	}

   	/* ---------------------------- */
   	/*   	  ATTACH WIKI PAGE		*/
   	/* ---------------------------- */	 	 
	public class AttachmentInfo {
        
        String name;
        String attachImage;
		String id;
		Attachment attach;
		      
        public String getId () {
        	return id;
        }
        
        public void setId (String id) {
        	this.id = id;
        }
        
        public String getName() {
                return name;
        }

        public void setName(String name) {
                this.name = name;
        }  
        
        public String getAttachImage() {
                return attachImage;
        }

        public void setAttachImage (String attachImage) {
                this.attachImage = attachImage;
        }          

        public void setAttachment (Attachment attach) {
                this.attach = attach;
        }
        
        public Attachment getAttachment() {
                return attach;
        }
                                     
	}

}