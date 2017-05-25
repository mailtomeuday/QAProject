/**************************************************************************************************
 * Name           : GS_UserAssetTrigger
 * Object         : User_Asset__c
 * Requirement    : 
 * Target         : Trigger handlers are bound in this trigger.
 * Refer classes  : 
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-06-01
 * Modify History :
 **************************************************************************************************/
trigger GS_UserAssetTrigger on User_Asset__c(before insert, before update, after insert, after update, after delete, after undelete) {

    new GS_Triggers()
    // before insert
    .bind(GS_Triggers.Evt.beforeinsert, new GS_UserAssetValidationTHandler())
    .bind(GS_Triggers.Evt.beforeinsert,new GS_UserAssetInitalStatusTHandler())
    .bind(GS_Triggers.Evt.beforeinsert,new GS_UserAssetAssignAccTHandler())

    // before update
    .bind(GS_Triggers.Evt.beforeupdate, new GS_UserAssetValidationTHandler())
    .bind(GS_Triggers.Evt.beforeupdate,new GS_UserAssetAssignAccTHandler())


    // After insert
    .bind(GS_Triggers.Evt.afterinsert,new GS_UserAssetUpdateContactValueTHandler())
    .bind(GS_Triggers.Evt.afterinsert, new GS_UserAssetValidationTHandler())


    // After update
    .bind(GS_Triggers.Evt.afterupdate,new GS_UserAssetUpdateContactValueTHandler())

    // After delete
    .bind(GS_Triggers.Evt.afterdelete,new GS_UserAssetUpdateContactValueTHandler())

    // After undelete
    .bind(GS_Triggers.Evt.afterundelete,new GS_UserAssetUpdateContactValueTHandler())

    .manage();
}