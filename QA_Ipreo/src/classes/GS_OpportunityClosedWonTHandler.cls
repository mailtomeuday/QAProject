/**************************************************************************************************
 * Name           : GS_OpportunityClosedWonTHandler
 * Object         : Opportunity/Opportunity Product/Asset/Asset License
 * Requirement    : STY-00170, STY-00172, STY-00178, STY-00251
 * Target         : When an opportunity is closed won verified,
 *                  the opportunity product should be converted to asset and asset license.
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-06-09
 * Modify History :
 * Updated by Ted 2015-06-12
 * Updated by Yang 2015-06-15
 **************************************************************************************************/
public class GS_OpportunityClosedWonTHandler implements GS_Triggers.Handler {

    public void handle() {
		boolean operationSuccessful = true;
        if (!GS_GlobalVariables.EXECUTED) {
            GS_GlobalVariables.EXECUTED = true;
            String uniqueAssetCheck;
            Set<Id> lstOpportunityId = new Set<Id>();
            Set<Id> lstToCloneOppId = new Set<Id>();
            List<OpportunityLineItem> lstOriginOpportunityLineItem;
            Set<Id> accountIdSet = new Set<Id>();
            Set<Id> productIdSet = new Set<Id>();

            Map<Id, Opportunity> newMapOpportunity = (Map<Id, Opportunity>)Trigger.newMap;
            Map<Id, Opportunity> oldMapOpportunity = (Map<Id, Opportunity>)Trigger.oldMap;
            Map<String, List<OpportunityLineItem>> oppLineItemMap = new Map<String, List<OpportunityLineItem>>();
            Map<Id, List<OpportunityLineItem>> mapAllOppLineItem = new Map<Id, List<OpportunityLineItem>>();
            Map<String, String> assetIdMap = new Map<String, String>();
            Map<Id, Opportunity> mapOppWithOriginId = new Map<Id, Opportunity>();
            // Get opportunies with renewal opportunities to check if there's a renewal opportunity exsits,
            // if yes, this opportunity should not be renewed one more time.
            Map<Id, Opportunity> mapCheckCloneOpp = new Map<Id, Opportunity>();

            system.debug('new map: ' + newMapOpportunity);
            system.debug('old map: ' + oldMapOpportunity);
            for (Id tempOppId : newMapOpportunity.keySet()) {
                if (   newMapOpportunity.get(tempOppId).StageName != oldMapOpportunity.get(tempOppId).StageName
                        && newMapOpportunity.get(tempOppId).StageName == 'Closed Won Verified') {
                    lstOpportunityId.add(tempOppId);
                    if (newMapOpportunity.get(tempOppId).No_of_Product_Add_Ons__c == 0) {
                        lstToCloneOppId.add(tempOppId);
                    }
                }
            }

            system.debug('close won opp: ' + lstOpportunityId);
            if (lstOpportunityId.size() > 0) {

                System.debug('*** : GS_OpportunityClosedWonTHandler fired.');
                // Get Opp line items which status in (Renewal, Won) and Revenue type in (ACV, ACV/TRANS)

				/* UB: Changing the query to avoid additional DML and Query for updating assets and WO on Opp Product(SPS-1430) */
                //lstOriginOpportunityLineItem = GS_OpportunityDMLHandler.getLineItemsToRenewAssetByIds(lstOpportunityId);
                lstOriginOpportunityLineItem = GS_OpportunityDMLHandler.getWonLineItemsByOppId(lstOpportunityId);

                system.debug('opp lineitems: ' + lstOriginOpportunityLineItem);
                if (lstOriginOpportunityLineItem.size() > 0) {
                    //generate the accountIdSet and productIdSet, as well as the oppLineItemMap for checking asset
                    for (OpportunityLineItem tempOppLineItem : lstOriginOpportunityLineItem) {
                        	/*UB: Assets to be created based on setup on Product for asset field (SPS-1430)*/
                        	if(tempOppLineItem.Product2.Asset__c == TRUE){
                        system.debug('opp lineitem: ' + tempOppLineItem);
                        accountIdSet.add(tempOppLineItem.Opportunity.AccountId);
                        productIdSet.add(tempOppLineItem.Product2Id);
                        uniqueAssetCheck = String.valueOf(tempOppLineItem.Opportunity.AccountId) + '_' + String.valueOf(tempOppLineItem.Product2Id) + '_' + tempOppLineItem.Product_Region__c;
                        system.debug('unique Asset Check '+ uniqueAssetCheck);
                        if (!oppLineItemMap.containsKey(uniqueAssetCheck))
                            oppLineItemMap.put(uniqueAssetCheck, new List<OpportunityLineItem> {tempOppLineItem});
                        else
                            oppLineItemMap.get(uniqueAssetCheck).add(tempOppLineItem);
                    }
                    }
                    system.debug('accountid set: ' + accountIdSet);
                    system.debug('productid set: ' + productIdSet);
                    system.debug('opplineitemmap: ' + oppLineItemMap);
                    //generate assetIdMap for checking asset

                    for (Asset ast : [SELECT Id, AccountProductRegionKey__c FROM Asset
                                      WHERE AccountId IN : accountIdSet
                                      AND Product2Id IN : productIdSet]) {
                        assetIdMap.put(ast.AccountProductRegionKey__c, String.valueOf(ast.Id));
                    }
                    system.debug('assetIdMap: ' + assetIdMap);
                    operationSuccessful = generateAssetwithLicenses(oppLineItemMap, assetIdMap);
                    if(!operationSuccessful)
                    	return;
                }

                // Get all Opp line items which status in (Renewal, Won), this opp line items are used to create work orders.
                for (OpportunityLineItem tempOppLineItem : lstOriginOpportunityLineItem) {
                //for (OpportunityLineItem tempOppLineItem : GS_OpportunityDMLHandler.getWonLineItemsByOppId(lstOpportunityId)) {
                    if (!mapAllOppLineItem.containsKey(tempOppLineItem.OpportunityId)) {
                        mapAllOppLineItem.put(tempOppLineItem.OpportunityId, new List<OpportunityLineItem> {tempOppLineItem});
                    } else {
                        mapAllOppLineItem.get(tempOppLineItem.OpportunityId).add(tempOppLineItem);
                    }
                }

                if (mapAllOppLineItem.size() > 0) {
                    operationSuccessful = generateWO(mapAllOppLineItem);
                    if(!operationSuccessful)
                    	return;
                }
				try{
					update lstOriginOpportunityLineItem;
				}	
				catch (Exception ex) {
            		processException(ex);
            		return;
        		}
                // Check lstToCloneOppId and remove the opportunity id which doesn't need to be cloned.
                mapCheckCloneOpp = new Map<Id, Opportunity>(GS_OpportunityDMLHandler.getOppsByIdWithRenewalOpps(lstToCloneOppId));
                
                for(Id tempOppId : lstToCloneOppId) {
                    if(!mapCheckCloneOpp.get(tempOppId).Opportunities__r.isEmpty()) {
                        lstToCloneOppId.remove(tempOppId);
                    }
                }

                // Clone Opportunity, query the opportunity to select fields except SyncedQuoteId
                String strSelectChild = ',Evergreen_Period__c, Contract__r.Evergreen__c, Account.Name, RecordType.Name, (select Id, Subscription_End_Date__c from OpportunityLineItems where Subscription_End_Date__c != null limit 1)';

                // Clone Opportunity and related items
                mapOppWithOriginId = cloneRenewalOppoWithOriginId(Database.query(getCreatableFieldsSOQLwithChild('Opportunity', strSelectChild, 'Id in : lstToCloneOppId')));
                if(mapOppWithOriginId == null)
            		return;
                if (mapOppWithOriginId.size() > 0) {
                    operationSuccessful = cloneRenewalOpportunityProducts(mapOppWithOriginId);
                    if(!operationSuccessful)
                    	return;
                    operationSuccessful = cloneOpportunityContactRoles(mapOppWithOriginId);
                    if(!operationSuccessful)
                    	return;
                    operationSuccessful = cloneOpportunityTeamMembers(mapOppWithOriginId);
                    if(!operationSuccessful)
                    	return;
                    operationSuccessful = cloneOpportunityPartners(mapOppWithOriginId);
                    if(!operationSuccessful)
                    	return;
                }
            }
        }
    }

