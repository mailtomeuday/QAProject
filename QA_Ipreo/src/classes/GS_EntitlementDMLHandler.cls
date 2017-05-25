/**************************************************************************************************
 * Name           : GS_EntitlementDMLHandler
 * Object         : Entitlement
 * Requirement    : 
 * Target         : DML on Entitlement
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-07-23
 * Modify History :
 **************************************************************************************************/
public class GS_EntitlementDMLHandler {
    
    // get all entitlements by account id
    /*public static List<Entitlement> getEntitlementsByAccountId(Set<Id> accIds) {
		return [SELECT  Id
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
				FROM Entitlement
				WHERE AccountId =: accIds];
    }*/
}