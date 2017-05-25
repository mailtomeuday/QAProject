/**************************************************************************************************
 * Name           : GS_AccountTrigger
 * Object         : Account
 * Requirement    : STY-00012
 * Target         : Trigger handlers are bound in this trigger.
 * Refer classes  : 
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-07-06
 * Modify History :
 **************************************************************************************************/
trigger GS_AccountTrigger on Account(before insert, before update, after update, before delete) {
    new GS_Triggers()
    // before insert
    .bind(GS_Triggers.Evt.beforeinsert,new GS_AccountValidationTHandler())
    .bind(GS_Triggers.Evt.beforeinsert,new GS_AccountUpdateStatusTHandler())

    // before update
    .bind(GS_Triggers.Evt.beforeupdate,new GS_AccountValidationTHandler())
    .bind(GS_Triggers.Evt.beforeupdate,new GS_AccountUpdateStatusTHandler())
    .bind(GS_Triggers.Evt.afterupdate,new GS_AccountStatsTHandler())
    
    // before delete
    .bind(GS_Triggers.Evt.beforedelete,new GS_AccountValidationTHandler())   
    .manage();
}