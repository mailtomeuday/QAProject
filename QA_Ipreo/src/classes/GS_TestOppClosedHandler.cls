/**************************************************************************************************
 * Name           : GS_TestOppClosedHandler
 * Object         : Opportunity/Opportunity Product/Work Order
 * Requirement    : 
 * Target         : Test GS_OpportunityClosedTHandler, that handler generate cancelled Wo if the opportunit is closed
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-09-09
 **************************************************************************************************/
@isTest
private class GS_TestOppClosedHandler {

    static testMethod void oppCloseHandler() {

        Test.startTest();
        User testUser = GS_TestDataCreator.createUser('Operations User', 'OperationsUser@test.com', 'APAC');

        Follow_Rule_Setting__c testSetting1 = new Follow_Rule_Setting__c();
        Follow_Rule_Setting__c testSetting2 = new Follow_Rule_Setting__c();
        testSetting1.Name = 'Opportunity';
        testSetting2.Name = 'OpportunityTeam';
        testSetting1.isOpen__c = true;
        testSetting2.isOpen__c = true;
        insert testSetting1;    
        insert testSetting2;

        Account testAccount = GS_TestDataCreator.createAccount('TestAccount');
        Account testAccount1 = GS_TestDataCreator.createAccount('TestAccount1');
        Opportunity testOpp = GS_TestDataCreator.createOpportunity(testAccount, 'test opportunity', 'Renewal', 'Opportunity Identified', 'Subscription', '1 year', 'Tier 1');
        Partner testPartner =GS_TestDataCreator.createPartner(testAccount1,'Reseller, Distributor',testOpp);
        Contact testContact = GS_TestDataCreator.createContact('testA', testAccount);
        Contract__c testContract = GS_TestDataCreator.createContract('test Contract', testAccount, 'Pending' , 'Shanghai', testContact, 'China' , 'Monthly' ,'Subscription Start Date', 'ZhongShan North Road', '30 Days');  
        Attachment testAttachment = GS_TestDataCreator.createAttachment(testContract, 'test Attachment', false , 'Test Contents');
        OpportunityContactRole testConRole = GS_TestDataCreator.createOppConRole(testContact, testOpp, 'Business User');
        
        Product2 testProduct = GS_TestDataCreator.createProduct('TestProduct1', true, true, 'implementation', 'ACV');
        PricebookEntry testPBEntry = GS_TestDataCreator.createPriceBookEntry(testProduct, 100);
       //Uday 24062016: Changed the Pass Through parameter as zero, as there is a new validation to have zero or null for cancelled opportunity products
        OpportunityLineItem oppLineItem = GS_TestDataCreator.createOppLineItem(testPBEntry, testOpp, 'Renewal', 100, 200, 0, 'Yes', 'Analec','Renewed',10000, null, 'ACV', 'NA');
        
        testContract.Status__c = 'Customer Executed';
        testContract.Evergreen__c = 'No';
        testContract.Customer_Signed_Date__c = Date.valueOf('2015-10-20');
        update testContract;
        Test.stopTest();

        oppLineItem.No_of_Users__c = 100;
        oppLineItem.Data_Region__c = 'APAC';
        oppLineItem.Dataset__c = 'Contacts';
        oppLineItem.Site_License__c = 'APAC';
        oppLineItem.Subscription_Start_Date__c = Date.valueOf('2015-09-15');
        oppLineItem.Subscription_End_Date__c = Date.valueOf('2015-09-30');
        oppLineItem.Term_Months__c = 0;
        oppLineItem.Estimated_Completion_Date__c = Date.valueOf('2015-08-30');
        oppLineItem.Renewal_Increase__c = 20;
        oppLineItem.ACpV__c = 0;
        oppLineItem.UnitPrice = 0;
        //oppLineItem.Work_Order__r = testWO1;
        oppLineItem.Status__c = 'Cancelled';
        oppLineItem.Lost_Cancelled_Reason__c = 'Test Reason';
        oppLineItem.Cancel_Comment__c = 'Test Reason';
        update oppLineItem;

        testOpp.Non_Subsidized_Contracted_Value__c = 100000;
        testOpp.LOB__c = 'Equity - Research, Sales & Trading';
        testOpp.StageName = GS_GlobalVariables.OPPCLOSEDWONVERIFIED;
        testOpp.Sales_Ops_Owner__c = testUser.Id;
        testOpp.Contract__c = testContract.Id;

        GS_GlobalVariables.EXECUTED = false;
        update testOpp;

        System.debug(LoggingLevel.INFO, '*** testOpp: ' + testOpp);

        List<Work_Order__c> generatedWO = [SELECT Id, RecordType.Name, Product__c, Opportunity__c from Work_Order__c];
        System.debug(LoggingLevel.INFO, '*** generatedWO: ' + generatedWO);
        RecordType cancelRT = [SELECT Id FROM RecordType Where Name = 'Cancellation' AND SobjectType = 'Work_Order__c'];
        System.assertEquals(1, generatedWO.size());
        System.assertEquals(cancelRT.Id, generatedWO[0].RecordType.Id);

    }

