/**
 * Test class, contains unit tests for validating the MassUpdateCases.
 */
@isTest
private class GS_TestMassUpdateCases {

	
    static testMethod void massUpdateTest() {
        Account testAccount = GS_TestDataCreator.createAccount('TestAccount');
        
        list<Case> lstSelectedCases = new list<Case>();
 		       
        Case testCase1 = GS_TestDataCreator.createcase(testAccount.Id,'New','2 - Medium','Email2Case','Service Request','Training Request','Test Case 1','Test Case 1 Description',UserInfo.getUserId());
        lstSelectedCases.add(testCase1);
        Case testCase2 = GS_TestDataCreator.createcase(testAccount.Id,'New','2 - Medium','Email2Case','Service Request','Training Request','Test Case 2 - Ipreo Identity Verification','Test Case 2 Description',UserInfo.getUserId());
        lstSelectedCases.add(testCase2);
        Case testCase3 = GS_TestDataCreator.createcase(testAccount.Id,'New','2 - Medium','Email2Case','Access Management','Trial Access Request','Test Case 3','Test Case 3 Description',UserInfo.getUserId());
        lstSelectedCases.add(testCase3);
		
		Test.startTest();
		Test.setCurrentPage(Page.GS_MassUpdateCases);
		
		ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstSelectedCases);
		stdSetController.setSelected(lstSelectedCases);
		
		GS_MassUpdateCases objMassUpdatecls = new GS_MassUpdateCases(stdSetController);
		Integer count = objMassUpdatecls.getRecordsSize();
		system.assertEquals(count, 3);		
		Test.stopTest();
		
    }
}