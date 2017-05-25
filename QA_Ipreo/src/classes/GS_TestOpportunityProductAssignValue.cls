/**************************************************************************************************
 * Name           : GS_TestOpportunityProductAssignValue
 * Object         : OpportunityLineItem
 * Requirement    : STY-00045, STY-00171, STY-00011
 * Target         : Test GS_OpportunityProductAssignValueTHander
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-06-16
 * Modify History :
 **************************************************************************************************/
@isTest
private class GS_TestOpportunityProductAssignValue {
    /***********************************************************************************************************************************
     *Requirement :STY-00045
     *Details     :IF record created, THEN 
                      IF Revenue Type == null, THEN
                        IF Opportunity.Revenue Type == Subscription or Project, THEN
                             Revenue Type = Product.Default Revenue Type
     *Requirement :STY-00171
     *Details     :On Create,IF Region == null, THEN Region = User.Region
     *Requirement :STY-00011
     *Details     :IF record created, THEN IF Product Vertical == null, THEN Product Vertical = Product.Vertical
     ***********************************************************************************************************************************/
    static testMethod void productAssignValue1() {

        User testUser = GS_TestDataCreator.createUser('Standard User', 'OperationsUser@test.com', 'JAPAN');

        System.runAs(testUser){

            Follow_Rule_Setting__c testSetting1 = new Follow_Rule_Setting__c();
            Follow_Rule_Setting__c testSetting2 = new Follow_Rule_Setting__c();
            testSetting1.Name = 'Opportunity';
            testSetting2.Name = 'OpportunityTeam';
            testSetting1.isOpen__c = true;
            testSetting2.isOpen__c = true;
            insert testSetting1;    
            insert testSetting2;
            
            Account testAccount = GS_TestDataCreator.createAccount('TestAccount');
            Opportunity testOpp1 = GS_TestDataCreator.createOpportunity(testAccount, 'test opportunity', 'New_Business', 'Opportunity Identified', 'Subscription', '1 year', 'Tier 1');
            
            // createProduct(String name, Boolean isAsset, Boolean requiredPassThrough)
            //testOpp1 Revenue Tyoe = Subscription
            
            Product2 testProduct11 = GS_TestDataCreator.createProduct('TestProduct1', true, true,'TEST','ACV','Buyside');
            Product2 testProduct12 = GS_TestDataCreator.createProduct('TestProduct2', true, false,'TEST','TRANS','Buyside');
            

            // createPriceBookEntry(Product2 product, Decimal unitPrice)
            PricebookEntry testPBEntry11 = GS_TestDataCreator.createPriceBookEntry(testProduct11, 100);
            PricebookEntry testPBEntry12 = GS_TestDataCreator.createPriceBookEntry(testProduct12, 100);
            

            // createOppLineItem(PricebookEntry priceEntry, Opportunity opp, String productTransactionType,Decimal estAnnualFees, String revenueType)
            OpportunityLineItem oppLineItem11 = GS_TestDataCreator.createOppLineItem(testPBEntry11, testOpp1, 'New Business', 100, 200, 50, 'Yes', 'Analec',100000,null);
            OpportunityLineItem oppLineItem12 = GS_TestDataCreator.createOppLineItem(testPBEntry12, testOpp1, 'New Business', 50, 100, null, 'Yes', 'Analec',100000,null);
            

            OpportunityLineItem oppLineItemResult = [select Id, Product_Vertical__c from OpportunityLineItem where Id =: oppLineItem11.Id];
            //System.assertEquals('GMG', oppLineItemResult.Product_Vertical__c);

            OpportunityLineItem oppLineItemRegionResult = [select Id, Product_Region__c from OpportunityLineItem where Id =: oppLineItem11.Id];
            //System.assertEquals('JAPAN', oppLineItemRegionResult.Product_Region__c);

            OpportunityLineItem oppLineItemResult11 = [select Id, Product_Revenue_Type__c from OpportunityLineItem where Id =: oppLineItem11.Id];
            //System.assertEquals('ACV', oppLineItemResult11.Product_Revenue_Type__c);
            OpportunityLineItem oppLineItemResult12 = [select Id, Product_Revenue_Type__c from OpportunityLineItem where Id =: oppLineItem12.Id];
            //System.assertEquals('TRANS', oppLineItemResult12.Product_Revenue_Type__c);
            
        }
    }

    static testMethod void productAssignValue2() {

        User testUser = GS_TestDataCreator.createUser('Standard User', 'StandUser@test.com', 'JAPAN');

        System.runAs(testUser){

            Follow_Rule_Setting__c testSetting1 = new Follow_Rule_Setting__c();
            Follow_Rule_Setting__c testSetting2 = new Follow_Rule_Setting__c();
            testSetting1.Name = 'Opportunity';
            testSetting2.Name = 'OpportunityTeam';
            testSetting1.isOpen__c = true;
            testSetting2.isOpen__c = true;
            insert testSetting1;    
            insert testSetting2;
            
            Account testAccount = GS_TestDataCreator.createAccount('TestAccount');
            Opportunity testOpp2 = GS_TestDataCreator.createOpportunity(testAccount, 'test opportunity', 'New_Business', 'Opportunity Identified', 'Project', '1 year', 'Tier 1');

            // createProduct(String name, Boolean isAsset, Boolean requiredPassThrough)
            //testOpp2 Revenue Type = Per Event
            Product2 testProduct21 = GS_TestDataCreator.createProduct('TestProduct2', true, false,'TEST','PROJ','Buyside');        
            

            // createPriceBookEntry(Product2 product, Decimal unitPrice)
            PricebookEntry testPBEntry21 = GS_TestDataCreator.createPriceBookEntry(testProduct21, 100);
            
            
            /* 05/19/2016 UB: Updated revenueType parameter from null to PROJ as the new validation expects a valid value */
            // createOppLineItem(PricebookEntry priceEntry, Opportunity opp, String productTransactionType,Decimal estAnnualFees, String revenueType)
            OpportunityLineItem oppLineItem21 = GS_TestDataCreator.createOppLineItem(testPBEntry21, testOpp2, 'New Business', 50, 100, null, 'Yes', 'Analec',100000,'PROJ');
            
            

            OpportunityLineItem oppLineItemResult21 = [select Id, Product_Revenue_Type__c from OpportunityLineItem where Id =: oppLineItem21.Id];
            //System.assertEquals('PROJ', oppLineItemResult21.Product_Revenue_Type__c);
            
            
        }
    }   
}