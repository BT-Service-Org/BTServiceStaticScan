@isTest
public class PSCProductDetailCtrlTest {
	@isTest
    public static void getHeaderNavigationIdTest1(){
        system.assert(PSCProductDetailCtrl.getProductTypeValues('Sales_Cloud')!=null,'success');
    }
}