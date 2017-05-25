/**************************************************************************************************
 * Name           : GS_AssetTrigger
 * Object         : Asset
 * Requirement    : STY-00012
 * Target         : Trigger handlers are bound in this trigger.
 * Refer classes  : GS_AssetUpdateACCStatusHandler
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-06-01
 * Modify History :
 **************************************************************************************************/
trigger GS_AssetTrigger on Asset (before insert, before update, after insert, after update, after delete, after undelete) {
    new GS_Triggers()

    // Before Insert
    .bind(GS_Triggers.Evt.beforeinsert,new GS_AssetAssignValueTHandler())

    // Before Update
    .bind(GS_Triggers.Evt.beforeupdate,new GS_AssetAssignValueTHandler())

    //After Insert
    .bind(GS_Triggers.Evt.afterinsert,new GS_AssetUpdateACCStatusTHandler())
    .bind(GS_Triggers.Evt.afterinsert,new GS_AssetUpdateACCRAGScoreTHandler())

    //After Update
    .bind(GS_Triggers.Evt.afterupdate,new GS_AssetUpdateACCStatusTHandler())
    .bind(GS_Triggers.Evt.afterupdate,new GS_AssetUpdateACCRAGScoreTHandler())
    .bind(GS_Triggers.Evt.afterupdate,new GS_AssetUpdateUserAssetStatusTHandler())
    .bind(GS_Triggers.Evt.afterupdate,new GS_AssetUpdateSponsAssetStatusTHandler())

    // After delete
    .bind(GS_Triggers.Evt.afterdelete,new GS_AssetUpdateACCStatusTHandler())
    .bind(GS_Triggers.Evt.afterdelete,new GS_AssetUpdateACCRAGScoreTHandler())

    // After undelete
    .bind(GS_Triggers.Evt.afterundelete,new GS_AssetUpdateACCStatusTHandler())
    .bind(GS_Triggers.Evt.afterundelete,new GS_AssetUpdateACCRAGScoreTHandler())

    .manage();
}