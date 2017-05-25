/**************************************************************************************************
 * Name           : GS_EventTrigger
 * Object         : Event
 * Requirement    : 
 * Target         : Trigger handlers are bound in this trigger.
 * Refer classes  : 
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-08-21
 * Modify History :
 **************************************************************************************************/
trigger GS_EventTrigger on Event(before insert, after insert, before update, after update) {
	new GS_Triggers()

	// before insert
    .bind(GS_Triggers.Evt.beforeinsert,new GS_EventAssignValueTHandler())
    
    // after insert
    .bind(GS_Triggers.Evt.afterinsert,new GS_EventSendAlertsTHandler())

    // before update
    .bind(GS_Triggers.Evt.beforeupdate,new GS_EventAssignValueTHandler())

    // after update
    .bind(GS_Triggers.Evt.afterupdate,new GS_EventSendAlertsTHandler())

    .manage();
}