/**************************************************************************************************
 * Name           : GS_OppLineItemCalNetNewBizHander
 * Object         : OpportunityLineItem
 * Requirement    :
 * Target         : Update custom field Product__c, and make it concerted with the standard product.
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-06-26
 * Modify History :
 **************************************************************************************************/
public class GS_OppLineItemUpdateProductTHandler implements GS_Triggers.Handler {
    public void handle() {
    	if(Trigger.isInsert) {

			Set<Id> setOppIds = new Set<Id>();
			List<Opportunity> lstOpps = new List<Opportunity>();
			Map<Id, Opportunity> mapOpps = new Map<Id, Opportunity>();

    		for(OpportunityLineItem tempOppLineItem : (List<OpportunityLineItem>)Trigger.new) {
    			if(!setOppIds.contains(tempOppLineItem.OpportunityId)){
    				setOppIds.add(tempOppLineItem.OpportunityId);
    			}
    		}

			System.debug(LoggingLevel.INFO, '***GS_OppLineItemUpdateProductTHandler setOppIds: ' + setOppIds);

			lstOpps = GS_OpportunityDMLHandler.getOpportunitiesById(setOppIds);

			if(lstOpps.size() > 0) {
				mapOpps = new Map<Id, Opportunity>(lstOpps);
				for(OpportunityLineItem tempOppLineItem : (List<OpportunityLineItem>)Trigger.new) {
					tempOppLineItem.Account__c = mapOpps.get(tempOppLineItem.OpportunityId).AccountId;
	    			tempOppLineItem.Product__c = tempOppLineItem.Product2Id;
	    		}
			}

    	}

    	if(Trigger.isUpdate) {
    		for(Id tempOppLineItemId : ((Map<Id, OpportunityLineItem>)Trigger.newMap).keySet()) {
    			if(((Map<Id, OpportunityLineItem>)Trigger.newMap).get(tempOppLineItemId).Product2Id != ((Map<Id, OpportunityLineItem>)Trigger.oldMap).get(tempOppLineItemId).Product2Id) {
    				((Map<Id, OpportunityLineItem>)Trigger.newMap).get(tempOppLineItemId).Product__c = ((Map<Id, OpportunityLineItem>)Trigger.newMap).get(tempOppLineItemId).Product2Id;
    			}
    		}
    	}
    }
}