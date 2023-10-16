//######################################################
// This class enables to load data extracted via SOQL
// into custom datasets in Analytics.
// It relies on the WAV_DataLoad_CFG__mdt custom metadata
// for configuration and requires Analytics JSON dataset
// metadata files to be loaded as static resources.
// This is the Queuable migration of the initial design
// to enhance bulkification of the process.
// Author : P-E GROS - Nov 2018
// Update : P-E GROS - June 2019 (Support of relationships in SOQL)
// #####################################################

public class WAV_DataLoad_QUE implements Queueable {
    
    private String                   processName;
    private String                   query;
    private String                   orderByField;
    private String                   lastFieldValue;
    private Integer                  offset;
    private Integer                  iteration;    
    private InsightsExternalData     loader;
    private Map<String,list<String>> fieldMap;
    private Boolean                  hasRelationFields;
    private String                   header;
    private Datetime                 startTS;
    
    
    //######################################################
    // Constructor for process launch
    //###################################################### 
    
    public WAV_DataLoad_QUE(WAV_DataLoad_CFG__mdt dataSet) {
               
        this.startTS = System.now();
        this.processName = dataSet.DeveloperName;
        this.iteration = 0;
        system.debug('initializing DataLoad process ' + this.processName
                    + ' for iteration ' + this.iteration);
        
        this.query = dataSet.Query__c;
        system.debug('initializing query --> ' + this.query);
        
        this.orderByField = dataSet.OrderBy__c;
        system.debug('initializing orderByField --> ' + this.orderByField);
        
        // ignoring lastFieldValue on first iteration.
        this.lastFieldValue = '';
            
        this.offset = (Integer)(dataSet.MaxRowsPerFile__c);
        system.debug('initializing query --> ' + this.offset);
            
        initLoader(dataSet);
        system.debug('initializing loader --> ' + this.loader);
       
        initFieldMap(dataSet);
        system.debug('initializing fieldMap --> '          + this.fieldMap);
        system.debug('initializing hasRelationFields --> ' + this.hasRelationFields);
        system.debug('initializing header --> '            + this.header);
    }
    
    //######################################################
    // Constructor for process continuation.
    //######################################################
                           
    public WAV_DataLoad_QUE(String               processName,
                            String               query,
                            String               orderByField,
                            String	             lastFieldValue,
                            Integer              offset,
                            Integer              iteration,
                            InsightsExternalData loader,
                            Map<String,list<String>> fieldMap,
                            Boolean              hasRelationFields,
                            String               header,
                            Datetime             startTS) {
                                
        System.debug('continuing DataLoad process ' + processName
                    + ' for iteration ' + iteration
                    + ' after value '   + lastFieldValue);
        this.processName       = processName;
        this.query             = query;
        this.orderByField      = orderByField;
        this.lastFieldValue    = lastFieldValue;
        this.offset            = offset;
        this.iteration         = iteration;
        this.loader            = loader;
        this.fieldMap          = fieldMap;  
        this.hasRelationFields = hasRelationFields;  
        // ignoring header on subsequent data parts.                  
        this.header            = '';
        this.startTS           = startTS;                   
    }
    
    //######################################################
    // Main process execution : iterates on all datasets
    // declared in the configuration.
    //###################################################### 
    
    public void execute(QueueableContext context) {
        System.debug('execute DataLoad process ' + processName
                   + ' for iteration ' + iteration);
        
        Integer partNbr = processDS();
        if (partNbr < offset) {
            system.debug('execute DataLoad process ' + processName
                       + ' completed at iteration '  + iteration);
            loader.Action = 'Process';
            update loader;
            system.debug('execute loader action triggered ' + loader);
            if (!Test.isRunningTest()) {
              ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(
                'internal', 'me',
                ConnectApi.FeedElementType.FeedItem,
                '### WAV Dataload processed for ' + processName + ' data ###\n\n'
                + 'started at ' + startTS + ' and ended at ' + System.now() + '\n'
                + 'completed after ' + (iteration + 1) + ' iterations (' + (iteration * offset + partNbr) + ' records fetched).');
            }
        } else {
            system.debug('execute DataLoad process '  + processName
                       + ' requeued after iteration ' + iteration);
            WAV_DataLoad_QUE continueJob = new WAV_DataLoad_QUE(
                             processName, query, orderByField, lastFieldValue,
                             offset, (iteration + 1), loader, fieldMap, hasRelationFields, header,startTS);
            ID jobID = System.enqueueJob(continueJob); 
            system.debug('execute continuation job launched: ' + jobID);
        }
    }
    
