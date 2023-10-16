////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Class Name       : PABonusCalcResult
// Purpose/Overview : Class to collect the Spot Bonus analysis for a given PA. 
// Author           : Troy Hedges
// Test Class       : PABonusCalcTest
//
// Change History   : Date Modified | Developer Name  | Method/Section Modified/Added  | Purpose of Changes
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public class PABonusCalcResult
{
  public ID paID {get; set;}                    // the PA record id of the PA
  public ID paContactID {get; set;}             // the PA contact id
  public String fullName {get; set;}            // the full name of the PA
  public Date startDate {get; set;}             // the start date of the bonus evaluation period
  public Date endDate {get; set;}               // the end date of the bonus evaluation period
  public Boolean bonusEligible {get; set;}      // flag to indicate if the PA is bonus eligible based on all the analysis
  public Boolean bonusOverlap {get; set;}       // flag to indicate that bonus evaluation period overlaps with previous bonus
  public Decimal bonusAmount {get; set;}        // the calculated bonus amount based on the analysis
  public Decimal baseBonusAmount {get; set;}        // the calculated bonus amount based on the analysis
  public Decimal ctaIncrement {get; set;}        // the calculated bonus amount based on the analysis
  public Boolean paQualified {get; set;}        // flag to indicate candidate was a PA on PSE engagements over the full time period
  public Decimal utilPercentage {get; set;}     // the utilization percentage over the analysis time period [not factored in to bonus]
  public Boolean ctaQualified {get; set;}       // flag to indicate candidate is a CTA
  public Decimal ctaPercentage {get; set;}      // the percentage of time candidate was CTA over the analysis time period
  public Date ctaAcquireDate {get; set;}        // the date of CTA acquisition
  public Integer cntCSAT {get; set;}            // the number of CSAT surveys over the analysis time period
  public Decimal avgCSAT {get; set;}            // the avg CSAT score over the analysis time period
  public Date lastBonusDate {get; set;}         // the date of last bonus; this is the last bonus period end date
  //public Decimal lastBonusAmount {get; set;}    // the last bonus amount
  public List<String> debugMessages {get; set;}  //Debug Messages
  public String notes {get; set;}               // general string field to collect notes on the PA candidate
  public String paProjectNotes {get; set;}               // general string field to collect notes on the PA project

  public List<PA_Onboarding_Project__c> projList = new List<PA_Onboarding_Project__c>();
  public List<PA_Customer_Survey__c> surveyList = new List<PA_Customer_Survey__c>();


  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Description : Constructor.
  // Params      : n/a
  // Return      : n/a
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  public PABonusCalcResult()
  {
    reset();
  }

  public void reset()
  {
  	bonusEligible = false;
    bonusOverlap = false;
    paQualified = false;
    ctaQualified = false;
    ctaPercentage = 0;
    cntCSAT = 0;
    avgCSAT = 0.0;
	bonusAmount=0.0;
	baseBonusAmount = 0.0;
	ctaIncrement=0.0;
    projList.clear();
    surveyList.clear();
    debugMessages = new List<String>();
  }


  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Description : Getter for the list of PSE projects with dates in the spot bonus calculation date range.
  // Params      : n/a
  // Return      : list of PA_Onboarding_Project__c objects
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  public List<PA_Onboarding_Project__c>  getProjList()
  {
  	return projList;
  }

  public List<PA_Customer_Survey__c>  getSurveyList()
  {
  	return surveyList;
  }

  public String getFormattedStartDate()
  {
    if (startDate != null)
    {
      return startDate.format();
    }

    return '';
  }

  public String getFormattedEndDate()
  {
    if (endDate != null)
    {
      return endDate.format();
    }

    return '';
  }

  public String getFormattedLastBonusDate()
  {
    if (lastBonusDate != null)
    {
      return lastBonusDate.format();
    }

    return '';
  }

  public String getFormattedCTAAcquireDate()
  {
    if (ctaAcquireDate != null)
    {
      return ctaAcquireDate.format();
    }

    return '';
  }

  public String getFormattedBonusAmount()
  {
    if (bonusAmount != null)
    {
      List<String> args = new String[] {'0', 'number', '###,###,##0'};
      return String.format(bonusAmount.setScale(0).format(), args);
      //bonusAmount.setScale(0);
      //return bonusAmount.toPlainString();
    }

    return '';
  }

/*
  public String getFormattedLastBonusAmount()
  {
    if (lastBonusAmount != null)
    {
      List<String> args = new String[] {'0', 'number', '###,###,##0'};
      return String.format(lastBonusAmount.setScale(0).format(), args);
    }

    return '';
  }
  */

  public String getFormattedUtilPercentage()
  {
    if (utilPercentage != null)
    {
      List<String> args = new String[] {'0', 'number', '##0'};
      return String.format((utilPercentage * 100.0).setScale(0).format(), args);
    }

    return '';
  }

  public String getFormattedCTAPercentage()
  {
    if (ctaPercentage != null)
    {
      List<String> args = new String[] {'0', 'number', '##0'};
      return String.format((ctaPercentage * 100.0).setScale(0).format(), args);
    }

    return '';
  }

  public String getFormattedAvgCSAT()
  {
    if (avgCSAT != null)
    {
      List<String> args = new String[] {'0', 'number', '##0.##'};
      return String.format(avgCSAT.setScale(2).format(), args);
      //avgCSAT.setScale(1);
      //return avgCSAT.toPlainString();
    }

    return '';
  }

  public void addNote(String note)
  {
  	if (notes != null)
  	{
  		notes = notes + '; ' + note;
  	}
  	else
  	{
  		notes = note;
  	}
  }

}