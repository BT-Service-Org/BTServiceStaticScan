public with sharing class OrgRefresh_BatchResult {
    public Id recordId {get;set;}
    public Boolean created {get ;set;}
    public Boolean success {get; set;}
    public String errors {get; set;}
    
    public OrgRefresh_BatchResult(Id recordId, Boolean created, Boolean success, String errors) {
        this.recordId = recordId;
        this.created = created;
        this.success = success;
        this.errors = errors;
    }
}