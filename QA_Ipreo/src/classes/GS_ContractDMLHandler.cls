/**************************************************************************************************
 * Name           : GS_ContractDMLHandler
 * Object         : Contract__c
 * Requirement    : 
 * Target         : DML on Contract__c
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-10-07
 * Modify History :
 **************************************************************************************************/
public class GS_ContractDMLHandler {
    
    // Get Contracts
    public static List<Contract__c> getContractsWithAttsByIds (Set<Id> contractIds) {
    	return [SELECT Id
    				  ,(SELECT Id
    				  	FROM Attachments)
    			FROM Contract__c
    			WHERE Id in: contractIds];
    }
}