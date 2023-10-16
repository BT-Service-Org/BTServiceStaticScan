//######################################################
// Test class for the WAV_DataLoad_UTL class.
// Author : P-E GROS - July 2018
// #####################################################
@istest
class WAV_DataLoad_UTL_TST {

    static testmethod void testExecuteSynch() {
        
       WAV_DataLoad_UTL.execute(null);
       //WAV_DataLoad_UTL.executeSynch('WAV_Test');
       
        
       // test simply for code coverage
       // init and control of test conditions impossible
       // Static resources & custom metadata may not be defined in test class
       // SOQL on InsightsExternalData(Part) return actual data in the Org.
       /*
       WAV_DataLoad_CFG__mdt[] configList = [select DeveloperName from WAV_DataLoad_CFG__mdt];
       System.debug('testExecuteSynch configList' + configList);
       InsightsExternalData[] loader      = [select Id, createdDate from InsightsExternalData];
       System.debug('testExecuteSynch loader' + loader);
       InsightsExternalDataPart[] parts   = [select Id, createdDate from InsightsExternalDataPart];
       System.debug('testExecuteSynch parts' + parts);
       System.assertEquals(configList.size(),loader.size());
       System.assertEquals(configList.size(),parts.size());
       */
        /*
       Map<String,String> fieldMap = new Map<String,String> {'Client' => 'Name', 'Location' => 'Site', 'Source' => 'AccountSource' };
       Account testObj = new Account(Name='test',site='test');
        
       String returnStr = WAV_DataLoad_UTL.formatDataLine(fieldMap,testObj);
       System.assertEquals('"test","test",""\n',returnStr);
       */
        
       WAV_DataLoad_QUE testQueue = new WAV_DataLoad_QUE('test','soql','Id','Id0000',1,1,null,null,null,'test',System.now());
       
    }
    
    // To increase code coverage
    static testmethod void testFormatDataLine() {                
       Map<String,list<String>> fieldMap = new Map<String,list<String>>
                  {'Client'   => new list<String> {'Name'},
                   'Location' => new list<String> {'Site'},
                   'Source'   => new list<String> {'AccountSource'}};
       Account testObj = new Account(Name='testA',site='testS');
        
       system.debug('testFormatDataLine: testObj'  + testObj);
       system.debug('testFormatDataLine: fieldMap' + fieldMap);
        
       WAV_DataLoad_QUE queue = new WAV_DataLoad_QUE(
                            'TESTProcess','select Name from Account', 'Id','Id0000',5,1,null,fieldMap,false,
                            'Client,Location,Source',System.now());
        
       String returnStr = queue.formatDataLine(fieldMap,false,testObj);
       System.assertEquals('"testA","testS",""\n',returnStr);
        
       User testUser = new User(LastName='testU');
       testObj.owner = testUser;
       fieldMap.put('Owner',new list<String> {'Owner','LastName'}) ;   
        system.debug('testFormatDataLine: testUser' + testUser);
       system.debug('testFormatDataLine: testObj2'  + testObj);
       system.debug('testFormatDataLine: fieldMap2' + fieldMap);
       returnStr = queue.formatDataLine(fieldMap,true,testObj);
       System.assertEquals('"testA","testS","","testU"\n',returnStr);
    }
    static testmethod void testgetOffsetQuery() {     
       Map<String,list<String>> fieldMap = new Map<String,list<String>>
                  {'Client'   => new list<String> {'Name'},
                   'Location' => new list<String> {'Site'},
                   'Source'   => new list<String> {'AccountSource'}};
       //Map<String,String> fieldMap = new Map<String,String> {'Client' => 'Name', 'Location' => 'Site', 'Source' => 'AccountSource' };
       //Account testObj = new Account(Name='test',site='test');
        
       WAV_DataLoad_QUE queueWhere = new WAV_DataLoad_QUE(
                            'TESTProcess','select Name from Account Where Name like \'%TST%\'', 'Id','Id0000',5,1,null,fieldMap,false,
                            'Client,Location,Source',System.now());
       WAV_DataLoad_QUE queueNoWhere = new WAV_DataLoad_QUE(
                            'TESTProcess','select Name from Account', 'Id','Id0000',5,1,null,fieldMap,false,
                            'Client,Location,Source',System.now());
        
       String queryWhere   = queueWhere.getOffsetQuery();
       System.assertEquals('select Name from Account Where Name like \'%TST%\' AND Id > \'Id0000\' ORDER BY Id LIMIT 5',
                           queryWhere);
        
       String queryNoWhere = queueNoWhere.getOffsetQuery();
       System.assertEquals('select Name from Account WHERE Id > \'Id0000\' ORDER BY Id LIMIT 5',
                           queryNoWhere);
        
    }
        
}