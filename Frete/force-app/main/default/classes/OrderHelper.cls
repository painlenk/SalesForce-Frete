public with sharing class OrderHelper {
   

    public static void setDeliveryAddress (List<Order> orderList) {

        Set<ID> accountIdSet = new Set<Id>();
        
        

        for(Order order : orderList) {

            accountIdSet.add(order.AccountId);
            

        }

        Map<Id, Account> accountIdToAccountMap = new Map<Id, Account> (

        [
            SELECT Id, City__r.Name, CEP__c, City__r.State__r.Name , Bairro__c, Rua__c, Numero__c
            FROM Account
            WHERE Id IN: accountIdSet

        ]

        );


        for(Order order : orderList) {

            Account acc = accountIdToAccountMap.get(order.AccountId);

            order.ShippingCity = acc.City__r.Name;
            order.ShippingPostalCode = acc.CEP__c;
            order.ShippingState = acc.City__r.State__r.Name;
            order.ShippingStreet = acc.Rua__c + ', ' + acc.Numero__c + ', ' + acc.Bairro__c;

        }

        
        
    }

    public static List<Order> findFreight (List<Order> orderList) {
        

        Set<String> citySet = new Set<String>();
        Set<String> stateSet = new Set<String>();
        Set<String> postalCodeSet = new Set<String>();
        Set<Id> orderIdSet = new Set<Id>();

        for(Order order : orderList) {
            citySet.add(order.ShippingCity);
            stateSet.add(order.ShippingState);
            postalCodeSet.add(order.ShippingPostalCode);
            orderIdSet.add(order.Id);
        }

        List<Freight__c> freightList = [
            SELECT Id, CEP__c, City__c,City__r.Name , State__c, State__r.Name, FreightBase__c, FreightByWeight__c, FreightByVolumn__c, DistributionCenter__c
            FROM Freight__c
            WHERE  City__r.Name IN :citySet
            OR State__R.name IN :stateSet
            OR CEP__c IN :postalCodeSet

        ];
        

        Map<String, List<Freight__c>> localToFreightListMap = new Map<String, List<Freight__c>>();
        Map<String, id> cityNameToCityId = new Map<String, id>();
        Map<String, id> stateNameToStateId = new Map<String, id>();

        

        for(Freight__c freight : freightList) {

            String key = '';

            if(String.isNotBlank(freight.CEP__c)) {
                key = freight.CEP__c;
            }
            else if (String.isNotBlank(freight.City__c)) {
                key = freight.City__c;
                cityNameToCityId.put(freight.City__r.Name, freight.City__c);
            }

            else if (String.isNotBlank(freight.State__c)) {
                key = freight.State__c;
                stateNameToStateId.put(freight.State__r.Name, freight.State__c);
            }

            if(localToFreightListMap.containsKey(key)){
                localToFreightListMap.get(key).add(freight);
            } else {
                localToFreightListMap.put(key, new List<Freight__c>{freight});
            }
        }

        

        Map<Id, list<OrderItem>> orderIdToOrderItemMap = new Map<Id, list<OrderItem>>();


        for( Orderitem orderItem :[
            SELECT Id, OrderId, Order.ShippingPostalCode, Order.ShippingCity, Order.ShippingState , Volume__c, Weight__c, Quantity 
            FROM OrderItem
            WHERE OrderId IN :orderIdSet
        ]){
            
            if(orderIdToOrderItemMap.containsKey(orderItem.OrderId)){

                orderIdToOrderItemMap.get(orderItem.OrderId).add(orderItem);

            }else {
                orderIdToOrderItemMap.put(orderItem.orderId, new List<orderItem>{orderItem});
            }

            
        }

        for(Order order : orderList) {

            List<Freight__c> freights;

            if(localToFreightListMap.containsKey(order.ShippingPostalCode)) {

                freights = localToFreightListMap.get(order.ShippingPostalCode) ;

            }else if(cityNameToCityId.containsKey(order.ShippingCity) && localToFreightListMap.containsKey(cityNameToCityId.get(order.ShippingCity))) {

                freights  =  localToFreightListMap.get(cityNameToCityId.get(order.ShippingCity));

            }else if (stateNameToStateId.containsKey(order.ShippingState) && localToFreightListMap.containsKey(stateNameToStateId.get(order.ShippingState))) {

                freights  =  localToFreightListMap.get(stateNameToStateId.get(order.ShippingState));

            } else {

                order.addError('Não foi possível localizar um frete');
            }  

            

            if(!orderIdToOrderItemMap.containsKey(order.Id)) {

                continue;
            }

            Decimal totalWeight = 0;
            Decimal totalVolume =0;
            Decimal totalQuantity =0;
            
            for(OrderItem orderItem: orderIdToOrderItemMap.get(order.Id) ) {

                
                totalWeight += orderItem.Weight__c;
                totalVolume += orderItem.Volume__c;
                totalQuantity += orderItem.Quantity;
            }



            Decimal lowestValue = null;
            Freight__c chosenFreight = null ;
            
            for(Freight__c freight : freights) {

                Decimal volume = freight.FreightByVolumn__c * totalWeight;
                Decimal weight = freight.FreightByWeight__c * totalVolume;
                Decimal quantity = freight.FreightBase__c * totalQuantity;

                List<Decimal> freigthPrices = new List<Decimal>{
                    volume,
                    weight,
                    quantity
                };

                freigthPrices.sort();

                Decimal expensiveFreight = freigthPrices.get(freigthPrices.size() -1);

               if(lowestValue == null || lowestValue > expensiveFreight ) {
                    lowestValue = expensiveFreight;
                    chosenFreight = freight;   
                }
            }

           

            order.Freight__c = chosenFreight.Id;
            order.DistributionCenter__c = chosenFreight.DistributionCenter__c;
            order.TotalFreight__c = lowestValue;
 
        }

        return orderList;
    }

    
    
   
}