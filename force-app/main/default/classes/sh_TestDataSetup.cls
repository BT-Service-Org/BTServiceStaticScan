public with sharing class sh_TestDataSetup {
	public static List<Attachment> attachments {get; set;}
	public static Id acPracId {get; set;}
	public static Id bioId {get; set;}
	public static Id singleAttachment {get; set;}
	
	
  public static void createPractices() {
  	 attachments = new List<Attachment>();
  	 createPractice('services-1', 'Services-1', false, 0);
  	 createPractice('services-2', 'Services-2', false, 0);
  	 acPracId = createPractice('analytics-cloud-practice', 'Analytics Practice', true, 1);
  	 createPractice('customer-experience-design', 'CXD', true, 2);
  	 insert (attachments);
  	 
  	 createProjects (acPracId, null);
  }
  
  public static Id createPractice(String practiceName, String practiceTitle, Boolean isPractice, Integer sequence) {
  	sh_Practice__c prac = new sh_Practice__c();
  	prac.name = practiceTitle;
  	prac.Practice_Name__c = practiceName;
  	prac.isPractice__c = isPractice;
  	prac.Sequence__c = sequence;
  	insert (prac);
  	
  	if (attachments == null) {
  		attachments = new List<Attachment>();
  	}

    if (practiceName != 'services-2') {  	
    	Blob bodyBlob = Blob.valueOf('A simple text file.');
	  	Attachment qf1 = new Attachment(name = 'QuickFact1', parentid = prac.Id, body = bodyBlob);
	  	attachments.add(qf1);
	  	Attachment qf2 = new Attachment(name = 'QuickFact2', parentid = prac.Id, body = bodyBlob);
	  	attachments.add(qf2);
	  	Attachment qf3 = new Attachment(name = 'QuickFact3', parentid = prac.Id, body = bodyBlob);
	  	attachments.add(qf3);
	  	Attachment qf4 = new Attachment(name = 'QuickFact4', parentid = prac.Id, body = bodyBlob);
	  	attachments.add(qf4);
	    Attachment fs = new Attachment(name = 'FactSheet', parentid = prac.Id, body = bodyBlob);
	  	attachments.add(fs);
    }
    
    return (prac.id);
  }
  
  public static void createBios(Id practiceId) {
  	List<sh_bio__c> bios = new List<sh_bio__c>();
  	sh_bio__c bio = createBio('Shashidhar Gurumurthy', 'shashidhar-gurumurthy');
  	bioId = bio.Id;
  	bios.add(bio);
  	
  	bio = createBio('Amisha Goyal', 'amisha-goyal');
  	bios.add(bio);
  	
  	createBio('Justin Waite', 'justin-waite');
  	bios.add(bio);
  	
  	createProjects (null, bioId); 
  	
  	if (practiceId != null) {
  		createPracticeLeaders(practiceId, bios);
  	}
  }
  
  private static sh_bio__c createBio(String name, String bioCode) {
  	sh_bio__c bio = new sh_bio__c(name = name, Bio_Name__c = bioCode);
  	insert (bio);
  	
  	Blob bodyBlob = Blob.valueOf('A simple text file.');
	Attachment bioPic = new Attachment(name = 'BioPicture', parentid = bio.Id, body = bodyBlob);
	insert(bioPic);
	Attachment bioDoc = new Attachment(name = 'BioDocument', parentid = bio.Id, body = bodyBlob);
	insert(bioDoc);
  	
  	return (bio);
  }
  
  private static void createPracticeLeaders(Id practiceId, List<sh_bio__c> bios) {
  	System.debug('>>>>>>>>>>>>>>>>>>>practiceId: ' + practiceId);
  	sh_Practice_Leader__c pl1 = new sh_Practice_Leader__c(sh_Practice__c = practiceId, sh_Leader__c = bios.get(0).Id, Sequence__c = 1);
  	insert(pl1);
  	sh_Practice_Leader__c pl2 = new sh_Practice_Leader__c(sh_Practice__c = practiceId, sh_Leader__c = bios.get(1).Id, Sequence__c = 2);
  	insert(pl2);
  } 
  
  public static sh_project__c createFeaturedTeam() {
  	sh_project__c proj = new sh_project__c(name = 'Masco', Title__c = 'Masco', Project_Name__c = 'masco', Year__c = '2014', Sequence__c = 1);
  	insert (proj);
  	
  	List<sh_bio__c> bios = new List<sh_bio__c>();
  	
  	sh_bio__c bio = createBio('Shashidhar Gurumurthy', 'shashidhar-gurumurthy');
  	bios.add(bio);
  	bio = createBio('Amisha Goyal', 'amisha-goyal');
  	bios.add(bio);
  	createBio('Justin Waite', 'justin-waite');
  	bios.add(bio);
  	
  	sh_projectTeam__c tm1 = new sh_projectTeam__c(Bio__c = bios.get(0).Id, Project__c = proj.Id, Sequence__c = 1);
  	sh_projectTeam__c tm2 = new sh_projectTeam__c(Bio__c = bios.get(1).Id, Project__c = proj.Id, Sequence__c = 2);
  	sh_projectTeam__c tm3 = new sh_projectTeam__c(Bio__c = bios.get(2).Id, Project__c = proj.Id, Sequence__c = 3);
  	insert (tm1);
  	insert (tm2);
  	insert (tm3);
  	
  	return (proj);
  }
  
  private static void createProjects(Id practiceId, Id personId) {
  	sh_project__c proj1 = new sh_project__c(name = 'CSG Analytics', Title__c = 'CSG Analytics', Project_Name__c = 'csg-analytics', Year__c = '2014', Sequence__c = 1);
  	insert (proj1);
  	sh_project__c proj2 = new sh_project__c(name = 'Home Depot Paint', Title__c = 'Home Depot Paint', Project_Name__c = 'home-depot-paint', Year__c = '2014', Sequence__c = 2);
  	insert (proj2);
  	
  	Blob bodyBlob = Blob.valueOf('A simple text file.');
  	Attachment a = new Attachment(name = 'StaticImage.png', parentid = proj1.Id, body = bodyBlob);
  	insert (a);
  	singleAttachment = a.Id;
  	
  	if (practiceId != null) {
	  	sh_practiceProject__c pp1 = new sh_practiceProject__c(Practice__c = practiceId, Project__c = proj1.Id, Sequence__c = 1);
	  	sh_practiceProject__c pp2 = new sh_practiceProject__c(Practice__c = practiceId, Project__c = proj2.Id, Sequence__c = 2);
	  	insert (pp1);
	  	insert (pp2);
  	} else {
  		sh_projectTeam__c tm1 = new sh_projectTeam__c(Bio__c = personId, Project__c = proj1.Id, Sequence__c = 1);
  		sh_projectTeam__c tm2 = new sh_projectTeam__c(Bio__c = personId, Project__c = proj2.Id, Sequence__c = 2);
  		insert (tm1);
  		insert (tm2);
  	}
  }
  
  public static sh_Offering__c createOffering(Id practiceId) {
  	sh_Offering__c offering = new sh_Offering__c(Practice__c = practiceId, name = 'CSG Analytics', Offering_Name__c = 'csg-analytics', Sequence__c = 1);
  	insert (offering);
  	
  	Blob bodyBlob = Blob.valueOf('A simple text file.');
  	Attachment a = new Attachment(name = 'StaticImage.png', parentid = offering.Id, body = bodyBlob);
  	insert (a);
  	singleAttachment = a.Id;
  	
  	sh_keyPresentation__c keyPres = new sh_keyPresentation__c(Description__c = 'Some Description',
  															  Presentation_Name__c = 'project-Some Name', 
  															  Offering__c = offering.Id);
  	
  	insert keyPres;
  	return offering;
  }
  
  public static Id createKeyPresentation(String name, String code, String type) {
  	sh_project__c project;
  	sh_Practice__c practice;
  	Id idToReturn;
  
    sh_keyPresentation__c keyPres = new sh_keyPresentation__c(Description__c = 'Some Description');
  
  	
  	if (type == 'project') {
  		project = new sh_project__c(name = name, Title__c = name, Project_Name__c = code, Year__c = '2014', Sequence__c = 1);
  		insert (project);
  		idToReturn = project.Id;
  		keyPres.Presentation_Name__c = 'project-Some Name';
  		keyPres.Project__c = idToReturn;
  	} else {
  		practice = new sh_Practice__c(name = name, Practice_Name__c = code, isPractice__c = true, Sequence__c = 1);
  	    insert (practice);
  	    idToReturn = practice.Id;
  		keyPres.Presentation_Name__c = 'practice-Some Name';
  	    keyPres.Practice__c = idToReturn;
  	}
  	insert (keyPres);
  	
  	Blob bodyBlob = Blob.valueOf('A simple text file.');
	Attachment attach = new Attachment(name = 'SomeFile.pptx', parentid = keyPres.Id, body = bodyBlob);
	insert(attach);
  	
  	return (idToReturn);
  }
  
}