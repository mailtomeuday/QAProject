public class GS_HeatmapAccountFilterController 
{
    public String region {get;set;}
    public Integer countOfAccounts {get;set;}
    public String[] RoleIds{get;set;} 
    public SelectOption[] SelectedRoleOptions{get;set;} 
    public SelectOption[] RoleOptions{get;set;} 
    public final Integer RECORDS_PER_FILE = 500;
    public set<Id> setHeatMapJobID;
    public boolean disableButton{get;set;}
    public string strSelectedRoleOptions = '';
    public integer marketCapValue{get;set;}
    private integer ACC_TEAM_MEMBER_LIMIT;
    private integer ACCOUNTS_LIMIT;
    private integer ACCOUNT_LIMIT_EXCLUDE;
    
    public GS_HeatmapAccountFilterController(){
        disableButton = false;
        SelectedRoleOptions = new List<SelectOption>();
        RoleOptions = getRoleOptions();
        marketCapValue = 100;
    }
            
    public List<SelectOption> getRegionOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Account.Region__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('', ' None '));    
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }       
        return options;
    }
    
    public List<SelectOption> getRoleOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        //options.add(new SelectOption('', ' None '));    
        for( UserRole ur : [select Id,Name from UserRole])
        {
            options.add(new SelectOption((string)ur.Id, ur.Name));
        }       
        return options;
    }
    
    public PageReference FilterAccountsByRole()
    {
    	deletePartialFiles();//delete stale partial files if any.
    	
        list<string> lstProductNames = new list<string>();
        boolean isCorp = Boolean.valueOf(ApexPages.currentPage().getParameters().get('IsCorp'));
        
        if(isCorp)
        {
            ACCOUNTS_LIMIT = 7000;
            ACCOUNT_LIMIT_EXCLUDE = 2000;
            ACC_TEAM_MEMBER_LIMIT = 44000;
            List<Products_For_Corporate_Heat_Map__c> lstCorpProds = GS_CustomSettingDMLHandler.getProductsForHeatMap();
            for(Products_For_Corporate_Heat_Map__c corpProd : lstCorpProds)
            {
                lstProductNames.add(corpProd.Product_Name__c);
            }
        }
        else
        {
            marketCapValue = Null;
            ACCOUNTS_LIMIT = 3000;
            ACC_TEAM_MEMBER_LIMIT = 38000;
            List<Product2> lstCorpProds = GS_ProductDMLHandler.getAllProducts();
            for(Product2 corpProd : lstCorpProds)
            {
                lstProductNames.add(corpProd.Name);
            }
        }
        
        system.debug('isCorp---->>'+isCorp);
        list<AccountTeamMember> lstAccountTeamMember;
        RoleIds = new List<String>();
        set<Id> setRoleID = new set<Id>();
        
        System.debug(SelectedRoleOptions);
        if(SelectedRoleOptions.isEmpty())
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select roles to generate the report.');
            ApexPages.addMessage(myMsg);
            return null;    
        }
        
        for(SelectOption so : SelectedRoleOptions ){
            RoleIds.add(so.getValue());
            setRoleID.add((Id)so.getValue());
            strSelectedRoleOptions += so.getLabel()+ ',';
        }
        
        if(!string.isEmpty(strSelectedRoleOptions)){
            strSelectedRoleOptions = strSelectedRoleOptions.substring(0, strSelectedRoleOptions.length() - 1);
        }
        System.debug('RoleIds=====>>'+RoleIds);
        
        if(region != null)
        {
            if(isCorp)
            {
                lstAccountTeamMember = [select Id, AccountId, Account.Name,Account.Status__c,Account.BillingState, Account.BillingCity, Account.Market_Cap__c, User.FirstName, User.LastName  from AccountTeamMember where User.UserRoleId in: RoleIds and Account.Vertical__c =: 'Corporate' and Account.Market_Cap__c >=: marketCapValue limit :ACC_TEAM_MEMBER_LIMIT];   
            }
            else
            {
                lstAccountTeamMember = [select Id, AccountId, Account.Name,Account.Status__c, User.FirstName, User.LastName, Account.Market_Cap__c  from AccountTeamMember where User.UserRoleId in: RoleIds and Account.Region__c =: region limit :ACC_TEAM_MEMBER_LIMIT];
            }
        }
        else
        {
            if(isCorp)
            {
                lstAccountTeamMember = [select Id, AccountId, Account.Name,Account.Status__c,User.FirstName, Account.BillingState, Account.BillingCity,User.LastName,Account.Market_Cap__c  from AccountTeamMember where User.UserRoleId in: RoleIds and Account.Vertical__c =: 'Corporate' and Account.Market_Cap__c >=: marketCapValue limit :ACC_TEAM_MEMBER_LIMIT]; 
            }
            else
            {
                lstAccountTeamMember = [select Id, AccountId, Account.Name,Account.Status__c,User.FirstName, User.LastName  from AccountTeamMember where User.UserRoleId in: RoleIds limit :ACC_TEAM_MEMBER_LIMIT];
            }
            
        }
        
        System.debug('lstAccountTeamMember.size()=====>>'+lstAccountTeamMember.size());
        
        //list<AccountTeamMember> lstAccountTeamMember = [select Id, AccountId, Account.Name,Account.Status__c,User.FirstName, User.LastName  from AccountTeamMember where User.UserRoleId in: RoleIds limit 38000];
        
        if(lstAccountTeamMember.size() == ACC_TEAM_MEMBER_LIMIT)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Report cannot be created with the current criteria. The query returned more than <strong>' + lstAccountTeamMember.size() + '</strong> Account Team Member records. Please narrow your search criteria to generate the report.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        map<Id, Account> mapOfIdToAccount = new map<Id, Account>();
        
        for(AccountTeamMember atm : lstAccountTeamMember)
        {
            Account acc = new Account();
            acc.Id = atm.AccountId;
            acc.Name = atm.Account.Name;
            acc.Status__c = atm.Account.Status__c;
            if(isCorp)
            {
                acc.billingCity = atm.Account.billingCity;
                acc.billingState = atm.Account.billingState;
                acc.Market_Cap__c = atm.Account.Market_Cap__c; 
            }
            mapOfIdToAccount.put(atm.AccountId, acc);
        }
        
        system.debug('Accounts matching with Account Team Member Roles:'+mapOfIdToAccount.size());
        
        if(isCorp)
        {
            map<Id, Account> tempAccountMap;
            
            if(region != null){
                tempAccountMap = new map<Id, Account>([select Id,Name,BillingState,BillingCity,Status__c,Market_Cap__c from Account where Region__c =: region and Vertical__c =: 'Corporate' and Market_Cap__c >=: marketCapValue and Id not in: mapOfIdToAccount.keyset()]);
            }
            else{
                tempAccountMap = new map<Id, Account>([select Id,Name,BillingState,BillingCity,Status__c,Market_Cap__c from Account where Vertical__c =: 'Corporate' and Market_Cap__c >=: marketCapValue and Id not in: mapOfIdToAccount.keyset()]);
            }   
            
            /*if(tempAccountMap.size() == ACCOUNT_LIMIT_EXCLUDE)
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please narrow your search as the report cannot be created with these many Account records.');
                ApexPages.addMessage(myMsg);
                return null;
            }*/
            
            system.debug('Accounts NOT matching with Account Team Member Roles:'+tempAccountMap.size());
            
            if(tempAccountMap != null){
                mapOfIdToAccount.putAll(tempAccountMap);
            }
        }
        
        countOfAccounts = mapOfIdToAccount.size();
        
        system.debug('Count of accounts '+countOfAccounts);
        
        if(countOfAccounts > ACCOUNTS_LIMIT)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Report cannot be created with the current criteria. The query returned more than <strong>' + countOfAccounts + '</strong> Account records. Please narrow your search criteria to generate the report.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        string message = ''; 
        
        if(countOfAccounts > 0)
        {
            message = 'Report will contain '+countOfAccounts+' Records. You will receive an email with the report at: '+UserInfo.getUserEmail()+' once the report is generated.'; 
            BatchInvoke(mapOfIdToAccount, lstAccountTeamMember, setRoleID, lstProductNames, isCorp);
            disableButton = true;
        }
        else
        {
            message = 'No Records Found.';
        }
        
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, message);
        ApexPages.addMessage(myMsg);
        
        return null;
    }
    
    public PageReference AbortOperation()
    {
        List<AsyncApexJob> jobs = [SELECT Id, ApexClass.Name,Status FROM AsyncApexJob where Status in ('Holding','Queued','Preparing','Processing') and ApexClass.Name = 'GS_HeatMapBatchJob_JU' and createdById =: UserInfo.getUserID()];
        for(AsyncApexJob job : jobs)
        {
            System.abortJob(job.Id);
            system.debug('Aborted Job: '+ job.Id + 'Status of the job: '+job.Status);
        }
    	//abort scheduled job
        String strJobName = 'Heat Map Merge Job _' + UserInfo.getUserId();
        GS_MergeHeatMapScheduler objHeatMapScheduler = new GS_MergeHeatMapScheduler(setHeatMapJobID, strJobName, region, 0, '', null, 0);
        objHeatMapScheduler.abortJob(strJobName);
        deletePartialFiles();
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'Operation has been aborted.');
        ApexPages.addMessage(myMsg);
        disableButton = false;
        return null;
    }
    
    public void BatchInvoke(map<Id,Account> mapIdToAccount, list<AccountTeamMember> lstAccTeamMember, Set<Id> setRoleID, list<string> lstProductNames, boolean isCorporate) 
    {
        setHeatMapJobID = new set<Id>();
        //Folder heatMapFolder = [select Id from Folder where Name = 'Heat Map Reports'];
        //delete [Select Id From Document where FolderId =:heatMapFolder.Id and CreatedById =: UserInfo.getUserId()];
        
        Integer listSize = mapIdToAccount.size();
        map<Id, Account> mapAccount = new map<Id, Account> ();
        Integer count = 0;
        for(Account a : mapIdToAccount.values())
        {
            mapAccount.put(a.Id, a);
            count++;
            listSize--;
            
            if(count == RECORDS_PER_FILE || listSize == 0)
            {
                GS_HeatMapBatchJob_JU batch = new GS_HeatMapBatchJob_JU(mapAccount, lstAccTeamMember, setRoleID, lstProductNames, isCorporate);
                setHeatMapJobID.add(database.executeBatch(batch, 2000));
                count = 0;
                mapAccount = new map<Id, Account>();
            }
        }
        
        Datetime sysTime = System.now().addSeconds( 30 );      
        String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        String strJobName = 'Heat Map Merge Job _' + UserInfo.getUserId();
        Integer numFilesGen;
        
        system.debug('Count of accounts '+countOfAccounts);
        
        if(countOfAccounts < RECORDS_PER_FILE)
            numFilesGen = 1;
        else    
            numFilesGen = Math.Mod(countOfAccounts, RECORDS_PER_FILE) == 0 ? (countOfAccounts / RECORDS_PER_FILE)  : (countOfAccounts / RECORDS_PER_FILE) + 1;
        if(!test.isrunningtest()){
            //Abort any job with same name if it is already running
            GS_MergeHeatMapScheduler objHeatMapScheduler = new GS_MergeHeatMapScheduler(setHeatMapJobID, strJobName, region, numFilesGen, strSelectedRoleOptions, lstProductNames, marketCapValue);
            objHeatMapScheduler.abortJob(strJobName);
            System.schedule(strJobName, chronExpression, objHeatMapScheduler);
        }
        
    }
    
    private void deletePartialFiles()
    {
    	list<Folder> lstHeatMapFolder = [select Id from Folder where Name = 'Heat Map Reports'];
    	if(lstHeatMapFolder != null && lstHeatMapFolder.size() > 0){
    		list<Document> lstAtt = [Select Id From Document where FolderId =: lstHeatMapFolder[0].Id and CreatedById =: UserInfo.getUserId() and Name like:'HEAT_MAP_PARTIAL_FILE_%'];
    		if(lstAtt != null && lstAtt.size() > 0){
    			delete lstAtt;
    		}
    	}
    }
}