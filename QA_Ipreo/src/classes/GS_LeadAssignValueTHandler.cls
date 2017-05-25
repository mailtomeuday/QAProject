/**************************************************************************************************
 * Name           : GS_LeadAssignValueTHandler
 * Object         : Lead
 * Requirement    :
 * Target         : Trigger handlers are bound in this trigger.
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-12-23
 * Modify History :
 **************************************************************************************************/
public class GS_LeadAssignValueTHandler implements GS_Triggers.Handler {
	public void handle() {
		if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore) {
			assignLeadEmail();
		}
	}

	private void assignLeadEmail() {
		for(Lead ld : (List<Lead>)Trigger.new) {
			if(String.isNotBlank(ld.BDEmail__c) && String.isBlank(ld.Email)) {
				if(GS_CommonUtility.isValidEmailFormat(ld.BDEmail__c)) {
					ld.Email = ld.BDEmail__c;
				}
			}
		}
	}
}