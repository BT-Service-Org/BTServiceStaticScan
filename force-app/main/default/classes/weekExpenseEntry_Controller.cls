public class weekExpenseEntry_Controller {
    // properties -------------------------------------------------------------
    private String strSOWId {private get; private set;}
    private Date dtLastWeekBeginning {private get; private set;}
    public List<voExpenseEntry> lstExpenses {public get; public set;}
    public String strLastWeekBeginning {get; set;}

    // controller -------------------------------------------------------------
    public weekExpenseEntry_Controller() {
        // get the querystring parms
        System.debug('Unpackaging querystring parms...');
        
        if (ApexPages.currentPage().getParameters().containsKey('sowid')) {
            strSOWId = ApexPages.currentPage().getParameters().get('sowid'); 
        } else {
            strSOWId = '';
        }
        System.debug('SOW Id Received: ' + strSOWId);
        System.debug('Initializing class properties...');
        dtLastWeekBeginning = Date.today().toStartOfWeek().addDays(-6);
        strLastWeekBeginning = Date.today().toStartOfWeek().addDays(-6).format();
        lstExpenses = new List<voExpenseEntry>();
        System.debug('Initialized');
    }

    public List<voExpenseEntry> getWeekExpenses() {
        
        System.debug('GETTING EXPENSES');
        // define local vars
        String currentUserId = UserInfo.getUserId();
        List<SOW_Resource_Assignment__c> tempAry;
        
        // query the records
        if (strSOWId != '') {
            System.debug('SOW RECIEVED CASE');
            tempAry = [select Id, SOW__r.Name, SOW__c, Resource_Name__c 
                from SOW_Resource_Assignment__c 
                where SOW__r.OwnerId = :currentUserId and SOW__c = :strSOWId
                order by SOW__r.Name, Hourly_Rate__c desc, Resource_Name__c];
            System.debug('QUERY DONE');           
        } else {
            System.debug('SOW NOT RECIEVED CASE');
            tempAry = [select Id, SOW__r.Name, SOW__c, Resource_Name__c 
                from SOW_Resource_Assignment__c 
                where SOW__r.OwnerId = :currentUserId and SOW__r.Status__c != 'Closed'
                order by SOW__r.Name, Hourly_Rate__c desc, Resource_Name__c];
            System.debug('QUERY DONE');
        }
        // print the collection ot the debug log
        System.debug(tempAry);
        
        String tempSOWName = '';
        
        for (SOW_Resource_Assignment__c rec : tempAry) {
            // initialize an expense entry
            Weekly_Expense_Entry__c tempExpense = new Weekly_Expense_Entry__c();
            // populate with what we know
            tempExpense.Week_Beginning__c = dtLastWeekBeginning;
            tempExpense.SOW__c = rec.SOW__c;
            tempExpense.SOW_Resource_Assignment__c = rec.Id;
            tempExpense.Expense_Amount__c = 0;
            
            // build an expense vo
            voExpenseEntry tempVO = new voExpenseEntry();
            tempVO.expenseEntry = tempExpense;
            tempVO.resourceName = rec.Resource_Name__c;
            // only store the SOW name for the first entry of each
            if (tempSOWName != rec.SOW__r.Name) {
                tempVO.sowName = rec.SOW__r.Name;
            } else {
                tempVO.sowName = '';
            }
            
            // add it to the list to be returned
            lstExpenses.add(tempVO);
            
            // store the current name
            tempSOWName = rec.SOW__r.Name;
        }
        // print the collection ot the debug log
        System.debug(lstExpenses);
        
        // return the data
        return lstExpenses;
    }
    
    public PageReference saveExpenses() {
        // declare local vars
        PageReference redir;
        List<Weekly_Expense_Entry__c> expensesToSave = new List<Weekly_Expense_Entry__c>();
        
        // mark the time as actual
        for (voExpenseEntry rec : lstExpenses) {
            if (rec.expenseEntry.Expense_Amount__c > 0) {
                expensesToSave.add(rec.expenseEntry);
            }
        }
        // debug information
        System.debug('Saving the following records:');
        System.debug(expensesToSave);
        // perform the update
        insert expensesToSave;
        // determine the redirect
        if (strSOWId != '') {
            redir = new PageReference('/' + strSOWId);
        } else {
            redir = new PageReference('/home/home.jsp');
        }
        return redir;
    }

}