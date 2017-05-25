/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class GS_CampaignMemberReportControllerTest {

    static testMethod void doSearchTest() {

		/* Creation of account and contacts */
    	Account testAccount = GS_TestDataCreator.createAccount('TestAccount_Report');
    	List<Contact> contacts = new List<Contact>();
    	for(integer i=0; i<50; i++)
    	{
    		contacts.add(GS_TestDataCreator.createContact(('Last Name_' + i), testAccount, false));	
    	}
    	Database.insert(contacts);
    	
    	/* Creation of campaign and campaign members */
    	Campaign campaign = GS_TestDataCreator.createCampaign('Test Campaign', 'Planned', true, 'Email', true);
    	List<CampaignMember> campaignMembers = new List<CampaignMember>();
    	List<Task> taskList = new List<Task>();
    	User user = [select id from User where Profile.Name = 'Sales User' limit 1];
    	for(Contact contact : contacts)
    	{
    		campaignMembers.add(GS_TestDataCreator.createCampaignMember(campaign, contact, 'Sent', false));
    		taskList.add(GS_TestDataCreator.createTask(user ,contact, false));
    	}
    	Database.insert(campaignMembers);   	
    	Database.insert(taskList);
    	GS_CampaignMemberReportController controller = new GS_CampaignMemberReportController();
    	
    	controller.getAccountFilterOptions();
    	controller.getStatusOptions();
    	controller.AbortOperation();
    	controller.resetFilters();
    	
    	/* To Search with Specific Campaign */
    	controller.accountFilter = '3';
    	controller.doSearch();
    	
    	controller.campWrapper.Campaign__c = campaign.id;
    	controller.doSearch();
    	
    	/* Search with All Campaigns */
		controller.accountFilter = '1';
    	controller.doSearch();
		controller.navigateToBack();
		
		/* Search with All Active Campaigns */
		controller.accountFilter = '1';
    	controller.doSearch();
    	
		/* Add Tasks to Campaigns */
    	taskList = new List<Task>();
    	for(Contact contact : contacts)
    	{
    		taskList.add(GS_TestDataCreator.createTask(user ,contact, false));
    	}
    	
    	Database.insert(taskList);
    	
    	/* Search with Status 'Clicked' */
    	controller.Status = new List<String>{'Clicked'};
    	controller.accountFilter = '1';
    	controller.doSearch();
    	
    }
}