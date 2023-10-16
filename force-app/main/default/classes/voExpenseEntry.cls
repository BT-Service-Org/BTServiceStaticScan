public class voExpenseEntry {

    // properties -------------------------------------------------------------
    public Weekly_Expense_Entry__c expenseEntry {public get; public set;}
    public String resourceName {public get; public set;}
    public String sowName {public get; public set;}
    
    // controller -------------------------------------------------------------
    public voExpenseEntry() {
        expenseEntry = new Weekly_Expense_Entry__c();
        resourceName = '';
        sowName = '';
    }
}