/**
* @description :	> This is a Virtual class. It has methods to handle almost all the trigger events 
*					> Blank implementation for these methods.
* 					> There should be a concrete class overriding this virtual class and provide Implementation.
*					> The Concrete class can override only the methods required and ignore rest!
*/
public virtual class tf_TriggerHandler {
/**
  @return type : Boolean - Run this specific Handler or No?
* @description : Respective Handlers can provide implementation for this method and return False/True!
*				> Typically to Control Recursion at the Specific Handler level!
*/     
    public virtual Boolean runTriggerHandler(){
        return true; //By default it returns TRUE
    }
    /**
    @description : method
    */
    public virtual void handleBeforeInsert() {}
    /**
    @description : method
    */
    public virtual void handleBeforeUpdate() {}
    /**
    @description : method
    */
    public virtual void handleBeforeDelete() {}
    /**
    @description : method
    */
    public virtual void handleAfterInsert() {}
    /**
    @description : method
    */
    public virtual void handleAfterUpdate() {}
    /**
    @description : method
    */
    public virtual void handleAfterDelete() {}
    /**
    @description : method
    */
    public virtual void handleAfterUnDelete() {}
}