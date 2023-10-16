/**
	Apex class Name : MockInterfaceOverride
	@description		: This class  extends Mock interface to cover the code for external object records (for ex.,  User__x )
	Created Date	:  Feb 17, 2023
*/
public class MockInterfaceOverride extends MockInterface{
    final List<SObject> objectList;
	
    @testvisible
    MockInterfaceOverride(List<SObject> mockRecords){
        this.objectList = mockRecords;
    }

    public override List<SObject> passThrough(List<SObject> records){
        return objectList;
    }
}