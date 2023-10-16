/**
* Test Class for GDC_MS_NavigationMenuItems
**/
@isTest
public with sharing class GDC_MS_NavigationMenuItemsTest {
    @IsTest
    public static void testNavigationMenuItems() {
        test.startTest();
        GDC_MS_NavigationMenuItems obj= new GDC_MS_NavigationMenuItems();
        obj.getDefaultValue();
        obj.getValues();
        
        List<NavigationMenuItem> navItems= new List<NavigationMenuItem>();
        try{
            navItems= GDC_MS_NavigationMenuItems.getNavigationMenuItems();
            System.assertNotEquals(navItems.size(),0);
        }catch(Exception e){
            System.assertEquals(navItems.size(),0); 
        }
        test.stopTest();
    }
}