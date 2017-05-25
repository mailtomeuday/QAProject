/**************************************************************************************************
 * Name           : GS_UserAssetValidationTHandler
 * Object         : User Asset
 * Requirement    :
 * Target         : Add validation here
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-12-03
 * Modify History :
 **************************************************************************************************/
public class GS_UserAssetValidationTHandler implements GS_Triggers.Handler {

    public void handle() {
        validateUserAssetUnique();
        validateContact();
    }

    // No duplicated user assets for a contact
    // Please take care when the field name is changed.
    private void validateUserAssetUnique() {

        Set<Id> assetIds = new Set<Id>();

        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                for (SObject tempObj : Trigger.new) {
                    if (tempObj.get('Asset__c') != NULL) {
                        assetIds.add(String.valueOf(tempObj.get('Asset__c')));
                    }
                }
				Map<String, User_Asset__c> allExistingUAMap;
                if (!assetIds.isEmpty()) {
                    // queried by Asset ids, it will be looped and check if there's a duplicate user asset
                    /*for (User_Asset__c item : GS_UserAssetDMLHandler.getUserAssetsByAssetIds(assetIds)) {
                        for (SObject tempObj : Trigger.new) {
                            if (    tempObj.get('Asset__c') == item.Asset__c
                                    && tempObj.get('User__c') == item.User__c) {
                                tempObj.addError(System.Label.Msg_Cannot_Create_Duplicate_User_Assets);
                            }
                        }
                    }*/
                    /*Removed nested for loop to check duplicates. Used AssetID and ContactID as Key to check duplicates */
                    allExistingUAMap = new Map<String, User_Asset__c>();
                    for (User_Asset__c item : GS_UserAssetDMLHandler.getUserAssetsByAssetIds(assetIds)){
                    	String key = item.Asset__c+'_'+item.User__c;
                    	allExistingUAMap.put(key,item);
                    }
                    for (SObject tempObj : Trigger.new){
                    	String dupKey = tempObj.get('Asset__c')+'_'+tempObj.get('User__c');
                    	if(allExistingUAMap.containsKey(dupKey)){
                    		tempObj.addError(System.Label.Msg_Cannot_Create_Duplicate_User_Assets);	
                    	}
                    }
                }
            } else if (Trigger.isUpdate) {
				List<User_Asset__c> listUserORAssetUpdated;
                for (SObject tempObj : Trigger.new) {
                    listUserORAssetUpdated = new List<User_Asset__c>();
                    if (tempObj.get('Asset__c') != NULL) {
                        assetIds.add(String.valueOf(tempObj.get('Asset__c')));
                        User_Asset__c uaAsset = (User_Asset__c)tempObj;
                        User_Asset__c olduaAsset = (User_Asset__c)Trigger.oldMap.get(uaAsset.Id);
                        if(uaAsset != null && olduaAsset != null && (uaAsset.Asset__c != olduaAsset.Asset__c || uaAsset.User__c != olduaAsset.User__c)){
                        	listUserORAssetUpdated.add(uaAsset);
                        }
                    }
                }
                /* Check if any Asset/Contact is updated for User Asset*/
                if(listUserORAssetUpdated.size() == 0){
                	return;
                }
				Map<String, User_Asset__c> allExistingUAMap;
                if (!assetIds.isEmpty()) {
                    Map<Id, User_Asset__c> mapUserAssetsByAssets = new Map<Id, User_Asset__c>(GS_UserAssetDMLHandler.getUserAssetsByAssetIds(assetIds));

                    // before check the value, since the updated records are involved in the queried user assets.
                    // so remove first.
                    for (SObject tempObj : Trigger.new) {
                        mapUserAssetsByAssets.remove(String.valueOf(tempObj.get('Id')));
                    }

                    /*for (Id usId : mapUserAssetsByAssets.keySet()) {
                        Boolean isExisting = FALSE;
                        for (SObject tempObj : Trigger.new) {
                            if (    tempObj.get('Asset__c') == mapUserAssetsByAssets.get(usId).Asset__c
                                    && tempObj.get('User__c') == mapUserAssetsByAssets.get(usId).User__c) {
                                tempObj.addError(System.Label.Msg_Cannot_Create_Duplicate_User_Assets);
                            }
                        }
                    }*/
                    /*Removed nested for loop to check duplicates. Used AssetID and ContactID as Key to check duplicates */
                    allExistingUAMap = new Map<String, User_Asset__c>();
                    for (Id usId : mapUserAssetsByAssets.keySet()) {
                    	User_Asset__c item = mapUserAssetsByAssets.get(usId);
                    	if(item != null){
	                    	String key = item.Asset__c+'_'+item.User__c;
	                    	allExistingUAMap.put(key,item);	
                    	}
                    	
                    }
                    for (SObject tempObj : Trigger.new){
                    	String dupKey = tempObj.get('Asset__c')+'_'+tempObj.get('User__c');
                    	if(allExistingUAMap.containsKey(dupKey)){
                    		tempObj.addError(System.Label.Msg_Cannot_Create_Duplicate_User_Assets);	
                    	}
                    }                    
                }
            }
        }
    }

    // Contact can only be selected from related accounts
    // Asset Account, Sponsored Account, Consulting Account
    private void validateContact() {

        if (Trigger.isAfter && Trigger.isInsert) {

            // Key is asset id, value is Sponsored_Users_Account__c id,
            Map<Id, Set<Id>> mapAssIdSponAccId = new Map<Id, Set<Id>>();

            // Key is asset id, value is Consulting_Company_Account__c id,
            Map<Id, Set<Id>> mapClientAccIdConsultantAccId = new Map<Id, Set<Id>>();

            // Query all sponsored users assets which are related to the current assets
            List<Sponsored_Asset__c> lstSponsoredAssets = new List<Sponsored_Asset__c>();

            // Query all Consultant Accounts which are related to the current Account
            List<Consulting_Company__c> lstConsultantCompanies = new List<Consulting_Company__c>();

            // Store all Asset Id from User Assets
            Set<Id> stAssetId = new Set<Id>();

            // Store all Account Id from User Assets
            Set<Id> stAccId = new Set<Id>();

            // Store new user asset list, to get the User__r.AccountId from user asset
            List<User_Asset__c> lstNewUserAssets = new List<User_Asset__c>();

            // Get all Asset Id from User Assets
            for (User_Asset__c ua : (List<User_Asset__c>)Trigger.new) {
                if (!stAssetId.contains(ua.Asset__c)) {
                    stAssetId.add(ua.Asset__c);
                }
            }

            // Get value by stAssetId and user asset id
            lstSponsoredAssets = [SELECT Id, Account_Name__c, Asset_Name__c FROM Sponsored_Asset__c WHERE Asset_Name__c IN :stAssetId];
            lstNewUserAssets = [SELECT Id, User__c, Is_Sponsored_User__c, Is_Consultant__c, User__r.AccountId, Asset__c, Asset__r.AccountId, Consultant_Account__c FROM User_Asset__c WHERE Id IN : Trigger.newMap.keySet()];

            // lstNewUserAssets is queried with the accountid and it can be assigned to stAccId
            for (User_Asset__c ua : lstNewUserAssets) {
                stAccId.add(ua.Asset__r.AccountId);
            }

            lstConsultantCompanies = [SELECT Id, Client_Account__c, Consulting_Company_Account__c FROM Consulting_Company__c where Client_Account__c = : stAccId];

            // Map<Asset Id, Set<Account>> from Sponsored_Asset__c
            if (lstSponsoredAssets.size() > 0) {
                for (Sponsored_Asset__c sponAsset : lstSponsoredAssets) {
                    if (sponAsset.Account_Name__c != NULL) {
                        if (!mapAssIdSponAccId.containsKey(sponAsset.Asset_Name__c)) {
                            Set<Id> tempId = new Set<Id>();
                            tempId.add(sponAsset.Account_Name__c);
                            mapAssIdSponAccId.put(sponAsset.Asset_Name__c, tempId);
                        } else {
                            Set<Id> tempId = mapAssIdSponAccId.get(sponAsset.Asset_Name__c);
                            if (!tempId.contains(sponAsset.Account_Name__c)) {
                                tempId.add(sponAsset.Account_Name__c);
                            }
                        }
                    }

                }
            }


            // Map<Client Account Id, Set<Consultant Account Id>> from Consulting_Company__c
            if (lstConsultantCompanies.size() > 0) {
                for (Consulting_Company__c conCompany : lstConsultantCompanies) {
                    if (conCompany.Consulting_Company_Account__c != NULL) {
                        if (!mapClientAccIdConsultantAccId.containsKey(conCompany.Client_Account__c)) {
                            Set<Id> tempId = new Set<Id>();
                            tempId.add(conCompany.Consulting_Company_Account__c);
                            mapClientAccIdConsultantAccId.put(conCompany.Client_Account__c, tempId);
                        } else {
                            Set<Id> tempId = mapClientAccIdConsultantAccId.get(conCompany.Client_Account__c);
                            if (!tempId.contains(conCompany.Consulting_Company_Account__c)) {
                                tempId.add(conCompany.Consulting_Company_Account__c);
                            }
                        }
                    }

                }
            }

            System.debug(LoggingLevel.INFO, '*** mapClientAccIdConsultantAccId: ' + mapClientAccIdConsultantAccId);

            // This list is used to assign the Sponsored_Users_Account__c
            List<User_Asset__c> lstTargetUserAsset = new List<User_Asset__c>();

            for (User_Asset__c ua : lstNewUserAssets) {
                // Check if the contact is from the asset's account
                if (    ua.Asset__r.AccountId != ua.User__r.AccountId) {
                    // Check if the contact is from the sponsored account or consultant account
                    if ((mapAssIdSponAccId.get(ua.Asset__c) == null || mapAssIdSponAccId.get(ua.Asset__c).size() == 0) && (mapClientAccIdConsultantAccId.get(ua.Asset__r.AccountId) == null || mapClientAccIdConsultantAccId.get(ua.Asset__r.AccountId).size() == 0)) {
                        Trigger.newMap.get(ua.Id).addError(System.label.Msg_Assign_User_Err);
                    } else {
                        Boolean isValid = false;

                        if(mapAssIdSponAccId.get(ua.Asset__c) != null){
                            for (Id accId : mapAssIdSponAccId.get(ua.Asset__c)) {
                                if (accId == ua.User__r.AccountId) {
                                    isValid = true;

                                    // Check sponsored User Account
                                    if (ua.Is_Sponsored_User__c){
                                        ua.Sponsored_Users_Account__c = accId;
                                    }

                                    lstTargetUserAsset.add(ua);
                                    break;
                                }
                            }
                        }

                        if(mapClientAccIdConsultantAccId.get(ua.Asset__r.AccountId) != null){
                            for (Id accId : mapClientAccIdConsultantAccId.get(ua.Asset__r.AccountId)) {
                                if (accId == ua.User__r.AccountId) {
                                    isValid = true;

                                    // Check sponsored User Account
                                    if (ua.Is_Consultant__c){
                                        ua.Consultant_Account__c = accId;
                                    }

                                    lstTargetUserAsset.add(ua);
                                    break;
                                }
                            }
                        }

                        if (!isValid) {
                            Trigger.newMap.get(ua.Id).addError(System.label.Msg_Assign_User_Err);
                        }
                    }
                }
            }

            if(!lstTargetUserAsset.isEmpty()) {
                update lstTargetUserAsset;
            }
        }
    }
}