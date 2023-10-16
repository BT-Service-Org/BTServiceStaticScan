public with sharing abstract class ParentAPIRequest {
    /*To convert the object to json format*/
    public String convertToJSON(){
        return JSON.serialize(this);
    }
    //Add all the mandatory request parameters in the list to validate the request
    public virtual Boolean validate(){
        return true;
    }
}