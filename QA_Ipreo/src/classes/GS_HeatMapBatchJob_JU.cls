global class GS_HeatMapBatchJob_JU implements Database.Batchable<sObject> , Database.Stateful
{
    map<Id, Account> mapAccount;
    GS_HeatMapController_JU hmc;
    set<Id> setOfUserRoleID;
    
    global GS_HeatMapBatchJob_JU(map<Id, Account> mapOfIdToAccount, list<AccountTeamMember> lstAccTeamMember, set<Id> userRoleIdSet, list<string> lstProductNames, boolean isCorp)
    {
        //mapAccount = new Map<Id, Account>([select Id, Name, Status__c from Account where Vertical__c != 'Corporate' limit 500]);
        mapAccount = mapOfIdToAccount;
        setOfUserRoleID = userRoleIdSet;
        hmc = new GS_HeatMapController_JU();
        hmc.lstProducts = lstProductNames;
        hmc.isCorporateHM = isCorp;
        hmc.prepareHeatMapData(mapAccount, lstAccTeamMember);
    }
        
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        system.debug('mapAccount========='+mapAccount);
        string strAccountIds = GS_HeatMapController_JU.getInClauseFromSet(mapAccount.keyset());
        string strUserRoleIds = GS_HeatMapController_JU.getInClauseFromSet(setOfUserRoleID);
        string query = 'select id,AccountId,Products__c,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,LastModifiedBy.FirstName,LastModifiedBy.LastName,OwnerId from Task where whatId__c in (\'001\',\'006\') and whoId__c = \'003\' and AccountId in '+strAccountIds+' and Owner.UserRoleId in '+strUserRoleIds +' and CREATEDDATE = LAST_N_DAYS:730 ALL ROWS';
        if(Test.isRunningTest())
        {
        	query = 'select id,AccountId,Products__c,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,LastModifiedBy.FirstName,LastModifiedBy.LastName,OwnerId from Task where whatId__c in (\'001\',\'006\') and whoId__c = \'003\' and AccountId in '+strAccountIds+' and Owner.UserRoleId in '+strUserRoleIds +' and CREATEDDATE = LAST_N_DAYS:730 Limit 1500';
        }
        system.debug('query========='+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Sobject> scope) 
    {
        list<sObject> lstActivities = new list<sObject>();
        lstActivities.addAll(scope);
        list<sobject> lstEvent = [select id,AccountId,Products__c,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,LastModifiedBy.FirstName,LastModifiedBy.LastName,OwnerId from Event where whatId__c in ('001','006') and whoId__c = '003' and AccountId in: mapAccount.keyset() and Owner.UserRoleId in: setOfUserRoleID and CREATEDDATE = LAST_N_DAYS:730 ALL ROWS];
        lstActivities.addAll(lstEvent);
        
        hmc.populateHeatMapData(lstActivities, mapAccount);
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        hmc.createAttachment();  
    }
}