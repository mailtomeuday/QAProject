@isTest
private class GS_TestCaseAutomateCloseMunisAndFI {

      static testMethod void caseSubjectEquals() {
          Account testAccount = GS_TestDataCreator.createAccount('Ipreo');
          test.startTest();
          Case testCase = new Case();
          testCase.AccountId = Null;
          testCase.Status = 'New';
          testCase.Origin = 'Email2Case (Equity)';
          testCase.Customer_Sent_Email_After_Case_Closed__c = 'Yes';
          testCase.Subject = 'Citi Entitlement Audit Report 6am';
          insert testCase;
          test.stopTest();
  }

          static testMethod void caseSubjectStartsWith() {
          Account testAccount = GS_TestDataCreator.createAccount('Ipreo');
          test.startTest();
          Case testCase = new Case();
          testCase.AccountId = Null;
          testCase.Status = 'New';
          testCase.Origin = 'Email2Case (Equity)';
          testCase.Customer_Sent_Email_After_Case_Closed__c = 'Yes';
          testCase.Subject = 'Automatic Reply';
          insert testCase;
          test.stopTest();
  }

          static testMethod void caseSubjectContains() {
          Account testAccount = GS_TestDataCreator.createAccount('Ipreo');
          test.startTest();
          Case testCase = new Case();
          testCase.AccountId = Null;
          testCase.Status = 'New';
          testCase.Origin = 'Email2Case (Equity)';
          testCase.Customer_Sent_Email_After_Case_Closed__c = 'Yes';
          testCase.Subject = 'Internet >> DEMO | Demo BAML Dealsync (webscript)';
          insert testCase;
          test.stopTest();
  }
}