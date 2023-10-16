/**
Class Name      : CSG_SkillsTaxonomySyncSchedulerCls
@description    : This is the scheduler class to schedule the taxonomay batch class.
*/
public class CSG_SkillsTaxonomySyncSchedulerCls implements Schedulable {
  /**
      @description : This is the scheduler execute method
      @param   sc - schedulableContext
     */
  public void execute(SchedulableContext sc) {
    CSG_SkillsTaxonomySyncBatch btch = new CSG_SkillsTaxonomySyncBatch();
    database.executebatch(btch);
  }
}