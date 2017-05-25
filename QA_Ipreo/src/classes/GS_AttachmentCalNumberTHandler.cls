/**************************************************************************************************
 * Name           : GS_AttachmentCalNumberTHandler
 * Object         : Attachment
 * Requirement    :
 * Target         : When attachment is inserted, updated, deleted, undeleted,
 * 					assign the value of No. of Attachments on Contact__c
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-10-07
 * Modify History :
 **************************************************************************************************/
public class GS_AttachmentCalNumberTHandler implements GS_Triggers.Handler {

	public void handle() {

		System.debug(LoggingLevel.INFO, '*** GS_AttachmentCalNumberTHandler fires');

		// A set of parentId from attachments. Check which contract's attachment number is changed
		Set<Id> contractIds = new Set<Id>();
		if (Trigger.isInsert || Trigger.isUndelete) {
			for (Attachment att : (List<Attachment>)Trigger.New) {
				contractIds.add(att.ParentId);
			}
		} else if (Trigger.isDelete) {
			for (Attachment att : (List<Attachment>)Trigger.Old) {
				contractIds.add(att.ParentId);
			}
		}

		calculateAttachmentsNum(contractIds);
	}

	private void calculateAttachmentsNum (Set<Id> contractIds) {
		List<Contract__c> lstTargetContract = new List<Contract__c>();
		for(Contract__c con : GS_ContractDMLHandler.getContractsWithAttsByIds(contractIds)) {
			System.debug(LoggingLevel.INFO, '*** con: ' + con);
			if(con.Attachments != NULL){
				con.No_of_Attachments__c = con.Attachments.size();
				lstTargetContract.add(con);
			}
		}
		try{
			update lstTargetContract;
		} catch(DmlException ex) {
			System.debug(LoggingLevel.Error, '*** ex.getDmlMessage(0)): ' + ex.getDmlMessage(0));
			if (Trigger.isInsert || Trigger.isUndelete) {
				for (Attachment att : (List<Attachment>)Trigger.New) {
					if(att.ParentId == ex.getDmlId(0)) {
						att.addError(ex.getDmlMessage(0));
					}
				}
			} else if (Trigger.isDelete) {
				for (Attachment att : (List<Attachment>)Trigger.Old) {
					if(att.ParentId == ex.getDmlId(0)) {
						att.addError(ex.getDmlMessage(0));
					}
				}
			}
		}
	}
}