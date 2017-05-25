/**************************************************************************************************
 * Name           : GS_AccountStatsTHandler
 * Object         : Account
 * Requirement    : 
 * Target         : Test class to cover code related RAG Status functionality 
 * Refer classes  : GS_RAGStatusTrigger, GS_AssetUpdateACCRAGScoreTHandler,GS_RAGStatusUpdateAssetTHandler
 * Author         : Joshi
 * Create Date    : 2017-02-16
 * Modify History :
 **************************************************************************************************/
 
@isTest
private class GS_TestRAGStatusHandlers {

	static Asset objAsset1,objAsset2,objAsset3;
	static Account objAccount;
	
	static void createTestData()
	{
		objAccount = GS_TestDataCreator.createAccount('Test RAG Status Account', true);
		
		Product2 prod1 = GS_TestDataCreator.createProduct('Test Prod1', false, false);
		Product2 prod2 = GS_TestDataCreator.createProduct('Test Prod2', false, false);
		Product2 prod3 = GS_TestDataCreator.createProduct('Test Prod3', false, false);
		
		objAsset1 = GS_TestDataCreator.createAsset(objAccount, objAccount.name, prod1, 'NA');
		objAsset1.status = 'Active';
        objAsset2 = GS_TestDataCreator.createAsset(objAccount, objAccount.name, prod2, 'NA');
        objAsset2.status = 'Active';
		objAsset3 = GS_TestDataCreator.createAsset(objAccount, objAccount.name, prod3, 'NA');
		objAsset3.status = 'Active';
		
		update new list<Asset>{objAsset1, objAsset2, objAsset3};
		
	}
	
    static testMethod void TestRAGSummarySingleRAGStatus() {
        
        createTestData();
        
        Test.startTest();
        
        RAG_Status__c objRAGStatus = new RAG_Status__c(); 
        
        objRAGStatus.Asset__c = objAsset1.Id;
		objRAGStatus.RAG_Status__c = 'Red';
		objRAGStatus.Description__c = 'Test Desc Red 1';        
        insert objRAGStatus;
        
        objAsset1 = [select Current_RAG_Status__c, Current_RAG_Status_Description__c, Current_RAG_Status_Last_Modified_Date__c from Asset where Id =: objAsset1.Id];
        
        system.assertEquals(objAsset1.Current_RAG_Status__c, 'Red');
        system.assertEquals(objAsset1.Current_RAG_Status_Description__c, 'Test Desc Red 1');
        system.assertEquals(objAsset1.Current_RAG_Status_Last_Modified_Date__c, date.today());
        
        objRAGStatus = new RAG_Status__c(); 
        
        objRAGStatus.Asset__c = objAsset2.Id;
		objRAGStatus.RAG_Status__c = 'Amber';
		objRAGStatus.Description__c = 'Test Desc Amber 1';        
        insert objRAGStatus;
        
        objAsset2 = [select Current_RAG_Status__c, Current_RAG_Status_Description__c, Current_RAG_Status_Last_Modified_Date__c from Asset where Id =: objAsset2.Id];
        
        system.assertEquals(objAsset2.Current_RAG_Status__c, 'Amber');
        system.assertEquals(objAsset2.Current_RAG_Status_Description__c, 'Test Desc Amber 1');
        system.assertEquals(objAsset2.Current_RAG_Status_Last_Modified_Date__c, date.today());
        
        objRAGStatus = new RAG_Status__c(); 
        
        objRAGStatus.Asset__c = objAsset3.Id;
		objRAGStatus.RAG_Status__c = 'Green';
		objRAGStatus.Description__c = 'Test Desc Green 1';        
        insert objRAGStatus;
        
        objAsset3 = [select Current_RAG_Status__c, Current_RAG_Status_Description__c, Current_RAG_Status_Last_Modified_Date__c from Asset where Id =: objAsset3.Id];
        
        system.assertEquals(objAsset3.Current_RAG_Status__c, 'Green');
        system.assertEquals(objAsset3.Current_RAG_Status_Description__c, 'Test Desc Green 1');
        system.assertEquals(objAsset3.Current_RAG_Status_Last_Modified_Date__c, date.today());
        
        objAccount = [select id, RAG_Status_Summary__c from Account where Id =: objAccount.Id];
        
        system.assertEquals(objAccount.RAG_Status_Summary__c, 'Red-Amber-Green');
                        
        Test.stopTest();
        
    }
    
    static testMethod void TestRAGSummaryMultipleRAGStatus() {
    	
    	createTestData();
    	
    	Test.startTest();
    	
    	for(integer i=0; i< 3; i++){
    		RAG_Status__c objRAGStatus = new RAG_Status__c(); 
        
	        objRAGStatus.Asset__c = objAsset1.Id;
			objRAGStatus.RAG_Status__c = 'Red';
			objRAGStatus.Description__c = 'Test Desc Red '+i;        
	        insert objRAGStatus;
    	}
    	
    	for(integer i=0; i< 3; i++){
    		RAG_Status__c objRAGStatus = new RAG_Status__c(); 
        
	        objRAGStatus.Asset__c = objAsset2.Id;
			objRAGStatus.RAG_Status__c = 'Amber';
			objRAGStatus.Description__c = 'Test Desc Amber '+i;        
	        insert objRAGStatus;
    	}
    	
    	for(integer i=0; i< 3; i++){
    		RAG_Status__c objRAGStatus = new RAG_Status__c(); 
        
	        objRAGStatus.Asset__c = objAsset3.Id;
			objRAGStatus.RAG_Status__c = 'Green';
			objRAGStatus.Description__c = 'Test Desc Green '+i;        
	        insert objRAGStatus;
    	}
    	
    	objAccount = [select id, RAG_Status_Summary__c from Account where Id =: objAccount.Id];
        
        system.assertEquals(objAccount.RAG_Status_Summary__c, 'Red-Amber-Green');
        
    	delete [select id from RAG_Status__c where Asset__c =: objAsset1.Id];
    	
    	objAccount = [select id, RAG_Status_Summary__c from Account where Id =: objAccount.Id];
        
        system.assertEquals(objAccount.RAG_Status_Summary__c, 'Amber-Green');
        
        delete [select id from RAG_Status__c where Asset__c =: objAsset2.Id];
    	
    	objAccount = [select id, RAG_Status_Summary__c from Account where Id =: objAccount.Id];
        
        system.assertEquals(objAccount.RAG_Status_Summary__c, 'Green');
        
        delete [select id from RAG_Status__c where Asset__c =: objAsset3.Id];
    	
    	objAccount = [select id, RAG_Status_Summary__c from Account where Id =: objAccount.Id];
        
        system.assertEquals(objAccount.RAG_Status_Summary__c, null);
        
	 	Test.stopTest();
    	
    }
}