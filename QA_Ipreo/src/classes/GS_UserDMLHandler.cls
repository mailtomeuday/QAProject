/**************************************************************************************************
 * Name           : GS_UserDMLHandler
 * Object         : User
 * Requirement    : 
 * Target         : DML on User
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-09-10
 * Modify History :
 **************************************************************************************************/
public class GS_UserDMLHandler {
    public static List<User> getUsersByIds(Set<Id> userIds) {
        return [Select Id
                      ,Name
                      ,Region__c
                      ,UserRole.Name
                      ,FirstName
                      ,LastName
                      ,IsActive
                FROM User
                WHERE Id in: userIds];
    }

    public static List<User> getUsersByNames(Set<String> userName) {
        return [Select Id
                      ,Name
                      ,Email
                      ,Region__c
                FROM User
                WHERE Name =: userName
                AND IsActive = TRUE];
    }
}