/**************************************************************************************************
 * Name           : GS_OppSyncLineItemAccTHandler
 * Object         : Opportunity/Opportunity Product
 * Requirement    : STY-000201
 * Target         : Update Opportunity Products' account
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-06-26
 * Modify History :
 **************************************************************************************************/
public class GS_OppSyncLineItemAccTHandler implements GS_Triggers.Handler {
	public void handle() {
		if(Trigger.isUpdate) {

			Set<Id> setOppIds = new Set<Id>();
			List<OpportunityLineItem> lstOppLineItems = new List<OpportunityLineItem>();

			for (Id tempOppId : ((Map<Id, Opportunity>)Trigger.newMap).keySet()) {
				if(((Map<Id, Opportunity>)Trigger.newMap).get(tempOppId).AccountId != ((Map<Id, Opportunity>)Trigger.oldMap).get(tempOppId).AccountId) {
					setOppIds.add(tempOppId);
				}
			}

			System.debug(LoggingLevel.INFO, '***GS_OppSyncLineItemAccTHandler setOppIds: ' + setOppIds);

			lstOppLineItems = GS_OpportunityDMLHandler.getLineItemsByOppId(setOppIds);

			for(OpportunityLineItem tempOppLineItem : lstOppLineItems) {
				tempOppLineItem.Account__c = ((Map<Id, Opportunity>)Trigger.newMap).get(tempOppLineItem.OpportunityId).AccountId;
			}

			try {
				update lstOppLineItems;
			} catch(DmlException ex) {
				System.debug(LoggingLevel.Error, '*** ex.getMessage(): ' + ex.getMessage());
			}
		}
	}
}