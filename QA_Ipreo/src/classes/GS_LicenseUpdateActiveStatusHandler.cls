/**************************************************************************************************
 * Name           : GS_LicenseUpdateActiveStatusHandler
 * Object         : License
 * Requirement    : STY-00012
 * Target         : A formula field Auto_Populated_Active_Status__c has been created to check license status. This class will update another field
 *                  align the formula field.
 * Refer classes  : 
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-06-03
 * Modify History :
 **************************************************************************************************/
public class GS_LicenseUpdateActiveStatusHandler {
    public static void updateStatus() {

		List<Asset_License__c> listLicense;
		List<Asset_License__c> listTargetLicense;

		listTargetLicense = new List<Asset_License__c>();
		listLicense = [SELECT Id
			                ,Status__c
			                ,Auto_Populated_Active_Status__c
			          FROM Asset_License__c
			          WHERE Active_Need_to_Be_Updated__c = true
			          Limit 3000];

		for(Asset_License__c tempLicense : listLicense) {
			tempLicense.Status__c = tempLicense.Auto_Populated_Active_Status__c ? 'Active' : 'Inactive';
			listTargetLicense.add(tempLicense);
		}

		update listTargetLicense;
	}
}