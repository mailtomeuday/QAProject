/**************************************************************************************************
 * Name           : GS_SponsoredAssetTrigger
 * Object         : Sponsored_Asset__c
 * Requirement    : 
 * Target         : Trigger handlers are bound in this trigger.
 * Refer classes  : 
 * Author         : Ambadas Joshi M <ambadas_morkhandikar@epam.com>
 * Create Date    : 2016-06-06
 * Modify History :
 **************************************************************************************************/

trigger GS_SponsoredAssetTrigger on Sponsored_Asset__c (before insert, before update) {

	new GS_Triggers()
    // before insert
    .bind(GS_Triggers.Evt.beforeinsert, new GS_SponsoredAssetValidationTHandler())

    // before update
    .bind(GS_Triggers.Evt.beforeupdate, new GS_SponsoredAssetValidationTHandler())

    .manage();
}