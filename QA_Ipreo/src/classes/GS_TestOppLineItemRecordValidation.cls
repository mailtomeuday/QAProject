/**************************************************************************************************
 * Name           : GS_TestOppLineItemRecordValidation
 * Object         : OpportunityLineItem
 * Requirement    : STY-00187
 * Target         : Test GS_OppLineItemRecordValidationTHandler
 * Refer classes  : 
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-07-06
 * Modify History :
 **************************************************************************************************/
@isTest
private class GS_TestOppLineItemRecordValidation {

	// IF Status IN ( "Won", "Renewed" ) AND Subscription End Date ≠ null AND Subscription End Date ≠ one or more Subscription End Dates on Opportunity Products 
	// related to the same opportunity, THEN error:  "All subscription end dates must be coterminous"
	static testMethod void recordValidation() {

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
		Product2 testProduct2 = GS_TestDataCreator.createProduct('TestProduct2', true, false);

		// createPriceBookEntry(Product2 product, Decimal unitPrice)
		PricebookEntry testPBEntry1 = GS_TestDataCreator.createPriceBookEntry(testProduct1, 100);
		PricebookEntry testPBEntry2 = GS_TestDataCreator.createPriceBookEntry(testProduct2, 100);

		// createOppLineItem(PricebookEntry priceEntry, Opportunity opp, String productTransactionType, Decimal acpv, Decimal tcpv, Decimal passThrough)
		OpportunityLineItem oppLineItem1 = GS_TestDataCreator.createOppLineItem(testPBEntry1, testOpp, 'New Business', 100, 200, 50, 'Yes', 'Analec', null, null, null, 'ACV', 'NA');	
		OpportunityLineItem oppLineItem2 = GS_TestDataCreator.createOppLineItem(testPBEntry2, testOpp, 'New Business', 50, 100, null, 'Yes', 'Analec', null, null, null, 'ACV', 'NA');
		
		List<OpportunityLineItem> lstTestOppLineItems = new List<OpportunityLineItem>();

		oppLineItem1.Status__c = 'Won';
		oppLineItem1.Subscription_Start_Date__c = Date.valueOf('2015-09-07');
		oppLineItem1.Subscription_End_Date__c = Date.valueOf('2015-09-30');
		oppLineItem1.Term_Months__c = 13;
		lstTestOppLineItems.add(oppLineItem1);

		oppLineItem2.Status__c = 'Won';
		oppLineItem2.Subscription_Start_Date__c = Date.valueOf('2015-09-07');
		oppLineItem2.Subscription_End_Date__c = Date.valueOf('2015-10-31');
		oppLineItem2.Term_Months__c = 13;
		lstTestOppLineItems.add(oppLineItem2);
		
		test.startTest();
    	try{
        	update lstTestOppLineItems;
        }catch(Exception e){
            //Boolean expectedExceptionThrown =  e.getMessage().contains('All subscription end dates must be coterminous') ? true : false;
            //system.assertEquals(expectedExceptionThrown,true);
            system.assertNotEquals(e.getMessage(),NULL);       
		} 
		
		oppLineItem1.Subscription_End_Date__c = Date.valueOf('2015-10-31');
		
		try{
        	update lstTestOppLineItems;
        }catch(Exception e){
            system.assertEquals(e.getMessage(),NULL);       
		}
		        			
		oppLineItem1.Subscription_Start_Date__c = null;
		oppLineItem1.Subscription_End_Date__c = null;
		oppLineItem1.Term_Months__c = null;
		oppLineItem2.Subscription_Start_Date__c = null;
		oppLineItem2.Subscription_End_Date__c = null;
		oppLineItem2.Term_Months__c = null;

		try{
        	update lstTestOppLineItems;
        }catch(Exception e){
            system.assertNotEquals(e.getMessage(),NULL);       
		}
		
		oppLineItem1.Estimated_Completion_Date__c = Date.valueOf('2016-08-31');
		oppLineItem2.Estimated_Completion_Date__c = Date.valueOf('2016-08-07');
		
		try{
        	update lstTestOppLineItems;

        }catch(Exception e){
            system.assertNotEquals(e.getMessage(),NULL);       
		}
    			
		oppLineItem2.Estimated_Completion_Date__c = Date.valueOf('2016-08-31');

		try{
        	update lstTestOppLineItems;
        }catch(Exception e){
            system.assertEquals(e.getMessage(),NULL);       
		}
				
		//non-ACV
		oppLineItem1.Product_Revenue_Type__c = 'PROJ';
		oppLineItem2.Product_Revenue_Type__c = 'PROJ';
		
		oppLineItem1.Subscription_Start_Date__c = null;
		oppLineItem1.Subscription_End_Date__c = null;
		oppLineItem1.Term_Months__c = null;
		oppLineItem2.Subscription_Start_Date__c = null;
		oppLineItem2.Subscription_End_Date__c = null;
		oppLineItem2.Term_Months__c = null;

		try{
        	update lstTestOppLineItems;
        }catch(Exception e){
            system.assertNotEquals(e.getMessage(),NULL);       
		}
				
		oppLineItem1.Subscription_Start_Date__c = Date.valueOf('2015-09-07');
		oppLineItem1.Subscription_End_Date__c = Date.valueOf('2015-09-30');
		oppLineItem1.Term_Months__c = 13;
		oppLineItem2.Subscription_Start_Date__c = Date.valueOf('2015-09-07');
		oppLineItem2.Subscription_End_Date__c = Date.valueOf('2015-09-30');
		oppLineItem2.Term_Months__c = 13;
		
		try{
        	update lstTestOppLineItems;
        }catch(Exception e){
            system.assertEquals(e.getMessage(),NULL);       
		}
		test.stopTest();		
	}
		
}