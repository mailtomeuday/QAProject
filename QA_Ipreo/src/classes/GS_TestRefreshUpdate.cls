@isTest
private class GS_TestRefreshUpdate {
    static testMethod void GS_RefreshUpdateContacts() {
    	Account acc = new Account(Name='TestAcc01');
    	insert acc;
    	Contact con = new Contact(FirstName='John', LastName='Smith', Email='John.Smith@testipreo.com', BDEmail__c='John.Smith@testipreo.com');
    	insert con;
    	
    	Test.startTest();
    	GS_RefreshUpdateContacts batch = new GS_RefreshUpdateContacts();
		Database.executeBatch(batch);
		Test.stopTest();
    }

    static testMethod void GS_RefreshUpdateLeads() {
    	Lead lead = new Lead(FirstName='John', LastName='Smith', Email='John.Smith@testipreo.com', BDEmail__c='John.Smith@testipreo.com', Company='Test_Company');
    	insert lead;
    	
    	Test.startTest();
    	GS_RefreshUpdateLeads batch = new GS_RefreshUpdateLeads();
		Database.executeBatch(batch);
		Test.stopTest();
    }    
}