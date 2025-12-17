global class UpdateAllAccounts implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Option perf: ne prendre que les accounts ayant au moins une order activated
        return Database.getQueryLocator([
            SELECT Id
            FROM Account
            WHERE Id IN (SELECT AccountId FROM Order WHERE Status = 'Activated' AND AccountId != null)
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Account> scope) {
        Set<Id> accountIds = new Set<Id>();
        for (Account a : scope) accountIds.add(a.Id);

        AccountRevenueService.recalcRevenue(accountIds);
    }

    global void finish(Database.BatchableContext bc) {}
}