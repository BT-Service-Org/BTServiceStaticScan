public class AdminWidgetConfigController {
	
	public AdminWidgetConfigController(){
	}
		
	public void verifyAdminPerm(){
		TeamUtil.isAdminMemberUser();
	}
	

}