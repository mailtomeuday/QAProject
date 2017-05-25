/**************************************************************************************************
 Delete after data update job is completed in production
 **************************************************************************************************/
 
global class GS_UpdateContactActivityProductsBatch implements Database.Batchable<sObject>, Database.Stateful{
	
	string query;
	global String failureReasons = '';
    global integer totalCount = 0;
    global integer failedRecCount = 0;
    global integer successRecCount = 0;
    
	global GS_UpdateContactActivityProductsBatch(string strQuery){
		query = strQuery;
	}
	
    global Database.QueryLocator start(Database.BatchableContext bc){
    	return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
    	
    	
    	list<Product_Interest__c> ProdInterestList = GS_ActivityUtil.setProductInterest(scope);
    	
    	set<Product_Interest__c>  ProdInterestSet = new set<Product_Interest__c>();
    	
    	ProdInterestSet.addAll(ProdInterestList);
    	
    	ProdInterestList = new list<Product_Interest__c>();
    	
    	ProdInterestList.addAll(ProdInterestSet);
    	
		if(ProdInterestList != null && ProdInterestList.size() > 0){
			try{
				Database.UpsertResult[] arrResult = database.upsert(ProdInterestList, false);
    	
		    	for(integer i = 0; i < arrResult.size(); i++){
		            totalCount++;
		            If(!arrResult[i].isSuccess()){
		                failedRecCount ++;
		                string recordErrors = '';
		                for(Database.Error err: arrResult[i].getErrors()){
		                    recordErrors += err.getmessage()+';';
		                } 
		                failureReasons +=  '<tr> <td>'+ProdInterestList[i].Contact__c+'</td> <td>Failed</td> <td>Error:'+recordErrors+'</td> </tr>';    
		            }
		            else{
		                successRecCount ++;
		            }
		        }
			}	
			catch(Exception ex){
				throw ex;
			}
		}
    }
    
    global void finish(Database.BatchableContext BC) {
    	
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
	            string exlname = 'Activity Products Update Job Results.xls';
	            exlAttc.setFileName(exlname);
	            exlAttc.setBody(exlBlob);
	        }
	        
	        list<string> toAddresses = new list<string>();
			toAddresses.add('ambadas_morkhandikar@epam.com');
			//toAddresses.add('uday_bikkumalla@epam.com');
	        	   
	        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(toAddresses); 
            email.setSubject('Activity Products update batch job');
            string textBody = 'Activity Products update batch job has been completed successfully. Following is the summary of results: \n\n Total number of records: '+totalCount+'\n Number of records successful: '+successRecCount+ '\n Number of records failed: '+failedRecCount;
            if(failedRecCount > 0)
            {
            	textBody += '\n\n The attached file contains failure reason for the records that failed.';
            }
            textBody += '\n\n Note: Batch class used in the Job: "GS_UpdateContactActivityProductsBatch.cls"';
            
            email.setPlainTextBody(textBody);
            
            if(exlAttc != null)
            {
            	email.setFileAttachments(new Messaging.EmailFileAttachment[]{exlAttc});
            }
            

            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});

        }
    
    }
}