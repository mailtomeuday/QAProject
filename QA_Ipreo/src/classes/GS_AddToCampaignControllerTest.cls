@isTest
private class GS_AddToCampaignControllerTest {
    
    static testMethod void testAddToCampaign() {

        Test.startTest();
        List<Product2> products = new List<Product2>();
        Product2 coporateProduct = new Product2(
            Name = 'BD Corporate Governance',
            Vertical__c = 'Corporate',
            ProductCode = 'BDCG',
            Subgroup__c = 'BDC',
            Family = 'BDCG',
            Finance_Product_Code__c = 'BDCG'
        );
        Product2 gmgProduct = new Product2(
            Name = 'BD Advance (Derivatives)',
            Vertical__c = 'GMG',
            ProductCode = 'BDA - DV',
            Subgroup__c = 'BD',
            Family = 'BD Advanced',
            Finance_Product_Code__c = 'DIS'
        );
        products.add(coporateProduct);
        products.add(gmgProduct);
        insert products;


        Account a = new Account(
            Name = '86Research, LTD (Shanghai Office)',
            Status__c = 'Prospect',
            Vertical__c = 'Buyside',
            Account_Type__c = 'Family Office',
            BDTypeName__c = 'Family Office'

        );
        insert a;

        List<Contact> contacts = new List<Contact>();
        Contact c = new Contact(
            LastName = 'Test Contact',
            AccountId = a.Id,
            User_Status__c = 'Active'
        );
        Contact c2 = new Contact(
            LastName = 'Test Contact',
            AccountId = a.Id,
            User_Status__c = 'Inactive'
        );
        contacts.add(c);
        contacts.add(c2);
        insert contacts;

        List<Asset> assets = new List<Asset>();
        Asset asset1 = new Asset(
            Name = 'Asset1',
            AccountId = a.Id,
            Status = 'Active',
            Product_Region__c = 'LATAM',
            // Opportunity__c = o.Id,
            Product2Id = coporateProduct.Id
        );
        Asset asset2 = new Asset(
            Name = 'Asset2',
            AccountId = a.Id,
            Status = 'Active',
            Product_Region__c = 'EMEA',
            // Opportunity__c = o.Id,
            Product2Id = gmgProduct.Id
        );
        assets.add(asset1);
        assets.add(asset2);
        insert assets;

        List<User_Asset__c> userAssets = new List<User_Asset__c>();
        User_Asset__c userAsset1 = new User_Asset__c(
            Active__c = 'Active',
            Asset_Account__c = a.Id,
            Asset__c = asset1.Id,
            User__c = c.Id,
            Role__c = 'User',
            System_Outage_Notification_Opt_Out__c = true
        );
        User_Asset__c userAsset2 = new User_Asset__c(
            Active__c = 'Active',
            Asset_Account__c = a.Id,
            Asset__c = asset2.Id,
            User__c = c2.Id,
            Role__c = 'Comp User',
            System_Outage_Notification_Opt_Out__c = true
        );
        userAssets.add(userAsset1);
        userAssets.add(userAsset2);
        insert userAssets;

        Campaign cam = new Campaign(
            Name = 'Test Campaign 7-22',
            Status = 'In Progress',
            IsActive = true,
            Type = 'Email'
        );
        insert cam;

        Test.stopTest();
        List<User_Asset__c> ConfirmResults = new List<User_Asset__c>();
        ConfirmResults.add(userAsset1);
        ConfirmResults.add(userAsset2);
        PageReference pf = new PageReference('/apex/AddToCampaign');
        Test.setCurrentPage(pf);
        ApexPages.currentPage().getParameters().put('id', cam.Id);
        GS_AddToCampaignController con = new GS_AddToCampaignController();
        con.assetName = 'Asset';
        con.condition = 'e';
        con.contactBillingCountry = 'USA';
        con.billingCondition = 'c';
        con.doSearch();
        con.accountFilter = '2';
        con.vertical = 'GMG';
        con.dynamicProduct();
        con.vertical = 'Corporate';
        con.dynamicProduct();
        con.vertical = 'All';
        con.notificationIndex = '1';
        con.dynamicProduct();
        con.getConditionOptions();
        con.getRoleOptions();
        con.getUserAssets();
        con.getVerticalOptions();
        con.getAccountFilterOptions();
        con.getProductRegionOptions();
        con.getUserStatusOptions();
        con.getNotificationOptions();
        con.selectedProducts = new String[]{'BD Advance (Derivatives)', 'BD Corporate Governance'};
        con.doSearch();
        con.viewResult();
        con.ConfirmResults = ConfirmResults;
        con.addToCampaign();
        con.resetFilter();
        Boolean hasNext = con.hasNext;
        Boolean hasPrevious = con.hasPrevious;
        Integer pageNumber = con.pageNumber;
        con.first();
        con.last();
        con.previous();
        con.next();
        con.cancel();
        
    }

