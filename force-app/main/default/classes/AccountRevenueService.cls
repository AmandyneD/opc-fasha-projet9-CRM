public with sharing class AccountRevenueService {

    public static void recalcRevenue(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) return;

        Map<Id, Decimal> sumByAccount = new Map<Id, Decimal>();
        for (AggregateResult ar : [
            SELECT AccountId accId, SUM(TotalAmount) total
            FROM Order
            WHERE AccountId IN :accountIds
            AND Status = 'Activated'
            GROUP BY AccountId
        ]) {
            sumByAccount.put((Id) ar.get('accId'), (Decimal) ar.get('total'));
        }

        List<Account> toUpdate = new List<Account>();
        for (Account a : [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id IN :accountIds]) {
            Decimal newCA = sumByAccount.containsKey(a.Id) ? sumByAccount.get(a.Id) : 0;
            if (a.Chiffre_d_affaire__c != newCA) {
                a.Chiffre_d_affaire__c = newCA;
                toUpdate.add(a);
            }
        }

        if (!toUpdate.isEmpty()) update toUpdate;
    }
}