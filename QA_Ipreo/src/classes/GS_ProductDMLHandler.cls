/**************************************************************************************************
 * Name           : GS_ProductDMLHandler
 * Object         : Prodcut
 * Requirement    : 
 * Target         : DML on Prodcut
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-07-10
 * Modify History :
 **************************************************************************************************/
public class GS_ProductDMLHandler {
    public static List<Product2> getProductsById(Set<Id> productIds) {
        System.debug(LoggingLevel.INFO, '*** executed GS_ProductDMLHandler.getProductsById');
        return [SELECT Id
                      , Name
                      , ProductCode
                      , Description
                      , RevenueScheduleType
                      , RevenueInstallmentPeriod
                      , NumberOfRevenueInstallments
                      , IsActive
                      , CreatedDate
                      , CreatedById
                      , LastModifiedDate
                      , LastModifiedById
                      , SystemModstamp
                      , Family
                      , IsDeleted
                      , Revenue_Type__c
                      , Vertical__c
                      , Pass_Through_Required__c
                      , Work_Order_Type_Default__c
                      , Site_License_Per_Region__c
                      , Seat_Fee_No_of_Users__c
                      , Dataset__c
                      , Data_Region__c
               FROM Product2
               WHERE Id in: productIds];
    }
    
    public static List<Product2> getAllProducts() 
    {
    	return [select id, Name from Product2 order by Name];	
    }
}