global with sharing class BatchToUpdateAccountWithProdBundle  implements Database.Batchable<Sobject>{

       
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        //query to get only the opportunity records which needs to reset "Is_Close_Date_In_Current_Year__c" Field
        return Database.getQueryLocator([select id,Product_Bundle__c from Account]);
    }

    global void execute(Database.BatchableContext bc, List<Account> scope)
    {
    	//savepoint sp = database.setSavepoint();
    	list<Id> accountIds = new list<Id>();
    	for(account a : scope)
    	{
    		accountIds.add(a.Id);
    	}
    	
		map<Id,string> mapOfAccounts = GS_CommonUtility.getAccountProductBundle(accountIds,scope);
		
		list<account> lstUpdateAcc = new list<account>();
		
		for(account acc : scope)
		{
			string prodBundle = mapOfAccounts.get(acc.Id);
			acc.Product_Bundle__c = prodBundle;
		    lstUpdateAcc.add(acc);
		}
		update lstUpdateAcc;
		//database.rollback(sp);
    } 
    
    global void finish(Database.BatchableContext bc){
    
    }
}