/**************************************************************************************************
 * Name           : GS_TestLeadTrigger
 * Object         : 
 * Requirement    : 
 * Target         : Test handlers on Lead Trigger
 * Refer classes  : 
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-12-24
 * Modify History :
 **************************************************************************************************/
@isTest
private class GS_TestLeadTrigger {
    static  testMethod void checkCountry() {
    	Country_List__c coutL1 = new Country_List__c();
        coutL1.Name = 'TestCountry';
        insert coutL1;

    	Lead ld = new Lead( LastName = 'Test Lead', Company = 'Test Lead', Country = 'TestCountry',  BDEmail__c = 'test.email@pwc.com');
    	insert ld;

    	Lead ldResult = [select Id, Email, BDEmail__c from Lead where LastName = 'Test Lead' limit 1];
    	System.assertEquals(ldResult.BDEmail__c, String.valueOf(ldResult.Email));
    }
}