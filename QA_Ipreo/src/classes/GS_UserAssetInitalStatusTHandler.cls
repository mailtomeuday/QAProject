/**************************************************************************************************
 * Name           : GS_UserAssetInitalStatusTHandler
 * Object         : User Asset
 * Requirement    : STY-00012
 * Target         : When user asset is created, assign value to Status by Asset status.
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-06-07
 * Modify History :
 **************************************************************************************************/
public class GS_UserAssetInitalStatusTHandler implements GS_Triggers.Handler {

	public void handle(){
		if(Trigger.isInsert) {

			Set<Id> setAssetIds = new Set<Id>();
			Map<Id, Asset> mapAssets = new Map<Id, Asset>();

			for(User_Asset__c tempUserAsset : (List<User_Asset__c>)Trigger.new){
				if(!setAssetIds.contains(tempUserAsset.Id)){
					setAssetIds.add(tempUserAsset.Asset__c);
				}
			}

			if(setAssetIds.size() > 0){
				mapAssets = new Map<Id, Asset>(GS_AssetDMLHandler.getAssetsByIds(setAssetIds));
				System.debug(LoggingLevel.INFO, '*** mapAssets: ' + mapAssets);
				for(User_Asset__c tempUserAsset : (List<User_Asset__c>)Trigger.new){
					tempUserAsset.Active__c = mapAssets.get(tempUserAsset.Asset__c).Status;
				}
			}			
		}
	}
    
}