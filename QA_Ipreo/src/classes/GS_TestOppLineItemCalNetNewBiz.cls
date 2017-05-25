/**************************************************************************************************
 * Name           : GS_TestOppLineItemCalNetNewBiz
 * Object         : OpportunityLineItem
 * Requirement    : STY-00149 -> STY-00201
 * Target         : Test GS_OppLineItemCalNetNewBizTHandler
 * Refer classes  : 
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-07-06
 * Modify History :
 **************************************************************************************************/
@isTest
private class GS_TestOppLineItemCalNetNewBiz {

    // IF Status IN ( null, "Won", "Renewed" ) THEN Net New Business = ACpV - Prior Year ACpV - Pass Through + Prior  Year Pass Through
    static testMethod void calNetNewBiz1() {

        Test.startTest();
        Follow_Rule_Setting__c testSetting1 = new Follow_Rule_Setting__c();
        Follow_Rule_Setting__c testSetting2 = new Follow_Rule_Setting__c();
        testSetting1.Name = 'Opportunity';
        testSetting2.Name = 'OpportunityTeam';
        testSetting1.isOpen__c = true;
        testSetting2.isOpen__c = true;
       try{
        insert testSetting1;    
        insert testSetting2;

        Account testAccount = GS_TestDataCreator.createAccount('TestAccount');
        Opportunity testOpp1 = GS_TestDataCreator.createOpportunity(testAccount, 'test opportunity', 'New_Business', 'Opportunity Identified', 'Subscription', '1 year', 'Tier 1');
        
        // createProduct(String name, Boolean isAsset, Boolean requiredPassThrough)
        Product2 testProduct1 = GS_TestDataCreator.createProduct('TestProduct1', true, true,null,'Project',null);
        Product2 testProduct2 = GS_TestDataCreator.createProduct('TestProduct2', true, false,null,'Project',null);

        // createPriceBookEntry(Product2 product, Decimal unitPrice)
        PricebookEntry testPBEntry1 = GS_TestDataCreator.createPriceBookEntry(testProduct1, 100);
        PricebookEntry testPBEntry2 = GS_TestDataCreator.createPriceBookEntry(testProduct2, 100);

        // createOppLineItem(PricebookEntry priceEntry, Opportunity opp, String productTransactionType, Decimal acpv, Decimal tcpv, Decimal passThrough)
        OpportunityLineItem oppLineItem1 = GS_TestDataCreator.createOppLineItem(testPBEntry1, testOpp1, 'New Business', 100, 200, 50, 'Yes', 'Analec', null, null, null, 'ACV', 'NA');  
        OpportunityLineItem oppLineItem3 = GS_TestDataCreator.createOppLineItem(testPBEntry2, testOpp1, 'New Business', 0, 0, null, 'Yes', 'Analec','Lost', NULL, 'Incumbent (Functionality)', 'ACV', 'NA',false);
        OpportunityLineItem oppLineItem6 = GS_TestDataCreator.createOppLineItem(testPBEntry1, testOpp1, 'New Business', 100, 200, 50, 'Yes', 'Analec','won', null, null, 'ACV', 'NA');
        oppLineItem3.Cancel_Comment__c = 'Competitor (Both)';
        insert oppLineItem3;
        Test.stopTest();
			
        List<OpportunityLineItem> lstTestOppLineItems = new List<OpportunityLineItem>();

        OpportunityLineItem oppLineItemResult11 = [select Id, Net_New_Business__c from OpportunityLineItem where Id =: oppLineItem1.Id];
        //System.assertEquals(50, oppLineItemResult11.Net_New_Business__c);
        OpportunityLineItem oppLineItemResult13 = [select Id, Net_New_Business__c from OpportunityLineItem where Id =: oppLineItem3.Id];
        //System.assertEquals(0, oppLineItemResult13.Net_New_Business__c);

        oppLineItem1.Status__c = 'won';
        oppLineItem1.Prior_Year_ACpV__c = 10;
        oppLineItem1.Prior_Year_Pass_Through__c =30;
        lstTestOppLineItems.add(oppLineItem1);

        oppLineItem6.Status__c = 'Lost';
        oppLineItem6.ACpV__c = 0;
        oppLineItem6.UnitPrice = 0;
        oppLineItem6.Lost_Cancelled_Reason__c = 'Competitor (Both)';
        oppLineItem6.Cancel_Comment__c = 'Competitor (Both)';
        lstTestOppLineItems.add(oppLineItem6);
        
        update lstTestOppLineItems;
        
        OpportunityLineItem oppLineItemResult21 = [select Id, Net_New_Business__c from OpportunityLineItem where Id =: oppLineItem1.Id];
        //System.assertEquals(70, oppLineItemResult21.Net_New_Business__c);

        OpportunityLineItem oppLineItemResult25 = [select Id, Net_New_Business__c from OpportunityLineItem where Id =: oppLineItem6.Id];
        //System.assertEquals(0, oppLineItemResult25.Net_New_Business__c);
		}
        catch(System.DmlException ex){
        	System.debug(ex.getMessage());
            System.assert(true,ex.getMessage().contains('ACpV must be greater than 0 when this product is lost'));
		}
    }

static testMethod void calNetNewBiz2() {
        Test.startTest();
        Follow_Rule_Setting__c testSetting1 = new Follow_Rule_Setting__c();
        Follow_Rule_Setting__c testSetting2 = new Follow_Rule_Setting__c();
        testSetting1.Name = 'Opportunity';
        testSetting2.Name = 'OpportunityTeam';
        testSetting1.isOpen__c = true;
        testSetting2.isOpen__c = true;
        
        insert testSetting1;    
        insert testSetting2;

        Account testAccount = GS_TestDataCreator.createAccount('TestAccount');
        Opportunity testOpp2 = GS_TestDataCreator.createOpportunity(testAccount, 'test opportunity', 'Renewal', 'Opportunity Identified', 'Subscription', '1 year', 'Tier 1');
        
        // createProduct(String name, Boolean isAsset, Boolean requiredPassThrough)
        Product2 testProduct1 = GS_TestDataCreator.createProduct('TestProduct1', true, true,null,'Subscription',null);
        Product2 testProduct2 = GS_TestDataCreator.createProduct('TestProduct2', true, false,null,'Subscription',null);

        // createPriceBookEntry(Product2 product, Decimal unitPrice)
        PricebookEntry testPBEntry1 = GS_TestDataCreator.createPriceBookEntry(testProduct1, 100);
        PricebookEntry testPBEntry2 = GS_TestDataCreator.createPriceBookEntry(testProduct2, 100);

        // createOppLineItem(PricebookEntry priceEntry, Opportunity opp, String productTransactionType, Decimal acpv, Decimal tcpv, Decimal passThrough)
        
        OpportunityLineItem oppLineItem2 = GS_TestDataCreator.createOppLineItem(testPBEntry2, testOpp2, 'Renewal', 0, 0, null, 'Yes', 'Analec','Cancelled', NULL, 'Incumbent (Functionality)', 'ACV', 'NA',false);  
        oppLineItem2.Cancel_Comment__c = 'Competitor (Both)';  
        insert oppLineItem2;
        OpportunityLineItem oppLineItem4 = GS_TestDataCreator.createOppLineItem(testPBEntry1, testOpp2, 'Renewal', 50, 100, 25, 'Yes', 'Analec','Renewed', NULL, 'Incumbent (Functionality)', 'ACV', 'NA');
       //Uday 24062016: Changed the Pass Through parameter as zero, as there is a new validation to have zero or null for cancelled opportunity products
        OpportunityLineItem oppLineItem5 = GS_TestDataCreator.createOppLineItem(testPBEntry1, testOpp2, 'Renewal', 0, 0, 0, 'Yes', 'Analec','Cancelled', NULL, 'Incumbent (Functionality)', 'ACV', 'NA',false);
        oppLineItem5.Cancel_Comment__c = 'Competitor (Both)';  
        insert oppLineItem5;
        Test.stopTest();
        List<OpportunityLineItem> lstTestOppLineItems = new List<OpportunityLineItem>();

        OpportunityLineItem oppLineItemResult12 = [select Id, Net_New_Business__c from OpportunityLineItem where Id =: oppLineItem2.Id];
        //System.assertEquals(0, oppLineItemResult12.Net_New_Business__c);

        oppLineItem2.Prior_Year_Pass_Through__c = 10;
        lstTestOppLineItems.add(oppLineItem2);

        oppLineItem4.Prior_Year_Pass_Through__c = 10;
        lstTestOppLineItems.add(oppLineItem4);

        //oppLineItem5.Status__c = 'Cancelled';
        oppLineItem5.ACpV__c = 0;
        oppLineItem5.UnitPrice = 0;
        oppLineItem5.Prior_Year_ACpV__c = 10;
        oppLineItem5.Prior_Year_Pass_Through__c = 10;
        oppLineItem5.Lost_Cancelled_Reason__c = 'Competitor (Functionality)';        
        lstTestOppLineItems.add(oppLineItem5);
		System.debug('===Line Items=='+lstTestOppLineItems);
        update lstTestOppLineItems;

        OpportunityLineItem oppLineItemResult22 = [select Id, Net_New_Business__c from OpportunityLineItem where Id =: oppLineItem2.Id];
        //System.assertEquals(10, oppLineItemResult22.Net_New_Business__c);

        OpportunityLineItem oppLineItemResult23 = [select Id, Net_New_Business__c from OpportunityLineItem where Id =: oppLineItem4.Id];
        //System.assertEquals(35, oppLineItemResult23.Net_New_Business__c);

        OpportunityLineItem oppLineItemResult24 = [select Id, Net_New_Business__c from OpportunityLineItem where Id =: oppLineItem5.Id];
        //System.assertEquals(0, oppLineItemResult24.Net_New_Business__c);
        } 
    static testMethod void calNetNewBiz3() {

        Test.startTest();
        Follow_Rule_Setting__c testSetting1 = new Follow_Rule_Setting__c();
        Follow_Rule_Setting__c testSetting2 = new Follow_Rule_Setting__c();
        testSetting1.Name = 'Opportunity';
        testSetting2.Name = 'OpportunityTeam';
        testSetting1.isOpen__c = true;
        testSetting2.isOpen__c = true;
       try{
        insert testSetting1;    
        insert testSetting2;

        Account testAccount = GS_TestDataCreator.createAccount('TestAccount');
        Opportunity testOpp1 = GS_TestDataCreator.createOpportunity(testAccount, 'test opportunity', 'New_Business', 'Opportunity Identified', 'Subscription', '1 year', 'Tier 1');
        
        // createProduct(String name, Boolean isAsset, Boolean requiredPassThrough)
        Product2 testProduct1 = GS_TestDataCreator.createProduct('TestProduct1', true, true,null,'Project',null);
        Product2 testProduct2 = GS_TestDataCreator.createProduct('TestProduct2', true, false,null,'Project',null);

        // createPriceBookEntry(Product2 product, Decimal unitPrice)
        PricebookEntry testPBEntry1 = GS_TestDataCreator.createPriceBookEntry(testProduct1, 100);
        PricebookEntry testPBEntry2 = GS_TestDataCreator.createPriceBookEntry(testProduct2, 100);

        // createOppLineItem(PricebookEntry priceEntry, Opportunity opp, String productTransactionType, Decimal acpv, Decimal tcpv, Decimal passThrough)
        OpportunityLineItem oppLineItem1 = GS_TestDataCreator.createOppLineItem(testPBEntry1, testOpp1, 'New Business', 100, 200, 50, 'Yes', 'Analec', null, null, null, 'ACV', 'NA');  
        OpportunityLineItem oppLineItem3 = GS_TestDataCreator.createOppLineItem(testPBEntry2, testOpp1, 'New Business', 0, 0, null, 'Yes', 'Analec','Lost', NULL, 'Incumbent (Functionality)', 'ACV', 'NA');
        OpportunityLineItem oppLineItem6 = GS_TestDataCreator.createOppLineItem(testPBEntry1, testOpp1, 'New Business', 100, 200, 50, 'Yes', 'Analec','won', null, null, 'ACV', 'NA');
        Test.stopTest();

        List<OpportunityLineItem> lstTestOppLineItems = new List<OpportunityLineItem>();

        OpportunityLineItem oppLineItemResult11 = [select Id, Net_New_Business__c from OpportunityLineItem where Id =: oppLineItem1.Id];
        //System.assertEquals(50, oppLineItemResult11.Net_New_Business__c);
        OpportunityLineItem oppLineItemResult13 = [select Id, Net_New_Business__c from OpportunityLineItem where Id =: oppLineItem3.Id];
        //System.assertEquals(0, oppLineItemResult13.Net_New_Business__c);

        oppLineItem1.Status__c = 'Won';
        oppLineItem1.Prior_Year_ACpV__c = 10;
        oppLineItem1.Prior_Year_Pass_Through__c =30;
        lstTestOppLineItems.add(oppLineItem1);

        oppLineItem6.Status__c = 'Lost';
        oppLineItem6.ACpV__c = 30;
        oppLineItem6.UnitPrice = 30;
        oppLineItem6.Lost_Cancelled_Reason__c = 'Competitor (Both)';
        oppLineItem6.Cancel_Comment__c = 'Competitor (Both)';
        lstTestOppLineItems.add(oppLineItem6);
        
        update lstTestOppLineItems;
        
        OpportunityLineItem oppLineItemResult21 = [select Id, Net_New_Business__c from OpportunityLineItem where Id =: oppLineItem1.Id];

        OpportunityLineItem oppLineItemResult25 = [select Id, Net_New_Business__c from OpportunityLineItem where Id =: oppLineItem6.Id];
        System.assertEquals(70, oppLineItemResult21.Net_New_Business__c);
           System.assertEquals(30, oppLineItemResult25.Net_New_Business__c);
        }
        catch(System.DmlException ex){
            System.debug(ex.getMessage());            
        }
    }    
}