    // Generate assets and licenses when the opportunity is close won verified
    private boolean generateAssetwithLicenses(Map<String, List<OpportunityLineItem>> oppLineItemMap, Map<String, String> assetIdMap) {
        List<Asset> newAssetList = new List<Asset>();
        List<Asset_License__c> newLicenseList = new List<Asset_License__c>();
        List<OpportunityLineItem> updateOppLineitems = new List<OpportunityLineItem>();
        Map<ID,OpportunityLineItem> mapProductLineItems;
        Map<ID,Asset_License__c> mapProductLicenses;
        Map<Id, List<Asset_License__c>> mapLicenseWithAssetId = new Map<Id, List<Asset_License__c>>();
        mapProductLineItems = new Map<ID, OpportunityLineItem>();
        mapProductLicenses = new Map<ID, Asset_License__c>();
        for (String accPrdId : oppLineItemMap.keySet()) {
            Asset ast = new Asset();
            if (!assetIdMap.containsKey(accPrdId)) {
                ast.Name = oppLineItemMap.get(accPrdId)[0].Opportunity.Account.Name + ' ' + oppLineItemMap.get(accPrdId)[0].Product2.Name + ' ' + (oppLineItemMap.get(accPrdId)[0].Product_Region__c != NULL ? oppLineItemMap.get(accPrdId)[0].Product_Region__c : '');
                if (ast.Name.length() > 255) {
                    ast.Name = ast.Name.left(255);
                }
                ast.AccountId = oppLineItemMap.get(accPrdId)[0].Opportunity.AccountId;
                ast.Product2Id = oppLineItemMap.get(accPrdId)[0].Product2Id;
                ast.Opportunity__c = oppLineItemMap.get(accPrdId)[0].OpportunityId;
                ast.Contract__c = oppLineItemMap.get(accPrdId)[0].Opportunity.Contract__c;
                ast.AccountProductRegionKey__c = accPrdId;
                ast.Status = 'Inactive';
                ast.Product_Region__c = oppLineItemMap.get(accPrdId)[0].Product_Region__c;
                newAssetList.add(ast);
            }
            
            for (OpportunityLineItem item : oppLineItemMap.get(accPrdId)) {
                Asset_License__c license = new Asset_License__c();
                license.Asset__r = new Asset (AccountProductRegionKey__c = accPrdId);
                license.Account__c = item.Opportunity.AccountId;
                license.Opportunity__c = item.OpportunityId;
                license.Contract__c = item.Opportunity.Contract__c;
                license.Start_Date__c = item.Subscription_Start_Date__c;
                license.End_Date__c = item.Subscription_End_Date__c;
                license.No_of_Seats__c = item.No_of_Users__c;
                if(String.isBlank(item.License__c)){
                    newLicenseList.add(license);
                    mapProductLicenses.put(item.Id, license);                    
                }
                if (String.isBlank(item.Asset__c)) {
                    item.Asset__r = new Asset (AccountProductRegionKey__c = accPrdId);
                }
                updateOppLineitems.add(item);
                mapProductLineItems.put(item.ID, item);
            }
        }
        system.debug('mapProductLineItems : ' + mapProductLineItems);
        system.debug('mapProductLicenses : ' + mapProductLicenses);
        system.debug('asset list: ' + newAssetList);
        system.debug('license list: ' + newLicenseList);
        try {
            List<SObject> objectList = new List<SObject>();
            objectList.addAll((List<SObject>)newAssetList);
            objectList.addAll((List<SObject>)newLicenseList);
            insert objectList;

            /*
            for (Integer i = 0; i < newLicenseList.size(); i++) {
                updateOppLineitems[i].License__c = newLicenseList[i].Id;
            }*/
            for(ID LineItemId : mapProductLicenses.keySet()){
                OpportunityLineItem oli = mapProductLineItems.get(LineItemId);
                Asset_License__c assetLicense = mapProductLicenses.get(LineItemId);
                if(oli != null && assetLicense != null){
                    oli.License__c = assetLicense.id;
                }
            }
            return true;
         /* UB: Commenting update as this statement moved to top (SPS-1430) */
           //update updateOppLineitems;
        } catch (Exception ex) {
            processException(ex);
            return false;
        }
    }

