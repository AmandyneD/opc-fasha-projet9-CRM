public with sharing class OrderBusinessLogic {

    public static void recalculateNetAmount(Set<Id> orderIds) {

        List<Order> orders = [
            SELECT Id, TotalAmount, ShipmentCost__c
            FROM Order
            WHERE Id IN :orderIds
        ];

        for (Order o : orders) {
            Decimal total = o.TotalAmount == null ? 0 : o.TotalAmount;
            Decimal ship  = o.ShipmentCost__c == null ? 0 : o.ShipmentCost__c;
            o.NetAmount__c = total - ship;
        }

        if (!orders.isEmpty()) {
            update orders;
        }
    }
}