/**************************************************************************************************
 * Name           : GS_UnfollowAccountBatchJob
 * Object         : AccountTeamMember
 * Requirement    : RQ-265
 * Target         : Unfollow Account when a member was removed from account team, but not for users with a Sales Profile.
 * Refer classes  : 
 * Author         : Terry Nong
 * Create Date    : 2015-12-02
 * Modify History :
 **************************************************************************************************/
global class GS_UnfollowAccountBatchJob implements Database.Batchable<sObject> {

    public String query;
    
    global GS_UnfollowAccountBatchJob(String query) {
        this.query = query;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        try {
            Set<String> accIdSet = new Set<String>();
            Map<String, Map<String, AccountTeamMember>> accTeamMap = new Map<String, Map<String, AccountTeamMember>>();
            for(Account a : (List<Account>)scope) {
                accIdSet.add(a.Id);
                Map<String, AccountTeamMember> teamMap = new Map<String, AccountTeamMember>();
                for(AccountTeamMember atm : a.AccountTeamMembers) {
                    teamMap.put(atm.AccountId + '' + atm.UserId, atm);
                    accTeamMap.put(a.Id, teamMap);
                }
            }
            System.debug(LoggingLevel.INFO, '*** accTeamMap: ' + accTeamMap);
            Map<String, Map<String, EntitySubscription>> accEntityMap = new Map<String, Map<String, EntitySubscription>>();
            for(EntitySubscription e : [SELECT Id, 
                                                ParentId,
                                                SubscriberId 
                                                FROM EntitySubscription 
                                                Where ParentId IN: accIdSet limit 1000]) {
                if(accEntityMap.containsKey(e.ParentId)) {
                    accEntityMap.get(e.ParentId).put(e.ParentId + '' + e.SubscriberId, e);
                }else {
                    Map<String, EntitySubscription> entityMap = new Map<String, EntitySubscription>();
                    entityMap.put(e.ParentId + '' + e.SubscriberId, e);
                    accEntityMap.put(e.ParentId, entityMap);
                }
            }
            System.debug(LoggingLevel.INFO, '*** accEntityMap: ' + accEntityMap);
            //filter out EntitySubscription
            List<EntitySubscription> entities = new List<EntitySubscription>();
            for(Account a : (List<Account>)scope) {
                if(accTeamMap == null || !accTeamMap.containsKey(a.Id)) {
                    if(accEntityMap != null && accEntityMap.containsKey(a.Id)) {
                        entities.addAll(accEntityMap.get(a.Id).values());
                    }
                }else {
                    Map<String, AccountTeamMember> accountTeamMap = accTeamMap.get(a.Id);
                    if(accEntityMap == null || !accEntityMap.containsKey(a.Id)) continue; 
                    for(EntitySubscription e : accEntityMap.get(a.Id).values()) {
                        if(accountTeamMap != null && !accountTeamMap.containsKey(e.ParentId + '' + e.SubscriberId)) {
                            entities.add(e);
                        }
                    }
                } 
            }
            System.debug(LoggingLevel.INFO, '*** entities: ' + entities);
            if(entities.size() > 0) Database.delete(entities, false);
        }catch(Exception e) {
            System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug(LoggingLevel.INFO, '*** finish *** ');
    }
}