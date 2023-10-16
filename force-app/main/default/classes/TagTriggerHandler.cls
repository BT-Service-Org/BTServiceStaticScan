/*------------------------------------------------------------
 Author:        Rohan Saxena
 Description:   Handler Class for Tag Trigger
 Apex Class :   TagTriggerHandler
 Test Class:    TagTriggerHandlerTest
------------------------------------------------------------*/
public with sharing class TagTriggerHandler {

/*
   * @Method:      preventProductinTag
   * @Created by:  Rohan Saxena
   * @Description: This method prevent the insertion of Tag records having same name as of product
   * @Param:       List < Tag__c >
   * @Return:      
   */
    public static void preventProductinTag(List < Tag__c > newTag) {
      try {

        set < String > tagNames = new set < String > ();
        Map < String, Boolean > tagAndProductstatus = new Map < String, Boolean > ();

        for (Tag__c tag: newTag) {
          tagNames.add(tag.Name.toLowerCase());
        }

        List < Product_Custom__c > lstExistingproduct = [SELECT Id, Name FROM Product_Custom__c WHERE Name IN: tagNames];
        if (!lstExistingproduct.isEmpty()) {
          for (Product_Custom__c tag: lstExistingproduct) {
            if (tagNames.contains(tag.Name.toLowerCase())) {
              tagAndProductstatus.put(tag.Name.toLowerCase(), true);
            }
          }
  
          for (Tag__c tag: newTag) {
            if (tagAndProductstatus.get(tag.Name.toLowerCase())) {
              tag.addError(System.Label.PSC_Same_Tag_ProductError);
            }
          }
        }

      } catch (Exception e) {
        throw new custom_exception(e.getMessage());
      }
    }
  
    //Custom Exception
    public class custom_exception extends Exception {
  
    }
  }