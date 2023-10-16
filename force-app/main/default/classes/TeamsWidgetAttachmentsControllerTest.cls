@IsTest private class TeamsWidgetAttachmentsControllerTest {
    
    public static testMethod void TeamsWidgetAttachments() {
        TeamsWidgetAttachmentsController TWA = new TeamsWidgetAttachmentsController();
        TWA.setTeamId('a0B30000001vU4VEAU');
        String teamId = TWA.getTeamId();
        if(teamId == null){
            System.assert(false, 'getTeamId error');
        }
        TWA.refresh();
        TWA.currentTeam();
        TWA.PictureID = '00P300000034I31EAE';
        String PictureIDGET = TWA.PictureID;
        if(PictureIDGET == null){
            System.assert(false, 'getPictureID error');
        }
        TWA.teamInfo = [Select t.Picture__c From Team__c t Where t.Id ='a0B30000001vU4VEAU'];
        Team__c teamInfo = TWA.teamInfo;
        if(teamInfo == null){
            System.assert(false, 'teamInfo error');
        }
        TeamsWidgetAttachmentsController.AttachmentInfo AI = new TeamsWidgetAttachmentsController.AttachmentInfo();
        
        // List<TeamsWidgetAttachmentsController.AttachmentInfo> miList =  TWA.getAttachments();
        
        
        String name = AI.getName();
        String attI = AI.getAttachImage();
        Attachment at = AI.getAttachment();
        String Id = AI.getId();
         
        TWA.getAttachCount();
        TWA.DeleteAttach();
        
        
    }
}