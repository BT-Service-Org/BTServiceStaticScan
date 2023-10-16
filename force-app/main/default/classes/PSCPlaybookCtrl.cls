public class PSCPlaybookCtrl {
    @AuraEnabled(Cacheable=true)
    public static PlayBookWrapper getAllPlayBookInfo(String key, String pageName){
        List<PlayBookDetailWrapper> playbookDetailListWrapper   = new List<PlayBookDetailWrapper>();
        PlayBookWrapper playBookWrap                            = new PlayBookWrapper();
        
        key = string.isNotBlank(key)?key:'Practice/Role';
        pageName = string.isNotBlank(pageName)?pageName:'playbooks';
        List<String> keyList = key.split(';');

        if(pageName=='playbooks'){
            List<Playbook__c> playBookList = [SELECT Id, Name, Description__c, Contract_Type__c,Community_URL__c 
                                            FROM Playbook__c 
                                            WHERE Contract_Type__c in :keyList 
                                            AND Status__c = 'Live'
                                            ORDER BY Name
                                            LIMIT 50000];
            if(playBookList.size()>0){
                for(Playbook__c playbook:playBookList){
                    PlayBookDetailWrapper playbookDetailWrapper = createPlayBookDetailWrapperInstance(playbook.Name,playbook.Description__c,playbook.Id,playbook.Community_URL__c,null);
                    playbookDetailListWrapper.add(playbookDetailWrapper);
                }
            
                if(key.equalsIgnoreCase('SOW;Both Order Form & SOW')){  
                    playBookWrap = createPlayBookWrapperInstance(playbookDetailListWrapper,PSCSettingService.getValue('Playbook_Images'),System.Label.Playbook_Header_Text,System.Label.Playbook_Header_Description,null);
                }
                else if(key.equalsIgnoreCase('Order Form;Both Order Form & SOW')){
                    playBookWrap = createPlayBookWrapperInstance(playbookDetailListWrapper,PSCSettingService.getValue('Playbook_Images'),System.Label.Playbook_Orderform_Header,System.Label.Playbook_Orderform_Description,null);
                }
                else if(key.equalsIgnoreCase('Practice')){
                    playBookWrap = createPlayBookWrapperInstance(playbookDetailListWrapper,PSCSettingService.getValue('Playbook_Images'),'Select your Practice','',null);
                }
                else if(key.equalsIgnoreCase('Role')){
                    playBookWrap = createPlayBookWrapperInstance(playbookDetailListWrapper,PSCSettingService.getValue('Playbook_Images'),'Select your Role','',null);
                }   
            }
        }
        else if(pageName=='allStages'){
            List<Stage__c> stageList = [SELECT Id, Name, Description__c, Community_URL__c 
                                        FROM Stage__c
                                        WHERE RecordType.DeveloperName = 'Project'
                                        ORDER BY StageNumber__c ASC
                                        LIMIT 50000];
            if(stageList.size()>0){
                for(Stage__c stage:stageList){
                    PlayBookDetailWrapper playbookDetailWrapper = createPlayBookDetailWrapperInstance(stage.Name,stage.Description__c,stage.Id,stage.Community_URL__c,null);
                    playbookDetailListWrapper.add(playbookDetailWrapper);
                }
                playBookWrap = createPlayBookWrapperInstance(playbookDetailListWrapper,PSCSettingService.getValue('Stages_Images'),System.Label.pscStageHeader,'',null);
            }
        }
        else if(pageName=='roles'){
            List<Method_Ownership_By_Product__c> roles = [SELECT Id, Product__c, Product__r.Name, Product__r.Community_URL__c, Role__c, Role__r.Name, Role__r.Community_URL__c 
                                                        FROM Method_Ownership_By_Product__c 
                                                        WHERE Role__c != null 
                                                        ORDER BY Name
                                                        LIMIT 50000];

            Set<String> uniqueRoleNames = new Set<String>();
            List<Method_Ownership_By_Product__c> uniqueRoles = new List<Method_Ownership_By_Product__c>();

            for (Method_Ownership_By_Product__c role : roles) {
                if(!uniqueRoleNames.contains(role.Role__r.Name)){
                    uniqueRoleNames.add(role.Role__r.Name);
                    PlayBookDetailWrapper playbookDetailWrapper = createPlayBookDetailWrapperInstance(role.Role__r.Name,null,role.Role__c,role.Role__r.Community_URL__c,null);
                    playbookDetailListWrapper.add(playbookDetailWrapper);
                }
            }
            if(playbookDetailListWrapper.size()>0){
                playBookWrap = createPlayBookWrapperInstance(playbookDetailListWrapper,PSCSettingService.getValue('Roles_Images'),System.Label.pscRoleHeader,System.Label.pscRoleHeaderDescription,null);
            }
        }
        else if(pageName=='productOfferings'){
            Set<String> uniqueProductNames = new Set<String>();

            List<Method_Ownership_By_Product__c> productOfferings = [SELECT Id, Product__c, Product__r.Name, Product__r.Community_URL__c, Role__c, Role__r.Name, Role__r.Community_URL__c 
                                                                    FROM Method_Ownership_By_Product__c 
                                                                    WHERE Product__c != null
                                                                    AND Product__r.Status__c = 'Live'
                                                                    ORDER BY Name
                                                                    LIMIT 50000];
            
            for (Method_Ownership_By_Product__c product : productOfferings) {
                if(!uniqueProductNames.contains(product.Product__r.Name)){
                    uniqueProductNames.add(product.Product__r.Name);
                    PlayBookDetailWrapper playbookDetailWrapper = createPlayBookDetailWrapperInstance(product.Product__r.Name,null,product.Product__c,product.Product__r.Community_URL__c,null);
                    playbookDetailListWrapper.add(playbookDetailWrapper);
                }
            }
            if(playbookDetailListWrapper.size()>0){
                playBookWrap = createPlayBookWrapperInstance(playbookDetailListWrapper,PSCSettingService.getValue('Product_Offering_Images'),System.Label.All_Product_Offerings,'',null);
            }
        }
        else if(pageName=='serviceOfferings'){
            List<Method_Ownership_By_Product__c> serviceOfferings = [SELECT Id, Product__c, Product__r.Name, Product__r.Community_URL__c, Role__c, Role__r.Name, Role__r.Community_URL__c 
                                                                    FROM Method_Ownership_By_Product__c 
                                                                    WHERE Product__c != null 
                                                                    AND Product__r.RecordType.DeveloperName='Service_Offering' 
                                                                    AND Product__r.Status__c = 'Live'
                                                                    ORDER BY Name
                                                                    LIMIT 50000];
            Set<String> uniqueProductNames = new Set<String>();
            List<Method_Ownership_By_Product__c> uniqueServiceOfferings = new List<Method_Ownership_By_Product__c>();
            
            for (Method_Ownership_By_Product__c product : serviceOfferings) {
                if(!uniqueProductNames.contains(product.Product__r.Name)){
                    uniqueProductNames.add(product.Product__r.Name);
                    PlayBookDetailWrapper playbookDetailWrapper = createPlayBookDetailWrapperInstance(product.Product__r.Name,null,product.Product__c,product.Product__r.Community_URL__c,null);
                    playbookDetailListWrapper.add(playbookDetailWrapper);
                }
            }
            if(playbookDetailListWrapper.size()>0){
                playBookWrap = createPlayBookWrapperInstance(playbookDetailListWrapper,PSCSettingService.getValue('Product_Offering_Images'),System.Label.pscServicesOfferingHeader,System.Label.pscServicesOfferingHeaderDesc,null);
            }
        }
        else if(pageName=='Industries'){
            String imageMetadata = PSCSettingService.getValue('Industries_Images');
            List<Industry__c> industryList = [SELECT Id,Name
                                              FROM Industry__c
                                              ORDER BY Name];
            for (Industry__c industry : industryList) {
                PlayBookDetailWrapper playbookDetailWrapper = createPlayBookDetailWrapperInstance(industry.Name,null,industry.Id,'/ServicesCentral/s/global-search/%40uri#sort=relevancy&f:@pscindustrynames=['+EncodingUtil.urlEncode(industry.Name, 'UTF-8').replace ('+', '%20')+']',null);
                playbookDetailListWrapper.add(playbookDetailWrapper);
                
            }
            if(playbookDetailListWrapper.size()>0){
                playBookWrap = createPlayBookWrapperInstance(playbookDetailListWrapper,PSCSettingService.getValue('Industries_Images'),'','','/industry/fallback.png');
            }
        } else if(pageName=='Target Audience'){
            String imageMetadata = PSCSettingService.getValue('target_audience_images');
            List<Role_Family__c> TargetAudienceList = [SELECT Id,Name
                                              FROM Role_Family__c
                                              ORDER BY Name];
            for(Role_Family__c audience : TargetAudienceList) {
                PlayBookDetailWrapper playbookDetailWrapper = createPlayBookDetailWrapperInstance(audience.Name,null,audience.Id,'/ServicesCentral/s/global-search/%40uri#sort=relevancy&f:@targetaudience=['+EncodingUtil.urlEncode(audience.Name, 'UTF-8').replace ('+', '%20')+']',null);
                playbookDetailListWrapper.add(playbookDetailWrapper);
                
            }
            if(playbookDetailListWrapper.size()>0){
                playBookWrap = createPlayBookWrapperInstance(playbookDetailListWrapper,PSCSettingService.getValue('target_audience_images'),'','','/audience/role.png');
            }
        }
        return playBookWrap;
    }

    private static PlayBookDetailWrapper createPlayBookDetailWrapperInstance(String title,String description,String id,String communityURL,String bgUrl){
        PlayBookDetailWrapper playbookDetailWrapperIns = new PlayBookDetailWrapper();
        playbookDetailWrapperIns.name = title;
        playbookDetailWrapperIns.description = description;
        playbookDetailWrapperIns.id = id;
        playbookDetailWrapperIns.communityURL = communityURL;
        playbookDetailWrapperIns.bgUrl = bgUrl;
        return playbookDetailWrapperIns;
    }

    private static PlayBookWrapper createPlayBookWrapperInstance(List<PlayBookDetailWrapper> sobjectList,String playBookResources,String pageHeader,String pageDescription,String fallbackImg){
        PlayBookWrapper playBookWrapIns                            = new PlayBookWrapper();
        playBookWrapIns.sobjectList = sobjectList;
        playBookWrapIns.playBookResources = playBookResources;
        playBookWrapIns.pageHeader = pageHeader;
        playBookWrapIns.pageDescription = pageDescription;
        if(fallbackImg != null){
            playBookWrapIns.fallbackTileImg = fallbackImg;
        }
        return playBookWrapIns;
    }
    
    public class PlayBookWrapper{
        @AuraEnabled
        public List<PlayBookDetailWrapper> sobjectList{get;set;}
        @AuraEnabled
        public String playBookResources{get;set;}
        @AuraEnabled
        public string pageHeader{get;set;}
        @AuraEnabled
        public string pageDescription{get;set;}
        @AuraEnabled
        public string fallbackTileImg{get;set;}
    }

    public class PlayBookDetailWrapper{
        @AuraEnabled
        public string name{get;set;}
        @AuraEnabled
        public string description{get;set;}
        @AuraEnabled
        public string id{get;set;}
        @AuraEnabled
        public string communityURL{get;set;}
        @AuraEnabled
        public string bgUrl{get;set;}   
    }
}