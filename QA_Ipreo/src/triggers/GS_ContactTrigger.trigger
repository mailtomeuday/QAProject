/**************************************************************************************************
 * Name           : GS_ContactTrigger
 * Object         : Contact
 * Requirement    : 
 * Target         : Trigger handlers are bound in this trigger.
 * Refer classes  : 
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-12-23
 * Modify History :
 **************************************************************************************************/
trigger GS_ContactTrigger on Contact(before insert, before update, after update, before delete) {
    new GS_Triggers()
    // before insert
    .bind(GS_Triggers.Evt.beforeinsert,new GS_ContactValidationTHandler())
    .bind(GS_Triggers.Evt.beforeinsert,new GS_ContactAssignValueTHandler())

    // before update
    .bind(GS_Triggers.Evt.beforeupdate,new GS_ContactValidationTHandler())
    .bind(GS_Triggers.Evt.beforeupdate,new GS_ContactAssignValueTHandler())
    
    // before delete
    .bind(GS_Triggers.Evt.beforedelete,new GS_ContactValidationTHandler())
    .manage();
}