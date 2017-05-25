/**************************************************************************************************
 * Name           : GS_WorkOrderUpdateStatusQueueable
 * Object         : Work_Order__c
 * Requirement    : STY-00012
 * Target         : This is a queueable class, it will proceed work order active status logic,
 *                  and it will chain queueable class to update license and asset active status. 
 * Refer classes  : 
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-06-03
 * Modify History :
 **************************************************************************************************/
global class GS_WorkOrderUpdateStatusQueueable implements Queueable{
    global void execute(QueueableContext context) {
    	System.debug(LoggingLevel.INFO, '*** GS_WorkOrderUpdateStatusQueueable is executed.');
        GS_WorkOrderUpdateActiveStatusHandler.updateActiveStatus();
        If(!Test.isRunningTest()){
        	System.enqueueJob(new GS_LicenseUpdateStatusQueueable());
        }
    }
}