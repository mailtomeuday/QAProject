global with sharing class GS_UpdateYearDependentOppFieldsBatch implements Database.Batchable<Sobject>, Database.Stateful 
{
    String finalstr;
    global integer count = 0;
    global integer countf = 0;
    global integer counts = 0;
    
    public GS_UpdateYearDependentOppFieldsBatch()
    {
        finalstr = '';
    }
       
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        //query to get only the opportunity records which needs to reset "Is_Close_Date_In_Current_Year__c" Field
        return Database.getQueryLocator([SELECT ID, CloseDate, StageName, This_Year_ACV__c, Is_Close_Date_In_Current_Year__c FROM Opportunity Where (CloseDate = THIS_YEAR) or (CloseDate = LAST_YEAR)]);
    }

    global void execute(Database.BatchableContext bc, List<Opportunity> scope)
    {
        string msg;
        string msg1;
        for (Opportunity Opty : scope) 
        {            
            count++;
            //compare 'CloseDate.year' to 'today' if they are same then update 'Is_Close_Date_In_Current_Year__c' to 'Yes'
            // and set This_Year_ACV__c to 1 or 0
            if (Opty.CloseDate.year() == Date.Today().year()) {
                Opty.Is_Close_Date_In_Current_Year__c = 'Yes';
                system.debug('Opty.StageName:'+Opty.StageName);
                if(Opty.StageName.Equals('Closed Won Sales') || Opty.StageName.Equals('Closed Won Verified')){
                    Opty.This_Year_ACV__c = 1;
                }
                else{
                    Opty.This_Year_ACV__c = 0;
                }
            //compare 'CloseDate.year' to 'today' if they are not same then update 'Is_Close_Date_In_Current_Year__c' to 'No'        
            } else {
                Opty.Is_Close_Date_In_Current_Year__c = 'No'; 
                Opty.This_Year_ACV__c = 0;
            }
        }
        
        Database.saveresult[] arrResult = Database.Update(scope, false);
        
        for(integer i = 0; i < arrResult.size(); i++){
            msg = '';
            msg1 = '';
            If(!arrResult[i].isSuccess()){
                countf ++;
                string recordErrors = '';
                for(Database.Error err: arrResult[i].getErrors()){
                    recordErrors += err.getmessage()+';';
                } 
                msg +=  '<tr> <td>'+scope[i].Id+'</td> <td>Failed</td> <td>Error:'+recordErrors+'</td> </tr>';    
            }
            else{
                counts ++;
                msg1 +=  '<tr> <td>'+scope[i].Id+'</td> <td>Success</td> <td>Sucessfully updated</td> </tr>'; 
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
            string exlname = 'Opportunity records which needs to reset IsCloseDateInCurrentYear Field.xls';
            exlAttc.setFileName(exlname);
            exlAttc.setBody(exlBlob);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            User_List_Data_Update_Notifications__c notifSetting = GS_CustomSettingDMLHandler.getCustomSetting('UpdateYearDependentOppFieldsBatch');
            if(notifSetting != null && notifSetting.Email_Addresses__c != null){
                list<string> toAddresses = ((string)notifSetting.Email_Addresses__c).split(',');
                email.setToAddresses(toAddresses); 
                String subject = 'ResetIsClosedDateInCurrentYearBatch XLS';
                email.setSubject('Opportunities - Current Year Dependent Fields - Update Job - Results');
                email.setToAddresses( toAddresses );
                email.setPlainTextBody('The batch Job for updating the fields "Is Close Date In Current Year" & "This Year ACV "on Opportunities has been completed successfully. Following are the results for the same. \n\n Batch class used in the Job: "GS_UpdateYearDependentOppFieldsBatch" \n\n Total number of records:'+count+'\n Number of records successful:'+counts+ '\n Number of records failed:'+countf+'\n\n The attached file contains failure reason for the records that failed.');
                email.setFileAttachments(new Messaging.EmailFileAttachment[]{exlAttc});
                if(!test.isRunningTest()){
                    Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                }
            }
        }  
    }
}