    //######################################################
    // Unitary process execution : sequences all the operation
    // to fetch and upload data to Analytics for a given dataset
    // at a given offset. Returns the actual number of rows
    // processed.
    //###################################################### 
    //
    public Integer processDS() {
       system.debug('processDS START'); 
       String offsetQuery = getOffsetQuery();
       system.debug('processDS processing SOQL ' + offsetQuery);
           
       String loaderFileStr = header;
       system.debug('processDS data file header initialized ' + loaderFileStr);
       
       Integer rowNbr = 0;
       for (SObject iterObj : database.query(offsetQuery)) {
           system.debug('processDS processing object ' + iterObj);
           loaderFileStr += formatDataLine(fieldMap,hasRelationFields,iterObj);
           rowNbr += 1;
           lastFieldValue = String.valueOf(iterObj.get(orderByField));
       }
       system.debug('processDS data file content prepared with '
                    + rowNbr + ' rows.');
       addDataPart(loaderFileStr);
                       
       system.debug('processDS END: data file stored ');
       return rowNbr;
    }
    
    //######################################################
    // Private helper classes for Initialization
    //######################################################
    
    private void initLoader(WAV_DataLoad_CFG__mdt dataSet) {
        
       system.debug('initLoader START');
       StaticResource MetadataJson = [SELECT Id, Body FROM StaticResource
                                       WHERE Name = :dataSet.MetaJson__c LIMIT 1];
       system.debug('initLoader MetadataJson fetched ' + MetadataJson);     
   
       String metadataBodyStr = MetadataJson.Body.toString();
	   Integer dsNameStart = metadataBodyStr.indexOf('fullyQualifiedName');
	   //System.debug('initLoader: DS Name declare start is ' + dsNameStart);
	   Integer dsNameEnd = metadataBodyStr.indexOf(',',dsNameStart);
	   //System.debug('initLoader: DS Name declare end is ' + nameEnd);
	   String dsName = MetadataBodyStr.substring(dsNameStart + 19,dsNameEnd);
	   //System.debug('initLoader: DS Name declaration extracted is ' + nameStr);
	   dsName = dsName.replaceAll('[" :]','');
	   System.debug('initLoader: DS Name extracted is ' + dsName);
        
       this.loader = new InsightsExternalData();
       this.loader.Format        = 'Csv';
       //this.loader.EdgemartAlias = dataSet.DeveloperName;
       //this.loader.EdgemartAlias = dataSet.MetaJson__c;
       this.loader.EdgemartAlias = dsName;
       this.loader.MetadataJson  = MetadataJson.Body;
       //this.loader.Operation     = 'Overwrite';
       this.loader.Operation     = dataSet.Operation__c;
       this.loader.Action        = 'None';
       system.debug('initLoader: loader initialized ' + loader);
       insert this.loader;
       //system.debug('initLoader END: loader inserted --> ' + this.loader); 
       system.debug('initLoader END: loader inserted'); 
       /*this.loader = new InsightsExternalData();
       this.loader.Format        = 'Csv';
       this.loader.EdgemartAlias = dataSet.DeveloperName;
       this.loader.MetadataJson  = MetadataJson.Body;
       this.loader.Operation     = 'Overwrite';
       this.loader.Action        = 'None';
       //system.debug('initLoader loader initialized ' + loader);
       insert this.loader;
       //system.debug('initLoader END: loader inserted --> ' + this.loader); 
       */
        
       return;
    }
    
