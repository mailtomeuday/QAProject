/**************************************************************************************************
 * Name           : GS_TaskProductInterestTHandler
 * Object         : Task
 * Requirement    : 
 * Target         : Create Product Interest records
 * Refer classes  : 
 * Author         : Joshi (ambadas_morkhandikar@epam.com)
 * Create Date    : 2017-04-25
 * Modify History :
 **************************************************************************************************/
public with sharing class GS_TaskProductInterestTHandler implements GS_Triggers.Handler {
	public Map<Id, Task> mapNewTask = new Map<Id, Task>();
	
	public void handle() {
		if(Trigger.isInsert || Trigger.isUpdate){
			mapNewTask = (Map<Id, Task>)Trigger.newMap;
		}
		//GS_ActivityUtil.setProductInterest(mapNewTask.keyset(), 'Task');
	}
    
}