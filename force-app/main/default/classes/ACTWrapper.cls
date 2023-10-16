global class ACTWrapper implements Comparable {
   
    @AuraEnabled public String name;
    @AuraEnabled public String description;
    @AuraEnabled public Integer progress;
    @AuraEnabled public Boolean isCompleted = false;
    @AuraEnabled public Integer daysLeft;
    public String learningPathId;
    
    public ACTWrapper(String name, String description, Decimal progress, Boolean isCompleted, Date dueDate) {
        this.name = name;
        this.description =  description;
        this.progress = (Integer)(progress * 100);
        this.isCompleted = isCompleted;
        this.daysLeft = Date.today().daysBetween(dueDate);
    }

    global Integer compareTo(Object compareTo) {
		ACTWrapper compareToWrapper = (ACTWrapper)compareTo;
        
        Integer retVal = 0;
        if (daysLeft > compareToWrapper.daysLeft) {
            retVal = 1;
        } else if (daysLeft < compareToWrapper.daysLeft) {
            retVal = -1;
        }
        return retVal;
    }
}