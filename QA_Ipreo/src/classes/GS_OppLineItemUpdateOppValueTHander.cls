/**************************************************************************************************
 * Name           : GS_OppLineItemUpdateOppValueTHander
 * Object         : OpportunityLineItem
 * Requirement    :
 * Target         : Update Product_Bundled__c when line item is created, updated, deleted
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-06-16
 * Modify History :
 **************************************************************************************************/
public class GS_OppLineItemUpdateOppValueTHander implements GS_Triggers.Handler {
    
    public void handle() {
    	updateOppProCodeBundle();
    	updateOppRenewalDate();
    }

    private void updateOppProCodeBundle() {
    	Set<Id> setOppIds = new Set<Id>();
    	List<Opportunity> lstTargetOpp = new List<Opportunity>();
    	String strSeparator = '_';

    	if(Trigger.isUpdate){
	    	for(Id tempItemId : ((Map<Id,OpportunityLineItem>)Trigger.newMap).keySet()) {
	    		if(!setOppIds.contains(((Map<Id,OpportunityLineItem>)Trigger.newMap).get(tempItemId).OpportunityId)) {
	    			if(   ((Map<Id,OpportunityLineItem>)Trigger.newMap).get(tempItemId).Status__c
	    			   != ((Map<Id,OpportunityLineItem>)Trigger.oldMap).get(tempItemId).Status__c){
	    				setOppIds.add(((Map<Id,OpportunityLineItem>)Trigger.newMap).get(tempItemId).OpportunityId);
	    			}
	    		}
	    	}
	    } else if(Trigger.isDelete){
	    	for(OpportunityLineItem tempItem : (List<OpportunityLineItem>)Trigger.old) {
	    		if(!setOppIds.contains(tempItem.OpportunityId)) {
	    			setOppIds.add(tempItem.OpportunityId);
	    		}
	    	}
	    } else {
	    	for(OpportunityLineItem tempItem : (List<OpportunityLineItem>)Trigger.new) {
	    		if(!setOppIds.contains(tempItem.OpportunityId)) {
	    			setOppIds.add(tempItem.OpportunityId);
	    		}
	    	}
	    }

    	lstTargetOpp = GS_OpportunityDMLHandler.getOpportunitiesWithLineItemsById(setOppIds);

    	for (Opportunity tempOpp : lstTargetOpp) {
    		tempOpp.Product_Bundle__c = '';
    		for(Integer i = 0; i < tempOpp.OpportunityLineItems.size(); i++){
    			if(tempOpp.OpportunityLineItems[i].Status__c != GS_GlobalVariables.OPPLINEITEMSTATUSLOST && tempOpp.OpportunityLineItems[i].Status__c != GS_GlobalVariables.OPPLINEITEMSTATUSCANCELLED){
	    			if(i == 0) {
	    				tempOpp.Product_Bundle__c = tempOpp.OpportunityLineItems[i].ProductCode;
	    			} else if(String.isNotBlank(tempOpp.Product_Bundle__c)){
	    				tempOpp.Product_Bundle__c += strSeparator + tempOpp.OpportunityLineItems[i].ProductCode;
	    			} else{
	    				tempOpp.Product_Bundle__c = tempOpp.OpportunityLineItems[i].ProductCode;
	    			}
	    		}
    		}
    	}


    	try{
    		update lstTargetOpp;
    	}catch(DmlException ex) {
    		System.debug(LoggingLevel.Error, '*** Error Message: ' + ex.getMessage());
    	}
    }

    private void updateOppRenewalDate() {

    	if(Trigger.isupdate && Trigger.isAfter) {

    		Map<Id, Date> mapOppWithEndDate = new Map<Id, Date>();
	    	Map<Id, Opportunity> mapTargetOpp = new Map<Id, Opportunity>();
	    	Map<Id, OpportunityLineItem> mapNewLineItem = (Map<Id, OpportunityLineItem>)Trigger.newMap;
	    	Map<Id, OpportunityLineItem> oldNewLineItem = (Map<Id, OpportunityLineItem>)Trigger.oldMap;

	    	for(Id tempLineItemId : Trigger.newMap.keySet()) {
	    		if(    mapNewLineItem.get(tempLineItemId).Subscription_End_Date__c != NULL
	    			&& mapNewLineItem.get(tempLineItemId).Subscription_End_Date__c != oldNewLineItem.get(tempLineItemId).Subscription_End_Date__c) {
	    			mapOppWithEndDate.put(mapNewLineItem.get(tempLineItemId).OpportunityId, mapNewLineItem.get(tempLineItemId).Subscription_End_Date__c);
	    		}
	    	}

    		mapTargetOpp = new Map<Id, Opportunity>(GS_OpportunityDMLHandler.getOpportunitiesWithLineItemsById(mapOppWithEndDate.keySet()));

    		for(Id oppId : mapTargetOpp.keySet()) {
    			if(mapTargetOpp.get(oppId).RecordType.DeveloperName != GS_GlobalVariables.OPPRTNEWBUSINESS){
    				mapTargetOpp.remove(oppId);
    			}
    		}

    		for(Id oppId : mapTargetOpp.keySet()) {
    			mapTargetOpp.get(oppId).Renewal_Date__c = mapOppWithEndDate.get(oppId);
    		}

	    	try{
	    		if(!mapTargetOpp.isEmpty()){
	    			update mapTargetOpp.values();
	    		}
	    	}catch(DmlException ex) {
	    		System.debug(LoggingLevel.Error, '*** Error Message: ' + ex.getMessage());
	    	}
    	}
    }
}