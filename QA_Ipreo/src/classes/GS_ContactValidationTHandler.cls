/**************************************************************************************************
 * Name           : GS_ContactValidationTHandler
 * Object         : Contact
 * Requirement    : 
 * Target         : Validate value
 * Refer classes  : 
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-12-24
 * Modify History :
 **************************************************************************************************/
public class GS_ContactValidationTHandler implements GS_Triggers.Handler {

    public Map<Id, Contact> mapNewCon;
    public Map<Id, Contact> mapOldCon;

    public void handle() {

        if(Trigger.isInsert) {
            mapNewCon = (Map<Id, Contact>)Trigger.newMap;
        } else if (Trigger.isUpdate) {
            mapNewCon = (Map<Id, Contact>)Trigger.newMap;
            mapOldCon = (Map<Id, Contact>)Trigger.oldMap;
        } else if (Trigger.isDelete) {
            mapOldCon = (Map<Id, Contact>)Trigger.oldMap;
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

        // Check only system administrater and operations user can delete Contact
        if(Trigger.isDelete && Trigger.isBefore) {
            checkDelOperator();
        }
    }

    // Check if the Counntry
    private void checkCountry() {
        if(Trigger.isInsert) {
        	for(Contact con : (List<Contact>)Trigger.new) {

        		if(String.isNotBlank(con.OtherCountry)){
    	    		if(!GS_CommonUtility.isValidCountry(con.OtherCountry)) {
    	    			con.OtherCountry.addError(Label.Msg_Invalid_Country);
    	    		}
    	    	}

    	    	if(String.isNotBlank(con.MailingCountry)){
    	    		if(!GS_CommonUtility.isValidCountry(con.MailingCountry)) {
    	    			con.MailingCountry.addError(Label.Msg_Invalid_Country);
    	    		}
    	    	}
        	}
        } else if (Trigger.isUpdate) {

            for(Contact con : (List<Contact>)Trigger.new) {
                if(con.OtherCountry != mapOldCon.get(con.Id).OtherCountry) {
                    if(String.isNotBlank(con.OtherCountry)){
                        if(!GS_CommonUtility.isValidCountry(con.OtherCountry)) {
                            con.OtherCountry.addError(Label.Msg_Invalid_Country);
                        }
                    }
                }

                if(con.MailingCountry != mapOldCon.get(con.Id).MailingCountry) {
                    if(String.isNotBlank(con.MailingCountry)){
                        if(!GS_CommonUtility.isValidCountry(con.MailingCountry)) {
                            con.MailingCountry.addError(Label.Msg_Invalid_Country);
                        }
                    }
                }
            }
        }
    }

    // Check only system administrater and operations user can delete Contact
    private void checkDelOperator() {

        Set<String> profilesName = new Set<String>();
        profilesName.add(GS_GlobalVariables.SYSTEMADMIN);
        profilesName.add(GS_GlobalVariables.OPERATIONSUER);

        if(GS_CommonUtility.getProfileMapByName(profilesName).get(UserInfo.getProfileId()) == NULL) {
            for(Contact acc : (List<Contact>)Trigger.old) {
                acc.addError(Label.Check_Contact_Deleting_Operator);
            }
        }
    }
}