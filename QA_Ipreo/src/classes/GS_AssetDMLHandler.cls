/**************************************************************************************************
 * Name           : GS_AssetDMLHandler
 * Object         : Asset
 * Requirement    : 
 * Target         : DML on Asset
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-07-06
 * Modify History :
 **************************************************************************************************/
public class GS_AssetDMLHandler {

    // Get Asset records and its associated user assets by Asset Ids
    public static List<Asset> getAssetsWithUserAssetsByIds(Set<Id> setAssetIds) {
    	return [SELECT Id
    				  ,Name
    				  ,Status
    				  ,(SELECT Id
    				  		 ,Name
    				  		 ,Active__c
    				  		 ,Asset__c
    				  		 ,User__c
    				   FROM User_Assets__r)
    			FROM Asset
    			WHERE Id in: setAssetIds];
    }

    // Get Asset records by Id
    public static List<Asset> getAssetsByIds(Set<Id> setAssetIds) {
        return [SELECT Id
                      ,Name
                      ,AccountId
                      ,Status
                FROM Asset
                WHERE Id in: setAssetIds];
    }


    // Get Sponsored Asset by Asset Id
    public static List<Asset> getSponAssetByAssetIds(Set<Id> setAssetIds) {
        return [SELECT Id
                      ,Name
                      ,Status
                      ,(SELECT Id
                              ,Active__c
                        FROM Sponsored_Accounts__r)
                FROM Asset
                WHERE Id in: setAssetIds];
    }
}