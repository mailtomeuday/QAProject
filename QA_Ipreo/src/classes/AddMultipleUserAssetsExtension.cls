public with sharing class AddMultipleUserAssetsExtension {

    public class UserAsset {

        public Boolean selected { get; set; }
        public Boolean deleted { get; set; }
        public Boolean hasNewPermission {get; set;}
        public Boolean hasDelPermission {get; set;}
        public Boolean existing {get; set;}
        public Asset asset { get; set; }
        public Contact user { get; set; }
        public Boolean systemOutageNotificationOptOut { get; set; }
        public String role { get; set; }
        public String userAssetID { get; set; }
        public UserAsset(Asset a, Contact u) {
            asset = a;
            user = u;
            selected = false;
            hasNewPermission = false;
            hasDelPermission = false;
            existing = false;
            deleted = false;
            role = 'User';
        }
    }

    // Getters and setters
    public String language { get; set; }
    public Asset asset { get; set; }
    public List<UserAsset> uaBindings { get; set; }
    //SPS-1356, Variable used for For Pagination
    public  List<UserAsset> lstSetBindings{get;set;}
    public string accountName { get; set; }
    public Boolean showTop50ThousandMsg {get;set;}
    // Private controller variables
    //private List<UserAsset> listUA;
    private List<User_Asset__c> listUserAssetForInserting;
    private List<User_Asset__c> listUserAssetForDeleting;
    private List<Id> userAssetIds;
    // Key is contactid, this variable is used to check UserRecordAccess by Contact Id.
    private Map<Id, UserRecordAccess> mapRecordAccesses;
    // Key is contactid, this variable is used to check if there has been a user assert of contact.
    private Map<Id, User_Asset__c> mapConWithUserAsset;
    GS_CustomIterable obj;
    // Constructor
    public AddMultipleUserAssetsExtension(ApexPages.StandardController controller) {
		List<UserAsset> listUA;
        // When creating tasks from opportunities, Salesforce passes the account as the WhoId; we need to null this out if it's not a lead or contact
        try {
            ID assetId = ApexPages.currentPage().getParameters().get('aid');
            asset = [SELECT Id, AccountId, Account.Name, Name FROM Asset WHERE Id = : assetId];
        }
        // Catch exceptions where URL parameter may not be an ID
        catch (Exception ex) {
            asset = null;
        }

        listUA = new List<UserAsset>();
        uaBindings = new List<UserAsset>();
        //listUserAssetForInserting = new List<User_Asset__c>();
        //listUserAssetForDeleting = new List<User_Asset__c>();
        userAssetIds = new List<Id>();
        mapRecordAccesses = new Map<Id, UserRecordAccess>();
        mapConWithUserAsset = new Map<Id, User_Asset__c>();
        showTop50ThousandMsg = false;
        // select the existing user assets
        for(User_Asset__c ua : [SELECT Id, Asset__c, Asset_Account__c, User__c, Role__c, System_Outage_Notification_Opt_Out__c 
                                FROM User_Asset__c Where Asset__c =: asset.Id]) {
            mapConWithUserAsset.put(ua.User__c, ua);
            userAssetIds.add(ua.Id);
        }
        // loop all the contacts related to the asset. And create the total list of binding.
        for (Contact c : [SELECT Id, FirstName, LastName, AccountId, Account.Name, Name FROM Contact WHERE AccountId = :asset.AccountId  order by Account.Name,LastName limit 50000]) {
            listUA.add(new UserAsset(asset, c));
        }
        if(listUA != null && listUA.size() == 50000){
            showTop50ThousandMsg = true;
            system.debug('showTop50ThousandMsg-------->'+showTop50ThousandMsg); 
        }
        
        Boolean isCreateable = User_Asset__c.sObjectType.getDescribe().isCreateable();
        Boolean isDeletable = User_Asset__c.sObjectType.getDescribe().isDeletable();
        for(UserAsset ua : listUA) {
            // check if the user asset of the current contact has been added.
            if(mapConWithUserAsset.get(ua.user.Id) != NULL){
                ua.existing = TRUE;
                ua.role = mapConWithUserAsset.get(ua.user.Id).Role__c;
                ua.systemOutageNotificationOptOut = mapConWithUserAsset.get(ua.user.Id).System_Outage_Notification_Opt_Out__c;
                ua.userAssetID = mapConWithUserAsset.get(ua.user.Id).Id;
            }
            // check if the user has the permission to create user asset
            ua.hasNewPermission = isCreateable;
            ua.hasDelPermission = isDeletable;
        }
        // sort the list
        for(UserAsset ua : listUA) {
            if(!ua.existing) {
                uaBindings.add(ua);
            }
        }
        for(UserAsset ua : listUA) {
            if(ua.existing) {
                uaBindings.add(ua);
            }
        }
        language = UserInfo.getLanguage();
        obj = new GS_CustomIterable(uaBindings); 
        obj.setPageSize = 1000;
        next();  
    }

    // Save
    public ApexPages.PageReference save() {
        listUserAssetForInserting = new List<User_Asset__c>();
        listUserAssetForDeleting = new List<User_Asset__c>();
        Savepoint sp = Database.setSavepoint();
        System.debug(LoggingLevel.INFO, '*** uaBindings: ' + uaBindings);
        try {
            for (UserAsset ua : uaBindings) {
                if (ua.selected && ua.asset != null && ua.user != null) {
                    User_Asset__c uAsset =  new User_Asset__c(
                        Asset__c = ua.asset.Id, 
                        User__c = ua.user.Id,
                        Role__c = ua.role,
                        System_Outage_Notification_Opt_Out__c = ua.systemOutageNotificationOptOut,
                        Asset_Account__c = asset.AccountId,
                        Sponsored_Users_Account__c = (asset.AccountId != ua.user.AccountId ?  ua.user.AccountId : null)
                    );
                    listUserAssetForInserting.add(uAsset);
                }
                
            }
            insert listUserAssetForInserting;

            for (UserAsset ua : uaBindings) {
                if (ua.deleted && ua.asset != null && ua.user != null) {
                    listUserAssetForDeleting.add(mapConWithUserAsset.get(ua.user.Id));
                }
            }

            delete listUserAssetForDeleting;

            return new ApexPages.PageReference(ApexPages.currentPage().getParameters().get('retURL'));
        } catch(Exception ex) {
            Database.rollback(sp);
            ApexPages.addMessages(ex);
            System.debug(LoggingLevel.Error, '*** ex.getLineNumber(): ' + ex.getLineNumber());
            return null;
        }
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
    
    public ApexPages.PageReference getSearchResults() {
        List<UserAsset> listUA;
        listUA = new List<UserAsset>();
        uaBindings = new List<UserAsset>();
        list<string> listAccIds = new list<string>();
        Set<Id> accountIds;
        showTop50ThousandMsg = false;
        
        try{
            string accName = '\'%' + accountName.trim() + '%\'';
            string assetId = '\''+asset.Id+'\'';
            system.debug('accName-------->'+accName);
            string accountQuery = 'select Account_Name__r.Id FROM Sponsored_Asset__c'+
                                    ' WHERE Asset_Name__r.Id = '+ assetId +
                                        ' and Account_Name__r.Name like '+accName;
            
            system.debug('accountQuery-------->'+accountQuery);
                                        
            list<Sponsored_Asset__c> listSponsoredAssets =  Database.Query(accountQuery);
            accountIds = New Set<Id>();
                                    
            for (Sponsored_Asset__c sa : listSponsoredAssets){
                accountIds.add(sa.Account_Name__r.Id);
            }
            
            system.debug('1--asset-------->'+asset); 
            system.debug('1--Account-------->'+asset.Account); 
            //add existing asset account to the list of searched accounts
            if(asset.Account != null && asset.Account.Name.containsIgnoreCase(accountName)){
                accountIds.add(asset.Account.Id);
            }
            
            system.debug('1--accountIds-------->'+accountIds); 
            
            if(accountIds != null){
                system.debug('accountIds-------->'+accountIds); 
                string contactQuery = 'SELECT Id, FirstName, LastName, Account.Name, AccountId, Account.Id, Name FROM Contact WHERE AccountId in :accountIds order by Account.Name,LastName limit 50000';
                system.debug('contactQuery-------->'+contactQuery); 
                system.debug('asset-------->'+asset); 
                list<Contact> listContact = Database.Query(contactQuery);
                if(listContact != null && listContact.size() == 50000){
                    showTop50ThousandMsg = true;
                    system.debug('showTop50ThousandMsg-------->'+showTop50ThousandMsg); 
                }
                // loop all the contacts related to the asset. And create the total list of binding.
                for (Contact c : listContact) {
                    listUA.add(new UserAsset(asset, c));
                }
                
                Boolean isCreateable = User_Asset__c.sObjectType.getDescribe().isCreateable();
                Boolean isDeletable = User_Asset__c.sObjectType.getDescribe().isDeletable();
                for(UserAsset ua : listUA) {
                    // check if the user asset of the current contact has been added.
                    if(mapConWithUserAsset.get(ua.user.Id) != NULL){
                        ua.existing = TRUE;
                        ua.role = mapConWithUserAsset.get(ua.user.Id).Role__c;
                        ua.systemOutageNotificationOptOut = mapConWithUserAsset.get(ua.user.Id).System_Outage_Notification_Opt_Out__c;
                        ua.userAssetID = mapConWithUserAsset.get(ua.user.Id).Id;
                    }
                    // check if the user has the permission to create user asset
                    ua.hasNewPermission = isCreateable;
                    ua.hasDelPermission = isDeletable;
                }
                // sort the list
                for(UserAsset ua : listUA) {
                    if(!ua.existing) {
                        uaBindings.add(ua);
                    }
                }
                for(UserAsset ua : listUA) {
                    if(ua.existing) {
                        uaBindings.add(ua);
                    }
                }
            }
        obj = new GS_CustomIterable(uaBindings); 
        obj.setPageSize = 1000;
        next();
            
        }
        
        catch(Exception ex)
        {
            throw ex;
            //ApexPages.addMessages(ex);
        }
        
        return null;
    }
    /* SPS-1356, To implement pagination */
    public Boolean hasNext {
    get 
    {
        return obj.hasNext();
    }
    set;
    }
    
    public Boolean hasPrevious {
        get 
        {
            return obj.hasPrevious();
        }
        set;
    }
    public Boolean hasLast {
        get 
        {
            return obj.hasLast();
        }
        set;
    }   
    public Boolean hasFirst {
        get 
        {
            return obj.hasFirst();
        }
        set;
    }   
    public void next() 
    {
        lstSetBindings = obj.next();
    }
    
    public void previous() 
    {
        lstSetBindings = obj.previous();
    }
    public void First() 
    {
        lstSetBindings = obj.First();
    }   
    public void Last() 
    {
        lstSetBindings = obj.Last();
    }    
    
}