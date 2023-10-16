@isTest
public class PSCMethodologyDefaultCtrlTest {
    @isTest
    public static void getMethodologyFormDataTest(){
        List<PermissionSetAssignment> userPermissionSet =  [SELECT Id, PermissionSet.Name,AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId()]; 
        Test.startTest();
            PSCMethodologyDefaultCtrl.getMethodologyFormData();
        Test.stopTest();
        List<PermissionSetAssignment> userPermissionSetUpdated =  [SELECT Id, PermissionSet.Name,AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId()]; 
        System.assertEquals(true, userPermissionSetUpdated.size() >= userPermissionSet.size(), 'Methodology permission set should be assigned');
    }
}