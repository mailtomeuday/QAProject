/**************************************************************************************************
 * Name           : GS_WorkOrderDMLHandler
 * Object         : Work_Order__c
 * Requirement    : 
 * Target         : DML on Work_Order__c
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-06-15
 * Modify History :
 **************************************************************************************************/
public class GS_WorkOrderDMLHandler {

	public static List<Work_Order__c> getWorkOrdersByOpportunityId(Set<Id> OpportunityIds) {
		return [SELECT Name
					  ,Opportunity__c
					  ,OwnerId
					  ,Account__c
					  ,Product__c
					  ,Contract__c
					  ,Est_Completion_Date__c
					  ,Opportunity_Product_Est_Completion_Date__c
					  ,ACpV__c
					  ,Prior_Year_ACpV__c
					  ,TCpV__c
					  ,Annual_Pass_Through__c
					  ,Est_Annual_Transaction_Fees__c
					  ,Term_Months__c
					  ,Product_Vertical__c
					  ,Product_Region__c
					  ,Referral_Partner__c
					  ,RecordTypeId
					  ,Sales_Rep__c
					  ,Product_Revenue_Type__c
					  ,Net_New_Business__c
					  ,Subscription_Start_Date__c
					  ,Subscription_End_Date__c
				FROM Work_Order__c
				WHERE Opportunity__c =: OpportunityIds];
	}

    // get Queue Id for each product, key is queue name and value is queue id
    // Since every productlineitem has a product so input in a list of opportunityLineItem
    public static Map<String, Id> getWOQueueNameWithQueueId(List<OpportunityLineItem> lstOpportunityLineItem) {

        Set<String> stQueueName = new Set<String>();
        // key is queue name and value is queue id
        Map<String, Id> mapQueue = new Map<String, Id>();

        // Get all selected queues
        for(OpportunityLineItem temp : lstOpportunityLineItem) {
            if(!stQueueName.contains(temp.Product2.Work_Order_Queue__c)){
                stQueueName.add(temp.Product2.Work_Order_Queue__c);
            }
        }

        for(QueueSobject tempQueueSobj : GS_GroupDMLHandler.getQueuesByObjNameAndQueueName(stQueueName, 'Work_Order__c')) {
            mapQueue.put(tempQueueSobj.Queue.Name, tempQueueSobj.QueueId);
        }

        return mapQueue;
    }
    
}