global class GS_OpportunityPipelineHistoryBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
	global list<String> toAddresses = new list<String>{'salesforce_notifications@ipreo.com'};
	global integer totalCount = 0;
    global integer failedCount = 0;
    global integer successCount = 0;
    global string failedMessages = '';
	
	global Database.QueryLocator start(Database.BatchableContext bc) {
        string query = 'SELECT AccountId, Account.Name, ACV__c, CloseDate, Estimated_Annual_Transaction_Fees__c, Net_New_Business__c, Id, CurrencyIsoCode, Name, ' +
        					  'OwnerId, Owner.Name, Annual_Pass_Through__c, Prior_Year_ACV__c, Prior_Year_Pass_Through__c, RecordType.Name, StageName, Amount, Vertical__c, ' +
        					  'No_of_GMG_Opportunity_Products__c ' +
					   'FROM Opportunity WHERE isClosed = false';
					   
		if (test.isRunningTest())
			query += ' LIMIT 100';
		
		return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
		System.debug(scope.size());
		
		List<Opportunity_Pipeline_History__c> ophs = new List<Opportunity_Pipeline_History__c>();
		
		for (Opportunity opp : (List<Opportunity>)scope) {
			Opportunity_Pipeline_History__c oph = new Opportunity_Pipeline_History__c();
			
			oph.Account__c = opp.AccountId;
			oph.Account_Name__c = opp.Account.Name;
			oph.ACV__c = opp.ACV__c;
			oph.Close_Date__c = opp.CloseDate;
			oph.Estimated_Annual_Transaction_Fees__c = opp.Estimated_Annual_Transaction_Fees__c;
			oph.Net_New_Business__c = opp.Net_New_Business__c;
			oph.Opportunity__c = opp.Id;
			oph.CurrencyIsoCode = opp.CurrencyIsoCode;
			oph.Opportunity_Currency__c = opp.CurrencyIsoCode;
			oph.Opportunity_Name__c = opp.Name;
			oph.Opportunity_Owner__c = opp.Owner.Name;
			oph.Pass_Through__c = opp.Annual_Pass_Through__c;
			oph.Prior_Year_ACV__c = opp.Prior_Year_ACV__c;
			oph.Prior_Year_Pass_Through__c = opp.Prior_Year_Pass_Through__c;
			oph.Record_Type__c = opp.RecordType.Name;
			oph.Stage__c = opp.StageName;
			oph.TCV__c = opp.Amount;
			oph.Opportunity_Pipeline_History_Unique_Key__c = opp.Id + '_' + System.today().format();
			
			if (opp.No_of_GMG_Opportunity_Products__c > 0)
				oph.Vertical__c = 'GMG';
			else
				oph.Vertical__c = 'Corporate';
			
			ophs.add(oph);
		}
		
		System.debug(ophs.size());
		totalCount += ophs.size();
		
		if (ophs.size() > 0) {
			try {
				upsert ophs Opportunity_Pipeline_History__c.Field.Opportunity_Pipeline_History_Unique_Key__c;
				successCount += ophs.size();
			}
			catch (Exception e) {
				failedCount += ophs.size();
				failedMessages += e.getMessage();
			}
		}
    }

    global void finish(Database.BatchableContext BC) {
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    	
    	email.setToAddresses(toAddresses); 
		email.setSubject('Weekly Opportunity Pipeline History Batch Job Completed');
		string textBody = 'The weekly batch job to capture Opportunity pipeline history has completed. Below is a summary of the results:' +
							'\n\nTotal number of records: ' + totalCount + '\nSuccess: ' + successCount + '\nFailed: '+ failedCount;
        if(failedMessages != '') {
        	textBody += '\n\nError Messages:\n' + failedMessages;
        }
            
        textBody += '\n\nBatch class used in the job: "GS_OpportunityPipelineHistoryBatch"';
            
        email.setPlainTextBody(textBody);
            
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});		
    }
    
	global void execute(SchedulableContext SC) {
		GS_OpportunityPipelineHistoryBatch batchJob = new GS_OpportunityPipelineHistoryBatch();
		Database.executeBatch(batchJob, 200);
	}
}