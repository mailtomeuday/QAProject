/**************************************************************************************************
 * Name           : GS_OpportunityValidationTHandler
 * Object         : Opportunity
 * Requirement    :
 * Target         : Validation rule on Opportunity
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-10-07
 * Modify History :
 **************************************************************************************************/
public class GS_OpportunityValidationTHandler implements GS_Triggers.Handler{
    public void handle() {
    	Map<Id, Opportunity> mapNewOpp = (Map<Id, Opportunity>)Trigger.newMap;
    	checkContactRole(mapNewOpp);
    }

    private void checkContactRole(Map<Id, Opportunity> mapNewOpp) {

    	for(Opportunity opp : GS_OpportunityDMLHandler.getOppWithOppContactRoleById(Trigger.newMap.keySet())) {
    		if(    (  /* mapNewOpp.get(opp.Id).StageName == GS_GlobalVariables.OPPCONTRACTPENDING
                    ||*/ mapNewOpp.get(opp.Id).StageName == GS_GlobalVariables.OPPCLOSEWONSALES
                    || mapNewOpp.get(opp.Id).StageName == GS_GlobalVariables.OPPCLOSEDWONVERIFIED)
    			&& opp.OpportunityContactRoles.isEmpty() ){
    				Trigger.newMap.get(opp.Id).addError(Label.Msg_Req_Opportunity_Contact_Role);
    		}
    	}
    }
}