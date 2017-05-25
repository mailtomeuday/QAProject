/**************************************************************************************************
 * Name           : GS_CaseGetEntitlementTHandler
 * Object         : Account
 * Requirement    : STY-00115
 * Target         : Assign Entitlement to Case
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-07-23
 * Modify History :
 **************************************************************************************************/
public class GS_CaseGetEntitlementTHandler implements GS_Triggers.Handler {
    public void handle() {

        Set<Id> accIds = new Set<Id>();
        Map<Id, Account> mapAccount = new Map<Id, Account>();

        System.debug(LoggingLevel.INFO, '*** Trigger.new: ' + Trigger.new);

        // Get account ids that cases are related to
        for (Case tempCase : (List<Case>)Trigger.new) {
            if (!accIds.contains(tempCase.AccountId)) {
                accIds.add(tempcase.AccountId);
            }
        }

        // Get account list with only one entitlement on the account
        System.debug(LoggingLevel.INFO, '*** accIds: ' + accIds);
        mapAccount = new Map<Id, Account>(GS_AccountDMLHandler.getAccountWithEntitlement(accIds));
        System.debug(LoggingLevel.INFO, '*** mapAccount: ' + mapAccount);

        // loop the inserted cases and assign entitlement to the case
        for (Case tempCase : (List<Case>)Trigger.new) {
            if (mapAccount.get(tempCase.AccountId) != NULL) {

                if (!mapAccount.get(tempCase.AccountId).Entitlements.isEmpty() && !isExcludedFromSLA(tempCase)) {
                    if (Trigger.isInsert) {
                        tempCase.EntitlementId = mapAccount.get(tempCase.AccountId).Entitlements[0].Id;
                    } else if (Trigger.isUpdate) {
                        if (((Case)Trigger.newMap.get(tempCase.Id)).AccountId != ((Case)Trigger.oldMap.get(tempCase.Id)).AccountId) {
                            tempCase.EntitlementId = mapAccount.get(tempCase.AccountId).Entitlements[0].Id;
                        } else if (((Case)Trigger.oldMap.get(tempCase.Id)).Sub_Type__c == GS_GlobalVariables.CASESUBTYPETRIALACCESSREQUEST) {
                            tempCase.EntitlementId = mapAccount.get(tempCase.AccountId).Entitlements[0].Id;
                        }
                    }
                } else if (isExcludedFromSLA(tempCase) && Trigger.isUpdate) {
                    tempCase.EntitlementId = NULL;
                    tempCase.SlaStartDate = NULL;
                }
            }
        }
    }

    // Exclude the trial users by case type or case orign.
    private Boolean isExcludedFromSLA(Case c) {

        // Exclude the case whose Case Origin is Internal.
        String stExcludeInternal = 'Internal';

        if ( c.Sub_Type__c == GS_GlobalVariables.CASESUBTYPETRIALACCESSREQUEST
                ||
                (c.Origin != NULL &&
                 (c.Origin == GS_GlobalVariables.CASEORIGINSALESREQUESTSIR
                  ||  c.Origin == GS_GlobalVariables.CASEORIGINTRIALUSERSGMG
                  ||  c.Origin.contains(stExcludeInternal)))) {
            return TRUE;
        }

        return FALSE;
    }
}