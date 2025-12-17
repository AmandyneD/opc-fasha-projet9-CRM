public with sharing class AccountOrderTotalsController {

    @AuraEnabled(cacheable=true)
    public static Decimal getSumOrdersByAccount(Id accountId) {
        if (accountId == null) return 0;

        AggregateResult ar = [
            SELECT SUM(TotalAmount) total
            FROM Order
            WHERE AccountId = :accountId
              AND Status = 'Activated'
        ];

        Decimal total = (Decimal) ar.get('total');
        return total == null ? 0 : total;
    }
}