/**************************************************************************************************
 * Name           : GS_OpportunityTrigger
 * Object         : Opportunity
 * Requirement    : STY-00070 / TY-00070
 * Target         : Trigger handlers are bound in this trigger.
 * Refer classes  : 
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-06-09
 * Modify History :
 **************************************************************************************************/
trigger GS_OpportunityTrigger on Opportunity(before insert, after insert, before update, after update) {
    new GS_Triggers()
    // Before insert
    .bind(GS_Triggers.Evt.beforeinsert,new GS_OpportunityAssignValueTHandler())
    .bind(GS_Triggers.Evt.afterinsert,new GS_OpportunityUpdateTeamMemberHandler())
    // Before update
    .bind(GS_Triggers.Evt.beforeupdate,new GS_OpportunityValidationTHandler())
    .bind(GS_Triggers.Evt.beforeupdate,new GS_OpportunityAssignValueTHandler())
    .bind(GS_Triggers.Evt.beforeupdate,new GS_OpportunitySetRenewalDateHandler())

    // After update
    .bind(GS_Triggers.Evt.afterupdate,new GS_OpportunityClosedWonTHandler())
    .bind(GS_Triggers.Evt.afterupdate,new GS_OpportunityClosedTHandler())
    .bind(GS_Triggers.Evt.afterupdate,new GS_OppSyncLineItemAccTHandler())
    .bind(GS_Triggers.Evt.afterupdate,new GS_OpportunityUnfollowHandler())

    .manage();
}