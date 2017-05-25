/**************************************************************************************************
 * Name           : GS_CaseAutomateCloseMunisAndFITHandler
 * Object         : Case
 * Requirement    : 
 * Target         : If the account field is blank on case set account field to "Ipreo"
 * Refer classes  :
 * Author         : Ambadas Morkhandikar
 * Create Date    : 2016/12/27
 * Modify History : Added Null Check for Case Subject and Changed Subject String comparision to Ignore Case.
 **************************************************************************************************/
public class GS_CaseAutomateCloseMunisAndFITHandler implements GS_Triggers.Handler {
    public void handle() {
        if (Trigger.isInsert && Trigger.isBefore) {
            System.debug(LoggingLevel.INFO, '*** GS_CaseAutomateCloseMunisAndFITHandler is executed: ');
            updateRecordsWithNoAccount();
        }
    }   
    // If the account field is blank on case set account field to "Ipreo"
    private void updateRecordsWithNoAccount() {
        for (Case cs: (List<Case>)Trigger.new) {
            system.debug('This is the result before '+Trigger.new);
            if(cs.Subject != Null && cs.AccountID == Null && (cs.Origin == 'Email2Case (Equity)' || cs.Origin == 'Email2Case (iCompliance)')){
                if(cs.Status != 'Closed' || cs.Customer_Sent_Email_After_Case_Closed__c == 'Yes' ){
                    if(IsMatchingSubject(cs.Subject, 'Equals') || 
                    	IsMatchingSubject(cs.Subject, 'StartsWith') || 
                    		IsMatchingSubject(cs.Subject, 'Contains')){
            
                    		system.debug('This is the result before '+Trigger.new);
                    		System.debug('The value is: ' + cs.Account);
                        	if(cs.ContactID == Null){
                            	Account var = [SELECT Id,Name FROM Account where Name = 'Ipreo' limit 1];  
                            	cs.AccountID = var.Id;
                            	System.debug('The value is: ' + cs.Account);   
                        	}
                    }
                }       
            }     
        }   
    }   
    
    private boolean IsMatchingSubject(string subject, string operator)
    {
    	boolean matchFound = false;
    	 
    	list<string> equalsSubjectList = new List<String> 
    									 {
    									 	'Citi Entitlement Audit Report 6am', 
											'Citi Equity Compliance Report 3pm', 
											'Citi Equity Compliance Report 7pm',
											'Daily Testing Update Summary',
											'DEMO : DEUTSCHEBANK - Feed Started',
											'DEMO : Stifel.com - Feed Started',
											'DRSQL1DC3US01\\PD01 - PROD Alert: Orders with Compliance Restriction',
											'Order Exceptions: Structured Products Training Course Check',
											'Orion PROD Environment Daily unMappedInvestors Report',
											'Password Update Notification',
											'Production NJ2 MTE errors/warnings from proc_eqh_MonitorIssueNetWarnings.',
											'XML Deal Submission Notification - Failure',
											'XML Deal Submission Notification - Success'
										  };
    													  
    	list<string> startsWithSubjectList = new List<String> 
    										 {
    										 	'Automatic Reply',
												'Completed: Orion Outage in QA',
												'DEMO : DEUTSCHEBANK Feed',
												'DEMO : Stifel.com Feed',
												'Demo: Participants Upload Feed Run',
											 	'INSTSQL1NJ2US1\\PD01: Production NJ2 MTE API errors/warnings',
											 	'[MARKETING]',
											 	'Orion Production Outage Scheduled',
											 	'5131 Renewal Escalation -'   															
											  };
    														  
    	list<string> containsSubjectList = new List<String> 
									   	   {
									   	   		'Internet >> DEMO | Demo BAML Dealsync (webscript)'
										   };
    														
		if(operator.equalsIgnoreCase('Equals'))
		{
			for(string item : equalsSubjectList)
			{
				if(subject.equalsIgnoreCase(item)) {
					matchFound = true;
					break;
				}
			}
		}
		
		else if(operator.equalsIgnoreCase('startsWith'))
		{
			for(string item : startsWithSubjectList)
			{
				if(subject.startsWithIgnoreCase(item)) {
					matchFound = true;
					break;
				}
			}
		}
		
		else if(operator.equalsIgnoreCase('contains'))
		{
			for(string item : containsSubjectList)
			{
				if(subject.containsIgnoreCase(item)) {
					matchFound = true;
					break;
				}
			}
		}
		
		return matchFound;
    }
    
    
}