/**************************************************************************************************
 * Name           : GS_AssetAssignValueTHandler
 * Object         : Asset
 * Requirement    :
 * Target         : Trigger handlers are bound in this trigger. This handler is used to
 * 					update fields of asset
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2016-02-25
 * Modify History : 1. Add function updateAccountProductRegionKey.
 * 					   AccountProductRegionKey is made up of AccountId + '_' + Product2Id + '_' + Product_Region__c
 **************************************************************************************************/
public class GS_AssetAssignValueTHandler implements GS_Triggers.Handler {

	public Map<Id, Asset> mapNewAsset;
	public Map<Id, Asset> mapOldAsset;

	public void handle() {

		// Assign asset maps from context.
		if (Trigger.isInsert && Trigger.isAfter) {
			mapNewAsset = (Map<Id, Asset>)Trigger.newMap;
		} else if (Trigger.isUpdate) {
			mapNewAsset = (Map<Id, Asset>)Trigger.newMap;
			mapOldAsset = (Map<Id, Asset>)Trigger.oldMap;
		}

		if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
			updateAccountProductRegionKey();
		}
	}

	// Assign AccountProductRegionKey__c
	private void updateAccountProductRegionKey() {

		String strSeprator = '_';
		String strAccId = '';
		String strProId = '';
		String strRegion = '';

		// When insert an asset, update AccountProductRegionKey__c
		if(Trigger.isInsert) {
			for(Asset ast : (List<Asset>)Trigger.New) {

				strAccId = ast.AccountId != NULL ? String.valueOf(ast.AccountId) : '';
				strProId = ast.Product2Id != NULL ? String.valueOf(ast.Product2Id) : '';
				strRegion = ast.Product_Region__c != NULL ? String.valueOf(ast.Product_Region__c) : '';

				ast.AccountProductRegionKey__c = strAccId + strSeprator + strProId + strSeprator + strRegion;
			}
		// When update an asset, check if the accountid, productid or the product region is changed, if changed update AccountProductRegionKey__c
		} else if (Trigger.isUpdate) {

			for(Id astId : mapNewAsset.keySet()) {

				if(mapNewAsset.get(astId).AccountId != mapOldAsset.get(astId).AccountId ||
				   mapNewAsset.get(astId).Product2Id != mapOldAsset.get(astId).Product2Id ||
				   mapNewAsset.get(astId).Product_Region__c != mapOldAsset.get(astId).Product_Region__c) {

					strAccId = mapNewAsset.get(astId).AccountId != NULL ? String.valueOf(mapNewAsset.get(astId).AccountId) : '';
					strProId = mapNewAsset.get(astId).Product2Id != NULL ? String.valueOf(mapNewAsset.get(astId).Product2Id) : '';
					strRegion = mapNewAsset.get(astId).Product_Region__c != NULL ? String.valueOf(mapNewAsset.get(astId).Product_Region__c) : '';

					mapNewAsset.get(astId).AccountProductRegionKey__c = strAccId + strSeprator + strProId + strSeprator + strRegion;
				}
			}
		}
	}
}