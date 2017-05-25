@isTest
private class GS_TestUpdateYearDependentOppFieldsBatch {


    static testmethod void test() 
    {
    	Follow_Rule_Setting__c testSetting1 = new Follow_Rule_Setting__c();
        Follow_Rule_Setting__c testSetting2 = new Follow_Rule_Setting__c();
        testSetting1.Name = 'Opportunity';
        testSetting2.Name = 'OpportunityTeam';
        testSetting1.isOpen__c = true;
        testSetting2.isOpen__c = true;
        insert testSetting1;    
        insert testSetting2; 
        
        User_List_Data_Update_Notifications__c notif = new User_List_Data_Update_Notifications__c();
        notif.Name = 'UpdateYearDependentOppFieldsBatch';
        notif.Email_Addresses__c = 'test1@test.com,test2@test.com,test3@test.com';
        insert notif;
        
        User testUser1 = GS_TestDataCreator.createUser('Operations User', 'Tom.124@test.com', 'APAC');   
          
       	//insert oppourtunity and update the closedate 
        Account testAccount = GS_TestDataCreator.createAccount('TestAccount');         
        Opportunity testOpp = GS_TestDataCreator.createOpportunity(testAccount, 'test opportunity', 'New_Business', 'Opportunity Identified', 'Subscription', '1 year', 'Tier 1');
        Contact testContact = GS_TestDataCreator.createContact('testA', testAccount);
        Product2 testProduct1 = GS_TestDataCreator.createProduct('TestProduct1', true, true, 'implementation', 'PROJ');  
        PricebookEntry testPBEntry1 = GS_TestDataCreator.createPriceBookEntry(testProduct1, 100);
        OpportunityLineItem oppLineItem1 = GS_TestDataCreator.createOppLineItem(testPBEntry1, testOpp, 'New Business', 100, 200, 50, 'Yes', 'Analec', null, 10000, null, 'PROJ', 'NA');
        system.debug('oppLineItem1 Oppline item type------->>>>'+oppLineItem1.Product_Revenue_Type__c);
        system.debug('Opp rev type------->>>>'+testOpp.Revenue_Type__c);
        testOpp.CloseDate=Date.valueOf(String.valueof(Datetime.now()));
        //testOpp.Is_Close_Date_In_Current_Year__c='No';
        testOpp.OwnerId= testUser1.Id;
        Update testOpp;
            
        //insert oppourtunity and update the closedate
        Account testAccount1 = GS_TestDataCreator.createAccount('TestAccount');
        Opportunity testOpp1 = GS_TestDataCreator.createOpportunity(testAccount, 'test opportunity', 'Renewal', 'Opportunity Identified', 'Subscription', '1 year', 'Tier 1');
        testOpp1.CloseDate=Date.valueOf(String.valueof(Datetime.now().addYears(-1)));
        testOpp1.OwnerId= testUser1.Id;
        Update testOpp1;

       	System.runAs(testUser1)
        { 
        	Test.startTest();
         	
         	//Update testOpp;
        	GS_UpdateYearDependentOppFieldsBatch rcb = new GS_UpdateYearDependentOppFieldsBatch();
        	Id batchId = Database.executeBatch(rcb);   
        	// after the testing stops, assert records were updated properly
        	System.assertEquals(2, [select count() from Opportunity Where (CloseDate = THIS_YEAR) or (CloseDate = LAST_YEAR)]);
            
            Test.stopTest();
    	}
        
   }    
    
}