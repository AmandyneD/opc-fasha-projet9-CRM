public with sharing class OrderBusinessLogic {

    public static void recalculateNetAmount(Set<Id> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) return;

        // 1) Total = somme des OrderItems (TotalPrice)
        Map<Id, Decimal> totalsByOrder = new Map<Id, Decimal>();
        for (AggregateResult ar : [
            SELECT OrderId oid, SUM(TotalPrice) sumTotal
            FROM OrderItem
            WHERE OrderId IN :orderIds
            GROUP BY OrderId
        ]) {
            totalsByOrder.put((Id) ar.get('oid'), (Decimal) ar.get('sumTotal'));
        }

        // 2) Recalcul NetAmount = totalLignes - shipping
        List<Order> toUpdate = [
            SELECT Id, ShipmentCost__c
            FROM Order
            WHERE Id IN :orderIds
        ];

        for (Order o : toUpdate) {
            Decimal total = totalsByOrder.containsKey(o.Id) ? totalsByOrder.get(o.Id) : 0;
            Decimal ship  = o.ShipmentCost__c == null ? 0 : o.ShipmentCost__c;
            o.NetAmount__c = total - ship;
        }

        update toUpdate;
    }
}