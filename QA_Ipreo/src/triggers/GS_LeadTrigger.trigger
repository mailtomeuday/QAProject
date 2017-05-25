/**************************************************************************************************
 * Name           : GS_LeadTrigger
 * Object         : Lead
 * Requirement    : 
 * Target         : Trigger handlers are bound in this trigger.
 * Refer classes  : 
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-12-23
 * Modify History :
 **************************************************************************************************/
trigger GS_LeadTrigger on Lead(before insert, before update) {
	new GS_Triggers()
	// before insert
    .bind(GS_Triggers.Evt.beforeinsert,new GS_LeadValidationTHandler())
    .bind(GS_Triggers.Evt.beforeinsert,new GS_LeadAssignValueTHandler())

	// before update
    .bind(GS_Triggers.Evt.beforeupdate,new GS_LeadValidationTHandler())
    .bind(GS_Triggers.Evt.beforeupdate,new GS_LeadAssignValueTHandler())
    .manage();
}