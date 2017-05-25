/**************************************************************************************************
 * Name           : GS_TaskTrigger
 * Object         : Task
 * Requirement    : 
 * Target         : Trigger handlers are bound in this trigger.
 * Refer classes  : 
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-08-06
 * Modify History :
 **************************************************************************************************/
trigger GS_TaskTrigger on Task(before insert, after insert, before update, after update) {
    new GS_Triggers()

    // before insert
    .bind(GS_Triggers.Evt.beforeinsert,new GS_TaskAssignValueTHandler())

    // after insert
    .bind(GS_Triggers.Evt.afterinsert,new GS_TaskSendAlertsTHandler())

    // before update
    .bind(GS_Triggers.Evt.beforeupdate,new GS_TaskAssignValueTHandler())

    // after update
    .bind(GS_Triggers.Evt.afterupdate,new GS_TaskSendAlertsTHandler())

    .manage();
}