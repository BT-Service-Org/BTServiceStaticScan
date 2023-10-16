public with sharing class FeatureToggleTestUtilities {
    
    public class MockFeatureToggleQueryService implements System.StubProvider {
        
        private Feature_Toggle__mdt parentToggle;
        private Child_Feature_Toggle__mdt childToggle;

        public MockFeatureToggleQueryService(Feature_Toggle__mdt parentToggle,Child_Feature_Toggle__mdt childToggle){
            this.parentToggle = parentToggle;
            this.childToggle = childToggle;
            
           
        }

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, 
                                       Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames, 
                                      List<Object> listOfArgs) {
        
        List<Sobject> featureToggles = createFeatureToggleMetadata(parentToggle, childToggle);
        if(stubbedMethodName == 'runQuery'){
               return featureToggles;                                     
        }
        return null;
      }

      public List<Sobject> createFeatureToggleMetadata(Feature_Toggle__mdt parentToggle,Child_Feature_Toggle__mdt childToggle){
        List<Sobject> sobjects = new List<Sobject>();
        Feature_Toggle__mdt metadataRecord;
        if(parentToggle != null && childToggle != null){
            String parentStart = String.valueOf(parentToggle.Start_Date__c).remove('00:00:00');
            String parentEnd = String.valueOf(parentToggle.End_Date__c).remove('00:00:00');
            metadataRecord = (Feature_Toggle__mdt)JSON.deserialize('{"MasterLabel":"'+parentToggle.Masterlabel+'", "DeveloperName":"'+parentToggle.Masterlabel+'", "Is_Active__c": '+parentToggle.Is_Active__c+', "Callback__c":"'+parentToggle.Callback__c+'", "Start_Date__c":"'+parentStart+'", "End_Date__c":"'+parentEnd+'", "Child_Feature_Toggles__r": {"totalSize":1, "done":true, "records":[{"MasterLabel":"'+childToggle.MasterLabel+'","Is_Active__c":'+childToggle.Is_Active__c+', "Callback__c":"'+childToggle.Callback__c+'"}]}}',  Feature_Toggle__mdt.class);
        }else{
            String parentStart = String.valueOf(parentToggle.Start_Date__c).remove('00:00:00');
            String parentEnd = String.valueOf(parentToggle.End_Date__c).remove('00:00:00');
            metadataRecord = (Feature_Toggle__mdt)JSON.deserialize('{"MasterLabel":"'+parentToggle.Masterlabel+'", "DeveloperName":"'+parentToggle.Masterlabel+'", "Is_Active__c": '+parentToggle.Is_Active__c+', "Callback__c":"'+parentToggle.Callback__c+'", "Start_Date__c":"'+parentStart+'", "End_Date__c":"'+parentEnd+'"}',  Feature_Toggle__mdt.class);
        }
        sobjects.add(metadataRecord);
        return sobjects;
    }
        
   }
    
    public static FeatureToggleQueryService createToggleQueryServiceMock(Feature_Toggle__mdt parentToggle,Child_Feature_Toggle__mdt childToggle){
        MockFeatureToggleQueryService mockToggleQueryServiceClass = new MockFeatureToggleQueryService(parentToggle,childToggle);
        FeatureToggleQueryService featureToggleQueryServiceMock = (FeatureToggleQueryService)Test.createStub(FeatureToggleQueryService.class, mockToggleQueryServiceClass);
       
        return featureToggleQueryServiceMock;
    }

    public static Feature_Toggle__mdt createParentFeatureToggle(String name, Boolean active, Date startDate, Date endDate, String callback){
        Feature_Toggle__mdt parentToggle = new Feature_Toggle__mdt();
        parentToggle.MasterLabel = name;
        parentToggle.Is_Active__c = active;
        parentToggle.Start_Date__c = startDate;
        parentToggle.End_Date__c = endDate;
        parentToggle.Callback__c = !String.isBlank(callback) ? callback : 'DummyValue';
        return parentToggle;
    }

    public static Child_Feature_Toggle__mdt createChildFeatureToggle(String name, Boolean active, Date startDate, Date endDate, String callback){
        Child_Feature_Toggle__mdt childToggle = new Child_Feature_Toggle__mdt();
        childToggle.MasterLabel = name;
        childToggle.Is_Active__c = active;
        childToggle.Start_Date__c = startDate;
        childToggle.End_Date__c = endDate;
        childToggle.Callback__c = !String.isBlank(callback) ? callback : 'DummyValue';
        return childToggle;
    }
}