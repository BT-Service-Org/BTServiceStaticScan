({
    getTokenAction: function(component, event, helper) {
        const getTokenAction = component.get('c.getToken');
        
        var getTokenPromise = new Promise(function (resolve, reject) {
            getTokenAction.setCallback(this, function (response) {
                
                if (response.getState() === 'SUCCESS') {
                    var responseData = response.getReturnValue();
                    resolve(JSON.parse(responseData));
                } else if (response.getState() === 'ERROR') {
                    reject(Error('Error generating token'));
                }
            });
        });
        $A.enqueueAction(getTokenAction);
        return getTokenPromise;
    }
});