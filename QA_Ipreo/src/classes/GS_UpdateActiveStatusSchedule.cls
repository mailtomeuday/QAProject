/**************************************************************************************************
 * Name           : GS_UpdateActiveStatusSchedule
 * Object         : Work_Order__c
 * Requirement    : STY-00012
 * Target         : Update the Active field on Work Order and make it align with the field Auto_Populated_Active_Status__c
 * Refer classes  : GS_WorkOrderUpdateActiveStatusHandler
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-06-03
 * Modify History :
 **************************************************************************************************/
global class GS_UpdateActiveStatusSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new GS_WorkOrderUpdateStatusBatch(), 200);
    }
}