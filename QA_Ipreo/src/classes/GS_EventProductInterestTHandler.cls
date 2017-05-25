/**************************************************************************************************
 * Name           : GS_EventProductInterestTHandler
 * Object         : Event
 * Requirement    : 
 * Target         : Create Product Interest records
 * Refer classes  : 
 * Author         : Joshi (ambadas_morkhandikar@epam.com)
 * Create Date    : 2017-04-25
 * Modify History :
 **************************************************************************************************/

public with sharing class GS_EventProductInterestTHandler implements GS_Triggers.Handler {
	public Map<Id, Event> mapNewEvent = new Map<Id, Event>();
	
	public void handle() {
		if(Trigger.isInsert || Trigger.isUpdate){
			mapNewEvent = (Map<Id, Event>)Trigger.newMap;
		}
		GS_ActivityUtil.setProductInterest(mapNewEvent.keyset(), 'Event');
	}
    
}