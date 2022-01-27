public with sharing class OrderHandler {

    private static Boolean enabled;

    static {
        enabled = true;
    }

    public static Boolean isEnabled () {
        return enabled;
    }

    public static void enableTrigger () {
        enabled = true;
    }

    public static void disableTrigger () {
        enabled = false;
    }




    List<Order> oldRecords {get; set;} //Trigger.old
    List<Order> newRecords {get; set;} //Trigger.new
    Map<Id, Order> oldMap {get; set;} //Trigger.odlMap
    Map<Id, Order> newMap {get; set;}//Trigger.newMap


    public OrderHandler(List<Order> oldRecords, List<Order> newRecords, Map<Id, Order> oldMap, Map<Id, Order> NewMap) {
        this.oldRecords = oldRecords;
        this.newRecords = newRecords;
        this.oldMap = oldMap;
        this.newmap = newMap;
    }


    
   public void beforeInsert() {
       OrderHelper.setDeliveryAddress(this.newRecords);
       OrderHelper.findFreight(this.newRecords);

   }

   public void beforeUpdate() {
     OrderHelper.setDeliveryAddress(this.newRecords);
     OrderHelper.findFreight(this.newRecords);
   }
}