/**************************************************************************************************
 * Name           : GS_OppLineItemRecordValidationTHandler
 * Object         : OpportunityLineItem
 * Requirement    :
 * Target         : Validation rule on OpportunityLineItem
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-07-01
 * Modify History :
 **************************************************************************************************/
public class GS_OppLineItemRecordValidationTHandler implements GS_Triggers.Handler {

    public void handle() {
        Profile SysAdminProfile = [select id from Profile where name =: 'System Administrator'];
        Set<Id> stRelatedOppIds = new Set<Id>();
        List<OpportunityLineItem> lstTotalOppLineItems = new List<OpportunityLineItem>();

        // Get opportunity id of line items
        for (OpportunityLineItem tempLineItem : (List<OpportunityLineItem>)Trigger.new) {
            if (!stRelatedOppIds.contains(tempLineItem.OpportunityId)) {
                stRelatedOppIds.add(tempLineItem.OpportunityId);
            }
        }

        System.debug(LoggingLevel.INFO, '*** stRelatedOppIds: ' + stRelatedOppIds);

        lstTotalOppLineItems = GS_OpportunityDMLHandler.getWonLineItemsByOppId(stRelatedOppIds);
        
        // Line items with opportunity items, group the line items by opportunity id.
        Map<Id, List<OpportunityLineItem>> mapOppLineItemsWithOppId = new Map<Id, List<OpportunityLineItem>>();
        
        for (OpportunityLineItem tempOppLineItem : lstTotalOppLineItems) {
            System.debug(LoggingLevel.INFO, '*** tempOppLineItem.Subscription_End_Date__c: ' + tempOppLineItem.Subscription_End_Date__c);
            if (mapOppLineItemsWithOppId.containsKey(tempOppLineItem.OpportunityId)) {
                mapOppLineItemsWithOppId.get(tempOppLineItem.OpportunityId).add(tempOppLineItem);
            } else {
                mapOppLineItemsWithOppId.put(tempOppLineItem.OpportunityId, new List<OpportunityLineItem> {tempOppLineItem});
            }
        }
        
        Map<Id, List<OpportunityLineItem>> mapACVTRANSOppLineItems = new Map<Id, List<OpportunityLineItem>>();
        Map<Id, List<OpportunityLineItem>> mapNonACVTRANSOppLineItems = new Map<Id, List<OpportunityLineItem>>();
        
        for(Id tempOppId : mapOppLineItemsWithOppId.keySet())
        {
            boolean isNonACVTrans = false;
            for (OpportunityLineItem tempOppLineItem : mapOppLineItemsWithOppId.get(tempOppId)) {
                if(tempOppLineItem.Product_Revenue_Type__c != 'ACV' && tempOppLineItem.Product_Revenue_Type__c != 'ACV/TRANS'){
                    isNonACVTrans = true;
                    break;
                } 
            }
            
            if(isNonACVTrans){
                mapNonACVTRANSOppLineItems.put(tempOppId, mapOppLineItemsWithOppId.get(tempOppId));
            }
            else{
                mapACVTRANSOppLineItems.put(tempOppId, mapOppLineItemsWithOppId.get(tempOppId));
            }
            
        }
        
        system.debug('Current User ProfileId :' + UserInfo.getProfileId());
        system.debug('Sys Admin User ProfileId :'+SysAdminProfile.Id);
        
        //Need to bypass validation for sys admins
        if(UserInfo.getProfileId() != SysAdminProfile.Id || Test.isRunningTest()){
            checkSubscriptionEndDate(mapNonACVTRANSOppLineItems);
            checkEstComplAndSubscripEndDates(mapACVTRANSOppLineItems);
        }
                
    }

    // IF Status IN ( "Won", "Renewed" ) AND Subscription End Date ≠ null
    // AND Subscription End Date ≠ one or more Subscription End Dates on Opportunity Products related to the same opportunity,
    // THEN error:  "All subscription end dates must be co-terminus"
    private void checkSubscriptionEndDate(Map<Id, List<OpportunityLineItem>> mapOppLineItemsWithOppId) {

        Set<Id> setErrOppId = new Set<Id>();
        Set<Id> setMultiNullsOppId = new Set<Id>();
        
        for (Id tempOppId : mapOppLineItemsWithOppId.keySet()) {

            //Condition add by Matthew Sun 2016.2.23, only mutliple opp line items need to be checked
            if(mapOppLineItemsWithOppId.get(tempOppId).size() > 1){
                Date tempDate = NULL;
                Integer tempNull = 0;
                for (OpportunityLineItem tempOppLineItem : mapOppLineItemsWithOppId.get(tempOppId)) {
                    if (tempDate == NULL) {
                        if (tempOppLineItem.Subscription_End_Date__c != NULL) {
                            tempDate = tempOppLineItem.Subscription_End_Date__c;
                        }
                    } 
                    else {
                        if (tempOppLineItem.Subscription_End_Date__c != NULL) {
                            if (tempDate != tempOppLineItem.Subscription_End_Date__c) {
                                System.debug(LoggingLevel.INFO, '*** tempDate: ' + tempDate);
                                System.debug(LoggingLevel.INFO, '*** tempOppLineItem.Subscription_End_Date__c: ' + tempOppLineItem.Subscription_End_Date__c);
                                if (!setErrOppId.contains(tempOppId)) {
                                    setErrOppId.add(tempOppId);
                                }
                            }
                        }
                    }

                    //Add by Matthew Sun 2016.2.17, cannot allow more than 1 null subscription end date
                    if(tempOppLineItem.Subscription_End_Date__c == null){
                        tempNull += 1;
                    }
                }
                //Add by Matthew Sun 2016.2.17, cannot allow more than 1 null subscription end date
                if(tempNull > 0){
                    setMultiNullsOppId.add(tempOppId);
                }
            }            
        }

        for (OpportunityLineItem tempLineItem : (List<OpportunityLineItem>)Trigger.new) {
            if (setErrOppId.contains(tempLineItem.OpportunityId)) {
                tempLineItem.Subscription_End_Date__c.addError(System.label.Msg_Coterminous_Subscription_End_Date);
            }

            //Add by Matthew Sun 2016.2.17, cannot allow more than 1 null subscription end date
            if(setMultiNullsOppId.contains(tempLineItem.OpportunityId)){
                tempLineItem.addError(System.label.Msg_Multiple_Nulls_Subscription_End_Date);                
            }
        }
    }
    
