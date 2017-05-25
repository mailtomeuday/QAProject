/**************************************************************************************************
 * Name           : GS_OpportunityDMLHandler
 * Object         : Opportunity
 * Requirement    : 
 * Target         : DML on Opportunity
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-06-09
 * Modify History :
 **************************************************************************************************/
public class GS_OpportunityDMLHandler {

    // Get Opportunities by Id
    public static List<Opportunity> getOpportunitiesById(Set<Id> opportunityIds) {
        if(opportunityIds == null || opportunityIds.size() == 0){
        	return new List<Opportunity>();
        }
        return [SELECT Id
                        ,Name
                        ,Account.Vertical__c
                        ,ACV__c
                        ,Product_Bundle__c
                        ,Contract__c
                        ,Contract_Status__c
                        ,Evergreen__c
                        ,Evergreen_Period__c
                        ,Net_New_Business__c
                        ,No_of_Opportunity_Products__c
                        ,No_of_Opp_Products_with_One_Year__c
                        ,No_of_Opp_Products_without_Status__c
                        ,No_of_Renewed_Opp_Products__c
                        ,NYSE_Program_Tier__c
                        ,Original_Opportunity__c
                        ,Annual_Pass_Through__c
                        ,Prior_Year_ACV__c
                        ,Renewal_Status__c
                        ,Revenue_Delta_Type__c
                        ,Revenue_Type__c
                        ,Vertical__c
                        ,Bundled_With__c
                        ,Evergreen_Date__c
                 FROM Opportunity
                 WHERE Id in: opportunityIds];
    }

    // Get Opportunities with Line Items by Id
    public static List<opportunity> getOpportunitiesWithLineItemsById(Set<Id> opportunityIds) {
    	if(opportunityIds == null || opportunityIds.size() == 0){
        	return new List<Opportunity>();
        }
        return [SELECT Id
                      ,Name
                      ,ACV__c
                      ,Product_Bundle__c
                      ,Contract__c
                      ,Contract_Status__c
                      ,Evergreen__c
                      ,Evergreen_Period__c
                      ,Net_New_Business__c
                      ,RecordType.DeveloperName
                      ,No_of_Opportunity_Products__c
                      ,No_of_Opp_Products_with_One_Year__c
                      ,No_of_Opp_Products_without_Status__c
                      ,No_of_Renewed_Opp_Products__c
                      ,NYSE_Program_Tier__c
                      ,Original_Opportunity__c
                      ,Annual_Pass_Through__c
                      ,Prior_Year_ACV__c
                      ,Renewal_Status__c
                      ,Revenue_Delta_Type__c
                      ,Revenue_Type__c
                      ,Vertical__c
                      ,Bundled_With__c
                      ,Evergreen_Date__c
                      ,StageName
                      ,(SELECT Id
                              ,ProductCode
                              ,Status__c
                              ,Subscription_End_Date__c
                              ,Lost_Cancelled_Reason__c
                              ,Estimated_Completion_Date__c
                              ,Product2.Name
                        FROM OpportunityLineItems
                        ORDER BY ProductCode)
               FROM Opportunity
               WHERE Id in: opportunityIds];
    }

    // Get Opportunities with Line Items and licenses by Id
    public static List<opportunity> getOppsWithLineItemsAndLicenseById(Set<Id> opportunityIds) {
    	if(opportunityIds == null || opportunityIds.size() == 0){
        	return new List<Opportunity>();
        }    	
        return [SELECT Id
                      ,Name
                      ,ACV__c
                      ,Product_Bundle__c
                      ,Contract__c
                      ,Contract_Status__c
                      ,Evergreen__c
                      ,Evergreen_Period__c
                      ,Net_New_Business__c
                      ,No_of_Opportunity_Products__c
                      ,No_of_Opp_Products_with_One_Year__c
                      ,No_of_Opp_Products_without_Status__c
                      ,No_of_Renewed_Opp_Products__c
                      ,NYSE_Program_Tier__c
                      ,Original_Opportunity__c
                      ,Annual_Pass_Through__c
                      ,Prior_Year_ACV__c
                      ,Renewal_Status__c
                      ,Revenue_Delta_Type__c
                      ,Revenue_Type__c
                      ,Vertical__c
                      ,Bundled_With__c
                      ,Evergreen_Date__c
                      ,Renewal_Increment__c
                      ,(SELECT Id
                              ,Subscription_Start_Date__c
                              ,Subscription_End_Date__c
                              ,License__c
                              ,Work_Order__c
                              ,Product_Revenue_Type__c
                        FROM OpportunityLineItems)
                      ,(SELECT Id
                              ,Start_Date__c
                              ,End_Date__c
                        FROM Licenses__r)
               FROM Opportunity
               WHERE Id in: opportunityIds];
    }
    
