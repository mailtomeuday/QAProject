/**************************************************************************************************
 * Name           : GS_OpportunityProductAssignValueTHander
 * Object         : OpportunityLineItem
 * Requirement    : STY-00045, STY-00171, STY-00011
 * Target         : Assign value when an opportunity product is created
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-06-16
 * Modify History :
 **************************************************************************************************/
public class GS_OpportunityProductAssignValueTHander implements GS_Triggers.Handler {
	public void handle() {
		if (Trigger.isBefore) {
			System.debug(LoggingLevel.INFO, '*** GS_OpportunityProductAssignValueTHander.');
			System.debug(LoggingLevel.INFO, '*** trigger.new: ' + trigger.new);

			Map<Id, OpportunityLineItem> mapNewLineItems = (Map<Id,OpportunityLineItem>)Trigger.newMap;
			Set<Id> setOppIds = new Set<Id>();
			Set<Id> setProdIds = new Set<Id>();
			Set<Id> setCreatedByIds = new Set<Id>();
			Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>();
			Map<Id, Product2> mapProduct = new Map<Id, Product2>();
			Map<Id, User> mapUser = new Map<Id, User>();

			for(OpportunityLineItem tempLineItem : (List<OpportunityLineItem>)Trigger.new) {
				if(!setOppIds.contains(tempLineItem.OpportunityId)) {
					setOppIds.add(tempLineItem.OpportunityId);
				}

				if(!setProdIds.contains(tempLineItem.Product2Id)) {
					setProdIds.add(tempLineItem.Product2Id);
				}
			}
			setCreatedByIds.add(UserInfo.getUserId());

			if(setOppIds.size() > 0) {
				mapOpportunity = new Map<Id, Opportunity>(GS_OpportunityDMLHandler.getOpportunitiesById(setOppIds));
			}

			if(setProdIds.size() > 0) {
				mapProduct = new Map<Id, Product2>(GS_ProductDMLHandler.getProductsById(setProdIds));
			}

			if(setCreatedByIds.size() > 0) {
				mapUser = new Map<Id, User>(GS_UserDMLHandler.getUsersByIds(setCreatedByIds));
			}

			//Map<Id, OpportunityLineItem> mapNewLineItems = new Map<Id, OpportunityLineItem>(GS_OpportunityDMLHandler.getLineItemsById(Trigger.newMap.keyset()));
			System.debug(LoggingLevel.INFO, '*** mapNewLineItems: ' + mapNewLineItems);
			for(OpportunityLineItem tempLineItem : (List<OpportunityLineItem>)Trigger.new) {

				// Set Product_Region__c
				if (String.isBlank(tempLineItem.Product_Region__c)) {
					//mapNewLineItems.get(tempId).Product_Region__c = mapNewLineItems.get(tempId).CreatedBy.Region__c;
					System.debug(LoggingLevel.INFO, '*** tempLineItem.CreatedById: ' + tempLineItem.CreatedById);
					tempLineItem.Product_Region__c = mapUser.get(UserInfo.getUserId()).Region__c;
				}

				// Set Product_Vertical__c
				if (String.isBlank(tempLineItem.Product_Vertical__c)) {
					//mapNewLineItems.get(tempId).Product_Vertical__c = mapNewLineItems.get(tempId).Opportunity.Account.Vertical__c;
					tempLineItem.Product_Vertical__c = mapProduct.get(tempLineItem.Product2Id).Vertical__c;
				}

				// Set Product_Revenue_Type__c
				if( String.isBlank(tempLineItem.Product_Revenue_Type__c) && !String.isBlank(tempLineItem.Product_Vertical__c)) {
					tempLineItem.Product_Revenue_Type__c = mapProduct.get(tempLineItem.Product2Id).Revenue_Type__c;
				}

				System.debug(LoggingLevel.INFO, '*** tempLineItem.Product_Revenue_Type__c: ' + tempLineItem.Product_Revenue_Type__c);
			}
		}
	}
}