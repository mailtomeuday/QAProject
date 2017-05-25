/**************************************************************************************************
 * Name           : GS_UserAssetAssignAccTHandler
 * Object         : User Asset
 * Requirement    : 
 * Target         : When user asset is created or Asset is changed, assign value to Asset Account.
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-10-08
 * Modify History :
 **************************************************************************************************/
public class GS_UserAssetAssignAccTHandler implements GS_Triggers.Handler{
    public void handle() {

    	Set<Id> assetIds = new Set<Id>();
    	// key is asset id value is asset
    	Map<Id, Asset> mapAsset = new Map<Id, Asset>();

    	// get asset id from user asset to query account id of asset
    	if(Trigger.isInsert) {
	    	for(User_Asset__c userAssert : (List<User_Asset__c>)Trigger.new) {
	    		assetIds.add(userAssert.Asset__c);
	    	}
	    // if update, only get assetid when the asset is changed.
	    } else if (Trigger.isUpdate) {
	    	for(Id userAssertId : Trigger.newMap.keySet()) {
	    		if(((User_Asset__c)Trigger.newMap.get(userAssertId)).Asset__c != ((User_Asset__c)Trigger.oldMap.get(userAssertId)).Asset__c) {
	    			assetIds.add(((User_Asset__c)Trigger.newMap.get(userAssertId)).Asset__c);
	    		}
	    	}
	    }

	    // query asset
    	mapAsset = new Map<Id, Asset>(GS_AssetDMLHandler.getAssetsByIds(assetIds));

    	// assign account id from asset.accountid to user asset.asset_account
    	for(User_Asset__c temp : (List<User_Asset__c>)Trigger.new){
            System.debug(LoggingLevel.INFO, '*** temp.Asset__c: ' + temp.Asset__c);
    		if(mapAsset.get(temp.Asset__c) != NULL && temp.Asset_Account__c == NULL ){
    			temp.Asset_Account__c = mapAsset.get(temp.Asset__c).AccountId;
    		}
    	}
    }
}