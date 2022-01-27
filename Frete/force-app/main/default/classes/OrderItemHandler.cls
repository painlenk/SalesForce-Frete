public with sharing class OrderItemHandler {

    List<OrderItem> oldRecords {get; set;}//Trigger.old
    List<OrderItem> newRecords {get; set;}//Trigger.new
    Map<Id, OrderItem> oldMap {get; set;}//Trigger.oldMap
    Map<Id, OrderItem> newMap {get; set;}//Trigger.NewMap


    public OrderItemHandler(List<OrderItem> oldRecords, List<OrderItem> newRecords, Map<Id, OrderItem> oldMap, Map<Id, OrderItem> newMap ) {
        this.oldRecords = oldRecords;
        this.newRecords = newRecords;
        this.oldMap = oldMaP;
        this.newMap = newMap;
    }


    public  void afterInsert() {
         
        OrderItemHelper.updateOrderFreight(this.newRecords);
    }


}