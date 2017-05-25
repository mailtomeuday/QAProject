/**************************************************************************************************
 * Name           : GS_LeadInsertFromEDDScheduleJob
 * Object         : Lead
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Katherine Chen
 * Create Date    : 2016-04-05
 * Modify History :
 **************************************************************************************************/
global class GS_LeadInsertFromEDDScheduleJob implements Schedulable {
    global void execute(SchedulableContext sc) {
    	GS_LeadInsertFromEDDBatch batchJob = new GS_LeadInsertFromEDDBatch();
    	Database.executeBatch(batchJob, 50);
    }
}