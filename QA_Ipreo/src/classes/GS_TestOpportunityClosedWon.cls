/**************************************************************************************************
 * Name           : GS_TestOpportunityClosedWon
 * Object         : Opportunity/Opportunity Product/Asset/Asset License
 * Requirement    : STY-00170, STY-00172, STY-00178
 * Target         : Test GS_OpportunityClosedWonTHandler
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-09-09
 **************************************************************************************************/

@isTest
private class GS_TestOpportunityClosedWon {
    /***********************************************************************************************************************************
     *Requirement :STY-00170
     *Details     :IF IsChanged(Opportunity.Stage) AND Opportunity.Stage == "Closed Won Verified",FOR EACH opportunity product,
     *             IF Status = Renewed OR Won AND Revenue Type IN (ACV, ACV/TRANS), THEN
     *             IF there does not already exist an asset for the Product AND Opportunity.Account, THEN create an asset record ,Create a license record
     *Requirement :STY-00172
     *Details     :IF IsChanged(Stage) AND Stage == Closed Won Verified, THEN
     *             Clone opportunity except for all calculated fields, and transform certain fields
     *             Clone each opportunity product WHERE Status == Renew OR Won
     *             Clone opportunity team members
     *             Clone opportunity contact roles
     *Requirement :STY-00178
     *Details     :IF IsChanged(Stage) AND Stage == Closed Won Verified, THEN
     *             FOR EACH Opportunity Product
     *             IF Status == Renew OR Won, THEN create Work Order record
     ***********************************************************************************************************************************/

