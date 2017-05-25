/**************************************************************************************************
 * Name           : GS_TestOppLineItemUpdateProduct
 * Object         : OpportunityLineItem
 * Requirement    :
 * Target         : Test GS_OppLineItemUpdateProductTHandler
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-09-15
 * Modify History :
 **************************************************************************************************/

@isTest
private class GS_TestOppLineItemUpdateProduct {
	//IF IsNew() OR IsChanged( Account ), THEN Account = Opportunity Product.Opportunity.Account
	//IF IsNew() OR IsChanged( Product ), THEN Product = Opportunity Product.Product 
	//Salesforce does not allow lookup filters on the standard field
	static testMethod void oppLineItemUpdateProduct() {

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
		Product2 testProduct1 = GS_TestDataCreator.createProduct('TestProduct1', true, true);
        testProduct1.Revenue_Type__c = 'PROJ';
        update testProduct1;

		// createPriceBookEntry(Product2 product, Decimal unitPrice)
		PricebookEntry testPBEntry1 = GS_TestDataCreator.createPriceBookEntry(testProduct1, 100);

		// createOppLineItem(PricebookEntry priceEntry, Opportunity opp, String productTransactionType, Decimal acpv, Decimal tcpv, Decimal passThrough)
        OpportunityLineItem oppLineItem1 = GS_TestDataCreator.createOppLineItem(testPBEntry1, testOpp, 'New Business', 100, 200, 50, 'Yes', 'Analec');
		oppLineItem1.Product_Revenue_Type__c = 'PROJ';
        update oppLineItem1;
      
		OpportunityLineItem oppResult = [select Id,Product2Id, Product__c, Opportunity.AccountId, Account__c from OpportunityLineItem where OpportunityId =: testOpp.Id];
		
		//system.assertEquals(oppResult.Product__c, oppResult.Product2Id);
		//system.assertEquals(oppResult.Account__c, oppResult.Opportunity.AccountId);

		oppLineItem1.ACpV__c = 150;
		
		update oppLineItem1;
	}
}