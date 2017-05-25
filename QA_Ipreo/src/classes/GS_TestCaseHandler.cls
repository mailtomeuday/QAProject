/**************************************************************************************************
 * Name           : GS_TestCaseTrigger
 * Object         : 
 * Requirement    : 
 * Target         : Test handlers on Case Trigger
 * Refer classes  : 
 * Author         : Katherine Chen
 * Create Date    : 2016-04-13
 * Modify History :
 **************************************************************************************************/
@isTest
private class GS_TestCaseHandler 
{
    static testMethod void testCaseCreateOrUpdate() 
    {
        Group testGroup = new Group(Name='Test Group', Type='Queue');
        insert testGroup;

        User thisUsr = [Select id from User where Id = :UserInfo.getUserId()];
        System.runAs(thisUsr) {
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }

        Account testAccount = GS_TestDataCreator.createAccount('TestAccount');
        Case testCase1 = GS_TestDataCreator.createcase(testAccount.Id,'New','2 - Medium','Internal','Service Request','Training Request','Test Case 1','Test Case 1 Description',UserInfo.getUserId());
        Case testCase2 = GS_TestDataCreator.createcase(testAccount.Id,'New','2 - Medium','Email2Case','Service Request','Training Request','Test Case 2 - Ipreo Identity Verification','Test Case 2 Description',testGroup.Id);
        Case testCase3 = GS_TestDataCreator.createcase(testAccount.Id,'New','2 - Medium','Internal','Access Management','Trial Access Request','Test Case 3','Test Case 3 Description',UserInfo.getUserId());

        List<Case> lstCaseResult = [select Description, Id  from Case where Subject = 'Test Case 1']; 
        List<Case> lstUpdateCase = new List<Case>();
        if(lstCaseResult.size() >0)
        {
            lstCaseResult[0].Description = 'Test Case 1 Description Updated';
            lstUpdateCase.add(lstCaseResult[0]);
        }   

        List<Case> lstCaseResult1 = [select Description, Id, OwnerId,First_Response_Provided__c  from Case where Subject = 'Test Case 2 - Ipreo Identity Verification']; 
        if(lstCaseResult1.size() >0)
        {
            lstCaseResult1[0].OwnerId = UserInfo.getUserId();
            lstCaseResult1[0].First_Response_Provided__c = true;
            lstUpdateCase.add(lstCaseResult1[0]);
        }  

        update lstUpdateCase;

        List<Case> lstCaseResult2 = [select Description, Id  from Case where Subject = 'Test Case 1']; 
        if(lstCaseResult2.size() >0)
        {
            System.assertEquals('Test Case 1 Description Updated', lstCaseResult2[0].Description);
        }   
    }
 
}