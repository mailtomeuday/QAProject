/**************************************************************************************************
 * Name           : GS_ContactDmlHandler
 * Object         : Contact
 * Requirement    : 
 * Target         : DML on Contact
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-10-16
 * Modify History :
 **************************************************************************************************/
public class GS_ContactDmlHandler {
    
    public static List<Contact> getContactsByConIds (Set<Id> conIds) {

    	return [SELECT Id
    				  ,Name
    				  ,AccountId
                      ,Asset_Bundle__c
                      ,GMG_Activity_Products__c
                      ,Corporate_Activity_Products__c
                      ,PCS_Activity_Products__c
    			FROM Contact
    			WHERE Id =: conIds];
    }

    public static List<Contact> getContactsWithAssetsByConIds (Set<Id> conIds) {

        return [SELECT Id
                      ,Name
                      ,AccountId
                      ,Asset_Bundle__c
                      ,(SELECT Id, Name, Active__c, Asset__r.Product2.ProductCode
                        FROM User_Assets__r)
                FROM Contact
                WHERE Id =: conIds];
    }
}