    // Generate work order when the opportunity is close won verified
    private boolean generateWO(Map<Id, List<OpportunityLineItem>> oppLineItemMap) {

        System.debug(LoggingLevel.INFO, '*** : generateWO is executed.');

		RecordType rtRenewal = GS_RecordTypeUtility.getRecordType(GS_GlobalVariables.OPPRTRENEWAL, 'Opportunity');
        // Map WO with opportunityId, the key is related opportunity id not WO id
        Map<Id, List<Work_Order__c>> mapWOWithOppId = new Map<Id, List<Work_Order__c>>();
        // key is queue name and value is queue id, used to assign queue to work order
        Map<String, Id> mapQueue = new Map<String, Id>();
        // Get all opplineItems for product.Work_Order_Queue__c
        List<OpportunityLineItem> lstOppLineItems = new List<OpportunityLineItem>();
        // Get all record types by object name, Key is RecordType Name and Id is recordtype id
        Map<String, Id> mapRTNamesWithId = new Map<String, Id>();

        List<Work_Order__c> lstTargetWO = new List<Work_Order__c>();
        List<OpportunityLineItem> lstTargetOppLineItems = new List<OpportunityLineItem>();

        for(Id tempId : oppLineItemMap.keySet()) {
            for ( Integer i = oppLineItemMap.get(tempId).size() - 1; i >= 0; i-- ){
                    if(String.isBlank(oppLineItemMap.get(tempId)[i].Product2.Work_Order_Type_Default__c)) {
                        oppLineItemMap.get(tempId).remove(i);
                    }
                }
        }

        for(Id tempId : oppLineItemMap.keySet()) {
            for(OpportunityLineItem tempItem : oppLineItemMap.get(tempId)) {
                lstOppLineItems.add(tempItem);
            }
        }

        mapQueue = GS_WorkOrderDMLHandler.getWOQueueNameWithQueueId(lstOppLineItems);
        mapRTNamesWithId = GS_RecordTypeUtility.getRecordTypeNamesWithId('Work_Order__c');

        for (Work_Order__c tempWO : GS_WorkOrderDMLHandler.getWorkOrdersByOpportunityId(oppLineItemMap.keySet())) {
            if (!mapWOWithOppId.containsKey(tempWO.Opportunity__c)) {
                mapWOWithOppId.put(tempWO.Opportunity__c, new List<Work_Order__c> {tempWO});
            } else {
                mapWOWithOppId.get(tempWO.Opportunity__c).add(tempWO);
            }
        }

        for (Id oppId : oppLineItemMap.keySet()) {
            for (OpportunityLineItem tempOppLineItem : oppLineItemMap.get(oppId)) {

                Boolean productExists = false;
                if (mapWOWithOppId.get(oppId) != null) {
                    for (Work_Order__c checkWO : mapWOWithOppId.get(oppId)) {
                        if (String.isNotBlank(tempOppLineItem.Work_Order__c)) {
                            productExists = true;
                            break;
                        }
                    }
                }
                if (productExists || (!tempOppLineItem.product2.Work_Order_on_Renewal__c && tempOppLineItem.Opportunity.recordTypeId == rtRenewal.id) ) {
                    continue;
                }

                // Create a new work order which is the work order of the opportunity product in current loop
                Work_Order__c tempWO = new Work_Order__c();

                if(mapQueue.containsKey(tempOppLineItem.Product2.Work_Order_Queue__c)) {
                    tempWO.OwnerId = mapQueue.get(tempOppLineItem.Product2.Work_Order_Queue__c);
                }

                if(String.isNotEmpty(tempOppLineItem.Product2.Work_Order_Type_Default__c)){
                    if(mapRTNamesWithId.containsKey(tempOppLineItem.Product2.Work_Order_Type_Default__c)) {
                        tempWO.RecordTypeId = mapRTNamesWithId.get(tempOppLineItem.Product2.Work_Order_Type_Default__c);
                    }
                }
                tempWO.Opportunity__c = tempOppLineItem.OpportunityId;
                tempWO.Account__c = tempOppLineItem.Opportunity.AccountId;
                tempWO.Product__c = tempOppLineItem.Product2Id;
                tempWO.Contract__c = tempOppLineItem.Opportunity.Contract__c;
                tempWO.ACpV__c = tempOppLineItem.ACpV__c;
                tempWO.Prior_Year_ACpV__c = tempOppLineItem.Prior_Year_ACpV__c;
                tempWO.Prior_Year_Pass_Through__c = tempOppLineItem.Prior_Year_Pass_Through__c;
                tempWO.TCpV__c = tempOppLineItem.UnitPrice;
                tempWO.Annual_Pass_Through__c = tempOppLineItem.Annual_Pass_Through__c;
                tempWO.Est_Annual_Transaction_Fees__c = tempOppLineItem.Estimated_Annual_Fees__c;
                tempWO.Term_Months__c = tempOppLineItem.Term_Months__c;
                tempWO.Product_Vertical__c = tempOppLineItem.Product_Vertical__c;
                tempWO.Product_Region__c = tempOppLineItem.Product_Region__c;
                tempWO.Referral_Partner__c = tempOppLineItem.Referral_Partner__c;
                tempWO.Sales_Rep__c = tempOppLineItem.Opportunity.OwnerId;
                tempWO.Product_Revenue_Type__c = tempOppLineItem.Product_Revenue_Type__c;
                tempWO.Net_New_Business__c = tempOppLineItem.Net_New_Business__c;
                tempWO.Subscription_Start_Date__c = tempOppLineItem.Subscription_Start_Date__c;
                tempWO.Subscription_End_Date__c = tempOppLineItem.Subscription_End_Date__c;
                tempWO.Product_Transaction_Type__c = tempOppLineItem.Product_Transaction_Type__c;
                tempWO.Dataset__c = tempOppLineItem.Dataset__c;
                tempWO.Site_License__c = tempOppLineItem.Site_License__c;
                tempWO.Data_Region__c = tempOppLineItem.Data_Region__c;
                tempWO.No_of_Users__c = tempOppLineItem.No_of_Users__c;
                tempWO.Est_Completion_Date__c = tempOppLineItem.Estimated_Completion_Date__c;
                tempWO.Opportunity_Product_Est_Completion_Date__c = tempOppLineItem.Estimated_Completion_Date__c;
                tempWO.Est_Start_Date__c = tempOppLineItem.Est_Start_Date__c;
                tempWO.Expense_Cap__c = tempOppLineItem.Expense_Cap__c;
                tempWO.Free_Period_months__c = tempOppLineItem.Free_Period_months__c;
                tempWO.Upfront_Expense_Fee__c = tempOppLineItem.Upfront_Expense_Fee__c;
                tempWO.CurrencyIsoCode = tempOppLineItem.CurrencyIsoCode;
                tempWO.Product_Comments__c = tempOppLineItem.Description;
                tempWO.Debt_Issue_Size__c = tempOppLineItem.Debt_Issue_Size__c;
                tempWO.No_of_Calls__c = tempOppLineItem.No_of_Calls__c;
                tempWO.No_of_Deals__c = tempOppLineItem.No_of_Deals__c;
                tempWO.No_of_Meetings__c = tempOppLineItem.No_of_Meetings__c;
                tempWO.No_of_Conferences__c = tempOppLineItem.No_of_Conferences__c;
                tempWO.No_of_Questions__c = tempOppLineItem.No_of_Questions__c;
                tempWO.No_of_Reports__c = tempOppLineItem.No_of_Reports__c;
                if(tempOppLineItem.Status__c != 'Renewed'){
                    tempWO.Requires_Implementation_UAT__c = tempOppLineItem.Requires_Implementation_UAT__c;
                }
                // Use blank instead of null
                String strExpCompletionDate = tempWO.Est_Completion_Date__c != NULL ? (' - ' + String.valueOf(tempWO.Est_Completion_Date__c)) : '';
                String strProductRegion = tempWO.Product_Region__c != NULL ? (' - ' + tempWO.Product_Region__c) : '';

                tempWO.Name = tempOppLineItem.Opportunity.Account.Name
                              + ' - '
                              + tempOppLineItem.Product2.Name
                              + strExpCompletionDate
                              + strProductRegion;
                // Name max length is 80
                if (tempWO.Name.length() > 80) {
                    tempWO.Name = tempWO.Name.left(80);
                }

                lstTargetOppLineItems.add(tempOppLineItem);
                lstTargetWO.add(tempWO);
            }
        }
        try {

            System.debug(LoggingLevel.INFO, '*** lstTargetWO: ' + lstTargetWO);
            insert lstTargetWO;

            for (Integer i = 0; i < lstTargetWO.size(); i++) {
                lstTargetOppLineItems[i].Work_Order__c = lstTargetWO[i].Id;
            }
            return true;
            /* UB: Commenting update as this statement moved to top(SPS-1430) */
            //update lstTargetOppLineItems;
        } catch (Exception ex) {
            System.debug(LoggingLevel.INFO, '*** ex.getMessage(): ' + ex.getMessage());
            processException(ex);
            return false;
        }
    }

