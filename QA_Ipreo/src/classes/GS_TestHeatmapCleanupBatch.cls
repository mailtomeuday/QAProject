@isTest(SeeAllData=true)
private class GS_TestHeatmapCleanupBatch {
    
    static testMethod void HeatmapCleanupTest() 
    {
        Test.startTest();
        createHeatMaps();
        Test.stopTest();
        
        GS_HeatmapCleanupBatch batch = new GS_HeatmapCleanupBatch();
        database.executeBatch(batch);
    }
    
    static testMethod void HeatmapCleanupNegativeTest() 
    {
        createHeatMaps();
        
        User u = GS_TestDataCreator.createUser('Read Only', 'test1234@test5678.com');
        
        system.runAs(u)
        {
            Test.startTest();
            system.debug('u------'+u.lastname);
            GS_HeatmapCleanupBatch batch = new GS_HeatmapCleanupBatch();
            batch.failureReasons = 'Insufficient Permission to delete';
            batch.failedRecCount = 1;
            database.executeBatch(batch);
            Test.stopTest();
        }
        
    }
    
     
    static void createHeatMaps()
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
        
        System.schedule(strJobName, chronExpression, mergeController);
        Folder heatMapFolder = [select Id from Folder where Name = 'Heat Map Reports'];
        list<Document> lstAtt = [Select Id,FolderId, Name,body,ContentType From Document where FolderId =:heatMapFolder.Id and CreatedById =: UserInfo.getUserId() and Name like:'HEAT_MAP_PARTIAL_FILE_%'];
        
        mergeController.MergeReports(lstAtt, heatMapFolder.Id);
    }
}