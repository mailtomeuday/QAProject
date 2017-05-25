global with sharing class GS_HeatMapBatchJob_UB implements Database.Batchable<sObject> , Database.Stateful
{
   // global string strHeatMapData;
    map<Id, Account> mapAccount;
    GS_HeatMapController_UB hmc;
        global GS_HeatMapBatchJob_UB(){
            mapAccount = new Map<Id, Account>([select Id, Name, Status__c from Account where Vertical__c != 'Corporate']);
            hmc = new GS_HeatMapController_UB();
            hmc.prepareHeatMapData(mapAccount);
        }
        
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        system.debug('mapAccount========='+mapAccount);
        string strAccountIds = '(';
        for(string key : mapAccount.keyset())
        {
            strAccountIds += '\''+key+'\',';
        }
        strAccountIds = strAccountIds.substring(0, strAccountIds.length() - 1);
        strAccountIds += ')';
         
        string query = 'select id,AccountId,Products__c,LastModifiedDate from Task where whatId__c in (\'001\',\'006\') and whoId__c = \'003\' and AccountId in '+strAccountIds;
        system.debug('query========='+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        list<sObject> lstActivities = new list<sObject>();
        lstActivities.addAll(scope);
        list<sobject> lstEvent = [select id,AccountId,Products__c,LastModifiedDate from Event where whatId__c in ('001','006') and whoId__c = '003' and AccountId in: mapAccount.keyset()];
        lstActivities.addAll(lstEvent);
        
        hmc.populateHeatMapData(lstActivities, mapAccount);
        //System.debug('Inside excute---'+strHeatMapData );
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        //System.debug('From Finish'+strHeatMapData);
        hmc.createAttachment('');  
    }
}