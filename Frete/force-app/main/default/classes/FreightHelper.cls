public with sharing class FreightHelper {
   

    public static void calcScore (List<Freight__c> FreightList ) {

        for(Freight__c freight : FreightList) {

            Integer score =0;

            if(String.isNotBlank(String.valueOf(freight.State__c))) {
                score += 10;
            }else if (String.isNotBlank(String.valueOf(freight.City__c))) {
                score += 100;
            }else if (String.isNotBlank(String.valueOf(freight.CEP__c))) {
                score += 1000;
            }

            freight.Score__c = score;
            
        }

        
    }

}