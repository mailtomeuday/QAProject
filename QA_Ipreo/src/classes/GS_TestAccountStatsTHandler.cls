/**************************************************************************************************
 * Name           : GS_AccountStatsTHandler
 * Object         : Account
 * Requirement    : 
 * Target         : Test class for GS_AccountStatsTHandler.
 * Refer classes  :
 * Author         : Uday Bikkumalla
 * Create Date    : 2016-08-26
 * Modify History :
 **************************************************************************************************/
@isTest
public  class GS_TestAccountStatsTHandler {
    static testMethod void accountMergeTest() 
    {
        Account masterAcc = GS_TestDataCreator.createAccount('Test ABC Labs');
        Account duplicateAcc = GS_TestDataCreator.createAccount('Test ABC');
        Work_Order__c wo_master = GS_TestDataCreator.createWorkOrder(masterAcc, 'Implementation', masterAcc.name, Date.Today().addDays(10));
        Work_Order__c wo_duplicate = GS_TestDataCreator.createWorkOrder(duplicateAcc, 'Implementation', duplicateAcc.name, Date.Today().addDays(10));
        Work_Order__c wo_duplicate_1 = GS_TestDataCreator.createWorkOrder(duplicateAcc, 'Implementation', duplicateAcc.name, Date.Today().addDays(10));
        wo_duplicate_1.Active__c=true;
        update wo_duplicate_1;
        
        product2 prod1 = GS_TestDataCreator.createProduct('Test Prodcut', false, false);
        product2 prod2 = GS_TestDataCreator.createProduct('Test Prodcut New', false, false);
        
        Asset asset_master_1 = GS_TestDataCreator.createAsset(masterAcc, masterAcc.name, prod1, 'NA');
        Asset asset_master_2 = GS_TestDataCreator.createAsset(masterAcc, masterAcc.name, prod2, 'NA');
        asset_master_2.status = 'Active';
        update asset_master_2;
        Asset asset_duplicate = GS_TestDataCreator.createAsset(duplicateAcc, duplicateAcc.name, prod1, 'NA');
        
        try {
            merge masterAcc duplicateAcc;
        } catch (DmlException e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage()); 
        }
        List<ID> accountIds = new List<ID>();
        accountIds.add(masterAcc.Id);
        List<Account> lstAccounts = GS_AccountDMLHandler.getAssetsWorkOrdersByAccount(accountIds);
        /*System.assertEquals(1,lstAccounts[0].No_of_All_Work_Orders__c);
        System.assertEquals(1,lstAccounts[0].No_of_Active_Work_Orders__c);
        System.assertEquals(2,lstAccounts[0].No_of_All_Assets__c);
        System.assertEquals(1,lstAccounts[0].No_of_Active_Assets__c);*/
    }
    static testMethod void updateAccountOnAssetWOTest() 
    {
        Account masterAcc = GS_TestDataCreator.createAccount('Test ABC Labs');
        Account duplicateAcc = GS_TestDataCreator.createAccount('Test ABC');
        Work_Order__c wo_master = GS_TestDataCreator.createWorkOrder(masterAcc, 'Implementation', masterAcc.name, Date.Today().addDays(10));
        Work_Order__c wo_duplicate = GS_TestDataCreator.createWorkOrder(duplicateAcc, 'Implementation', duplicateAcc.name, Date.Today().addDays(10));
        wo_duplicate.Account__c = masterAcc.Id;
        wo_duplicate.Active__c=true;
        update wo_duplicate;
        
        product2 prod1 = GS_TestDataCreator.createProduct('Test Prodcut', false, false);
        product2 prod2 = GS_TestDataCreator.createProduct('Test Prodcut New', false, false);
        
        Asset asset_master = GS_TestDataCreator.createAsset(masterAcc, masterAcc.name, prod1, 'NA');
        asset_master.status = 'Active';
        update asset_master;
        Asset asset_duplicate1 = GS_TestDataCreator.createAsset(duplicateAcc, duplicateAcc.name, prod1, 'NA');
        delete asset_duplicate1;
        Asset asset_duplicate = GS_TestDataCreator.createAsset(duplicateAcc, duplicateAcc.name, prod2, 'NA');
        asset_duplicate.AccountId = masterAcc.Id;
        update asset_duplicate;
        
        
        List<ID> accountIds = new List<ID>();
        accountIds.add(masterAcc.Id);
        List<Account> lstAccounts = GS_AccountDMLHandler.getAssetsWorkOrdersByAccount(accountIds);
        System.assertEquals(2,lstAccounts[0].No_of_All_Work_Orders__c);
        System.assertEquals(1,lstAccounts[0].No_of_Active_Work_Orders__c);
        System.assertEquals(2,lstAccounts[0].No_of_All_Assets__c);
        System.assertEquals(1,lstAccounts[0].No_of_Active_Assets__c);
    }    

}