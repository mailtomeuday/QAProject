/**************************************************************************************************
 * Name           : GS_AssetUpdateACCRAGScoreTHandler
 * Object         : Asset/Account
 * Requirement    : SPS-1506
 * Target         : When Current RAG Status on Asset changes, Recalculate avg RAG Score on Account.
 * Refer classes  :
 * Author         : Joshi (ambadas_morkhandikar@epam.com)
 * Create Date    : 2017-02-13
 * Modify History :
 **************************************************************************************************/
 
public with sharing class GS_AssetUpdateACCRAGScoreTHandler implements GS_Triggers.Handler {
    
    public void handle() {
        
        map<Id,Asset> currentRecordsMap;
        
        if(trigger.newMap != null)
        {
            currentRecordsMap = (map<Id,Asset>)trigger.newMap;
        }
        else if(trigger.oldMap != null)
        {
            currentRecordsMap = (map<Id,Asset>)trigger.oldMap;
        }
        system.debug('currentRecordsMap------------>>>'+currentRecordsMap);
        map<Id, List<Asset>> mapOfAccountToAssets;
        mapOfAccountToAssets = new map<Id, List<Asset>>();
        set<Id> accountIdSet = new Set<Id>();
        
        for (Id tempAssetId : currentRecordsMap.keyset()) {
            Asset objAsset = (Asset)currentRecordsMap.get(tempAssetId);
            accountIdSet.add(objAsset.AccountId);
        }
        
        list<Asset> lstAllAssets = [Select Id, accountId, Current_RAG_Status__c from Asset where accountId in: accountIdSet and Status =: 'Active'];
        
        list<Account> upateAccountlist = new list<Account>();
        
        if(lstAllAssets != null && lstAllAssets.size() > 0){
	        for(Asset objAsset : lstAllAssets)
	        {    
	        	List<Asset> tempList;
	            
	            if(mapOfAccountToAssets.containsKey(objAsset.accountId)){
	                tempList = mapOfAccountToAssets.get(objAsset.accountId);
	            }
	            else{
	                tempList = new List<Asset>();
	            }
	            tempList.add(objAsset);
	            mapOfAccountToAssets.put(objAsset.accountId, tempList);
	        }
        
        	for(Id accId : mapOfAccountToAssets.keyset()){
            	upateAccountlist.add(calculateAverageRAGStatus(accId, mapOfAccountToAssets.get(accId)));
        	}
        }
        else{
        	for(Id accId : accountIdSet)
        	{
        		Account acc = new Account();
        		acc.Id = accId;
        		acc.RAG_Status_Summary__c = null;
        		
        		upateAccountlist.add(acc);
        	}
        }
        
        if(upateAccountlist.size() > 0){
            update upateAccountlist;
        }
        
    }
    
    /*
    * Purpose: This method is for calculating the RAG Status Summary by capturing unique RAG Status values from all the Assets on that Account
    * Parameters: Id AccountId, list<Asset> list of all assets on that Account
    * Return: Account with the RAG_Status_Summary__c value set on it. 
    */
    private Account calculateAverageRAGStatus(Id accId, list<Asset> lstAsset)
    {
    	List<string> lstUniqueRAGStatus = new string[3];
    	
        if(lstAsset != null && lstAsset.size() > 0){
            for(integer i=0; i< lstAsset.size(); i++){
                if(!String.IsBlank(lstAsset[i].Current_RAG_Status__c)){
                	if(lstAsset[i].Current_RAG_Status__c.equalsIgnoreCase('Red') && String.isBlank(lstUniqueRAGStatus[0])){
                		lstUniqueRAGStatus[0] = 'Red';
                	}
                	if(lstAsset[i].Current_RAG_Status__c.equalsIgnoreCase('Amber') && String.isBlank(lstUniqueRAGStatus[1])){
                		lstUniqueRAGStatus[1] = 'Amber';
                	}
                	if(lstAsset[i].Current_RAG_Status__c.equalsIgnoreCase('Green') && String.isBlank(lstUniqueRAGStatus[2])){
                		lstUniqueRAGStatus[2] = 'Green';
                	}
                }
            }
        }
        
        Account acc = new Account();
		acc.Id = accId;
        acc.RAG_Status_Summary__c = getRAGSummary(lstUniqueRAGStatus);
        
        return acc;
    }
    
    /*
    * Purpose: This method builds the RAG Status Summary string to be set to the field RAG_Status_Summary__c on Account object
    * Parameters: list<string> containing the unique RAG Status values
    * Return: String with the RAG Status summary, something like Red-Amber-Green
    */
    private string getRAGSummary(List<string> lstUniqueRAGStatus)
    {
    	string strRAGSummary = '';
    	
    	strRAGSummary += !String.isBlank(lstUniqueRAGStatus[0]) ? lstUniqueRAGStatus[0] + '-' : '';
    	strRAGSummary += !String.isBlank(lstUniqueRAGStatus[1]) ? lstUniqueRAGStatus[1] + '-' : '';
    	strRAGSummary += !String.isBlank(lstUniqueRAGStatus[2]) ? lstUniqueRAGStatus[2] : '';
		strRAGSummary = strRAGSummary.removeEnd('-');
		
    	return strRAGSummary; 
    }

}