    // Get line items from opportunity
    // Status__c IN ('Renewed', 'Won')
    public static List<OpportunityLineItem> getWonLineItemsByOppId(Set<Id> opportunityIds) {
    	if(opportunityIds == null || opportunityIds.size() == 0){
        	return new List<OpportunityLineItem>();
        }    	
        return [SELECT Name
                      ,OpportunityId
                      ,Opportunity.AccountId
                      ,Opportunity.Account.Name
                      ,Opportunity.Contract__c
                      ,Opportunity.Original_Opportunity__c
                      ,Opportunity.OwnerId
                      ,Opportunity.Renewal_Increment__c
                      ,Opportunity.RecordTypeId
                      ,Product2Id
                      ,Product2.Name
                      ,Product2.Work_Order_Type_Default__c
                      ,Product2.Asset__c
                      ,Product2.Work_Order_Queue__c
                      ,Product2.Work_Order_on_Renewal__c
                      ,PricebookEntryId
                      ,No_of_Users__c
                      ,UnitPrice
                      ,Asset__c
                      ,Annual_Pass_Through__c
                      ,Referral_Partner__c
                      ,Status__c
                      ,Lost_Cancelled_Reason__c
                      ,Subscription_Start_Date__c
                      ,Subscription_End_Date__c
                      ,Est_Start_Date__c
                      ,Estimated_Completion_Date__c
                      ,Product_Transaction_Type__c
                      ,Prior_Year_ACpV__c
                      ,Prior_Year_Pass_Through__c
                      ,Net_New_Business__c
                      ,Term_Months__c
                      ,Product_Revenue_Type__c
                      ,Product_Vertical__c
                      ,Product_Region__c
                      ,Estimated_Annual_Fees__c
                      ,ACpV__c
                      ,Renewal_Increase__c
                      ,Work_Order__c
                      ,Dataset__c
                      ,Data_Region__c
                      ,Site_License__c
                      ,Asset__r.AccountId
                      ,Asset__r.Status
                      ,Asset__r.Product2Id
                      ,License__c
                      ,Expense_Cap__c
                      ,Upfront_Expense_Fee__c
                      ,Free_Period_months__c
                      ,CurrencyISOCode
                      ,Description
                      ,Debt_Issue_Size__c
                      ,No_of_Calls__c
                      ,No_of_Deals__c
                      ,No_of_Debt_Issues__c
                      ,No_of_Meetings__c
                      ,No_of_Conferences__c
                      ,No_of_Questions__c
                      ,No_of_Reports__c
                      ,Requires_Implementation_UAT__c
                FROM OpportunityLineItem
                WHERE OpportunityId IN : opportunityIds
                AND Status__c IN ('Renewed', 'Won')];
    }

    // Get line items from opportunity
    // Status__c = 'Cancelled'
    public static List<OpportunityLineItem> getCancelledLineItemsByOppId(Set<Id> opportunityIds) {
    	if(opportunityIds == null || opportunityIds.size() == 0){
        	return new List<OpportunityLineItem>();
        }   	
        return [SELECT Name
                      ,OpportunityId
                      ,Opportunity.AccountId
                      ,Opportunity.Account.Name
                      ,Opportunity.Contract__c
                      ,Opportunity.OwnerId
                      ,Product2Id
                      ,Product2.Name
                      ,Product2.Work_Order_Type_Default__c
                      ,Product2.Asset__c
                      ,Product2.Work_Order_Queue__c
                      ,No_of_Users__c
                      ,UnitPrice
                      ,Annual_Pass_Through__c
                      ,Referral_Partner__c
                      ,Status__c
                      ,Subscription_Start_Date__c
                      ,Subscription_End_Date__c
                      ,Est_Start_Date__c
                      ,Estimated_Completion_Date__c
                      ,Product_Transaction_Type__c
                      ,Prior_Year_ACpV__c
                      ,Prior_Year_Pass_Through__c
                      ,Net_New_Business__c
                      ,Term_Months__c
                      ,Product_Revenue_Type__c
                      ,Product_Vertical__c
                      ,Product_Region__c
                      ,Estimated_Annual_Fees__c
                      ,ACpV__c
                      ,Renewal_Increase__c
                      ,Work_Order__c
                      ,Dataset__c
                      ,Data_Region__c
                      ,Site_License__c
                      ,Expense_Cap__c
                      ,Upfront_Expense_Fee__c
                      ,Free_Period_months__c
                      ,CurrencyISOCode
                      ,Description
                      ,Debt_Issue_Size__c
                      ,No_of_Calls__c
                      ,No_of_Deals__c
                      ,No_of_Meetings__c
                      ,No_of_Conferences__c
                      ,No_of_Questions__c
                      ,No_of_Reports__c
                      ,Requires_Implementation_UAT__c
                FROM OpportunityLineItem
                WHERE OpportunityId IN : opportunityIds
                AND Status__c = 'Cancelled'];
    }

