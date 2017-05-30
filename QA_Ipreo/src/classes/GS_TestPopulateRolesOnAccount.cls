/**
 * This class contains unit tests for GS_PopulateRolesOnAccountBatch & GS_PopulateRolesOnAccountScheduler
 */
@isTest
private class GS_TestPopulateRolesOnAccount {
    
    static testMethod void TestSingleATMScheduler() 
    {
        createdSingleATMTestData();
        
        Test.startTest();
        
        Datetime sysTime = System.now().addSeconds(60);
        String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        String strJobName = 'Test_Populate_RolesOn_Account_Job_' + DateTime.Now();
        
        GS_PopulateRolesOnAccountScheduler  objPopulateRolesOnAccountScheduler = new GS_PopulateRolesOnAccountScheduler(null);
        System.schedule(strJobName, chronExpression, objPopulateRolesOnAccountScheduler);
                
        Test.stopTest();
    }
        
    static testMethod void TestMultipleATMScheduler() 
    {
        createdMultipleATMTestData();
        
        Test.startTest();
        
        Datetime sysTime = System.now().addSeconds(60);
        String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        String strJobName = 'Test_Populate_RolesOn_Account_Job_' + DateTime.Now();
        
        GS_PopulateRolesOnAccountScheduler  objPopulateRolesOnAccountScheduler = new GS_PopulateRolesOnAccountScheduler(null);
        System.schedule(strJobName, chronExpression, objPopulateRolesOnAccountScheduler);
                
        Test.stopTest();
    }
    
    static testMethod void TestRandomAccountWithRoles() 
    {
        list<Id> excludeList = new list<Id>();
                                              
        Account acc = GS_TestDataCreator.createAccount('Test Acc for 837 - 3');
        
        acc.Region__c = 'North America'; 
                
        AccountTeamMember atm = GS_TestDataCreator.createAccountTeamMember(acc.Id, 'Primary Account Manager', 'NA', excludeList);
        insert atm;
        acc.primary_account_manager__c = atm.UserId;
        excludeList.add(atm.UserId);
        
        atm = GS_TestDataCreator.createAccountTeamMember(acc.Id, 'Secondary Account Manager', 'NA', excludeList);
        insert atm;
        acc.secondary_account_manager__c = atm.UserId;
        excludeList.add(atm.UserId);
        
        atm = GS_TestDataCreator.createAccountTeamMember(acc.Id, 'Primary Sales Rep', 'NA', excludeList);
        insert atm;
        acc.primary_sales_rep__c = atm.UserId;
        excludeList.add(atm.UserId);
        
        atm = GS_TestDataCreator.createAccountTeamMember(acc.Id, 'Secondary Sales Rep', 'NA', excludeList);
        insert atm;
        acc.secondary_sales_rep__c = atm.UserId;
        excludeList.add(atm.UserId);
        
        atm = GS_TestDataCreator.createAccountTeamMember(acc.Id, 'Team Lead GMI Analyst', 'NA', excludeList);
        insert atm;
        acc.Team_Lead_GMI_Analyst__c = atm.UserId;
        excludeList.add(atm.UserId);
        
        update acc;
        
        acc = [select Id,primary_account_manager__c,secondary_account_manager__c,primary_sales_rep__c,secondary_sales_rep__c from Account where Name =: 'Test Acc for 837 - 3' limit 1];
        
        system.debug('acc-------->>>'+acc);
        
        list<AccountTeamMember> lstAtm = [select Id, TeamMemberRole from  AccountTeamMember where accountId =: acc.Id];
        
        system.debug('lstAtm-------->>>'+lstAtm);
        
        delete lstAtm;
           
        Test.startTest();
        
        Datetime sysTime = System.now().addSeconds(60);
        String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        String strJobName = 'Test_Populate_RolesOn_Account_Job_' + DateTime.Now();
        
        GS_PopulateRolesOnAccountScheduler  objPopulateRolesOnAccountScheduler = new GS_PopulateRolesOnAccountScheduler(null);
        System.schedule(strJobName, chronExpression, objPopulateRolesOnAccountScheduler);
              
        Test.stopTest();
                
        acc = [select Id,primary_account_manager__c,secondary_account_manager__c,primary_sales_rep__c,secondary_sales_rep__c from Account where Name =: 'Test Acc for 837 - 3' limit 1];
        
        /*system.assertEquals(acc.primary_account_manager__c == null, true);
        system.assertEquals(acc.secondary_account_manager__c == null, true);
        system.assertEquals(acc.primary_sales_rep__c == null, true);
        system.assertEquals(acc.secondary_sales_rep__c == null, true);*/
        
        
    }
    
