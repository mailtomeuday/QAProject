public with sharing class GS_HeatMapController_JU {
    
    public list<string> lstProducts {get;set;}
    //public list<HeatMapData> lstHeatMapData {get;set;}
    //public string jsonString {get;set;}
    public map<string, HeatMapData> mapOfAccountwithHeatMap {get;set;} 
    public map<Id,User> mapOfIdToUser;
    public map<Id,map<string,asset>> mapOfAccountProductAsset;
    public map<Id,map<string,work_order__c>> mapOfAccountProductWO;
    public boolean isCorporateHM;
    
    public class HeatMapData{
        public Id accountId {get;set;}
        public string AccountName {get;set;}
        public string clientStatus {get;set;}
        public string issuerMarketCap {get;set;}
        public string coverage {get;set;}
        public string billingCity {get;set;}
        public string billingState {get;set;}
        public string mostRecentInteraction {get;set;}
        public map<string, sObject> mapOfProdAndActivities {get;set;}
        
        public HeatMapData()
        {
            accountId = null;
            AccountName = '';
            clientStatus = '';
            issuerMarketCap = '';
            coverage = '';
            billingCity = '';
            billingState = '';
            mostRecentInteraction = '';
        }
    } 
    
    public void prepareHeatMapData(map<Id, Account> mapAccount, list<AccountTeamMember> lstAccountTeamMember)
    {
        mapOfAccountwithHeatMap = new map<string, HeatMapData>();
        //lstProducts = [select id,name from Product2 order by Name];
        mapOfIdToUser = new map<Id,User>([select Id, FirstName, LastName from User]);
        mapOfAccountProductAsset = new map<Id,map<string,asset>>();
        mapOfAccountProductWO = new map<Id,map<string,work_order__c>>();
        list<Id> accountIds = new list<Id>();
        accountIds.addAll(mapAccount.keyset());
        list<Account> accountsWithAssets = GS_AccountDMLHandler.getAssetsWorkOrdersByAccount(accountIds); 
        
        for(Account a : accountsWithAssets)
        {
            map<string,asset> assetMap = new map<string,asset>();
            map<string,work_order__c> woMap = new map<string,work_order__c>();
            
            for(Asset asset : a.Assets)
            {
                assetMap.put(asset.Product2.Name,asset);
            }
            
            mapOfAccountProductAsset.put(a.Id,assetMap);
            
            for(work_order__c wo : a.Work_Orders__r)
            {
                woMap.put(wo.Product__r.Name, wo);
            }
            
            mapOfAccountProductWO.put(a.Id, woMap);
        }
        
        set<Id> accTeamMemberSet = new set<Id>();
        
        for(AccountTeamMember acctmember : lstAccountTeamMember)
        {
            accTeamMemberSet.add(acctmember.Id);
        }
        
        //list<AccountTeamMember> lstAccountTeamMember = [select Id, AccountId, User.FirstName, User.LastName from AccountTeamMember where AccountId in: (mapAccount.keyset())];
        list<AccountTeamMember> templstAccountTeamMember = [select Id, AccountId, User.FirstName, User.LastName from AccountTeamMember where Id not in: accTeamMemberSet and AccountId in: (mapAccount.keyset())];
        
        lstAccountTeamMember.addAll(templstAccountTeamMember);
        
        map<string, list<string>> mapAccountIDCoverage = new map<string, list<string>>();
        
        for(AccountTeamMember atm : lstAccountTeamMember)
        {
            string coverage = atm.User.LastName + ', ' + atm.User.FirstName;
            
            if(mapAccountIDCoverage.containsKey(atm.AccountId)){
                list<string> coverageList = mapAccountIDCoverage.get(atm.AccountId);
                coverageList.add(coverage);
            }
            else{
                mapAccountIDCoverage.put(atm.AccountId, new list<string>{coverage});
            }
                        
        }
        
        for(Account acc : mapAccount.values())
        {
            HeatMapData objHeatMapData = new HeatMapData();
            
            objHeatMapData.accountId = acc.Id;
            objHeatMapData.AccountName = acc.Name;
            objHeatMapData.clientStatus = acc.Status__c;
            objHeatMapData.issuerMarketCap = acc.Market_Cap__c != null ? string.valueOf(acc.Market_Cap__c) : '';
            objHeatMapData.coverage = '';
            objHeatMapData.BillingCity = string.IsNotBlank(acc.BillingCity) ? acc.BillingCity : '';
            objHeatMapData.BillingState = string.IsNotBlank(acc.BillingState) ? acc.BillingState : '';
            list<string> lstCoverage = mapAccountIDCoverage.get(acc.Id);
            if(lstCoverage != null){ 
                for(string s: lstCoverage)
                {
                    objHeatMapData.coverage += s + ';'; 
                }
                
                objHeatMapData.coverage = objHeatMapData.coverage.substring(0, objHeatMapData.coverage.length() - 1);
            }

            mapOfAccountwithHeatMap.put(acc.Id,objHeatMapData);
        }
    }
    
    public void populateHeatMapData(list<sObject> lstActivities, map<Id, Account> mapAccount)
    {
        
        for(sObject activity : lstActivities)
        {
            HeatMapData objHeatMap = mapOfAccountwithHeatMap.get((string)activity.get('AccountId'));
            
            if(objHeatMap.mapOfProdAndActivities == null)
            {
                objHeatMap.mapOfProdAndActivities = new map<string,sObject>();
            }
            
            DateTime tempActivityDate;
            DateTime tempMostRecentActivityDate;
            
            tempMostRecentActivityDate =  (DateTime)activity.get('CreatedDate');
            
            if(activity.get('Products__c') != null && string.valueOf(activity.get('Products__c')).contains(';'))
            {
                list<string> productList =  string.valueOf(activity.get('Products__c')).split(';');
                
                for(string prod : productList)
                {
                    if(objHeatMap.mapOfProdAndActivities.containsKey(prod))
                    {
                        tempActivityDate = (DateTime)objHeatMap.mapOfProdAndActivities.get(prod).get('CreatedDate');
                        
                        if(tempMostRecentActivityDate > tempActivityDate)
                        {
                            objHeatMap.mapOfProdAndActivities.put(prod, activity);
                        }
                    }
                    else
                    {
                        objHeatMap.mapOfProdAndActivities.put(prod, activity);
                    }
                }
            }
            else
            {
                string prod = string.valueOf(activity.get('Products__c'));
                
                if(objHeatMap.mapOfProdAndActivities.containsKey(prod))
                {
                    tempActivityDate = (DateTime)objHeatMap.mapOfProdAndActivities.get(prod).get('CreatedDate');
                    
                    if(tempMostRecentActivityDate > tempActivityDate)
                    {
                        objHeatMap.mapOfProdAndActivities.put(prod, activity);
                    }
                }
                else
                {
                    objHeatMap.mapOfProdAndActivities.put(prod, activity);
                }
            }
            
        }
                
        
        //jsonString = JSON.Serialize(lstProductList) + JSON.Serialize(lstHeatMapData);
       // return createRows();
        
        //system.debug('populateHeatMapData-->>lstHeatMapData'+lstHeatMapData);
    }
    
    public  void createAttachment()
    {
        Folder heatMapFolder = [select id from Folder where Name =: 'Heat Map Reports'];
        Document doc = new Document();
        Blob test = Blob.valueOf(createRows());
        doc.FolderId = heatMapFolder.Id;
        doc.Name = 'HEAT_MAP_PARTIAL_FILE_'+ Datetime.now().format()+'.xls';
        doc.contenttype = 'EXCEL';
        doc.type = 'xls';
        doc.Body = test;
        insert doc;
    }
    
    public  string createTable(string createdRows, string selectedRoles, string region, integer marketCap)
    {
        system.debug('selectedRoles==='+selectedRoles);
        system.debug('region==='+region);
        string s = '<html> <head> <style> table { font-family: arial, sans-serif; border-collapse: collapse; width: 100%; }td, th { border: 1px solid #dddddd; text-align: left;padding: 8px; } </style> </head> <body><table>';
        s += '<tr><strong>Green < 120 days, Yellow: 120-180 days, Red > 180 days, Blue = Client, White = No Actions + Unknown Client Status</strong><br/>';
        s += '<strong>Report criteria</strong><br/><strong>Selected Roles:</strong> '+ selectedRoles +'<br/><strong> Region: </strong>'+ region; 
        s += !isCorporateHM ? '</tr>' : '<br/><strong> Vertical:</strong>Corporate<br/><strong> Issuer Market Cap (mm): </strong>'+ marketCap +'</tr>';        
        s += createHeader();
        s += createdRows;
        s += '</table></body> </html>';
        return s;
    }
    
    private  string createRows()
    {
        string rowData = '';
        
        for(HeatMapData hmData : mapOfAccountwithHeatMap.values())
        {
            datetime dtMostRecentInteraction = null;
            string strMostRecentInteraction = '';
            
            rowData += '<tr>';
            rowData += '<td>'+hmData.AccountName+'</td>';
            rowData += '<td>'+hmData.clientStatus+'</td>';
            if(isCorporateHM)
            {
                if(string.IsNotBlank(hmData.issuerMarketCap)){
                    decimal d = (Decimal.valueOf(hmData.issuerMarketCap)).setScale(2);
                    hmData.issuerMarketCap = string.valueOf(d);
                }
                rowData += '<td>'+hmData.issuerMarketCap+'</td>';
            }
            
            rowData += '<td>'+hmData.coverage+'</td>';
            
            if(isCorporateHM){
                rowData += '<td>'+hmData.billingCity+'</td>';
                rowData += '<td>'+hmData.billingState+'</td>';
            }
            rowData += '<td>{--mostRecentInteraction--}</td>';
            
            for(string productName : lstProducts)
            {
                if(hasActiveAsset(hmData.accountId, productName) || hasActiveWO(hmData.accountId, productName))
                {
                    rowData += '<td '+ colorCode('blue') +'></td>';
                    continue;
                }
                
                sObject tempObj;
                
                if(hmData.mapOfProdAndActivities != null){
                    tempObj = hmData.mapOfProdAndActivities.get(productName);              
                }
                
                if(tempObj != null){
                    system.debug('tempObj--------->>>'+tempObj);
                    string personName = getNameFromId((Id)tempObj.get('OwnerId')); 
                    system.debug('personName--------->>>'+personName);
                    DateTime dt = (DateTime)tempObj.get('CreatedDate'); 
                    rowData += '<td '+ colorCode(dt) +'>'+ personName + ' on '+ ((DateTime)tempObj.get('CreatedDate')).date().format()+'</td>';
                    //rowData += '<td '+ colorCode(dt) +'>'+ tempObj.get('CreatedDate')+'</td>';
                    if(dtMostRecentInteraction == null || dtMostRecentInteraction < (DateTime)tempObj.get('CreatedDate'))
                    {
                        dtMostRecentInteraction = (DateTime)tempObj.get('CreatedDate');
                        strMostRecentInteraction = personName + ' on ' +((DateTime)tempObj.get('CreatedDate')).date().format();
                    }
                }
                else
                {
                    rowData += '<td></td>';
                }
                
            }
            
            if(dtMostRecentInteraction != null){
                rowData = rowData.replace('<td>{--mostRecentInteraction--}</td>', '<td '+ colorCode(dtMostRecentInteraction) +'>'+ strMostRecentInteraction+'</td>');
            }
            else{
                rowData = rowData.replace('<td>{--mostRecentInteraction--}</td>', '<td></td>'); 
            }
                
            
            rowData += '</tr>';
        }
        
        return rowData;
    }

    private  string createHeader()
    {
        string headerString = ''; 
        if(isCorporateHM)      
            headerString += '<tr><th>Account</th><th>Client Status</th><th>Issuer Market Cap (mm)</th><th>Coverage</th><th>Billing City</th><th>Billing State</th><th>Most Recent Prospecting Activity</th>';      
        else
            headerString += '<tr><th>Account</th><th>Client Status</th><th>Coverage</th><th>Most Recent Prospecting Activity</th>';
            
        for(string prodName : lstProducts)
        {
            headerString += '<th>'+ prodName + '</th>';
        }
                
        headerString += '</tr>';    
            
        return headerString;
    }
    
    private string createCell(string style)
    {
        return null;    
    }
    
    private  string colorCode(datetime dt)
    {
        //Integer numberDaysDue = date.today().daysBetween(dt.date());
        Integer numberDaysDue = dt.date().daysBetween(date.today());
        if(numberDaysDue < 120)        
            return 'style = "background-color: green;"';
        else if(numberDaysDue >= 120 && numberDaysDue <= 180)
            return 'style = "background-color: yellow;"';
        else if(numberDaysDue > 180)
            return 'style = "background-color: red;"';
        else
            return '';  
    }
    
    private  string colorCode(string color)
    {
        return 'style = "background-color:' + color + ';"';
    }
    
    private string getNameFromId(Id userId)
    {
        User u = mapOfIdToUser.get(userId);
        return u.LastName +', '+u.FirstName;
    }
    
    private boolean hasActiveAsset(Id accountId, string productName)
    {
        boolean hasActiveAsset = false;
        
        map<string,asset> mapOfProductAsset = mapOfAccountProductAsset.get(accountId);
        
        if(mapOfProductAsset != null)
        {
            if(mapOfProductAsset.get(productName) != null && (mapOfProductAsset.get(productName)).Status == 'Active'){
                hasActiveAsset = true;
            }
        }
        
        return hasActiveAsset;
    }
    
    private boolean hasActiveWO(Id accountId, string productName)
    {
        boolean hasActiveWO = false;
        
        map<string,work_order__c> mapOfProductWO = mapOfAccountProductWO.get(accountId);
        
        if(mapOfProductWO != null)
        {
            if(mapOfProductWO.get(productName) != null && (mapOfProductWO.get(productName)).Active__c){
                hasActiveWO = true;
            }
        }
        
        return hasActiveWO;
    }
    
    public static string getInClauseFromSet(Set<Id> IdSet)
    {
        string strInClause = '(';
        for(string key : IdSet)
        {
            strInClause += '\''+key+'\',';
        }
        strInClause = strInClause.substring(0, strInClause.length() - 1);
        strInClause += ')';
        
        return strInClause;
    }
}