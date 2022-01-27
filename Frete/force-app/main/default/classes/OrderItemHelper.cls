public with sharing class OrderItemHelper {
    

    public static void updateOrderFreight (List<OrderItem> orderItemList) {
        Set<Id>  orderIdSet = new set<Id>();

        for(OrderItem orderItem : orderItemList) {

            orderIdSet.add(orderItem.OrderId);
        }

        List<Order> orderList = [
            SELECT Id, ShippingPostalCode, ShippingCity, ShippingState, Freight__c, DistributionCenter__c, TotalFreight__c
            FROM Order
            WHERE Id IN :orderIdSet
        ];

        List<Order> updateOrderList = OrderHelper.findFreight(orderList);

        OrderHandler.disableTrigger();
        update updateOrderList;
        OrderHandler.enableTrigger();

    }

}