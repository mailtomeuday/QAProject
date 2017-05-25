/**************************************************************************************************
 * Name           : GS_OppLineItemCalNetNewBizTHandler
 * Object         : OpportunityLineItem
 * Requirement    : STY-00149 -> STY-00201
 * Target         : Calculte Net New Business
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-06-24
 * Modify History :
 **************************************************************************************************/
public class GS_OppLineItemCalNetNewBizTHandler implements GS_Triggers.Handler {
	public void handle() {
		if (Trigger.isInsert) {
			System.debug(LoggingLevel.INFO, '*** GS_OppLineItemCalNetNewBizTHandler is executed. The action is insert. ');
			for (OpportunityLineItem tempItem : (List<OpportunityLineItem>)Trigger.new) {
				Decimal decACpV = tempItem.ACpV__c == null ? 0 : tempItem.ACpV__c;
				Decimal decPriorACpV = tempItem.Prior_Year_ACpV__c == null ? 0 : tempItem.Prior_Year_ACpV__c;
				Decimal decPassThrough = tempItem.Annual_Pass_Through__c == null ? 0 : tempItem.Annual_Pass_Through__c;
				Decimal decPrePassThrough = tempItem.Prior_Year_Pass_Through__c == null ? 0 : tempItem.Prior_Year_Pass_Through__c;
				if (tempItem.Status__c == null || tempItem.Status__c == 'Won' || tempItem.Status__c == 'Renewed') {
					tempItem.Net_New_Business__c = decACpV - decPriorACpV - decPassThrough + decPrePassThrough;
				} else if (tempItem.Status__c == 'Cancelled') {
					tempItem.Net_New_Business__c = -1 * decPriorACpV + decPrePassThrough;
				} else if (tempItem.Status__c == 'Lost') {
					tempItem.Net_New_Business__c = 0;
				}
			}
		}

		if (Trigger.isUpdate) {
			System.debug(LoggingLevel.INFO, '*** GS_OppLineItemCalNetNewBizTHandler is executed. The action is update. ');
			Map<Id, OpportunityLineItem> mapNewLineItem = new Map<Id, OpportunityLineItem>();
			Map<Id, OpportunityLineItem> mapOldLineItem = new Map<Id, OpportunityLineItem>();
			mapNewLineItem = (Map<Id, OpportunityLineItem>)Trigger.newMap;
			mapOldLineItem = (Map<Id, OpportunityLineItem>)Trigger.oldMap;
			for (Id tempOppLineItemId : mapNewLineItem.keySet()) {

				Decimal decACpV = mapNewLineItem.get(tempOppLineItemId).ACpV__c == null ? 0 : mapNewLineItem.get(tempOppLineItemId).ACpV__c;
				Decimal decPriorACpV = mapNewLineItem.get(tempOppLineItemId).Prior_Year_ACpV__c == null ? 0 : mapNewLineItem.get(tempOppLineItemId).Prior_Year_ACpV__c;
				Decimal decPassThrough = mapNewLineItem.get(tempOppLineItemId).Annual_Pass_Through__c == null ? 0 : mapNewLineItem.get(tempOppLineItemId).Annual_Pass_Through__c;
				Decimal decPrePassThrough = mapNewLineItem.get(tempOppLineItemId).Prior_Year_Pass_Through__c == null ? 0 : mapNewLineItem.get(tempOppLineItemId).Prior_Year_Pass_Through__c;

				// When status is changed, the calculation will be fired.
				if (   mapNewLineItem.get(tempOppLineItemId).Status__c != mapOldLineItem.get(tempOppLineItemId).Status__c
					&& (   mapNewLineItem.get(tempOppLineItemId).Status__c == null
						|| mapNewLineItem.get(tempOppLineItemId).Status__c == 'Won'
						|| mapNewLineItem.get(tempOppLineItemId).Status__c == 'Renewed')){

					mapNewLineItem.get(tempOppLineItemId).Net_New_Business__c = decACpV - decPriorACpV - decPassThrough + decPrePassThrough;

				// When ACpV__c or Prior_Year_ACpV__c or Pass_Through__c or Prior_Year_Pass_Through__c is changed, the calculation will be fired.
				} else if (    (   mapNewLineItem.get(tempOppLineItemId).Status__c == null
						        || mapNewLineItem.get(tempOppLineItemId).Status__c == 'Won'
						        || mapNewLineItem.get(tempOppLineItemId).Status__c == 'Renewed')
							&& (   mapNewLineItem.get(tempOppLineItemId).ACpV__c != mapOldLineItem.get(tempOppLineItemId).ACpV__c
								|| mapNewLineItem.get(tempOppLineItemId).Prior_Year_ACpV__c != mapOldLineItem.get(tempOppLineItemId).Prior_Year_ACpV__c
								|| mapNewLineItem.get(tempOppLineItemId).Annual_Pass_Through__c != mapOldLineItem.get(tempOppLineItemId).Annual_Pass_Through__c
								|| mapNewLineItem.get(tempOppLineItemId).Prior_Year_Pass_Through__c != mapOldLineItem.get(tempOppLineItemId).Prior_Year_Pass_Through__c)) {
					mapNewLineItem.get(tempOppLineItemId).Net_New_Business__c = decACpV - decPriorACpV - decPassThrough + decPrePassThrough;

				} else if(   mapNewLineItem.get(tempOppLineItemId).Status__c == 'Cancelled'
					      && mapNewLineItem.get(tempOppLineItemId).Status__c != mapOldLineItem.get(tempOppLineItemId).Status__c) {
					mapNewLineItem.get(tempOppLineItemId).Net_New_Business__c = -1 * decPriorACpV + decPrePassThrough;
				} else if (   mapNewLineItem.get(tempOppLineItemId).Status__c == 'Cancelled'
							&& (   mapNewLineItem.get(tempOppLineItemId).Prior_Year_ACpV__c != mapOldLineItem.get(tempOppLineItemId).Prior_Year_ACpV__c
								|| mapNewLineItem.get(tempOppLineItemId).Prior_Year_Pass_Through__c != mapOldLineItem.get(tempOppLineItemId).Prior_Year_Pass_Through__c)){
					mapNewLineItem.get(tempOppLineItemId).Net_New_Business__c = -1 * decPriorACpV + decPrePassThrough;
				} else if(   mapNewLineItem.get(tempOppLineItemId).Status__c == 'Lost'
					      && mapNewLineItem.get(tempOppLineItemId).Status__c != mapOldLineItem.get(tempOppLineItemId).Status__c) {
					mapNewLineItem.get(tempOppLineItemId).Net_New_Business__c = 0;
				}
			}
		}
	}
}