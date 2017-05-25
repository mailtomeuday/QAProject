/**************************************************************************************************
 * Name           : GS_WorkOrderUpdateActiveStatusHandler
 * Object         : Work_Order
 * Requirement    : STY-00012
 * Target         : For each work order of record type “Research”, If Completion Date populated and year = current year,
 *                  active. Else If Completion Date not populated and Expected Completion Date populated and
 *                  Expected Completion Date year = current year, active Else, inactive.
 *                  A formula field has been created to follow the logic above. This class will update another field
 *                  align the formula field.
 * Refer classes  : 
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-06-03
 * Modify History :
 **************************************************************************************************/
public with sharing class GS_WorkOrderUpdateActiveStatusHandler {
    
	public static void updateActiveStatus() {
		System.debug(LoggingLevel.INFO, '*** : GS_WorkOrderUpdateActiveStatusHandler.updateActiveStatus is execueted.');
		List<Work_Order__c> listWO;
		List<Work_Order__c> listTargetWO;

		listTargetWO = new List<Work_Order__c>();
		listWO = [SELECT Id
			                ,Active__c
			                ,Auto_Populated_Active_Status__c
			          FROM Work_Order__c
			          WHERE Active_Need_to_Be_Updated__c = true
			          Limit 3000];

		for(Work_Order__c tempWO : listWO) {
			tempWO.Active__c = tempWO.Auto_Populated_Active_Status__c;
			listTargetWO.add(tempWO);
		}

		update listTargetWO;
	}
}