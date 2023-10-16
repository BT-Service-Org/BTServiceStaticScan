public with sharing class EDHQ_BT_ApplicationContext {
    private static Map<String,Object> contextValues = new Map<String,Object>();
    
    public static void setContextValue(String key, Object value){
        contextValues.put(key, value);
    }
    
    public static Object getContextValue(String key){
        return contextValues.get(key);
    }
}