/**************************************************************************************************
 * Name           : GS_AtRiskStatusUpdateAccountTHandler
 * Object         : At-Risk Status/ Account
 * Requirement    : SPS-1827
 * Target         : Update Current At-Risk Status and Current At-Risk Reason on Account record with the  
 					latest values in At-Risk Status related list, each time At-Risk Status is added, changed, deleted.
 * Refer classes  :
 * Author         : Joshi (ambadas_morkhandikar@epam.com)
 * Create Date    : 2017-03-23
 * Modify History :
 **************************************************************************************************/
public with sharing class GS_AtRiskStatusUpdateAccountTHandler implements GS_Triggers.Handler  {
    public void handle() {
    	map<Id,Desktop_Status__c> currentRecordsMap;
		Set<Id> accountIdSet = new Set<Id>();
		
		if(trigger.newMap != null){
			currentRecordsMap = (map<Id,Desktop_Status__c>)trigger.newMap;
		}
		else if(trigger.oldMap != null){
			currentRecordsMap = (map<Id,Desktop_Status__c>)trigger.oldMap;
		}
		
		if(currentRecordsMap != null){
			system.debug('currentRecordsMap======'+currentRecordsMap);
			for(Id currRecId : currentRecordsMap.keyset()){
				Desktop_Status__c objAtRiskStatus = currentRecordsMap.get(currRecId);
				if(objAtRiskStatus != null){
					system.debug('objAtRiskStatus.Account__r======'+objAtRiskStatus.Account__r);
					accountIdSet.add(objAtRiskStatus.Account__c);
				}
			}
			
			list<Account> lstAccountsToUpdate = new list<Account>();
			map<Id, list<Desktop_Status__c>> mapOfAccountDesktopStatusList =  new map<Id, list<Desktop_Status__c>>();	
			
			system.debug('accountIdSet======'+accountIdSet);
			
			list<Desktop_Status__c> lstAllDesktopStatus = [select Id, Account__c, Desktop_Status__c, At_Risk_Reason__c 
																from Desktop_Status__c where Account__c in:accountIdSet 
																	order by CreatedDate Desc];
			
			if(lstAllDesktopStatus != null && lstAllDesktopStatus.size() > 0){
				for(Desktop_Status__c objDesktopStatus : lstAllDesktopStatus){
					list<Desktop_Status__c> lstTempDesktopStatus;
					
					if(mapOfAccountDesktopStatusList.containsKey(objDesktopStatus.Account__c)){
						lstTempDesktopStatus = mapOfAccountDesktopStatusList.get(objDesktopStatus.Account__c);
					}
					else{
						lstTempDesktopStatus = new list<Desktop_Status__c>();
					}
					
					lstTempDesktopStatus.add(objDesktopStatus);
					mapOfAccountDesktopStatusList.put(objDesktopStatus.Account__c, lstTempDesktopStatus);
				}
				
				for(Id accountId : mapOfAccountDesktopStatusList.keyset()){
					
					if(mapOfAccountDesktopStatusList.get(accountId) != null && 
						mapOfAccountDesktopStatusList.get(accountId).size() > 0){
							Desktop_Status__c objDesktop = mapOfAccountDesktopStatusList.get(accountId)[0];
							Account acc = new Account();
							acc.Id = accountId;
							acc.Churn__c = objDesktop.Desktop_Status__c;
							acc.Churn_Reason__c = objDesktop.At_Risk_Reason__c;
							lstAccountsToUpdate.add(acc); 
					}
				}
			}
			system.debug('lstAccountsToUpdate======'+lstAccountsToUpdate);
			if(lstAccountsToUpdate.size() > 0){
				try{
					update lstAccountsToUpdate;
				}
				catch(Exception ex){
					throw ex;
				}
			}														
		}
    }
}