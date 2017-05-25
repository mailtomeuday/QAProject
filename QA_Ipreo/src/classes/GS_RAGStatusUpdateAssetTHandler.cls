/**************************************************************************************************
 * Name           : GS_RAGStatusUpdateAssetTHandler
 * Object         : RAG Status/Asset
 * Requirement    : SPS-1506
 * Target         : Update Current RAG Status and Previous RAG Status fields on Asset, 
 *					each time RAG Status record is added, changed, deleted.
 * Refer classes  :
 * Author         : Joshi (ambadas_morkhandikar@epam.com)
 * Create Date    : 2016-12-21
 * Modify History :
 **************************************************************************************************/
public with sharing class GS_RAGStatusUpdateAssetTHandler  implements GS_Triggers.Handler {
	
	public void handle() {
		map<Id,RAG_Status__c> currentRecordsMap;
		
		if(trigger.newMap != null)
		{
			currentRecordsMap = (map<Id,RAG_Status__c>)trigger.newMap;
		}
		else if(trigger.oldMap != null)
		{
			currentRecordsMap = (map<Id,RAG_Status__c>)trigger.oldMap;
		}
		
		if(currentRecordsMap != null){
			
			Set<Id> assetIdSet = new Set<Id>();
			
			for(Id key : currentRecordsMap.keyset())
			{
				RAG_Status__c objRAGStatus = currentRecordsMap.get(key);
				assetIdSet.add(objRAGStatus.Asset__c);
			}
			
			list<Asset> lstAssetsToUpdate = new list<Asset>();
			map<Id, list<RAG_Status__c>> mapOfAssetRAGHistory =  new map<Id, list<RAG_Status__c>>();
			
			list<RAG_Status__c> lstAllRAGStatus = [select Asset__c, Asset__r.Current_RAG_Status__c, Asset__r.Account.Id, 
														Description__c, RAG_Status__c,LastModifiedDate 
															from RAG_Status__c where Asset__c in: assetIdSet order by CreatedDate Desc];
			
			if(lstAllRAGStatus != null && lstAllRAGStatus.size() > 0){
				for(RAG_Status__c objRAGStatus : lstAllRAGStatus)
				{
					list<RAG_Status__c> lstTempRAGStatus;
					if(mapOfAssetRAGHistory.containsKey(objRAGStatus.Asset__c)){
						lstTempRAGStatus = mapOfAssetRAGHistory.get(objRAGStatus.Asset__c);
					}
					else{
						lstTempRAGStatus = new list<RAG_Status__c>();
					}
					
					lstTempRAGStatus.add(objRAGStatus);
					mapOfAssetRAGHistory.put(objRAGStatus.Asset__c, lstTempRAGStatus);
				}
				
				for(Id assetId : mapOfAssetRAGHistory.keyset()){
					lstAssetsToUpdate.add(updateCurrAndPrevRAGStatus(assetId, mapOfAssetRAGHistory.get(assetId)));
				}
			}
			else{
				
				for(Id assetId : assetIdSet){
					
					Asset objAsset = new Asset();
					
					objAsset.Id = assetId;
					objAsset.Current_RAG_Status__c = null;
					objAsset.Current_RAG_Status_Description__c = null;
					objAsset.Current_RAG_Status_Last_Modified_Date__c = null;
					objAsset.Previous_RAG_Status__c = null;
					objAsset.Previous_RAG_Status_Description__c =  null;
					objAsset.Previous_RAG_Status_Last_Modified_Date__c = null;
					
					lstAssetsToUpdate.add(objAsset);
				}
			}
			
			if(lstAssetsToUpdate.size() > 0){
				update lstAssetsToUpdate;
			}
		}
	}
	
	private Asset updateCurrAndPrevRAGStatus(Id assetId, list<RAG_Status__c> lstRAGStatus)
	{
		Asset asset;
		asset = new Asset();
		asset.Id = assetId;
			
		if(lstRAGStatus != null && lstRAGStatus.size() > 0){
			
			if(lstRAGStatus.size() == 1){
				asset.Current_RAG_Status__c = lstRAGStatus[0].RAG_Status__c;
				asset.Current_RAG_Status_Description__c = lstRAGStatus[0].Description__c;
				asset.Current_RAG_Status_Last_Modified_Date__c = lstRAGStatus[0].LastModifiedDate.date();
				asset.Previous_RAG_Status__c = null;
				asset.Previous_RAG_Status_Description__c =  null;
				asset.Previous_RAG_Status_Last_Modified_Date__c = null;
			}
			else if(lstRAGStatus.size() > 1){
				asset.Current_RAG_Status__c = lstRAGStatus[0].RAG_Status__c;
				asset.Current_RAG_Status_Description__c = lstRAGStatus[0].Description__c;
				asset.Current_RAG_Status_Last_Modified_Date__c = lstRAGStatus[0].LastModifiedDate.date();
				asset.Previous_RAG_Status__c = lstRAGStatus[1].RAG_Status__c;
				asset.Previous_RAG_Status_Description__c = lstRAGStatus[1].Description__c;
				asset.Previous_RAG_Status_Last_Modified_Date__c = lstRAGStatus[1].LastModifiedDate.date();
			}
			
		}
		else{
				asset.Current_RAG_Status__c = null;
				asset.Current_RAG_Status_Description__c = null;
				asset.Current_RAG_Status_Last_Modified_Date__c = null;
				asset.Previous_RAG_Status__c = null;
				asset.Previous_RAG_Status_Description__c =  null;
				asset.Previous_RAG_Status_Last_Modified_Date__c = null;
			
		}
		
		
		return asset;
	}
	
}