/**
	Apex class Name : CSG_SkillsTaxonomySyncBatch
	@description		: This class automates the sync skill taxonomy between the external skill object records to CSG Profile Skill custom object
	Test Class		: CSG_SkillsTaxonomySyncBatchTest
	Created Date	: May 9, 2022  
	Database.executebatch(new CSG_SkillsTaxonomySyncBatch(),200);
*/

public class CSG_SkillsTaxonomySyncBatch implements Database.Batchable<sObject> {
  //The custom label "Skill_Batch_Frequency" stores the value LAST_N_DAYS:4
  public static final string SKILL_BATCH_FREQUENCY = String.escapeSingleQuotes(
    Label.Skill_Batch_Frequency
  );

  /**
     @description : Start method of the batch class to get the latest ProfileSkillTax external object records
     @return : Database.QueryLocator
     @param bc - Database.BatchableContext
     */

  public Database.QueryLocator start(Database.BatchableContext bc) {
    //Query all the Profile Skill tax records from external object whose Last modified date is in 4 days
    String query =
      'Select id,Primary_Product_Skill__c ,Last_Modified_Date__c,ProfileSkillTaxId__c,Type_c__c,Category_c__c,Sub_Category_c__c,Name__c,Description__c,ExternalId,One_Skill_c__c,CSG_Community_c__c from ProfileSkillTax__x  where Last_Modified_Date__c =' +
      SKILL_BATCH_FREQUENCY;

    return Database.getQueryLocator(query);
  }

  /**
     @description : Execute method of the batch class to update Taxonomy
     @param bc - Database.BatchableContext
     @param scope - Database.BatchableContext , List<Sobject>
     */
  public void execute(Database.BatchableContext bc, List<sObject> scope) {
    performExecution(scope);
  }

  /**
     @description : Logic which syncs the external object records to upsert CSG Profile Skill records
     @return : String
     @param scope - List<Sobject>
     */
  public string performExecution(List<sObject> scope) {
    string isSuccess = 'success';
    //List to store all the CSG Profile Skill records to upsert
    List<CSGProfileSkill__c> profileSkillsToUpsert = new List<CSGProfileSkill__c>();
    CSGProfileSkill__c profileSkill;

    for (Sobject eachSkill : scope) {
      ProfileSkillTax__x eachTax = (ProfileSkillTax__x) eachSkill;
      profileSkill = new CSGProfileSkill__c();
      profileSkill.External_Id__c = eachTax.ExternalId;
      profileSkill.Type__c = eachTax.Type_c__c;
      profileSkill.Category__c = eachTax.Category_c__c;
      profileSkill.Sub_Category__c = eachTax.Sub_Category_c__c;
      profileSkill.Name = eachTax.Name__c;
      profileSkill.Description__c = eachTax.Description__c;
      profileSkill.One_Skill__c = eachTax.One_Skill_c__c;
      profileSkill.CSG_Community__c = eachTax.CSG_Community_c__c;
      profileSkill.Primary_Product_Skill__c = eachTax.Primary_Product_Skill__c;
      profileSkillsToUpsert.add(profileSkill);
    }

    //Upsert the skills based off the External_Id__c field which has the unique Org 62 ProfileSkill Id
    Database.UpsertResult[] results = Database.upsert(
      profileSkillsToUpsert,
      CSGProfileSkill__c.External_Id__c.getDescribe().getSObjectField(),
      false
    );

    for (Integer i = 0; i < results.size(); i++) {
      if (!results.get(i).isSuccess()) {
        Database.Error err = results.get(i).getErrors().get(0);
        isSuccess = 'fail' + err.getMessage();
        Logger.error(err.getMessage(), results);
        //System.debug(Logginglevel.ERROR,'Error - '+err.getMessage() + '\nStatus Code : '+err.getStatusCode()+'\n Fields : '+err.getFields());
      }
    }
    Logger.saveLog();
    return isSuccess;
  }

  /**
     @description : Finish method of the batch class
     @param bc - Database.BatchableContext
     */
  public void finish(Database.BatchableContext bc) {
  }
}