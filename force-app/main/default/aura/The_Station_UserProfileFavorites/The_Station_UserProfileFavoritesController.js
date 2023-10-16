({
    doInit : function(cmp, event, helper) {
        var favorites;
        var userActionA = cmp.get("c.getUserFavorites");
        userActionA.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                favorites = response.getReturnValue();
                cmp.set('v.favoriteContentRecords',favorites);
                if(favorites != null) {                     
                    cmp.set('v.displayEmptyMessage',false);
                }                
            }
        });
        $A.enqueueAction(userActionA);

        // POST FREEZE REMOVE APEX METHOD getRunningUserInfo AND JUST USE THIS LINE BUT UPDATE StationContentPiece TO TAKE JUST USERID.
        var userId = $A.get("$SObjectType.CurrentUser.Id");

        var userActionB = cmp.get("c.getRunningUserInfo");
        userActionB.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var user = response.getReturnValue();
                cmp.set('v.runningUser',user);
            }
        });
        $A.enqueueAction(userActionB);                
    }
})