@isTest(seeAllData=true)
public class GS_TestPermissionSetQueueController {
	public static testmethod void exportPermissionSetReport(){
		GS_PermissionSetQueueController controller = new GS_PermissionSetQueueController();
		controller.report='PermissionSet';				
		controller.exportToExcel();		
		System.assertNotEquals(0,controller.psa.size());
	}
	public static testmethod void exportQueueMembersReport(){
		GS_PermissionSetQueueController controller = new GS_PermissionSetQueueController();
		controller.setReport('QueueMember');
		System.assertEquals(controller.getReport(),'QueueMember');
		controller.getQueueMembers();
		GS_UserDMLHandler.getUsersByIds(controller.setUserIds);
		controller.exportToExcel();
		System.assertNotEquals(0,controller.queueMembers.size());
	}	

}