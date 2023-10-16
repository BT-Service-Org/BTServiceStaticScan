@isTest
public class PSCThemeHeaderCtrlTest {
	@testSetup
    static void createData() {
        ccnavmenus__Menu__c navMenuObj = PSCTestDataFactory.createMenu();
        insert navMenuObj;
    }
    
    @isTest
    public static void getHeaderNavigationIdTest1(){
        system.assertEquals(PSCThemeHeaderCtrl.getHeaderNavigationId('PSC Menu'),[SELECT Id
                                                                           FROM ccnavmenus__Menu__c 
                                                                           WHERE Name =:PSCSettingService.getValue('Navigation_Menu_Name') ]?.Id,'success');
    }
    
    @isTest
    public static void getHeaderNavigationIdTest2(){
        system.assertEquals(PSCThemeHeaderCtrl.getHeaderNavigationId('PSC Menu'),[SELECT Id
                                                                           FROM ccnavmenus__Menu__c 
                                                                           WHERE Name ='PSC Menu' ]?.Id,'success');
    }
}