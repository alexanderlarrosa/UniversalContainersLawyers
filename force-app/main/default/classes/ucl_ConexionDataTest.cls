@isTest
private class ucl_ConexionDataTest {
    @isTest static void testGetConexionData(){
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetDataResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);
        // Call method to test
        HttpResponse result = ucl_ConexionData.getConexionData();
        
        //Call method
        boolean conexionStatus = ucl_ConexionData.dataToObject();
        System.assert(conexionStatus);
        // Verify mock response is not null
        System.assertNotEquals(null,result, 'The callout returned a null response.');
        // Verify status code
        System.assertEquals(200,result.getStatusCode(), 'The status code is not 200.');
        // Verify content type   
        System.assertEquals('application/json;charset=UTF-8',
          result.getHeader('Content-Type'),
          'The content type value is not expected.');  
        List<Legal_Advisor__c> advisorList = [SELECT Account_Number__c FROM Legal_Advisor__c LIMIT 1];
        for(Legal_Advisor__c advisor:advisorList){
            String acutalAccountNumber = advisor.Account_Number__c;
            String expectedAccountNumber = 'a209ebbb-39c6-4852-8732-82237c0674fb';
            System.assertEquals(expectedAccountNumber, acutalAccountNumber);
        }
        
        List<Client__c> clientList = [SELECT Client_Number__c FROM Client__c LIMIT 1];
        System.debug('Tamaño lista '+clientList.size());
        for(Client__c client: clientList){
            String actualClientNumber='12afa152-8115-492b-bb49-87399ab49af8';
            String expectedClientNumber = client.Client_Number__c;
            System.assertEquals(expectedClientNumber, actualClientNumber);
        }
        
        
    }
    
    
    
   
}