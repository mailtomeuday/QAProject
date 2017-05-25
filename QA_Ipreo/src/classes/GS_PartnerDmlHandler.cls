/**************************************************************************************************
 * Name           : GS_PartnerDmlHandler
 * Object         : Partner
 * Requirement    : 
 * Target         : DML on Partner
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-09-11
 * Modify History :
 **************************************************************************************************/

// This class is default to without sharing, but if some with sharing apex calls this class, this will
// be used as with sharing, and this will cause an error that partner is not supported.
// Please pay attention to this when using partner.
public class GS_PartnerDmlHandler {
    
    // Get partners by opportunity id
    public static List<Partner> getPartnersByOppId(Set<Id> oppIds) {
    	return [SELECT  OpportunityId
    				  , AccountFromId
    				  , AccountToId
    				  , Role
    				  , IsPrimary
    			FROM Partner
    			WHERE OpportunityId =: oppIds];
    }
}