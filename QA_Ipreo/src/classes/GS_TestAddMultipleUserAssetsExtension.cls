@isTest
private class GS_TestAddMultipleUserAssetsExtension {
	
	static testMethod void addMulUserAssExtension() {

    	Follow_Rule_Setting__c testSetting1 = new Follow_Rule_Setting__c();
    	Follow_Rule_Setting__c testSetting2 = new Follow_Rule_Setting__c();
    	testSetting1.Name = 'Opportunity';
    	testSetting2.Name = 'OpportunityTeam';
    	testSetting1.isOpen__c = true;
    	testSetting2.isOpen__c = true;
    	insert testSetting1;	
    	insert testSetting2;

		Account testAccount = GS_TestDataCreator.createAccount('TestAccount');
		List<Contact> lstContacts = new List<Contact>();
		Contact testContact = GS_TestDataCreator.createContact('TestContact', testAccount,false);
		for(Integer i = 0; i<2500; i++){
			Contact Con = GS_TestDataCreator.createContact('TestContact_'+i, testAccount,false);
		    lstContacts.add(Con);
		}
		insert lstContacts;
		Product2 testProduct = GS_TestDataCreator.createProduct('TestProduct', true, false);
		Asset testAsset = GS_TestDataCreator.createAsset(testAccount, 'TestAsset', testProduct, 'NA');

		/*User_Asset__c testUserAsset = new User_Asset__c();
		testUserAsset.User__c = testContact.Id;
		testUserAsset.Asset__c = testAsset.Id;
		insert testUserAsset;*/

		ApexPages.currentPage().getParameters().put('aid', testAsset.Id);

		ApexPages.StandardController stdAsset = new ApexPages.StandardController(testAsset);
        AddMultipleUserAssetsExtension controller = new AddMultipleUserAssetsExtension(stdAsset);

        //controller.asset = testAsset;
        //controller.uaBindings = new List<AddMultipleUserAssetsExtension.UserAsset>();
        AddMultipleUserAssetsExtension.UserAsset itemUA = new AddMultipleUserAssetsExtension.UserAsset(testAsset,testContact);
        itemUA.selected = true;
        controller.uaBindings.add(itemUA);

        controller.save();

        if(controller.uaBindings.size() > 0)
        {
            for(AddMultipleUserAssetsExtension.UserAsset u : controller.uaBindings)
            {
                System.assertEquals(false, u.existing);
            }
        }
        
        //test search functionality
        Sponsored_Asset__c sa = new Sponsored_Asset__c(Account_Name__c =testAccount.Id, Asset_Name__c = testAsset.Id);
        insert sa;
        controller.accountName = 'test';
        controller.getSearchResults();
		if(controller.hasFirst){
        	controller.First();	
        }
        if(controller.hasFirst){
        	controller.First();	
        }        
        if(controller.hasNext){
        	controller.next();	
        }
		if(controller.hasPrevious){
        	controller.Previous();	
        }
        if(controller.hasPrevious){
        	controller.Previous();	
        }
        if(controller.hasPrevious){
        	controller.Previous();	
        }
        if(controller.hasPrevious){
        	controller.Previous();	
        }
		if(controller.hasLast){
        	controller.Last();	
        }
		if(controller.hasLast){
        	controller.Last();	
        }        
		if(controller.hasFirst){
        	controller.First();	
        }
		if(controller.hasFirst){
        	controller.First();	
        }        
        if(controller.hasNext){
        	controller.next();	
        }
		if(controller.hasLast){
        	controller.Last();	
        } 
        if(controller.hasNext){
        	controller.next();	
        }                         
        system.assertEquals(controller.uaBindings.size() > 0,true);
	}
	
}