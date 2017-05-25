/**************************************************************************************************
 * Name           : GS_CaseTrigger
 * Object         : Case
 * Requirement    : 
 * Target         : Trigger handlers are bound in this trigger.
 * Refer classes  : 
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-07-06
 * Modify History :
 **************************************************************************************************/
trigger GS_CaseTrigger on Case(before insert, after insert, before update) {

    new GS_Triggers()
    // before insert
    .bind(GS_Triggers.Evt.beforeinsert, new GS_CaseAssignValueTHandler())
    .bind(GS_Triggers.Evt.beforeinsert, new GS_CaseGetEntitlementTHandler())
    .bind(GS_Triggers.Evt.beforeinsert, new GS_CaseAssignOwnerManagerTHandler())
    .bind(GS_Triggers.Evt.beforeinsert, new GS_CaseAutomateCloseMunisAndFITHandler())
    
    // after insert
    .bind(GS_Triggers.Evt.afterinsert, new GS_CaseDealMileStoneTHandler())
    
    // before update
    .bind(GS_Triggers.Evt.beforeupdate, new GS_CaseAssignValueTHandler())
    .bind(GS_Triggers.Evt.beforeupdate, new GS_CaseGetEntitlementTHandler())
    .bind(GS_Triggers.Evt.beforeupdate, new GS_CaseAssignOwnerManagerTHandler())
    .bind(GS_Triggers.Evt.beforeupdate, new GS_CaseDealMileStoneTHandler())
    .manage();
}