    static testMethod void TestVariousRegionsATMScheduler() 
    {
        createdATMWithDiffRegionsTestData();
        
        Test.startTest();
        
        Datetime sysTime = System.now().addSeconds(60);
        String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        String strJobName = 'Test_Populate_RolesOn_Account_Job_' + DateTime.Now();
        
        GS_PopulateRolesOnAccountScheduler  objPopulateRolesOnAccountScheduler = new GS_PopulateRolesOnAccountScheduler(null);
        System.schedule(strJobName, chronExpression, objPopulateRolesOnAccountScheduler);
                
        Test.stopTest();
    }
    
    static testMethod void TestSingleATMSchedulerForExistingAccount() 
    {
        createdSingleATMTestDataForExistingAccount();
        
        Test.startTest();
        
        Datetime sysTime = System.now().addSeconds(60);
        String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        String strJobName = 'Test_Populate_RolesOn_Account_Job_' + DateTime.Now();
        
        GS_PopulateRolesOnAccountScheduler  objPopulateRolesOnAccountScheduler = new GS_PopulateRolesOnAccountScheduler(null);
        System.schedule(strJobName, chronExpression, objPopulateRolesOnAccountScheduler);
                
        Test.stopTest();
    }
    
    private static void createdSingleATMTestData()
    {
        list<AccountTeamMember> listAtm = new list<AccountTeamMember>();
        
        set<string> rolesSet = new set<string>{
                                            'Primary Account Manager', 
                                            'Secondary Account Manager',
                                            'Primary Sales Rep', 
                                            'Secondary Sales Rep',
                                            'Team Lead GMI Analyst'
                                          };
        
        for(string role : rolesSet)
        {
            Integer i = 1;
            Account acc = GS_TestDataCreator.createAccount('Test Acc for 837 - ' + i);
            list<Id> excludeList = new list<Id>();
            AccountTeamMember atm = GS_TestDataCreator.createAccountTeamMember(acc.Id, role, 'NA', excludeList);
            excludeList.add(atm.UserId);
            listAtm.add(atm);
            i++;
        }
        system.debug('Size========='+listAtm.size());
        insert listAtm;
        
    } 
    
    private static void createdMultipleATMTestData()
    {
        list<AccountTeamMember> listAtm = new list<AccountTeamMember>();
        list<Id> excludeList = new list<Id>();
        
        set<string> rolesSet = new set<string>{
                                            'Primary Account Manager', 
                                            'Secondary Account Manager',
                                            'Primary Sales Rep', 
                                            'Secondary Sales Rep',
                                            'Team Lead GMI Analyst'
                                          };
                                                  
        Account acc = GS_TestDataCreator.createAccount('Test Acc for 837 - 2');
        acc.Region__c = 'North America'; 
        update acc;
        
        for(string role : rolesSet)
        {
            AccountTeamMember atm = GS_TestDataCreator.createAccountTeamMember(acc.Id, role, 'NA', excludeList);
            excludeList.add(atm.UserId);
            insert atm;
            
            atm = GS_TestDataCreator.createAccountTeamMember(acc.Id, role, 'EMEA', excludeList);
            excludeList.add(atm.UserId);
            insert atm;
            
            atm = GS_TestDataCreator.createAccountTeamMember(acc.Id, role, 'APAC', excludeList);
            excludeList.add(atm.UserId);
            insert atm;
            
            atm = GS_TestDataCreator.createAccountTeamMember(acc.Id, role, 'NA', excludeList);
            excludeList.add(atm.UserId);
            insert atm;
            
        }
        
        system.debug('Size------>>>'+listAtm.size());
    } 
    
