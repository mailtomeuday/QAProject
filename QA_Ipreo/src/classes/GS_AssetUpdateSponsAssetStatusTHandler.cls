/**************************************************************************************************
 * Name           : GS_AssetUpdateSponsAssetStatusTHandler
 * Object         : Asset/Sponsored Asset
 * Requirement    : STY-00101
 * Target         : When Asset status is changed, update the Sponsored Asset status
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-09-10
 * Modify History :
 **************************************************************************************************/
public class GS_AssetUpdateSponsAssetStatusTHandler implements GS_Triggers.Handler {
    public void handle() {

    	Set<Id> stChangedAssetId = new Set<Id>();
    	Map<Id, Asset> newAssetMap = (Map<Id, Asset>)Trigger.newMap;
    	Map<Id, Asset> oldAssetMap = (Map<Id, Asset>)Trigger.oldMap;

    	// Get asset id whose status is changed.
    	for(Id astId : Trigger.newMap.keySet()) {
    		if(newAssetMap.get(astId).Status != oldAssetMap.get(astId).Status) {
    			stChangedAssetId.add(astId);
    		}
    	}

    	if(!stChangedAssetId.isEmpty()) {
    		updateSponAssetStatus(stChangedAssetId);
    	}
    }

    private void updateSponAssetStatus(Set<Id> changedAssetIds){

    	List<Sponsored_Asset__c> lstTargetSponAst = new List<Sponsored_Asset__c>();

    	for(Asset tempAsset : GS_AssetDMLHandler.getSponAssetByAssetIds(changedAssetIds)) {
    		for(Sponsored_Asset__c tempSponAst : tempAsset.Sponsored_Accounts__r) {
    			if(tempAsset.Status == 'Active' && !tempSponAst.Active__c) {
    				tempSponAst.Active__c = true;
    				lstTargetSponAst.add(tempSponAst);
    			} else if(tempAsset.Status != 'Active' && tempSponAst.Active__c) {
    				tempSponAst.Active__c = false;
    				lstTargetSponAst.add(tempSponAst);
    			}
    		}
    	}

    	update lstTargetSponAst;
    }
}