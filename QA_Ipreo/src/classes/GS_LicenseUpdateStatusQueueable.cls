/**************************************************************************************************
 * Name           : GS_ProjectUpdateStatusQueueable
 * Object         : License
 * Requirement    : STY-00012
 * Target         : This is a queueable class, it will proceed project asset status logic,
 *                  and it will chain queueable class to update license and asset active status. 
 * Refer classes  : 
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-06-04
 * Modify History :
 **************************************************************************************************/
global class GS_LicenseUpdateStatusQueueable implements Queueable{
    global void execute(QueueableContext context) {
    	System.debug(LoggingLevel.INFO, '*** GS_LicenseUpdateStatusQueueable is executed.');
        GS_LicenseUpdateActiveStatusHandler.updateStatus();
    }
}