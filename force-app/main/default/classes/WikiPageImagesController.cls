public class WikiPageImagesController {
	
	String idWikiPage = System.currentPageReference().getParameters().get('idWP');

   	/* ---------------------------- */
   	/*   	  ATTACH WIKI PAGE		*/
   	/* ---------------------------- */	 	 
	public class AttachmentInfo {
        
        String name;
        String attachImage;
		String id;
        
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
                                        
	}
	
    public List<AttachmentInfo> getAttachments() {
    	List<Attachment> Attachments = new List<Attachment>();
    	if (idWikiPage == '{!idWikiPage}') {
    		Attachments = [select name, id, parentid, ContentType from attachment order by name];
    	}
    	else {
    		Attachments = [select name, id, parentid, ContentType from attachment where parentid=:idWikiPage order by name];
    	}
    	
    	System.debug('\n\n//////////////////////\n SAVE THIS WIKI PAGE ID: ' + idWikiPage +'\nSAVE THIS WIKI PAGE ATTACHMENTS: ' + Attachments + '\n//////////////////////////////////\n\n');
		List<AttachmentInfo> infos = new List<AttachmentInfo>();

		for (Attachment item: Attachments){	
            AttachmentInfo info = new AttachmentInfo();
            info.setId(item.Id);
            info.setName(item.Name);
            
            String ContentType = item.ContentType;
            String image = '';
       		 System.debug('\n\n//////////////////////\n SAVE THIS WIKI PAGE ATTACHMENTS CONTENT TYPE: ' + item.ContentType + '\n//////////////////////////////////\n\n');
       		// MIME TYPE
       		Map<String, String> typesMime = new Map<String, String>{'image/jpeg' => 'images.gif', 'image/png' => 'images.gif', 'image/gif' => 'images.gif', 'image/bmp' => 'images.gif', 'image/pjpeg' => 'images.gif'};	
       		if(typesMime.containsKey(ContentType)) {
       			image = typesMime.get(ContentType);
       		}
            info.setAttachImage(image);
            infos.add(info);
        }	
        System.debug('\n\n//////////////////////\n SAVE THIS WIKI PAGE ATTACHMENTS INFO : ' + infos + '\n//////////////////////////////////\n\n');
		return infos;   	    									
    }     
    
    public Integer getAttachCount () {
    	return [select count() from attachment where parentid=:idWikiPage];
    }
}