	static testMethod void testOppCloseHandler_methodOne() {

        Test.startTest();
        User testUser = GS_TestDataCreator.createUser('Operations User', 'OperationsUser@test.com', 'APAC');

        Follow_Rule_Setting__c testSetting1 = new Follow_Rule_Setting__c();
        Follow_Rule_Setting__c testSetting2 = new Follow_Rule_Setting__c();
        testSetting1.Name = 'Opportunity';
        testSetting2.Name = 'OpportunityTeam';
        testSetting1.isOpen__c = true;
        testSetting2.isOpen__c = true;
        insert testSetting1;    
        insert testSetting2;

        Account testAccount = GS_TestDataCreator.createAccount('TestAccount');
        Account testAccount1 = GS_TestDataCreator.createAccount('TestAccount1');
    	Opportunity testOpp;
    	OpportunityLineItem oppLineItem;
    	System.runAs(testUser){
         testOpp = GS_TestDataCreator.createOpportunity(testAccount, 'test opportunity', 'Renewal', 'Opportunity Identified', 'Subscription', '1 year', 'Tier 1');
       // Partner testPartner =GS_TestDataCreator.createPartner(testAccount1,'Reseller',testOpp);
        Contact testContact = GS_TestDataCreator.createContact('testA', testAccount);
        Contract__c testContract = GS_TestDataCreator.createContract('test Contract', testAccount, 'Pending' , 'Shanghai', testContact, 'China' , 'Monthly' ,'Subscription Start Date', 'ZhongShan North Road', '30 Days');  
        Attachment testAttachment = GS_TestDataCreator.createAttachment(testContract, 'test Attachment', false , 'Test Contents');
        OpportunityContactRole testConRole = GS_TestDataCreator.createOppConRole(testContact, testOpp, 'Business User');
        
        Product2 testProduct = GS_TestDataCreator.createProduct('TestProduct1', true, true, 'implementation', 'ACV');
        PricebookEntry testPBEntry = GS_TestDataCreator.createPriceBookEntry(testProduct, 100);
       //Uday 24062016: Changed the Pass Through parameter as zero, as there is a new validation to have zero or null for cancelled opportunity products
        oppLineItem = GS_TestDataCreator.createOppLineItem(testPBEntry, testOpp, 'Renewal', 100, 200, 0, 'Yes', 'Analec','Renewed',10000, null, 'ACV', 'NA');
        
        testContract.Status__c = 'Customer Executed';
        testContract.Evergreen__c = 'No';
        testContract.Customer_Signed_Date__c = Date.valueOf('2015-10-20');
        update testContract;
        Test.stopTest();

        oppLineItem.No_of_Users__c = 100;
        oppLineItem.Data_Region__c = 'APAC';
        oppLineItem.Dataset__c = 'Contacts';
        oppLineItem.Site_License__c = 'APAC';
        oppLineItem.Subscription_Start_Date__c = Date.valueOf('2015-09-15');
        oppLineItem.Subscription_End_Date__c = Date.valueOf('2015-09-30');
        oppLineItem.Term_Months__c = 0;
        oppLineItem.Estimated_Completion_Date__c = Date.Today().addDays(5);
        oppLineItem.Renewal_Increase__c = 20;
        oppLineItem.ACpV__c = 0;
        oppLineItem.UnitPrice = 0;
        //oppLineItem.Work_Order__r = testWO1;
        oppLineItem.Status__c = 'Renewed';
        oppLineItem.Lost_Cancelled_Reason__c = 'Test Reason';
        oppLineItem.Cancel_Comment__c = 'Test Reason';
        update oppLineItem;
    
        testOpp.Non_Subsidized_Contracted_Value__c = 100000;
        testOpp.LOB__c = 'Equity - Research, Sales & Trading';
        testOpp.StageName = GS_GlobalVariables.OPPCLOSEDWONVERIFIED;        
    	testOpp.Sales_Ops_Owner__c = testUser.Id;
    	testOpp.OwnerId = testUser.Id;
        testOpp.Contract__c = testContract.Id;
        GS_GlobalVariables.EXECUTED = false;
    }
    	oppLineItem.Estimated_Completion_Date__c = Date.valueOf('2015-09-30');
    	update oppLineItem;
     	System.runAs(testUser){   
        try{
                    update testOpp;      	                 
            }
            catch(Exception ex){
                GS_OpportunityClosedTHandler CWT = new GS_OpportunityClosedTHandler();
                CWT.processException(ex);
            }
         }
     }
	
}