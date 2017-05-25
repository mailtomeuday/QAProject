/**************************************************************************************************
 * Name           : GS_CaseDealMileStoneTHandler
 * Object         : Case
 * Requirement    : STY-00240
 * Target         : Update case mile stone to track case sla status
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-08-24
 * Modify History :
 **************************************************************************************************/
public class GS_CaseDealMileStoneTHandler implements GS_Triggers.Handler {

    public void handle() {
        checkFirstResponseProvided();
        checkCaseOwner();
        updateCaseForMilestone();
    }

    // when the case is responded or sent email, set both the Case First Response Required and Case First Response Completed satisfied.
    private void checkFirstResponseProvided() {
        if (Trigger.isUpdate && Trigger.isBefore) {

            Set<Id> stSatisfiedCaseId = new Set<Id>();
            Map<Id, Case> mapOldCase = (Map<Id, Case>)Trigger.oldMap;
            Map<Id, Case> mapNewCase = (Map<Id, Case>)Trigger.newMap;

            // get case id which are created by manually.
            for(Id tempCaseId : mapNewCase.keySet()) {
                if (    ((  mapNewCase.get(tempCaseId).First_Response_Provided__c != mapOldCase.get(tempCaseId).First_Response_Provided__c
                        || mapNewCase.get(tempCaseId).Inserted__c != mapOldCase.get(tempCaseId).Inserted__c
                        )
                     && mapNewCase.get(tempCaseId).First_Response_Provided__c)
                    ||
                        (mapNewCase.get(tempCaseId).Sent_Email_Message__c != mapOldCase.get(tempCaseId).Sent_Email_Message__c
                     && mapNewCase.get(tempCaseId).Sent_Email_Message__c) ) {
                    stSatisfiedCaseId.add(tempCaseId);
                }
            }

            // Get case milestones for the manually created case. And satisfy the ownership case milestone
            if (stSatisfiedCaseId.size() > 0) {

                List<Database.SaveResult> results;
                List<String> lstMilestoneNames = new List<String>();

                lstMilestoneNames.add(GS_GlobalVariables.MSCASEFIRSTREQUIRED);
                lstMilestoneNames.add(GS_GlobalVariables.MSCASEFIRSTCOMPLETED);

                List<CaseMileStone> lstMSTarget = GS_MileStoneDMLHandler.getCaseMileStoneByNameAndCaseId(stSatisfiedCaseId, lstMilestoneNames);
                System.debug(LoggingLevel.INFO, '*** lstMSTarget: ' + lstMSTarget);
                results = GS_MileStoneDMLHandler.satisfyMilestone(lstMSTarget);
                System.debug(LoggingLevel.INFO, '*** results: ' + results);
            }
        }
    }

    // Check case owner for cases from email-to-case
    // In this function, also reset the start data time for the first response completed milestone
    private void checkCaseOwner(){
        if (Trigger.isUpdate && Trigger.isBefore) {

            Set<Id> stSatisfiedCaseId = new Set<Id>();
            Map<Id, Case> mapOldCase = (Map<Id, Case>)Trigger.oldMap;
            Map<Id, Case> mapNewCase = (Map<Id, Case>)Trigger.newMap;

            // get case id which are created by manually.
            for(Id tempCaseId : mapNewCase.keySet()) {
                if(mapNewCase.get(tempCaseId).OwnerId != NULL){
                    if (    String.valueOf(mapNewCase.get(tempCaseId).OwnerId).startsWith('005')
                         && String.valueOf(mapOldCase.get(tempCaseId).OwnerId).startsWith('00G')) {
                        stSatisfiedCaseId.add(tempCaseId);
                    }
                }
            }

            // Get case milestones for the manually created case. And satisfy the ownership case milestone
            if (stSatisfiedCaseId.size() > 0) {

                List<CaseMileStone> lstMSChangerOwner = GS_MileStoneDMLHandler.getCaseMileStoneByNameAndCaseId(stSatisfiedCaseId, new List<String>{GS_GlobalVariables.MSCASEOWNERSHIP});
                
                // When the owner has been assigned from queue to user, update the first response complete milestone start date
                List<CaseMileStone> lstMSFRComplete = GS_MileStoneDMLHandler.getCaseMileStoneByNameAndCaseId(stSatisfiedCaseId, new List<String>{GS_GlobalVariables.MSCASEFIRSTCOMPLETED});
                System.debug(LoggingLevel.INFO, '*** lstMSFRComplete: ' + lstMSFRComplete);
                GS_MileStoneDMLHandler.satisfyMilestone(lstMSChangerOwner);
                // When the owner has been assigned from queue to user, update the first response complete milestone start date
                GS_MileStoneDMLHandler.setStartDate(lstMSFRComplete);
            }
        }
    }

    //Get the case milestone when inserting the case.
    //We are going to update the case again to get the case milestone when we are doing the creating
    //Invoked by updateCaseForMilestoneForTrigger()
    @future
    private static void updateCaseForMilestone(List<Id> lstNewCaseId) {
        System.debug(LoggingLevel.INFO, '*** lstNewCaseId: ' + lstNewCaseId);
        List<Case> lstTargetCase = new List<Case>();
        for(Case tempCase : [SELECT Id, Inserted__c from Case WHERE Id =: lstNewCaseId AND IsCLosed = FALSE]) {
            tempCase.Inserted__c = TRUE;
            lstTargetCase.add(tempCase);
        }
        System.debug(LoggingLevel.INFO, '*** lstTargetCase: ' + lstTargetCase);
        update lstTargetCase;

    }

    // We are going to update the case again to get the case milestone when we are doing the creating
    // Invoke future function updateCaseForMilestone()
    private void updateCaseForMilestone(){
        if (Trigger.isInsert && Trigger.isAfter) {

            List<Id> lstCaseIds = new List<Id>();
            for(Case cs : (List<Case>)Trigger.new) {
                if(cs.First_Response_Provided__c){
                    lstCaseIds.add(cs.Id);
                }
            }

            if(!lstCaseIds.isEmpty()){
                updateCaseForMilestone(lstCaseIds);
            }
        }
    }
}