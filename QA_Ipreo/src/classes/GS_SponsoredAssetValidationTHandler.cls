/**************************************************************************************************
 * Name           : GS_SponsoredAssetValidationTHandler
 * Object         : Sponsored_Asset__c
 * Requirement    :
 * Target         : Add validation here
 * Refer classes  :
 * Author         : Ambadas Joshi M <ambadas_morkhandikar@epam.com>
 * Create Date    : 2016-06-06
 * Modify History :
 **************************************************************************************************/
public with sharing class GS_SponsoredAssetValidationTHandler implements GS_Triggers.Handler {
	
	public void handle() {
        validateSponsoredAssetUnique();
    }
	
	//only one sponsored asset with single account-asset combination
	private void validateSponsoredAssetUnique() {

        Set<string> assetNames = new Set<string>();

        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                for (SObject tempObj : Trigger.new) {
                    if (tempObj.get('Asset_Name__c') != NULL) {
                        assetNames.add(String.valueOf(tempObj.get('Asset_Name__c')));
                    }
                }

                if (!assetNames.isEmpty()) {
                    // queried by Asset names, it will be looped and check if there's a duplicate sponsored asset
                    for (Sponsored_Asset__c item : GS_SponsoredAssetDMLHandler.getSponsoredAssetsByAssetNames(assetNames)) {
                        for (SObject tempObj : Trigger.new) {
                            if (    tempObj.get('Asset_Name__c') == item.Asset_Name__c
                                    && tempObj.get('Account_Name__c') == item.Account_Name__c) {
                                tempObj.addError(System.Label.Msg_Duplicate_Sponsored_Assets);
                            }
                        }
                    }
                }
            } else if (Trigger.isUpdate) {

                for (SObject tempObj : Trigger.new) {
                    if (tempObj.get('Asset_Name__c') != NULL) {
                        assetNames.add(String.valueOf(tempObj.get('Asset_Name__c')));
                    }
                }

                if (!assetNames.isEmpty()) {
                    Map<Id, Sponsored_Asset__c> mapSponsoredAssetsByAssets = new Map<Id, Sponsored_Asset__c>(GS_SponsoredAssetDMLHandler.getSponsoredAssetsByAssetNames(assetNames));

                    // before check the value, since the updated records are involved in the queried sponsored assets.
                    // so remove first.
                    for (SObject tempObj : Trigger.new) {
                        mapSponsoredAssetsByAssets.remove(String.valueOf(tempObj.get('Id')));
                    }

                    for (Id usId : mapSponsoredAssetsByAssets.keySet()) {
                        for (SObject tempObj : Trigger.new) {
                            if (    tempObj.get('Asset_Name__c') == mapSponsoredAssetsByAssets.get(usId).Asset_Name__c
                                    && tempObj.get('Account_Name__c') == mapSponsoredAssetsByAssets.get(usId).Account_Name__c) {
                                tempObj.addError(System.Label.Msg_Duplicate_Sponsored_Assets);
                            }
                        }
                    }
                }
            }
        }
	}
}