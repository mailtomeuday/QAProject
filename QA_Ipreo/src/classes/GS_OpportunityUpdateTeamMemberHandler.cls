/**************************************************************************************************
 * Name           : GS_OpportunityUpdateTeamMemberHandler
 * Object         : OpportunityTeamMember
 * Requirement    : RQ-265
 * Target         : Update team member after insert to trigger team member follow record.
 * Refer classes  : 
 * Author         : Terry Nong
 * Create Date    : 2015-12-04
 * Modify History :
 **************************************************************************************************/
public class GS_OpportunityUpdateTeamMemberHandler implements GS_Triggers.Handler {

    public void handle() {

        if(!Follow_Rule_Setting__c.getall().get('Opportunity').isOpen__c) return;

        System.debug(LoggingLevel.INFO, '*** -------------------->>>>>>>>>>>: ');
        // System.debug(LoggingLevel.INFO, '*** : ' + [Select OpportunityId From OpportunityTeamMember Where OpportunityId In: Trigger.newMap.keySet()]);
        Set<String> oppIds = new Set<String>();
        for(Opportunity o : (List<Opportunity>)Trigger.new) {
            if(o.StageName != 'Closed Won Verified') {
                oppIds.add(o.Id);
            }
        }
        List<OpportunityTeamMember> members =  [Select OpportunityId From OpportunityTeamMember Where OpportunityId In: oppIds];
        if(members != null && members.size() > 0) update members;
    }
}