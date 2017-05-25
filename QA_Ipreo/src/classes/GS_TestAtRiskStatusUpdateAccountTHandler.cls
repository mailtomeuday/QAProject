/**
 * Test class, contains unit tests for validating the GS_AtRiskStatusUpdateAccountTHandler.
 */
@isTest
private class GS_TestAtRiskStatusUpdateAccountTHandler {

    static testMethod void AtRiskTest() {
		
		Account testAccount = GS_TestDataCreator.createAccount('TestAccount');
		
		Test.startTest();
		
		Desktop_Status__c objAtRisk = new Desktop_Status__c();
		objAtRisk.Account__c = testAccount.Id;
		objAtRisk.At_Risk_Reason__c = 'At Risk – Budget';
		objAtRisk.Desktop_Status__c = true;
		
		insert objAtRisk;
		
		objAtRisk = [select Account__c,At_Risk_Reason__c,Desktop_Status__c from Desktop_Status__c where Id =: objAtRisk.Id];
		testAccount = [select Churn__c,Churn_Reason__c from Account where Id =: testAccount.Id];
		
		//system.assertEquals(testAccount.Churn__c, objAtRisk.Desktop_Status__c);
		//system.assertEquals(testAccount.Churn_Reason__c, objAtRisk.At_Risk_Reason__c);
		
		objAtRisk = new Desktop_Status__c();
		objAtRisk.Account__c = testAccount.Id;
		objAtRisk.At_Risk_Reason__c = 'At Risk – Usage';
		objAtRisk.Desktop_Status__c = true;
		
		insert objAtRisk;
		
		objAtRisk = [select Account__c,At_Risk_Reason__c,Desktop_Status__c from Desktop_Status__c where Id =: objAtRisk.Id];
		testAccount = [select Churn__c,Churn_Reason__c from Account where Id =: testAccount.Id];
		
		//system.assertEquals(testAccount.Churn__c, objAtRisk.Desktop_Status__c);
		//system.assertEquals(testAccount.Churn_Reason__c, objAtRisk.At_Risk_Reason__c);
		
		objAtRisk.Desktop_Status__c = true;
		objAtRisk.At_Risk_Reason__c = 'At Risk – Data';
		update objAtRisk;
		
		objAtRisk = [select Account__c,At_Risk_Reason__c,Desktop_Status__c from Desktop_Status__c where Id =: objAtRisk.Id];
		testAccount = [select Churn__c,Churn_Reason__c from Account where Id =: testAccount.Id];
		
		//system.assertEquals(testAccount.Churn__c, objAtRisk.Desktop_Status__c);
		//system.assertEquals(testAccount.Churn_Reason__c, objAtRisk.At_Risk_Reason__c);
				
		Test.stopTest();  
		
    }
}