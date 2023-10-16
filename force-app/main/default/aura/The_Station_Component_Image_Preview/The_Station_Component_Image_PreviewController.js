({
	getPreviewFromServer : function(cmp) {
		/*var action = cmp.get("c.getPreview");
        
        action.setParams({
            pContentDocumentId : cmp.get("v.ContentDocumentId")
        });
        
        console.log( cmp.get("v.ContentDocumentId") );
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var svgPreview = response.getReturnValue();
                svgPreview = svgPreview.replace("<svg", "<svg style='width:auto;height:100%;border: 0px Solid Black;background-color:white'");
                
                cmp.set("v.Preview", svgPreview);
                

            }
        });
        */
        var extId = cmp.get("v.ContentDocumentExternalId");
        var cvId = cmp.get("v.ContentVersionId");
        var icon = cmp.get("v.IconPreviewUrl");
        //if (icon != undefined ) {
        //    console.log('setting icon preview: ' + icon);
        //    cmp.set("v.ImgSrc", icon);
        //} else
        if (extId != undefined) {
        	extId = extId.replace(':','%3A');
        	cmp.set("v.ImgSrc", "https://org62.my.salesforce.com/contenthub/renditiondownload?rendition_page_number=0&rendition_id="+extId+"%40THUMBNAIL_BIG&xds_id=0XC30000000KzGh");
        } else if (cvId != undefined) {
            cmp.set("v.ImgSrc", "https://org62.my.salesforce.com/sfc/servlet.shepherd/version/renditionDownload?rendition=SVGZ&versionId="+cvId);
        } else if (icon != undefined) {
            cmp.set("v.ImgSrc", icon);
        } else {
            cmp.set("v.ImgSrc", '/sfsites/c/resource/The_Station_Icons/Icons/UNKNOWN@2x.png');
        }
        
     	//$A.enqueueAction(action);
	}
})