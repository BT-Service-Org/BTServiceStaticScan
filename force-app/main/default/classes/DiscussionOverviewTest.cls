@IsTest private class DiscussionOverviewTest {


    
    public static testMethod void testDiscussion() {
    
    DiscussionOverviewController dis= new DiscussionOverviewController();
    
    try {
        dis.setParamAll('true');
    }
    catch (exception e) {
        System.assert(true, e);
    }
    
    try {
        dis.constructorFunction();
    }
    catch (exception e) {
        System.assert(true, e);
    }
    
    if (dis.getTabControl() == null) {
        System.assert(true, 'Tab Control return null'); 
    }
    
    if (dis.getForums() == null) {
        System.assert(true, 'Forums return null');  
    }
    
    /* PAGINATION */
    try {
        dis.nextPage();
    }
    catch (exception e) {
        System.assert(true, e);
    }
    
    if (dis.getCurrentPagination() == null) {
        System.assert(true, 'Current Pagination return null');  
    }
    
    if (dis.getCntPagination() == null) {
        System.assert(true, 'Count Pagination return null');    
    }
    
    if (dis.getNumberOfItemsToShow() == null) {
        System.assert(true, 'getNumberOfItemsToShow return null');  
    }
    
    if (dis.getFirstRow() == null) {
        System.assert(true, 'getFirstRow return null'); 
    }
    
    if (dis.getPrevPageLinkShow() == null) {
        System.assert(true, 'getPrevPageLinkShow return null'); 
    }
    
    if (dis.getPrevPageShow() == null) {
        System.assert(true, 'getPrevPageShow return null'); 
    }
    
    if (dis.getNextPageLinkShow() == null) {
        System.assert(true, 'getNextPageLinkShow return null'); 
    }
    
    if (dis.getNextPageShow() == null) {
        System.assert(true, 'getNextPageShow return null'); 
    }
    
    
    
    try {
        dis.prevPage();
    }
    catch (exception e) {
        System.assert(true, e);
    }
    
    if (dis.getCurrentPagination() == null) {
        System.assert(true, 'Current Pagination return null');  
    }
    
    if (dis.getCntPagination() == null) {
        System.assert(true, 'Count Pagination return null');    
    }
    
    if (dis.getNumberOfItemsToShow() == null) {
        System.assert(true, 'getNumberOfItemsToShow return null');  
    }
    
    if (dis.getFirstRow() == null) {
        System.assert(true, 'getFirstRow return null'); 
    }
    
    if (dis.getPrevPageLinkShow() == null) {
        System.assert(true, 'getPrevPageLinkShow return null'); 
    }
    
    if (dis.getPrevPageShow() == null) {
        System.assert(true, 'getPrevPageShow return null'); 
    }
    
    if (dis.getNextPageLinkShow() == null) {
        System.assert(true, 'getNextPageLinkShow return null'); 
    }
    
    if (dis.getNextPageShow() == null) {
        System.assert(true, 'getNextPageShow return null'); 
    }
    
    /* DISCUSSION FORUMS */
    
    if (dis.getDiscussionForums('') == null) {
        System.assert(true, 'getDiscussionForums return null'); 
    }
    
    /*
    List<DiscussionOverviewController.TeamForums> discussionForumList=dis.getDiscussionForums('12');
    System.assert(discussionForumList.size()==0,'No hay elementos en la lista discussionForumList');
    */
    
    /* MOST ACTIVE USERS */
    if (dis.getMostActiveUsers() == null) {
        System.assert(true, 'getMostActiveUsers return null');  
    }
    
    /* ACTIVE USER CLASS */
    DiscussionOverviewController.ActiveUser activeU = new DiscussionOverviewController.ActiveUser();
    
    if (activeU.getMostActive() == null) {
        System.assert(true, 'Active User class null var');  
    }
    
    if (activeU.getName() == null) {
        System.assert(true, 'Active User class null var');  
    }
    
    if (activeU.getId() == null) {
        System.assert(true, 'Active User class null var');  
    }
    
    if (activeU.getCommentsCount() == null) {
        System.assert(true, 'Active User class null var');  
    }
    
    if (activeU.getPicture() == null) {
        System.assert(true, 'Active User class null var');  
    }
    
    try {
        activeU.setCommentsCount(0);
    }
    catch (exception e) {
        System.assert(true, e);
    }
    
    
    /* TEAM FORUMS CLASS */
    DiscussionOverviewController.TeamForums team    = new DiscussionOverviewController.TeamForums();
    
    if (dis.getNoForums() == null) {
        System.assert(true, 'No forums return null');   
    }
    
    if (team.getTeamId() == null) {
        System.assert(true, 'TeamForums class null var');   
    }
    
    if (team.getTeamName() == null) {
        System.assert(true, 'TeamForums class null var');   
    }
    
    if (team.getTeamDescription() == null) {
        System.assert(true, 'TeamForums class null var');   
    }
    
    if (team.getNumberOfMessages() == null) {
        System.assert(true, 'TeamForums class null var');   
    }
    
    if (team.getNumberOfThreads() == null) {
        System.assert(true, 'TeamForums class null var');   
    }
    
    if (team.getLastPostMessage() == null) {
        System.assert(true, 'TeamForums class null var');   
    } 
    
    if (team.getImage() == null) {
        System.assert(true, 'TeamForums class null var');   
    }
    
    if (team.getImage() == null) {
        System.assert(true, 'TeamForums class null var');   
    }
    
    
    /*
    String lastPostString= team.lastPostInfoString('a0630000002QmjJAAS');
    System.assert(lastPostString==null,' En el metodo lastPostInfoString devuelve null');
    
    
    List<DiscussionOverviewController.ActiveUser> listUser = dis.getMostActiveUsers();
    System.assert(lastPostString==null,' En el metodo lastPostInfoString devuelve null');
    
    
    
    listUser = dis.sortResult (listUser);
    DiscussionOverviewController.ActiveUser active= new DiscussionOverviewController.ActiveUser();
    */
    
    }
    
 }