/**************************************************************************************************
 * Name           : GS_OpportunityProductTrigger
 * Object         : OpportunityLineItem
 * Requirement    : 
 * Target         : Trigger handlers are bound in this trigger.
 * Refer classes  : 
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-06-16
 * Modify History :
 **************************************************************************************************/
trigger GS_OpportunityProductTrigger on OpportunityLineItem(before insert, after insert, before update, after update, after delete, after undelete) {
    new GS_Triggers()
    // Before insert
    .bind(GS_Triggers.Evt.beforeinsert,new GS_OppLineItemCalNetNewBizTHandler())
    .bind(GS_Triggers.Evt.beforeinsert,new GS_OpportunityProductAssignValueTHander())
    .bind(GS_Triggers.Evt.beforeinsert,new GS_OppLineItemUpdateProductTHandler())

    // After insert
    .bind(GS_Triggers.Evt.afterinsert,new GS_OppLineItemUpdateOppValueTHander())

    // Before update
    .bind(GS_Triggers.Evt.beforeupdate,new GS_OppLineItemCalNetNewBizTHandler())

    // After update
    .bind(GS_Triggers.Evt.afterupdate,new GS_OppLineItemRecordValidationTHandler())
    .bind(GS_Triggers.Evt.afterupdate,new GS_OppLineItemUpdateProductTHandler())
    .bind(GS_Triggers.Evt.afterupdate,new GS_OppLineItemUpdateOppValueTHander())

    // After delete
    .bind(GS_Triggers.Evt.afterdelete,new GS_OppLineItemUpdateOppValueTHander())

    // After undelete
    .bind(GS_Triggers.Evt.afterundelete,new GS_OppLineItemUpdateOppValueTHander())

    .manage();
}