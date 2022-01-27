trigger OrderTrigger on Order (before insert, before update, after insert, after update, before delete, after delete) {


    OrderHandler handler = new OrderHandler( Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    
    
    switch on Trigger.operationType {
        when BEFORE_INSERT {
            handler.beforeInsert();
        }
        when BEFORE_UPDATE{
            handler.beforeUpdate();
        }
    }
}