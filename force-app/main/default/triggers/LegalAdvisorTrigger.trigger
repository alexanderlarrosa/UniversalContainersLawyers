trigger LegalAdvisorTrigger on Legal_Advisor__c (after delete) {
	
	
	if(Trigger.isDelete){
		ucl_LegalAdvisorTriggerHandler.deleteRelatedClients(Trigger.Old);
	}
	
	
}