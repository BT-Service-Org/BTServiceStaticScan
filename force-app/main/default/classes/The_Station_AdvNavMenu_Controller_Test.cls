@isTest
public class The_Station_AdvNavMenu_Controller_Test {
    
    @isTest
    private static void getMenusTest() {
        List<The_Station_AdvancedNavMenu_Controller.NavigationMenuWrapper> menus = The_Station_AdvancedNavMenu_Controller.getMenus('MainMenu','ChildMenu', 'baseurl.com/');
        System.assertNotEquals(null, menus, 'Menus tree should be returned');
        System.assertEquals('MainItem', menus[0].title, 'The first main item should be "MainItem"');
        System.assertEquals('Child Item 1', menus[0].childs[0].title, 'The first child of the first main item should be "Child Item 1"');
        System.assertEquals('Child Item 1.1', menus[0].childs[0].childs[0].title, 'The first child of the first child of the main item should be "Child Item 1.1"');
    }

}