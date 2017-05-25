/**************************************************************************************************
 * Name           : GS_TestEmailAlertOnEvent
 * Object         : 
 * Requirement    : 
 * Target         : Test Event Trigger for email alert 
 * Refer classes  : 
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-10-15
 * Modify History :
 **************************************************************************************************/
@isTest
private class GS_TestEmailAlertOnEvent {

    static testMethod void eventEmailAlert() {

        User testUser1 = GS_TestDataCreator.createUser('Operations User', 'Tom.123@test.com', 'APAC');
        User testUser2 = GS_TestDataCreator.createUser('Operations User', 'Jerry.123@test.com', 'APAC');

        AccountTeamMember accTeamMember1 = new AccountTeamMember();
        AccountTeamMember accTeamMember2 = new AccountTeamMember();
        Alert_Groups__c testAlertGroup = new Alert_Groups__c();

        List <AccountTeamMember> lstAccTeamMember = new List<AccountTeamMember>();

        System.runAs(testUser1)
        {
            Account testAccount = GS_TestDataCreator.createAccount('TestAccount');
            Contact testContact = GS_TestDataCreator.createContact('testA', testAccount);
			
			Follow_Rule_Setting__c testSetting1 = GS_TestDataCreator.createFollowRuleSetting('Opportunity',true);
			Follow_Rule_Setting__c testSetting2 = GS_TestDataCreator.createFollowRuleSetting('OpportunityTeam',true);
			
			Opportunity testOpp1 = GS_TestDataCreator.createOpportunity(testAccount, 'test opportunity', 'Renewal', 'Opportunity Identified', 'Subscription', '1 year', 'Tier 1');
			
            testAlertGroup.Name = 'CorpIR-TEST';
            testAlertGroup.Group_Name__c = 'CorpIR-GMI';
            testAlertGroup.Group_Email__c = 'alert.group@test.com';
            insert testAlertGroup;

            accTeamMember1.UserId = testUser1.Id;
            accTeamMember1.AccountId = testAccount.Id;

            accTeamMember2.UserId = testuser2.Id;
            accTeamMember2.AccountId = testAccount.Id;

            lstAccTeamMember.add(accTeamMember1);
            lstAccTeamMember.add(accTeamMember2);

            insert lstAccTeamMember;

            Event testEvent1 = GS_TestDataCreator.createEvent(testUser1,100,Date.valueOf('2015-10-19'),testContact);
            Event testEvent2 = GS_TestDataCreator.createEvent(testUser1,200,Date.valueOf('2015-10-19'),testContact);
            Event testEvent3 = GS_TestDataCreator.createEvent(testUser1,300,Date.valueOf('2015-10-19'),testContact);
            Event testEvent4 = GS_TestDataCreator.createEvent(testUser1,400,Date.valueOf('2015-10-19'),testContact);			
			
            
            testEvent1.Send_Alert__c = 'Yes';
            testEvent1.whatid = testOpp1.id;
            testEvent1.Type = 'Meeting (Client Visit)';
            testEvent1.Alert_Coverage_Groups__c = testAlertGroup.Group_Name__c;
            update testEvent1;

            testEvent3.Send_Alert__c = 'Yes';
            update testEvent3;

            testEvent4.Type = 'Meeting (Client Visit)';
            testEvent4.Send_Alert__c = 'Yes';
            testEvent4.whatid = testOpp1.id;
            update testEvent4;

            List<Event> lstEventResult = [select Id, Send_Alert__c, Alert_Sent_Date__c,Type from Event where Id =:testEvent1.Id ];
            if(lstEventResult.size() > 0)
            {
                System.assertEquals('Yes', lstEventResult[0].Send_Alert__c);
                System.assertEquals(Date.today(), lstEventResult[0].Alert_Sent_Date__c.date());
            }
            List<Event> lstEventResult2 = [select Id, Send_Alert__c, Alert_Sent_Date__c,Type from Event where Id =:testEvent2.Id ];
            if(lstEventResult2.size() > 0)
            {
                System.assertEquals('No', lstEventResult2[0].Send_Alert__c);
                System.assertEquals(null, lstEventResult2[0].Alert_Sent_Date__c);
            }
            List<Event> lstEventResult3 = [select Id, Send_Alert__c, Alert_Sent_Date__c,Type from Event where Id =:testEvent3.Id ];
            if(lstEventResult3.size() > 0)
            {
                System.assertEquals('Yes', lstEventResult3[0].Send_Alert__c);
                System.assertEquals(Date.today(), lstEventResult3[0].Alert_Sent_Date__c.date());
            }
            List<Event> lstEventResult4 = [select Id, Send_Alert__c, Alert_Sent_Date__c,Type from Event where Id =:testEvent4.Id ];
            if(lstEventResult4.size() > 0)
            {
                System.assertEquals('Yes', lstEventResult4[0].Send_Alert__c);
                System.assertEquals(Date.today(), lstEventResult4[0].Alert_Sent_Date__c.date());
            }
        }
    }
    