    static testMethod void closeWon1() {

        User testUser = GS_TestDataCreator.createUser('Operations User', 'OperationsUser@test.com', 'APAC');

        List<Follow_Rule_Setting__c> lstFollowRule = new List<Follow_Rule_Setting__c>();
        Follow_Rule_Setting__c testSetting1 = new Follow_Rule_Setting__c();
        Follow_Rule_Setting__c testSetting2 = new Follow_Rule_Setting__c();
        testSetting1.Name = 'Opportunity';
        testSetting2.Name = 'OpportunityTeam';
        testSetting1.isOpen__c = true;
        testSetting2.isOpen__c = true;
        lstFollowRule.add(testSetting1);
        lstFollowRule.add(testSetting2);
        insert lstFollowRule;

        List<String> accNames = new List<String>();
        accNames.add('TestAccount');
        accNames.add('TestAccount1');
        List<Account> testAccounts = GS_TestDataCreator.createAccounts(accNames);

        Account testAccount = testAccounts[0];
        Account testAccount1 = testAccounts[1];

        Opportunity testOpp = GS_TestDataCreator.createOpportunity(testAccount, 'test opportunity', 'New_Business', 'Opportunity Identified', 'Subscription', '1 year', 'Tier 1');
        Partner testPartner1 = GS_TestDataCreator.createPartner(testAccount1, 'Reseller, Distributor', testOpp);
        Contact testContact = GS_TestDataCreator.createContact('testA', testAccount);
        Contract__c testContract = GS_TestDataCreator.createContract('test Contract', testAccount, 'Pending' , 'Shanghai', testContact, 'China' , 'Monthly' , 'Subscription Start Date', 'ZhongShan North Road', '30 Days');
        Attachment testAttachment = GS_TestDataCreator.createAttachment(testContract, 'test Attachment', false , 'Test Contents');
        OpportunityContactRole testConRole = GS_TestDataCreator.createOppConRole(testContact, testOpp, 'Business User');

        // createProduct(String name, Boolean isAsset, Boolean requiredPassThrough)
        Product2 testProduct1 = GS_TestDataCreator.createProduct('TestProduct1', true, true, 'implementation', 'ACV');

        // createPriceBookEntry(Product2 product, Decimal unitPrice)
        PricebookEntry testPBEntry1 = GS_TestDataCreator.createPriceBookEntry(testProduct1, 100);

        // createOppLineItem(Account acc, String name, String recordTypeName, String stageName, String revenueType, String renewalIncrement, String NYSEProgramTier, String verticalType )
        OpportunityLineItem oppLineItem1 = GS_TestDataCreator.createOppLineItem(testPBEntry1, testOpp, 'New Business', 100, 200, 50, 'Yes', 'Analec', 'Won', 10000, null, 'ACV', 'NA');

        List<OpportunityLineItem> lstTestOppLineItems = new List<OpportunityLineItem>();

        testContract.Status__c = 'Customer Executed';
        testContract.Evergreen__c = 'No';
        testContract.Customer_Signed_Date__c = Date.valueOf('2015-10-20');
        update testContract;

        oppLineItem1.No_of_Users__c = 100;
        oppLineItem1.Data_Region__c = 'APAC';
        oppLineItem1.Dataset__c = 'Contacts';
        oppLineItem1.Site_License__c = 'APAC';
        oppLineItem1.Subscription_Start_Date__c = Date.valueOf('2015-09-15');
        oppLineItem1.Subscription_End_Date__c = Date.valueOf('2015-09-30');
        oppLineItem1.Term_Months__c = 13;
        oppLineItem1.Estimated_Completion_Date__c = Date.valueOf('2015-08-30');
        oppLineItem1.Renewal_Increase__c = 20;
        lstTestOppLineItems.add(oppLineItem1);

        update lstTestOppLineItems;

        //Opportunity oppResult1 = [select Id,StageName from Opportunity where Id =: testOpp.Id];

        testOpp.StageName = 'Closed Won Verified';
        //oppResult1.Contracted_Value__c = 10;
        testOpp.Sales_Ops_Owner__c = testUser.Id;
        testOpp.Contract__c = testContract.Id;

        GS_GlobalVariables.EXECUTED = false;

        System.debug(LoggingLevel.DEBUG, '*** query number 1: ' + Limits.getQueries());

        Test.startTest();

        System.debug(LoggingLevel.DEBUG, '*** query number 2: ' + Limits.getQueries());

        update testOpp;

        System.debug(LoggingLevel.DEBUG, '*** query number 3: ' + Limits.getQueries());

        Test.stopTest();
        /*
        //data comparison : newly asset and license
        List<Asset> lstAssResult = new List<Asset>();
        List<Asset_License__c> lstLicResult = new List<Asset_License__c>();
        lstAssResult = [select Id, Name, Status, Contract__r.Name, AccountId, Product2Id, Opportunity__c, Contract__c from Asset where Opportunity__r.Id = : testOpp.Id];
        lstLicResult = [select Id, Opportunity__c, Account__c, Contract__c, No_of_Seats__c, Start_Date__c, End_Date__c from Asset_License__c where Opportunity__c = : testOpp.Id];

        if (lstAssResult.size() > 0) {
            System.assertEquals(testAccount.Name + ' ' + testProduct1.Name + ' ' + oppLineItem1.Product_Region__c, lstAssResult[0].Name);
            System.assertEquals(testOpp.AccountId, lstAssResult[0].AccountId);
            System.assertEquals(testProduct1.Id, lstAssResult[0].Product2Id);
            //System.assertEquals(testOpp.Id, lstAssResult[0].Opportunity__c);
            System.assertEquals(testContract.Id, lstAssResult[0].Contract__c);
            System.assertEquals('Inactive', lstAssResult[0].Status);
        }
        if (lstLicResult.size() > 0) {
            System.assertEquals(testOpp.Id, lstLicResult[0].Opportunity__c);
            System.assertEquals(testOpp.AccountId, lstLicResult[0].Account__c);
            System.assertEquals(testContract.Id, lstLicResult[0].Contract__c);
            System.assertEquals(oppLineItem1.No_of_Users__c, lstLicResult[0].No_of_Seats__c);
            System.assertEquals(oppLineItem1.Subscription_Start_Date__c, lstLicResult[0].Start_Date__c);
            System.assertEquals(oppLineItem1.Subscription_End_Date__c, lstLicResult[0].End_Date__c);
        }


        //for newly opportunity, opportunity products
        List<Opportunity> lstOppResult = new List<Opportunity>();
        lstOppResult = [select Id, Name, (SELECT Id, Name, RecordTypeId, Renewal_Status__c, Revenue_Delta_Type__c, CloseDate from Opportunities__r) from Opportunity];
        if (lstOppResult.size() > 0 && lstOppResult[0].Opportunities__r.size() > 0) {
            Opportunity newOppResult = lstOppResult[0].Opportunities__r[0];
            String name = testAccount.Name + ' - Renewal - ' + oppLineItem1.Subscription_End_Date__c.addDays(1).year();
            if (name.length() > 120) {
                name = name.left(120);
            }
            System.assertEquals(name, newOppResult.Name);
            System.assertEquals(GS_TestDataCreator.getRecordType('Renewal', 'Opportunity').Id, newOppResult.RecordTypeId);
            System.assertEquals(oppLineItem1.Subscription_End_Date__c.addDays(1), newOppResult.CloseDate);
            System.assertEquals('Renewal Pending', newOppResult.Renewal_Status__c);
            System.assertEquals('Uptick', newOppResult.Revenue_Delta_Type__c);

            List<OpportunityLineItem> lstOppLItemResult = [select Id, Name, Product_Transaction_Type__c, Status__c, Lost_Cancelled_Reason__c, Estimated_Completion_Date__c, Subscription_Start_Date__c, Subscription_End_Date__c, Prior_Year_ACpV__c from OpportunityLineItem where OpportunityId = :newOppResult.Id ];
            if (lstOppLItemResult.size() > 0) {
                System.assertEquals('Renewal', lstOppLItemResult[0].Product_Transaction_Type__c);
                System.assertEquals(null, lstOppLItemResult[0].Status__c);
                System.assertEquals(null, lstOppLItemResult[0].Lost_Cancelled_Reason__c);
                System.assertEquals(oppLineItem1.Estimated_Completion_Date__c.addYears(1), lstOppLItemResult[0].Estimated_Completion_Date__c);
                System.assertEquals(oppLineItem1.Subscription_End_Date__c.addDays(1), lstOppLItemResult[0].Subscription_Start_Date__c);
                System.assertEquals(oppLineItem1.Subscription_End_Date__c.addYears(1), lstOppLItemResult[0].Subscription_End_Date__c);
                System.assertEquals(oppLineItem1.ACpV__c, lstOppLItemResult[0].Prior_Year_ACpV__c);
            }
        }
        */
    }

    static testMethod void AttachmentCalNumber() {

        Account testAccount = GS_TestDataCreator.createAccount('TestAccount');
        Contact testContact = GS_TestDataCreator.createContact('testA', testAccount);
        Contract__c testContract = GS_TestDataCreator.createContract('test Contract', testAccount, 'Pending', 'Shanghai', testContact, 'China' , 'Monthly' , 'Subscription Start Date', 'ZhongShan North Road', '30 Days');
        Attachment testAttachment = GS_TestDataCreator.createAttachment(testContract, 'test Attachment', false , 'Test Contents');

        delete testAttachment;

    }
}