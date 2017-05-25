global with sharing class GS_CampaignMemberReportBatch implements Database.Batchable<sObject>, Database.Stateful {
	String query;
	String createdRows;
	List<String> Status;
	
	global GS_CampaignMemberReportBatch(String query,String[] Status){
		this.query = query;
		createdRows = '';
		this.Status = status;
	}
	
	global Database.queryLocator start(Database.BatchableContext bc){
		System.debug(query);
		if (test.isRunningTest()){
			query += ' LIMIT 100';
		}
		//query += ' LIMIT 50000';
		return Database.getQueryLocator(query);			
	}
	
	global void execute(Database.BatchableContext bc, List<SObject> scope){
		List<CampaignMember> campaignMembers = (List<CampaignMember>)scope;
		createdRows += GS_CampaignMemberReportController.processBatch(campaignMembers); 
	}
	
	global void finish(Database.BatchableContext bc){
		GS_CampaignMemberReportController.createAndSendReport(createdRows);
		System.debug(createdRows);
	}
}