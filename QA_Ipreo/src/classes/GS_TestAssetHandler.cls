@isTest
private class GS_TestAssetHandler {
    static testMethod void assetHandler() {

        Follow_Rule_Setting__c testSetting1 = new Follow_Rule_Setting__c();
        Follow_Rule_Setting__c testSetting2 = new Follow_Rule_Setting__c();
        testSetting1.Name = 'Opportunity';
        testSetting2.Name = 'OpportunityTeam';
        testSetting1.isOpen__c = true;
        testSetting2.isOpen__c = true;
        insert testSetting1;    
        insert testSetting2;

        Account testAccount = GS_TestDataCreator.createAccount('TestAccount');
        Account testAccount2 = GS_TestDataCreator.createAccount('TestAccount2');
        Contact testContact = GS_TestDataCreator.createContact('TestContact', testAccount);
        Contact testContact2 = GS_TestDataCreator.createContact('TestContact', testAccount2);
        Product2 testProduct = GS_TestDataCreator.createProduct('TestProduct', true, false);
        Asset testAsset = GS_TestDataCreator.createAsset(testAccount, 'TestAsset', testProduct, 'NA');

        Sponsored_Asset__c testSpoAss = new Sponsored_Asset__c();
        testSpoAss.Account_Name__c = testAccount.Id;
        testSpoAss.Asset_Name__C = testAsset.Id;
        testSpoAss.Active__c = false;
        insert testSpoAss;

        User_Asset__c testUserAss1 = new User_Asset__c();
        testUserAss1.User__c = testContact.Id;
        testUserAss1.Asset__c = testAsset.Id;
        insert testUserAss1;

        User_Asset__c testUserAss2 = new User_Asset__c();
        testUserAss2.User__c = testContact2.Id;
        testUserAss2.Asset__c = testAsset.Id;

        try{
            insert testUserAss2;        
        }catch(Exception e){
           System.debug('The following exception has occurred: ' + e.getMessage());
        } 

        testAsset.Status = 'Active';
        testAsset.Product_Region__c = 'LATAM';
        update testAsset;
		
		Set<ID> setAssetIds = new Set<ID>();
		setAssetIds.add(testAsset.id);
		GS_AssetUpdateUserAssetStatusTHandler.updateUserAssets(setAssetIds); 
		GS_AssetUpdateUserAssetStatusTHandler.sendEmailOnError('Test Failure Message');
        List<Account> lstAccoutResult = [select Id,No_of_Active_Assets__c,No_of_All_Assets__c from Account where Id = :testAccount.Id];
        if(lstAccoutResult.size() > 0)
        {
            System.assertEquals(1, lstAccoutResult[0].No_of_Active_Assets__c);
            System.assertEquals(1, lstAccoutResult[0].No_of_All_Assets__c);
        }
        List<User_Asset__c> lstUAResult = [select Id, Active__c from User_Asset__c where Asset__c = :testAsset.Id];
        if(lstUAResult.size() > 0)
        {
            for(User_Asset__c uAsset : lstUAResult)
            {
                System.assertEquals('Active', uAsset.Active__c);
            }
        }
        List<Sponsored_Asset__c> lstSAResult = [select Id, Active__c from Sponsored_Asset__c where Asset_Name__C = :testAsset.Id];
        if(lstSAResult.size() > 0)
        {
            for(Sponsored_Asset__c sAsset : lstSAResult)
            {
                System.assertEquals(true, sAsset.Active__c);
            }
        }
    }
    
    
}