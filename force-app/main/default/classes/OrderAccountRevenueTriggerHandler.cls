public with sharing class OrderAccountRevenueTriggerHandler {

    public static void handle(
        Boolean isInsert,
        Boolean isUpdate,
        Boolean isDelete,
        Boolean isUndelete,
        List<Order> newList,
        List<Order> oldList,
        Map<Id, Order> newMap,
        Map<Id, Order> oldMap
    ) {
        Set<Id> accountIds = new Set<Id>();

        if (isInsert || isUndelete) {
            for (Order o : newList) {
                if (o.AccountId != null) accountIds.add(o.AccountId);
            }
        }

        if (isDelete) {
            for (Order o : oldList) {
                if (o.AccountId != null) accountIds.add(o.AccountId);
            }
        }

        if (isUpdate) {
            for (Order o : newList) {
                Order oldO = oldMap.get(o.Id);
                if (oldO == null) continue;

                // Recalc seulement si on a un changement qui peut impacter la somme
                Boolean accountChanged = o.AccountId != oldO.AccountId;
                Boolean statusChanged  = o.Status != oldO.Status;

                if (accountChanged || statusChanged) {
                    if (o.AccountId != null) accountIds.add(o.AccountId);
                    if (oldO.AccountId != null) accountIds.add(oldO.AccountId); // important si Account change
                }
            }
        }

        AccountRevenueService.recalcRevenue(accountIds);
    }
}