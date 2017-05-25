@isTest
public with sharing class GS_TestUserDMLHandler {
    static testmethod void testGetUsersByIds(){
         // Create  Users for UserDMLHandler
        Integer countUsers = [select count() from User];
        GS_TestDataCreator.createUser('Operations User','test_ops_user.sps.915@epam.com');
        GS_TestDataCreator.createUser('Sales User','test_sales_user.sps.915@epam.com');      
        Set<Id> userIds = new Set<Id>();
        List<User> users;
        for(User u : [select id from User]){
            userIds.add(u.id);
        }
        users = GS_UserDMLHandler.getUsersByIds(userIds);       
        System.assertEquals(countUsers+2,users.size());     
    }
    static testmethod void testGetUserNames(){  
        Integer countUsers = [select count() from User where isActive=true];
        GS_TestDataCreator.createUser('Operations User','test_ops_user.sps.915@epam.com');
        GS_TestDataCreator.createUser('Sales User','test_sales_user.sps.915@epam.com');     
        Set<String> userNames = new Set<String>();
        List<User> users;
        for(User u : [select id,name from User]){
        userNames.add(u.name);
        }
        users = GS_UserDMLHandler.getUsersByNames(userNames);       
        System.assertEquals(countUsers+2,users.size());     
    }

}