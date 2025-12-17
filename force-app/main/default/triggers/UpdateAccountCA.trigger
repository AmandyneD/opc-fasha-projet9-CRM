trigger UpdateAccountCA on Order (after insert, after update, after delete, after undelete) {

    Set<Id> accountIds = new Set<Id>();

    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
        for (Order o : Trigger.new) if (o.AccountId != null) accountIds.add(o.AccountId);
    }
    if (Trigger.isDelete) {
        for (Order o : Trigger.old) if (o.AccountId != null) accountIds.add(o.AccountId);
    }

    AccountRevenueService.recalcRevenue(accountIds);
}