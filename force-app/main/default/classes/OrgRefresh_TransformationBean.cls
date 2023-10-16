public with sharing class OrgRefresh_TransformationBean {
     //Specify the definition of a source 
     public OrgRefresh_FieldValueDefn srcDefn {get;set;}
     //specify one or more definition values in the target for a given source definition.
     public OrgRefresh_FieldValueDefn[] targetDefn {get;set;}
}