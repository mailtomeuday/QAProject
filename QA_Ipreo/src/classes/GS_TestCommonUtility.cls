/**************************************************************************************************
 * Name           : GS_TestCommonUtility
 * Object         : 
 * Requirement    : 
 * Target         : Test GS_CommonUtility 
 * Refer classes  : 
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-10-20
 * Modify History :
 **************************************************************************************************/

@isTest
private class GS_TestCommonUtility {
    static testMethod void commonUtility() {
    	User testUser = GS_TestDataCreator.createUser('Operations User', 'OperationsUser@test.com', 'APAC');
    	UserRole testUserRole = [select Id from UserRole where Name = 'Buyside Americas Sales Rep'];
    	testUser.UserRoleId = testUserRole.Id;
    	update testUser;

    	Map<Id,UserRole> roleRange = new Map<Id,UserRole>();
    	List<UserRole> allRole = new List<UserRole>();
    	allRole = [select Id,ParentRoleId,Name from UserRole];
    	for(UserRole tempRole : allRole){
    		roleRange.put(tempRole.Id, tempRole);
    	}

    	List<Id> recordId = new List<Id>();
    	recordId.add(testuser.Id);

        System.runAs(testUser){

	    	Follow_Rule_Setting__c testSetting1 = new Follow_Rule_Setting__c();
	    	Follow_Rule_Setting__c testSetting2 = new Follow_Rule_Setting__c();
	    	testSetting1.Name = 'Opportunity';
	    	testSetting2.Name = 'OpportunityTeam';
	    	testSetting1.isOpen__c = true;
	    	testSetting2.isOpen__c = true;
	    	insert testSetting1;	
	    	insert testSetting2;

	    	Account testAccount = GS_TestDataCreator.createAccount('TestAccount');
	    	Opportunity testOpp = GS_TestDataCreator.createOpportunity(testAccount, 'test opportunity', 'New_Business', 'Opportunity Identified', 'Subscription', '1 year', 'Tier 1');
	    	

	    	String objName = GS_CommonUtility.getObjectNameById(testAccount.Id);

	    	Schema.DescribeSObjectResult objResult1 = GS_CommonUtility.getDescribeSObjectResult('Account');
	    	Schema.DescribeSObjectResult objResult2 = GS_CommonUtility.getDescribeSObjectResult(null);

	    	Boolean isObjAndIdCorresponding1 = GS_CommonUtility.isObjectAndIdCorresponding('Account',testOpp.Id);
	    	Boolean isObjAndIdCorresponding2 = GS_CommonUtility.isObjectAndIdCorresponding('Account',testAccount.Id);
	    	Boolean isObjAndIdCorresponding3 = GS_CommonUtility.isObjectAndIdCorresponding('Account',null);
	    	Boolean isObjAndIdCorresponding4 = GS_CommonUtility.isObjectAndIdCorresponding('Account','00');
	    	Boolean isObjAndIdCorresponding5 = GS_CommonUtility.isObjectAndIdCorresponding(null,testAccount.Id);

	    	String getPrefixByObjName1 = GS_CommonUtility.getPrefixByObjectName('Account');
	    	String getPrefixByObjName2 = GS_CommonUtility.getPrefixByObjectName(null);

	    	Boolean isRelationMergeField1 = GS_CommonUtility.isRelationMergeField('Opportunity','Annual_Pass_Through__c');
	    	Boolean isRelationMergeField2 = GS_CommonUtility.isRelationMergeField('Opportunity',null);
	    	Boolean isRelationMergeField3 = GS_CommonUtility.isRelationMergeField('Opportunity','Id');

	    	String getNameFieldByRelationMergeField1 = GS_CommonUtility.getNameFieldByRelationMergeField('Opportunity','Annual_Pass_Through__c');
	    	String getNameFieldByRelationMergeField2 = GS_CommonUtility.getNameFieldByRelationMergeField('Opportunity',null);
	    	String getNameFieldByRelationMergeField3 = GS_CommonUtility.getNameFieldByRelationMergeField('Opportunity','AccountId');

	    	Boolean isRoleAndSubordinates1 = GS_CommonUtility.isRoleAndSubordinates(roleRange,'00E11000000ecmT',testUser.UserRoleId);
	    	Boolean isRoleAndSubordinates2 = GS_CommonUtility.isRoleAndSubordinates(roleRange,'00E11000000ecmT',null);
	    	Boolean isRoleAndSubordinates3 = GS_CommonUtility.isRoleAndSubordinates(roleRange,null,testUser.UserRoleId);

	    	List<UserRecordAccess> getRecordAccesses = GS_CommonUtility.getRecordAccesses(testUser.Id,recordId);

	    	//Boolean isRoleAndSubordinates = GS_CommonUtility.isRoleAndSubordinates();

	    	System.assertEquals('Account', objName);

	    	System.assertEquals(false, isObjAndIdCorresponding1);
	    	System.assertEquals(true, isObjAndIdCorresponding2);
	    	System.assertEquals('001', getPrefixByObjName1);
	    	System.assertEquals(false, isRelationMergeField1);
	    	System.assertEquals(true, isRelationMergeField2);
	    	
    	}
    }
    
    @isTest(SeeAllData=true)
    static void testGetAccountProductBundle() 
    {
    	list<Account> lstAcc = [select id from Account limit 10];
    	list<Id> idList = new list<Id>();
    	for(Account a : lstAcc)
    	{
    		idList.add(a.Id);
    	}
    	map<Id,string> testMap = GS_CommonUtility.GetAccountProductBundle(idList,lstAcc); 
    	
    	System.assertEquals(true, testMap.size() > 0);
    	
    	string prodBundle = testMap.get(lstAcc[0].Id);
    	   	
    	System.assertEquals(true, prodBundle != null);    	
    }
}