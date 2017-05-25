/**************************************************************************************************
 * Name           : GS_TestHeatmapAccountFilterController
 * Object         : 
 * Requirement    : 
 * Target         : Test class for Heat map report code 
 * Refer classes  : 
 * Author         : Ambadas Joshi Morkhandikar (ambadas_morkhandikar@epam.com)
 * Create Date    : 2016-09-13
 * Modify History :
 **************************************************************************************************/
@isTest(SeeAllData=true)
public with sharing class GS_TestHeatmapAccountFilterController 
{
    static testMethod void GetGMGReport() 
    {	
    	ApexPages.currentPage().getParameters().put('IsCorp','false');
        GS_HeatmapAccountFilterController filterCon = new GS_HeatmapAccountFilterController();
        filterCon.getRegionOptions();
        filterCon.SelectedRoleOptions = new List<SelectOption>();
        UserRole testUserRole = [select Id from UserRole where Name = 'GMG APAC Sales Rep'];
        selectoption opt = new SelectOption(testUserRole.Id, 'GMG APAC Sales Rep');
        filterCon.SelectedRoleOptions.add(opt);
        
        filterCon.FilterAccountsByRole();
        
        Datetime sysTime = System.now().addSeconds( 30 );      
        String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        String strJobName = 'Test_Heat Map For GMG Merge Job _' + UserInfo.getUserId();
        Integer numFilesGen;
        
        if(filterCon.countOfAccounts < 500)
            numFilesGen = 1;
        else    
            numFilesGen = Math.Mod(filterCon.countOfAccounts, 500) == 0 ? (filterCon.countOfAccounts / 500)  : (filterCon.countOfAccounts / 500) + 1;
        //set<ID> jobIdSet, string jobName, string selectedRegion, integer numFilesGen, string strRolesSelected, list<string> lstProductNames, double marketCapVal
        list<string> lstProductNames = new list<string>();
        List<Product2> lstCorpProds = GS_ProductDMLHandler.getAllProducts();
		for(Product2 corpProd : lstCorpProds)
		{
			lstProductNames.add(corpProd.Name);
		}
        GS_MergeHeatMapScheduler mergeController = new GS_MergeHeatMapScheduler(filterCon.setHeatMapJobID, strJobName, filterCon.region, numFilesGen, filterCon.strSelectedRoleOptions,lstProductNames,filterCon.marketCapValue);
        
        Test.startTest();
        System.schedule(strJobName, chronExpression, mergeController);
        Test.stopTest();
        //mergeController.execute();
        
        List<Id> lstCurrentUserId = new List<Id>{UserInfo.getUserId()};
        //for coverage
        User u = [select Id from User where ProfileId in (Select Id from Profile where Name = 'System Administrator') and Id not in: (lstCurrentUserId) and IsActive = true limit 1];
        /*system.runAs(u)
        {
        	System.schedule(strJobName+'_'+u.Id, chronExpression, new GS_MergeHeatMapScheduler(filterCon.setHeatMapJobID, strJobName+'_'+u.Id, filterCon.region, numFilesGen, filterCon.strSelectedRoleOptions,lstProductNames,filterCon.marketCapValue));
        	filterCon.AbortOperation();
        }*/
    }
    
    static testMethod void GetCorporateReport() 
    {
    	ApexPages.currentPage().getParameters().put('IsCorp','true');
        GS_HeatmapAccountFilterController filterCon = new GS_HeatmapAccountFilterController();
        filterCon.marketCapValue = 1000;
        filterCon.region = 'North America';
        filterCon.getRegionOptions();
        filterCon.SelectedRoleOptions = new List<SelectOption>();
        UserRole testUserRole = [select Id from UserRole where Name = 'Corporate Americas Sales Rep'];
        selectoption opt = new SelectOption(testUserRole.Id, 'Corporate Americas Sales Rep');
        filterCon.SelectedRoleOptions.add(opt);
        
        filterCon.FilterAccountsByRole();
        
        Datetime sysTime = System.now().addSeconds( 30 );      
        String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        String strJobName = 'Test_Heat Map For Corp Merge Job _' + UserInfo.getUserId();
        Integer numFilesGen;
        
        if(filterCon.countOfAccounts < 500)
            numFilesGen = 1;
        else    
            numFilesGen = Math.Mod(filterCon.countOfAccounts, 500) == 0 ? (filterCon.countOfAccounts / 500)  : (filterCon.countOfAccounts / 500) + 1;
        //set<ID> jobIdSet, string jobName, string selectedRegion, integer numFilesGen, string strRolesSelected, list<string> lstProductNames, double marketCapVal
        list<string> lstProductNames = new list<string>();
        List<Products_For_Corporate_Heat_Map__c> lstCorpProds = GS_CustomSettingDMLHandler.getProductsForHeatMap();
		for(Products_For_Corporate_Heat_Map__c corpProd : lstCorpProds)
		{
			lstProductNames.add(corpProd.Product_Name__c);
		}
        GS_MergeHeatMapScheduler mergeController = new GS_MergeHeatMapScheduler(filterCon.setHeatMapJobID, strJobName, filterCon.region, numFilesGen, filterCon.strSelectedRoleOptions,lstProductNames,filterCon.marketCapValue);
        
        Test.startTest();
        System.schedule(strJobName, chronExpression, mergeController);
        Test.stopTest();
        //mergeController.MergeReports();
        
        List<Id> lstCurrentUserId = new List<Id>{UserInfo.getUserId()};
        //for coverage
        User u = [select Id from User where ProfileId in (Select Id from Profile where Name = 'System Administrator') and Id not in: (lstCurrentUserId) and IsActive = true limit 1];
        system.debug('user------->>'+u);
       /* system.runAs(u)
        {
        	System.schedule(strJobName+'_'+u.Id, chronExpression, new GS_MergeHeatMapScheduler(filterCon.setHeatMapJobID, strJobName+'_'+u.Id, filterCon.region, numFilesGen, filterCon.strSelectedRoleOptions,lstProductNames,filterCon.marketCapValue));
        	filterCon.AbortOperation();
        }*/
        
        
    }
}