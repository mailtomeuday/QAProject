global class GS_RefreshUpdateContacts implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select id, Email, BDEmail__c from Contact';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        if ([SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox || Test.isRunningTest()) {
        	for (Contact con : scope) {
            	if (con.Email != null)
        			con.Email += '.qa';
            
            	if (con.BDEmail__c != null)
        			con.BDEmail__c += '.qa';
        	}
        
			update scope;
        }	
    }   
    
    global void finish(Database.BatchableContext BC) {
    }
}