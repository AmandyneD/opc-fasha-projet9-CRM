global class UpdateAllAccounts implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id
            FROM Account
            WHERE Id IN (
                SELECT AccountId
                FROM Order
                WHERE Status = 'Activated'
                  AND AccountId != null
            )
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Account> scope) {
        Set<Id> accountIds = new Map<Id, Account>(scope).keySet();
        AccountRevenueService.recalcRevenue(accountIds);
    }

    global void finish(Database.BatchableContext bc) {}
}