    // Clone Renewal Opportunity and return a map with original Opportunities ID
    private Map<Id, Opportunity> cloneRenewalOppoWithOriginId(List<Opportunity> lstOpportunity ) {

        System.debug(LoggingLevel.INFO, '*** : Method cloneRenewalOpportunity is executed.');
        System.debug(LoggingLevel.INFO, '*** lstOpportunity: ' + lstOpportunity);

        if (lstOpportunity.size() == 0) {
            return new Map<Id, Opportunity>();
        }

        String strSeparator = ' - ';

        Map<Id, Opportunity> mapOppWithOriginId = new Map<Id, Opportunity>();

        List<Opportunity> lstClonedOpportunity = lstOpportunity.deepClone(true);

        // Index of lstOpportunity to get readonly value which can not be cloned for lstClonedOpportunity.
        Integer oppCounter = 0;
        for (Opportunity tempOpportunity : lstClonedOpportunity) {
            Date tempSubscriptionEndDate = null;

            // Check the "Announce Deal" value, this field was assigned value by workflow.
            // but the condition Deal Announcement Sent is assigned value in workflow and the workflow executes after this trigger.
            // so this field has to be assigned value here before the workflow which is used to sent announcement email.
            if( tempOpportunity.Announce_Deal__c) {
                tempOpportunity.Announce_Deal__c = true;
            }else if(tempOpportunity.Deal_Announcement_Sent__c == NULL) {
                tempOpportunity.Announce_Deal__c = FALSE;
            } else if(!tempOpportunity.Confidential_Announcement__c){
                tempOpportunity.Announce_Deal__c = TRUE;
            }
            
            tempOpportunity.RecordTypeId = (GS_RecordTypeUtility.getRecordType('Renewal', 'Opportunity')).Id;

            System.debug(LoggingLevel.INFO, '*** tempOpportunity: ' +tempOpportunity);
            System.debug(LoggingLevel.INFO, '*** tempOpportunity.RecordTypeId: ' +tempOpportunity.RecordTypeId);
            System.debug(LoggingLevel.INFO, '*** tempOpportunity.OpportunityLineItems: ' + tempOpportunity.OpportunityLineItems);
            
            for(OpportunityLineItem tempLineItem : tempOpportunity.OpportunityLineItems){
                if( tempLineItem.Subscription_End_Date__c != NULL) {
                    tempSubscriptionEndDate = tempLineItem.Subscription_End_Date__c;
                }
            }

            if (tempSubscriptionEndDate != NULL) {

                tempOpportunity.CloseDate = tempSubscriptionEndDate.addDays(1);
                tempOpportunity.Renewal_Date__c = tempSubscriptionEndDate.addDays(1);

                if ( String.isNotBlank(lstOpportunity[oppCounter].Evergreen_Period__c)) {
                    tempOpportunity.Evergreen_Date__c = tempSubscriptionEndDate.addDays(Integer.valueOf(lstOpportunity[oppCounter].Evergreen_Period__c) * (-1));
                } else {
                    tempOpportunity.Evergreen_Date__c = tempSubscriptionEndDate;
                }
            } else {
                tempOpportunity.Evergreen_Date__c = NULL;
                if (String.isNotBlank(tempOpportunity.Renewal_Increment__c)) {
                    if (tempOpportunity.Renewal_Increment__c.contains('months')) {
                        tempOpportunity.CloseDate = tempOpportunity.CloseDate.addMonths(Integer.valueOf(tempOpportunity.Renewal_Increment__c.left(1)));
                    } else if (tempOpportunity.Renewal_Increment__c.contains('year')) {
                        tempOpportunity.CloseDate = tempOpportunity.CloseDate.addYears(Integer.valueOf(tempOpportunity.Renewal_Increment__c.left(1)));
                    }
                }
            }

            tempOpportunity.Renewal_Status__c = NULL;
            tempOpportunity.Revenue_Delta_Type__c = NULL;
            tempOpportunity.StageName = 'Opportunity Identified';
            tempOpportunity.ForecastCategoryName = 'Projected';
            tempOpportunity.Probability = 10;
            tempOpportunity.Original_Opportunity__c = tempOpportunity.Id;
            tempOpportunity.Bundled_With__c = NULL;
            tempOpportunity.Key_Win__c = false;
            //SPS-1625: Dont copy Commit and At Risk  to renewal
            tempOpportunity.Commit__c = false;
            tempOpportunity.At_Risk__c = false;
            tempOpportunity.Id = NULL;
            tempOpportunity.Lead_Created_By__c = NULL;
            tempOpportunity.LeadSource = NULL;
            /* SPS-1273 Copy TSX Tier from Account instead of Opportunity */
            tempOpportunity.TSX_Tier__c = tempOpportunity.Account.TSX_Tier__c;
            /*Modified by Ted, dont need to clone oppunique key, only for migration*/
            tempOpportunity.OppUniqueKey__c = NULL;
            System.debug(LoggingLevel.INFO, '*** tempOpportunity.Deal_Announcement_Sent__c: ' + tempOpportunity.Deal_Announcement_Sent__c);
            tempOpportunity.Deal_Announcement_Sent__c = NULL;
            tempOpportunity.Deal_Announcement_Kudos__c = NULL;
            tempOpportunity.Verified_Date__c = NULL;
            /*SPS-1774, Do not copy est.completion date and cancel reason to renewal Opportunity*/
            tempOpportunity.Estimated_Completion_Date__c = NULL;
            tempOpportunity.Cancel_Reason__c = NULL;
            //SPS-1580: Don't copy Invoice Unpaid field to renewal
            tempOpportunity.Invoice_Unpaid__c = false;
            //SPS-1575: Don't copy In Budgetfield to renewal
            tempOpportunity.In_Budget__c = false;
            if(tempOpportunity.NYSE_Program_Tier__c == GS_GlobalVariables.NYSEPROGRAMTIERA) {
                tempOpportunity.NYSE_Program_Tier__c = '';
            }
            tempOpportunity.Sales_Ops_Owner__c = NULL;
            if(String.isNotBlank(tempOpportunity.Contract__c)) {
                if(tempOpportunity.Contract__r.Evergreen__c=='No') {
                    tempOpportunity.Contract__c = NULL;
                    //SPS-1543: Evergreen Renewal Date should not be populated when Contract is not Evergreen
                    tempOpportunity.Evergreen_Date__c = NULL;
                }
            }
            tempOpportunity.Name = tempOpportunity.Account.Name +
                                   (String.isNotBlank(tempOpportunity.Product_Bundle__c) ? (strSeparator + tempOpportunity.Product_Bundle__c) : '') +
                                   strSeparator +
                                   GS_GlobalVariables.OPPRTRENEWAL +
                                   (tempOpportunity.CloseDate != NULL ? (strSeparator + String.valueOf(tempOpportunity.CloseDate.year())) : '');
            if (tempOpportunity.Name.length() > 120) {
                    tempOpportunity.Name = tempOpportunity.Name.left(120);
            }
            oppCounter ++;
        }

        try {
            // Create cloned opportunity
            if (lstClonedOpportunity.size() > 0) {
                insert lstClonedOpportunity;
            }

            for (Opportunity tempOpportunity : lstClonedOpportunity) {
                mapOppWithOriginId.put(tempOpportunity.Original_Opportunity__c, tempOpportunity);
            }

            return mapOppWithOriginId;

        } catch (Exception ex) {
            system.debug(ex);
            processException(ex);
            return null;
        }
    }

