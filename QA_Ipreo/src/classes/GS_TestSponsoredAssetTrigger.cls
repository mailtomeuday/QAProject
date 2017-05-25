/**************************************************************************************************
 * Name           : GS_TestSponsoredAssetTrigger
 * Object         : 
 * Requirement    : 
 * Target         : Test handlers on SponsoredAssetTrigger
 * Refer classes  : 
 * Author         : Ambadas Joshi. M (ambadas_morkhandikar@epam.com)
 * Create Date    : 2016-06-08
 * Modify History :
 **************************************************************************************************/
@isTest
private class GS_TestSponsoredAssetTrigger {
    static  testMethod void checkDuplicateSponsoredAssets() {
        Account testAccount = GS_TestDataCreator.createAccount('TestAccount');
        Account testAccount1 = GS_TestDataCreator.createAccount('TestAccount1');
        Account testAccount2 = GS_TestDataCreator.createAccount('TestAccount2');
        Product2 testProduct = GS_TestDataCreator.createProduct('TestProduct', true, false);
        Asset testAsset = GS_TestDataCreator.createAsset(testAccount, 'TestAsset', testProduct, 'NA');
        
        createSponsoredAsset(testAsset, testAccount1);
        createSponsoredAsset(testAsset, testAccount2);
        
        try
        {
            createSponsoredAsset(testAsset, testAccount1);
        }
        catch(Exception ex)
        {
            system.assertEquals(ex.getMessage().contains(System.Label.Msg_Duplicate_Sponsored_Assets), true);
        }
    }
    
    private static Sponsored_Asset__c createSponsoredAsset(Asset asset, Account acc){
      Sponsored_Asset__c sAsset = new Sponsored_Asset__c();
      sAsset.Account_Name__c = acc.Id;
      sAsset.Asset_Name__c = asset.Id;
      sAsset.Active__c = true;
      insert sAsset;
      return sAsset;
    }
}