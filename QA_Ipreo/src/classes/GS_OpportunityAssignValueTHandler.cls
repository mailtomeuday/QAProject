/**************************************************************************************************
 * Name           : GS_OpportunityAssignValueTHandler
 * Object         : Opportunity
 * Requirement    : STY-00011, STY-00007, STY-00230
 * Target         : Assign value when an opportunity is created or updated
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-07-02
 * Modify History : 2017-02-10 - SPS-1699
 * Changes		  : Added Logic to compute Est.Completion Date, Cancel reason based on Opp.Products
 **************************************************************************************************/
public class GS_OpportunityAssignValueTHandler implements GS_Triggers.Handler{

    public void handle() {

        // Related account information
        Set<Id> setAccIds = new Set<Id>();
        List<Account> lstAcc = new List<Account>();
        Map<Id, Account> mapAcc = new Map<Id, Account>();

        for(Opportunity tempOpp : (List<Opportunity>)Trigger.new) {
            if(!setAccIds.contains(tempOpp.AccountId)) {
                setAccIds.add(tempOpp.AccountId);
            }
        }

        lstAcc = GS_AccountDMLHandler.getAccountsByIds(setAccIds);

        if(lstAcc.size() > 0) {
            mapAcc = new Map<Id, Account>(lstAcc);
        }
        assginOppVertical(mapAcc);
        assignNYSEProgramTier(mapAcc);
        assginOppLOB(mapAcc);
        assginTSXTier(mapAcc);
        assignOppFieldValues(mapAcc);
        setCWVDetails();
        //assignOppNameWhenClose(mapAcc);
    }

    // On opportunity, If vertical is blank, default the vertical as account's vertical
    private void assginOppVertical(Map<Id, Account> mapAccounts) {
        if(Trigger.isInsert){
            if(Trigger.isBefore) {
                for(Opportunity tempOpp : (List<Opportunity>)Trigger.new) {
                    if(String.isBlank(tempOpp.Vertical__c)) {
                        tempOpp.Vertical__c = mapAccounts.get(tempOpp.AccountId).Vertical__c;
                    }
                }
            }
        }
    }

    // On opportunity, If LOB is blank, default the LOB as account's LOB
    private void assginOppLOB(Map<Id, Account> mapAccounts) {
        if(Trigger.isInsert){
            if(Trigger.isBefore) {
                for(Opportunity tempOpp : (List<Opportunity>)Trigger.new) {
                    if(String.isBlank(tempOpp.LOB__c)) {
                        tempOpp.LOB__c = mapAccounts.get(tempOpp.AccountId).LOB__c;
                    }
                }
            }
        }
    }

    // Opportunity
    // IF record created, THEN
    // IF record created AND NYSE Program Tier == null AND Account.NYSE Program Tier ≠ "Tier A", THEN NYSE Program Tier = Account.NYSE Program Tier
    // IF record created AND NYSE Program Tier == null AND Account.NYSE Program Tier == "Tier A" AND Record Type.Name == "New Business", THEN NYSE Program Tier = "Tier A"
    private void assignNYSEProgramTier(Map<Id, Account> mapAccounts) {
        if(Trigger.isInsert){
            if(Trigger.isBefore) {

                RecordType rtNewBusiness = GS_RecordTypeUtility.getRecordType(GS_GlobalVariables.OPPRTNEWBUSINESS, 'Opportunity');

                for(Opportunity tempOpp : (List<Opportunity>)Trigger.new) {
                    if(    String.isBlank(tempOpp.NYSE_Program_Tier__c)
                        && mapAccounts.get(tempOpp.AccountId).NYSE_Program_Tier__c != GS_GlobalVariables.NYSEPROGRAMTIERA) {
                        tempOpp.NYSE_Program_Tier__c = mapAccounts.get(tempOpp.AccountId).NYSE_Program_Tier__c;
                    } else if(     String.isBlank(tempOpp.NYSE_Program_Tier__c)
                                && mapAccounts.get(tempOpp.AccountId).NYSE_Program_Tier__c == GS_GlobalVariables.NYSEPROGRAMTIERA
                                && tempOpp.RecordTypeId == rtNewBusiness.Id) {
                        tempOpp.NYSE_Program_Tier__c = GS_GlobalVariables.NYSEPROGRAMTIERA;
                    }
                }
            }
        }
    }
	// On opportunity, Default the TSX Tier as account's TSX Tier
    private void assginTSXTier(Map<Id, Account> mapAccounts) {
        if(Trigger.isInsert){
            if(Trigger.isBefore) {
                for(Opportunity tempOpp : (List<Opportunity>)Trigger.new) {
                    if(String.isBlank(tempOpp.TSX_Tier__c)) {
                        tempOpp.TSX_Tier__c = mapAccounts.get(tempOpp.AccountId).TSX_Tier__c;
                    }
                }
            }
        }
    }    

