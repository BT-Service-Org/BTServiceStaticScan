/**
 * Shared methods related to FieldSets.
 */
public class SolutionFinderFieldSetUtilities {
    
    public static List<Schema.FieldSetMember> getFieldSetMembers(String sObjectName, String fieldSetName) {
        
        // Create a list of FieldSetMembers to be returned at the end of this method.
        List<Schema.FieldSetMember> fieldSetMembers = new List<Schema.FieldSetMember>();
        
        // Validate the object name provided exists.
        Map<String, Schema.SObjectType> mapOfSObjects = Schema.getGlobalDescribe();
        if (!mapOfSObjects.containsKey(sObjectName)) {
            throw new SolutionFinderFieldSetException(SolutionFinderFieldSetException.SOBJECT_NOT_FOUND);
        }
        Schema.DescribeSObjectResult sObjectResult = mapOfSObjects.get(sObjectName).getDescribe();
        
        // Validate the fieldset name provided exists.
        Map<String, Schema.FieldSet> mapOfFieldSets = sObjectResult.fieldSets.getMap();
        if (!mapOfFieldSets.containsKey(fieldSetName)) {
            throw new SolutionFinderFieldSetException(SolutionFinderFieldSetException.FIELDSET_NOT_FOUND);
        }
        
        // Populate the list of FieldSetMembers to 
        fieldSetMembers = mapOfFieldSets.get(fieldSetName).getFields();
        
        // Return the list of FieldSetMembers.
        return fieldSetMembers;
    }
}