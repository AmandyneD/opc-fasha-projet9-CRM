trigger OrderTrigger on Order (before update) {
    for (Order o : Trigger.new) {
        Order oldO = Trigger.oldMap.get(o.Id);

        if (o.ShipmentCost__c != oldO.ShipmentCost__c) {
            Decimal total = o.TotalAmount == null ? 0 : o.TotalAmount;
            Decimal ship  = o.ShipmentCost__c == null ? 0 : o.ShipmentCost__c;
            o.NetAmount__c = total - ship;
        }
    }
}