@isTest
public with sharing class PSCBrowseAllMenuCtrlTest {
    @testSetup
    static void createData() {
        ccnavmenus__Menu__c menuObj = PSCTestDataFactory.createMenu();
        insert menuObj;

        ccnavmenus__Menu_Item__c menuItemObj = PSCTestDataFactory.createMenuItem(menuObj.Id,null);
        menuItemObj.Name = 'Products';
        insert menuItemObj;

        ccnavmenus__Menu_Item__c menuItemObj1 = PSCTestDataFactory.createMenuItem(menuObj.Id,menuItemObj.Id);
        insert menuItemObj1;
    }
    @isTest
    public static void positiveTest1(){
        Test.startTest();
        System.assertEquals(1, PSCBrowseAllMenuCtrl.getMenuItemsByCategory('Products').menuItems.size(),'Success');
        Test.stopTest();
    }
}