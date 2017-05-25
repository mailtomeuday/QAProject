/**************************************************************************************************
 * Name           : GS_EmailMessageUpdateSLATHandler
 * Object         : EmailMessage
 * Requirement    : 
 * Target         : 1. There two fields on Case, Sent_Email_Message__c,First_Response_Provided__c
 *                  When an email is sent out from the case, these two fields will be checked on.
 *                  2. Check on Responded_by_Email_But_Not_Taken_Owner__c when the case is reponded by
 *                  Email message but not assigned to some owner from a queue.
 * Refer classes  : 
 * Author         : 
 * Create Date    : 
 * Modify History :
 **************************************************************************************************/
public class GS_EmailMessageUpdateSLATHandler implements GS_Triggers.Handler {

    public void handle() {
        Set<Id> caseId = new Set<Id>();

        for (EmailMessage em : (List<EmailMessage>)Trigger.New) {
            if (em.Incoming == FALSE ) {
                caseId.add(em.parentId);
            }
        }

        List<Case> caseList = new List<Case>();

        for (Case c : [SELECT OwnerId, Responded_by_Email_But_Not_Taken_Owner__c, Sent_Email_Message__c, First_Response_Provided__c FROM Case WHERE ID IN :caseId]) {
            if (c.Sent_Email_Message__c == FALSE || c.First_Response_Provided__c == FALSE) {
                c.Sent_Email_Message__c = true;
                c.First_Response_Provided__c = true;
                if(c.OwnerId != NULL && String.valueOf(c.OwnerId).startsWith('00G') && c.Responded_by_Email_But_Not_Taken_Owner__c == FALSE){
                    c.Responded_by_Email_But_Not_Taken_Owner__c = TRUE;
                }
                caseList.add(c);
            }
        }

        try {
            update caseList;
        } catch (DmlException ex) {

            for (Integer i = 0; i < ex.getNumDml(); i++) {
                for (EmailMessage em : (List<EmailMessage>)Trigger.New) {
                    if (em.ParentId == ex.getDmlId(i)) {
                        em.addError(ex.getDmlMessage(i));
                    }
                }
            }

        }
    }
}