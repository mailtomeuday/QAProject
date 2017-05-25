/**************************************************************************************************
 * Name           : GS_SponsoredAssetDMLHandler
 * Object         : User Asset
 * Requirement    : 
 * Target         : DML on User Asset
 * Refer classes  :
 * Author         : Ambadas Joshi M <ambadas_morkhandikar@epam.com>
 * Create Date    : 2016-06-06
 * Modify History :
 **************************************************************************************************/

public class GS_SponsoredAssetDMLHandler {
	
	public static List<Sponsored_Asset__c> getSponsoredAssetsByAssetNames(Set<string> assetNames) {
		return [SELECT Id
					  ,Name
					  ,Asset_Name__c
					  ,Account_Name__c
					  ,Active__c
				FROM Sponsored_Asset__c
				WHERE Asset_Name__c in: assetNames
				LIMIT 9999];
	}

}