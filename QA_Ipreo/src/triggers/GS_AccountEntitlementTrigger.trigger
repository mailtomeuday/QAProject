/**************************************************************************************************
 * Name           : GS_AccountEntitlementTrigger
 * Object         : Account
 * Requirement    : 
 * Target         : This trigger is seperated from the account trigger, because this trigger should be
 *                  inactive until phase 2.
 * Refer classes  : 
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-11-24
 * Modify History :
 **************************************************************************************************/
trigger GS_AccountEntitlementTrigger on Account(after insert) {
    new GS_Triggers()
    // after insert
    .bind(GS_Triggers.Evt.afterinsert,new GS_AccountCreateEntitlementTHandler())

    .manage();
}