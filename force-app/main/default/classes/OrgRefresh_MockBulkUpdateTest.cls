@isTest
global class OrgRefresh_MockBulkUpdateTest implements HttpCalloutMock {


    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        //validate the request params through asserts
        System.debug('=====req.getBody()===' + req.getBody());
        System.debug('=====req.getEndpoint()===' + req.getEndpoint());

        // Create a fake auth response
        HttpResponse res = new HttpResponse();
        
        //set the response based on the end point
        if(req.getEndpoint().endsWith('/result')){ // then this is our status call
            res.setHeader('Content-Type', ' application/xml; charset=UTF-8');
            res.setBody('<?xml version="1.0" encoding="UTF-8"?><results xmlns="http://www.force.com/2009/06/asyncapi/dataload"><result><errors><fields>Next_Available_Date__c</fields><message>Contact: bad field names on insert/update call: Next_Available_Date__c</message><statusCode>INVALID_FIELD_FOR_INSERT_UPDATE</statusCode></errors><success>false</success><created>false</created></result></results>');
            res.setStatusCode(200);
            res.setStatus('OK');
            System.assert(req.getEndpoint().contains('75130000001nvUUAAY')); // assert we got the right batch number
            System.assert(req.getEndpoint().contains('75030000000prS0AAI')); // assert we got the right job number
            return res;
        }
        //auth end point
        else if (req.getEndpoint().endsWith('/batch')){ // this is our create batch call
             res.setHeader('Content-Type', ' application/xml; charset=UTF-8');
             res.setBody('<?xml version="1.0" encoding="UTF-8"?><batchInfo '+
                 '  xmlns="http://www.force.com/2009/06/asyncapi/dataload"> '+
                 '<id>75130000001nvUUAAY</id> '+
                 '<jobId>75030000000prS0AAI</jobId> '+
                 '<state>Queued</state> '+
                 '<createdDate>2014-09-05T13:11:29.000Z</createdDate> '+
                 '<systemModstamp>2014-09-05T13:11:29.000Z</systemModstamp> '+
                 '<numberRecordsProcessed>0</numberRecordsProcessed> '+
                 '<numberRecordsFailed>0</numberRecordsFailed> '+
                 '<totalProcessingTime>0</totalProcessingTime> '+
                 '<apiActiveProcessingTime>0</apiActiveProcessingTime> '+
                ' <apexProcessingTime>0</apexProcessingTime> '+
                '</batchInfo>');
             res.setStatusCode(201);
             res.setStatus('Created');
             return res;
        } else if (req.getEndpoint().endsWith('/job')) { // this is our create job call
             res.setHeader('Content-Type', ' application/xml; charset=UTF-8');
             res.setBody('<?xml version="1.0" encoding="UTF-8"?><jobInfo '+
                 '  xmlns="http://www.force.com/2009/06/asyncapi/dataload"> '+
                 '<id>75030000000prS0AAI</id> '+
                 '<operation>update</operation> '+
                 '<object>Contact</object> '+
                 '<createdById>00530000009juvcAAA</createdById> '+
                 '<createdDate>2014-09-05T13:11:29.000Z</createdDate> '+
                 '<systemModstamp>2014-09-05T13:11:29.000Z</systemModstamp> '+
                 '<state>Open</state> '+
                 '<concurrencyMode>Parallel</concurrencyMode> '+
                 '<contentType>XML</contentType> '+
                 '<numberBatchesQueued>0</numberBatchesQueued> '+
                 '<numberBatchesInProgress>0</numberBatchesInProgress> '+
                 '<numberBatchesCompleted>0</numberBatchesCompleted> '+
                 '<numberBatchesFailed>0</numberBatchesFailed> '+
                 '<numberBatchesTotal>0</numberBatchesTotal> '+
                 '<numberRecordsProcessed>0</numberRecordsProcessed> '+
                 '<numberRetries>0</numberRetries> '+
                 '<apiVersion>31.0</apiVersion> '+
                 '<numberRecordsFailed>0</numberRecordsFailed> '+
                 '<totalProcessingTime>0</totalProcessingTime> '+
                 '<apiActiveProcessingTime>0</apiActiveProcessingTime> '+
                ' <apexProcessingTime>0</apexProcessingTime> '+
                '</jobInfo>');
             res.setStatusCode(201);
             res.setStatus('Created');
             return res;
        } else { // this is our close job call
             res.setHeader('Content-Type', ' application/xml; charset=UTF-8');
             res.setBody('<?xml version="1.0" encoding="UTF-8"?><jobInfo '+
                '   xmlns="http://www.force.com/2009/06/asyncapi/dataload"> '+
                ' <id>75030000000prS0AAI</id> '+
                ' <operation>update</operation> '+
                ' <object>Contact</object> '+
                ' <createdById>00530000009juvcAAA</createdById> '+
                ' <createdDate>2014-09-05T13:11:29.000Z</createdDate> '+
                ' <systemModstamp>2014-09-05T13:11:29.000Z</systemModstamp> '+
                ' <state>Closed</state> '+
                ' <concurrencyMode>Parallel</concurrencyMode> '+
                ' <contentType>XML</contentType> '+
                ' <numberBatchesQueued>0</numberBatchesQueued> '+
                ' <numberBatchesInProgress>0</numberBatchesInProgress> '+
                 '<numberBatchesCompleted>1</numberBatchesCompleted> '+
                 '<numberBatchesFailed>0</numberBatchesFailed> '+
                 '<numberBatchesTotal>1</numberBatchesTotal> '+
                 '<numberRecordsProcessed>1</numberRecordsProcessed> '+
                 '<numberRetries>0</numberRetries> '+
                 '<apiVersion>31.0</apiVersion> '+
                ' <numberRecordsFailed>1</numberRecordsFailed> '+
                ' <totalProcessingTime>263</totalProcessingTime> '+
                ' <apiActiveProcessingTime>96</apiActiveProcessingTime> '+
                ' <apexProcessingTime>0</apexProcessingTime> '+
                '</jobInfo>');
             res.setStatusCode(200);
             res.setStatus('OK');
             System.assert(req.getEndpoint().contains('75030000000prS0AAI')); // assert we got the right job number
             return res;
        }
    }
    

}