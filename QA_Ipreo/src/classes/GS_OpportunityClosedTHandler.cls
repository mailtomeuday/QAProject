/**************************************************************************************************
 * Name           : GS_OpportunityClosedTHandler
 * Object         : Opportunity/Opportunity Product/Work Order
 * Requirement    :
 * Target         : When an opportunity is closed, generate Wo if the opportunit is closed
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-10-28
 * Modify History :
 **************************************************************************************************/
public class GS_OpportunityClosedTHandler implements GS_Triggers.Handler {
    public static Set<Id> oppLineItemsCancelled = new Set<Id>();

    public void handle() {
        if(Trigger.isUpdate && Trigger.isAfter){
            Map<Id, Opportunity> newMapOpportunity = (Map<Id, Opportunity>)Trigger.newMap;
            Map<Id, Opportunity> oldMapOpportunity = (Map<Id, Opportunity>)Trigger.oldMap;
            Map<Id, List<OpportunityLineItem>> mapAllOppLineItem = new Map<Id, List<OpportunityLineItem>>();
            Set<Id> lstOpportunityId = new Set<Id>();

            for (Id tempOppId : newMapOpportunity.keySet()) {
                if (   newMapOpportunity.get(tempOppId).StageName != oldMapOpportunity.get(tempOppId).StageName
                        && (newMapOpportunity.get(tempOppId).StageName == GS_GlobalVariables.OPPCLOSEDCANCELLEDVERIFIED ||
                            newMapOpportunity.get(tempOppId).StageName == GS_GlobalVariables.OPPCLOSEDWONVERIFIED )) {
                    lstOpportunityId.add(tempOppId);
                }
            }

            // Get all Opp line items which status in = 'Cancelled', this opp line items are used to create work orders.
            for (OpportunityLineItem tempOppLineItem : GS_OpportunityDMLHandler.getCancelledLineItemsByOppId(lstOpportunityId)) {
                //SPS-870: Don't create work order for cancelled opp products with revenue type 'Proj'
                if(tempOppLineItem.Product_Revenue_Type__c == 'PROJ'){
                    continue;
                }
                
                //Check if we already processed this Opportunity Line Item.  Avoid duplicate Work Orders
                if (!oppLineItemsCancelled.contains(tempOppLineItem.Id)) {
                    if (!mapAllOppLineItem.containsKey(tempOppLineItem.OpportunityId)) 
                        mapAllOppLineItem.put(tempOppLineItem.OpportunityId, new List<OpportunityLineItem> {tempOppLineItem});
                    else 
                        mapAllOppLineItem.get(tempOppLineItem.OpportunityId).add(tempOppLineItem);
                
                    oppLineItemsCancelled.add(tempOppLineItem.Id);
                }
            }

            if (mapAllOppLineItem.size() > 0) {
                generateWO(mapAllOppLineItem);
            }
        }
    }

