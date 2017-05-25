/**************************************************************************************************
 * Name           : GS_CaseAssignValueTHandler
 * Object         : Case
 * Requirement    :
 * Target         : assign value
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2016-12-4
 * Modify History :
 **************************************************************************************************/
public class GS_CaseAssignValueTHandler implements GS_Triggers.Handler {
	public void handle() {

		if (Trigger.isInsert && Trigger.isBefore) {
			System.debug(LoggingLevel.INFO, '*** GS_CaseAssignValueTHandler is executed: ');
			assginTypeAndSubType();
		}

		if (Trigger.isUpdate && Trigger.isBefore) {
			System.debug(LoggingLevel.INFO, '*** GS_CaseAssignValueTHandler is executed: ');
			checkIfCaseRespondedWithoutAssignToUser();
		}
	}

	// If email subject contains "Ipreo Identity Verification"
	// then default the Case Type to "Access Management" and the Sub Type to "Machine Registration".
	private void assginTypeAndSubType() {

		// Check the subject from emailmessage
		for (Case cs : (List<Case>)Trigger.new) {
			if (cs.Origin != NULL && cs.Subject != NULL) {
				String strSubject = cs.Subject.toLowerCase();
				if (		cs.Origin.contains('Email2Case')
				            &&	strSubject.contains('ipreo identity verification')) {
					cs.Type = 'Access Management';
					cs.Sub_Type__c = 'Machine Registration';
				}
			}

		}

	}

	// Check on Responded_by_Email_But_Not_Taken_Owner__c when the case is first responded manually withou
	// assign to some one from a queue.
	private void checkIfCaseRespondedWithoutAssignToUser() {
		for (Case cs : (List<Case>)Trigger.new) {
			System.debug(LoggingLevel.INFO, '*** cs.OwnerId: ' + cs.OwnerId);
			System.debug(LoggingLevel.INFO, '*** cs.Responded_by_Email_But_Not_Taken_Owner__c: ' + cs.Responded_by_Email_But_Not_Taken_Owner__c);
			System.debug(LoggingLevel.INFO, '*** cs.First_Response_Provided__c: ' + cs.First_Response_Provided__c);
			if (((Case)Trigger.oldMap.get(cs.Id)).First_Response_Provided__c != cs.First_Response_Provided__c && 
				cs.OwnerId != NULL && String.valueOf(cs.OwnerId).startsWith('00G') &&
				cs.Responded_by_Email_But_Not_Taken_Owner__c == FALSE &&
				cs.First_Response_Provided__c == TRUE) {
				cs.Responded_by_Email_But_Not_Taken_Owner__c = TRUE;
			}
		}
	}
}