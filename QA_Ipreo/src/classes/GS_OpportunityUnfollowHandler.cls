/**************************************************************************************************
 * Name           : GS_OpportunityUnfollowHandler
 * Object         : Opportunity
 * Requirement    : STY-415
 * Target         : remove all followers when an opportunity is closed won verified
 * Refer classes  :
 * Author         : Terry
 * Create Date    : 2015-12-03
 * Modify History :
 **************************************************************************************************/
public class GS_OpportunityUnfollowHandler implements GS_Triggers.Handler {

    public void handle() {

        if(!Follow_Rule_Setting__c.getall().get('Opportunity').isOpen__c) return;

        Set<String> idsSet = new Set<String>();
        for(Opportunity o : (List<Opportunity>)Trigger.new) {
            if(o.StageName == 'Closed Won Verified') {
                idsSet.add(o.Id);
            }
        }
        if(idsSet.size() < 1) return;
        try {
            List<EntitySubscription> entitySubscriptions = new List<EntitySubscription>();

            for(EntitySubscription es : [Select Id From EntitySubscription Where ParentId In: idsSet limit 1000]) {
                entitySubscriptions.add(es);
            }
            //unfollow account while sales user
            Set<String> accIdsSet = new Set<String>();
            Set<String> userIdsSet = new Set<String>();
            for(Opportunity o : [Select Id, AccountId, (Select UserId, User.Profile.Name From OpportunityTeamMembers) 
                                            From Opportunity Where Id In: idsSet]) {
                for(OpportunityTeamMember otm : o.OpportunityTeamMembers) {
                    if(otm.User.Profile.Name == 'Sales User') {
                        userIdsSet.add(otm.UserId);
                        accIdsSet.add(o.AccountId);
                    }
                }
            }
            for(EntitySubscription es : [Select Id From EntitySubscription Where ParentId In: accIdsSet And SubscriberId In: userIdsSet limit 1000]) {
                entitySubscriptions.add(es);
            }
            if(entitySubscriptions.size() > 0) delete entitySubscriptions;
        }catch(Exception e) {
            System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
        }
    }
}