/**************************************************************************************************
 * Name           : GS_LeadInsertFromEDDBatch
 * Object         : Lead
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Katherine Chen
 * Create Date    : 2016-04-05
 * Modify History :
 **************************************************************************************************/
global class GS_LeadInsertFromEDDBatch implements Database.Batchable<EDDEntity.EDDLead> , Database.AllowsCallouts, Database.Stateful
{
    public EDDEntity.EDDEntityStruct EDDEntityobj;
    public List<EDDEntity.errorMassage> errorList;
    
    global GS_LeadInsertFromEDDBatch() 
    {
    	errorList = new List<EDDEntity.errorMassage>();
    }
    
    global Iterable<EDDEntity.EDDLead> start(Database.BatchableContext bc) 
    {
    	GS_LeadGetDataFromEDD ldFEDD = new GS_LeadGetDataFromEDD();
		EDDEntityobj = ldFEDD.getCreateLeadsData();
    	return EDDEntityobj.Leads;
    }
    
    global void execute(Database.BatchableContext BC, list<EDDEntity.EDDLead> scope) 
    {
    	System.debug('*** scope: ' + scope);
    	GS_LeadInsertFromEDDHandler batchHandler = new GS_LeadInsertFromEDDHandler();
		errorList.addAll(batchHandler.insertLeadsData(scope));
    }

    global void finish(Database.BatchableContext BC) 
    {
    	String strTable = '<table style="  border: 1px solid #ccc; border-collapse: collapse;">';
    	String strTH = '<tr> <th>Warehouse id</th> <th>Issuer Name</th> <th>Error Message</th> </tr>';
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
            mailBody = 'Created Lead data from EDD successfully.';
        }
		System.debug('*** emailBody: ' + mailBody);
    	Send(UserInfo.getUserId(), 'EDD to SFDC Current Lead Job Result', mailBody);
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