    // Get line items from opportunity
    // Status__c IN ('Renewed', 'Won') and Product.Asset == checked
    public static List<OpportunityLineItem> getLineItemsToRenewAssetByIds(Set<Id> opportunityIds) {
    	if(opportunityIds == null || opportunityIds.size() == 0){
        	return new List<OpportunityLineItem>();
        }     	
        return [SELECT Name
                      ,OpportunityId
                      ,Opportunity.AccountId
                      ,Opportunity.Account.Name
                      ,Opportunity.Contract__c
                      ,Opportunity.Original_Opportunity__c
                      ,Opportunity.OwnerId
                      ,Product2Id
                      ,Product2.Name
                      ,Product2.Work_Order_Type_Default__c
                      ,Product2.Asset__c
                      ,Product2.Work_Order_Queue__c
                      ,PricebookEntryId
                      ,No_of_Users__c
                      ,UnitPrice
                      ,Asset__c
                      ,Annual_Pass_Through__c
                      ,Referral_Partner__c
                      ,Status__c
                      ,Lost_Cancelled_Reason__c
                      ,Subscription_Start_Date__c
                      ,Subscription_End_Date__c
                      ,Est_Start_Date__c
                      ,Estimated_Completion_Date__c
                      ,Product_Transaction_Type__c
                      ,Prior_Year_ACpV__c
                      ,Net_New_Business__c
                      ,Term_Months__c
                      ,Product_Revenue_Type__c
                      ,Product_Vertical__c
                      ,Product_Region__c
                      ,Estimated_Annual_Fees__c
                      ,ACpV__c
                      ,Renewal_Increase__c
                      ,Dataset__c
                      ,Data_Region__c
                      ,Site_License__c
                      ,License__c
                      ,Expense_Cap__c
                      ,Upfront_Expense_Fee__c
                      ,Free_Period_months__c
                      ,CurrencyISOCode
                FROM OpportunityLineItem
                WHERE OpportunityId IN : opportunityIds
                AND Status__c IN ('Renewed', 'Won')
                AND Product2.Asset__c = TRUE];
    }

    // Get Opportunities with renewal opportunities
    public static List<Opportunity> getOppsByIdWithRenewalOpps(Set<Id> opportunityIds) {
    	if(opportunityIds == null || opportunityIds.size() == 0){
        	return new List<Opportunity>();
        }     	
        return [SELECT Id
                        ,Name
                        ,Account.Vertical__c
                        ,ACV__c
                        ,Product_Bundle__c
                        ,Contract__c
                        ,Contract_Status__c
                        ,Evergreen__c
                        ,Evergreen_Period__c
                        ,Net_New_Business__c
                        ,No_of_Opportunity_Products__c
                        ,No_of_Opp_Products_with_One_Year__c
                        ,No_of_Opp_Products_without_Status__c
                        ,No_of_Renewed_Opp_Products__c
                        ,NYSE_Program_Tier__c
                        ,Original_Opportunity__c
                        ,Annual_Pass_Through__c
                        ,Prior_Year_ACV__c
                        ,Renewal_Status__c
                        ,Revenue_Delta_Type__c
                        ,Revenue_Type__c
                        ,Vertical__c
                        ,Bundled_With__c
                        ,Evergreen_Date__c
                        ,(SELECT Id
                          FROM Opportunities__r)
                 FROM Opportunity
                 WHERE Id in: opportunityIds];
    }

    // Get Opportunity with Opportunity Contact Role by Opportunity ids
    public static List<Opportunity> getOppWithOppContactRoleById(Set<Id> oppIds) {
    	if(oppIds == null || oppIds.size() == 0){
        	return new List<Opportunity>();
        }    	
        return [SELECT Id
                      , (SELECT Id
                        FROM OpportunityContactRoles)
                FROM Opportunity
                WHERE Id in: oppIds];
    }

