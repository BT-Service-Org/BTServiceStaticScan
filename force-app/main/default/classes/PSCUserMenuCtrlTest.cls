@isTest
public class PSCUserMenuCtrlTest {
	@isTest
    public static void getUserMenuItemsTest(){
        system.assert(PSCUserMenuCtrl.getUserMenuItems()!=null,'success');
    }
}