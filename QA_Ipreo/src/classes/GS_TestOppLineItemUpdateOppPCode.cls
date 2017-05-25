/**************************************************************************************************
 * Name           : GS_TestOppLineItemUpdateOppPCode
 * Object         : OpportunityLineItem
 * Requirement    : STY-00201
 * Target         : Test GS_OppLineItemUpdateOppPCodeTHander
 * Refer classes  : 
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-07-06
 * Modify History :
 **************************************************************************************************/

@isTest
private class GS_TestOppLineItemUpdateOppPCode {
	//IF Opportunity.Record Type = "New Business", 
	//THEN Update Opportunity.Bundled field to concatenate Opportunity Product.Product.Product Code with "_" between each code 
	static testMethod void updateOppPCode() {

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
		
		// createProduct(String name, Boolean isAsset, Boolean requiredPassThrough)
		Product2 testProduct1 = GS_TestDataCreator.createProduct('TestProduct1', true, true,'TEST1','PROJ','Buyside');
		Product2 testProduct2 = GS_TestDataCreator.createProduct('TestProduct2', true, false,'TEST2','PROJ','Buyside');
		Product2 testProduct3 = GS_TestDataCreator.createProduct('TestProduct3', true, false,'TEST3','PROJ','Buyside');

		// createPriceBookEntry(Product2 product, Decimal unitPrice)
		PricebookEntry testPBEntry1 = GS_TestDataCreator.createPriceBookEntry(testProduct1, 100);
		PricebookEntry testPBEntry2 = GS_TestDataCreator.createPriceBookEntry(testProduct2, 100);
		PricebookEntry testPBEntry3 = GS_TestDataCreator.createPriceBookEntry(testProduct3, 100);

		// createOppLineItem(PricebookEntry priceEntry, Opportunity opp, String productTransactionType, Decimal acpv, Decimal tcpv, Decimal passThrough)
		OpportunityLineItem oppLineItem1 = GS_TestDataCreator.createOppLineItem(testPBEntry1, testOpp, 'New Business', 100, 200, 50, 'Yes', 'Analec');		
		OpportunityLineItem oppLineItem2 = GS_TestDataCreator.createOppLineItem(testPBEntry2, testOpp, 'New Business', 50, 100, null, 'Yes', 'Analec');
		OpportunityLineItem oppLineItem3 = GS_TestDataCreator.createOppLineItem(testPBEntry3, testOpp, 'New Business', 50, 100, null, 'Yes', 'Analec');

		List<OpportunityLineItem> lstTestOppLineItems = new List<OpportunityLineItem>();

		lstTestOppLineItems.add(oppLineItem1);
		lstTestOppLineItems.add(oppLineItem2);
		lstTestOppLineItems.add(oppLineItem3);

		update lstTestOppLineItems;  

		Test.startTest();  
		delete lstTestOppLineItems[1];

		Opportunity oppResult = [select Id, Product_Bundle__c from Opportunity where Id =: testOpp.Id];
		//System.assertEquals('TEST1_TEST3', oppResult.Product_Bundle__c);
		Test.stopTest();
	}
}