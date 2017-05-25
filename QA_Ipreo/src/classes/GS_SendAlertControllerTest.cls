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
private class GS_SendAlertControllerTest {

    static testMethod void sendEmailToPrimaryRepTest() {
        // TO DO: implement unit test
		/* Creation of account and contacts */
    	Account testAccount = GS_TestDataCreator.createAccount('TestAccount_Report',false);
		User user = [select id from User where Profile.Name = 'Sales User' limit 1];
    	testAccount.Primary_Sales_Rep__c = user.id;
    	insert testAccount;     	
    	List<Contact> contacts = new List<Contact>();
    	for(integer i=0; i<1; i++)
    	{
    		contacts.add(GS_TestDataCreator.createContact(('Last Name_' + i), testAccount, false));	
    	}
    	Database.insert(contacts);
    	
    	/* Creation of campaign and campaign members */
    	Campaign campaign = GS_TestDataCreator.createCampaign('Test Campaign', 'Planned', true, 'Email', true);
    	List<CampaignMember> campaignMembers = new List<CampaignMember>();

    	for(Contact contact : contacts)
    	{
    		campaignMembers.add(GS_TestDataCreator.createCampaignMember(campaign, contact, 'Clicked', false));
    	}
    	Database.insert(campaignMembers);	
    	List<Id> campaignMemberids = new List<Id>();
    	for(CampaignMember campaignMember : campaignMembers)
    	{
    		campaignMemberids.add(campaignMember.id);
    	}
    	GS_SendAlertController.sendEmail(campaignMemberids);
    }

    static testMethod void sendEmailToSecondaryRepTest() {
        // TO DO: implement unit test
		/* Creation of account and contacts */
    	Account testAccount = GS_TestDataCreator.createAccount('TestAccount_Report',false);
		User user = [select id from User where Profile.Name = 'Sales User' limit 1];
    	testAccount.Secondary_Sales_Rep__c = user.id;
    	insert testAccount;     	
    	List<Contact> contacts = new List<Contact>();
    	for(integer i=0; i<1; i++)
    	{
    		contacts.add(GS_TestDataCreator.createContact(('Last Name_' + i), testAccount, false));	
    	}
    	Database.insert(contacts);
    	
    	/* Creation of campaign and campaign members */
    	Campaign campaign = GS_TestDataCreator.createCampaign('Test Campaign', 'Planned', true, 'Email', true);
    	List<CampaignMember> campaignMembers = new List<CampaignMember>();

    	for(Contact contact : contacts)
    	{
    		campaignMembers.add(GS_TestDataCreator.createCampaignMember(campaign, contact, 'Clicked', false));
    	}
    	Database.insert(campaignMembers);	
    	List<Id> campaignMemberids = new List<Id>();
    	for(CampaignMember campaignMember : campaignMembers)
    	{
    		campaignMemberids.add(campaignMember.id);
    	}
    	GS_SendAlertController.sendEmail(campaignMemberids);
    }    
}