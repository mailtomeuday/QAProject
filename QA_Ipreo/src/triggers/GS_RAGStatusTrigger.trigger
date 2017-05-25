/**************************************************************************************************
 * Name           : GS_RAGStatusTrigger
 * Object         : RAG Status
 * Requirement    : SPS-1506
 * Target         : Trigger handlers are bound in this trigger.
 * Refer classes  : GS_AssetUpdateACCStatusHandler
 * Author         : Joshi (ambadas_morkhandikar@epam.com)
 * Create Date    : 2016-12-21
 * Modify History :
 **************************************************************************************************/
trigger GS_RAGStatusTrigger on RAG_Status__c (after delete, after insert, after undelete, after update) {
	new GS_Triggers()
	//After Insert
	.bind(GS_Triggers.Evt.afterinsert,new GS_RAGStatusUpdateAssetTHandler())
	
	//After Update
	.bind(GS_Triggers.Evt.afterupdate,new GS_RAGStatusUpdateAssetTHandler())
	
	//After delete
	.bind(GS_Triggers.Evt.afterdelete,new GS_RAGStatusUpdateAssetTHandler())
	
	//After undelete
	.bind(GS_Triggers.Evt.afterundelete,new GS_RAGStatusUpdateAssetTHandler())
	.manage();
}