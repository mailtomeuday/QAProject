/**************************************************************************************************
 * Name           : GS_WorkOrderUpdateStatusTrigger
 * Object         : Work_Order__c
 * Requirement    : STY-00012
 * Target         : Trigger handlers are bound in this trigger.
 * Refer classes  : GS_WOUpdateACCStatusHandler
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-06-01
 * Modify History :
 **************************************************************************************************/
trigger GS_WorkOrderUpdateStatusTrigger on Work_Order__c(before insert, before update, after insert, after update, after delete, after undelete) {
	new GS_Triggers()
    // After Update
    .bind(GS_Triggers.Evt.afterupdate,new GS_WorkOrderUpdateACCStatusTHandler())

    // Remove this for tempory, this should be delete when deploy to QA
    //.bind(GS_Triggers.Evt.afterupdate,new GS_WorkOrderPopulateSubDateTHandler())

    // After Insert
    .bind(GS_Triggers.Evt.afterinsert,new GS_WorkOrderUpdateACCStatusTHandler())

    // After delete
    .bind(GS_Triggers.Evt.afterdelete,new GS_WorkOrderUpdateACCStatusTHandler())

    // After undelete
    .bind(GS_Triggers.Evt.afterundelete,new GS_WorkOrderUpdateACCStatusTHandler())

    .manage();
}