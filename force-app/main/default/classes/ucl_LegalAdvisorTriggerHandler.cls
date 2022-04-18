public with sharing class ucl_LegalAdvisorTriggerHandler {
    public static void deleteRelatedClients(List<Legal_Advisor__c> advisorList){
        System.debug('Advisor Name es '+advisorList[0].Name);
        Id advisorId = advisorList[0].id;
        List<Client__c> clientList = [SELECT Legal_Advisor__c FROM Client__c WITH SECURITY_ENFORCED];
        List<Client__c> clientToDelete = new List<Client__c>();
        for(Client__c client: clientList){
            if(client.Legal_Advisor__c==advisorId){
                clientToDelete.add(client);
            }
        }
        System.debug('Client to delete ');
        System.debug(clientToDelete);
    }
}
