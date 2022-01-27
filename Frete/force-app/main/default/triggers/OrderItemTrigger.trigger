trigger OrderItemTrigger on OrderItem (after insert, after update) {

    OrderItemHandler handler = new OrderItemHandler(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap); 

    switch on Trigger.operationType {
        when AFTER_INSERT {
            handler.afterInsert();
        }

        when AFTER_UPDATE {
            handler.afterInsert();
        }
        
    }
}