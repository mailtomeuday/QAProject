/**************************************************************************************************
 * Name           : GS_OppTeamMember
 * Object         : OpportunityTeamMember
 * Requirement    : RQ-265
 * Target         : Trigger to add Opportunity coverage members to automatically follow an Opportunity record. For users with Sales Profile, they should also be added to follow the Account record at that point.
 * Refer classes  : 
 * Author         : Terry Nong
 * Create Date    : 2015-11-23
 * Modify History :
 **************************************************************************************************/
trigger GS_OppTeamMember on OpportunityTeamMember (after insert, after update, before delete) {

    Set<Id> setTeamMemberID = new Set<Id>();
    Set<String> opptySet = new Set<String>();
    Map<String, String> mem_oppMap = new Map<String, String>();
    if((Trigger.isInsert || Trigger.isUpdate) && Follow_Rule_Setting__c.getall().get('OpportunityTeam').isOpen__c) {
        // System.debug(LoggingLevel.INFO, '*** Trigger.new: ' + Trigger.new);
        for(OpportunityTeamMember otm : Trigger.new) {
            setTeamMemberID.add(otm.UserId);
            opptySet.add(otm.OpportunityId);
            mem_oppMap.put(otm.Id, otm.OpportunityId);
        }
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name, Profile.Name FROM User WHERE Id IN : setTeamMemberId]);
        //build map for opportunity and account
        Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity>();
        Map<String, String> oppAccMap = new Map<String, String>();
        for(Opportunity o : [SELECT Id, AccountId, StageName FROM Opportunity WHERE Id IN : opptySet]) {
            opptyMap.put(o.Id, o);
            if(o.AccountId != null) oppAccMap.put(o.Id, o.AccountId);
        }
        //Find all subscription entity by opportunity ids and user ids
        Map<String, EntitySubscription> oppEntitySubscriptionMap = new Map<String, EntitySubscription>();
        for(EntitySubscription esb : [Select ParentId, SubscriberId 
                                        From EntitySubscription Where ParentId In: opptySet And SubscriberId In: setTeamMemberID limit 1000]) {
            oppEntitySubscriptionMap.put(esb.ParentId +'' + esb.SubscriberId, esb);
        }
        //Find all subscription entity by account ids and user ids
        Map<String, EntitySubscription> accEntitySubscriptionMap = new Map<String, EntitySubscription>();
        for(EntitySubscription esb : [Select ParentId, SubscriberId 
                                        From EntitySubscription Where ParentId In: oppAccMap.values() And SubscriberId In: setTeamMemberID limit 1000]) {
            accEntitySubscriptionMap.put(esb.ParentId +'' + esb.SubscriberId, esb);
        }
        List<EntitySubscription> entitySubscriptions = new List<EntitySubscription>();
        try {
            for(OpportunityTeamMember otm : Trigger.new) {
                // ConnectApi.ChatterUsers.follow(null, otm.UserId, otm.OpportunityId);
                if(opptyMap.get(mem_oppMap.get(otm.Id)).StageName == 'Closed Won Verified') continue;
                if(!oppEntitySubscriptionMap.containsKey(otm.OpportunityId + '' + otm.UserId)) {
                    EntitySubscription es = new EntitySubscription(ParentId = otm.OpportunityId, SubscriberId = otm.UserId);
                    entitySubscriptions.add(es);
                }
                if(userMap.get(otm.UserId).Profile.Name == 'Sales User') {
                    // ConnectApi.ChatterUsers.follow(null, otm.UserId, opptyMap.get(otm.OpportunityId).AccountId);
                    if(!accEntitySubscriptionMap.containsKey(oppAccMap.get(otm.OpportunityId) + '' + otm.UserId)) {
                        EntitySubscription es = new EntitySubscription(ParentId = oppAccMap.get(otm.OpportunityId), SubscriberId = otm.UserId);
                        entitySubscriptions.add(es);
                    }
                }
            }
            if(entitySubscriptions.size() > 0) insert entitySubscriptions;
        }catch(Exception e) {
            System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
        }
        
    }
    if(Trigger.isDelete && Follow_Rule_Setting__c.getall().get('OpportunityTeam').isOpen__c) {
        try {
            for(OpportunityTeamMember otm : Trigger.old) {
                setTeamMemberID.add(otm.UserId);
                opptySet.add(otm.OpportunityId);
            }
            Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name, Profile.Name FROM User WHERE Id IN : setTeamMemberId]);
            List<EntitySubscription> entitySubscriptions = new List<EntitySubscription>();
            for(EntitySubscription es : [Select ParentId, SubscriberId 
                                                From EntitySubscription 
                                                Where ParentId In: opptySet 
                                                And SubscriberId In: setTeamMemberID limit 1000]) {

                entitySubscriptions.add(es);
            }
            //check sales user
            setTeamMemberID = new Set<Id>();
            opptySet = new Set<String>();
            for(OpportunityTeamMember otm : Trigger.old) {
                if(userMap.get(otm.UserId).Profile.Name == 'Sales User') {
                    setTeamMemberID.add(otm.UserId);
                    opptySet.add(otm.OpportunityId);
                }
            }
            Set<String> accIdsSet = new Set<String>();
            for(Opportunity o : [SELECT Id, AccountId, StageName FROM Opportunity WHERE Id IN : opptySet]) {
                if(o.AccountId != null) accIdsSet.add(o.AccountId);
            }
            for(EntitySubscription es : [Select ParentId, SubscriberId 
                                                From EntitySubscription 
                                                Where ParentId In: accIdsSet 
                                                And SubscriberId In: setTeamMemberID limit 1000]) {
                entitySubscriptions.add(es);
            }
            if(entitySubscriptions.size() > 0) delete entitySubscriptions;

        }catch(Exception e) {
            System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
        }
    }
    
}