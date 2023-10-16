@isTest
public class CaseSIWrapperTest {
    @isTest static void wrapperCompare() {
        List<CaseSIWrapper> wrappedList = new List<CaseSIWrapper>();

        Test.startTest();

		List<String> date1Tokens = new List<String>{'{','"CreatedDate__c"',':"2016-10-30T15:27:02.000Z"}'};
        String siPayload = String.join(date1Tokens,'');

        System.debug('siPayload: ' + siPayload);
        Strategic_Initiative_c__x si = (Strategic_Initiative_c__x)JSON.deserialize(siPayload, Strategic_Initiative_c__x.class);
        
        CaseSIWrapper wrapped1 = new CaseSIWrapper();
        wrapped1.wsi = si;
        wrappedList.add(wrapped1);
        
        System.debug(si);
        System.debug(si.CreatedDate__c);

        List<String> date2Tokens = new List<String>{'{','"CreatedDate"',':"2017-10-30T15:27:02.000Z"}'};
        String casePayload = String.join(date2Tokens,'');
        Case newCase = (Case)JSON.deserialize(casePayload, Case.class);
        CaseSIWrapper wrapped2 = new CaseSIWrapper();
        wrapped2.wcase = newCase;
        wrappedList.add(wrapped2);

        System.debug(newCase);
        System.debug(newCase.CreatedDate);
        
        wrappedList.sort();

        Test.stopTest();
        
        System.assert(wrappedList.isEmpty() == FALSE, 'Content query return zero results');
        CaseSIWrapper first = (CaseSIWrapper)wrappedList.get(0);
        System.assert(first.wrappedType == 'Case', 'Incorrect Order value');
    }
}