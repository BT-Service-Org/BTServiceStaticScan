@isTest
public with sharing class PSCTestDataFactory {
    public static ccnavmenus__Menu__c createMenu(){
        ccnavmenus__Menu__c menuObj = new ccnavmenus__Menu__c();
        menuObj.Name = 'PSC Menu';

        return menuObj;
    }

    public static ccnavmenus__Menu_Item__c createMenuItem(Id menuId,Id menuItemId){
        ccnavmenus__Menu_Item__c menuItemObj1 = new ccnavmenus__Menu_Item__c();
        if(menuId != null){
            menuItemObj1.ccnavmenus__Menu__c = menuId;
        }
        if(menuItemId != null){
            menuItemObj1.ccnavmenus__Menu_Item__c = menuItemId;
        }
        menuItemObj1.Name = 'Sales Cloud';
        menuItemObj1.ccnavmenus__Position__c = '1';
        menuItemObj1.ccnavmenus__URL__c = '/ServicesCentral/s';

        return menuItemObj1;
    }

    public static Knowledge__kav createKnowledge(){
        Id recTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('PSC_Knowledge').getRecordTypeId();
        Knowledge__kav kObj = new Knowledge__kav ();
        kObj.Summary = 'test summary';
        kObj.Title = 'test title';
        kObj.Body__c = 'test body';
        kObj.UrlName = 'test-title';
        kObj.Legacy_Id__c = '123';
        kObj.recordTypeId = recTypeId;
        return kObj;
    }

    public static Method__C createMethod(Double methodNumber){
        Method__C newObj = new Method__c();
        newObj.Method_Number__c = methodNumber;

        return newObj;
    }


    public static Methodology_Version__C createMethodVersion(Id methodId){
        Methodology_Version__C mvObj = new Methodology_Version__C();
        if(methodId != null){
            mvObj.Method__C = methodId;
        }

        return mvObj;
    }

    public static Grouping__c createGrouping(String grpName){
        Grouping__c newObj = new Grouping__c();
        newObj.Name = grpName;

        return newObj;
    }

    public static Method_by_Grouping__C createMethodByGrouping(Id methodId, Id groupId){
        Method_by_Grouping__C mgObj = new Method_by_Grouping__C();
        if(methodId != null){
            mgObj.Method__C = methodId;
        }
        if(groupId != null){
            mgObj.Grouping__C = groupId;
        }
        return mgObj;
    }

    public static Stage__c createStage(String stageName){
        Stage__c newObj = new Stage__c();
        newObj.Name = stageName;

        return newObj;
    }

    public static Method_with_Stage__c createMethodByStaging(Id methodId, Id stageId){
        Method_with_Stage__c msObj = new Method_with_Stage__c();
        if(methodId != null){
            msObj.Method__C = methodId;
        }
        if(stageId != null){
            msObj.Stage__C = stageId;
        }
        return msObj;
    }

    public static Deliverables__c createDeliverable(){
        Deliverables__c deliverableObj = new Deliverables__c();
        deliverableObj.Name = 'Journey Map';
        return deliverableObj;
    }

    public static Method_by_Deliverables__c createMethodByDeliverable(Id methodId, Id deliverableId){
        Method_by_Deliverables__c mdObj = new Method_by_Deliverables__c();
        if(methodId != null){
            mdObj.Method__C = methodId;
        }
        if(deliverableId != null){
            mdObj.Deliverable__c = deliverableId;
        }
        return mdObj;
    }
    
    public static Contact createContact(){
        Contact con = new Contact();
        con.LastName = 'test last';
        con.Email = 'test@test.com';
        return con;
    }
    
    public static Project_Assignment__c createProjectAssignment(Id projectId, Id conId){
        Project_Assignment__c proAss = new Project_Assignment__c();
        proAss.End_Date__c  = Date.today().addDays(10);
        proAss.PSA_Project__c  = projectId;
        proAss.Resource__c   = conId;
        return proAss;
    }
    
    public static PSA_Project__c createProject(String projectRecType){
        Id recTypeId = Schema.SObjectType.PSA_Project__c.getRecordTypeInfosByDeveloperName().get(projectRecType).getRecordTypeId();
        PSA_Project__c proAss = new PSA_Project__c();
        proAss.Name = 'test Project';
        return proAss;
    }
    
    public static Project_by_Product_Offerings__c createProjectByProOff(Id projectId,Id productId){
        Project_by_Product_Offerings__c proAss = new Project_by_Product_Offerings__c();
        proAss.Project__c = projectId;
        proAss.Product__c = productId;
        return proAss;
    }
    
    public static Product_Custom__c createProduct(String recTypeName){
        Id recTypeId = Schema.SObjectType.Product_Custom__c.getRecordTypeInfosByDeveloperName().get(recTypeName).getRecordTypeId();
        Product_Custom__c prod = new Product_Custom__c();
        prod.Name = 'test Product';
        prod.RecordTypeId = recTypeId;
        return prod;
    }
    
    public static Article_Product__c createArticleProduct(Id articleId,Id prodId){
        Article_Product__c artProd = new Article_Product__c();
        artProd.Knowledge__c = articleId;
        artProd.Product__c  = prodId;
        return artProd;
    }
    
    public static ContentVersion createFile(){
        ContentVersion file = new ContentVersion();
        file.VersionData  = Blob.valueOf('test');
        file.Title   = 'prodId';
        file.PathOnClient = 'test';
        return file;
    }
    
    public static ContentDocumentLink createContentDocLink(Id ContentDocumentId ,Id LinkedEntityId ){
        ContentDocumentLink file = new ContentDocumentLink();
        file.ContentDocumentId  = contentDocumentId;
        file.LinkedEntityId   = linkedEntityId;
        return file;
    }
    
    public static Activity__c createActivity(){
        Activity__c act = new Activity__c();
        act.Name  = 'test';
        return act;
    }
    
    public static Method_By_Activity__c createMethodActivity(Id methodId,Id activityId){
        Method_By_Activity__c metAct = new Method_By_Activity__c();
        metAct.Method__c   = methodId;
        metAct.Activity__c    = activityId;
        return metAct;
    }
    
    public static Activity_Ownership__c createActivityOwnerShip(Id activityId,Id roleId){
        Activity_Ownership__c actOwn = new Activity_Ownership__c();
        actOwn.Activity__c = activityId;
        actOwn.Role__c = roleId;
        actOwn.Accountable__c  = 'Yes';
        return actOwn;
    }
    
    public static Role__c createRole(){
        Role__c role = new Role__c();
        role.name   = 'Test Role';
        return role;
    }

    public static Playbook__c createPlaybook(String ContractType){
        Playbook__c playbook = new Playbook__c();
        playbook.Contract_Type__c = ContractType;
        return playbook;
    }

    public static Method_Ownership_By_Product__c createMethodOwnershipByProduct(Id roleId, Id productId, Id methodId){
        Method_Ownership_By_Product__c mobp = new Method_Ownership_By_Product__c();
        mobp.Role__c = roleId;
        mobp.Product__c = productId;
        mobp.Method__c = methodId;
        return mobp;
    }

    public static Method_by_Product__c createMethodByProduct(Id productId, Id methodId){
        Method_by_Product__c mobp = new Method_by_Product__c();
        mobp.Product__c = productId;
        mobp.Method__c = methodId;
        return mobp;
    }

    public static Article_Method__c createArticleMethod(Id articleId,Id methodId){
        Article_Method__c artProd = new Article_Method__c();
        artProd.Knowledge__c = articleId;
        artProd.Method__c  = methodId;
        return artProd;
    }
    
    public static Templates__c createtemplate(Id methodId){
        Templates__c temp = new Templates__c();
        temp.Method__c  = methodId;
        temp.Method_Version_Description__c = 'test';
        temp.Link__c = 'https://docs.google.com/';
        temp.Type__c = 'Google Drive Link';
        return temp;
    }

    public static Industry__c createIndustry(String Name, Integer Order){
        Industry__c industry = new Industry__c();
        industry.Name = Name;
        industry.Order__c = Order;
        return industry;
    }

    public static Feedback_for_Method__c createFeedbackForMethod(Id methodId, String recTypeName){
        Id recTypeId = Schema.SObjectType.Feedback_for_Method__c.getRecordTypeInfosByDeveloperName().get(recTypeName).getRecordTypeId();
        Feedback_for_Method__c feedbackForMethod = new Feedback_for_Method__c();
        feedbackForMethod.Method__c = methodId;
        feedbackForMethod.RecordTypeId = recTypeId;
        return feedbackForMethod;
    }

    public static Article_Feedback__c createArticleFeedback(Id knowledgeId, String sentiment){
        Article_Feedback__c articleFeedback = new Article_Feedback__c();
        articleFeedback.Knowledge__c = knowledgeId;
        articleFeedback.Sentiment__c = sentiment;
        articleFeedback.Feedback__c = 'Test';
        articleFeedback.Status__c = 'In Progress';
        return articleFeedback;
    }
    
    public static Achievement__c createAchievement(){
        Id recordTypeIdBadge = Schema.SObjectType.Achievement__c.getRecordTypeInfosByDeveloperName().get('Badge').getRecordTypeId();
        Achievement__c achievement = new Achievement__c();
        achievement.RecordTypeId = recordTypeIdBadge;
        achievement.Activity__c = 'Contribute';
        achievement.Count_Needed__c = 1;
        achievement.Active__c = true;
        return achievement;
    }
    
    public static User_Achievement_Activity__c createUAA(){
        Id recordTypeId = Schema.SObjectType.User_Achievement_Activity__c.getRecordTypeInfosByDeveloperName().get('Tracking').getRecordTypeId();
        User_Achievement_Activity__c uaa = new User_Achievement_Activity__c();
        uaa.RecordTypeId = recordTypeId;
        uaa.User__c = UserInfo.getUserId();
        uaa.Activity__c = 'Contribute';
        return uaa;
    }
}