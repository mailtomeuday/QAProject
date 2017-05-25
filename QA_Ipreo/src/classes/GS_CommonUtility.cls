/**************************************************************************************************
 * Name           : GS_CommonUtility
 * Object         :
 * Requirement    :
 * Target         : A common utility class
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-08-19
 * Modify History :
 **************************************************************************************************/
public class GS_CommonUtility {

	// Check object name by prefix of id
	public static String getObjectNameById(String recordIdOrPrefix) {
		String objectName = '';
		try {
			//Get prefix from record ID
			//This assumes that you have passed at least 3 characters
			String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0, 3);

			//Get schema information
			Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe();

			//Loop through all the sObject types returned by Schema
			for (Schema.SObjectType stype : gd.values()) {
				Schema.DescribeSObjectResult r = stype.getDescribe();
				String prefix = r.getKeyPrefix();
				System.debug('Prefix is ' + prefix);

				//Check if the prefix matches with requested prefix
				if (prefix != null && prefix.equals(myIdPrefix)) {
					objectName = r.getName();
					System.debug('Object Name! ' + objectName);
					break;
				}
			}
		} catch (Exception e) {
			System.debug(e);
		}
		return objectName;
	}

	// Get Schema.DescribeSObjectResult by Object Api Name
	public static Schema.DescribeSObjectResult getDescribeSObjectResult(String objectApiName) {

		//Get schema information
		Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe();
		Schema.DescribeSObjectResult gdr;
		if (gd.get(objectApiName) != NULL) {
			return gd.get(objectApiName).getDescribe();
		} else {
			return null;
		}
	}

	// Check if the object and id is corresponding
	public static Boolean isObjectAndIdCorresponding (String objectApiName, String recordId) {
		Schema.DescribeSObjectResult gd = getDescribeSObjectResult(objectApiName);

		if (recordId == NULL) {
			return false;
		} else if (recordId.length() < 3) {
			return false;
		}

		if (gd != NULL) {
			if (gd.getKeyPrefix() == String.valueOf(recordId).substring(0, 3)) {
				return true;
			} else {
				return false;
			}
		} else {
			return false;
		}
	}

	// Check if the object and id is corresponding
	public static String getPrefixByObjectName (String objectApiName) {
		Schema.DescribeSObjectResult dsr = getDescribeSObjectResult(objectApiName);
		if (dsr != NULL) {
			return dsr.getKeyPrefix();
		} else {
			return '';
		}
	}

	// Return true if the input field is a relationship field in email template
	public static Boolean isRelationMergeField (String objectApiName, String objectField) {
		Schema.DescribeSObjectResult dsr = GS_CommonUtility.getDescribeSObjectResult(objectApiName);
		Map<String, Schema.SObjectField> mapSF = dsr.fields.getMap();

		for (String name : mapSF.keySet()) {
			Schema.DescribeFieldResult dfr = mapSF.get(name).getDescribe();
			if (dfr.getRelationshipName() == objectField) {
				return true;
			} else if (dfr.getName() ==  objectField) {
				if(dfr.getRelationshipName() != NULL){
					return true;
				} else {
					return false;
				}
			} else {
				return false;
			}
		}

		return false;
	}

	// Return a relationship object's name field by the input relationship merge field from email templates
	// If no result, return '';
	public static String getNameFieldByRelationMergeField (String objectApiName, String objectField) {
		Schema.DescribeSObjectResult dsr = GS_CommonUtility.getDescribeSObjectResult(objectApiName);
		Map<String, Schema.SObjectField> mapSF = dsr.fields.getMap();

		for (String name : mapSF.keySet()) {
			Schema.DescribeFieldResult dfr = mapSF.get(name).getDescribe();
			if (dfr.getRelationshipName() == objectField) {
				return dfr.getRelationshipName() + '.Name';
			} else if (dfr.getName() ==  objectField) {
				if(dfr.getRelationshipName() != NULL){
					return dfr.getRelationshipName() + '.Name';
				}
			}
		}

		return '';
	}

	// Check if the role is the specific role or its subordinates
	public static Boolean isRoleAndSubordinates(Map<Id, UserRole> roleRange, Id targetRoleId, Id currentRoleId) {
		System.debug(LoggingLevel.INFO, '*** currentRoleId: ' + currentRoleId);
		if(currentRoleId == null) {
			return false;
		}
		if(currentRoleId == targetRoleId){
			return true;
		}else if(roleRange.get(currentRoleId).ParentRoleId != NULL) {
			currentRoleId = roleRange.get(currentRoleId).ParentRoleId;
			return isRoleAndSubordinates(roleRange, targetRoleId, currentRoleId);
		}else {
			return false;
		}
	}

	// Check if the user has permission to input records
	public static List<UserRecordAccess> getRecordAccesses(Id userId, List<Id> recordIds) {
		return [SELECT RecordId
					  ,HasEditAccess
					  ,HasDeleteAccess
					  ,HasReadAccess
				FROM UserRecordAccess
				WHERE UserId =: userId
				AND RecordId in: recordIds];
	}

	//Check email format
	public static Boolean isValidEmailFormat(String emailAddress) {
		String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
		Pattern patEmail = Pattern.compile(emailRegex);
		Matcher matEmail = patEmail.matcher(emailAddress);
		if (!matEmail.matches()) {
			return false;
		} else {
			return true;
		}
	}

	//Check valid country
	public static Boolean isValidCountry(String countryName) {
		if(Country_List__c.getValues(countryName) != NULL){
			return TRUE;
		} else {
			return FALSE;
		}
	}

	//Get Profile Maps for name and id
	public static Map<Id, Profile> getProfileMapByName(Set<String> profileNames) {

		Map<Id, Profile> mapProfileNameId = new Map<Id, Profile>();

		if(profileNames != null) {
			if(profileNames.size() > 0){
				mapProfileNameId = new Map<Id, Profile>([SELECT Id, Name from Profile where Name in: profileNames]);
			}
		}

		return mapProfileNameId;
	}
	//Get Product Bundle for Opp
	public static String getProductBundlerForOpp(Opportunity opportunity, Boolean checkProductStatus) {
		String strSeparator = '_';
		String productBundle = '';
		Integer j = 0;
		for(Integer i = 0; i < opportunity.OpportunityLineItems.size(); i++){
			if((opportunity.OpportunityLineItems[i].Status__c != GS_GlobalVariables.OPPLINEITEMSTATUSLOST && opportunity.OpportunityLineItems[i].Status__c != GS_GlobalVariables.OPPLINEITEMSTATUSCANCELLED) || !checkProductStatus){
    			if(j == 0) {
    				productBundle = opportunity.OpportunityLineItems[i].ProductCode;
    			} else if(String.isNotBlank(productBundle)){
    				productBundle += strSeparator + opportunity.OpportunityLineItems[i].ProductCode;
    			} else{
    				productBundle = opportunity.OpportunityLineItems[i].ProductCode;
    			}
    			j++;
    		}
		}
		return productBundle;
    }
		
	public static map<Id,string> getAccountProductBundle(List<ID> accountIds, List<Account> listOriginAccount) 
	{
		map<Id,string> accountProdBundleMap = new map<Id,string>();		
		set<String> productCodeSet;
		
		if(accountIds.size()> 0){
			//List<Account> listOriginAccount = GS_AccountDMLHandler.getAssetsWorkOrdersByAccount(accountIds);
			//listOriginAccount = GS_AccountDMLHandler.getAssetsWorkOrdersByAccount(accountIds);
			for (Account tempAccount : listOriginAccount) {
				productCodeSet = new set<String>();
				string productBundle = '';
				for (Asset tempAsset : tempAccount.Assets) {
					if (tempAsset.Status == 'Active') {
						productCodeSet.add(tempAsset.Product2.ProductCode);
					}
				}
				for(Work_Order__c tempWO : tempAccount.Work_Orders__r) {
                    if(tempWO.Active__c == true) {
                        productCodeSet.add(tempWO.Product__r.ProductCode);
                    }
                }	
				
				for(string productCode : productCodeSet){
					productBundle += productCode + '_' ;
				}
				
				if(!string.isBlank(productBundle)){
					productBundle = productBundle.subString(0, productBundle.length() - 1);
					productBundle = productBundle.left(255);
				}
				
				accountProdBundleMap.put(tempAccount.Id, productBundle);
			}
		} 
		
		return accountProdBundleMap;
	}

   /* Get Cancel reason(Cancel_Reason__c) for Opportunity.
   If all Opp.Products have same Cancel reason, Assign reason from First Product.
   If all Opp.Products do not have same cancel reason, Set Cancel reason as 'Multiple Reasons' */ 
   public static String getCancelReasonforOpp(Opportunity opportunity)
   {
	   	String cancelReason = '';
	   	Set<String> reasons = new Set<String>();
	   	for(OpportunityLineItem oli: opportunity.OpportunityLineItems)
	   	{
	   		if(oli.Lost_Cancelled_Reason__c == null)
	   		{
	   			cancelReason = '';
	   			return cancelReason;
	   		}
	   		reasons.add(oli.Lost_Cancelled_Reason__c);
	   	}
	   	if(reasons.size() > 0){
	   		if(reasons.size() > 1){
	   			cancelReason = 'Multiple Reasons';	
	   		}
	   		else
	   		{
	   			List<String> lstReasons = new List<String>();
	   			lstReasons.addAll(reasons);
	   			cancelReason = lstReasons[0];
	   		}
	   	}
	   	return cancelReason;
   }

   /* Calculate Estimated_Completion_Date__c for Opportunity.
   If all Opp.Products have same Estimated_Completion_Date__c, Assign Estimated_Completion_Date__c from First Product.
   If all Opp.Products do not have same Estimated_Completion_Date__c, Set Estimated_Completion_Date__c as BLANK */ 
   public static Date getEstCompletionDate(Opportunity opportunity)
   {
	   	Date estCompletionDate = null;
	   	Set<Date> setDates = new Set<Date>();
	   	for(OpportunityLineItem oli: opportunity.OpportunityLineItems)
	   	{
	   		if(oli.Status__c == 'Lost' || oli.Status__c == 'Cancelled')
	   		{
	   			continue;
	   		}
	   		if(oli.Estimated_Completion_Date__c == null)
	   		{
	   			estCompletionDate = null;
	   			return estCompletionDate;
	   		}
	   		setDates.add(oli.Estimated_Completion_Date__c);
	   	}
	   	if(setDates.size() == 1){
	   			List<Date> lstDates = new List<Date>();
	   			lstDates.addAll(setDates);
	   			estCompletionDate = lstDates[0];
	   	}
	   	return estCompletionDate;
   }   
}