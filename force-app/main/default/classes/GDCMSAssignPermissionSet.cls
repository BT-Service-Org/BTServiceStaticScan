public without sharing class GDCMSAssignPermissionSet {
	
    private set<id> userIdSet;
    public GDCMSAssignPermissionSet(Set<id> userIdSet){
        this.userIdSet = userIdSet;
    }
    
    public boolean assignpermissionSet(){
        Set<id> alreadyassigned = new Set<id>();
        Set<id> newAssignments = new Set<id>();
        List<PermissionSetAssignment> newPSAList= new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> psaList = [Select PermissionSetId, AssigneeId, IsActive FROM PermissionSetAssignment where assigneeId in :userIdSet and PermissionSet.Name = 'GDCMS_Basic_Permission'];
        for(PermissionSetAssignment psa : psaList){
            alreadyassigned.add(psa.AssigneeId);
        }
        for(id userId : userIdSet){
            if(!alreadyassigned.contains(userId)) newAssignments.add(userId);
        }

        if(!newAssignments.isEmpty()){
            PermissionSet ps = [SELECT Id, Name FROM PermissionSet where name = 'GDCMS_Basic_Permission' limit 1];
            for(Id userId : newAssignments){
                newPSAList.add( buildPermissionSetAssignment(userId,ps.id));
            }
        }
		if(!newPSAList.isEmpty())
			Database.insert(newPSAList);        
        return true;
    }
    
    private PermissionSetAssignment buildPermissionSetAssignment(id userId, id permissionSetId){
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.PermissionSetId = permissionSetId;
        psa.AssigneeId = userId;
        return psa;
    }
}