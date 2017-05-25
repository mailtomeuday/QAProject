@isTest
private class GS_AccountBatchJobTest {

   static testmethod void test() {
        Test.startTest();

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

        Country_List__c coutL1 = new Country_List__c(Name = 'China');
        Country_List__c coutL2 = new Country_List__c(Name = 'USA');
        insert coutL1;
        insert coutL2;

        Account a2 = new Account(
            Name = '86Research, LTD (Shanghai Office) 2',
            Status__c = 'Prospect',
            Vertical__c = 'Buyside',
            Account_Type__c = 'Family Office',
            BDTypeName__c = 'Family Office',
            BillingCountry = 'China',
            ShippingCountry = 'China',
            Primary_Exchange_Country__c = 'China'
        );
        insert a2;

        a2.BillingCountry = 'USA';
        a2.ShippingCountry = 'USA';
        a2.Primary_Exchange_Country__c = 'USA';
        update a2;

        User u = new User(
            Username = 'test@ipreo_epam.com',
            FirstName = 'Test',
            LastName = 'Ipreo',
            Email = 'test@ipreo.com',
            ProfileId = UserInfo.getProfileId(),
            Alias = 'TIpreo',
            EmailEncodingKey = 'ISO-8859-1',
            TimeZoneSidKey = 'Asia/Shanghai',
            LocaleSidKey = 'zh_CN',
            LanguageLocaleKey = 'en_US'
        );
        insert u;

        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountId = a.Id;
        atm.UserId = UserInfo.getUserId();
        insert atm;

        AccountTeamMember atm2 = new AccountTeamMember();
        atm2.AccountId = a.Id;
        atm2.UserId = u.Id;
        insert atm2;

        EntitySubscription es = new EntitySubscription(ParentId = a.Id, SubscriberId = u.Id);
        insert es;

        // Schedule the test job
        String sch1 = '0 0 0 3 9 ? 2022';
        String jobName1 = 'GS_AccountTeamMemberBatchScheduleJobTest' + Math.rint(Math.random() * 1000000);
        String jobId = System.schedule(jobName1, sch1, new GS_AccountTeamMemberBatchScheduleJob());

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals('0 0 0 3 9 ? 2022',ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2022-09-03 00:00:00',String.valueOf(ct.NextFireTime));


        // Schedule the test job
        String sch2 = '0 0 0 4 9 ? 2022';
        String jobName2 = 'GS_UnfollowAccountBatchScheduleJobTest' + Math.rint(Math.random() * 1000000);
        String jobId2 = System.schedule(jobName2, sch2, new GS_UnfollowAccountBatchScheduleJob());

        CronTrigger ct2 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId2];
        System.assertEquals('0 0 0 4 9 ? 2022',ct2.CronExpression);
        System.assertEquals(0, ct2.TimesTriggered);
        System.assertEquals('2022-09-04 00:00:00',String.valueOf(ct2.NextFireTime));

        Test.stopTest();

   }
}