/**************************************************************************************************
 * Name           : GS_AccountUpdateStatusTHandler
 * Object         : Account
 * Requirement    : STY-0012
 * Target         : Update Account Status
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-07-06
 * Modify History : automatically update account type, vertical upon BDTypeName__c 12/10/15
 **************************************************************************************************/
public class GS_AccountUpdateStatusTHandler implements GS_Triggers.Handler {

	public void handle() {
        
        Set<String> accTypeSet = new Set<String>();
        Map<String, String> dependentMap = new Map<String, String>();
        PicklistFieldController controller = new PicklistFieldController();
        Map<String,Set<String>> valueMap = controller.getDependentOptionsImpl('Account', 'Vertical__C', 'Account_Type__c');
        for(String s : valueMap.keySet()) {
            for(String s1 : valueMap.get(s)) {
                accTypeSet.add(s1);
                dependentMap.put(s1, s);
            }
        }
		if (Trigger.isBefore) {
			if (Trigger.isInsert) {
				for (Account tempAcc : (List<Account>)Trigger.new) {

					if (tempAcc.No_of_Active_Sponsored_Assets__c == 0
					        && tempAcc.No_of_Active_Work_Orders__c == 0
					        && tempAcc.No_of_Active_Assets__c == 0) {
						if (tempAcc.No_of_Sponsored_Assets__c == 0
						     && tempAcc.No_of_All_Work_Orders__c == 0
						     && tempAcc.No_of_All_Assets__c == 0) {
							tempAcc.status__c = GS_GlobalVariables.ACCSTATUSPROSPECT;
						} else {
							tempAcc.status__c = GS_GlobalVariables.ACCSTATUSFORMERCLIENT;
						}
					} else {
						tempAcc.status__c = GS_GlobalVariables.ACCSTATUSCLIENT;
					}
                    if(accTypeSet.contains(tempAcc.BDTypeName__c)) {
                        tempAcc.Account_Type__c = tempAcc.BDTypeName__c;
                        tempAcc.Vertical__c = dependentMap.get(tempAcc.BDTypeName__c);
                    }
				}
			}

			if (Trigger.isUpdate) {

				Map<Id, Account> newAccountMap = (Map<Id, Account>)Trigger.newMap;
				Map<Id, Account> oldAccountMap = (Map<Id, Account>)Trigger.oldMap;

				for (Id tempAccId : Trigger.newMap.keySet()) {
					if (newAccountMap.get(tempAccId).No_of_All_Assets__c != oldAccountMap.get(tempAccId).No_of_All_Assets__c
					     || newAccountMap.get(tempAccId).No_of_All_Work_Orders__c != oldAccountMap.get(tempAccId).No_of_All_Work_Orders__c
					     || newAccountMap.get(tempAccId).No_of_Active_Assets__c != oldAccountMap.get(tempAccId).No_of_Active_Assets__c
					     || newAccountMap.get(tempAccId).No_of_Active_Work_Orders__c != oldAccountMap.get(tempAccId).No_of_Active_Work_Orders__c
					     || newAccountMap.get(tempAccId).No_of_Active_Sponsored_Assets__c != oldAccountMap.get(tempAccId).No_of_Active_Sponsored_Assets__c
					     || newAccountMap.get(tempAccId).No_of_Sponsored_Assets__c != oldAccountMap.get(tempAccId).No_of_Sponsored_Assets__c
                         || (!String.isBlank(newAccountMap.get(tempAccId).BDTypeName__c) && newAccountMap.get(tempAccId).BDTypeName__c != oldAccountMap.get(tempAccId).BDTypeName__c)) {

						System.debug(LoggingLevel.INFO, '*** GS_AccountUpdateStatusTHandler is executed when updated and meet filters. ');
						System.debug(LoggingLevel.INFO, '*** newAccountMap.get(tempAccId).No_of_All_Assets__c: ' + newAccountMap.get(tempAccId).No_of_All_Assets__c);
						System.debug(LoggingLevel.INFO, '*** newAccountMap.get(tempAccId).No_of_All_Work_Orders__c: ' + newAccountMap.get(tempAccId).No_of_All_Work_Orders__c);
						System.debug(LoggingLevel.INFO, '*** newAccountMap.get(tempAccId).No_of_Active_Assets__c: ' + newAccountMap.get(tempAccId).No_of_Active_Assets__c);
						System.debug(LoggingLevel.INFO, '*** newAccountMap.get(tempAccId).No_of_Active_Work_Orders__c: ' + newAccountMap.get(tempAccId).No_of_Active_Work_Orders__c);
						System.debug(LoggingLevel.INFO, '*** newAccountMap.get(tempAccId).No_of_Active_Sponsored_Assets__c: ' + newAccountMap.get(tempAccId).No_of_Active_Sponsored_Assets__c);
						System.debug(LoggingLevel.INFO, '*** newAccountMap.get(tempAccId).No_of_Sponsored_Assets__c: ' + newAccountMap.get(tempAccId).No_of_Sponsored_Assets__c);


						if ( newAccountMap.get(tempAccId).No_of_Active_Sponsored_Assets__c == 0
						        && newAccountMap.get(tempAccId).No_of_Active_Work_Orders__c == 0
						        && newAccountMap.get(tempAccId).No_of_Active_Assets__c == 0) {
							if (newAccountMap.get(tempAccId).No_of_Sponsored_Assets__c == 0
							     && newAccountMap.get(tempAccId).No_of_All_Work_Orders__c == 0
							     && newAccountMap.get(tempAccId).No_of_All_Assets__c == 0) {
								newAccountMap.get(tempAccId).status__c = GS_GlobalVariables.ACCSTATUSPROSPECT;
							} else {
								newAccountMap.get(tempAccId).status__c = GS_GlobalVariables.ACCSTATUSFORMERCLIENT;
							}
						} else {
							newAccountMap.get(tempAccId).status__c = GS_GlobalVariables.ACCSTATUSCLIENT;
						}
                        if(accTypeSet.contains(newAccountMap.get(tempAccId).BDTypeName__c)) {
                            newAccountMap.get(tempAccId).Account_Type__c = newAccountMap.get(tempAccId).BDTypeName__c;
                            newAccountMap.get(tempAccId).Vertical__c = dependentMap.get(newAccountMap.get(tempAccId).BDTypeName__c);
                        }
					}
				}
			}
		}
	}
}