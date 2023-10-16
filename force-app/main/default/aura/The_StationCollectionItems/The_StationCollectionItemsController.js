({
    doInit : function(cmp, event, helper) {

// added by Ryan
        var opts = [
            { value: "Alphabetical", label: "Alphabetical", selected: true },
            { value: "Last Updated", label: "Last Updated" },
            { value: "Created Date", label: "Created Date" }];
            
        cmp.set('v.options', opts);
        cmp.set('v.selectedValue', 'Alphabetical');

//        cmp.set('v.showFollowCollection', false);

// end

        var userAction = cmp.get("c.getRunningUserInfo");
        userAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var user = response.getReturnValue();
                cmp.set('v.runningUser',user);
            }
        });
        $A.enqueueAction(userAction);

        var urlAction = cmp.get("c.getLexOriginUrl");
        urlAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var origin = response.getReturnValue();
                cmp.set("v.originUrl", origin);
            }
        });
        $A.enqueueAction(urlAction);



        var collectionId = cmp.get("v.recordId");
        var selectedSort = cmp.get("v.selectedValue");
        
        var totalAction = cmp.get("c.getTotalItems");
        totalAction.setParams({
            recordId : collectionId
        });
        totalAction.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var ttl = response.getReturnValue();
                cmp.set('v.totalRecords',ttl);
                var pages = Math.ceil(parseInt(ttl) / parseInt(12));
                var pagesArray = [];
                for(var i=1; i<=pages; i++){
                    var obj = {};
                    obj['label'] = i.toString();
                    obj['value'] = i.toString();
                    pagesArray.push(obj);
                }
                cmp.set('v.pagesArray',pagesArray);
               

                var recordAction = cmp.get("c.getCollectionContentRecords");
                recordAction.setParams({
                    recordId : collectionId,
                    sortType : selectedSort,
                    ofst : 0
                });
                recordAction.setCallback(this, function(response) {
                   
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var groupList = response.getReturnValue();
                        cmp.set('v.groupList',groupList);

                        var contentAction = cmp.get("c.getContentPieces");
                                contentAction.setParams({
                                    contentJSON : JSON.stringify(groupList)
                                });
                                contentAction.setStorable();
                                contentAction.setCallback(this, function(contentResponse) {
                                    if (state === "SUCCESS") {
                                        var contentRecords = contentResponse.getReturnValue();
                                        cmp.set("v.groupList", contentRecords);
                                        if (contentRecords.length==0){
                                            cmp.set("v.contentNull",true);
                                        }
                                    }
                                });
                                $A.enqueueAction(contentAction);

                    }
                });
                $A.enqueueAction(recordAction);

                    }
                });
        $A.enqueueAction(totalAction);


        
    },
    OnchangeView : function (cmp, event) {
        var tileView = cmp.get('v.typeTile');
        tileView = !tileView;
        cmp.set("v.typeTile", tileView);
    },
    handleAddContent : function(cmp, event) {
        var modalBody;
        var groupRecordId = cmp.get("v.recordId");
        $A.createComponent("c:The_Station_CollectionAddContentToExistingFlow", 
        { collectionRecordId: groupRecordId }, 
        function(content, status) {
            if (status === "SUCCESS") {
                modalBody = content;
                cmp.find('overlayLib').showCustomModal({
                    header: "The Station - Add Content To Collection",
                    body: modalBody, 
                    showCloseButton: true,
                    cssClass: "modalBackgroundColor",
                    closeCallback: function() {
                        // $A.get('e.force:refreshView').fire();                               
                    }
                })
            }                               
        });
    },
    handleModeEvent : function(cmp, event) {
        var mode = event.getParam("mode");
        var currentMode = cmp.get("v.editMode");
        
        if (mode=="Edit" && !currentMode){
            cmp.set("v.editMode",!currentMode);
        }
        else if (mode=="Save" && currentMode){
            cmp.set("v.editMode",!currentMode);
            // $A.get('e.force:refreshView').fire(); //try rendering instead
            // var selectedSort = cmp.get("v.selectedSort");
            // var collectionId = cmp.get("v.recordId");
            // var recordAction = cmp.get("c.getCollectionContentRecords");
            // recordAction.setParams({
            //     recordId : collectionId,
            //     sortType : selectedSort
            // });
            // recordAction.setCallback(this, function(response) {
            //     var state = response.getState();
            //     if (state === "SUCCESS") {
            //         var groupList = response.getReturnValue();
            //         cmp.set('v.groupList',groupList);
            //     }
            // });
            // $A.enqueueAction(recordAction);
            window.location.reload();

        }
    },
    handleChange: function(cmp, event, helper) {
        var selectedSort = cmp.get("v.selectedValue");
        var collectionId = cmp.get("v.recordId");
        var val = cmp.get("v.curpage");
		var offset = parseInt((val-1) * 12);	
            var recordAction = cmp.get("c.getCollectionContentRecords");
            recordAction.setParams({
                recordId : collectionId,
                sortType : selectedSort,
                ofst : offset
            });
            recordAction.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var groupList = response.getReturnValue();
                    cmp.set('v.groupList',groupList);
                }
            });
            $A.enqueueAction(recordAction);
    
    },
    doPaging: function(cmp, event, helper) {
        var selectedSort = cmp.get("v.selectedValue");
        var collectionId = cmp.get("v.recordId");
        var val = event.getSource().get("v.value");
        var offset = parseInt((val-1) * 12);
        cmp.set('v.curpage',val);
		cmp.set('v.offset',offset);	
            var recordAction = cmp.get("c.getCollectionContentRecords");
            recordAction.setParams({
                recordId : collectionId,
                sortType : selectedSort,
                ofst : offset
            });
            recordAction.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var groupList = response.getReturnValue();
                    cmp.set('v.groupList',groupList);
                }
            });
            $A.enqueueAction(recordAction);
    },
    handleDeleteEvent: function(cmp, event, helper){
        var contentId = event.getParam("deletecontentId");
        var delList = cmp.get("v.groupList");
        var result = delList.find(function(item) { return item.content.Id === contentId });
        var delindex = delList.indexOf(result);
        if (delindex > -1) {
            delList.splice(delindex, 1);
            cmp.set("v.groupList",delList);
        }
    },
    handleKeyUp: function (cmp, evt) {
        var collection = null;
        var action = null;
        var isEnterKey = evt.keyCode === 13;
//        var queryTerm = cmp.find('enter-search').get('v.value');
        if (isEnterKey) {
            cmp.set('v.issearching', true);
            var a = cmp.get('c.doSort');
            $A.enqueueAction(a);
            cmp.set('v.issearching', false);
        }
    },    
    onchangeSearch: function (cmp, evt) {
        
        var queryTerm = cmp.find('enter-search').get('v.value');
       
        if (queryTerm == '') {
            cmp.set('v.issearching', true);
            var a = cmp.get('c.doSort');
            $A.enqueueAction(a);
            cmp.set('v.issearching', false);
        }
    },
    doSort : function(cmp, event, helper) {
        
        var collectionId = cmp.get("v.recordId");
        var sort = cmp.find("collectionSort").get("v.value");
        var sortT = cmp.get('v.selectedValue');
        var collection = null;
        var action = null;
        var offset = cmp.get("v.offset");
        var queryTerm = cmp.find('enter-search').get('v.value');
                   
        action = cmp.get("c.getCollectionContentRecordsWithSearch");                
        action.setParams({            
            searchTerms : queryTerm,
            recordId : collectionId,
            sortType : sortT,
            ofst : offset
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
           
            if (state === "SUCCESS") {
                collection = response.getReturnValue();
                cmp.set("v.groupList", collection);                       
                // cmp.set("v.totalResults", collection ? collection.length : 0); 
                cmp.set("v.showCollectionFilterTitle", false);                                             
                if(queryTerm) {
                    cmp.set("v.searchTermValue", "'" + queryTerm + "'");
                    cmp.set("v.totalResults", collection ? collection.length : 0);                    
                } else {
                    cmp.set("v.searchTermValue", "All Records");
                    var totalRecords = cmp.get("v.totalRecords");
                    cmp.set("v.totalResults",totalRecords);              
                }                    
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);     
    },    
})