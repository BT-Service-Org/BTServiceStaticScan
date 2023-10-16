/**
	Apex class Name : MockInterface
	@description		: This is Mock interface class mocks the external object records (for ex.,  User__x )
	Created Date	:  Feb 17, 2023
*/
public virtual inherited sharing class MockInterface{

    /*
    @description  		A method that is overriden in the test class. When used outside of a test,
                        returns the records. When used in a test class, will return the overriden
                        method in the class that is defined in the test class, this overidden method
                        returns a list of the external object (Orders__x)
    **********************************************************************************************/
    public virtual List<SObject> passThrough(List<SObject> records){
        return records;
    } 
}