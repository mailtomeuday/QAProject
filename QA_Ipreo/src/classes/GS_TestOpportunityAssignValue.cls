/**************************************************************************************************
 * Name           : GS_TestOpportunityAssignValue
 * Object         : Opportunity
 * Requirement    : STY-00011, STY-00007
 * Target         : Test GS_OpportunityAssignValueTHandler
 * Refer classes  : 
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-07-06
 * Modify History :
 **************************************************************************************************/
@isTest
private class GS_TestOpportunityAssignValue {
	/***********************************************************************************************************************************
	 *Requirement :STY-00011
	 *Details     :Opportunity:IF record created, THEN IF Vertical == null, THEN Vertical = Account.Vertical
     *             Note:Do not modify on edit or if Vertical ≠ null.
     *Requirement :STY-00007
     *Details     :Opportunity:IF record created, THEN IF NYSE Program Tier == null, THEN NYSE Program Tier = Account.NYSE Program Tier
	 *             Note:Do not modify on edit or if NYSE Program Tier ≠ null.
	 ***********************************************************************************************************************************/
	static testMethod void assignValue() {

    	Follow_Rule_Setting__c testSetting1 = new Follow_Rule_Setting__c();
    	Follow_Rule_Setting__c testSetting2 = new Follow_Rule_Setting__c();
    	testSetting1.Name = 'Opportunity';
    	testSetting2.Name = 'OpportunityTeam';
    	testSetting1.isOpen__c = true;
    	testSetting2.isOpen__c = true;
    	insert testSetting1;	
    	insert testSetting2;
		
		Account testAccount1 = GS_TestDataCreator.createAccount('TestAccount','Buyside','Tier 1');
		Account testAccount2 = GS_TestDataCreator.createAccount('TestAccount','Buyside','Tier A');

		Opportunity testOpp1 = GS_TestDataCreator.createOpportunity(testAccount1, 'test opportunity', 'New_Business', 'Opportunity Identified', 'Subscription', '1 year', null , null);
		Opportunity testOpp2 = GS_TestDataCreator.createOpportunity(testAccount2, 'test opportunity', 'New_Business', 'Opportunity Identified', 'Subscription', '1 year', null , null);

		Opportunity oppResult1 = [select Id, Vertical__c,NYSE_Program_Tier__c from Opportunity where Id =: testOpp1.Id limit 1];
		System.assertEquals(testAccount1.Vertical__c, oppResult1.Vertical__c);
		System.assertEquals(testAccount1.NYSE_Program_Tier__c, oppResult1.NYSE_Program_Tier__c);
		
		Opportunity oppResult2 = [select Id, Vertical__c,NYSE_Program_Tier__c from Opportunity where Id =: testOpp2.Id limit 1];
		System.assertEquals(testAccount2.Vertical__c, oppResult2.Vertical__c);
		System.assertEquals(testAccount2.NYSE_Program_Tier__c, oppResult2.NYSE_Program_Tier__c);
	}
}