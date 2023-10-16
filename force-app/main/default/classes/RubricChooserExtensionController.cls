public class RubricChooserExtensionController
{
    private final Rubric__c theRubric;

    public RubricChooserExtensionController(ApexPages.StandardController stdController)
    {
    	//stdController.addFields(new List<string>{ 'Skill__c', 'Special_Objective__c' }); 
        stdController.addFields(new List<string>{ 'Skill__c', 'Special_Objective__c','BedRock__c' });// Added by CQ for BedRock Project
        theRubric = (Rubric__c)stdController.getRecord();
    }

    public PageReference SelectRubric()
    {
        PageReference rubricPage = null;
  /*         if( theRubric.Special_Objective__c > 0)  
        {
           rubricPage = Page.RubricEdit;
        }
        else {
             rubricPage = Page.RubricObjEdit;	
        	}  // before Bedrock version */
        
        if (theRubric.BedRock__c)
        {
            	// moved as first check by stw to ensure Bedrock has priority
				rubricPage = Page.RubricBedRockEdit;//changed by CQ based on BedRock requirements
                system.debug(theRubric.BedRock__c);
                system.debug(rubricPage);            
        }    
        
        else if( theRubric.Special_Objective__c == 0)  //changed by CQ based on BedRock requirements
        {
            rubricPage = Page.RubricObjEdit;
            system.debug('Spec. Obj = 0');
            system.debug(rubricPage);
        }        
        else
        {
             	rubricPage = Page.RubricEdit;
                system.debug(theRubric.BedRock__c);
                system.debug(rubricPage);
        }
        rubricPage.getParameters().putAll(ApexPages.currentPage().getParameters());
        rubricPage.setRedirect(true);
        return rubricPage;
    }
}