public with sharing class ucl_ConexionData {
    

    //Create conexion
    //Get JSON data
    public static HttpResponse getConexionData() {
        
        //Variables
        String url = 'https://altimetrik-bootcamp.herokuapp.com/LegalAccounts';
        Http http = new Http();
        HttpRequest request = new HttpRequest();


        //Get conexion
        request.setEndpoint(url);
        request.setMethod('GET');
        HttpResponse response = http.send(request);       
        return response;
    }

    
    //Convert response to Object
    @AuraEnabled(cacheable=true)
    public static boolea dataToObject(){        
        boolean conexionStatus = false;
        HttpResponse response = getConexionData();

        //Verification of response status
        if(response.getStatusCode() == 200) {
            conexionStatus=true;

            //Variables
           
            List<Legal_Advisor__c> disabledAdvisorList = new List<Legal_Advisor__c>();
            List<Client__c> newClientsList = new List<Client__c>();
            List<Legal_Advisor__c> newLegalAdvisorList = new List<Legal_Advisor__c>();

            //Creation List of Legal Advisor
            List<Object> legalAdvisorList = (List<Object>) JSON.deserializeUntyped(response.getBody());      
            System.debug('****** Lista legal advior list despues de deserializar');
            System.debug(legalAdvisorList);
            
            //Iteration through List and Maps
            //Get data from Maps to set Custom Objet "Legal_Advisor__c"

            newLegalAdvisorList = createLegalAdvisorObject(legalAdvisorList);
            System.debug('Lista new Legal Advisor list despues de createLegalAdvisorObject ');
            SYstem.debug(newLegalAdvisorList);
            newClientsList = createClientObject(legalAdvisorList, newLegalAdvisorList);
            

           
            
            //Iteration through List and Maps
            //Get data from Maps to set Custom Object "Clients"
            
            


        }
        return conexionStatus;
        
    }



    //Get data from Maps to set Custom Objet "Legal_Advisor__c"

    public static List<Legal_Advisor__c> createLegalAdvisorObject(List<Object> legalAdvisorList){
        List<Legal_Advisor__c> newLegalAdvisorList = new List<Legal_Advisor__c>();
        for(Object advisor:legalAdvisorList){
            Map<String,Object> legalAdvisorData = (Map<String,Object>) advisor;   
            Legal_Advisor__c legalAdvisor = new Legal_Advisor__c();
            String accountNumber = (String) legalAdvisorData.get('AccountNumber');
            String name = (String) legalAdvisorData.get('AccountName');
            String accountStatus = (String) legalAdvisorData.get('AccountStatus');
            String auxDate =  (String) legalAdvisorData.get('AsOfDate');           
            Date asOfDate = date.parse((String) legalAdvisorData.get('AsOfDate'));
            legalAdvisor.Account_Number__c = accountNumber;
            legalAdvisor.Name = name;
            legalAdvisor.Account_Status__c = accountStatus;
            legalAdvisor.As_of_Date__c = asOfDate;
            List<Object> clientList = (List<Object>) legalAdvisorData.get('Clients');
            newLegalAdvisorList.add(legalAdvisor);
                                                      
        } 
        insertAdvisorObjects(newLegalAdvisorList);
        return newLegalAdvisorList;

    }

    //Get data from Maps to set Custom Object "Clients"

    public static List<Client__c> createClientObject(List<Object> legalAdvisorList, List<Legal_Advisor__c> newLegalAdvisorList){
        List<Client__c> newClientsList = new List<Client__c>();
            for(integer i=0; i<newLegalAdvisorList.size();i++){
                Map<String,Object> legalAdvisorData = (Map<String,Object>) legalAdvisorList[i];   
                List<Object> clientList = (List<Object>) legalAdvisorData.get('Clients');
                for(Object client:clientList){
                    Map<String,Object> clientData = (Map<String,Object>) client;
                    Client__c newClient = new Client__c();
                    String name = (String) clientData.get('FirstName');
                    String lastName = (String) clientData.get('LastName');
                    String email = (String) clientData.get('Email');
                    String phone = (String) clientData.get('Phone');
                    String adress = (String) clientData.get('Address');
                    String clientNumber = (String) clientData.get('ClientNumber');
                    Id legalAdvisorId = newLegalAdvisorList[i].Id;
                    newClient.Name = name;
                    newClient.Last_Name__c = lastName;
                    newClient.Email__c = email;
                    newClient.Phone__c = phone;
                    newClient.Address__c = adress;
                    newClient.Client_Number__c = clientNumber;
                    newClient.Legal_Advisor__c = legalAdvisorId;
                    newClient.Created_From__c = 'JSON';
                    if(newLegalAdvisorList[i].Account_Status__c == 'Enabled'){
                        newClientsList.add(newClient);
                    }
                    
                }                               
            }

            insertClientObjects(newClientsList);
                           
            //insert newClientsList;
            return newClientsList;

    }

    

    //Insert or update objects
    public static void insertAdvisorObjects(List<Legal_Advisor__c> advisorList){
        System.debug('Entro en insert advisor object');
        System.debug(advisorList);
        List<Legal_Advisor__c> insertAdvisorList = new List<Legal_Advisor__c>();
        List<Legal_Advisor__c> updateAdvisorList = new List<Legal_Advisor__c>();
        List<Legal_Advisor__c> oldAdvisorList = [SELECT Account_Number__c FROM Legal_Advisor__c WITH SECURITY_ENFORCED];
        for(Legal_Advisor__c advisor:advisorList){
            for(Legal_Advisor__c oldAdvisor:oldAdvisorList){
                if(advisor.Account_Number__c == oldAdvisor.Account_Number__c){
                    updateAdvisorList.add(advisor);
                } else if(advisor.Account_Status__c=='Enabled'){
                    if(insertAdvisorList.contains(advisor)==false){
                        System.debug('Agrego Advisor '+advisor.Name);
                        insertAdvisorList.add(advisor);
                    }
                    
                }              
            }
            if(insertAdvisorList.contains(advisor)==false && advisor.Account_Status__c=='Enabled'){
                insertAdvisorList.add(advisor);
            }
        }
        System.debug('****************');
        System.debug(insertAdvisorList);
        /*
        SObject.sObjectType.getDescribe().isAccesible();
        SObject.sObjectType.getDescribe().isCreateable();
        SObject.sObjectType.getDescribe().isUpdateable();
        SObject.sObjectType.getDescribe().isDeleteable();
        */

        

        if (Legal_Advisor__c.SObjectType.getDescribe().isCreateable() == true) {
            insert insertAdvisorList;
        }
        
        //SObjectAccessDecision decision = Security.stripInaccessible(AccessType.CREATABLE, insertAdvisorList);
       
        //update updateAdvisorList;

    }

    public static void insertClientObjects(List<Client__c> clientList){
        //SELECT Legal_Advisor__r.Account_Number__c, Client_Number__c  FROM Client__c
        List<Client__c> oldClientList = [SELECT Legal_Advisor__r.Account_Number__c, Client_Number__c,  Created_From__c FROM Client__c WITH SECURITY_ENFORCED];
        List<Client__c> toDeleteClientList = new List<Client__c>();
        for(Client__c client:clientList){
            String idClient = client.Legal_Advisor__r.Account_Number__c + client.Client_Number__c;
            for(Client__c oldClient:oldClientList){
                String oldIdClient = oldClient.Legal_Advisor__r.Account_Number__c + oldClient.Client_Number__c;
                System.debug('Old Client '+oldClient);
                
                if(idClient!=oldIdClient && oldClient.Created_From__c!=null){
                    toDeleteClientList.add(oldClient);
                }
                
            }
        }
        
        //SObject.sObjectType.getDescribe().isCreateable();
        
        

    }
    
}

//ucl_ConexionData.dataToObject();