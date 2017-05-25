/**************************************************************************************************
 * Name           : GS_AccountValidationTHandler
 * Object         : Account
 * Requirement    : 
 * Target         : Validate value
 * Refer classes  : 
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-12-24
 * Modify History :
 **************************************************************************************************/
public class GS_AccountValidationTHandler implements GS_Triggers.Handler {

    public Map<Id, Account> mapNewAcc;
    public Map<Id, Account> mapOldAcc;

    public void handle() {

        if(Trigger.isInsert) {
            mapNewAcc = (Map<Id, Account>)Trigger.newMap;
        } else if (Trigger.isUpdate) {
            mapNewAcc = (Map<Id, Account>)Trigger.newMap;
            mapOldAcc = (Map<Id, Account>)Trigger.oldMap;
        } else if (Trigger.isDelete) {
            mapOldAcc = (Map<Id, Account>)Trigger.oldMap;
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

        // Check only system administrater and operations user can delete account
        if(Trigger.isDelete && Trigger.isBefore) {
            checkDelOperator();
        }
    }

    // Check if the Counntry
    private void checkCountry() {
        if(Trigger.isInsert) {
        	for(Account acc : (List<Account>)Trigger.new) {

        		if(String.isNotBlank(acc.BillingCountry)){
    	    		if(!GS_CommonUtility.isValidCountry(acc.BillingCountry)) {
    	    			acc.BillingCountry.addError(Label.Msg_Invalid_Country);
    	    		}
    	    	}

        		if(String.isNotBlank(acc.ShippingCountry)){
    	    		if(!GS_CommonUtility.isValidCountry(acc.ShippingCountry)) {
    	    			acc.ShippingCountry.addError(Label.Msg_Invalid_Country);
    	    		}
    	    	}

    	    	if(String.isNotBlank(acc.Primary_Exchange_Country__c)){
    	    		if(!GS_CommonUtility.isValidCountry(acc.Primary_Exchange_Country__c)) {
    	    			acc.Primary_Exchange_Country__c.addError(Label.Msg_Invalid_Country);
    	    		}
    	    	}
        	}
        } else if (Trigger.isUpdate) {
            for(Account acc : (List<Account>)Trigger.new) {

                if(acc.BillingCountry != mapOldAcc.get(acc.Id).BillingCountry) {
                    if(String.isNotBlank(acc.BillingCountry)){
                        if(!GS_CommonUtility.isValidCountry(acc.BillingCountry)) {
                            acc.BillingCountry.addError(Label.Msg_Invalid_Country);
                        }
                    }
                }

                if(acc.ShippingCountry != mapOldAcc.get(acc.Id).ShippingCountry) {
                    if(String.isNotBlank(acc.ShippingCountry)){
                        if(!GS_CommonUtility.isValidCountry(acc.ShippingCountry)) {
                            acc.ShippingCountry.addError(Label.Msg_Invalid_Country);
                        }
                    }
                }

                if(acc.Primary_Exchange_Country__c != mapOldAcc.get(acc.Id).Primary_Exchange_Country__c) {
                    if(String.isNotBlank(acc.Primary_Exchange_Country__c)){
                        if(!GS_CommonUtility.isValidCountry(acc.Primary_Exchange_Country__c)) {
                            acc.Primary_Exchange_Country__c.addError(Label.Msg_Invalid_Country);
                        }
                    }
                }
            }
        }
    }

    // Check only system administrater and operations user can delete account
    private void checkDelOperator() {

        Set<String> profilesName = new Set<String>();
        profilesName.add(GS_GlobalVariables.SYSTEMADMIN);

        if(GS_CommonUtility.getProfileMapByName(profilesName).get(UserInfo.getProfileId()) == NULL) {
            for(Account acc : (List<Account>)Trigger.old) {
                acc.addError(Label.Check_Account_Deleting_Operator);
            }
        }
    }
}