    // Format opportunity Name when closed.
   /* private void assignOppNameWhenClose(Map<Id, Account> mapAccounts) {
        if(Trigger.isUpdate){
            if(Trigger.isBefore) {

                String strSeparator = ' - ';

                for(Opportunity tempOpp : (List<Opportunity>)Trigger.new) {
                    if(String.isNotBlank(tempOpp.AccountId) && (tempOpp.StageName == GS_GlobalVariables.OPPCLOSEDLOST || tempOpp.StageName == GS_GlobalVariables.OPPCLOSEDCANCELLEDVERIFIED || tempOpp.StageName == GS_GlobalVariables.OPPCLOSEDCANCELLED)) {
                        tempOpp.Name = mapAccounts.get(tempOpp.AccountId).Name +
                                       (String.isNotBlank(tempOpp.Product_Bundle__c) ? (strSeparator + tempOpp.Product_Bundle__c) : '') +
                                       strSeparator +
                                       tempOpp.StageName +
                                       (tempOpp.CloseDate != NULL ? (strSeparator + String.valueOf(tempOpp.CloseDate.year())) : '');
                        if (tempOpp.Name.length() > 120) {
                            tempOpp.Name = tempOpp.Name.left(120);
                        }
                    }
                }
            }
        }
    }*/
    
    // Compute and Assign ProductBundle for opportunity.
    /*
    Compute and assign Cancel Reason and Est Completion Date
    */
    private void assignOppFieldValues(Map<Id, Account> mapAccounts) {
        if(Trigger.isUpdate){
            if(Trigger.isBefore) {

                Map<ID,Opportunity> mapTargetOpp = new Map<ID,Opportunity>(GS_OpportunityDMLHandler.getOpportunitiesWithLineItemsById(Trigger.newMap.keySet()));
                for(Opportunity tempOpp : (List<Opportunity>)Trigger.new) {
                    Opportunity Opp = mapTargetOpp.get(tempOpp.id);
                    Opportunity oldOpp = (Opportunity)Trigger.oldMap.get(tempOpp.id);
                    if(String.isNotBlank(tempOpp.AccountId) && (tempOpp.StageName == GS_GlobalVariables.OPPCLOSEDLOST || tempOpp.StageName == GS_GlobalVariables.OPPCLOSEDCANCELLEDVERIFIED || tempOpp.StageName == GS_GlobalVariables.OPPCLOSEDCANCELLED)) {
                        tempOpp.Product_Bundle__c = GS_CommonUtility.getProductBundlerForOpp(Opp,false);
                    }
                    String tempBundle = GS_CommonUtility.getProductBundlerForOpp(Opp,true);
                    if(String.isNotBlank(tempOpp.AccountId) && tempOpp.StageName.contains('Won') && tempOpp.Product_Bundle__c != tempBundle){   
                        tempOpp.Product_Bundle__c = GS_CommonUtility.getProductBundlerForOpp(Opp,true); 
                    }
                    if(oldOpp.StageName != GS_GlobalVariables.OPPCLOSEDCANCELLEDVERIFIED && tempOpp.StageName == GS_GlobalVariables.OPPCLOSEDCANCELLEDVERIFIED){   
                        tempOpp.Cancel_Reason__c = GS_CommonUtility.getCancelReasonforOpp(Opp); 
                    }
                    if(oldOpp.StageName != GS_GlobalVariables.OPPCLOSEDWONVERIFIED && tempOpp.StageName == GS_GlobalVariables.OPPCLOSEDWONVERIFIED){   
                        tempOpp.Estimated_Completion_Date__c = GS_CommonUtility.getEstCompletionDate(Opp); 
                    }                    
                    
                }
            }
        }
    }    
    
    private void setCWVDetails(){
    	if(Trigger.isUpdate && Trigger.isBefore){
    		for(ID oppId : Trigger.newMap.keySet()){
    			Opportunity newOpp = (Opportunity)Trigger.newMap.get(oppId);
    			Opportunity oldOpp = (Opportunity)Trigger.oldMap.get(oppId);
    			if(newOpp != null && oldOpp != null){
    				if(newOpp.StageName != oldOpp.StageName && newOpp.StageName == GS_GlobalVariables.OPPCLOSEDWONVERIFIED){
    					newOpp.Verified_Date__c = System.today();
	    				/*
	    				if(newOpp.Announce_Deal__c){
							newOpp.Announce_Deal__c = false;	
	    					newOpp.Deal_Announcement_Sent__c = System.now();    					
	    				}
	    				*/
    				}	
    			}
    		}
    	}
    }
   
   
  
}