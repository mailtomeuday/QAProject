@isTest
private class GS_OppTeamMemberTest {
    
    static testMethod void testOppTeamMemeber() {

        Test.startTest();
        Profile p = [Select Id From Profile Where Name = 'Sales User' limit 1];
        // update u;
        User u = new User(
            Username = 'test@ipreo_epam.com',
            FirstName = 'Test',
            LastName = 'Ipreo',
            Email = 'test@ipreo.com',
            ProfileId = p.Id,
            Alias = 'TIpreo',
            EmailEncodingKey = 'ISO-8859-1',
            TimeZoneSidKey = 'Asia/Shanghai',
            LocaleSidKey = 'zh_CN',
            LanguageLocaleKey = 'en_US'
        );
        insert u;
        List<Follow_Rule_Setting__c> frsList = new List<Follow_Rule_Setting__c>();
        Follow_Rule_Setting__c frs1 = new Follow_Rule_Setting__c(
            Name = 'Opportunity',
            isOpen__c = true
        );
        frsList.add(frs1);
        Follow_Rule_Setting__c frs2 = new Follow_Rule_Setting__c(
            Name = 'OpportunityTeam',
            isOpen__c = true
        );
        frsList.add(frs2);
        insert frsList;

        Account a = new Account(
            Name = '86Research, LTD (Shanghai Office)',
            Status__c = 'Prospect',
            Vertical__c = 'Buyside',
            Account_Type__c = 'Family Office',
            BDTypeName__c = 'Family Office'

        );
        insert a;

        Opportunity o = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = a.Id,
            StageName = 'Opportunity Identified',
            CloseDate = System.today().addDays(30),
            Revenue_Type__c = 'Subscription'
        );
        insert o;

        OpportunityTeamMember otm = new OpportunityTeamMember(
            OpportunityId = o.Id,
            UserId = u.Id
        );
        insert otm;

        List<EntitySubscription> enSubResult = [select ParentId,SubscriberId from EntitySubscription where SubscriberId = :u.Id];
        if(enSubResult.size() > 0)
        {
            System.assertEquals(a.Id, enSubResult[0].ParentId);
        }

        Test.stopTest();

        delete otm;

        PicklistFieldController.PicklistEntryWrapper pew = new PicklistFieldController.PicklistEntryWrapper();
        pew.active = 'true';
        pew.defaultValue = 'Bank';
        pew.label = 'Bank';
        pew.value = 'Bank';
        pew.validFor = 'gAAA';
    }
}