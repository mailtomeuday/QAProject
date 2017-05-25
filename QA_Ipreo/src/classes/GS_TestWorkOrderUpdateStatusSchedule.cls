/**************************************************************************************************
 * Name           : GS_TestWorkOrderUpdateStatusSchedule
 * Object         : Work_Order__c
 * Requirement    : STY-00012
 * Target         : Test WorkOrderUpdateActiveStatusSchedule
 * Refer classes  : 
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-06-03
 * Modify History :
 **************************************************************************************************/
@isTest
private class GS_TestWorkOrderUpdateStatusSchedule {
	
	static testMethod void runSchedule() {

    	Follow_Rule_Setting__c testSetting1 = new Follow_Rule_Setting__c();
    	Follow_Rule_Setting__c testSetting2 = new Follow_Rule_Setting__c();
    	testSetting1.Name = 'Opportunity';
    	testSetting2.Name = 'OpportunityTeam';
    	testSetting1.isOpen__c = true;
    	testSetting2.isOpen__c = true;
    	insert testSetting1;	
    	insert testSetting2;

		Account testAccount = GS_TestDataCreator.createAccount('TestAccount');
		Contact testContact = GS_TestDataCreator.createContact('TestContact', testAccount);
		Product2 testProduct = GS_TestDataCreator.createProduct('TestProduct', true, false);
		Asset testAsset = GS_TestDataCreator.createAsset(testAccount, 'TestAsset', testProduct, 'NA');

		// Active Work Order
		Work_Order__c testWO = GS_TestDataCreator.createWorkOrder(testAccount, 'Analytics', 'TestActiveWorkOrder', Date.valueOf(Datetime.now()));
		// Inactive Work Order
		Work_Order__c testActiveWO = GS_TestDataCreator.createWorkOrder(testAccount, 'Analytics', 'TestInactiveWorkOrder', date.newInstance(2000, 1, 1));
		// Active asset
		Asset_License__c testActiveLicense = GS_TestDataCreator.createLicense(testAsset, date.newInstance(1900, 1, 1), date.newInstance(2500, 1, 1));
		// Inactive asset
		Asset_License__c testInactiveLicense = GS_TestDataCreator.createLicense(testAsset, date.newInstance(1900, 1, 1), date.newInstance(2000, 1, 1));

		Test.startTest();

		// Schedule the test job

		String jobId = System.schedule('Test Account Status Schedule',
		                               '0 0 0 3 9 ? 2022',
		                               new GS_UpdateActiveStatusSchedule());

		// Get the information from the CronTrigger API object
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
		                  NextFireTime
		                  FROM CronTrigger WHERE id = :jobId];

		// Verify the expressions are the same
		System.assertEquals('0 0 0 3 9 ? 2022',
		                    ct.CronExpression);

		// Verify the job has not run
		System.assertEquals(0, ct.TimesTriggered);

		// Verify the next time the job will run
		System.assertEquals('2022-09-03 00:00:00',
		                    String.valueOf(ct.NextFireTime));

		Database.executeBatch(new GS_LicenseUpdateStatusBatch(), 200);
		Test.stopTest();
	}
}