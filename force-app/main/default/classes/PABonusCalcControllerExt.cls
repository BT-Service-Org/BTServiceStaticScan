////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Class Name       : PABonusCalcControllerExt
// Purpose/Overview : Controller extension for the PABonusCalc page. Used for calculating Spot Bonuses
// Author           : Troy Hedges
// Test Class       : <todo>
//
// Change History   : Date Modified | Developer Name  | Method/Section Modified/Added  | Purpose of Changes
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public with sharing class PABonusCalcControllerExt
{

  private Contact contact;

  //////////////////////////
  // spot bonus variables //
  //////////////////////////
  public PABonusCalcResult bonusResults {get; set;}
  public Date bonusCalcDate;

  public Boolean debugFlag {get; set;}

  ///////////////////////////////////////////////////////////////////////////////////////////
  // this testContact section was only added to try and fix UI anomaly with the DatePicker //
  // the pop-up calendar would not show and Googling indicated this would help             //
  ///////////////////////////////////////////////////////////////////////////////////////////
  private Contact testContact;

  public Contact getTestContact()
  {
    if (testContact == null) testContact = new Contact();

    return testContact;
  }

  public void setTestContact(Contact value)
  {
    testContact = value;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Description : Setter for the bonus calculation date. This is used in the UI to set a target date to 
  //               run the calculations for.
  // Params      : bonusCalcDate - the Date value
  // Return      : none
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  public void setBonusCalcDate(Date bonusCalcDate)
  {
    this.bonusCalcDate = bonusCalcDate;
  }

   ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Description : Getter for the bonus calculation date
  // Params      : n/a
  // Return      : String representation of the date object. Needed as default value causes parsing issue
  //               in the UI.
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  public String getBonusCalcDate()
  {
    return bonusCalcDate.format();
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Description : Constructor.
  // Params      : stdController - the standard controller for Spot Bonus object
  // Return      : none
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  public PABonusCalcControllerExt(ApexPages.StandardController stdController)
  {
    this.contact = (Contact)stdController.getRecord();
    this.contact = [SELECT Id, Name FROM Contact WHERE ID = :contact.Id];
    if(ApexPages.currentPage().getParameters().get('debug') !=null){
      this.debugFlag = Boolean.valueOf(ApexPages.currentPage().getParameters().get('debug'));
    }else{
      this.debugFlag=false;
    }
    calcBonusEligibility();
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Description : Calculate bonus eligibility for the given PA candidate with target end date.
  // Params      : endDate - the Date value for the target end date
  // Return      : Returns null to stay on same page.
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  public PageReference calcBonusEligibility(Date endDate)
  {
    bonusResults = PABonusCalcUtils.calcBonus(contact, endDate, false);
    System.debug('>>>>>>>> calcBonusEligibility(Date endDate) = '+bonusResults);
    return null;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Description : Calculate bonus eligibility for the given PA candidate with target end date default to today.
  // Params      : n/a
  // Return      : Returns null to stay on same page.
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  public PageReference calcBonusEligibility()
  {
    bonusCalcDate = Date.today();
    return calcBonusEligibility(Date.today());
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Description : Calculate bonus eligibility for the given PA candidate with target end date provided in
  //               the UI.
  // Params      : n/a
  // Return      : Returns null to stay on same page.
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  public PageReference calcBonusForTargetDate()
  {
    return calcBonusEligibility(bonusCalcDate);
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Description : Create the Spot Bonus records for the given PA based on the bonus analysis performed.
  // Params      : n/a
  // Return      : A page reference that will route to the first Spot Bonus record; else return null
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  public PageReference createSpotBonusRecs()
  {

    ID spotBonusID = PABonusCalcUtils.createSpotBonusRecs(bonusResults);

    if (spotBonusID != null)
    {
      return new PageReference('/' + spotBonusID);
    }

    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Creating Spot Bonus records not allowed.');
    ApexPages.addMessage(myMsg);
    return null;

  }
}