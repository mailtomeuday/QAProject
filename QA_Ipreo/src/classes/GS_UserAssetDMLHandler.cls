/**************************************************************************************************
 * Name           : GS_UserAssetDMLHandler
 * Object         : User Asset
 * Requirement    : 
 * Target         : DML on User Asset
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-12-03
 * Modify History :
 **************************************************************************************************/
public class GS_UserAssetDMLHandler {
    
	public static List<User_Asset__c> getUserAssetsByAssetIds(Set<Id> assetIds) {
		return [SELECT Id
					  ,User__c
					  ,Asset__c
				FROM User_Asset__c
				WHERE Asset__c in: assetIds
				LIMIT 9999];
	}

}