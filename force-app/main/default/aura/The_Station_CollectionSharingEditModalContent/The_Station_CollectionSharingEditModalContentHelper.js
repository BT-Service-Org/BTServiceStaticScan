({
    getRowActions: function (cmp, row, doneCallback) {
        var actions = [];
        var readAction = {
            'label': 'Read',
            'iconName': 'utility:preview',
            'name': 'read'
        };
        var editAction = {
            'label': 'Edit',
            'iconName': 'utility:edit',
            'name': 'edit'
        };
        var deleteAction = {
            'label': 'Revoke',
            'iconName': 'utility:delete',
            'name': 'revoke'
        };

        if (row.AccessLevel == 'Read') {
            readAction.disabled = 'true';
            actions.push(readAction);
            actions.push(editAction);
            actions.push(deleteAction);    
        } else if (row.AccessLevel == 'Edit') {            
            editAction.disabled = 'true';
            actions.push(readAction);
            actions.push(editAction);
            actions.push(deleteAction);                
        }
        // YOU HAVE TO HAVE A TIMEOUT ELSE IT DOES NOT RETURN ??
        setTimeout($A.getCallback(function () {
            doneCallback(actions);
        }), 200);
    }
})