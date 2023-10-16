global class CaseSIWrapper implements Comparable {
    @AuraEnabled public Case wcase {
        public get;
        public set {
            this.wcase = value;
            this.wrappedType = 'Case';
        }
    }
    @AuraEnabled public Strategic_Initiative_c__x wsi {
        public get;
        public set {
            this.wsi = value;
            this.wrappedType = 'SI';
        }
    }
    @AuraEnabled public String wrappedType {get;set;}

    global Integer compareTo(Object compareTo) {
        CaseSIWrapper compareToWrapper = (CaseSIWrapper)compareTo;

        Integer retVal = 0;
        Long d1 = 0;
        Long d2 = 0;

        // SI - CreatedDate__c - date/time
        // case - CreatedDate - date/time
        
        if (wcase != NULL) {
            d1 = wcase.CreatedDate.getTime();
        } else {
            d1 = wsi.CreatedDate__c.getTime();
        }

        if (compareToWrapper.wcase != NULL) {
            d2 = compareToWrapper.wcase.CreatedDate.getTime();
        } else {
            d2 = compareToWrapper.wsi.CreatedDate__c.getTime();
        }

        if (d1 < d2) {
            retVal = 1;
        } else {
            retVal = -1;
        }

        return retVal;
    }
}