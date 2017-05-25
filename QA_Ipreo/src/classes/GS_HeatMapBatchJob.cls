global with sharing class GS_HeatMapBatchJob implements Database.Batchable<sObject> , Database.Stateful
{
    public string strAccountIds;
    public string strUserRoleIds;
    public string strHeatMapData; 
       
    global GS_HeatMapBatchJob(string accountIds, string userRoleIds)
    {
        strAccountIds = accountIds;
        strUserRoleIds = userRoleIds;
        strHeatMapData = '';
        //hmc = new GS_HeatMapController();
        //hmc.prepareHeatMapData(mapAccount);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        string taskInnerquery = '(select Id, Products__c, CreatedDate, OwnerId from Tasks where whatId__c in (\'001\',\'006\') and whoId__c = \'003\' and Owner.UserRoleId in '+strUserRoleIds +' and IsDeleted = false and CREATEDDATE = LAST_N_DAYS:730)';
        string eventInnerQuery = '(select Id, Products__c, CreatedDate, OwnerId from Events where whatId__c in (\'001\',\'006\') and whoId__c = \'003\' and Owner.UserRoleId in '+strUserRoleIds +' and IsDeleted = false and CREATEDDATE = LAST_N_DAYS:730)';
        string accountTeamInnerQuery = '(select Id, User.FirstName, User.LastName from AccountTeamMembers where IsDeleted = false)';
        string assetInnerQuery = '(SELECT Id,Status,Product2.Name FROM Assets where IsDeleted = false)';
        string workOrderInnerQuery = '(SELECT Id, Active__c, Product__r.Name FROM Work_Orders__r where IsDeleted = false)';
        
        string query = 'select Id, Name, Status__c,' + taskInnerquery + 
                                                  ','+ eventInnerQuery + 
                                                  ','+ accountTeamInnerQuery + 
                                                  ','+ assetInnerQuery +
                                                  ','+ workOrderInnerQuery +
                        ' from Account where Id in ' + strAccountIds +' ALL ROWS';
        
        system.debug('query in start method of batch--------->>>>>'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Sobject> scope) 
    {
        GS_HeatMapController hmc = new GS_HeatMapController(); 
        strHeatMapData += hmc.populateHeatMapData(scope);
        system.debug('strHeatMapData in EXEC ===='+strHeatMapData);
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        system.debug('strHeatMapData in FINISH ===='+strHeatMapData);
        GS_HeatMapController hmc = new GS_HeatMapController(); 
        hmc.createAttachment(strHeatMapData);  
    }
}