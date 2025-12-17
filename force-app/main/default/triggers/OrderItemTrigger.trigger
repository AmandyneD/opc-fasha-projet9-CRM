trigger OrderItemTrigger on OrderItem (
    after insert, after update, after delete, after undelete
) {
    Set<Id> orderIds = new Set<Id>();

    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
        for (OrderItem oi : Trigger.new) {
            if (oi.OrderId != null) {
                orderIds.add(oi.OrderId);
            }
        }
    }

    if (Trigger.isDelete) {
        for (OrderItem oi : Trigger.old) {
            if (oi.OrderId != null) {
                orderIds.add(oi.OrderId);
            }
        }
    }

    if (!orderIds.isEmpty()) {
        OrderBusinessLogic.recalculateNetAmount(orderIds);
    }
}