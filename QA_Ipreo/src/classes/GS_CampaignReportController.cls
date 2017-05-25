public with sharing class GS_CampaignReportController {
    
    public final static Integer PAGESIZE = Integer.valueOf(System.Label.Page_Size);
    // returns a list of wrapper objects for the sObjects in the current page set
    List<UserAssetWrapper> userAssets {get;set;}

    List<CampaignMemberWrapper> campaignMembers {get;set;}
    /* SPS-1261 Changed to Transient */
    public transient List<User_Asset__c> ConfirmResults {get;set;}
    public Set<ID> ConfirmResultsSet {get;set;}

    public ApexPages.StandardSetController con {get;set;}

    public String campaignId {get;set;}

    public transient Map<String, CampaignMember> campaignMemberMap = new Map<String, CampaignMember>();
    
    public String userStatus {get;set;}
    
    public String accountFilter {get;set;}

    public Boolean isVisiable {get;set;}

    public Boolean isVisiable4ResultSection {get;set;}

    public Campaign campaign;
    public CampaignMember campMember {get;set;}

    public Set<String> accIdSet;
    
    public User_Asset__c userAsset {get;set;}
    
    public Integer totalRecord {get;set;}

    public String blockMessage {get;set;}
    
    public String notificationIndex {get;set;}

    public GS_CampaignReportController() {

        isVisiable = false;
        isVisiable4ResultSection = false;
        userStatus = 'Active';
        userAsset = new User_Asset__c();
        ConfirmResults = new List<User_Asset__c>();
        campMember = new CampaignMember(); 
        ConfirmResultsSet = new Set<ID>();
        if(con == null) {
            con = new ApexPages.StandardSetController(Database.getQueryLocator([Select Id,Full_Name__c FROM CampaignMember Order By CreatedDate limit 1]));
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
        String soql = 'Select Id, Name, User_Country__c, Role__c, Asset__r.Name, User__c, User__r.Name, Asset_Account__r.Name, '
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
 

        if(userStatus == 'Active' || userStatus == 'Inactive') soql += ' And User__r.User_Status__c = \'' + userStatus + '\'';

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
    
        public List<CampaignMemberWrapper> getCampaignMembers() {
        campaignMembers = new List<CampaignMemberWrapper>();
        if(con != null) {
        }
        
        return campaignMembers;
    }

    //filter Product by vertical
    public PageReference dynamicProduct() {

        return null;
    }

    public Boolean verify() {
        Boolean flag = false;

        if(userStatus == '-') {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select user status.'));
            flag = true;
        }
        return flag;
    }

    public void preLoadProducts() {
        Set<String> GMGProductSet = new Set<String>();
        Set<String> CororateProductSet = new Set<String>();
        Set<String> AllProductSet = new Set<String>();
        for(Product2 p : [Select Id, Name, Vertical__c From Product2 Order By Name limit 40000]) {
            if(p.Vertical__c == 'GMG' && GMGProductSet.size() < 1000) {
                GMGProductSet.add(p.Name);
            }
            if(p.Vertical__c == 'Corporate' && CororateProductSet.size() < 1000) {
                CororateProductSet.add(p.Name);
            }
            if(AllProductSet.size() < 1000) AllProductSet.add(p.Name);
            if(GMGProductSet.size() >= 1000 && CororateProductSet.size() >= 1000 && AllProductSet.size() >= 1000) break;
        }        
    }

    public PageReference resetFilter() {
        isVisiable = false;       
        userStatus = 'Active';
        userAsset = new User_Asset__c();
        return null;
    }

    public List<SelectOption> getAccountFilterOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('1','All Campaigns')); 
        options.add(new SelectOption('2','All Active Campaigns')); 
        options.add(new SelectOption('3','Select a Specific Campaign')); 
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
        Schema.DescribeSobjectResult dsr = Schema.getGlobalDescribe().get('CampaignMember').getDescribe();
        Schema.DescribeFieldResult dfr = dsr.fields.getMap().get('Status').getDescribe();
        options.add(new SelectOption('-','--None--')); 
        for(Schema.PicklistEntry pe : dfr.getPicklistValues()) {
            options.add(new SelectOption(pe.getValue(), pe.getLabel()));
        }
        return options;
    }
    
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
    
    class CampaignMemberWrapper{
        public CampaignMember campaignMember { get; set; } 
        public Task activity { get; set; }
    }
    
    

}