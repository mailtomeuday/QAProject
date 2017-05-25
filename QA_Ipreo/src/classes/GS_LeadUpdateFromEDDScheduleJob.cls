/**************************************************************************************************
 * Name           : GS_LeadUpdateFromEDDScheduleJob
 * Object         : Lead
 * Requirement    : 
 * Target         : 
 * Refer classes  :  
 * Author         : Katherine Chen
 * Create Date    : 2016-04-12
 * Modify History :
 **************************************************************************************************/
global class GS_LeadUpdateFromEDDScheduleJob implements Schedulable {
    global void execute(SchedulableContext sc) {
    	GS_LeadUpdateFromEDDBatch batchJob = new GS_LeadUpdateFromEDDBatch();
    	Database.executeBatch(batchJob, 50);
    }
}