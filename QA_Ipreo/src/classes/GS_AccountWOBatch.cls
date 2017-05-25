global class GS_AccountWOBatch implements Database.Batchable<sObject>, Database.Stateful {
	String query;
	String createdRows;
	
	global GS_AccountWOBatch(){
		this.query = 'SELECT Id,Name, Status__c, No_of_Active_Sponsored_Assets__c,No_of_Active_Work_Orders__c,No_of_Active_Assets__c,No_of_Sponsored_Assets__c,No_of_All_Work_Orders__c,No_of_All_Assets__c, '; 
        //this.query += '(SELECT Id, Active__c,Product__r.Name,Product__r.ProductCode FROM Work_Orders__r where Product__r.Revenue_Type__c = \'PROJ\')';
        this.query += '(SELECT Id, Active__c,Product__r.Name,Product__r.ProductCode,Product__r.Revenue_Type__c FROM Work_Orders__r)'; 
        this.query += ' FROM Account';
		createdRows = '';
	}
	
	global Database.queryLocator start(Database.BatchableContext bc){
		return Database.getQueryLocator(query);		
	}
	
	global void execute(Database.BatchableContext bc, List<Account> scope){
		createdRows += processAccounts(scope);
	}
	
	global void finish(Database.BatchableContext bc){
		createAndSendReport(createdRows);
	}
	
	private String processAccounts(List<Account> accounts){
		String rowData = '';
		Integer activeWONumber = 0;
        for (Account tempAccount : accounts) {
        	String Status = '';
		    for(Work_Order__c tempWO : tempAccount.Work_Orders__r) {
		        if(tempWO.Active__c == true && tempWO.Product__r.Revenue_Type__c == 'PROJ') {
		            activeWONumber ++ ;
		        }
    	}
    	if (tempAccount.No_of_Active_Sponsored_Assets__c == 0
			&& activeWONumber == 0
			&& tempAccount.No_of_Active_Assets__c == 0) {
					if (tempAccount.No_of_Sponsored_Assets__c == 0
						&& tempAccount.Work_Orders__r.size() == 0
						&& tempAccount.No_of_All_Assets__c == 0) {
						Status = GS_GlobalVariables.ACCSTATUSPROSPECT;
					}
					else
					{
						Status = GS_GlobalVariables.ACCSTATUSFORMERCLIENT;
					}
					
			}
			else {
					Status = GS_GlobalVariables.ACCSTATUSCLIENT;
				}
    	rowData += '<tr>';
    	rowData += '<td>'+tempAccount.Id +'</td>';
        rowData += '<td>'+tempAccount.Name +'</td>';
        rowData += '<td>'+activeWONumber +'</td>';
        rowData += '<td>'+tempAccount.Work_Orders__r.size() +'</td>';
        rowData += '<td>'+tempAccount.Status__c +'</td>';
        rowData += '<td>'+Status +'</td>';
        rowData += '</tr>';
		    activeWONumber = 0;
		}
		return rowData;
	}
	
	private String createTable(String createdRows)
	{
        string s = '<html> <head> <style> table { font-family: arial, sans-serif; border-collapse: collapse; width: 100%; }td, th { border: 1px solid #dddddd; text-align: left;padding: 8px; } </style> </head> <body><table>';
        s += createHeader();
        s += createdRows;
        s += '</table></body> </html>';
        return s;
    }
    
    private String createHeader(){
        string headerString = '';       
        headerString += '<tr><th>ID</th><th>Account Name</th><th># Active Proj Work Orders</th><th># All Work Orders</th><th>Status</th><th>New Status</th></tr>';      
        return headerString;
    }
    
    private void createAndSendReport(String rows)
    {
        string finalFileName = 'Account Report '+Datetime.now().format('dd-MMM-yy hh:mm:ss a')+'.xls';
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        Blob test = Blob.valueOf(createTable(rows));
        blob csvBlob = test;
        csvAttc.setFileName(finalFileName);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> {'uday_bikkumalla@epam.com'};
        String subject ='Account Report_'+ Datetime.now().format();
        email.setSubject(subject);
        email.setTargetObjectID(UserInfo.getUserID());
        email.saveAsActivity = false;
        email.setToAddresses(toAddresses);
        email.setPlainTextBody(subject);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }     

}