/**************************************************************************************************
 * Name           : GS_ContactAssignValueTHandler
 * Object         : Contact
 * Requirement    :
 * Target         : Trigger handlers are bound in this trigger.
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-12-23
 * Modify History :
 **************************************************************************************************/
public class GS_ContactAssignValueTHandler implements GS_Triggers.Handler {
	public void handle() {
		if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore) {
			assignContactEmail();
		}
	}

	private void assignContactEmail() {
		for(Contact con : (List<Contact>)Trigger.new) {
			if(String.isNotBlank(con.BDEmail__c) && String.isBlank(con.Email)) {
				if(GS_CommonUtility.isValidEmailFormat(con.BDEmail__c)) {
					con.Email = con.BDEmail__c;
				}
			}
		}
	}
}