/**************************************************************************************************
 * Name           : GS_LeadValidationTHandler
 * Object         : Lead
 * Requirement    : 
 * Target         : Validate value
 * Refer classes  : 
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-12-24
 * Modify History :
 **************************************************************************************************/
public class GS_LeadValidationTHandler implements GS_Triggers.Handler {
    
    public Map<Id, Lead> mapNewLd;
    public Map<Id, Lead> mapOldLd;

    public void handle() {

        if(Trigger.isInsert) {
            mapNewLd = (Map<Id, Lead>)Trigger.newMap;
        } else if (Trigger.isUpdate) {
            mapNewLd = (Map<Id, Lead>)Trigger.newMap;
            mapOldLd = (Map<Id, Lead>)Trigger.oldMap;
        }

        // Validate country list
        if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore) {
            
            // Check user's profile, if the user is a system administrator, it's unnecessary to validate the country
            // Especially for data migration.
            Boolean isExcludedForCountryValidate = FALSE;

            for(String itemName : Excluded_Profile_Country_Validation__c.getAll().keySet()) {
                if(Id.valueOf(itemName) == UserInfo.getProfileId()) {
                    isExcludedForCountryValidate = TRUE;
                }
            }

            if(!isExcludedForCountryValidate){
                checkCountry();
            }
        }
    }

    // Check if the Counntry
    private void checkCountry() {
        if(Trigger.isInsert) {
        	for(Lead ld : (List<Lead>)Trigger.new) {
        		if(String.isNotBlank(ld.Country)){
    	    		if(!GS_CommonUtility.isValidCountry(ld.Country)) {
    	    			ld.Country.addError(Label.Msg_Invalid_Country);
    	    		}
    	    	}
        	}
        } else if (Trigger.isUpdate) {
            for(Lead ld : (List<Lead>)Trigger.new) {
                if(ld.Country != mapOldLd.get(ld.Id).Country) {
                    if(String.isNotBlank(ld.Country)){
                        if(!GS_CommonUtility.isValidCountry(ld.Country)) {
                            ld.Country.addError(Label.Msg_Invalid_Country);
                        }
                    }
                }
            }
        }
    }
}