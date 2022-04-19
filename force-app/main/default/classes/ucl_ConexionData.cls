
public with sharing class ucl_ConexionData {
    

    //Create conexion
    //Get JSON data
    public static HttpResponse getConexionData() {
        
        //Variables
        String url = 'https://altimetrik-bootcamp.herokuapp.com/LegalAccounts';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();

        //Get conexion
        try{
            request.setEndpoint(url);
            request.setMethod('GET');
            response = http.send(request);       
            
        }catch(Exception e){
            logErrors(e.getMessage());
        }
        return response;
       
    }

    @future(callout=true)
    public static void call(){
        boolean status = dataToObject();
    }
    
    //Convert response to Object
    @AuraEnabled
    public static boolean dataToObject(){  
        boolean conexionStatus = false;
        try{       
            HttpResponse response = getConexionData();
            System.debug('Response es '+response.getStatusCode());
            //Verification of response status

            if(response.getStatusCode() == 200) {
                System.debug('Entro en el if de response');
                conexionStatus=true;

                //Variables
            
                List<Legal_Advisor__c> disabledAdvisorList = new List<Legal_Advisor__c>();
                List<Client__c> newClientsList = new List<Client__c>();
                List<Legal_Advisor__c> newLegalAdvisorList = new List<Legal_Advisor__c>();

                //Creation List of Legal Advisor
                List<Object> legalAdvisorList = (List<Object>) JSON.deserializeUntyped(response.getBody());                     
                newLegalAdvisorList = createLegalAdvisorObject(legalAdvisorList);
                newClientsList = createClientObject(legalAdvisorList, newLegalAdvisorList);

            }
        } catch(Exception e){
            logErrors(e.getMessage());
        }
        
        return conexionStatus;
        
    }



    //Get data from Maps to set Custom Objet "Legal_Advisor__c"

    public static List<Legal_Advisor__c> createLegalAdvisorObject(List<Object> legalAdvisorList){
        List<Legal_Advisor__c> newLegalAdvisorList = new List<Legal_Advisor__c>();
        try{
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
        }catch(Exception e){
            logErrors(e.getMessage());
        }
        
        return newLegalAdvisorList;

    }

    //Get data from Maps to set Custom Object "Clients"

    public static List<Client__c> createClientObject(List<Object> legalAdvisorList, List<Legal_Advisor__c> newLegalAdvisorList){
        List<Client__c> newClientsList = new List<Client__c>();
        try{
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
        }catch(Exception e){
            logErrors(e.getMessage());
        }
            
                           
        //insert newClientsList;
        return newClientsList; 

    }

    

    //Insert or update objects
    public static void insertAdvisorObjects(List<Legal_Advisor__c> advisorList){
        List<Legal_Advisor__c> newAdvisorList = new List<Legal_Advisor__c>();
        List<Legal_Advisor__c> updateAdvisorList = new List<Legal_Advisor__c>();
        List<Legal_Advisor__c> oldAdvisorList = [SELECT Account_Number__c FROM Legal_Advisor__c WITH SECURITY_ENFORCED];
        try{
            for(Legal_Advisor__c advisor:advisorList){
                for(Legal_Advisor__c oldAdvisor:oldAdvisorList){
                    if(advisor.Account_Number__c == oldAdvisor.Account_Number__c){
                        advisor.Id = oldAdvisor.Id; 
                        newAdvisorList.add(advisor);
                    }              
                }
                if(newAdvisorList.contains(advisor)==false && advisor.Account_Status__c=='Enabled'){
                    newAdvisorList.add(advisor);
                }
            }
            upsert newAdvisorList;
        }catch(Exception e){
            logErrors(e.getMessage());
        }
        
    }

    public static void insertClientObjects(List<Client__c> clientList){
        //SELECT Legal_Advisor__r.Account_Number__c, Client_Number__c  FROM Client__c
        List<Client__c> oldClientList = [SELECT Legal_Advisor__r.Account_Number__c, Client_Number__c,  Created_From__c FROM Client__c WITH SECURITY_ENFORCED];
        List<Client__c> toDeleteClientList = new List<Client__c>();
        try{
            for(Client__c client:clientList){
                String idClient = client.Legal_Advisor__r.Account_Number__c + client.Client_Number__c;
                for(Client__c oldClient:oldClientList){
                    String oldIdClient = oldClient.Legal_Advisor__r.Account_Number__c + oldClient.Client_Number__c;
                    
                    if(idClient!=oldIdClient && oldClient.Created_From__c!=null){
                        toDeleteClientList.add(oldClient);
                    }
                    
                }
            }
            delete toDeleteClientList;
            insert clientList;
        }catch(Exception e){
            logErrors(e.getMessage());
        }
        
        
    }

    public static void logErrors(String message){
        Error__c errorLog = new Error__c();
        errorLog.Message__c = message;
        System.debug(errorLog);
        Insert errorLog;
    }
    
}

//ucl_ConexionData.dataToObject();