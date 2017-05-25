/**************************************************************************************************
 * Name           : GS_AttachmentTrigger
 * Object         : Attachment
 * Requirement    : 
 * Target         : Trigger handlers are bound in this trigger.
 * Refer classes  : 
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-10-07
 * Modify History :
 **************************************************************************************************/
trigger GS_AttachmentTrigger on Attachment (after insert, after delete, after undelete) {
	new GS_Triggers()

    //After Insert
    .bind(GS_Triggers.Evt.afterinsert,new GS_AttachmentCalNumberTHandler())
	
    //After Delete
    .bind(GS_Triggers.Evt.afterdelete,new GS_AttachmentCalNumberTHandler())
	
    //After Undelete
    .bind(GS_Triggers.Evt.afterundelete,new GS_AttachmentCalNumberTHandler())

    .manage();
}