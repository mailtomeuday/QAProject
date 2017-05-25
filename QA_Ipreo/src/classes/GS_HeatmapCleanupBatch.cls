global with sharing class GS_HeatmapCleanupBatch implements Database.Batchable<sObject> , Database.Stateful
{
	global String failureReasons = '';
    global integer totalCount = 0;
    global integer failedRecCount = 0;
    global integer successRecCount = 0;
  
	global Database.QueryLocator start(Database.BatchableContext bc) 
    {
    	Integer numDays = 30;
    	Folder heatMapFolder = [select Id from Folder where Name = 'Heat Map Reports'];
    	Heat_Map_Cleanup_Duration_Criteria__c heatMapCleanupSetting = GS_CustomSettingDMLHandler.getHeatMapCustomSetting('DurationInDays');
    	
    	if(heatMapCleanupSetting != null && heatMapCleanupSetting.Number_Of_Days__c != null){
    		numDays = Integer.valueOf(heatMapCleanupSetting.Number_Of_Days__c);
    	}
		
		if(test.isRunningTest()){
			numDays = 0;
		}    	
    	string folderId = '\'' + heatMapFolder.Id + '\'';
    	string query = 'Select Id From Document where FolderId = ' + folderId + ' and CREATEDDATE < LAST_N_DAYS: ' + numDays; 
	 
	 	return Database.getQueryLocator(query);
    															    															 
    }
    
    global void execute(Database.BatchableContext BC, list<Sobject> scope) 
    {
    	Database.DeleteResult[] arrResult = Database.Delete(scope, false);
    	
    	for(integer i = 0; i < arrResult.size(); i++){
            totalCount++;
            If(!arrResult[i].isSuccess()){
                failedRecCount ++;
                string recordErrors = '';
                for(Database.Error err: arrResult[i].getErrors()){
                    recordErrors += err.getmessage()+';';
                } 
                failureReasons +=  '<tr> <td>'+scope[i].Id+'</td> <td>Failed</td> <td>Error:'+recordErrors+'</td> </tr>';    
            }
            else{
                successRecCount ++;
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) 
    {
		if(totalCount > 0)
    	{
	    	system.debug('In finish method:' +failureReasons);
	        Messaging.EmailFileAttachment exlAttc;
	        if(String.isNotEmpty(failureReasons))
	        {
	        	string header = '<table style="font-size:100%" border="2" cellpadding="5" border="2" cellspacing="0"><tr><td><b>Record Id</b></td> <td><b>Status</b></td> <td><b>Message</b></td></tr>';
	        	failureReasons = header + failureReasons+'</table>';
	            exlAttc = new Messaging.EmailFileAttachment();
	            blob exlBlob = Blob.valueOf(failureReasons);
	            string exlname = 'Heat Map Cleanup Job Results.xls';
	            exlAttc.setFileName(exlname);
	            exlAttc.setBody(exlBlob);
	        }
	        
	        list<string> toAddresses = new list<string>();

	        	User_List_Data_Update_Notifications__c notifSetting = GS_CustomSettingDMLHandler.getCustomSetting('HeatMapCleanUpJob');
	        	if(notifSetting != null && notifSetting.Email_Addresses__c != null ){
	            	toAddresses = ((string)notifSetting.Email_Addresses__c).split(',');
	        	}     
	        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(toAddresses); 
            email.setSubject('Heat Map Cleanup Job Results');
            string textBody = 'The batch Job for cleaning up Heat Map Reports has been completed successfully. Following is the summary of results: \n\n Total number of records: '+totalCount+'\n Number of records successful: '+successRecCount+ '\n Number of records failed: '+failedRecCount;
            if(failedRecCount > 0)
            {
            	textBody += '\n\n The attached file contains failure reason for the records that failed.';
            }
            textBody += '\n\n Note: Batch class used in the Job: "GS_HeatmapCleanupBatch.cls"';
            
            email.setPlainTextBody(textBody);
            
            if(exlAttc != null)
            {
            	email.setFileAttachments(new Messaging.EmailFileAttachment[]{exlAttc});
            }
            

            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});

        }
    }
}