    // Generate cancelled work order when the opportunity is closed
    private void generateWO(Map<Id, List<OpportunityLineItem>> oppLineItemMap) {

        System.debug(LoggingLevel.INFO, '*** : GS_OpportunityClosedTHandler.generateWO is executed.');

        // Map WO with opportunityId， the key is related opportunity id not WO id
        Map<Id, List<Work_Order__c>> mapWOWithOppId = new Map<Id, List<Work_Order__c>>();
        // key is queue name and value is queue id, used to assign queue to work order
        Map<String, Id> mapQueue = new Map<String, Id>();
        // Get all opplineItems for product.Work_Order_Queue__c
        List<OpportunityLineItem> lstOppLineItems = new List<OpportunityLineItem>();
        // Get record type by object name and record type name
        RecordType rtCancellation;

        List<Work_Order__c> lstTargetWO = new List<Work_Order__c>();
        List<OpportunityLineItem> lstTargetOppLineItems = new List<OpportunityLineItem>();

        for(Id tempId : oppLineItemMap.keySet()) {
            for ( Integer i = oppLineItemMap.get(tempId).size() - 1; i >= 0; i-- ){
                    if(String.isBlank(oppLineItemMap.get(tempId)[i].Product2.Work_Order_Type_Default__c)) {
                        oppLineItemMap.get(tempId).remove(i);
                    }
                }
        }

        for(Id tempId : oppLineItemMap.keySet()) {
            for(OpportunityLineItem tempItem : oppLineItemMap.get(tempId)) {
                lstOppLineItems.add(tempItem);
            }
        }

        mapQueue = GS_WorkOrderDMLHandler.getWOQueueNameWithQueueId(lstOppLineItems);
        rtCancellation = GS_RecordTypeUtility.getRecordType(GS_GlobalVariables.WOCANCELLATION, 'Work_Order__c');

        for (Work_Order__c tempWO : GS_WorkOrderDMLHandler.getWorkOrdersByOpportunityId(oppLineItemMap.keySet())) {
            if (!mapWOWithOppId.containsKey(tempWO.Opportunity__c)) {
                mapWOWithOppId.put(tempWO.Opportunity__c, new List<Work_Order__c> {tempWO});
            } else {
                mapWOWithOppId.get(tempWO.Opportunity__c).add(tempWO);
            }
        }

        for (Id oppId : oppLineItemMap.keySet()) {
            for (OpportunityLineItem tempOppLineItem : oppLineItemMap.get(oppId)) {

                Boolean productExists = false;
                if (mapWOWithOppId.get(oppId) != null) {
                    for (Work_Order__c checkWO : mapWOWithOppId.get(oppId)) {
                        if (String.isNotBlank(tempOppLineItem.Work_Order__c)) {
                            productExists = true;
                            break;
                        }
                    }
                }
                if (productExists) {
                    continue;
                }

                // Create a new work order which is the work order of the opportunity product in current loop
                Work_Order__c tempWO = new Work_Order__c();

                if(mapQueue.containsKey(tempOppLineItem.Product2.Work_Order_Queue__c)) {
                    tempWO.OwnerId = mapQueue.get(tempOppLineItem.Product2.Work_Order_Queue__c);
                }

                tempWO.RecordTypeId = rtCancellation.Id;
                tempWO.Opportunity__c = tempOppLineItem.OpportunityId;
                tempWO.Account__c = tempOppLineItem.Opportunity.AccountId;
                tempWO.Product__c = tempOppLineItem.Product2Id;
                tempWO.Contract__c = tempOppLineItem.Opportunity.Contract__c;
                tempWO.ACpV__c = tempOppLineItem.ACpV__c;
                tempWO.Prior_Year_ACpV__c = tempOppLineItem.Prior_Year_ACpV__c;
                tempWO.Prior_Year_Pass_Through__c = tempOppLineItem.Prior_Year_Pass_Through__c;
                tempWO.TCpV__c = tempOppLineItem.UnitPrice;
                tempWO.Annual_Pass_Through__c = tempOppLineItem.Annual_Pass_Through__c;
                tempWO.Est_Annual_Transaction_Fees__c = tempOppLineItem.Estimated_Annual_Fees__c;
                tempWO.Term_Months__c = tempOppLineItem.Term_Months__c;
                tempWO.Product_Vertical__c = tempOppLineItem.Product_Vertical__c;
                tempWO.Product_Region__c = tempOppLineItem.Product_Region__c;
                tempWO.Referral_Partner__c = tempOppLineItem.Referral_Partner__c;
                tempWO.Sales_Rep__c = tempOppLineItem.Opportunity.OwnerId;
                tempWO.Product_Revenue_Type__c = tempOppLineItem.Product_Revenue_Type__c;
                tempWO.Net_New_Business__c = tempOppLineItem.Net_New_Business__c;
                tempWO.Subscription_Start_Date__c = tempOppLineItem.Subscription_Start_Date__c;
                tempWO.Subscription_End_Date__c = tempOppLineItem.Subscription_End_Date__c;
                tempWO.Product_Transaction_Type__c = tempOppLineItem.Product_Transaction_Type__c;
                tempWO.Dataset__c = tempOppLineItem.Dataset__c;
                tempWO.Site_License__c = tempOppLineItem.Site_License__c;
                tempWO.Data_Region__c = tempOppLineItem.Data_Region__c;
                tempWO.No_of_Users__c = tempOppLineItem.No_of_Users__c;
                tempWO.Est_Completion_Date__c = tempOppLineItem.Estimated_Completion_Date__c;
                tempWO.Opportunity_Product_Est_Completion_Date__c = tempOppLineItem.Estimated_Completion_Date__c;
                tempWO.Est_Start_Date__c = tempOppLineItem.Est_Start_Date__c;
                tempWO.Expense_Cap__c = tempOppLineItem.Expense_Cap__c;
                tempWO.Free_Period_months__c = tempOppLineItem.Free_Period_months__c;
                tempWO.Upfront_Expense_Fee__c = tempOppLineItem.Upfront_Expense_Fee__c;
                tempWO.CurrencyIsoCode = tempOppLineItem.CurrencyIsoCode;
                tempWO.Product_Comments__c = tempOppLineItem.Description;
                tempWO.Debt_Issue_Size__c = tempOppLineItem.Debt_Issue_Size__c;
                tempWO.No_of_Calls__c = tempOppLineItem.No_of_Calls__c;
                tempWO.No_of_Deals__c = tempOppLineItem.No_of_Deals__c;
                tempWO.No_of_Meetings__c = tempOppLineItem.No_of_Meetings__c;
                tempWO.No_of_Conferences__c = tempOppLineItem.No_of_Conferences__c;
                tempWO.No_of_Questions__c = tempOppLineItem.No_of_Questions__c;
                tempWO.No_of_Reports__c = tempOppLineItem.No_of_Reports__c;
                if(tempOppLineItem.Status__c != 'Renewed'){
                    tempWO.Requires_Implementation_UAT__c = tempOppLineItem.Requires_Implementation_UAT__c;
                }

                // Use blank instead of null
                String strExpCompletionDate = tempWO.Est_Completion_Date__c != NULL ? (' - ' + String.valueOf(tempWO.Est_Completion_Date__c)) : '';
                String strProductRegion = tempWO.Product_Region__c != NULL ? (' - ' + tempWO.Product_Region__c) : '';

                tempWO.Name = tempOppLineItem.Opportunity.Account.Name
                              + ' - '
                              + tempOppLineItem.Product2.Name
                              + strExpCompletionDate
                              + strProductRegion;
                // Name max length is 80
                if (tempWO.Name.length() > 80) {
                    tempWO.Name = tempWO.Name.left(80);
                }

                lstTargetOppLineItems.add(tempOppLineItem);
                lstTargetWO.add(tempWO);
            }
        }
        try {

            System.debug(LoggingLevel.INFO, '*** lstTargetWO: ' + lstTargetWO);
            insert lstTargetWO;

            for (Integer i = 0; i < lstTargetWO.size(); i++) {
                lstTargetOppLineItems[i].Work_Order__c = lstTargetWO[i].Id;
            }
            update lstTargetOppLineItems;
        } catch (Exception ex) {
            System.debug(LoggingLevel.INFO, '*** ex.getMessage(): ' + ex.getMessage());
            processException(ex);            
        }
    }
    public void processException(Exception ex){
            String errorMessage = '';
            if(ex.getTypeName() == 'System.DmlException'){
                Set<String> errorMessages = new Set<String>();
                for (Integer i = 0; i < ex.getNumDml(); i++) {
                    errorMessages.add(ex.getDmlMessage(i));
                }               
                Integer i = 0;          
                for(String message: errorMessages){
                        errorMessage += message+(i == errorMessages.size()-1 ? '' : '<br/>');
                        i = i+1;
                }
            }
            else{
                errorMessage = 'Internal System Error.';    
            }
        if(!Test.isRunningTest()){
            for(ID oppId : Trigger.newMap.keySet()){
                    Opportunity opp = (Opportunity)Trigger.newMap.get(oppId);
                    opp.addError('Errors while saving related records: '+errorMessage+'<br/>Please contact your System administrator.<br/>',false);
                }   
        }
    }

}