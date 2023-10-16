public with sharing class PSCMethodologyHomeFormsCtrl {
    
    @AuraEnabled(Cacheable=true)
    public static List<MethodologyFormParentWrapper> getMethodologyFormData() {
        List<MethodologyFormParentWrapper> methodologyCardList = new List<MethodologyFormParentWrapper>();
        List<MethodologyFormWrapper> methodologySOWFormList = new List<MethodologyFormWrapper>();
        List<MethodologyFormWrapper> methodologyOrderFormList = new List<MethodologyFormWrapper>();
        List<MethodologyFormChildWrapper> sowPlayBooks = new List<MethodologyFormChildWrapper>();
        List<MethodologyFormChildWrapper> orderPlayBook = new List<MethodologyFormChildWrapper>();
        List<MethodologyFormChildWrapper> stageList = new List<MethodologyFormChildWrapper>();
        Map<Id, MethodologyFormChildWrapper> projectRoles = new Map<Id, MethodologyFormChildWrapper>();
        Map<Id, MethodologyFormChildWrapper> productOffering = new Map<Id, MethodologyFormChildWrapper>();

        for(Playbook__c playbook : [SELECT Id, Name, Contract_Type__c, Community_URL__c 
                                    FROM Playbook__c 
                                    WHERE Contract_Type__c IN :PSCConstants.PLAYBOOK_CONTRACT_TYPES 
                                    AND Status__c = 'Live'
                                    LIMIT 50000]){
            if(PSCConstants.CONTRACT_TYPE_SOW.equals(playbook.Contract_Type__c)){
                sowPlayBooks.add(new MethodologyFormChildWrapper(playbook.Id, playbook.Name, playbook.Community_URL__c));
            }else if(PSCConstants.CONTRACT_TYPE_ORDER_FORM.equals(playbook.Contract_Type__c)) {
                orderPlayBook.add(new MethodologyFormChildWrapper(playbook.Id, playbook.Name, playbook.Community_URL__c));
            }else if(PSCConstants.CONTRACT_TYPE_BOTH_ORDER_N_SOW.equals(playbook.Contract_Type__c)) {
                sowPlayBooks.add(new MethodologyFormChildWrapper(playbook.Id, playbook.Name, playbook.Community_URL__c));
                orderPlayBook.add(new MethodologyFormChildWrapper(playbook.Id, playbook.Name, playbook.Community_URL__c));
            }
        }

        for(Stage__c stage : [SELECT Id, Name, Community_URL__c FROM Stage__c WHERE RecordType.DeveloperName = 'Project' ORDER BY StageNumber__c ASC LIMIT 50000]){
            stageList.add(new MethodologyFormChildWrapper(stage.Id,stage.Name, stage.Community_URL__c));
        }

        for(Method_Ownership_By_Product__c mobp : [SELECT Id, Product__c,  Product__r.Status__c, Product__r.Name, Product__r.Community_URL__c, Role__c, Role__r.Name, Role__r.Community_URL__c FROM Method_Ownership_By_Product__c WHERE (Product__r.Status__c='Live' AND Product__c != null) OR Role__c != null LIMIT 50000]){
            if(mobp.Role__c != null){
                projectRoles.put(mobp.Role__c, new MethodologyFormChildWrapper(mobp.Role__c, mobp.Role__r.Name, mobp.Role__r?.Community_URL__c));

            }
            if (mobp.Product__c != null && mobp.Product__r.Status__c=='Live') {
                productOffering.put(mobp.Product__c, new MethodologyFormChildWrapper(mobp.Product__c, mobp.Product__r.Name, mobp.Product__r?.Community_URL__c));
            }
        }

        methodologySOWFormList.add(new MethodologyFormWrapper(PSCConstants.SOW_PLAYBOOKS_TITLE, PSCConstants.ALL_PLAYBOOKS_TITLE, System.Label.PSC_Playbook_Home_Link,sowPlayBooks));
        methodologySOWFormList.add(new MethodologyFormWrapper(PSCConstants.STAGES_TITLE, PSCConstants.ALL_STAGES_TITLE, System.Label.PSC_Stage_Home_Link, stageList));
        methodologySOWFormList.add(new MethodologyFormWrapper(PSCConstants.PROJECT_ROLES_TITLE, PSCConstants.ALL_PROJECT_ROLES_TITLE, System.Label.PSC_Project_Role_Home_Link, projectRoles.values()));
        methodologyOrderFormList.add(new MethodologyFormWrapper(PSCConstants.PRODUCT_OFFERINGS_TITLE, PSCConstants.ALL_PRODUCT_OFFERING_TITLE, System.Label.PSC_Product_Offering_Home_Link, productOffering.values()));
        methodologyOrderFormList.add(new MethodologyFormWrapper(PSCConstants.ORDER_FORM_PLAYBOOKS_TITLE, PSCConstants.ALL_PLAYBOOKS_TITLE, System.Label.PSC_Playbook_Home_Link, orderPlayBook));

        methodologyCardList.add(new MethodologyFormParentWrapper(PSCConstants.SOW_FORM_TITLE,methodologySOWFormList));
        methodologyCardList.add(new MethodologyFormParentWrapper(PSCConstants.ORDER_FORM_TITLE, methodologyOrderFormList));

        return methodologyCardList;
    } 

    @AuraEnabled(Cacheable=true)
    public static List<Stage__c> getAllStages(){
        List<Stage__c> stageList = new List<Stage__c>([SELECT Id, Name, Description__c, Community_URL__c FROM Stage__c LIMIT 50000]);
        return stageList;
    }

    @AuraEnabled(Cacheable=true)
    public static List<MethodologyFormChildWrapper> getAllProductOffering(){
        List<MethodologyFormChildWrapper> allProductOffering = new List<MethodologyFormChildWrapper>();
        for(Method_Ownership_By_Product__c mobp : [SELECT Id, Product__c, Product__r.Name, Product__r.Community_URL__c, Role__c, Role__r.Name, Role__r.Community_URL__c FROM Method_Ownership_By_Product__c WHERE Product__c != null LIMIT 50000]){
            allProductOffering.add(new MethodologyFormChildWrapper(mobp.Product__c,mobp.Product__r.Name,'/ServicesCentral/s/product-offerings'));
        }
        return allProductOffering;
    }

    public class MethodologyFormParentWrapper{
        @AuraEnabled
        public String title;
        @AuraEnabled
        public List<MethodologyFormWrapper> methodologyFormList;

        public MethodologyFormParentWrapper(String title, List<MethodologyFormWrapper> methodologyFormList){
            this.title = title;
            this.methodologyFormList = methodologyFormList;
        }
    }

    public class MethodologyFormWrapper{
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String linkTitle;
        @AuraEnabled
        public String allPageLink;
        @AuraEnabled
        public List<MethodologyFormChildWrapper> methodologyChildList;

        public MethodologyFormWrapper(String title, String linkTitle, String allPageLink, List<MethodologyFormChildWrapper> methodologyChildList){
            this.title = title;
            this.linkTitle = linkTitle;
            this.allPageLink = allPageLink;
            this.methodologyChildList = methodologyChildList;
        }
    }

    public class MethodologyFormChildWrapper{
        @AuraEnabled
        public Id recId;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String redirectLink;

        public MethodologyFormChildWrapper(Id recId, String name, String redirectLink){
            this.recId = recId;
            this.name = name;
            this.redirectLink = redirectLink;
        }
    }
}