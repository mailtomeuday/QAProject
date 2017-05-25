@isTest
private class GS_TestSponsoredUserAssetsController {
    static testMethod void testMethod1() {
        Account testAccount = GS_TestDataCreator.createAccount('TestAccount');
        Contact testContact = GS_TestDataCreator.createContact('TestContact', testAccount);
        Product2 testProduct = GS_TestDataCreator.createProduct('TestProduct', true, false);
        Asset testAsset = GS_TestDataCreator.createAsset(testAccount, 'TestAsset', testProduct, 'NA');
        
        User_Asset__c testUserAsset = new User_Asset__c();
        testUserAsset.User__c = testContact.Id;
        testUserAsset.Asset__c = testAsset.Id;
        testUserAsset.Is_Sponsored_User__c = true;
        insert testUserAsset;

        ApexPages.StandardController stdAsset = new ApexPages.StandardController(testAsset);
        GS_SponsoredUserAssetsController controller = new GS_SponsoredUserAssetsController(stdAsset);

        System.assertEquals(1, controller.userAsset.size());
    }
}