    static testMethod void testDoSearch() {

        Test.startTest();
        List<Product2> products = new List<Product2>();
        Product2 coporateProduct = new Product2(
            Name = 'BD Corporate Governance',
            Vertical__c = 'Corporate',
            ProductCode = 'BDCG',
            Subgroup__c = 'BDC',
            Family = 'BDCG',
            Finance_Product_Code__c = 'BDCG'
        );
        Product2 gmgProduct = new Product2(
            Name = 'BD Advance (Derivatives)',
            Vertical__c = 'GMG',
            ProductCode = 'BDA - DV',
            Subgroup__c = 'BD',
            Family = 'BD Advanced',
            Finance_Product_Code__c = 'DIS'
        );
        products.add(coporateProduct);
        products.add(gmgProduct);
        insert products;


        Account a = new Account(
            Name = '86Research, LTD (Shanghai Office)',
            Status__c = 'Prospect',
            Vertical__c = 'Buyside',
            Account_Type__c = 'Family Office'

        );
        insert a;

        List<Contact> contacts = new List<Contact>();
        Contact c = new Contact(
            LastName = 'Test Contact',
            AccountId = a.Id,
            User_Status__c = 'Active'
        );
        Contact c2 = new Contact(
            LastName = 'Test Contact',
            AccountId = a.Id,
            User_Status__c = 'Inactive'
        );
        contacts.add(c);
        contacts.add(c2);
        insert contacts;

        List<Asset> assets = new List<Asset>();
        Asset asset1 = new Asset(
            Name = 'Asset1',
            AccountId = a.Id,
            Status = 'Active',
            Product_Region__c = 'LATAM',
            // Opportunity__c = o.Id,
            Product2Id = coporateProduct.Id
        );
        Asset asset2 = new Asset(
            Name = 'Asset2',
            AccountId = a.Id,
            Status = 'Active',
            Product_Region__c = 'EMEA',
            // Opportunity__c = o.Id,
            Product2Id = gmgProduct.Id
        );
        assets.add(asset1);
        assets.add(asset2);
        insert assets;

        List<User_Asset__c> userAssets = new List<User_Asset__c>();
        User_Asset__c userAsset1 = new User_Asset__c(
            Active__c = 'Active',
            Asset_Account__c = a.Id,
            Asset__c = asset1.Id,
            User__c = c.Id,
            Role__c = 'User',
            System_Outage_Notification_Opt_Out__c = true
        );
        User_Asset__c userAsset2 = new User_Asset__c(
            Active__c = 'Active',
            Asset_Account__c = a.Id,
            Asset__c = asset2.Id,
            User__c = c2.Id,
            Role__c = 'Comp User',
            System_Outage_Notification_Opt_Out__c = true
        );
        userAssets.add(userAsset1);
        userAssets.add(userAsset2);
        insert userAssets;

        Campaign cam = new Campaign(
            Name = 'Test Campaign 7-22',
            Status = 'In Progress',
            IsActive = true,
            Type = 'Email'
        );
        insert cam;

        Test.stopTest();
        PageReference pf = new PageReference('/apex/AddToCampaign');
        Test.setCurrentPage(pf);
        ApexPages.currentPage().getParameters().put('id', cam.Id);
        GS_AddToCampaignController con = new GS_AddToCampaignController();
        con.assetName = 'Asset';
        con.role = new String[]{'A'};
        con.condition = 'e';
        con.contactBillingCountry = 'USA';
        con.billingCondition = 'c';
        con.vertical = '1';
        con.selectedProducts = new String[]{'A'};
        con.doSearch();
        con.role = null;
        con.selectedProducts = null;
        con.accountFilter = '3';
        con.userStatus = '-';
        con.vertical = '-';
        con.verify();
    }
}