    //For ACV or ACV/TRANS products (Subscription End Date cannot be null and Subscription End Date must be same
    //across all Opp Products OR Est. Completion Date cannot be null and must be same across all Opp Products
    private void checkEstComplAndSubscripEndDates(Map<Id, List<OpportunityLineItem>> mapOppLineItemsWithOppId) {

        Set<Id> setErrOppId = new Set<Id>();
        Set<Id> setMultiNullsOppId = new Set<Id>();
        
        for (Id tempOppId : mapOppLineItemsWithOppId.keySet()) {

            if(mapOppLineItemsWithOppId.get(tempOppId).size() > 1){
                Date tempDate = NULL;
                Date tempComplDate = NULL;
                Integer tempNull = 0;
                boolean hasSubscriptionEndDate = false;
                boolean hasEstCompletionDate = false;
                for (OpportunityLineItem tempOppLineItem : mapOppLineItemsWithOppId.get(tempOppId)) {
                    if(tempOppLineItem.Subscription_End_Date__c == NULL && tempOppLineItem.Estimated_Completion_Date__c == NULL){
                        tempNull += 1;
                        break;
                    }
                    else
                    {
                        if(tempOppLineItem.Subscription_End_Date__c != NULL){
                            hasSubscriptionEndDate = true;
                            break;
                        }
                        else if(tempOppLineItem.Estimated_Completion_Date__c != NULL){
                            hasEstCompletionDate = true;
                            break;  
                        }
                    }
                }
                
                if(hasSubscriptionEndDate){
                    for (OpportunityLineItem tempOppLineItem : mapOppLineItemsWithOppId.get(tempOppId)) {
                        if (tempDate == NULL) {
                            if (tempOppLineItem.Subscription_End_Date__c != NULL) {
                                tempDate = tempOppLineItem.Subscription_End_Date__c;
                            }
                        } 
                        else {
                            if (tempOppLineItem.Subscription_End_Date__c != NULL) {
                                if (tempDate != tempOppLineItem.Subscription_End_Date__c) {
                                    System.debug(LoggingLevel.INFO, '*** tempDate: ' + tempDate);
                                    System.debug(LoggingLevel.INFO, '*** tempOppLineItem.Subscription_End_Date__c: ' + tempOppLineItem.Subscription_End_Date__c);
                                    if (!setErrOppId.contains(tempOppId)) {
                                        setErrOppId.add(tempOppId);
                                    }
                                }
                            }
                        }
    
                        if(tempOppLineItem.Subscription_End_Date__c == null){
                            tempNull += 1;
                        }
                    }
                }
                
                if(hasEstCompletionDate){
                    for (OpportunityLineItem tempOppLineItem : mapOppLineItemsWithOppId.get(tempOppId)) {
                        if (tempComplDate == NULL) {
                            if (tempOppLineItem.Estimated_Completion_Date__c != NULL) {
                                tempComplDate = tempOppLineItem.Estimated_Completion_Date__c;
                            }
                        } 
                        else {
                            if (tempOppLineItem.Estimated_Completion_Date__c != NULL) {
                                if (tempComplDate != tempOppLineItem.Estimated_Completion_Date__c) {
                                    System.debug(LoggingLevel.INFO, '*** tempComplDate: ' + tempComplDate);
                                    System.debug(LoggingLevel.INFO, '*** tempOppLineItem.Estimated_Completion_Date__c: ' + tempOppLineItem.Estimated_Completion_Date__c);
                                    if (!setErrOppId.contains(tempOppId)) {
                                        setErrOppId.add(tempOppId);
                                    }
                                }
                            }
                        }
    
                        if(tempOppLineItem.Estimated_Completion_Date__c == null){
                            tempNull += 1;
                        }
                    }
                    
                }
                
                if(tempNull > 0){
                    setMultiNullsOppId.add(tempOppId);
                }
                
            }            
        }

        for (OpportunityLineItem tempLineItem : (List<OpportunityLineItem>)Trigger.new) {
            if (setErrOppId.contains(tempLineItem.OpportunityId)) {
                tempLineItem.addError(System.label.Msg_Coterminous_Sub_End_Date_Est_Comp_Date);
            }

            if(setMultiNullsOppId.contains(tempLineItem.OpportunityId)){
                tempLineItem.addError(System.label.Msg_Multiple_Nulls_Subscription_End_Date_Est_Comp_Date);                
            }
        }
    
    }
}