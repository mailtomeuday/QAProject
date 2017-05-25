/**************************************************************************************************
 * Name           : GS_TestEmailMessageUpdateSLATHandler
 * Object         :
 * Requirement    :
 * Target         : Test handlers on Email Massage Trigger
 * Refer classes  :
 * Author         : Katherine Chen
 * Create Date    : 2016-04-13
 * Modify History :
 **************************************************************************************************/
@isTest
private class GS_TestEmailMessageUpdateSLATHandler {
    static testMethod void testEmailMessage() {
        User thisUsr = [Select id from User where Id = :UserInfo.getUserId()];
        System.runAs(thisUsr) {
            Test.startTest();
            createCaseTeamRole();
            Test.stopTest();
        }

        CaseTeamRole testCaseTeamRole = [SELECT Id from CaseTeamRole Where Name = 'TestCaseRole' limit 1];


        Account testAccount = GS_TestDataCreator.createAccount('TestAccount');
        Case testCase = GS_TestDataCreator.createcase(testAccount.Id, 'New', '2 - Medium', 'Internal', 'Service Request', 'Training Request', 'Test Case 1', 'Test Case 1 Description', UserInfo.getUserId());
        CaseTeamMember testTeamMember = GS_TestDataCreator.createCaseTeamMember(testCase.Id, testCaseTeamRole.Id ,UserInfo.getUserId());

        EmailMessage testEmail = new EmailMessage();
        testEmail.ParentId = testCase.Id;
        testEmail.FromAddress = 'test.email@test.com';
        testEmail.Subject = 'Test Email Message';
        insert testEmail;

        EmailMessage emResult = [select ParentId, FromAddress, Id, Subject from EmailMessage where Subject = 'Test Email Message' limit 1];
        System.assertEquals(testCase.Id, emResult.ParentId);
        System.assertEquals('test.email@test.com', emResult.FromAddress);
    }

    @future
    private static void createCaseTeamRole() {
        GS_TestDataCreator.createCaseTeamRole('TestCaseRole');
    }
}