    // Clone opportunity product and add them to renewal opportunity
    private boolean cloneRenewalOpportunityProducts(Map<Id, Opportunity> mapOppWithOriginId) {

        System.debug(LoggingLevel.INFO, '*** : Method cloneRenewalOpportunityProducts is executed.');
        System.debug(LoggingLevel.INFO, '*** mapOppWithOriginId: ' + mapOppWithOriginId);

        List<OpportunityLineItem> lstOriginOppLineItem;
        List<OpportunityLineItem> lstTargetOppLineItem;

        lstOriginOppLineItem = GS_OpportunityDMLHandler.getWonLineItemsByOppId(mapOppWithOriginId.keySet());

        System.debug(LoggingLevel.INFO, '*** lstOriginOppLineItem: ' + lstOriginOppLineItem);

        lstTargetOppLineItem = lstOriginOppLineItem.deepClone();

        for (OpportunityLineItem tempLineItem : lstTargetOppLineItem) {

            tempLineItem.Product_Transaction_Type__c = 'Renewal';
            tempLineItem.Status__c = NULL;
            tempLineItem.Lost_Cancelled_Reason__c = NULL;
            //SPS-1273, Copy Levered Sales from Opportunity Product to Renewal Opportunity Product
            //tempLineItem.Referral_Partner__c = NULL;
            tempLineItem.Requires_Implementation_UAT__c = NULL;
            //SPS-1143: Set Term and Free Period to blank on Renewal Opportunity
            tempLineItem.Term_Months__c = NULL;
            tempLineItem.Free_Period_months__c = NULL;
            //SPS-1573 - do not copy Product Lost Amount (Total) and 
            //Product Lost Amount (Annual) to Renewal Opportunity Product
            tempLineItem.Product_Lost_Amount_Annual__c = NULL;
            tempLineItem.Product_Lost_Amount_Total__c = NULL;

            if (tempLineItem.Subscription_End_Date__c != NULL) {
                tempLineItem.Subscription_Start_Date__c = tempLineItem.Subscription_End_Date__c.addDays(1);
                if (String.isNotBlank(tempLineItem.Opportunity.Renewal_Increment__c)) {
                    if (tempLineItem.Opportunity.Renewal_Increment__c.contains('months')) {
                        tempLineItem.Subscription_End_Date__c = tempLineItem.Subscription_End_Date__c.addMonths(Integer.valueOf(tempLineItem.Opportunity.Renewal_Increment__c.left(1)));
                    } else if (tempLineItem.Opportunity.Renewal_Increment__c.contains('year')) {
                        tempLineItem.Subscription_End_Date__c = tempLineItem.Subscription_End_Date__c.addYears(Integer.valueOf(tempLineItem.Opportunity.Renewal_Increment__c.left(1)));
                    }
                }
            }
            
            //SPS-1177: Don't copy Est. Completion Date to Renewal Opp Prod for ACV and ACV/Trans Product Revenue Types
            if(tempLineItem.Product_Revenue_Type__c == 'ACV' || 
                tempLineItem.Product_Revenue_Type__c == 'ACV/TRANS')
            {
                tempLineItem.Estimated_Completion_Date__c = NULL;
            }  
            
            if(tempLineItem.Estimated_Completion_Date__c != NULL) {
                if (String.isNotBlank(tempLineItem.Opportunity.Renewal_Increment__c)) {
                    if (tempLineItem.Opportunity.Renewal_Increment__c.contains('months')) {
                        tempLineItem.Estimated_Completion_Date__c = tempLineItem.Estimated_Completion_Date__c.addMonths(Integer.valueOf(tempLineItem.Opportunity.Renewal_Increment__c.left(1)));
                    } else if (tempLineItem.Opportunity.Renewal_Increment__c.contains('year')) {
                        tempLineItem.Estimated_Completion_Date__c = tempLineItem.Estimated_Completion_Date__c.addYears(Integer.valueOf(tempLineItem.Opportunity.Renewal_Increment__c.left(1)));
                    }
                }
            }

            tempLineItem.Prior_Year_ACpV__c = tempLineItem.ACpV__c;

            if(tempLineItem.UnitPrice != NULL && tempLineItem.Renewal_Increase__c != NULL){
                tempLineItem.UnitPrice = tempLineItem.UnitPrice*(1 + tempLineItem.Renewal_Increase__c/100);
            }

            if(tempLineItem.ACpV__c != NULL && tempLineItem.Renewal_Increase__c != NULL){
                tempLineItem.ACpV__c = tempLineItem.ACpV__c*(1 + tempLineItem.Renewal_Increase__c/100);
            }

            tempLineItem.Prior_Year_Pass_Through__c = tempLineItem.Annual_Pass_Through__c;
            System.debug(LoggingLevel.INFO, '*** mapOppWithOriginId.get(tempLineItem.OpportunityId).Id: ' + mapOppWithOriginId.get(tempLineItem.OpportunityId).Id);
            tempLineItem.OpportunityId = mapOppWithOriginId.get(tempLineItem.OpportunityId).Id;
            tempLineItem.Work_Order__c = NULL;
            tempLineItem.License__c = NULL;
        }
        try {
            insert lstTargetOppLineItem;
            return true;
        } catch (Exception ex) {
            system.debug(ex);
            processException(ex);
            return false;
        }
    }

