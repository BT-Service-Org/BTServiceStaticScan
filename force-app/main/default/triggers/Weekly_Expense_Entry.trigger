trigger Weekly_Expense_Entry on Weekly_Expense_Entry__c (before insert, before update) {

    // change the entered date to reflect the Monday of the selected week
    for (Weekly_Expense_Entry__c expenseEntry : Trigger.New) {
        expenseEntry.Week_Beginning__c = expenseEntry.Week_Beginning__c.toStartOfWeek().addDays(1);
    }
}