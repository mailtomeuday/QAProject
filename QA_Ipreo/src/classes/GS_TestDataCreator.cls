/**************************************************************************************************
 * Name: TestDataCreator
 * Object:
 * Purpose:
 * 1. Tool Class all for test method
 * Author: Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date: 2015-06-01
***************************************************************************************************/
public class GS_TestDataCreator {

    public static User createUser(String profileName, String email) {
        Profile p = queryProfile(profileName);
        User u = new User(LastName = 'testuser', Alias = 'testuser', Email = email,
                          Username = email, CommunityNickname = email + 'nick', ProfileId = p.id,
                          EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles');
        insert u;
        return u;
    }

  public static User createUser(String profileName, String email, String region) {
    Profile p = queryProfile(profileName);
    User u = new User(LastName = 'testuser', Alias = 'testuser', Email = email,
                      Username = email, CommunityNickname = email + 'nick', ProfileId = p.id,
                      EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
                      LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles');
    u.Region__c = region;
    insert u;
    return u;
  }
  
  public static User createUser(String profileName, String email, String region, Boolean insertRecord) {
    Profile p = queryProfile(profileName);
    User u = new User(LastName = 'testuser', Alias = 'testuser', Email = email,
                      Username = email, CommunityNickname = email + 'nick', ProfileId = p.id,
                      EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
                      LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles');
    u.Region__c = region;
    if(insertRecord){
        try{
            insert u;
        }
        catch(System.DmlException ex){
            throw ex;
        }
    }
    return u;
  }

    public static Profile queryProfile(String name){
        Profile p =[select id,Name from Profile where Name=:name limit 1];
        return p;
    }

    public static Account createAccount(String name) {
        Account acc = new Account();
        acc.Name = name;
        acc.region__c = 'North America';
        insert acc;
        return acc;
    }
    
    public static Account createAccount(String name, Boolean insertRecord){
        Account acc = new Account();
        acc.Name = name;
        acc.region__c = 'North America';
        if(insertRecord)
        {
            try{
                insert acc;
                return acc; 
            }catch(DmlException ex){
                throw ex;
            }
       }
        return acc;
    }

    public static List<Account> createAccounts(List<String> names) {
        List<Account> lstAcc = new List<Account>();
        for(String tempName : names) {
            Account acc = new Account();
            acc.Name = tempName;
            acc.region__c = 'North America';
            lstAcc.add(acc);
        }
        insert lstAcc;
        return lstAcc;
    }

    public static Account createAccount(String name, String verticalType, String NYSEProgramTier) {
      Account acc = new Account();
      acc.Name = name;
      acc.Vertical__c = verticalType;
      acc.NYSE_Program_Tier__c = NYSEProgramTier;
      acc.region__c = 'North America';
      insert acc;
      return acc;
    }

    public static Partner createPartner(Account acc, String role , Opportunity opp) {
        Partner par = new Partner();
        par.Role= role;
        par.AccountToId = acc.Id;
        par.OpportunityId = opp.Id;
        insert par;
        return par;
    }


    public static Contact createContact(String lastName, Account acc) {
        Contact con = new Contact();
        con.LastName = lastName;
        con.AccountId = acc.Id;
        con.MailingCountry = 'China';
        con.Asset_Bundle__c = 'Test Asset Bundle';
        Country_List__c testCountry = new Country_List__c();
        testCountry.Name = 'China';
        insert testCountry;
        insert con;
        return con;
    }
    /* Creating Contacting and inserting to DB based on boolean flag */
    public static Contact createContact(String lastName, Account acc, Boolean insertRecord) {
        Contact con = new Contact();
        con.LastName = lastName;
        con.AccountId = acc.Id;
        con.Asset_Bundle__c = 'Test Asset Bundle';
        if(insertRecord){
            try{
                insert con;
            }
            catch(System.DmlException ex){
                throw ex;
            }       
        }
        return con;
    }

    public static OpportunityContactRole createOppConRole(Contact con, Opportunity opp , String role) {
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = con.Id;
        ocr.OpportunityId = opp.Id;
        insert ocr;
        return ocr;
    }

    public static Contract__c createContract(String name, Account acc , String status , String city , Contact con , String country , String frequency , String sDate , String street , String term) {
        Contract__c contract = new Contract__c();
        contract.Name = name;
        contract.Account__c = acc.Id;
        contract.Billing_Account__c = acc.Id;
        contract.Status__c = status;
        contract.Billing_City__c = city;
        contract.Billing_Contact__c = con.Id;
        contract.Billing_Country__c = country;
        contract.Billing_Frequency__c = frequency;
        contract.Billing_Start_Date__c = sDate;
        contract.Billing_Street__c = street;
        contract.Payment_Terms__c = term;
        insert contract;
        return contract;
    }

    public static Asset createAsset(Account acc, String name, Product2 pro, String proRegion) {
        Asset newAsset = new Asset();
        newAsset.AccountId = acc.Id;
        newAsset.Name = name;
        newAsset.Product2Id = pro.Id;
        newAsset.Product_Region__c = proRegion;
        insert newAsset;
        return newAsset;
    }

    public static Product2 createProduct(String name, Boolean isAsset, Boolean requiredPassThrough) {
        Product2 pro = new Product2();
        pro.Name = name;
        pro.Asset__c = isAsset;
        pro.Pass_Through_Required__c = requiredPassThrough;
        insert pro;
        return pro;
    }

    public static Product2 createProduct(String name, Boolean isAsset, Boolean requiredPassThrough, String workOrderType, String revenueType) {
        Product2 pro = new Product2();
        pro.Name = name;
        pro.Asset__c = isAsset;
        pro.Pass_Through_Required__c = requiredPassThrough;
        pro.Work_Order_Type_Default__c = workOrderType;
        pro.Revenue_Type__c = revenueType;
        insert pro;
        return pro;
    }


    public static Product2 createProduct(String name, Boolean isAsset, Boolean requiredPassThrough,String productCode, String revenueType, String verticalType) {
      Product2 pro = new Product2();
      pro.Name = name;
      pro.Asset__c = isAsset;
      pro.Pass_Through_Required__c = requiredPassThrough;
      pro.ProductCode = productCode;
      pro.Revenue_Type__c = revenueType;
      pro.Vertical__c = verticalType;
      insert pro;
      return pro;
    }

    public static Asset_License__c createLicense(Asset pAsset, Date startDate, Date endDate) {
        Asset_License__c al = new Asset_License__c();
        al.Asset__c = pAsset.Id;
        al.Start_Date__c = startDate;
        al.End_Date__c = endDate;
        insert al;
        return al;
    }

    public static User_Asset__c createUserAsset(Asset pAsset, Contact con) {
        User_Asset__c uAsset = new User_Asset__c();
        uAsset.Asset__c = pAsset.Id;
        uAsset.User__c = con.Id;
        insert uAsset;
        return uAsset;
    }

    public static Work_Order__c createWorkOrder(Account acc, String type, String name, Date completeDate) {
        Work_Order__c pro = new Work_Order__c();
        pro.RecordTypeId = getRecordType(type, 'Work_Order__c').Id;
        pro.Name = name;
        pro.Completion_Date__c = completeDate;
        pro.Account__c = acc.Id;
        insert pro;
        return pro;
    }

    public static RecordType getRecordType(String recordTypeName, String sObjectName) {
        RecordType rt = [SELECT Id
                               ,DeveloperName
                               ,SobjectType
                         FROM RecordType
                         WHERE SobjectType =: sObjectName
                         AND DeveloperName =: recordTypeName];
        return rt;
    }

    public static Opportunity createOpportunity(Account acc, String name, String recordTypeName, String stageName, String revenueType, String renewalIncrement, String NYSEProgramTier) {
        Opportunity opp = new Opportunity();
        opp.Name = name;
        opp.AccountId = acc.Id;
        opp.RecordTypeId = getRecordType(recordTypeName, 'Opportunity').Id;
        opp.CloseDate = Date.valueOf(String.valueof(Datetime.now().addDays(20)));
        opp.StageName = stageName;
        opp.Revenue_Type__c = revenueType;
        opp.Renewal_Increment__c = renewalIncrement;
        opp.NYSE_Program_Tier__c = NYSEProgramTier;
        opp.Non_Subsidized_Contracted_Value__c = 100000;
        opp.LOB__c = 'Equity - Research, Sales & Trading';

        insert opp;
        return opp;
    }

    public static Opportunity createOpportunity(Account acc, String name, String recordTypeName, String stageName, String revenueType, String renewalIncrement, String NYSEProgramTier, String verticalType ) {
        Opportunity opp = new Opportunity();
        opp.Name = name;
        opp.AccountId = acc.Id;
        opp.RecordTypeId = getRecordType(recordTypeName, 'Opportunity').Id;
        opp.CloseDate = Date.valueOf(String.valueof(Datetime.now().addDays(20)));
        opp.StageName = stageName;
        opp.Revenue_Type__c = revenueType;
        opp.Renewal_Increment__c = renewalIncrement;
        opp.NYSE_Program_Tier__c = NYSEProgramTier;
        opp.Vertical__c = verticalType;

        insert opp;
        return opp;
    }


    public static OpportunityLineItem createOppLineItem(PricebookEntry priceEntry, Opportunity opp, String productTransactionType, Decimal acpv, Decimal tcpv, Decimal passThrough, String applyNYSESubsidy, String competitorIncumbent, Decimal estAnnualFees, String revenueType) {
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.PriceBookEntryId = priceEntry.Id;
        oppLineItem.OpportunityId = opp.Id;
        oppLineItem.Product_Transaction_Type__c = productTransactionType;
        oppLineItem.ACpV__c = acpv;
        oppLineItem.UnitPrice = tcpv;
        oppLineItem.Annual_Pass_Through__c = passThrough;
        oppLineItem.Apply_NYSE_Subsidy__c = applyNYSESubsidy;
        oppLineItem.Competitor_Incumbent__c = competitorIncumbent;
        oppLineItem.Estimated_Annual_Fees__c = estAnnualFees;
        oppLineItem.Product_Revenue_Type__c = revenueType;
        oppLineItem.Product_Vertical__c = 'GMG';
        insert oppLineItem;
        return oppLineItem;
    }

    public static OpportunityLineItem createOppLineItem(PricebookEntry priceEntry, Opportunity opp, String productTransactionType, Decimal acpv, Decimal tcpv, Decimal passThrough, String applyNYSESubsidy, String competitorIncumbent) {
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.PriceBookEntryId = priceEntry.Id;
        oppLineItem.OpportunityId = opp.Id;
        oppLineItem.Product_Transaction_Type__c = productTransactionType;
        oppLineItem.ACpV__c = acpv;
        oppLineItem.UnitPrice = tcpv;
        oppLineItem.Annual_Pass_Through__c = passThrough;
        oppLineItem.Apply_NYSE_Subsidy__c = applyNYSESubsidy;
        oppLineItem.Competitor_Incumbent__c = competitorIncumbent;
        oppLineItem.Product_Vertical__c = 'GMG';
        insert oppLineItem;
        return oppLineItem;
    }

    public static OpportunityLineItem createOppLineItem(PricebookEntry priceEntry, Opportunity opp, String productTransactionType, Decimal acpv, Decimal tcpv, Decimal passThrough, String applyNYSESubsidy, String competitorIncumbent, String status) {
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.PriceBookEntryId = priceEntry.Id;
        oppLineItem.OpportunityId = opp.Id;
        oppLineItem.Product_Transaction_Type__c = productTransactionType;
        oppLineItem.ACpV__c = acpv;
        oppLineItem.UnitPrice = tcpv;
        oppLineItem.Annual_Pass_Through__c = passThrough;
        oppLineItem.Apply_NYSE_Subsidy__c = applyNYSESubsidy;
        oppLineItem.Competitor_Incumbent__c = competitorIncumbent;
        oppLineItem.Status__c = status;
        insert oppLineItem;
        return oppLineItem;
    }

    public static OpportunityLineItem createOppLineItem(PricebookEntry priceEntry, Opportunity opp, String productTransactionType, Decimal acpv, Decimal tcpv, Decimal passThrough, String applyNYSESubsidy, String competitorIncumbent, String status, String reason ) {
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.PriceBookEntryId = priceEntry.Id;
        oppLineItem.OpportunityId = opp.Id;
        oppLineItem.Product_Transaction_Type__c = productTransactionType;
        oppLineItem.ACpV__c = acpv;
        oppLineItem.UnitPrice = tcpv;
        oppLineItem.Annual_Pass_Through__c = passThrough;
        oppLineItem.Apply_NYSE_Subsidy__c = applyNYSESubsidy;
        oppLineItem.Competitor_Incumbent__c = competitorIncumbent;
        oppLineItem.Status__c = status;
        oppLineItem.Lost_Cancelled_Reason__c = reason;
        insert oppLineItem;
        return oppLineItem;
    }

    public static OpportunityLineItem createOppLineItem(PricebookEntry priceEntry, Opportunity opp, String productTransactionType, Decimal acpv, Decimal tcpv, Decimal passThrough, String applyNYSESubsidy, String competitorIncumbent, String status, Decimal estAnnualFees) {
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.PriceBookEntryId = priceEntry.Id;
        oppLineItem.OpportunityId = opp.Id;
        oppLineItem.Product_Transaction_Type__c = productTransactionType;
        oppLineItem.ACpV__c = acpv;
        oppLineItem.UnitPrice = tcpv;
        oppLineItem.Annual_Pass_Through__c = passThrough;
        oppLineItem.Apply_NYSE_Subsidy__c = applyNYSESubsidy;
        oppLineItem.Competitor_Incumbent__c = competitorIncumbent;
        oppLineItem.Status__c = status;
        oppLineItem.Estimated_Annual_Fees__c = estAnnualFees;
        insert oppLineItem;
        return oppLineItem;
    }

    public static OpportunityLineItem createOppLineItem(PricebookEntry priceEntry, Opportunity opp, String productTransactionType, Decimal acpv, Decimal tcpv, Decimal passThrough, String applyNYSESubsidy, String competitorIncumbent, String status, Decimal estAnnualFees, String reason, String revenueType, String productRegion) {
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.PriceBookEntryId = priceEntry.Id;
        oppLineItem.OpportunityId = opp.Id;
        oppLineItem.Product_Transaction_Type__c = productTransactionType;
        oppLineItem.ACpV__c = acpv;
        oppLineItem.UnitPrice = tcpv;
        oppLineItem.Annual_Pass_Through__c = passThrough;
        oppLineItem.Apply_NYSE_Subsidy__c = applyNYSESubsidy;
        oppLineItem.Competitor_Incumbent__c = competitorIncumbent;
        oppLineItem.Status__c = status;
        oppLineItem.Estimated_Annual_Fees__c = estAnnualFees;
        oppLineItem.Lost_Cancelled_Reason__c = reason;
        oppLineItem.Product_Revenue_Type__c = revenueType;
        oppLineItem.Product_Region__c = productRegion;
        System.debug('*** revenueType: ' + revenueType + '');
        System.debug('*** opp.Product_Revenue_Type__c: ' + oppLineItem.Product_Revenue_Type__c);
        insert oppLineItem;
        return oppLineItem;
    }
    
        public static OpportunityLineItem createOppLineItem(PricebookEntry priceEntry, Opportunity opp, String productTransactionType, Decimal acpv, Decimal tcpv, Decimal passThrough, String applyNYSESubsidy, String competitorIncumbent, String status, Decimal estAnnualFees, String reason, String revenueType, String productRegion,Boolean insertRecord) {
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.PriceBookEntryId = priceEntry.Id;
        oppLineItem.OpportunityId = opp.Id;
        oppLineItem.Product_Transaction_Type__c = productTransactionType;
        oppLineItem.ACpV__c = acpv;
        oppLineItem.UnitPrice = tcpv;
        oppLineItem.Annual_Pass_Through__c = passThrough;
        oppLineItem.Apply_NYSE_Subsidy__c = applyNYSESubsidy;
        oppLineItem.Competitor_Incumbent__c = competitorIncumbent;
        oppLineItem.Status__c = status;
        oppLineItem.Estimated_Annual_Fees__c = estAnnualFees;
        oppLineItem.Lost_Cancelled_Reason__c = reason;
        oppLineItem.Product_Revenue_Type__c = revenueType;
        oppLineItem.Product_Region__c = productRegion;
        System.debug('*** revenueType: ' + revenueType + '');
        System.debug('*** opp.Product_Revenue_Type__c: ' + oppLineItem.Product_Revenue_Type__c);
        try{
            if(insertRecord){
                insert oppLineItem;
            }
        }   
        catch(System.DmlException ex){
            throw ex;
        }
        return oppLineItem;
    }


    public static PricebookEntry createPriceBookEntry(Product2 product, Decimal unitPrice){
        PricebookEntry entry = new PricebookEntry();
        entry.Product2Id = product.Id;
        entry.Pricebook2Id = Test.getStandardPricebookId();
        entry.UnitPrice = unitPrice;
        entry.IsActive = true;
        insert entry;
        return entry;
    }

    public static PriceBook2 createPriceBook() {
        PriceBook2 standardPriceBook = new PriceBook2();
        standardPriceBook.Name = 'Test Standard Price Book';
        insert standardPriceBook;
        return standardPriceBook;
    }

    public static Attachment createAttachment(Contract__c contract, String name, Boolean isPrivate ,String contents) {
        Attachment att = new Attachment();
        Blob test = Blob.valueOf(contents);
        att.ParentId = contract.Id;
        att.Name = name;
        att.IsPrivate = isPrivate;
        att.Body = test;
        insert att;
        return att; 
    }

    public static Event createEvent(User u , Integer num , Date aDate ,Contact con) {
        Event eve = new Event();
        eve.OwnerId = u.Id;
        eve.DurationInMinutes = num;
        eve.ActivityDateTime = aDate;
        eve.WhoId = con.Id;
        eve.Products__c = 'BD Corporate (Assist)';
        insert eve;
        return eve;
    }
	
	public static Event createEvent(User u , Integer num , Date aDate ,Contact con, string products) {
        Event eve = new Event();
        eve.OwnerId = u.Id;
        eve.DurationInMinutes = num;
        eve.ActivityDateTime = aDate;
        eve.WhoId = con.Id;
        eve.Products__c = products;
        insert eve;
        return eve;
    }
    
    public static Event createEvent(User u , Integer num , Date aDate ,Lead objLead, string products) {
        Event eve = new Event();
        eve.OwnerId = u.Id;
        eve.DurationInMinutes = num;
        eve.ActivityDateTime = aDate;
        eve.WhoId = objLead.Id;
        eve.Products__c = products;
        insert eve;
        return eve;
    }
    
	public static Event createEvent(User u , Integer num , Date aDate ,Contact con, String activityType, Opportunity opp, Boolean insertRecord) {
        Event eve = new Event();
        eve.OwnerId = u.Id;
        eve.DurationInMinutes = num;
        eve.ActivityDateTime = aDate;
        eve.Type = activityType;
        eve.WhoId = con.Id;
        eve.WhatId = opp.Id;
        if(insertRecord){
            try{
                insert eve;
            }
            catch(System.DmlException ex){
                throw ex;
            }
        }
        return eve;
    }
    
    public static Task createTask(User u ,Contact con) {
        Task task = new Task();
        task.OwnerId = u.Id;
        task.WhoId = con.Id;
        task.Type = 'Call (Not Connected)';
        insert task;
        return task;
    }
    
    public static Task createTask(User u ,Contact con, string products) {
        Task task = new Task();
        task.OwnerId = u.Id;
        task.WhoId = con.Id;
        task.Type = 'Call (Not Connected)';
        task.Products__c = products;
        insert task;
        return task;
    }
    
    public static Task createTask(User u ,Lead objLead, string products) {
        Task task = new Task();
        task.OwnerId = u.Id;
        task.WhoId = objLead.Id;
        task.Type = 'Call (Not Connected)';
        task.Products__c = products;
        insert task;
        return task;
    }
    
    public static Task createTask(User u, Contact con, String activityType, ID whatId, Boolean insertRecord) {
        Task task = new Task();
        task.OwnerId = u.Id;
        task.Type = activityType;
        task.WhoId = con.Id;
        task.WhatId = whatId;
        if(insertRecord){
            try{
                insert task;
            }
            catch(System.DmlException ex){
                throw ex;
            }
        }
        return task;
    }
    
    public static Task createTask(User u ,Contact con, Boolean insertRecord) {
        Task task = new Task();
        task.OwnerId = u.Id;
        task.WhoId = con.Id;
        task.Type = 'Call (Not Connected)';
        if(insertRecord){
            try{
            insert task;
            }
            catch(System.DmlException ex){
                throw ex;
            }
        }   
        return task;
    }    

    public static Case createCase(Id accId,String status, String priority, String origin, String type, String subType, String subject, String description, Id ownerid) 
    {
        Case testCase = new Case();
        testCase.AccountId = accId;
        testCase.Status = status;
        testCase.Priority = priority;
        testCase.Origin = origin;
        testCase.Type = type;
        testCase.Sub_Type__c = subType;
        testCase.Subject = subject;
        testCase.Description = description;
        testCase.OwnerId = ownerid;
        testCase.Trial_Start_Date__c = date.parse('04/12/2016');
        testCase.Trial_End_Date__c = date.parse('05/20/2016');
        insert testCase;
        return testCase;
    }

    //@future
    public static void createCaseTeamRole(String name) 
    {
        CaseTeamRole testTeamRole = new CaseTeamRole();
        testTeamRole.Name = name;
        testTeamRole.AccessLevel = 'Edit';
        insert testTeamRole;
    }

    public static CaseTeamMember createCaseTeamMember(Id caseId , Id casRoleId, Id userId) 
    {
        CaseTeamMember testTeamMember = new CaseTeamMember();
        testTeamMember.ParentId = caseId;
        testTeamMember.MemberId = userId;
        testTeamMember.TeamRoleId = casRoleId;
        insert testTeamMember;
        return testTeamMember;
    }
    public static Follow_Rule_Setting__c createFollowRuleSetting(String name, Boolean insertRecord) 
    {
        Follow_Rule_Setting__c testSetting1 = new Follow_Rule_Setting__c();
        testSetting1.Name = name;
        testSetting1.isOpen__c = true;
        if(insertRecord){
            try{
                insert testSetting1;
            }
            catch(System.DmlException ex){
                throw ex;
            }
        }
        return testSetting1;
    }    

    public static Campaign createCampaign(String name, String status, Boolean active, String Type, Boolean insertRecord)
    {
        Campaign cam = new Campaign();
        cam.Name = name;
        cam.Status = status;
        cam.isActive = active;
        cam.Type = Type;
        if(insertRecord){
            try{
                insert cam;
            }
            catch(System.DmlException ex){
                throw ex;
            }
        }
        return cam;
    }

    public static CampaignMember createCampaignMember(Campaign campaign, Contact contact, String status,Boolean insertRecord)
    {
        CampaignMember camMember = new CampaignMember();
        camMember.campaignId = campaign.id;
        camMember.contactId = contact.id;
        camMember.status = status;
        camMember.createdDate =  System.now().addMinutes(-2);
        //camMember.lastModifiedDate = ;
        if(insertRecord){
            try{
                insert camMember;
            }
            catch(System.DmlException ex){
                throw ex;
            }
        }
        return camMember;
    }   
    
    public static AccountTeamMember createAccountTeamMember(Id accountId, string teamMemberRole, string userRegion, list<Id> excludeList)
    {
        User user = [select Id from User where region__c =: userRegion and isActive = true and Id not in: excludeList limit 1];
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.accountId = accountId;
        atm.UserId = user.Id;
        atm.TeamMemberRole = teamMemberRole;
        
        return atm;
    }
}