    private boolean cloneOpportunityTeamMembers(Map<Id, Opportunity> mapOppWithOriginId) {
        System.debug(LoggingLevel.INFO, '*** : cloneOpportunityTeamMembers is executed.');
        List<OpportunityTeamMember> lstOriginOppTeamMember;
        List<OpportunityTeamMember> lstTargetOppTeamMember;

        lstOriginOppTeamMember = GS_OpportunityDMLHandler.getTeamMembersByOppId(mapOppWithOriginId.keySet());
        lstTargetOppTeamMember = lstOriginOppTeamMember.deepClone();

        for (OpportunityTeamMember tempOpporTeamMember : lstTargetOppTeamMember) {
            tempOpporTeamMember.OpportunityId = (mapOppWithOriginId.get(tempOpporTeamMember.OpportunityId)).Id;
        }

        try {
            System.debug(LoggingLevel.INFO, '*** cloneOpportunityTeamMembers.lstTargetOppTeamMember: ' + lstTargetOppTeamMember);
            insert lstTargetOppTeamMember;
            return true;
        } catch (Exception ex) {
            System.debug(LoggingLevel.Error, '*** ex.getMessage(): ' + ex.getMessage());
            processException(ex);
            return false;
        }

    }

    private boolean cloneOpportunityContactRoles(Map<Id, Opportunity> mapOppWithOriginId) {
        System.debug(LoggingLevel.INFO, '*** : cloneOpportunityContactRoles');
        List<OpportunityContactRole> lstOriginOppContactRole;
        List<OpportunityContactRole> lstTargetOppContactRole;

        lstOriginOppContactRole = GS_OpportunityDMLHandler.getOppContactRoleByOppId(mapOppWithOriginId.keySet());
        lstTargetOppContactRole = lstOriginOppContactRole.deepClone();

        for (OpportunityContactRole tempOpporContactRole : lstTargetOppContactRole) {
            tempOpporContactRole.OpportunityId = (mapOppWithOriginId.get(tempOpporContactRole.OpportunityId)).Id;
        }

        try {
            insert lstTargetOppContactRole;
            return true;
        } catch (Exception ex) {
            system.debug(ex);
            processException(ex);
            return false;
        }

    }