    private void initFieldMap(WAV_DataLoad_CFG__mdt dataSet) {
        system.debug('initFieldMap START');
        
        this.hasRelationFields = false;
        this.fieldMap = new Map<String,list<String>>();
        JSONParser parser = JSON.createParser(dataSet.FieldMapping__c);

        this.header = '';
        String dsFieldName, objFieldName;
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                dsFieldName = parser.getText();
                //system.debug('initFieldMap dsFieldName found --> ' + dsFieldName);
                parser.nextToken();
                objFieldName = parser.getText();
                //system.debug('initFieldMap objFieldName found --> ' + objFieldName);
                
                //fieldMap.put(dsFieldName,objFieldName);
                list<string> fieldNameItems = objFieldName.split('\\.');
                this.fieldMap.put(dsFieldName,fieldNameItems);
                //system.debug('initFieldMap field inserted --> ' + fieldNameItems);
                if (objFieldName.contains('.')) {
                    system.debug('initFieldMap relationship found');
                    this.hasRelationFields = true;
                }
                this.header += '"' + dsFieldName + '",';
                //system.debug('initFieldMap adding ' + dsFieldName + ' / ' + objFieldName);
            } 
        }
        //system.debug('initFieldMap field map initialized  ' + this.fieldMap);
        //system.debug('initFieldMap hasRelationFields init ' + this.hasRelationFields);
        
        this.header = header.removeEnd(',');
        this.header += '\n';
        //system.debug('initFieldMap END : data file header initialized ' + header);
        
        return;
    }
    
    //######################################################
    // Private helper classes for Execution
    //######################################################
    
    // private --> public for test purposes.
    public String formatDataLine(map<String,list<String>> fieldMap,
                                 Boolean hasRelationFields,
                                 SObject objRecord) {
       //system.debug('formatDataLine processing object ' + objRecord);
       String dataLine = '';
       Object fieldValue = null;
            
       if (hasRelationFields){
           
           for (String fieldKey : fieldMap.keySet() ) {
               //system.debug('formatDataLine processing fieldKey '  + fieldKey);
               //system.debug('formatDataLine processing fieldName ' + fieldMap.get(fieldKey));
               Iterator<String> iterator = (fieldMap.get(fieldKey)).iterator();
               SObject objectIter = objRecord;
               
               while (iterator.hasNext()) {
                   String fieldName = iterator.next();
                   //system.debug('formatDataLine processing token ' + fieldName);

                   if (objectIter != null) {
                       if (!iterator.hasNext()) {
                           fieldValue = objectIter.get(fieldName);
                       } else {
                           objectIter = objectIter.getSobject(fieldName);
                       }
                   } else {
                       fieldValue = '';
                   }
               }   
               //system.debug('formatDataLine field value fetched  ' + fieldValue);    

               if (fieldValue != null) {
                   //dataLine += '"' + String.valueOf(objRecord.get(fieldMap.get(fieldKey))).remove('"') + '",';
                   dataLine += '"' + String.valueOf(fieldValue).remove('"') + '",';
               } else {
                   dataLine += '"",';
               }
           }
       } else {
           for (String fieldKey : fieldMap.keySet() ) {
               //system.debug('formatDataLine processing fieldKey '  + fieldKey);
               //system.debug('formatDataLine processing fieldName ' + fieldMap.get(fieldKey));
               fieldValue = objRecord.get((fieldMap.get(fieldKey))[0]);
          
               if (fieldValue != null) {
                   //dataLine += '"' + String.valueOf(objRecord.get(fieldMap.get(fieldKey))).remove('"') + '",';
                   dataLine += '"' + String.valueOf(fieldValue).remove('"') + '",';
               } else {
                   dataLine += '"",';
               }
           }
       }
       dataLine = dataLine.removeEnd(',');
       dataLine += '\n';   
       system.debug('formatDataLine dataLine formatted '  + dataLine);
        
       return dataLine;
    }
                                              
    private void addDataPart(String partContentStr) {
        
        Blob partContent = Blob.valueOf(partContentStr);
        system.debug('addDataPart partContent size ' + partContent.size());
              
        InsightsExternalDataPart dataPart = new InsightsExternalDataPart();
        dataPart.PartNumber = iteration + 1;
        dataPart.InsightsExternalDataId = loader.Id;
        dataPart.DataFile = partContent;
        //system.debug('addDataPart dataPart initialized ' + dataPart);

        insert dataPart;
        //system.debug('addDataPart dataPart inserted ' + dataPart);
        
        return;
    }
    
    // private --> public for test purposes.
    @TestVisible
    private String getOffsetQuery() {       
       String resultQuery = this.query;
       if (iteration != 0) {
           // keeping standard query for first iteration
           if (resultQuery.contains('WHERE')
               || resultQuery.contains('where')
               || resultQuery.contains('Where')) {
               // adding offset condition in existing where clause
               resultQuery = resultQuery + ' AND ';
           } else {
               // adding new where clause with offset condition
               resultQuery = resultQuery + ' WHERE ';
           }
           resultQuery = resultQuery + this.orderByField + ' > \'' + this.lastFieldValue + '\'';
       }
       resultQuery =   resultQuery + ' ORDER BY ' + this.orderByField + ' LIMIT ' + this.offset;
       
       return resultQuery;
    }
}