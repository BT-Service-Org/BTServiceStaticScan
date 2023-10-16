/**
* @description : tf_TriggerHandlerRegistryUtil 
*					> When A Trigger fires, the respective dispatcher takes control and handles the delegation 
*                   > For every specific Trigger event, the dispatcher is going to create respective instance and calls event specific method 
*					> e.g : for RenewalOptyHandler, afterUpdate event - RenewalOptyHandler needs to be registed againts After Update Event 
*  					> The following class handles all the logic for fetching the handlers for respective events
*/
public class tf_TriggerHandlerRegistryUtil {
    private static Map<String,Map<String,List<String>>> eventHandlerMap = new Map<String,Map<String,List<String>>>();
    private static final string NAME_OF_SOBJECT_BLANK = 'The SObject Name can not be Blank!';
    private static final String TRIGGER_HANDLER_INSTANCE_EXCEPTION = 'Trigger Handler Instantiation Failed: ';
    private static tf_TriggerHandlerRegistryDAO triggerHandlerRegistryDAO = new tf_TriggerHandlerRegistryDAO();

    @TestVisible
    private static void setMockDao(tf_TriggerHandlerRegistryDAO dao){
        triggerHandlerRegistryDAO = dao;
    }
     
    /**
     @param sObjectName - String
     @return   : Map<String,Set<String>> Map with Key as event name and values as the set of handler class names for the respective event
    * @description : The Event Mapping data is stored in Custom Metadata
    *				 Fetch the Data from CM and transform into the Event Map
    */    
    public static Map<String,List<String>> getEventHandlerMap(String sObjectName) {
        if(String.isBlank(sObjectName)){
            throw new tf_TriggerException(NAME_OF_SOBJECT_BLANK); 
        }

        //Lets check if the Map has the Data that we are looking for already - through previous calls
        if(!eventHandlerMap.containsKey(sObjectName)){
            Map<String, List<String>> triggerEventMap = new Map<String, List<String>>();
            for(Trigger_Handler_Registry__mdt rec : triggerHandlerRegistryDAO.getTriggerHandlerRegistryEntries(sObjectName))
            {
                if(String.isNotBlank(rec.Trigger_Handler_Name__c)){
                    addToMap(triggerEventMap, rec.Trigger_Event__c, rec.Trigger_Handler_Name__c);
                }
            }
            eventHandlerMap.put(sObjectName, triggerEventMap);
        }
        return eventHandlerMap.get(sObjectName);

    }
    /**
    @description : addToMap method
    @param mapOfStringVsStringList - Map<String,List<String>>
    @param key - String
    @param value - String
    */
    private static void addToMap(Map<String,List<String>> mapOfStringVsStringList, String key, String value) {
        if(mapOfStringVsStringList.containsKey(key)){
            mapOfStringVsStringList.get(key).add(value); 
        } else {
            mapOfStringVsStringList.put(key, new List<String> { value }); 
        } 
    } 
    /**
    @description : getHandlerInstance method
    @return      : tf_TriggerHandler
    @param className - String
    */
    public static tf_TriggerHandler getHandlerInstance(String className){
        try{
            return (tf_TriggerHandler)Type.forName(className).newInstance(); 
        } catch(Exception ex){
            throw new tf_TriggerException(TRIGGER_HANDLER_INSTANCE_EXCEPTION + ex.getMessage()); 
        }
    }
}