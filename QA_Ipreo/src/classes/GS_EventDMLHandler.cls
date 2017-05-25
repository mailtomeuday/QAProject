/**************************************************************************************************
 * Name           : GS_EventDMLHandler
 * Object         : Event
 * Requirement    : 
 * Target         : DML on Event
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-08-21
 * Modify History :
 **************************************************************************************************/
public class GS_EventDMLHandler {
    public static List<Event> getEventsByIds(List<Id> lstEventIds) {
    	return [SELECT Id
    				  ,Alert_Sent_Date__c
    				  ,Send_Alert__c
    			FROM Event
    			WHERE Id =: lstEventIds];
    }
}