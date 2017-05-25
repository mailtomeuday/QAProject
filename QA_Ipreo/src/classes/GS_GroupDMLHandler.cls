/**************************************************************************************************
 * Name           : GS_GroupDMLHandler
 * Object         : Group
 * Requirement    : 
 * Target         : DML on Group
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-08-25
 * Modify History :
 **************************************************************************************************/
public class GS_GroupDMLHandler {

    // Get list of queues by queue name. Queue is a kind of group
    public static List<QueueSobject> getQueuesByObjNameAndQueueName(Set<String> queueNames, String objectName) {
    	
    	return [SELECT Id
    				  ,QueueId
    				  ,Queue.Name
    				  ,SobjectType
    			FROM QueueSobject
    			WHERE Queue.Name in: queueNames
    			AND SobjectType =: objectName];
    }
}