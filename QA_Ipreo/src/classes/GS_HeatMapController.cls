public class GS_HeatMapController {
    
    public list<Product2> lstProducts {get;set;}
    public map<Id,User> mapOfIdToUser;
    
    public class HeatMapData{
        public Id accountId {get;set;}
        public string AccountName {get;set;}
        public string clientStatus {get;set;}
        public string coverage {get;set;}
        public string mostRecentInteraction {get;set;}
        public map<string, sObject> mapOfProdAndActivities {get;set;}
        
        public HeatMapData()
        {
            accountId = null;
            AccountName = '';
            clientStatus = '';
            coverage = '';
            mostRecentInteraction = '';
        }
    } 
        
    public string populateHeatMapData(list<Account> lstAccount)
    {
        string strHeatMapBatchData = '';
        list<sObject> lstActivities;
        map<string, HeatMapData> mapOfAccountwithHeatMap = new map<string, HeatMapData>();
        HeatMapData objHeatMap;
        lstProducts = [select id,name from Product2 order by Name];
    	mapOfIdToUser = new map<Id,User>([select Id, FirstName, LastName from User]);
    	
        for(Account acc : lstAccount)
        {
            lstActivities = new list<sObject>();
            
            lstActivities.addAll((list<sObject>)acc.Tasks);
            
            lstActivities.addAll((list<sObject>)acc.Events);
            
            list<string> coverageList = new list<string>();
            
            for(AccountTeamMember atm : acc.AccountTeamMembers)
            {
                string coverage = atm.User.LastName + ', ' + atm.User.FirstName;
                coverageList.add(coverage);
            }
            
            objHeatMap = mapOfAccountwithHeatMap.get((string)acc.Id);
                
            if(objHeatMap == null)
            {
                objHeatMap = new HeatMapData();
        
                objHeatMap.accountId = acc.Id;
                objHeatMap.AccountName = acc.Name;
                objHeatMap.clientStatus = acc.Status__c;
                objHeatMap.coverage = '';
                for(string s: coverageList)
                {
                    objHeatMap.coverage += s + ';'; 
                }
    
                mapOfAccountwithHeatMap.put(acc.Id, objHeatMap);
                
            }
            
            for(sObject activity : lstActivities)
            {
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
            
            strHeatMapBatchData += createRows(objHeatMap, acc);
        }
        
        return strHeatMapBatchData;
    }
    
    public  void createAttachment(string strHeatMapData)
    {
        Folder heatMapFolder = [select id from Folder where Name =: 'Heat Map Reports'];
        Document doc = new Document();
        Blob test = Blob.valueOf(strHeatMapData);
        doc.FolderId = heatMapFolder.Id;
        doc.Name = 'Heat Map_'+ Datetime.now().format()+'.xls';
        doc.contenttype = 'EXCEL';
        doc.type = 'xls';
        doc.Body = test;
        insert doc;
    }
    
    public  string createTable(string createdRows, string selectedRoles, string region)
    {
        system.debug('selectedRoles==='+selectedRoles);
        system.debug('region==='+region);
        string s = '<html> <head> <style> table { font-family: arial, sans-serif; border-collapse: collapse; width: 100%; }td, th { border: 1px solid #dddddd; text-align: left;padding: 8px; } </style> </head> <body><table>';
        s += '<tr><strong>Green < 120 days, Yellow: 120-180 days, Red > 180 days, Blue = Client, White = No Actions + Unknown Client Status</strong><br/>';
        s += '<strong>Report criteria - Selected Roles: </strong>'+ selectedRoles +'<br/><strong> Region:</strong>'+ region +'</tr>';
        s += createHeader();
        s += createdRows;
        s += '</table></body> </html>';
        return s;
    }
    
    private string createRows(HeatMapData hmData, Account acc)
    {
        map<Id,map<string,asset>> mapOfAccountProductAsset = new map<Id,map<string,asset>>();
        map<Id,map<string,work_order__c>> mapOfAccountProductWO = new map<Id,map<string,work_order__c>>();
        map<string,asset> assetMap = new map<string,asset>();
        map<string,work_order__c> woMap = new map<string,work_order__c>();
            
        for(Asset asset : acc.Assets)
        {
            assetMap.put(asset.Product2.Name,asset);
        }
        
        mapOfAccountProductAsset.put(acc.Id,assetMap);
        
        for(work_order__c wo : acc.Work_Orders__r)
        {
            woMap.put(wo.Product__r.Name, wo);
        }
        
        mapOfAccountProductWO.put(acc.Id, woMap);
        
        string rowData = '';
        
        datetime dtMostRecentInteraction = null;
        string strMostRecentInteraction = '';
        
        rowData += '<tr>';
        rowData += '<td>'+hmData.AccountName+'</td>';
        rowData += '<td>'+hmData.clientStatus+'</td>';
        rowData += '<td>'+hmData.coverage+'</td>';
        rowData += '<td>{--mostRecentInteraction--}</td>';
        
        for(Product2 product : lstProducts)
        {
            if(hasActiveAsset(hmData.accountId, product.Name, mapOfAccountProductAsset) || hasActiveWO(hmData.accountId, product.Name, mapOfAccountProductWO))
            {
                rowData += '<td '+ colorCode('blue') +'></td>';
                continue;
            }
            
            sObject tempObj;
            
            if(hmData.mapOfProdAndActivities != null){
                tempObj = hmData.mapOfProdAndActivities.get(product.Name);              
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
        
        return rowData;
        
    }
    
    private  string createHeader()
    {
        string headerString = '';       
        headerString += '<tr><th>Account</th><th>Client Status</th><th>Coverage</th><th>Most Recent Interaction</th>';      
        
        for(Product2 prod : lstProducts)
        {
            headerString += '<th>'+ prod.Name+ '</th>';
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
    
    private boolean hasActiveAsset(Id accountId, string productName, map<Id,map<string,asset>> mapOfAccountProductAsset)
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
    
    private boolean hasActiveWO(Id accountId, string productName, map<Id,map<string,work_order__c>> mapOfAccountProductWO)
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