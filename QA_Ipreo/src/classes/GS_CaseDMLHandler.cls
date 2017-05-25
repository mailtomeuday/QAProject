/**************************************************************************************************
 * Name           : GS_CaseDMLHandler
 * Object         : Case
 * Requirement    : 
 * Target         : DML on Case
 * Refer classes  :
 * Author         : Uday Bikkumalla (uday_bikkumalla@epam.com)
 * Create Date    : 2017-03-28
 * Modify History :
 **************************************************************************************************/
public class GS_CaseDMLHandler {
	
	/*
	Method Name		: 	getCasesByIds
	Return Type		: 	List<Case>
	Parameters		:	@Param1[Set<Id>, caseids]
	*/
	public static List<Case> getCasesByIds(Set<ID> caseIds)
	{
		if(caseIds == null || caseIds.size() == 0)
		{
        	return new List<Case>();
        }
        return [SELECT Id
        				,subject
        				,Product__c
       			FROM Case
                WHERE Id in: caseIds];
        			   
        			   
	}

}