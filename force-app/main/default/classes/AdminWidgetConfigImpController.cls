public class AdminWidgetConfigImpController {
	
	public AdminWidgetConfigImpController(){
	}
	
	public void verifyAdminPerm(){
		TeamUtil.isAdminMemberUser();
	}
	
}