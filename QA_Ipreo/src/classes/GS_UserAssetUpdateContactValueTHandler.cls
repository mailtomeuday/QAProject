/**************************************************************************************************
 * Name           : GS_UserAssetUpdateContactValueTHandler
 * Object         : User Asset
 * Requirement    :
 * Target         : Update Product_Bundled__c when line item is created, updated, deleted
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-06-16
 * Modify History :
 **************************************************************************************************/
public class GS_UserAssetUpdateContactValueTHandler implements GS_Triggers.Handler {

    public void handle() {
    	updateContactAssetBundle();
    }

    // When user asset is created updated or deleted undeleted, calculate the Asset Bundle on Contact.
    private void updateContactAssetBundle() {

    	Set<Id> stContactIds = new Set<Id>();
    	List<Contact> lstTargetContact = new List<Contact>();
    	String strSeparator = '_';

    	if(Trigger.isUpdate){
	    	for(Id tempItemId : ((Map<Id,User_Asset__c>)Trigger.newMap).keySet()) {
	    		if(!stContactIds.contains(((Map<Id,User_Asset__c>)Trigger.newMap).get(tempItemId).User__c)) {
	    			if(   ((Map<Id,User_Asset__c>)Trigger.newMap).get(tempItemId).Active__c
	    			   != ((Map<Id,User_Asset__c>)Trigger.oldMap).get(tempItemId).Active__c){
	    				stContactIds.add(((Map<Id,User_Asset__c>)Trigger.newMap).get(tempItemId).User__c);
	    			}
	    		}
	    	}
	    } else if(Trigger.isDelete){
	    	for(User_Asset__c tempItem : (List<User_Asset__c>)Trigger.old) {
	    		if(!stContactIds.contains(tempItem.User__c)) {
	    			stContactIds.add(tempItem.User__c);
	    		}
	    	}
	    } else {
	    	for(User_Asset__c tempItem : (List<User_Asset__c>)Trigger.new) {
	    		if(!stContactIds.contains(tempItem.User__c)) {
	    			stContactIds.add(tempItem.User__c);
	    		}
	    	}
	    }

    	lstTargetContact = GS_ContactDMLHandler.getContactsWithAssetsByConIds(stContactIds);

    	for (Contact tempCon : lstTargetContact) {
    		tempCon.Asset_Bundle__c = '';
    		for(Integer i = 0; i < tempCon.User_Assets__r.size(); i++){
    			if(tempCon.User_Assets__r[i].Active__c == GS_GlobalVariables.USERASSETACTIVE){
    				System.debug(LoggingLevel.INFO, '*** i: ' + i);
    				System.debug(LoggingLevel.INFO, '*** tempCon.User_Assets__r[i].Asset__r.Product2.ProductCode: ' + tempCon.User_Assets__r[i].Asset__r.Product2.ProductCode);
	    			if(i == 0) {
	    				tempCon.Asset_Bundle__c = tempCon.User_Assets__r[i].Asset__r.Product2.ProductCode;
	    			} else if(String.isNotBlank(tempCon.Asset_Bundle__c)){
	    				tempCon.Asset_Bundle__c += strSeparator + tempCon.User_Assets__r[i].Asset__r.Product2.ProductCode;
	    			} else{
	    				tempCon.Asset_Bundle__c = tempCon.User_Assets__r[i].Asset__r.Product2.ProductCode;
	    			}
	    		}
    		}
    	}


    	try{
    		System.debug(LoggingLevel.INFO, '*** lstTargetContact: ' + lstTargetContact);
    		update lstTargetContact;
    	}catch(DmlException ex) {
    		System.debug(LoggingLevel.Error, '*** Error Message: ' + ex.getMessage());
    	}
    }
}