    // Get line items from opportunity by id
    public static List<OpportunityLineItem> getLineItemsById(Set<Id> setId) {
    	if(setId == null || setId.size() == 0){
        	return new List<OpportunityLineItem>();
        }     	
        return [SELECT Name
                      ,OpportunityId
                      ,Opportunity.AccountId
                      ,Opportunity.Account.Name
                      ,Opportunity.Account.Vertical__c
                      ,Opportunity.Contract__c
                      ,Opportunity.Original_Opportunity__c
                      ,Opportunity.OwnerId
                      ,Opportunity.Revenue_Type__c
                      ,Product2.Work_Order_Queue__c
                      ,Product2Id
                      ,Product2.Name
                      ,Product2.Work_Order_Type_Default__c
                      ,Product2.Revenue_Type__c
                      ,PricebookEntryId
                      ,No_of_Users__c
                      ,UnitPrice
                      ,Asset__c
                      ,Annual_Pass_Through__c
                      ,Referral_Partner__c
                      ,Status__c
                      ,Lost_Cancelled_Reason__c
                      ,Subscription_Start_Date__c
                      ,Subscription_End_Date__c
                      ,Est_Start_Date__c
                      ,Estimated_Completion_Date__c
                      ,Product_Transaction_Type__c
                      ,Prior_Year_ACpV__c
                      ,Net_New_Business__c
                      ,Term_Months__c
                      ,Product_Revenue_Type__c
                      ,Product_Vertical__c
                      ,Product_Region__c
                      ,Estimated_Annual_Fees__c
                      ,ACpV__c
                      ,Renewal_Increase__c
                      ,CreatedBy.Region__c
                      ,Dataset__c
                      ,Data_Region__c
                      ,Site_License__c
                      ,License__c
                      ,Expense_Cap__c
                      ,Upfront_Expense_Fee__c
                      ,Free_Period_months__c
                FROM OpportunityLineItem
                WHERE Id IN : setId];
    }

    // Get line items from opportunity by Opp id
    public static List<OpportunityLineItem> getLineItemsByOppId(Set<Id> setId) {
    	if(setId == null || setId.size() == 0){
        	return new List<OpportunityLineItem>();
        }     	
        return [SELECT Name
                      ,OpportunityId
                      ,Opportunity.AccountId
                      ,Opportunity.Account.Name
                      ,Opportunity.Account.Vertical__c
                      ,Opportunity.Contract__c
                      ,Opportunity.Original_Opportunity__c
                      ,Opportunity.OwnerId
                      ,Opportunity.Revenue_Type__c
                      ,Product2Id
                      ,Product2.Name
                      ,Product2.Work_Order_Type_Default__c
                      ,Product2.Revenue_Type__c
                      ,Product2.Work_Order_Queue__c
                      ,PricebookEntryId
                      ,No_of_Users__c
                      ,UnitPrice
                      ,Asset__c
                      ,Annual_Pass_Through__c
                      ,Referral_Partner__c
                      ,Status__c
                      ,Lost_Cancelled_Reason__c
                      ,Subscription_Start_Date__c
                      ,Subscription_End_Date__c
                      ,Est_Start_Date__c
                      ,Estimated_Completion_Date__c
                      ,Product_Transaction_Type__c
                      ,Prior_Year_ACpV__c
                      ,Net_New_Business__c
                      ,Term_Months__c
                      ,Product_Revenue_Type__c
                      ,Product_Vertical__c
                      ,Product_Region__c
                      ,Estimated_Annual_Fees__c
                      ,ACpV__c
                      ,Renewal_Increase__c
                      ,CreatedBy.Region__c
                      ,Dataset__c
                      ,Data_Region__c
                      ,Site_License__c
                      ,License__c
                      ,Expense_Cap__c
                      ,Upfront_Expense_Fee__c
                      ,Free_Period_months__c
                FROM OpportunityLineItem
                WHERE OpportunityId IN : setId];
    }

    // Get Team Member from opportunity
    public static List<OpportunityTeamMember> getTeamMembersByOppId(Set<Id> opportunityIds) {
    	if(opportunityIds == null || opportunityIds.size() == 0){
        	return new List<OpportunityTeamMember>();
        }     	
        return [SELECT Id
                      ,Name
                      ,UserId
                      ,TeamMemberRole
                      ,OpportunityId
                      ,OpportunityAccessLevel
                FROM OpportunityTeamMember
                WHERE OpportunityId =: opportunityIds];
    }

    // Get Opportunity Contact Role from opportunity
    public static List<OpportunityContactRole> getOppContactRoleByOppId(Set<Id> opportunityIds) {
    	if(opportunityIds == null || opportunityIds.size() == 0){
        	return new List<OpportunityContactRole>();
        }     	
        return [SELECT Id
                      ,ContactId
                      ,IsPrimary
                      ,OpportunityId
                      ,Role
                FROM OpportunityContactRole
                WHERE OpportunityId =: opportunityIds];
    }
}