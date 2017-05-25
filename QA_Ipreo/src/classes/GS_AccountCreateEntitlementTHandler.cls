/**************************************************************************************************
 * Name           : GS_AccountCreateEntitlementTHandler
 * Object         : Account
 * Requirement    : STY-00115
 * Target         : Create Entitlement for accounts
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-07-23
 * Modify History :
 **************************************************************************************************/
public class GS_AccountCreateEntitlementTHandler implements GS_Triggers.Handler {
    public void handle() {
    	if(Trigger.isInsert) {
    		Map<Id, Account> newAccountMap = (Map<Id, Account>)Trigger.newMap;
    		createEntitlementsbyAccounts(newAccountMap);
    	}
    }

    // Insert entitlement: Entitlement Name = Account.Name, Account Name = Account.Id, Entitlement Process = Standard OLA
    public static void createEntitlementsbyAccounts(Map<Id, Account> mapAccount) {

    	List<Entitlement> lstInsertEntitlement = new List<Entitlement>();
    	SlaProcess standardSlaProcess = GS_SlaProcessDMLHandler.getStandardSLA();

    	// Generate entitlements for each account
    	if(String.isNotBlank(standardSlaProcess.Id)) {
	    	for(Id tempId : mapAccount.keySet()) {
	    		Entitlement tempEntitlement = new Entitlement();
	    		tempEntitlement.Name = mapAccount.get(tempId).Name;
	    		tempEntitlement.AccountId = mapAccount.get(tempId).Id;
	    		tempEntitlement.SlaProcessId = standardSlaProcess.Id;
	    		lstInsertEntitlement.add(tempEntitlement);
	    	}
	    }

	    try {
	    	List<Database.SaveResult> results = Database.insert(lstInsertEntitlement, false);
	    	for (Integer j = 0; j < results.size(); j++) {
	    		if(!results[j].isSuccess()) {
	    			String strErrorMsg = '';
	    			for(Database.Error tempError : results[j].getErrors()) {
	    				strErrorMsg = tempError + tempError.getMessage() + ' ';
	    			}
	    			mapAccount.get(lstInsertEntitlement[j].AccountId).addError(strErrorMsg);
	    		}
	    	}
	    } catch(Exception ex) {
	    	System.debug(LoggingLevel.Error, '*** ex.getMessage(): ' + ex.getMessage());
	    }
    }
}