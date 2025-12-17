trigger UpdateAccountCA on Order (after insert, after update, after delete, after undelete) {
    OrderAccountRevenueTriggerHandler.handle(
        Trigger.isInsert,
        Trigger.isUpdate,
        Trigger.isDelete,
        Trigger.isUndelete,
        Trigger.new,
        Trigger.old,
        Trigger.newMap,
        Trigger.oldMap
    );
}