public class The_Station_AdvancedNavMenu_Controller {
    
    private static final String NAV_MENU_ITEM_STATUS = 'Live';
    private static final String THE_STATION_COMMUNITY_URL = '/thestation/s';
    private static final String CURRENT_NETWORK_ID = Network.getNetworkId();
    
    // Returns a list of navigation menu items related to a specific navigation menu and a specific parent (navigation menu item)
    private static List<NavigationMenuItem> getNavigationMenuItems(Id navigationMenuId, Id parent)  {
        return Test.isRunningTest() ? MOCK_NAVIGATION_MAIN_MENU_ITEMS : [SELECT Id, Label, Target, Type 
                FROM NavigationMenuItem 
                WHERE ParentId = :parent AND Status= :NAV_MENU_ITEM_STATUS AND NavigationLinkSetId= :navigationMenuId
                ORDER BY Position ASC];
    }
    
    // Returns the Id of a navigation menu by its developer name
    private static Id getNavigationMenuIdByDeveloperName(String developerName)  {
        Id navigationMenuId;
        List<NavigationLinkSet> mainNavigationMenu = [SELECT Id FROM NavigationLinkSet WHERE DeveloperName=:developerName AND NetworkId =: CURRENT_NETWORK_ID];
        if(!mainNavigationMenu.isEmpty()) {
            navigationMenuId = mainNavigationMenu[0].Id;
        }
        return navigationMenuId;
    }
    
    // Returns an url which is the target direction for a specific navigaiton menu item
    private static String buildTargetUrl(NavigationMenuItem navigationMenuItem, String baseUrl) {
        if(navigationMenuItem.Type == 'InternalLink') {
            return baseUrl + navigationMenuItem.Target;
        }
        else if(navigationMenuItem.Type == 'ExternalLink') {
            return navigationMenuItem.Target;
        }
        return '';
    }
    
    @AuraEnabled
    public static List<NavigationMenuWrapper> getMenus(String mainMenu, String childMenus, String baseUrl) {
        List<NavigationMenuWrapper> menus = new List<NavigationMenuWrapper>();
        
        // Query main menu elements
        Id mainNavigationMenuId = getNavigationMenuIdByDeveloperName(mainMenu);
        List<NavigationMenuItem> mainMenuElements = Test.isRunningTest() ? MOCK_NAVIGATION_MAIN_MENU_ITEMS : getNavigationMenuItems(mainNavigationMenuId, null);
        
        List<String> childMenusSplit = childMenus.split(',');
        
        // For each main element, query its related child menu
        for(Integer i = 0; i < mainMenuElements.size(); i++) {
            List<NavigationMenuWrapper> childMenu = new List<NavigationMenuWrapper>();
            if(i < childMenusSplit.size()) {
                // Query the child menu
                Id childNavigationMenuId = getNavigationMenuIdByDeveloperName(childMenusSplit.get(i));
                // Query the first level elements
                List<NavigationMenuItem> childLevel1Elements = Test.isRunningTest() ? MOCK_NAVIGATION_CHILD_MENU_ITEMS_LEVEL1 : getNavigationMenuItems(childNavigationMenuId, null);
                
                // Add the elements of the child menu to a List
                for(NavigationMenuItem childLevel1Element : childLevel1Elements) {
                    // Query the second level elements
                    List<NavigationMenuItem> childLevel2Elements =  Test.isRunningTest() ? MOCK_NAVIGATION_CHILD_MENU_ITEMS_LEVEL2 : getNavigationMenuItems(childNavigationMenuId, childLevel1Element.Id);
                    
                    List<NavigationMenuWrapper> childLevel2 = new List<NavigationMenuWrapper>();
                    for(NavigationMenuItem childLevel2Element : childLevel2Elements) {
                        childLevel2.add(new NavigationMenuWrapper(childLevel2Element.Id, childLevel2Element.Label, buildTargetUrl(childLevel2Element, baseUrl), null));
                    }
                    childMenu.add(new NavigationMenuWrapper(childLevel1Element.Id, childLevel1Element.Label, buildTargetUrl(childLevel1Element, baseUrl), childLevel2));
                }
            }
            
            // Add the main menu element with its related child menu elements
            menus.add(new NavigationMenuWrapper(mainMenuElements.get(i).Id, mainMenuElements.get(i).Label, buildTargetUrl(mainMenuElements.get(i), baseUrl), childMenu));
        }
        
        return menus;
    }
    
    public class NavigationMenuWrapper {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String target;
        @AuraEnabled
        public List<NavigationMenuWrapper> childs;
        
        NavigationMenuWrapper(Id id, String title, String target, List<NavigationMenuWrapper> childs) {
            this.id = id;
            this.title = title;
            this.target = target;
            this.childs = childs;
        }
    }
    
    private static final List<NavigationMenuItem> MOCK_NAVIGATION_MAIN_MENU_ITEMS = new List<NavigationMenuItem>{new NavigationMenuItem(Label= 'MainItem', Type='')};
        private static final List<NavigationMenuItem> MOCK_NAVIGATION_CHILD_MENU_ITEMS_LEVEL1 = new List<NavigationMenuItem>{new NavigationMenuItem(Label= 'Child Item 1', Type='')};
            private static final List<NavigationMenuItem> MOCK_NAVIGATION_CHILD_MENU_ITEMS_LEVEL2 = new List<NavigationMenuItem>{new NavigationMenuItem(Label= 'Child Item 1.1', Target='/about', Type='InternalLink')};
                
                
                }