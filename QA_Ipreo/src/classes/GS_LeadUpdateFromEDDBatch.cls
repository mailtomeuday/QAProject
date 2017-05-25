/**************************************************************************************************
 * Name           : GS_LeadUpdateFromEDDBatch
 * Object         : Lead
 * Requirement    : 
 * Target         : 
 * Refer classes  : Update Lead data from EDD 
 * Author         : Katherine Chen
 * Create Date    : 2016-04-11
 * Modify History :
 **************************************************************************************************/
global class GS_LeadUpdateFromEDDBatch implements Database.Batchable<Lead> , Database.AllowsCallouts, Database.Stateful
{
    public List<EDDEntity.errorMassage> errorList;
    
    global GS_LeadUpdateFromEDDBatch() 
    {
    	errorList = new List<EDDEntity.errorMassage>();
    }
    
    global Iterable<Lead> start(Database.BatchableContext bc) 
    {
    	GS_LeadsUpdateFromEDDHandler leadGet = new GS_LeadsUpdateFromEDDHandler();
    	return leadGet.getAllLeads();
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> scope) 
    {
    	System.debug('*** scope: ' + scope);
    	GS_LeadsUpdateFromEDDHandler batchHandler = new GS_LeadsUpdateFromEDDHandler();
		errorList.addAll(batchHandler.updateLeads(scope));
    }

    global void finish(Database.BatchableContext BC) 
    {
        String strTable = '<table style="  border: 1px solid #ccc; border-collapse: collapse;">';
        String strTH = '<tr> <th>Issue id</th> <th>Issuer Name</th> <th>Error Message</th> </tr>';
        String strBody = '';
        for ( EDDEntity.errorMassage er : errorList)
        {
            String wareid = er.warehouse_id == 0?'':String.valueOf(er.warehouse_id);
            strBody += '<tr> <td style=" border: 1px solid #ccc;">'+wareid +'</td> <td style=" border: 1px solid #ccc;">'+er.lastName+'</td> <td style=" border: 1px solid #ccc;">'+er.errorMass+'</td> </tr>';
        }
        String strfooter = '</table>';
        String mailBody = strTable + strTH + strBody + strfooter;
        if(errorList.size() == 0)
        {
            mailBody = 'Update Lead data from EDD successfully.';
        }
        System.debug('*** emailBody: ' + mailBody + '');
        Send(UserInfo.getUserId(), 'EDD to SFDC Update Lead Job Result', mailBody);
        System.debug('*** errorList: ' + errorList + '');
    }

    private static List<Messaging.SendEmailResult> Send(Id systemUserId, String subject, String plainTextBody) {
        System.debug(LoggingLevel.INFO, '*** systemUserId: ' + systemUserId);
        if (systemUserId != NULL) {
            List<Messaging.SingleEmailMessage> lstMsg = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            msg.setTargetObjectId(systemUserId);
            msg.setSubject(subject);
            msg.setHtmlBody(plainTextBody);
            msg.setSaveAsActivity(false);
            lstMsg.add(msg);
            List<Messaging.SendEmailResult> results =
                Messaging.sendEmail(lstMsg);
            System.debug(LoggingLevel.INFO, '*** results: ' + results);
            return results;
        } else {
            return new List<Messaging.SendEmailResult>();
        }
    }
}