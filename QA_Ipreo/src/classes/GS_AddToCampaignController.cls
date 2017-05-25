/**************************************************************************************************
 * Name           : GS_AddToCampaignController
 * Object         : Campaign
 * Requirement    : RQ-378
 * Target         : Create Entitlement for accounts
 * Refer classes  :
 * Author         : Terry Nong (terry.nong@cnsdc01.pwc.com)
 * Create Date    : 2015-11-17
 * Modify History :
                    2016-09-2016 Uday Bikkumalla : Changed ConfirmResults to Transient to avoid view state error
                    and new set ConfirmResultsSet
                    Removed CampaignMembersMap from instance variables and created local variable in addToCampaign() with name
                    'campaignMembersSet'
                    2017-02-06 Joshi: Added ability to filter OUT people with certain Assets (SPS-1502)
 **************************************************************************************************/
public with sharing class GS_AddToCampaignController {

    public final static Integer PAGESIZE = Integer.valueOf(System.Label.Page_Size);
    // returns a list of wrapper objects for the sObjects in the current page set
    List<UserAssetWrapper> userAssets {get;set;}
    
    /* SPS-1261 Changed to Transient */
    public transient List<User_Asset__c> ConfirmResults {get;set;}
    public Set<ID> ConfirmResultsSet {get;set;}

    public ApexPages.StandardSetController con {get;set;}

    public String campaignId {get;set;}

    public transient Map<String, CampaignMember> campaignMemberMap = new Map<String, CampaignMember>();
    
    public User_Asset__c userAsset {get;set;}

    public String accountFilter {get;set;}

    public String assetName {get;set;}

    public String contactBillingCountry {get;set;}

    public String billingCondition {get;set;}

    public String userStatus {get;set;}

    public String[] role {get;set;}
    
    public String assetType {get;set;}

    public String[] productRegion {get;set;}

    public String condition {get;set;}

    public Integer totalRecord {get;set;}

    public Boolean isVisiable {get;set;}

    public Boolean isVisiable4ResultSection {get;set;}

    public Campaign campaign {get;set;}

    public Set<String> accIdSet;

    // public Boolean outageNotification {get;set;}

    public String vertical {get;set;}

    public String[] selectedProducts {get;set;}

    public String[] excludedProducts {get;set;}
    
    public Set<String> excludeUsersSet;

    public List<SelectOption> productOptions {get;set;}

    public Integer productOptionsSize {get;set;}

    public Map<String, Set<String>> productsMap = new Map<String, Set<String>>();

    public String blockMessage {get;set;}

    
    public String notificationIndex {get;set;}

    public GS_AddToCampaignController() {

        isVisiable = false;
        isVisiable4ResultSection = false;
        userStatus = 'Active';
        userAsset = new User_Asset__c();
        accountFilter = '2';
        productOptions = new List<SelectOption>();
        productOptionsSize = 4;
        campaignId = ApexPages.currentPage().getParameters().get('id');
        campaign = [Select Id, Name From Campaign Where Id =: campaignId];
        preLoadProducts();
        /*for(CampaignMember c : [Select ContactId, CampaignId From CampaignMember Where CampaignId =: campaignId]) {
            campaignMembersSet.add(c.ContactId);
            campaignMemberMap.put(c.ContactId, c);
        }*/
        // String userId = UserInfo.getUserId();
        // List<AccountTeamMember> teamMembers = [Select Id, UserId, AccountId From AccountTeamMember Where UserId =: UserInfo.getUserId()];
        // accIdSet = new Set<String>();
        // for(AccountTeamMember t : [Select Id, UserId, AccountId From AccountTeamMember Where UserId =: UserInfo.getUserId()]) {
        //     accIdSet.add(t.AccountId);
        // }
        ConfirmResults = new List<User_Asset__c>();
        ConfirmResultsSet = new Set<ID>();
        if(con == null) {
            con = new ApexPages.StandardSetController(Database.getQueryLocator([Select Asset__r.Name, User__c, User__r.Name, User__r.Email, Asset_Account__r.Name FROM User_Asset__c Order By User__r.Name limit 1]));
            //Where Asset_Account__c IN: accIdSet
            // sets the number of records in each page set
            con.setPageSize(PAGESIZE);
        }
    }

    public PageReference doSearch() {
        if(verify()) {
            isVisiable = false;
            isVisiable4ResultSection = false;
            return null;
        }
        isVisiable = true;
        isVisiable4ResultSection = false;
        String soql = 'Select count() From User_Asset__c Where Name != Null';
        soql = buildQuery(soql);
        System.debug(LoggingLevel.INFO, '*** soql: ' + soql);
        totalRecord = Database.countQuery(soql);
        if(totalRecord < 9999) {
            blockMessage = totalRecord + ' Number of Records will be added to ' + campaign.Name + ' Campaign';
        }else {
            blockMessage = 'Showing 9999 records but there could be more. Please use a filter to narrow down the results.';
        }
        //put result into collection then use to generate campaign member
        ConfirmResults = new List<User_Asset__c>();
        ConfirmResultsSet = new Set<ID>();
        String query = 'Select User__c, User__r.Name FROM User_Asset__c Where Name != Null';
        query = buildQuery(query);
        query += ' Order By User__r.Name limit 9999 ';
        for(User_Asset__c c : (List<User_Asset__c>)Database.query(query)) {
            ConfirmResults.add(c);
            ConfirmResultsSet.add(c.User__c);
        }
        return null;
    }

    public PageReference viewResult() {
        isVisiable = true;
        isVisiable4ResultSection = true;
        
        String soql = 'Select Id, Name, User_Country__c, Role__c, Asset__r.Name, User__c, User__r.Name, User__r.Account.Name, Asset_Account__r.Name, '
            + ' User__r.User_Status__c, Product_Region__c, System_Outage_Notification_Opt_Out__c,Is_Sponsored_User__c '
            + ' FROM User_Asset__c Where Name != Null ';

        soql = buildQuery(soql);
        soql += ' Order By User__r.Name limit 9999 ';
        System.debug(LoggingLevel.INFO, '*** soql: ' + soql);
        con = new ApexPages.StandardSetController(Database.getQueryLocator(soql));
        // sets the number of records in each page set
        con.setPageSize(PAGESIZE);

        //put result into collection then use to generate campaign member
        ConfirmResults = new List<User_Asset__c>();
        ConfirmResultsSet = new Set<ID>();
        for(User_Asset__c c : (List<User_Asset__c>)Database.query(soql)) {
            ConfirmResults.add(c);
            ConfirmResultsSet.add(c.User__c);
        }
        System.debug(LoggingLevel.INFO, '*** ConfirmResults: ' + ConfirmResults);
        return null;
    }

    private String buildQuery(String soql) {
        if(accountFilter == '2') {
            accIdSet = new Set<String>();
            for(AccountTeamMember t : [Select Id, UserId, AccountId From AccountTeamMember Where UserId =: UserInfo.getUserId()]) {
                accIdSet.add(t.AccountId);
            }
            System.debug(LoggingLevel.INFO, '*** accIdSet: ' + accIdSet);
            soql += ' And Asset_Account__c IN: accIdSet ';
        }
        if(accountFilter == '3') {
            if(userAsset.Asset_Account__c != null) {
                soql += ' And Asset_Account__c =\'' + userAsset.Asset_Account__c + '\'';
            }else {
                soql += ' And Asset_Account__c = Null';
            }
        }
        if(condition == 'e') soql += ' And Asset__r.Name =\'' + assetName + '\'';

        if(condition == 'n') soql += ' And Asset__r.Name !=\'' + assetName + '\'';

        if(condition == 'c') soql += ' And Asset__r.Name Like \'%' + assetName + '%\'';

        if(billingCondition == 'e') soql += ' And User_Country__c =\'' + contactBillingCountry + '\'';

        if(billingCondition == 'n') soql += ' And User_Country__c !=\'' + contactBillingCountry + '\'';

        if(billingCondition == 'c') soql += ' And User_Country__c Like \'%' + contactBillingCountry + '%\'';

        if(userStatus == 'Active' || userStatus == 'Inactive') soql += ' And User__r.User_Status__c = \'' + userStatus + '\'';

        if(role != null && role.size() > 0) soql += ' And Role__c IN: role ';
        
        if(assetType == '2') soql += ' And Is_Sponsored_User__c = false';
        
        if(assetType == '3') soql += ' And Is_Sponsored_User__c = true';
        
        if(productRegion != null && productRegion.size() > 0) soql += ' And Product_Region__c IN: productRegion ';

        // System.debug(LoggingLevel.INFO, '*** outageNotification: ' + outageNotification);
        // soql += ' And System_Outage_Notification_Opt_Out__c =: outageNotification ';
        //System Outage Notification Opt Out=False
        if(notificationIndex == '1') soql += ' And System_Outage_Notification_Opt_Out__c = false ';
        // System Outage Notification Opt Out is True or False
        // if(notificationIndex == '2')
        //System Outage Notification Opt Out=True  
        if(notificationIndex == '3') soql += ' And System_Outage_Notification_Opt_Out__c = true ';

        if(selectedProducts != null && selectedProducts.size() > 0) soql += ' And Asset__r.Product2.Name IN: selectedProducts ';

        //SPS-1502: include user assets for the selected Asset Product(s) only if 
        //the users on those assets do not also have user assets for the products to be excluded
        excludeUsersSet = new set<String>();
        system.debug('excludedProducts------->>'+excludedProducts);
        if(excludedProducts != null){
            string soqlExclude = 'Select Id, User__c from User_Asset__c where Asset__r.Product2.Name IN: excludedProducts';
            
            if(role != null && role.size() > 0) soqlExclude += ' And Role__c IN: role ';
        
            if(assetType == '2') soqlExclude += ' And Is_Sponsored_User__c = false';
        
            if(assetType == '3') soqlExclude += ' And Is_Sponsored_User__c = true';
        
            List<User_Asset__c> lstExcludeUserAssets = (List<User_Asset__c>)Database.query(soqlExclude);
            
            if(lstExcludeUserAssets != null && lstExcludeUserAssets.size() > 0){
                for(User_Asset__c ua : lstExcludeUserAssets){
                    excludeUsersSet.add(ua.User__c);
                }
            }
        }
        soql += ' AND User__c NOT IN: excludeUsersSet';
        System.debug(LoggingLevel.INFO, '*** selectedProducts: ' + selectedProducts);
        return soql;
    }
    //add confirm result into Campaign
    public PageReference addToCampaign() {
        PageReference pf = null;
        try {
            Map<String, CampaignMember> campaignMembers = new Map<String, CampaignMember>();
            
            /* SPS-1261 Changed to Transient */
            Set<String> campaignMembersSet = new Set<String>();
            for(CampaignMember c : [Select ContactId, CampaignId From CampaignMember Where CampaignId =: campaignId]) {
               campaignMembersSet.add(c.ContactId);
                //campaignMemberMap.put(c.ContactId, c);
                }
            for(ID cw : ConfirmResultsSet) {
                if(campaignMembersSet.contains(cw)) continue;
                CampaignMember c = new CampaignMember(
                    ContactId = cw,
                    CampaignId = campaignId
                );
                campaignMembers.put(cw, c);
            }
            if(!campaignMembers.isEmpty()) insert campaignMembers.values();
            pf = new PageReference('/' + campaignId);
        }catch(Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }
        return pf;
    }

    // returns a list of wrapper objects for the sObjects in the current page set
    public List<UserAssetWrapper> getUserAssets() {
        userAssets = new List<UserAssetWrapper>();
        if(con != null) {
            for(User_Asset__c c : (List<User_Asset__c>)con.getRecords()) {
                userAssets.add(new UserAssetWrapper(c));
            } 
        }
        
        System.debug(LoggingLevel.INFO, '*** userAssets: ' + userAssets);
        return userAssets;
    }
    
    //filter Product by vertical
	public PageReference dynamicProduct() 
    {
        System.debug(LoggingLevel.INFO, '*** vertical: ' + vertical);
        productOptionsSize = 4;
        productOptions = new List<SelectOption>();
        if(vertical == '-') return null;
		
		if(productsMap.get(vertical) == null) return null;
		if(productsMap.get(vertical) != null)
		{
			for(String pName : productsMap.get(vertical))
			{
                productOptions.add(new SelectOption(pName, pName)); 
            }
		}

        if(productOptions.size() > 10) {
            productOptionsSize = 10;
        }
        System.debug(LoggingLevel.INFO, '*** productOptions.size(): ' + productOptions.size());
        return null;
	}

    public Boolean verify() {
        Boolean flag = false;
        if(accountFilter == '3' && userAsset.Asset_Account__c == null) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please specific an account if you choose Select a Specific Account'));
            flag = true;
        }
        if(userStatus == '-') {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select user status.'));
            flag = true;
        }
        if(role == null || role.size() < 1) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select a role.'));
            flag = true;
        }
        if(vertical == '-') {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select a vertical.'));
            flag = true;
        }
        if(vertical != '-' && (selectedProducts == null || selectedProducts.size() < 1)) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select one or more products.'));
            flag = true;
        }
        return flag;
    }

    public void preLoadProducts() {
        Set<String> AllProductSet = new Set<String>();
        Set<String> verticalProducts;
        for(Product2 p : [Select Id, Name, Vertical__c From Product2 Order By Name limit 40000]) 
        {
			if(AllProductSet.size() < 1000) AllProductSet.add(p.Name);
			if(productsMap.get(p.Vertical__c) == null)
			{
				verticalProducts = new Set<String>();
				verticalProducts.add(p.Name);
				productsMap.put(p.Vertical__c, verticalProducts);	
				continue;			
			}
			verticalProducts = productsMap.get(p.Vertical__c);
			if(verticalProducts != null && verticalProducts.size() < 1000)
			{
				verticalProducts.add(p.Name);
			}
        }
        productsMap.put('All', AllProductSet);
    }

    public PageReference resetFilter() {
        isVisiable = false;
        productOptionsSize = 4;
        accountFilter = '2';
        assetName = '';
        userStatus = 'Active';
        condition = '-';
        billingCondition = '-';
        contactBillingCountry = null;
        role = null;
        assetType = null;
        productRegion = null;
        // outageNotification = false;
        notificationIndex = '1';
        vertical = '-';
        selectedProducts = null;
        excludedProducts = null;
        productOptions = new List<SelectOption>();
        userAsset = new User_Asset__c();
        return null;
    }

    public List<SelectOption> getAccountFilterOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('1','All Accounts')); 
        options.add(new SelectOption('2','My Account Teams')); 
        options.add(new SelectOption('3','Select a Specific Account')); 
        return options; 
    }

    public List<SelectOption> getConditionOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('-','--None--')); 
        options.add(new SelectOption('e','equals')); 
        options.add(new SelectOption('n','not equal to')); 
        options.add(new SelectOption('c','contains')); 
        return options; 
    } 

    public List<SelectOption> getUserStatusOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        Schema.DescribeSobjectResult dsr = Schema.getGlobalDescribe().get('Contact').getDescribe();
        Schema.DescribeFieldResult dfr = dsr.fields.getMap().get('User_Status__c').getDescribe();
        options.add(new SelectOption('-','--None--')); 
        for(Schema.PicklistEntry pe : dfr.getPicklistValues()) {
            options.add(new SelectOption(pe.getValue(), pe.getLabel()));
        }
        options.add(new SelectOption('Both','Both'));
        return options;
    }

    public List<SelectOption> getRoleOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        Schema.DescribeSobjectResult dsr = Schema.getGlobalDescribe().get('User_Asset__c').getDescribe();
        Schema.DescribeFieldResult dfr = dsr.fields.getMap().get('Role__c').getDescribe();
        for(Schema.PicklistEntry pe : dfr.getPicklistValues()) {
            options.add(new SelectOption(pe.getValue(), pe.getLabel()));
        }
        return options;
    }
    
   public List<SelectOption> getAssetTypeOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('1', 'Include All Users'));
        options.add(new SelectOption('2', 'Include Only Non Sponsored Users'));
        options.add(new SelectOption('3', 'Include Only Sponsored Users'));
        return options;
    }

    public List<SelectOption> getProductRegionOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        Schema.DescribeSobjectResult dsr = Schema.getGlobalDescribe().get('Asset').getDescribe();
        Schema.DescribeFieldResult dfr = dsr.fields.getMap().get('Product_Region__c').getDescribe();
        for(Schema.PicklistEntry pe : dfr.getPicklistValues()) {
            options.add(new SelectOption(pe.getValue(), pe.getLabel()));
        }
        return options; 
    } 

    public List<SelectOption> getVerticalOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        Schema.DescribeSobjectResult dsr = Schema.getGlobalDescribe().get('Product2').getDescribe();
        Schema.DescribeFieldResult dfr = dsr.fields.getMap().get('Vertical__c').getDescribe();
        options.add(new SelectOption('-','--None--')); 
        for(Schema.PicklistEntry pe : dfr.getPicklistValues()) {
            options.add(new SelectOption(pe.getValue(), pe.getLabel()));
        }
        options.add(new SelectOption('All','All')); 
        return options; 
    }

    public List<SelectOption> getNotificationOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('1','Exclude Users Who Opted Out (default)'));//System Outage Notification Opt Out=False
        options.add(new SelectOption('2','Included All Users'));//System Outage Notification Opt Out is True or False
        options.add(new SelectOption('3','Only Show Users Who Opted Out'));//System Outage Notification Opt Out=True
        return options; 
    }

    // displays the selected items
    // public PageReference process() {
    //     for(UserAssetWrapper cw : userAssets) {
    //         if(cw.checked) {
    //             ConfirmResults.add(cw);
    //         }
    //         // ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,cw.cont.Name));
    //     }
    //     return null;
    //  }

    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }

    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }

    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }

    // returns the first page of records
    public void first() {
        con.first();
    }

    // returns the last page of records
    public void last() {
        con.last();
    }

    // returns the previous page of records
    public void previous() {
        con.previous();
    }

    // returns the next page of records
    public void next() {
        con.next();
    }

    // returns the PageReference of the original page, if known, or the home page.
    public PageReference cancel() {
        // con.cancel();
        PageReference pf = new PageReference('/' + campaignId);
        return pf;
     }

    class UserAssetWrapper {

        public Boolean checked { get; set; }
        public User_Asset__c userAsset { get; set;}

        public UserAssetWrapper(User_Asset__c c){
            userAsset = c;
            checked = false;
        }
    }
}