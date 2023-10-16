({
    doInit: function(component, event, helper) {
        var action = component.get("c.getHeaderNavigationId");
        action.setParams({
            menuName : ''
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.menuId", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        var action1 = component.get("c.getUserAchievementData");
        action1.setParams({});
        action1.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                let ucData = response.getReturnValue().length>0?response.getReturnValue():null;
                let isLong;
                let arcX;
                let arcY;
                let d;
                if(ucData !=null){
                    component.set("v.levelPercent",ucData[0].Current_Level_Completion_Percent__c);
                    isLong = ucData[0].Current_Level_Completion_Percent__c > 50 ? 1 : 0;
                    arcX = parseFloat(Math.cos(2 * 3.14159 * (ucData[0].Current_Level_Completion_Percent__c/100))); 
                    arcY = parseFloat(Math.sin(2 * 3.14159 * (ucData[0].Current_Level_Completion_Percent__c/100)));
                    d =  "M 1 0 A 1 1 0" + " " +isLong +" "+ "1" + " " +arcX +" " + arcY+ " L 0 0";
                    component.set("v.diameter", d);
                    component.set("v.userBadgesData", response.getReturnValue());
                }
            }
        });
        $A.enqueueAction(action1);
    }
})