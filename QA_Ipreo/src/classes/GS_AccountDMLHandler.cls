/**************************************************************************************************
 * Name           : GS_AccountDMLHandler
 * Object         : Account
 * Requirement    : 
 * Target         : DML on Account
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-05-19
 * Modify History :
 **************************************************************************************************/
public class GS_AccountDMLHandler {

    // Get assets of account
    public static List<Account> getAssetsWithAccount(List<Id> accountIds) {

        List<Account> listAccount = [SELECT Id
                                           ,(SELECT Id
                                                   ,Status
                                            FROM Assets)
                                     FROM Account WHERE Id =: accountIds];

        return listAccount;
    }

    // Get Work Orders of account
    public static List<Account> getWorkOrdersWithAccount(List<Id> accountIds) {

        List<Account> listAccount = [SELECT Id
                                           ,(SELECT Id
                                                   ,Active__c
                                             FROM Work_Orders__r)
                                     FROM Account WHERE Id =: accountIds];

        return listAccount;
    }

    // Get Account by ids
    public static List<Account> getAccountsByIds(Set<Id> accountIds) {
        return [SELECT Id
                      ,IsDeleted
                      ,MasterRecordId
                      ,Name
                      ,Type
                      ,Vertical__c
                      ,Status__c
                      ,No_of_Active_Assets__c
                      ,No_of_Active_Work_Orders__c
                      ,No_of_All_Assets__c
                      ,No_of_All_Work_Orders__c
                      ,NYSE_Program_Tier__c
                      ,Tier__c
                      ,LOB__c
                      ,TSX_Tier__c
                      FROM Account
                      WHERE Id in: accountIds];
    }

    // Get Accounts with entitlement
    public static List<Account> getAccountWithEntitlement(Set<Id> accountIds) {
      return [SELECT Id
                      ,IsDeleted
                      ,MasterRecordId
                      ,Name
                      ,Type
                      ,Vertical__c
                      ,Status__c
                      ,No_of_Active_Assets__c
                      ,No_of_Active_Work_Orders__c
                      ,No_of_All_Assets__c
                      ,No_of_All_Work_Orders__c
                      ,NYSE_Program_Tier__c
                      ,Tier__c
                      ,(SELECT Id
                              ,IsPerIncident
                              ,EndDate
                              ,CasesPerEntitlement
                              ,AssetId
                              ,AccountId
                              ,ServiceContractId
                              ,Name
                              ,Type
                              ,BusinessHoursId
                              ,StartDate
                              ,Status
                              ,SlaProcessId
                              ,ContractLineItemId
                        FROM Entitlements
                        LIMIT 1)
                      FROM Account
                      WHERE Id in: accountIds];
    }

    // Get Account team members by Account Id
    public static List<AccountTeamMember> getAccTeamMemsByAccIds(List<Id> accountIds) {
        return [SELECT Id
                      ,AccountId
                      ,UserId
                      ,User.Email
                      ,User.Name
                      ,TeamMemberRole
                      ,AccountAccessLevel
                      FROM AccountTeamMember
                      WHERE AccountId =: accountIds];
    }

    
    // Get assets,Work Order of account
    public static List<Account> getAssetsWorkOrdersByAccount(List<Id> accountIds) {

        List<Account> listAccount = [SELECT Id
        									,No_of_Active_Assets__c
        									,No_of_All_Assets__c
        									,No_of_Active_Work_Orders__c
        									,No_of_All_Work_Orders__c
                                           ,(SELECT Id
                                                   ,Status,Product2.Name,Product2.ProductCode
                                                   ,AccountProductRegionKey__c,Product2.Id
                                                   ,AccountId,Product_Region__c
                                            FROM Assets)
                                            ,(SELECT Id
                                                   ,Active__c,Product__r.Name,Product__r.ProductCode 
                                             FROM Work_Orders__r)
                                     FROM Account WHERE Id =: accountIds];

        return listAccount;
    }
    
}