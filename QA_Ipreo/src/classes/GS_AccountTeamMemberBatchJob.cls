/**************************************************************************************************
 * Name           : GS_AccountTeamMemberBatchJob
 * Object         : AccountTeamMember
 * Requirement    : RQ-265
 * Target         : Trigger to add Account coverage members to automatically follow an Account record, but not for users with a Sales Profile.
 * Refer classes  : 
 * Author         : Terry Nong
 * Create Date    : 2015-11-23
 * Modify History :
 **************************************************************************************************/

global class GS_AccountTeamMemberBatchJob implements Database.Batchable<sObject> {

    public String query;
    
    global GS_AccountTeamMemberBatchJob(String query) {
        this.query = query;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
        //System.debug(LoggingLevel.INFO, '*** : ' + [Select UserId, OwnerId From UserAccountTeamMember Where OwnerId = '005m0000000vCuBAAU']);
        // EntitySubscription es = new EntitySubscription(ParentId='001m000000NaGfMAAV', SubscriberId = '005m0000001fTA2');
        // insert es;
        try {
            Set<String> accIdSet = new Set<String>();
            Set<String> userIdSet = new Set<String>();
            for(AccountTeamMember atm : (List<AccountTeamMember>)scope) {
                accIdSet.add(atm.AccountId);
                userIdSet.add(atm.UserId);
            }
            Map<String, EntitySubscription> entityMap = new Map<String, EntitySubscription>();
            for(EntitySubscription e : [SELECT Id, 
                                                ParentId,
                                                SubscriberId 
                                                FROM EntitySubscription 
                                                Where ParentId IN: accIdSet AND SubscriberId IN: userIdSet LIMIT 1000]) {

                entityMap.put(e.ParentId + '' + e.SubscriberId, e);
            }
            // https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_objects_entitysubscription.htm help to understand EntitySubscription limitation
            //Add EntitySubscription
            List<EntitySubscription> entities = new List<EntitySubscription>();
            for(AccountTeamMember atm : (List<AccountTeamMember>)scope) {
                String key = atm.AccountId + '' + atm.UserId;
                if(entityMap.containsKey(key)) continue;
                EntitySubscription es = new EntitySubscription(ParentId = atm.AccountId, SubscriberId = atm.UserId);
                entities.add(es);
            }
            Database.insert(entities, false);
        }catch(Exception e) {
            System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
        }
        
        
        /*try {
            Set<String> userIdSet = new Set<String>();
            for(AccountTeamMember atm : (List<AccountTeamMember>)scope) {
                userIdSet.add(atm.UserId);
            }
            Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name, Profile.Name FROM User WHERE Id IN : userIdSet AND Profile.Name != 'Sales User']);
            // System.debug(LoggingLevel.INFO, '*** userMap: ' + userMap);
            for(AccountTeamMember atm : (List<AccountTeamMember>)scope) {
                // System.debug(LoggingLevel.INFO, '*** UserId: ' + atm.UserId + '  AccountId ' + atm.AccountId);
                if(userMap.containsKey(atm.UserId)) {
                    ConnectApi.ChatterUsers.follow(null, atm.UserId, atm.AccountId);
                }
            }
        }catch(Exception e) {
            System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
        }*/
        
    }

    global void finish(Database.BatchableContext BC) {
        //TBD
    }
}