    // Clone partners to the renewal opportunity
    private boolean cloneOpportunityPartners(Map<Id, Opportunity> mapOppWithOriginId) {
        System.debug(LoggingLevel.INFO, '*** : cloneOpportunityPartners');
        List<Partner> lstOriginOppPartner;
        List<Partner> lstTargetOppPartner = new List<Partner>();

        lstOriginOppPartner = GS_PartnerDmlHandler.getPartnersByOppId(mapOppWithOriginId.keySet());

        for (Partner tempOppPartner : lstOriginOppPartner) {
            if (tempOppPartner.AccountToId != (mapOppWithOriginId.get(tempOppPartner.OpportunityId)).AccountId) {
                Partner newPR = tempOppPartner.clone(false);
                newPR.OpportunityId = (mapOppWithOriginId.get(tempOppPartner.OpportunityId)).Id;
                newPR.AccountFromId = null;
                lstTargetOppPartner.add(newPR);
            }
        }

        try {
            insert lstTargetOppPartner;
            return true;
        } catch (Exception ex) {
            system.debug(ex);
            processException(ex);
            return false;
        }

    }

    // Get Opp Fields without QuoteSync, with a child record.
    private static string getCreatableFieldsSOQLwithChild(String objectName, String selectChild, String whereClause) {

        String selects = '';

        if (whereClause == null || whereClause == '') { return null; }

        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();

        if (fMap != null) {
            for (Schema.SObjectField ft : fMap.values()) { // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)

                if (fd.isCreateable() && fd.getName() != 'SyncedQuoteId') { // field is creatable and remove 'SyncedQuoteId' since this field is readonly in trigger
                    selectFields.add(fd.getName());
                }
            }
        }

        if (!selectFields.isEmpty()) {
            for (string s : selectFields) {
                selects += s + ',';
            }
            if (selects.endsWith(',')) {selects = selects.substring(0, selects.lastIndexOf(','));}

        }
        System.debug(LoggingLevel.INFO, '*** Query String: ' + 'SELECT ' + selects + selectChild + ' FROM ' + objectName + ' WHERE ' + whereClause);
        return 'SELECT ' + selects + selectChild + ' FROM ' + objectName + ' WHERE ' + whereClause;

    }
    public void processException(Exception ex){
            String errorMessage = '';
            if(ex.getTypeName() == 'System.DmlException'){
                Set<String> errorMessages = new Set<String>();
                for (Integer i = 0; i < ex.getNumDml(); i++) {
                    errorMessages.add(ex.getDmlMessage(i));
                }   
                Integer i = 0;          
                for(String message: errorMessages){
                        errorMessage += message+(i == errorMessages.size()-1 ? '' : '<br/>');
                        i = i+1;
                }
            }
            else{
                errorMessage = 'Internal System Error.';    
            }
        
            for(ID oppId : Trigger.newMap.keySet()){
                    Opportunity opp = (Opportunity)Trigger.newMap.get(oppId);
                    opp.addError('Errors while saving related records: '+errorMessage+'<br/>Please contact your System administrator.<br/>',false);
                }        
    }
}