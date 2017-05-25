/**
 * This class contains unit tests for validating the behavior of the functionality to 
 * Populate Activity Product on Contact related classes and triggers.
 **/

@isTest
private class GS_TestActivityProductsOnContact {

	static Account a = GS_TestDataCreator.createAccount('Test Account For Activty Products');
	static Profile P = GS_TestDataCreator.queryProfile('Sales User');
    static User u = [select id,FirstName,LastName from User where Profile.Id =: P.Id and IsActive =: true limit 1];
    static string products = 'BD Advanced (2111);Activist Intelligence (Shark Repellent);Prism Virtual Data Room';
    
    static string prodGMG = 'BD Advanced (2111)';
    static string prodCorp = 'Activist Intelligence (Shark Repellent)';
    static string prodPCS = 'Prism Virtual Data Room';
    
    
    
    static testMethod void testTask() 
    {
    	Product2 prod1 = GS_TestDataCreator.createProduct(prodGMG, false, false, 'BDA - 2111', 'ACV', 'GMG');
    	Product2 prod2 = GS_TestDataCreator.createProduct(prodCorp, false, false, 'SR', 'ACV', 'Corporate');
    	Product2 prod3 = GS_TestDataCreator.createProduct(prodPCS, false, false, 'PRI - VDR', 'ACV', 'PCS');
    
    	Contact c = GS_TestDataCreator.createContact('Test Contact For Task Products', a);
        	
        System.runAs(u)
        {
        	GS_TestDataCreator.createTask(u ,c, products);
        	list<Product_Interest__c> lstProdInt = [select id from Product_Interest__c where contact__c =: c.Id];
	        system.assertEquals(lstProdInt.size(), 3);
	        contact con = [select Corporate_Activity_Products__c, GMG_Activity_Products__c, 
	        					PCS_Activity_Products__c from contact where Id =: c.Id];
	        					
	        system.assertEquals(con.GMG_Activity_Products__c, 'BD Advanced (2111)');
	        system.assertEquals(con.Corporate_Activity_Products__c, 'Activist Intelligence (Shark Repellent)');
	        system.assertEquals(con.PCS_Activity_Products__c, 'Prism Virtual Data Room');			
        }
        
        //Negative case - contact without country
        c.MailingCountry = null;
        update c;
        
        System.runAs(u)
        {
        	try
        	{
        		GS_TestDataCreator.createTask(u ,c, products);
        	}
        	catch(Exception ex)
        	{
        		system.assertNotEquals(ex, null);
        	}
        }
        
    }
    
    static testMethod void testEvent() 
    {
    	Product2 prod1 = GS_TestDataCreator.createProduct(prodGMG, false, false, 'BDA - 2111', 'ACV', 'GMG');
    	Product2 prod2 = GS_TestDataCreator.createProduct(prodCorp, false, false, 'SR', 'ACV', 'Corporate');
    	Product2 prod3 = GS_TestDataCreator.createProduct(prodPCS, false, false, 'PRI - VDR', 'ACV', 'PCS');
    	
    	Contact c = GS_TestDataCreator.createContact('Test Contact For Event Products', a);
        	
        System.runAs(u)
        {
        	GS_TestDataCreator.createEvent(u , 100 , date.today() , c, products);
        	list<Product_Interest__c> lstProdInt = [select id from Product_Interest__c where contact__c =: c.Id];
	        system.assertEquals(lstProdInt.size(), 3);
	        contact con = [select Corporate_Activity_Products__c, GMG_Activity_Products__c, 
	        					PCS_Activity_Products__c from contact where Id =: c.Id];
	        					
	        system.assertEquals(con.GMG_Activity_Products__c, 'BD Advanced (2111)');
	        system.assertEquals(con.Corporate_Activity_Products__c, 'Activist Intelligence (Shark Repellent)');
	        system.assertEquals(con.PCS_Activity_Products__c, 'Prism Virtual Data Room');	
        }
        
        //Negative case - contact without country
        c.MailingCountry = null;
        update c;
        
        System.runAs(u)
        {
        	try
        	{
        		GS_TestDataCreator.createEvent(u , 100 , date.today() , c, products);
        	}
        	catch(Exception ex)
        	{
        		system.assertNotEquals(ex, null);
        	}
        }
    }
    
    static testMethod void testBatchClass()
    {
    	Product2 prod1 = GS_TestDataCreator.createProduct(prodGMG, false, false, 'BDA - 2111', 'ACV', 'GMG');
    	Product2 prod2 = GS_TestDataCreator.createProduct(prodCorp, false, false, 'SR', 'ACV', 'Corporate');
    	Product2 prod3 = GS_TestDataCreator.createProduct(prodPCS, false, false, 'PRI - VDR', 'ACV', 'PCS');
    	
    	Contact c = GS_TestDataCreator.createContact('Test Contact For Event Products', a);
        	
        GS_TestDataCreator.createEvent(u , 100 , date.today() , c, products);
        list<Product_Interest__c> lstProdInt = [select id from Product_Interest__c where contact__c =: c.Id];
        
        delete lstProdInt;
        
	    string query = 'select products__c, whoid, whoId__c from Event where products__c != null';

		GS_UpdateContactActivityProductsBatch batch = new GS_UpdateContactActivityProductsBatch(query);

		database.executeBatch(batch, 10);
		
		//Negative
		batch = new GS_UpdateContactActivityProductsBatch(query);
		batch.failureReasons = 'Insufficient Permission to delete';
        batch.failedRecCount = 1;
        database.executeBatch(batch, 10);
            
    }
}