public class DummyFeature implements Featurable {
    //Default overridden method without parameters
    //Used to return values without any parameters
    public Boolean getFeatureState() {
      return true;  
    }
    //Method which can return data based on the input parameter.
    public Boolean getFeatureState(String jsonValue) {
        if (jsonValue == null) {
            return true;
        }
        Map<String,Object> paramMap = (Map<String, Object>) JSON.deserializeUntyped(jsonValue);
        //Calling some thridparty method with parameters from JSON map
        String param = (String) paramMap.get('Feature');
        // return SomeClass.doSomething(param);
        return false;
    }
}