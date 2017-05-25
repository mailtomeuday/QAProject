/**************************************************************************************************
 * Name           : GS_OpportunitySetRenewalDateHandler
 * Object         : Opportunity
 * Requirement    : 
 * Target         : Set RenewalDate value when opportunity status changed to "CWV"
 * Refer classes  :
 * Author         : Matthew Sun (matthew.sun@pwc.com)
 * Create Date    : 2016-02-26
 * Modify History :
 **************************************************************************************************/
public class GS_OpportunitySetRenewalDateHandler implements GS_Triggers.Handler{
    
    public void handle(){
    	Set<Id> oppIds = new Set<Id>();
    	Set<Opportunity> opps = new Set<Opportunity>();
            
        // Get opportunity id
        for(Opportunity opp : (List<Opportunity>)Trigger.new) {
    		if(opp.StageName == 'Closed Won Verified'){
            	oppIds.add(opp.Id);
            	opps.add(opp);
        	}
        }

        Map<Id, Date> mapOppDate = getOppLineItemsByOppIds(oppIds);

        for(Opportunity opp : opps){
            if(mapOppDate.get(opp.Id) != NULL){
        	   opp.Renewal_Date__c = mapOppDate.get(opp.Id).addDays(1);
            }
        }

    }

    public Map<Id, Date> getOppLineItemsByOppIds(Set<Id> oppIds){
    	List<OpportunityLineItem> oppItems = [SELECT Id, OpportunityId, Subscription_End_Date__c FROM OpportunityLineItem WHERE OpportunityId IN :oppIds];

    	Map<Id, Date> mapOppDate = new Map<Id, Date>();
    	for(OpportunityLineItem oppItem : oppItems){
    		if(oppItem.Subscription_End_Date__c != null && !mapOppDate.containsKey(oppItem.OpportunityId)){
    			mapOppDate.put(oppItem.OpportunityId, oppItem.Subscription_End_Date__c);
    		}
    	}

    	return mapOppDate;
    }

}