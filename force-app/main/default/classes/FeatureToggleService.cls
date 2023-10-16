global with sharing class FeatureToggleService {

    public static Boolean includeMetadataFields = false;
    public static Boolean isCacheEnabled = true;
    public static List<Feature_Toggle__mdt> cachedToggles = new List<Feature_Toggle__mdt>();
    private static FeatureToggleQueryService featureToggleQueryService = new FeatureToggleQueryService();
    private static Map<String,List<String>> mdtFieldsDescribe = featureToggleQueryService.getMetadataFieldDescribe();
    static {
        if (isCacheEnabled) {
            cachedToggles = FeatureToggleCacheService.getFromCache();
            if (cachedToggles == null)
                isCacheEnabled = false;
        }
    }
    
    @TestVisible
    private static void setMockQueryService(FeatureToggleQueryService toggleQueryService){
        featureToggleQueryService = toggleQueryService;
    }
    
    /**
     * getFeatureState method which returns state (on/off) of the Feature Toggle based on the Developer Name.
     * @param  parentFeatureLabel DeveloperName of the corresponding Feature_Toggle record.
     * @return Boolean             Bollean feature state - turned on or off.
     */

	public static Boolean getFeatureState(String parentFeatureLabel) {
        Feature f = null;
        if (isCacheEnabled) {
            f = getFeatureTogglesFromCache(parentFeatureLabel, cachedToggles);
        }
        else {
            FeatureToggleQueryService.FeatureCondition basicParentCondition = new FeatureToggleQueryService.FeatureCondition('DeveloperName =\'' + parentFeatureLabel + '\'');
            List<Feature_Toggle__mdt> toggles = getFeatureToggleRecords(basicParentCondition, null);
            f = toggles.isEmpty() ? new Feature(parentFeatureLabel, null) : new Feature(toggles.get(0));
        }
        Boolean returnValue = f.active;
        if (returnValue && f.isCallbackEnabled) {
            f.callbackValue = getCustomFeatureState(f.callbackClass);
            returnValue = returnValue && f.callbackValue;
        }
        return returnValue;
    }

    /**
     * getFeatureState method which returns state (on/off) of the Feature Toggle based on the Developer Name, and allows to pass parameters to a callback method
     * @param  String parentFeatureLabel DeveloperName of the corresponding Feature_Toggle record.
     * @param  String jsonString Parameter which will be passed to the Callback class method.
     * @return Boolean             Bollean feature state - turned on or off.
     */

	public static Boolean getParameterizedFeatureState(String parentFeatureLabel, String jsonString) {
        FeatureToggleQueryService.FeatureCondition basicParentCondition = new FeatureToggleQueryService.FeatureCondition('DeveloperName =\'' + parentFeatureLabel + '\'');
        List<Feature_Toggle__mdt> toggles = getFeatureToggleRecords(basicParentCondition, null);
        Feature f = toggles.isEmpty() ? new Feature(parentFeatureLabel, null) : new Feature(toggles.get(0));
        Boolean returnValue = f.active;
        if (returnValue && f.isCallbackEnabled) {
            f.callbackValue = getCustomFeatureState(f.callbackClass, jsonString);
            returnValue = returnValue && f.callbackValue;
        }
        return returnValue;
    } 

    /**
     * getFeatureState method which returns state (on/off) of the Feature Toggle based on the Developer Name, and allows to pass parameters to a callback method,
     for parent and child feature toggle
     * @param  parentFeatureLabel DeveloperName of the corresponding Feature_Toggle record.
     * @param  String parentJSONParam Parameter which will be passed to the Callback class method (Parent Feature Toggle Record).
     * @param  childFeatureLabel DeveloperName of the corresponding Child_Feature_Toggle record.   
     * @param  String childJSONParam Parameter which will be passed to the Callback class method (Child Feature Toggle Record).
     * @return Boolean           Boolean feature state - turned on or off.
     */
	@AuraEnabled
	public static Boolean getParameterizedFeatureState(String parentFeatureLabel, String parentJSONParam, String childFeatureLabel, String childJSONParam) {
        FeatureToggleQueryService.FeatureCondition basicParentCondition = new FeatureToggleQueryService.FeatureCondition('DeveloperName =\'' + parentFeatureLabel + '\'');
        FeatureToggleQueryService.FeatureCondition basicChildCondition = new FeatureToggleQueryService.FeatureCondition('DeveloperName =\'' + childFeatureLabel + '\'');
        
        List<Feature_Toggle__mdt> toggles = getFeatureToggleRecords(basicParentCondition, basicChildCondition);
        Feature f = toggles.isEmpty() ? new Feature(parentFeatureLabel, childFeatureLabel) : new Feature(toggles.get(0), childFeatureLabel);
        
        Boolean returnValue = f.active && f.features.get(0).active;
        if (returnValue && f.isCallbackEnabled) {
            f.callbackValue = getCustomFeatureState(f.callbackClass, parentJSONParam);
            returnValue = returnValue && f.callbackValue;
        }
        if (returnValue && f.features.get(0).isCallbackEnabled) {
            f.features.get(0).callbackValue = getCustomFeatureState(f.features.get(0).callbackClass, childJSONParam);
            returnValue = returnValue && f.features.get(0).callbackValue;
        }
        return returnValue;
    } 
    
    /**
     * getFeatureState method which returns state (on/off) of the Feature Toggle based on the Developer Name of the Parent and Child feature toggles
     * @param  parentFeatureLabel DeveloperName of the corresponding Feature_Toggle record.
     * @param  childFeatureLabel DeveloperName of the corresponding Child_Feature_Toggle record.
     * @return Boolean           Boolean feature state - turned on or off.
     */
	@AuraEnabled
	public static Boolean getFeatureState(String parentFeatureLabel, String childFeatureLabel) {
    	Feature f = null;
        if (isCacheEnabled) {
            f = getFeatureTogglesFromCache(parentFeatureLabel, childFeatureLabel, cachedToggles);
        }
        else {
            FeatureToggleQueryService.FeatureCondition basicParentCondition = parentFeatureLabel == null ? null : new FeatureToggleQueryService.FeatureCondition('DeveloperName =\'' + parentFeatureLabel + '\'');
            FeatureToggleQueryService.FeatureCondition basicChildCondition = childFeatureLabel == null ? null : new FeatureToggleQueryService.FeatureCondition('DeveloperName =\'' + childFeatureLabel + '\'');
            List<Feature_Toggle__mdt> toggles = getFeatureToggleRecords(basicParentCondition, basicChildCondition);
            f = toggles.isEmpty() ? new Feature(parentFeatureLabel, childFeatureLabel) : new Feature(toggles.get(0), childFeatureLabel);
        } 
        Boolean returnValue = f.active && f.features.get(0).active;
        if (returnValue && f.isCallbackEnabled) {
            f.callbackValue = getCustomFeatureState(f.callbackClass);
            returnValue = returnValue && f.callbackValue;
        }
        if (returnValue && f.features.get(0).isCallbackEnabled) {
            f.features.get(0).callbackValue = getCustomFeatureState(f.features.get(0).callbackClass);
            returnValue = returnValue && f.features.get(0).callbackValue;
        }
        return returnValue;
    }

    /**
     * getFeature method which returns Feature implementation of the Feature Toggle based on the Developer Name of the Parent feature toggle
     * @param  parentFeatureLabel DeveloperName of the corresponding Feature_Toggle record.
     * @return Feature            Feature-class instance which has all the details regarding Feature_Toggle record
     */

	public static Feature getFeature(String parentFeatureLabel){   
		return getFeature(parentFeatureLabel, null, null, null);        
    }
  
    /**
     * getFeature method which returns Feature implementation of the Feature Toggle based on the Developer Name of the Parent and Child feature toggles
     * @param  String parentFeatureLabel DeveloperName of the corresponding Feature_Toggle record.
     * @param  String childFeatureLabel  DeveloperName of the corresponding Child Feature_Toggle record.
     * @return Feature            Feature-class instance which has all the details regarding Feature_Toggle record
     */

	public static Feature getFeature(String parentFeatureLabel, String childFeatureLabel){   
		return getFeature(parentFeatureLabel, null, childFeatureLabel, null);        
    }
    
    /**
     * getFeature                 method which returns instance of the Feature feature class based on input params
     * @param  String parentFeatureLabel DeveloperName of the corresponding Feature_Toggle record.
     * @param  FeatureToggleQueryService.FeatureCondition parentCondition    FeatureToggleQueryService.FeatureCondition instance which will be used as a query condition to retrieve Feature_Toggle record
     * @return                    Feature record which has all the details regarding Feature_Toggle record
     */
	public static Feature getFeature(String parentFeatureLabel, FeatureToggleQueryService.FeatureCondition parentCondition){   
		return getFeature(parentFeatureLabel, parentCondition, null, null);        
    }
    
    /**
     * getFeature                 method which returns instance of the Feature feature class based on input params
     * @param  String parentFeatureLabel DeveloperName of the corresponding Feature_Toggle record.
     * @param  FeatureToggleQueryService.FeatureCondition    al.ConditionGroup instance which will be used as a query condition to retrieve Feature_Toggle record
     * @param  String childFeatureLabel  DeveloperName of the corresponding Child Feature_Toggle record.
     * @return                    Feature record which has all the details regarding Feature_Toggle record
     */
	public static Feature getFeature(String parentFeatureLabel, FeatureToggleQueryService.FeatureCondition parentCondition, String childFeatureLabel){   
		return getFeature(parentFeatureLabel, parentCondition, childFeatureLabel, null);        
    }
    
    /**
     * getFeature                 method which returns instance of the Feature feature class based on input params
     * @param  String parentFeatureLabel DeveloperName of the corresponding Feature_Toggle record.
     * @param  FeatureToggleQueryService.FeatureCondition parentCondition    al.ConditionGroup instance which will be used as a query condition to retrieve Feature_Toggle record
     * @param  String childFeatureLabel  DeveloperName of the corresponding Child Feature_Toggle record.
     * @param  FeatureToggleQueryService.FeatureCondition childCondition     al.ConditionGroup instance which will be used as a query condition to retrieve Child_Feature_Toggle record
     * @return  Feature           Feature record which has all the details regarding Feature_Toggle record
     */
	public static Feature getFeature(String parentFeatureLabel, FeatureToggleQueryService.FeatureCondition parentCondition, String childFeatureLabel, FeatureToggleQueryService.FeatureCondition childCondition){   
		
        FeatureToggleQueryService.FeatureCondition basicParentCondition = parentFeatureLabel == null ? null : new FeatureToggleQueryService.FeatureCondition('DeveloperName =\'' + parentFeatureLabel + '\'');
        FeatureToggleQueryService.FeatureCondition basicChildCondition = childFeatureLabel == null ? null : new FeatureToggleQueryService.FeatureCondition('DeveloperName =\'' + childFeatureLabel + '\'');
        
        if (parentCondition != null) {
            basicParentCondition.andCondition(parentCondition);
        }
        if (childCondition != null) {
            basicChildCondition.andCondition(childCondition);
        }            
                
        Feature f = null;
        if (isCacheEnabled && parentCondition == null && childCondition == null) {
            f = getFeatureTogglesFromCache(parentFeatureLabel, childFeatureLabel, cachedToggles);
        }
        else {
            List<Feature_Toggle__mdt> toggles = getFeatureToggleRecords(basicParentCondition, basicChildCondition);
            f = toggles.size() > 0 ? new Feature(toggles.get(0), childFeatureLabel) : new Feature(parentFeatureLabel, childFeatureLabel);
        }
        Boolean returnValue = f.active;
        
        if (returnValue && f.isCallbackEnabled) {
            f.callbackValue = getCustomFeatureState(f.callbackClass);
        }
        returnValue = returnValue && f.features.size() == 1;
        
        if (returnValue && Boolean.valueOf(f.features.get(0).isCallbackEnabled)) {
            f.features.get(0).callbackValue = getCustomFeatureState(f.features.get(0).callbackClass);
        }

        return f;
    }

     /**
     * getFeatureToggleRecords    method which queries on Feature_Toggle__mdt records based on input params and returns appropriate records
     * @param  parentCondition    FeatureToggleQueryService.FeatureCondition instance which will be used as a query condition to retrieve Feature_Toggle record
     * @param  childCondition     FeatureToggleQueryService.FeatureCondition instance which will be used as a query condition to retrieve Child_Feature_Toggle record
     * @return List<Feature_Toggle__mdt>  List of Feature_Toggle__mdt with associated Child_Feature_Toggle__mdt records
     */
    public static List<Feature_Toggle__mdt> getFeatureToggleRecords(FeatureToggleQueryService.FeatureCondition parentCondition, FeatureToggleQueryService.FeatureCondition childCondition){
       FeatureToggleQueryService.FeatureFields childFields = new FeatureToggleQueryService.FeatureFields(mdtFieldsDescribe.get('Child_Feature_Toggle__mdt'));
       FeatureToggleQueryService.FeatureFields parentFields = new FeatureToggleQueryService.FeatureFields(mdtFieldsDescribe.get('Feature_Toggle__mdt'));
       String childQuery = featureToggleQueryService.buildQuery(childFields, 'Child_Feature_Toggles__r', childCondition);
       parentFields.addInnerQuery(childQuery);
       String parentQuery = featureToggleQueryService.buildQuery(parentFields, 'Feature_Toggle__mdt', parentCondition);
       return cleanUpFeatureToggles((List<Feature_Toggle__mdt>) featureToggleQueryService.runQuery(parentQuery));
    }

    /**
     * getCustomFeature method which dynamically instantiates the Featurable implementation based on the class name
     * @param  String className   Name of the class to instantiate. Class must implement Featurable interface
     * @return Featurable         returns instance of the Featurable implementation
     */
    public static Featurable getCustomFeature(String className){   
		return validateAndReturnFeaturableInstance(className);
    }

    /**
     * getCustomFeatureState Returns the feature state (on/off) of the custom class which implements Featurable interface
     * @param  String className Name of the class to instantiate. Class must implement Featurable interface.
     * @return Boolean          Boolean flag state based on the custom Featurable implementation
     */
    public static Boolean getCustomFeatureState(String className){   
		return getCustomFeatureState(className, null);
    }
    /**
     * getCustomFeatureState Returns the feature state (on/off) of the custom class which implements Featurable interface
     * @param  String className Name of the class to instantiate. Class must implement Featurable interface.
     * @param  String jsonParam Stringified parameters for a custom logic
     * @return Boolean          Boolean flag state based on the custom Featurable implementation
     */
    public static Boolean getCustomFeatureState(String className, String jsonParam){   
        Featurable f = validateAndReturnFeaturableInstance(className);
        return f.getFeatureState(jsonParam);
    }
    /**
     * validateAndReturnFeaturableInstance Checks if a class can be instantiated and whether it implements Featurable interface
     * @param  className Name of the class to instantiate
     * @return Featurable Class instance         
     */ 
    private static Featurable validateAndReturnFeaturableInstance(String className) {
        Type featureT = Type.forName(className);
        if (featureT == null)
            throw new FeatureToggleException('Incorrect Class Name was specified as a Callback Class. No such class was found.');
        if (featureT.newInstance() instanceof Featurable) {
            return (Featurable) featureT.newInstance();
        } else {
            throw new FeatureToggleException(className + ' does not implement the Featurable interface! Callback Class should implement Featurable interface.');
        }
    }
    
    global class Feature {
		global String label;
		global Boolean active;    
        global Boolean isCallbackEnabled;
        global Boolean callbackValue;    
        global String callbackClass;
        global Map<String,Object> properties = new Map<String,Object>();
    
        global List<Subfeature> features = new List<Subfeature>();
        
        global Feature () {
             this.active = false;
             this.isCallbackEnabled = false;

        }
        
        global Feature (String parentFeatureName, String childFeatureName) {
            this.label = parentFeatureName;
            this.active = false;
            if (childFeatureName != null) {
                features.add(new Subfeature(childFeatureName));
            }
        }
        
        global Feature (Feature_Toggle__mdt mdtFeature, String childFeatureName) {
            this.label = mdtFeature.DeveloperName;
            this.active = mdtFeature.Is_Active__c;
            this.callbackClass = mdtFeature.Callback__c;
            this.isCallbackEnabled = callbackClass != null;
            if (includeMetadataFields) {
                for (String field : mdtFieldsDescribe.get('Feature_Toggle__mdt')) {
                    properties.put(field, mdtFeature.get(field));
                }
            }
            for (Child_Feature_Toggle__mdt child : cleanUpChildFeatureToggles(mdtFeature.Child_Feature_Toggles__r)) {
                features.add(new Subfeature(child));
            }
            if (features.isEmpty() && childFeatureName != null) {
                features.add(new Subfeature(childFeatureName));
            }
        }

        global Feature (Feature_Toggle__mdt mdtFeature) {
            this.label = mdtFeature.DeveloperName;
            this.active = mdtFeature.Is_Active__c;
            this.callbackClass = mdtFeature.Callback__c;
            this.isCallbackEnabled = callbackClass != null;
            if(includeMetadataFields) {
                for (String field : mdtFieldsDescribe.get('Feature_Toggle__mdt')) {
                    properties.put(field, mdtFeature.get(field));
                }
            }
            for (Child_Feature_Toggle__mdt child : cleanUpChildFeatureToggles(mdtFeature.Child_Feature_Toggles__r)) {
                features.add(new Subfeature(child));
            }
        }

        global Feature (Feature_Toggle__mdt mdtFeature, List<Child_Feature_Toggle__mdt> cmdtFeatures) {
            this.label = mdtFeature.DeveloperName;
            this.active = mdtFeature.Is_Active__c;
            this.callbackClass = mdtFeature.Callback__c;
            this.isCallbackEnabled = callbackClass != null;
            if(includeMetadataFields) {
                for (String field : mdtFieldsDescribe.get('Feature_Toggle__mdt')) {
                    properties.put(field, mdtFeature.get(field));
                }
            }
            for (Child_Feature_Toggle__mdt cmdtFeature : cmdtFeatures) {
                features.add(new Subfeature(cmdtFeature));
            }
        }
    }
    
    global class Subfeature {
        global String label;
        global Boolean active;
        global Boolean isCallbackEnabled;
        global Boolean callbackValue;
        global String callbackClass;

        global Map<String,Object> properties = new Map<String,Object>();
        
        global Subfeature () {
             this.active = false;
             this.isCallbackEnabled = false;
        }
        
        global Subfeature (String featureName) {
            this.label = featureName;
            this.active = false;
            this.isCallbackEnabled = false;
        }
        
        global Subfeature (Child_Feature_Toggle__mdt mdtChild) {
            this.label = mdtChild.DeveloperName;
            this.callbackClass = mdtChild.Callback__c;
            this.isCallbackEnabled = callbackClass != null;
            this.active = mdtChild.Is_Active__c;
            if (includeMetadataFields) {
                for (String field : mdtFieldsDescribe.get('Child_Feature_Toggle__mdt')) {
                    properties.put(field, mdtChild.get(field));
                }
            }
        }    
    }

    
    /**
     * cleanUpFeatureToggles Method which removes the Feature_Toggles from the list which are out of the Date range
     * @param  List<Feature_Toggle__mdt> fToggles List of Feature_Toggles to cleanup
     * @return  List<Feature_Toggle__mdt> returns  cleaned up List of Feature_Toggles
     */
    private static List<Feature_Toggle__mdt> cleanUpFeatureToggles (List<Feature_Toggle__mdt> fToggles) {
        List<Feature_Toggle__mdt> returnList = new List<Feature_Toggle__mdt>();
        Date dateToday = Date.today();
        for (Feature_Toggle__mdt fToggle : fToggles) {
            Boolean filterCriteria = (fToggle.Start_Date__c == null ||  fToggle.Start_Date__c <= dateToday) &&  (fToggle.End_Date__c == null ||  fToggle.End_Date__c >= dateToday);
            if (filterCriteria) {
                returnList.add(fToggle);
            }
        }
        return returnList;
    }
    /**
     * cleanUpChildFeatureToggles Method which removes the Child_Feature_Toggles from the list which are out of the Date range
     * @param  List<Child_Feature_Toggle__mdt> fToggles List of Child_Feature_Toggles to cleanup
     * @return  List<Child_Feature_Toggle__mdt> returns  cleaned up List of Child_Feature_Toggles
     */
    private static List<Child_Feature_Toggle__mdt> cleanUpChildFeatureToggles (List<Child_Feature_Toggle__mdt> fToggles) {
        List<Child_Feature_Toggle__mdt> returnList = new List<Child_Feature_Toggle__mdt>();
        Date dateToday = Date.today();
        for (Child_Feature_Toggle__mdt fToggle : fToggles) {
            Boolean filterCriteria = (fToggle.Start_Date__c == null ||  fToggle.Start_Date__c <= dateToday) &&  (fToggle.End_Date__c == null ||  fToggle.End_Date__c >= dateToday);
            if (filterCriteria) {
                returnList.add(fToggle);
            }
        }
        return returnList;
    }
    
    /**
     * @param  childFeatureLabel  DeveloperName of the corresponding Child_Feature_Toggle record
     * @param  List<Feature_Toggle__mdt> fToggles description
     * @return                    return description
     */
    public static Feature getFeatureTogglesFromCache(String parentFeatureLabel, List<Feature_Toggle__mdt> fToggles) {
        return getFeatureTogglesFromCache(parentFeatureLabel, null, fToggles);
    }

    /**
     * @param  parentFeatureLabel DeveloperName of the corresponding Feature_Toggle record.
     * @param  childFeatureLabel  DeveloperName of the corresponding Child_Feature_Toggle record
     * @param  ist<Feature_Toggle__mdt>   fToggles description
     * @return                    return description
     */
    public static Feature getFeatureTogglesFromCache(String parentFeatureLabel, String childFeatureLabel, List<Feature_Toggle__mdt> fToggles) {
        List<Feature_Toggle__mdt> returnList = new List<Feature_Toggle__mdt>();
        List<Child_Feature_Toggle__mdt> childReturnList = new List<Child_Feature_Toggle__mdt>();
        Date dateToday = Date.today();
        if (fToggles != null)
            for (Feature_Toggle__mdt fToggle : fToggles) {
                Boolean filterCriteria = fToggle.DeveloperName == parentFeatureLabel && (fToggle.Start_Date__c == null ||  fToggle.Start_Date__c <= dateToday) &&  (fToggle.End_Date__c == null ||  fToggle.End_Date__c >= dateToday);
                if (filterCriteria) {
                    returnList.add(fToggle);
                    break;
                }
            }
        if (returnList.isEmpty()) {
            return new Feature(parentFeatureLabel, childFeatureLabel);
        }
        for (Child_Feature_Toggle__mdt cfToggle : returnList.get(0).Child_Feature_Toggles__r) {
            Boolean filterCriteria = cfToggle.DeveloperName == childFeatureLabel && (cfToggle.Start_Date__c == null ||  cfToggle.Start_Date__c <= dateToday) &&  (cfToggle.End_Date__c == null ||  cfToggle.End_Date__c >= dateToday);
            if (cfToggle.DeveloperName == childFeatureLabel) {
                childReturnList.add(cfToggle);
                break;
            }
        }
        if (childReturnList.isEmpty()) {
            return new Feature(returnList.get(0), childFeatureLabel);
        }
        return new Feature(returnList.get(0), childReturnList);
    }
}