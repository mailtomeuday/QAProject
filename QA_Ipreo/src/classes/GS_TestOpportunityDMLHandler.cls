@isTest
public class GS_TestOpportunityDMLHandler {
	static testmethod void  testOppDMLHandler(){
		Set<ID> oppIds = new Set<ID>();	
		GS_OpportunityDMLHandler.getOpportunitiesById(oppIds);
		GS_OpportunityDMLHandler.getOpportunitiesWithLineItemsById(oppIds);
		GS_OpportunityDMLHandler.getOppsWithLineItemsAndLicenseById(oppIds);
		GS_OpportunityDMLHandler.getWonLineItemsByOppId(oppIds);
		GS_OpportunityDMLHandler.getLineItemsToRenewAssetByIds(oppIds);
		GS_OpportunityDMLHandler.getCancelledLineItemsByOppId(oppIds);
		GS_OpportunityDMLHandler.getLineItemsToRenewAssetByIds(oppIds);
		GS_OpportunityDMLHandler.getOppsByIdWithRenewalOpps(oppIds);
		GS_OpportunityDMLHandler.getOppWithOppContactRoleById(oppIds);
		GS_OpportunityDMLHandler.getLineItemsById(oppIds);
		GS_OpportunityDMLHandler.getLineItemsByOppId(oppIds);
		GS_OpportunityDMLHandler.getTeamMembersByOppId(oppIds);
		GS_OpportunityDMLHandler.getOppContactRoleByOppId(oppIds);
	}

}