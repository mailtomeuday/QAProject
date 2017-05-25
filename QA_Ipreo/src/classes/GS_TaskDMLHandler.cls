/**************************************************************************************************
 * Name           : GS_TaskDMLHandler
 * Object         : Task
 * Requirement    : 
 * Target         : DML on Task
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-08-17
 * Modify History :
 **************************************************************************************************/
public class GS_TaskDMLHandler {
    public static List<Task> getTasksByIds(List<Id> lstTaskIds) {
    	return [SELECT Id
    				  ,Alert_Sent_Date__c
    				  ,Send_Alert__c
    				  ,Type
    				  ,Status
    			FROM Task
    			WHERE Id =: lstTaskIds];
    }
}