    static testMethod void TestEventAutoPopulateProducts() {

        User testUser1 = GS_TestDataCreator.createUser('Operations User', 'Tom.123@test.com', 'APAC');
        User testUser2 = GS_TestDataCreator.createUser('Operations User', 'Jerry.123@test.com', 'APAC');

        System.runAs(testUser1)
        {
            Account testAccount = GS_TestDataCreator.createAccount('TestAccount');
            Contact testContact = GS_TestDataCreator.createContact('testA', testAccount);
			
			Follow_Rule_Setting__c testSetting1 = GS_TestDataCreator.createFollowRuleSetting('Opportunity',true);
			Follow_Rule_Setting__c testSetting2 = GS_TestDataCreator.createFollowRuleSetting('OpportunityTeam',true);
			
			Opportunity testOpp = GS_TestDataCreator.createOpportunity(testAccount, 'test opportunity', 'New_Business', 'Opportunity Identified', 'Subscription', '1 year', 'Tier 1');
			Product2 testProduct1 = GS_TestDataCreator.createProduct('TestProduct1', true, true, 'implementation', 'ACV');
			Product2 testProduct2 = GS_TestDataCreator.createProduct('TestProduct2', true, true, 'implementation', 'ACV');
			PricebookEntry testPBEntry1 = GS_TestDataCreator.createPriceBookEntry(testProduct1, 100);
			PricebookEntry testPBEntry2 = GS_TestDataCreator.createPriceBookEntry(testProduct2, 100);
			OpportunityLineItem oppLineItem1 = GS_TestDataCreator.createOppLineItem(testPBEntry1, testOpp, 'New Business', 100, 200, 50, 'Yes', 'Analec', null, 10000, null, 'ACV', 'NA');
			OpportunityLineItem oppLineItem2 = GS_TestDataCreator.createOppLineItem(testPBEntry2, testOpp, 'New Business', 100, 200, 50, 'Yes', 'Analec', null, 10000, null, 'ACV', 'NA');

            Event testEvent1 = GS_TestDataCreator.createEvent(testUser1,100,Date.valueOf('2015-10-19'),testContact, 'Meeting (Client Visit)', testOpp, false);
            Event testEvent2 = GS_TestDataCreator.createEvent(testUser1,200,Date.valueOf('2015-10-19'),testContact, 'Meeting (Client Visit)', testOpp, false);
            Event testEvent3 = GS_TestDataCreator.createEvent(testUser1,300,Date.valueOf('2015-10-19'),testContact, 'Meeting (Client Visit)', testOpp, false);
            Event testEvent4 = GS_TestDataCreator.createEvent(testUser1,400,Date.valueOf('2015-10-19'),testContact, 'Meeting (Client Visit)', testOpp, false);
            Event testEvent5 = GS_TestDataCreator.createEvent(testUser1,400,Date.valueOf('2015-10-19'),testContact);			
			List<Event> eventsList = new List<Event>{testEvent1, testEvent2, testEvent3, testEvent4};
			insert eventsList;
			Map<Id, Event> mapEvents = new Map<Id,Event>([SELECT id, Products__c from Event]);
			Set<String> ProductsSet;
			
			ProductsSet = GS_ActivityUtil.getProductSetFromString(mapEvents.get(testEvent1.id).Products__c);
			System.assertEquals(2, ProductsSet.size());
			
			ProductsSet = GS_ActivityUtil.getProductSetFromString(mapEvents.get(testEvent5.id).Products__c);
			System.assertEquals(1, ProductsSet.size());
			
			testEvent5.Type = 'Meeting (Client Demo)';
			testEvent5.whatId = testOpp.Id;
			update testEvent5;
			
			mapEvents = new Map<Id,Event>([SELECT id, Products__c from Event]);
			ProductsSet = GS_ActivityUtil.getProductSetFromString(mapEvents.get(testEvent5.id).Products__c);
			System.assertEquals(1, ProductsSet.size());
			
        }
    }    
}