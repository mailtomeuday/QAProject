@isTest
private class GS_TestCase {

	static testMethod void caseOne() {
    	
    	Follow_Rule_Setting__c testSetting1 = new Follow_Rule_Setting__c();
    	Follow_Rule_Setting__c testSetting2 = new Follow_Rule_Setting__c();
    	testSetting1.Name = 'Opportunity';
    	testSetting2.Name = 'OpportunityTeam';
    	testSetting1.isOpen__c = true;
    	testSetting2.isOpen__c = true;
    	insert testSetting1;	
    	insert testSetting2;

    	Account testAccount = GS_TestDataCreator.createAccount('TestAccount');
		Opportunity testOpp = GS_TestDataCreator.createOpportunity(testAccount, 'test opportunity', 'New_Business', 'Opportunity Identified', 'Subscription', '1 year', 'Tier 1');
		Contact testContact = GS_TestDataCreator.createContact('testA', testAccount);

	    Case testCase = new Case();
	    testCase.AccountId = testAccount.Id;
	    testCase.Opportunity__c = testOpp.Id;
	    testCase.ContactId = testContact.Id;
	    testCase.Status = 'New';
	    testCase.Priority = '2 - Medium';
	    testCase.Origin = 'Direct Email';
	    testCase.Type = 'Service Request';
	    testCase.Subject = 'Test Case Subject';
	    testcase.Description = 'Test Case Description';
	    insert testCase;

	    testCase.First_Response_Provided__c = true;
	    update testCase;
	}

	static testMethod void caseTwo() {
    	
    	Follow_Rule_Setting__c testSetting1 = new Follow_Rule_Setting__c();
    	Follow_Rule_Setting__c testSetting2 = new Follow_Rule_Setting__c();
    	testSetting1.Name = 'Opportunity';
    	testSetting2.Name = 'OpportunityTeam';
    	testSetting1.isOpen__c = true;
    	testSetting2.isOpen__c = true;
    	insert testSetting1;	
    	insert testSetting2;

    	Account testAccount = GS_TestDataCreator.createAccount('TestAccount');
		Opportunity testOpp = GS_TestDataCreator.createOpportunity(testAccount, 'test opportunity', 'New_Business', 'Opportunity Identified', 'Subscription', '1 year', 'Tier 1');
		Contact testContact = GS_TestDataCreator.createContact('testA', testAccount);

	    Case testCase = new Case();
	    testCase.AccountId = testAccount.Id;
	    testCase.Opportunity__c = testOpp.Id;
	    testCase.ContactId = testContact.Id;
	    testCase.Status = 'New';
	    testCase.Priority = '2 - Medium';
	    testCase.Origin = 'Direct Email';
	    testCase.Type = 'Service Request';
	    testCase.Subject = 'Test Case Subject';
	    testcase.Description = 'Test Case Description';
	    testCase.Sub_Type__c = 'Trial Access Request';
	    testcase.Trial_Start_Date__c = Datetime.now().date();
	    testCase.Trial_End_Date__c = Datetime.now().date().addDays(1);
	    insert testCase;
	}
}