    private static void createdATMWithDiffRegionsTestData()
    {
        list<Id> excludeList = new list<Id>();
        Account accAsia = GS_TestDataCreator.createAccount('Test Acc Asia 1');
        accAsia.Region__c = 'Asia'; 
        update accAsia;
        
        AccountTeamMember atmJAPAN = GS_TestDataCreator.createAccountTeamMember(accAsia.Id, 'Primary Account Manager', 'JAPAN', excludeList);
        excludeList.add(atmJAPAN.UserId);
        insert atmJAPAN;
        
        AccountTeamMember atmNA = GS_TestDataCreator.createAccountTeamMember(accAsia.Id, 'Primary Account Manager', 'NA', excludeList);
        excludeList.add(atmNA.UserId);
        insert atmNA;
        
        Account accAfrica = GS_TestDataCreator.createAccount('Test Acc Africa 1');
        accAfrica.Region__c = 'Africa'; 
        update accAfrica;
        
        AccountTeamMember atmEMEA = GS_TestDataCreator.createAccountTeamMember(accAfrica.Id, 'Primary Account Manager', 'EMEA', excludeList);
        excludeList.add(atmEMEA.UserId);
        insert atmEMEA;
        
        atmNA = GS_TestDataCreator.createAccountTeamMember(accAfrica.Id, 'Primary Account Manager', 'NA', excludeList);
        excludeList.add(atmNA.UserId);
        insert atmNA;
        
        Account accNorthAmerica = GS_TestDataCreator.createAccount('Test Acc North America 1');
        accNorthAmerica.Region__c = 'North America'; 
        update accNorthAmerica;
        
        AccountTeamMember atmLATAM = GS_TestDataCreator.createAccountTeamMember(accNorthAmerica.Id, 'Primary Account Manager', 'LATAM', excludeList);
        excludeList.add(atmLATAM.UserId);
        insert atmLATAM;
        
        atmNA = GS_TestDataCreator.createAccountTeamMember(accNorthAmerica.Id, 'Primary Account Manager', 'NA', excludeList);
        excludeList.add(atmNA.UserId);
        insert atmNA;
        
        Account accAsia2 = GS_TestDataCreator.createAccount('Test Acc Asia 2');
        accAsia2.Region__c = 'Asia'; 
        update accAsia2;
        
        AccountTeamMember atmAPAC = GS_TestDataCreator.createAccountTeamMember(accAsia2.Id, 'Primary Account Manager', 'APAC', excludeList);
        excludeList.add(atmAPAC.UserId);
        insert atmAPAC;
        
        atmNA = GS_TestDataCreator.createAccountTeamMember(accAsia2.Id, 'Primary Account Manager', 'NA', excludeList);
        excludeList.add(atmNA.UserId);
        insert atmNA;
        
        /*Account accBlankRegion = GS_TestDataCreator.createAccount('Test Blank Region');
        accBlankRegion.Region__c = null; 
        update accBlankRegion;
        
        AccountTeamMember atmBlankRegion = GS_TestDataCreator.createAccountTeamMember(accBlankRegion.Id, 'Primary Account Manager', null, excludeList);
        excludeList.add(atmBlankRegion.UserId);
        insert atmBlankRegion;
        
        atmNA = GS_TestDataCreator.createAccountTeamMember(accBlankRegion.Id, 'Primary Account Manager', 'NA', excludeList);
        excludeList.add(atmNA.UserId);
        insert atmNA;*/
    }
    
    private static void createdSingleATMTestDataForExistingAccount()
    {
        list<AccountTeamMember> listAtm = new list<AccountTeamMember>();
        User tempUser;
        
        set<string> rolesSet = new set<string>{
                                            'Primary Account Manager', 
                                            'Secondary Account Manager',
                                            'Primary Sales Rep', 
                                            'Secondary Sales Rep',
                                            'Team Lead GMI Analyst'
                                          };
        tempUser = GS_TestDataCreator.createUser('Sales User', 'UserRole1289_@dom99.com', 'NA');
        for(string role : rolesSet)
        {
            Integer i = 1;
            Account acc = GS_TestDataCreator.createAccount('Test Acc for 1289 - ' + i);
            acc.primary_account_manager__c = tempUser.id;
            acc.secondary_account_manager__c = tempUser.id;
            acc.primary_sales_rep__c = tempUser.id;
            acc.secondary_sales_rep__c = tempUser.id;
            acc.Team_Lead_GMI_Analyst__c = tempUser.id;
            update acc;
            list<Id> excludeList = new list<Id>();
            excludeList.add(tempUser.Id);
            AccountTeamMember atm = GS_TestDataCreator.createAccountTeamMember(acc.Id, role, 'NA', excludeList);
            excludeList.add(atm.UserId);
            listAtm.add(atm);
            i++;
        }
        system.debug('Size========='+listAtm.size());
        insert listAtm;
        
    } 
    
}