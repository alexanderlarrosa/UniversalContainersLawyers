public with sharing class ucl_ConexionData {
    public static HttpResponse getConexionData() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://altimetrik-bootcamp.herokuapp.com/LegalAccounts');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200) {
            //List<Legal_Advisor__c> listLegalAdvisor = (List<Legal_Advisor__c>)JSON.deserialize(response.getBody(),List<Legal_Advisor__c>.class);
            // Deserialize the JSON string into collections of primitive data types.
            //List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody());
            //
            /*
            try{
                List<Legal_Advisor__c> listLegalAdvisor = (List<Legal_Advisor__c>)JSON.deserialize(response.getBody(),List<Legal_Advisor__c>.class);
            }catch(Exception e){
                System.debug('Error '+e.getCause());
                System.debug('Error '+e.getMessage());
            }

            */
            /*
            for(Object obj:results){
                Legal_Advisor__c legalAdvisor = New Legal_Advisor__c();
                Decimal n = (Decimal)JSON.deserialize('100.1', Decimal.class);
                //legalAdvisor = (Legal_Advisor__c)JSON.deserialize(obj, Legal_Advisor__c.class);
                //legalAdvisor = obj;
                System.debug('OBJ '+obj.get('AccountName');
            }
			*/
            
            
            //List<Legal_Advisor__c> listLegalAdvisor = (List<Legal_Advisor__c>)JSON.deserialize(response.getBody(),List<Legal_Advisor__c>.class);
			
            List<Object> legalAdvisorList = (List<Object>) JSON.deserializeUntyped(response.getBody());
            /*
			Map<String,Object> aux = (Map<String,Object>) legalAdvisorList[0];  
            System.debug();
            List<Object> clientList = (List<Object>) aux.get('Clients');
			*/
             
            List<Legal_Advisor__c> newLegalAdvisorList = new List<Legal_Advisor__c>();
            List<Client__c> newClientsList = new List<Client__c>();
            /*
            for(Object advisor:legalAdvisorList){
                Map<String,Object> legalAdvisorData = (Map<String,Object>) advisor;   
                Legal_Advisor__c legalAdvisor = new Legal_Advisor__c();
                //System.debug(legalAdvisorData.get('AccountNumber'));
                legalAdvisor.Account_Number__c = (String) legalAdvisorData.get('AccountNumber');
                legalAdvisor.Name = (String) legalAdvisorData.get('AccountName');
                legalAdvisor.Account_Status__c = (String) legalAdvisorData.get('AccountStatus');
                legalAdvisor.As_of_Date__c = date.today();
                List<Object> clientList = (List<Object>) legalAdvisorData.get('Clients');
                newLegalAdvisorList.add(legalAdvisor);
                for(Object client:clientList){
                    Map<String,Object> clientData = (Map<String,Object>) client;
                    Client__c newClient = new Client__c();
                    newClient.Name = (String) clientData.get('FirstName');
                    newClient.Last_Name__c = (String) clientData.get('LastName');
                    newClient.Email__c = (String) clientData.get('Email');
                    newClient.Phone__c = (String) clientData.get('Phone');
                    newClient.Address__c = (String) clientData.get('Address');
                    newClient.Client_Number__c = (String) clientData.get('ClientNumber');
                    newClient.Legal_Advisor__c = legalAdvisor.Id;
                    newClientsList.add(newClient);
                }                               
            }
            */
            Integer cont =1;
            for(Object advisor:legalAdvisorList){
                
                System.debug('Tamaño lista '+legalAdvisorList.size());
                System.debug('Entro en el for '+cont);
                cont++;
                Map<String,Object> legalAdvisorData = (Map<String,Object>) advisor;   
                Legal_Advisor__c legalAdvisor = new Legal_Advisor__c();
                //System.debug(legalAdvisorData.get('AccountNumber'));
                legalAdvisor.Account_Number__c = (String) legalAdvisorData.get('AccountNumber');
                legalAdvisor.Name = (String) legalAdvisorData.get('AccountName');
                legalAdvisor.Account_Status__c = (String) legalAdvisorData.get('AccountStatus');
                //String fecha = '6/12/2019';
                String auxDate =  (String) legalAdvisorData.get('AsOfDate');           
                List<String> asOfDate = auxDate.split('/');
                System.debug('Fecha proporcionada: '+auxdate);
                //System.debug(asOfDate[2]+'/'+asOfDate[0]+'/'+asOfDate[1]);
                Date d = date.parse((String) legalAdvisorData.get('AsOfDate'));
                System.debug(d);
                System.debug('TOday '+date.today());
                legalAdvisor.As_of_Date__c = d;
                //legalAdvisor.As_of_Date__c = date.parse(asOfDate[2]+'/'+asOfDate[0]+'/'+asOfDate[1]);                
                //(String) legalAdvisorData.get('AsOfDate') date.parse(asOfDate);
                List<Object> clientList = (List<Object>) legalAdvisorData.get('Clients');
                newLegalAdvisorList.add(legalAdvisor);                                            
            }
            
            insert newLegalAdvisorList;
            
            for(integer i=0; i<legalAdvisorList.size();i++){
                Map<String,Object> legalAdvisorData = (Map<String,Object>) legalAdvisorList[i];   
                List<Object> clientList = (List<Object>) legalAdvisorData.get('Clients');
                for(Object client:clientList){
                    Map<String,Object> clientData = (Map<String,Object>) client;
                    Client__c newClient = new Client__c();
                    newClient.Name = (String) clientData.get('FirstName');
                    newClient.Last_Name__c = (String) clientData.get('LastName');
                    newClient.Email__c = (String) clientData.get('Email');
                    newClient.Phone__c = (String) clientData.get('Phone');
                    newClient.Address__c = (String) clientData.get('Address');
                    newClient.Client_Number__c = (String) clientData.get('ClientNumber');
                    newClient.Legal_Advisor__c = newLegalAdvisorList[i].Id;
                    newClientsList.add(newClient);
                }                               
            }
           
            
            
        	insert newClientsList;
        }
        
        return response;
    }
}