global class GS_RefreshUpdateLeads implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select id, Email, BDEmail__c from Lead where IsConverted = false';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Lead> scope) {
        if ([SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox || Test.isRunningTest()) {
            for (Lead lead : scope) {
                if (lead.Email != null)
                    lead.Email += '.qa';
            
                if (lead.BDEmail__c != null)
                    lead.BDEmail__c += '.qa';
            }
        
            update scope;
        }   
    }   
    
    global void finish(Database.BatchableContext BC) {
    }
}