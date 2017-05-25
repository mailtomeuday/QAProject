@isTest
private class GS_TestAttachmentCalNumberTHandler {
    static testMethod void TestAttachmentCalNumberTHandler() {

    	Account testAccount1 = GS_TestDataCreator.createAccount('TestAccount','Buyside','Tier 1');
        Contract__c testContract = new Contract__c(
        								Name = 'Test Contract',
        								Account__c = testAccount1.Id,
        								Contract_Type__c = 'Renewal',
        								Status__c = 'Pending');
        insert testContract;

        Attachment testAttachment = GS_TestDataCreator.createAttachment(testContract, 'Test Attachment', false, 'Test Attachment Contents');

        List<Contract__c> lstConResult = [select Id,No_of_Attachments__c from Contract__c where Id = :testContract.Id];
        if(lstConResult.size() > 0)
        {
        	System.assertEquals(1, lstConResult[0].No_of_Attachments__c);
        }

        delete testAttachment;
        List<Contract__c> lstConResult2 = [select Id,No_of_Attachments__c from Contract__c where Id = :testContract.Id];
        if(lstConResult2.size() > 0)
        {
        	System.assertEquals(0, lstConResult2[0].No_of_Attachments__c);
        }
    }
}