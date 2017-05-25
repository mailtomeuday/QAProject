/**************************************************************************************************
 * Name           : GS_TestLeadUpdateFromEDDScheduleJob
 * Object         : 
 * Requirement    : 
 * Target         : TestClass for LeadUpdateFromEDDScheduleJob
 * Refer classes  :
 * Author         : Katherine Chen
 * Create Date    : 2016-04-12
 * Modify History :
 **************************************************************************************************/
@isTest
private class GS_TestLeadUpdateFromEDDScheduleJob {
    @isTest static void testUpdateLead() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new GS_MockHttpResponseForUpdate());
        
        HttpResponse res = GS_EDDDataCallOutUtility.getResponseFromEDD('salesforce@ipreo','Fourier2016','https://davos.app.ipreo.com/public/rest/api/internal/salesforce/UpdateLeadsV2.svc/?$format=json&IssueId=[1111123,1111124,1111125,1111126]');
        
        Lead testLead1 = createLead(123123,1111123, 'Test Company1', 'USD', 'New');
        Lead testLead2 = createLead(123124,1111124, 'Test Company2', 'USD', 'New');
        Lead testLead3 = createLead(123125,1111125, 'Test Company3', 'USD', 'New');
        Lead testLead4 = createLead(123126,1111126, 'Test Company4', 'USD', 'New');

        Country_List__c coutL1 = new Country_List__c();
        coutL1.Name = 'India';
        insert coutL1;

        // Verify response received contains fake values
        Test.startTest();

		// Schedule the test job
		String jobId = System.schedule('Test LeadUpdateFromEDD Schedule','0 0 0 3 9 ? 2022', new GS_LeadUpdateFromEDDScheduleJob());

		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
		                  NextFireTime
		                  FROM CronTrigger WHERE id = :jobId];

		// Verify the expressions are the same
		System.assertEquals('0 0 0 3 9 ? 2022',ct.CronExpression);

		// Verify the job has not run
		System.assertEquals(0, ct.TimesTriggered);

		// Verify the next time the job will run
		System.assertEquals('2022-09-03 00:00:00',String.valueOf(ct.NextFireTime));


		Test.stopTest();
    }

    private static Lead createLead(Integer id, Integer issueId, String issuer_nm,  String currencyCode, String status) {
        Lead testLead = new Lead();
        testLead.Ipreo_BDSF_1_10__BDCompanyId__c = id;
        testLead.Issue_id__c = issueId;
        testLead.Company = issuer_nm;
        testLead.LastName = issuer_nm;
        testLead.CurrencyIsoCode = currencyCode;
        testLead.Status = status;
        insert testLead;
        return testLead;
    }
}