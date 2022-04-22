
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
            logErrors(e);
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

                List<Legal_Advisor__c> newLegalAdvisorList = new List<Legal_Advisor__c>();

                //Creation List of Legal Advisor
                List<Object> legalAdvisorList = (List<Object>) JSON.deserializeUntyped(response.getBody());                     
                newLegalAdvisorList = createLegalAdvisorObject(legalAdvisorList);
                createClientObject(legalAdvisorList, newLegalAdvisorList);

            }
        } catch(Exception e){
            logErrors(e);
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
            logErrors(e);
        }
        
        return newLegalAdvisorList;

    }

    //Get data from Maps to set Custom Object "Clients"
    public static void createClientObject(List<Object> legalAdvisorList, List<Legal_Advisor__c> newLegalAdvisorList){
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
            logErrors(e);
        }
    }

    

    //Insert or update Legal Advisor Objects
    public static void insertAdvisorObjects(List<Legal_Advisor__c> advisorList){
        try{
            List<Legal_Advisor__c> newAdvisorList = new List<Legal_Advisor__c>();
        Set<String> accountNumbersLA = new Set<String>();
        for(Legal_Advisor__c advisor : advisorList){           
            String accountNumber = advisor.Account_Number__c;
            accountNumbersLA.add(accountNumber);
        }
        List<Legal_Advisor__c> oldAdvisorList = [SELECT Account_Number__c, (SELECT Name FROM Clients__r ) FROM Legal_Advisor__c WHERE Account_Number__c IN: accountNumbersLA WITH SECURITY_ENFORCED];      
        Map<String, Legal_Advisor__c> advisorsMap = new Map<String, Legal_Advisor__c>();
        for (Legal_Advisor__c oldAdvisor : oldAdvisorList) {
            advisorsMap.put(oldAdvisor.Account_Number__c, oldAdvisor);           
        }  

        for(Legal_Advisor__c advisor: advisorList){
            if (advisorsMap.get(advisor.Account_Number__c) != null) {
                System.debug('Entro en el if del mapa');
                advisor.Id = advisorsMap.get(advisor.Account_Number__c).Id;
                newAdvisorList.add(advisor);
            }else if(advisor.Account_Status__c=='Enabled'){
                newAdvisorList.add(advisor);
            }                         
        }

        upsert newAdvisorList; 
        }catch(Exception e){
            logErrors(e);
        }
        

    }


    //Insert Client Objects
    public static void insertClientObjects(List<Client__c> clientList){
        try{
            List<Client__c> oldClientList = [SELECT Legal_Advisor__r.Account_Number__c, Client_Number__c,  Created_From__c FROM Client__c WITH SECURITY_ENFORCED];
            List<Client__c> clientToDelete = new List<Client__c>();
            Map<String, Client__c> clientMap = new Map<String, Client__c>();
            List<String> idClientList = new List<String>();
            for(Client__c oldClient: oldClientList){
                String clientId = oldClient.Legal_Advisor__r.Account_Number__c + oldClient.Client_Number__c;
                clientMap.put(clientId, oldClient);
            }
            //
            for(Client__c client: clientList){
    
                String clientId = client.Legal_Advisor__r.Account_Number__c + client.Client_Number__c;
                //Me fijo si el cliente nuevo existe en la base de datos
                if(clientMap.get(clientId)!=null){
                    //Si existo le asigno el mismo id
                    client.Id = clientMap.get(clientId).Id;
                }
                    
            }     
            for(Client__c client: clientMap.values()){
                if(client.Created_From__c=='JSON'){
                    clientToDelete.add(client);
                }
            }
            delete clientToDelete;
            upsert clientList;  
        }catch(Exception e){
            logErrors(e);
        }

        
    }

    //Regist errors on Error objects
    public static void logErrors(Exception e){
        Error__c errorLog = new Error__c();
        errorLog.Date__c = Date.today();
        errorLog.Name = (e.getTypeName());
        errorLog.Message__c = (e.getMessage());
        sendEmail(e);
        Insert errorLog;
    }

    //Sending email
    public static void sendEmail(Exception e){
        //Get Administrator Email
        Profile sys_adm_profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' WITH SECURITY_ENFORCED];
        Id adminId = sys_adm_profile.Id;
        List<User> sys_admin = [SELECT Id, Email FROM User WHERE ProfileId =: adminId WITH SECURITY_ENFORCED];
        String adminEmail = sys_admin[0].Email;

        string[] mailAdress = new string[] {adminEmail};
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        mail.setToAddresses(mailAdress);
        mail.setSubject('Error Log');
        mail.setHtmlBody('Error Type: '+e.getTypeName()+' - '+e.getMessage());
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}
