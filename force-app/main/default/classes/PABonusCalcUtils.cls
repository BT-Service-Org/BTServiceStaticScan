////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Class Name       : PABonusCalcUtils
// Purpose/Overview : Contains the core logic for calculating the Spot Bonus results and creating Spot Bonus record. 
// Author           : Troy Hedges
// Test Class       : PABonusCalcTest
//
// Change History   : Date Modified | Developer Name  | Method/Section Modified/Added  | Purpose of Changes
//                    03/15/2017   | Geeta | Updated the avg CSAT score from 8.5 to 9 for bonus eligibility
//                    04/1/2018   | Geeta | Updated the avg CSAT score from 9 to 4.5 as CSAT changed to 5-point scale
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public with sharing class PABonusCalcUtils
{
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Description : Constructor.
  // Params      : n/a
  // Return      : n/a
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  public PABonusCalcUtils()
  {

  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Description : Calc spot bonus for specified contact and end date for evaluation period.
  // Params      : contact - the contact to evaluate
  //               endDate - the end date of the evaluation period (typically would be last day of month)
  //               genSpotBonus - generate spot bonus flag
  // Return      : PABonusCalcResult object storing bonus calc stats
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  public static PABonusCalcResult calcBonus(Contact contact, Date endDate, Boolean genSpotBonus)
  {
    PABonusCalcResult paBonusResult = new PABonusCalcResult();

    Integer nonCTATargetBonus = 0;
    Integer ctaTargetBonus = 0;
    Integer allowedGapWeeks = Integer.valueOf(PA_Onboarding_Property__c.getValues('Spot Bonus Allowed Gap')!=null?
                                             PA_Onboarding_Property__c.getValues('Spot Bonus Allowed Gap').Value__c:'0');

    //////////////////////
    // set PA id & name //
    //////////////////////
    //paBonusResult.paID = paRec.ID;
    paBonusResult.paContactId = contact.Id;
    paBonusResult.fullName = contact.Name;

    ////////////////////////////////////////////////
    // set start and end date for analysis period //
    ////////////////////////////////////////////////
    paBonusResult.endDate = endDate;
    paBonusResult.startDate = endDate.addMonths(-12).addDays(1);

    paBonusResult.debugMessages.add('Start Date:'+paBonusResult.startDate.format()+',endDate:'+paBonusResult.endDate.format());
    //////////////////////////////////////
    // determine if PA candidate is CTA //
    // Only include if they are Part-3  //
    // PASS                             //
    //////////////////////////////////////

    List<Certification_Data__c> certList = [SELECT Contact__c, Acquired_Date__c, Certification_Status__c
                                            FROM Certification_Data__c
                                            WHERE Contact__c = :paBonusResult.paContactId AND
                                                Certification_Type_Name__c = 'Certified Technical Architect' 
                                            and Certification_Status__c not in ('IN_PROGRESS_1','IN_PROGRESS_2','EXPIRED','NOT_CERTIFIED','NOT_CURRENT')]; //GR:added additional status values

    if (certList != null && certList.size() > 0)
      //if (paRec.Cert_Tech_Arch_Stg_3__c != null)
    {
      Certification_Data__c cert = certList[0];

      //if (cert.Certification_Status__c == 'CURRENT' || cert.Certification_Status__c == 'AT_RISK')
      //{
      paBonusResult.ctaAcquireDate = cert.Acquired_Date__c;

      if (paBonusResult.ctaAcquireDate != null && paBonusResult.ctaAcquireDate <= paBonusResult.endDate)
      {
        paBonusResult.ctaQualified = true;
      }

      paBonusResult.debugMessages.add('ctaQualified:endDate:'+endDate+', ctaAcquireDate='+paBonusResult.ctaAcquireDate+
                                        ', paBonusResult.ctaQualified='+paBonusResult.ctaQualified);

    }



    ////////////////////////////////////////////////////////////////////////////
    // determine if candidate was PA for analysis period and calc utilization //
    ////////////////////////////////////////////////////////////////////////////

    // should we filter on "Project Role" for value like "Program Architect"
    List<PA_Onboarding_Project__c> projList = [SELECT Id, Name, Customer_Name__c, Project_Name__c, PA_Onboarding__c, Project_Start_Date__c,
                                   Project_End_Date__c, Project_Role__c, Link_to_Org62_Assigmment__c, Type__c
                                   FROM PA_Onboarding_Project__c
                                   WHERE Consultant__c = :paBonusResult.paContactID AND
                                       Type__c = 'Billable' AND
                                           Project_Start_Date__c < :paBonusResult.endDate AND
                                           Project_End_Date__c >= :paBonusResult.startDate
                                           ORDER BY Project_End_Date__c desc];

    Integer daysUtil = 0;
    Boolean paProjectGapFlag = false;
    Date prevStartDt,prevEndDt;

    paBonusResult.debugMessages.add('Total projects found between start and end date:'+projList.size());
    Integer currIndex=1,projGapDays=0,nonPADays=0,overlappingProjects=0,paDays=0;
      
    for (PA_Onboarding_Project__c paProj : projList)
    {
      paBonusResult.projList.add(paProj);
        if(currIndex >1){
           //Compare the current project's end date and previous project's start date
            if(paProj.Project_End_Date__c < prevStartDt){
                //There is a gap in the assignment
                projGapDays += paProj.Project_End_Date__c.daysBetween(prevStartDt);
            }else{
                //The assignments overlap
                overlappingProjects++;
            }
            
        }
      if (paProj.Project_Start_Date__c <= paBonusResult.startDate &&
          ( paProj.Project_Role__c == 'Program Architect' || paProj.Project_Role__c =='Customer Success Executive' || paProj.Project_Role__c =='Business Transformation Architect' || paProj.Project_Role__c =='Business Architect') &&
          paProj.Type__c == 'Billable')
      {
          if(!paBonusResult.paQualified){
             //This is the most recent PA Project
             paBonusResult.paProjectNotes = 'Project Name:'+paProj.Customer_Name__c+'\n'+
                                            'Start Date:'+paProj.Project_Start_Date__c+'\n'+
                                            'End Date:'+paProj.Project_End_Date__c;
             
          }
          paBonusResult.paQualified = true;
      }

      if (paProj.Project_Role__c == 'Program Architect' || paProj.Project_Role__c =='Customer Success Executive' || paProj.Project_Role__c =='Business Transformation Architect' || paProj.Project_Role__c =='Business Architect')
      {
        Date tmpStartDate = paProj.Project_Start_Date__c < paBonusResult.startDate ? paBonusResult.startDate : paProj.Project_Start_Date__c;
        Date tmpEndDate = paProj.Project_End_Date__c > paBonusResult.endDate ? paBonusResult.endDate : paProj.Project_End_Date__c;
        daysUtil += tmpStartDate.daysBetween(tmpEndDate);
      }

      if (! paProj.Project_Role__c.startsWith('Program Architect')  &&
          paProj.Type__c == 'Billable' && ( paProj.Project_Role__c !='Customer Success Executive' && paProj.Project_Role__c !='Business Transformation Architect' && paProj.Project_Role__c != 'Business Architect'))
      {
         paProjectGapFlag = true;
         Date theStartDate,theEndDate;
         if(paProj.Project_Start_Date__c > paBonusResult.startDate){
            theStartDate = paProj.Project_Start_Date__c;
         }else{
            theStartDate = paBonusResult.startDate;
         }

         if(paProj.Project_End_Date__c > paBonusResult.endDate){
            theEndDate = paBonusResult.endDate;
         }else{
            theEndDate = paProj.Project_End_Date__c;
         }
         nonPADays += theStartDate.daysBetween(theEndDate);
      }else{
         Date theStartDate,theEndDate;
         if(paProj.Project_Start_Date__c > paBonusResult.startDate){
            theStartDate = paProj.Project_Start_Date__c;
         }else{
            theStartDate = paBonusResult.startDate;
         }

         if(paProj.Project_End_Date__c > paBonusResult.endDate){
            theEndDate = paBonusResult.endDate;
         }else{
            theEndDate = paProj.Project_End_Date__c;
         }
         paDays += theStartDate.daysBetween(theEndDate);
         //paBonusResult.debugMessages.add('Project Name:'+paProj.Name+',startDate:'+theStartDate+',endDate:'+theEndDate+',paDays : '+paDays);
      }
        prevEndDt = paProj.Project_End_Date__c;
        prevStartDt = paProj.Project_Start_Date__c;
        currIndex++;
    }
    paBonusResult.debugMessages.add('overlappingProjects = '+overlappingProjects);
    paBonusResult.debugMessages.add('projGapDays = '+projGapDays);
    paBonusResult.debugMessages.add('nonPADays = '+nonPADays);
    paBonusResult.debugMessages.add('paDays = '+paDays);
    if (paBonusResult.paQualified == false)
    {
      paBonusResult.addNote('Not a PA for full bonus review period');
    }
    
    if( (
            //If not a PA for aleast 48 weeks
            (paDays/7)<(52-allowedGapWeeks)
        )
    ){
        paBonusResult.debugMessages.add('Not a PA for > 48 weeks');
        
    }

    if( 
        (
            // if more than 4 weeks of Non PA or Non PA Assignment without overlaps
            (projGapDays + nonPADays)/7 > allowedGapWeeks && overlappingProjects == 0
        )
    
    ){
        paBonusResult.debugMessages.add('PA Gap >= '+allowedGapWeeks+ ' weeks with no overlap projects');
        
    }

    //If there were gaps in assignment and no overlapping projects then they don't qualify
    if( (
            //If not a PA for aleast 48 weeks
            (paDays/7)<(52-allowedGapWeeks)
        ) || 
        (
            // if more than 4 weeks of Non PA or Non PA Assignment without overlaps
            (projGapDays + nonPADays)/7 > allowedGapWeeks && overlappingProjects == 0
        )
    ){
        paBonusResult.debugMessages.add('Total weeks not as PA or with a gap = '+(projGapDays + nonPADays)/7);      
        paBonusResult.paQualified = false;
        paBonusResult.addNote('Gap in PA assignment for '+(projGapDays + nonPADays)/7 + 'weeks.');
    }
    ////////////////////////////////////////
    // determine CSAT count and avg score //
    ////////////////////////////////////////
    Decimal sumCSAT = 0;
    List<PA_Customer_Survey__c> surveyList = [SELECT Id, Name, Account_Name__c, Org62_Survey_Id__c, Converted_score__c, Overall_Score__c, Survey_Completed_Date__c
        FROM PA_Customer_Survey__c
        WHERE Contact__c = :paBonusResult.paContactId AND
                           (Survey_Completed_Date__c < :paBonusResult.endDate AND
                            Survey_Completed_Date__c >= :paBonusResult.startDate)];
    for (PA_Customer_Survey__c survey : surveyList)
    {
      paBonusResult.surveyList.add(survey);
      paBonusResult.cntCSAT++;
      sumCSAT += survey.Converted_score__c; //Overall_Score__c;
    }
    paBonusResult.debugMessages.add('Total CSATs : '+paBonusResult.cntCSAT);      

    if (paBonusResult.cntCSAT > 0) {
        paBonusResult.avgCSAT = sumCSAT / paBonusResult.cntCSAT;
    }
    paBonusResult.debugMessages.add('Average CSAT : '+paBonusResult.avgCSAT);      
    if (paBonusResult.avgCSAT < 4.5) {     //GR: changed CSAT from 10 point to 5 point scale
        paBonusResult.addNote('CSAT is below 4.5');
        paBonusResult.debugMessages.add('Average CSAT < 4.5');      
    }

    ///////////////////////////
    // get last bonus period //
    ///////////////////////////
    Integer bonusCount = [select count() from Spot_Bonus_Payment__c 
                          where Eligibility_Date__c >= :paBonusResult.startDate
                         and Spot_Bonus__r.Contact__c = :paBonusResult.paContactID
                         and Total_Bonus_Amount__c>0];
      

    paBonusResult.debugMessages.add('Spot Bonus Payment records greater than '+paBonusResult.startDate+' ='+bonusCount);
    if (bonusCount>0)
    {
      paBonusResult.bonusOverlap = true;
      paBonusResult.addNote('Bonus date range falls within previous Spot Bonus');
    }



    /////////////////////
    // determine bonus //
    /////////////////////
    PA_Onboarding_Property__c paTemplate = PA_Onboarding_Property__c.getValues('Bonus CTA Target');
    if (paTemplate != null) {
        ctaTargetBonus = Integer.valueOf(paTemplate.Value__c);
    }
    
    paTemplate = PA_Onboarding_Property__c.getValues('Bonus Non CTA Target');
    
    if (paTemplate != null){ 
        nonCTATargetBonus = Integer.valueOf(paTemplate.Value__c);
    }
    if (paBonusResult.paQualified )//&& (paBonusResult.cntCSAT > 0) && (paBonusResult.avgCSAT >= 9))
    {
      paBonusResult.bonusEligible = (paBonusResult.cntCSAT > 0) && (paBonusResult.avgCSAT >= 4.5) && (paBonusResult.bonusOverlap ? false : true);

      if(paBonusResult.bonusEligible){
          paBonusResult.bonusAmount = nonCTATargetBonus;
          paBonusResult.baseBonusAmount =paBonusResult.bonusAmount;
          if (paBonusResult.ctaQualified)
          {
              //Add the CTA increment to the base bonus
              paBonusResult.bonusAmount += ctaTargetBonus;
              paBonusResult.ctaIncrement = ctaTargetBonus;
          }
        
      }
      
      //paBonusResult.bonusAmount *= 0.5; // multiple by 50% to get 6 month bonus
    }

    /////////////////////////////////////////////
    // if flag set, then generate spot bonuses //
    /////////////////////////////////////////////
    if (genSpotBonus){
        createSpotBonusRecs(paBonusResult);
    }
    System.debug('>>>>>>>PABonusCalcUtils.calcBonus paBonusResult='+paBonusResult);
    return paBonusResult;
  }

  private static Date getPayoutDate(Date bonusCalcDate)
  {
    if (bonusCalcDate == null) {
        return null;
    }
    
    Integer mo = bonusCalcDate.month();
    Integer dd = bonusCalcDate.day();
    return Date.valueOf(bonusCalcDate.year() + '-'+mo+'-01');
    
    /*
    ////////
    // Q1 //
    ////////
    if (mo >= 2 && mo <= 4)
    {
      return Date.valueOf(bonusCalcDate.year() + '-02-01');
    }
    ////////
    // Q2 //
    ////////
    else if (mo >= 5 && mo <= 7)
    {
      return Date.valueOf(bonusCalcDate.year() + '-05-01');
    }
    ////////
    // Q3 //
    ////////
    else if (mo >= 8 && mo <= 10)
    {
        return Date.valueOf(bonusCalcDate.year() + '-08-01');
    }
    ////////
    // Q4 //
    ////////
    else if (mo == 11 || mo == 12)
    {
        return Date.valueOf(bonusCalcDate.year() + '-11-01');
    }
    ////////
    // Q4 //
    ////////
    else if (mo == 1)
    {
        return Date.valueOf(bonusCalcDate.year()-1 + '-11-01');
    }
    else
    {
      return Date.valueOf(bonusCalcDate.year() + '-02-01');
    }
    */

  }

  private static Integer calcFiscalYear(Date dt)
  {
    if (dt == null) return null;

    if (dt.month() == 1)
    {
      return (dt.year() - 1);
    }
    else
    {
      return (dt.year());
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Description : Create spot bonus record for the given spot bonus result object
  // Params      : paBonusResult - the spot bonus evaluation stats
  // Return      : the ID of the spot bonus record
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  public static ID createSpotBonusRecs(PABonusCalcResult paBonusResult)
  {

    if (paBonusResult != null)
    {
      Spot_Bonus__c sb = new Spot_Bonus__c();
      sb.Contact__c = paBonusResult.paContactID;
      

      Id bonusRecId;
      //Create bonus records if they are bonus eligible or if they have been a PA for a full 1 year
      //and have not been previously paid a bonus in the new bonus period.
      if((paBonusResult.bonusEligible || paBonusResult.paQualified) && !paBonusResult.bonusOverlap){
          sb.Status__c='Draft';
          sb.Period_Start_Date__c=paBonusResult.startDate;
          sb.Period_End_Date__c=paBonusResult.endDate;
          sb.Avg_CSAT__c=paBonusResult.avgCSAT;
          sb.Count_of_CSATs__c=paBonusResult.cntCSAT;
          sb.PA_Project_Notes__c=paBonusResult.paProjectNotes;
          if(paBonusResult.bonusEligible){
            sb.Category__c='System Recommended';
          }else{
            sb.Category__c='Non System Recommended';
          }
          String calcNotes = '';
          for(String msg: paBonusResult.debugMessages){
            calcNotes += msg+'\n';
          }
          sb.Calculation_Notes__c=calcNotes;

          sb.Bonus_Period__c =paBonusResult.paContactID+'_'+paBonusResult.startDate+'_'+paBonusResult.endDate;
          Schema.SObjectField extId = Spot_Bonus__c.Fields.Bonus_Period__c;
          Database.UpsertResult result = Database.upsert(sb,extId,true);
          if(result.isSuccess()){
            bonusRecId = result.getId();
          }       
          
          //Create the two payment records
          List<Spot_Bonus_Payment__c> toInsert = new List<Spot_Bonus_Payment__c>();
          
          Spot_Bonus_Payment__c payment = new Spot_Bonus_Payment__c(Spot_Bonus__c=bonusRecId,
                                                                    Eligibility_Date__c= getPayoutDate(paBonusResult.endDate),
                                                                    Base_Bonus_Amount__c = paBonusResult.baseBonusAmount * 0.50,
                                                                    CTA_Increment__c=paBonusResult.ctaIncrement *0.5,
                                                                    External_Id__c = bonusRecId+'-'+getPayoutDate(paBonusResult.endDate),
                                                                    Payment_Type__c='1 of 2'
                                                                );
                                                                
          toInsert.add(payment);
          
          //GR Jul 7: commenting out code below to fix a bug related to eligibility date. Eligibility date should be the period end date for 
          //both payment records.
          /*payment = new Spot_Bonus_Payment__c(Spot_Bonus__c=bonusRecId,
                                              Eligibility_Date__c= getPayoutDate(paBonusResult.endDate).addMonths(6),
                                              Base_Bonus_Amount__c = paBonusResult.baseBonusAmount * 0.50,
                                              CTA_Increment__c=paBonusResult.ctaIncrement *0.5,
                                              External_Id__c = bonusRecId+'-'+getPayoutDate(paBonusResult.endDate).addMonths(6),
                                              Payment_Type__c='2 of 2'
                                            ); */
                                            
          payment = new Spot_Bonus_Payment__c(Spot_Bonus__c=bonusRecId,
                                              Eligibility_Date__c= getPayoutDate(paBonusResult.endDate),
                                              Base_Bonus_Amount__c = paBonusResult.baseBonusAmount * 0.50,
                                              CTA_Increment__c=paBonusResult.ctaIncrement *0.5,
                                              External_Id__c = bonusRecId+'-'+getPayoutDate(paBonusResult.endDate).addMonths(6),
                                              Payment_Type__c='2 of 2'
                                            );                                  
                                            
          toInsert.add(payment);
          
          extId = Spot_Bonus_Payment__c.Fields.External_Id__c;
          List<Database.UpsertResult> paymentResults = Database.upsert(toInsert,extId,true);
          if(!paymentResults[0].isSuccess()){
            throw new SpotBonusException('Could not create Spot Bonus Payment records:'+paymentResults[0].getErrors());
          }
      }
      Contact ct = [select Id,Last_Spot_Bonus_Comments__c from Contact where Id=:paBonusResult.paContactID];
      if(ct.Last_Spot_Bonus_Comments__c!=null && ct.Last_Spot_Bonus_Comments__c!=''){
        ct.Last_Spot_Bonus_Comments__c +='\n';
      }else{
        ct.Last_Spot_Bonus_Comments__c ='';
      }
      ct.Last_Spot_Bonus_Comments__c +=paBonusResult.endDate.format() + ' : '+
                                       (paBonusResult.bonusEligible?'Bonus Eligible':paBonusResult.notes);    
      update ct;
      

      if(paBonusResult.bonusEligible){
          //////////////////////////////////////////////////
          // attach customer surveys to spot bonus record //
          //////////////////////////////////////////////////
          for (PA_Customer_Survey__c survey : paBonusResult.surveyList)
          {
            survey.Spot_Bonus__c = sb.id;
          }
    
          update paBonusResult.surveyList;
        
      }
      
      return bonusRecId;
    }

    return null;
  }

    public class SpotBonusException extends Exception{
        
    
    }
}