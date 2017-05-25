global class GS_UpdateOppFields implements Database.Stateful,Database.Batchable<sObject>{
	String finalstr;
    global integer count = 0;
    global integer countf = 0;
    global integer counts = 0;

    global GS_UpdateOppFields()
    {
        finalstr = '';
    }
    
	global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select id,StageName from Opportunity where StageName in (\'Closed Cancelled Verified\', \'Closed Won Verified\')';
        if(Test.isRunningTest())
        {
        	query = query + ' Limit 200';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
    	string msg;
    	Set<ID> oppIds = new Set<ID>();
    	for(Opportunity opp: scope)
    	{
    		oppIds.add(opp.id);
    	}
    	Map<ID,Opportunity> mapTargetOpp = new Map<ID,Opportunity>(GS_OpportunityDMLHandler.getOpportunitiesWithLineItemsById(oppIds));
    	List<Opportunity> lstOppsToUpdate = new List<Opportunity>();
    	for(ID oppId : mapTargetOpp.keySet())
    	{
    		count++;
    		Opportunity tempOpp = mapTargetOpp.get(oppId);
    		if(tempOpp.StageName == GS_GlobalVariables.OPPCLOSEDCANCELLEDVERIFIED)
    		{   
            	tempOpp.Cancel_Reason__c = GS_CommonUtility.getCancelReasonforOpp(tempOpp);
            	lstOppsToUpdate.add(tempOpp); 
            	continue;
            }
            if(tempOpp.StageName == GS_GlobalVariables.OPPCLOSEDWONVERIFIED)
            {   
            	tempOpp.Estimated_Completion_Date__c = GS_CommonUtility.getEstCompletionDate(tempOpp);
            	lstOppsToUpdate.add(tempOpp);
            	continue;  
            }  
    		
    	}
    	
    	Database.saveresult[] arrResult = Database.Update(lstOppsToUpdate, false);
        
        for(integer i = 0; i < arrResult.size(); i++){
            msg = '';
            If(!arrResult[i].isSuccess()){
                countf ++;
                string recordErrors = '';
                for(Database.Error err: arrResult[i].getErrors()){
                    recordErrors += err.getmessage()+';';
                } 
                msg +=  '<tr> <td>'+lstOppsToUpdate[i].Id+'</td> <td>Failed</td> <td>Error:'+recordErrors+'</td> </tr>';    
            }
            else{
                counts ++;
            }

            finalstr = finalstr + msg;
        }
    	
    	
    }
    
    global void finish(Database.BatchableContext bc){
    
    if(finalstr != '')
    {
        
        string header = '<table style="font-size:100%" border="2" cellpadding="5" border="2" cellspacing="0"><tr><td><b>Record Id</b></td> <td><b>Status</b></td> <td><b>Message</b></td></tr>';
        finalstr = header + finalstr+'</table>';
        Messaging.EmailFileAttachment exlAttc = new Messaging.EmailFileAttachment();
        blob exlBlob = Blob.valueOf(finalstr);
        string exlname = 'Opportunity Records_UpdateFailed.xls';
        exlAttc.setFileName(exlname);
        exlAttc.setBody(exlBlob);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        User_List_Data_Update_Notifications__c notifSetting = GS_CustomSettingDMLHandler.getCustomSetting('UpdateYearDependentOppFieldsBatch');
        if(notifSetting != null && notifSetting.Email_Addresses__c != null){
            list<string> toAddresses = ((string)notifSetting.Email_Addresses__c).split(',');
            email.setToAddresses(toAddresses); 
            email.setSubject('Opportunities - Update Fields Job - Results');
            email.setToAddresses( toAddresses );
            email.setPlainTextBody('The batch Job for updating the fields "Cancel Reason" & "Est. Completion Date"on Opportunities has been completed successfully. Following are the results for the same. \n\n Batch class used in the Job: "GS_UpdateOppFields" \n\n Total number of records:'+count+'\n Number of records successful:'+counts+ '\n Number of records failed:'+countf+'\n\n The attached file contains failure reason for the records that failed.');
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{exlAttc});
            if(!test.isRunningTest()){
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }
        }
    }
}

}