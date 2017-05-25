public with sharing class GS_HeatMapController_Joshi {
    
    static list<Product2> lstProducts {get;set;}
    //public list<HeatMapData> lstHeatMapData {get;set;}
    //public string jsonString {get;set;}
    static map<string, HeatMapData> mapOfAccountwithHeatMap {get;set;} 
    
    public class HeatMapData{
        public string AccountName {get;set;}
        public string clientStatus {get;set;}
        public string coverage {get;set;}
        public string mostRecentInteraction {get;set;}
        public map<string, sObject> mapOfProdAndActivities {get;set;}
    } 
    
    public static string populateHeatMapData(list<sObject> lstActivities, map<Id, Account> mapAccount)
    {
        mapOfAccountwithHeatMap = new map<string, HeatMapData>();
        
        lstProducts = [select id,name from Product2 order by Name limit 30];
        
        //lstHeatMapData = new list<HeatMapData>();
        
        //map<Id, Account> mapAccount = new Map<Id, Account>([select Id, Name, Status__c from Account where Vertical__c != 'Corporate']);
        
        list<AccountTeamMember> lstAccountTeamMember = [select Id, AccountId, User.FirstName, User.LastName from AccountTeamMember where AccountId in: (mapAccount.keyset())];
        
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
            
            objHeatMapData.AccountName = acc.Name;
            objHeatMapData.clientStatus = acc.Status__c;
            objHeatMapData.coverage = '';
            list<string> lstCoverage = mapAccountIDCoverage.get(acc.Id);
            if(lstCoverage != null){ 
                for(string s: lstCoverage)
                {
                    objHeatMapData.coverage += s + ';'; 
                }
            }

            mapOfAccountwithHeatMap.put(acc.Id,objHeatMapData);
            //lstHeatMapData.add(objHeatMapData);
        }
        
        //list<sObject> lstActivities = new list<sObject>();
        //list<sobject> lstTask = [select id,AccountId,Products__c,LastModifiedDate from Task where whatId__c in ('001','006') and whoId__c = '003' and AccountId in: mapAccount.keyset() limit 5000];
        //lstActivities.addAll(lstTask);
        //list<sobject> lstEvent = [select id,AccountId,Products__c,LastModifiedDate from Event where whatId__c in ('001','006') and whoId__c = '003' and AccountId in: mapAccount.keyset() limit 5000];
        //lstActivities.addAll(lstEvent);
        
        map<string, map<string,sObject>> mapOfAccountProdAndActivities = new map<string, map<string,sObject>>();
        
        for(sObject activity : lstActivities)
        {
            HeatMapData objHeatMap = mapOfAccountwithHeatMap.get((string)activity.get('AccountId'));
            
            if(objHeatMap.mapOfProdAndActivities == null)
            {
                objHeatMap.mapOfProdAndActivities = new map<string,sObject>();
            }
            
            DateTime tempActivityDate;
            DateTime tempMostRecentActivityDate;
            
            tempMostRecentActivityDate =  (DateTime)activity.get('LastModifiedDate');
            
            if(activity.get('Products__c') != null && string.valueOf(activity.get('Products__c')).contains(';'))
            {
                list<string> productList =  string.valueOf(activity.get('Products__c')).split(';');
                
                for(string prod : productList)
                {
                    if(objHeatMap.mapOfProdAndActivities.containsKey(prod))
                    {
                        tempActivityDate = (DateTime)objHeatMap.mapOfProdAndActivities.get(prod).get('LastModifiedDate');
                        
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
                    tempActivityDate = (DateTime)objHeatMap.mapOfProdAndActivities.get(prod).get('LastModifiedDate');
                    
                    if(tempMostRecentActivityDate > tempActivityDate)
                    {
                        objHeatMap.mapOfProdAndActivities.put(prod, activity);
                    }
                }
            }
            
        }
                
        
        //jsonString = JSON.Serialize(lstProductList) + JSON.Serialize(lstHeatMapData);
        return createRows();
        
        //system.debug('populateHeatMapData-->>lstHeatMapData'+lstHeatMapData);
    }
    
    public static void createAttachment(string createdRows)
    {
        lstProducts = [select id,name from Product2 order by Name limit 30];
        Account acc = [select id from Account where name =: 'Test Account Joshi 1'];
        Attachment att = new Attachment();
        Blob test = Blob.valueOf(createTable(createdRows));
        att.ParentId = acc.Id;
        att.Name = 'Heat Map_'+ Datetime.now().format()+'.xls';
        att.contenttype = 'EXCEL';
        att.Body = test;
        insert att;
    }
    
    private static string createTable(string createdRows)
    {
        string s = '<html> <head> <style> table { font-family: arial, sans-serif; border-collapse: collapse; width: 100%; }td, th { border: 1px solid #dddddd; text-align: left;padding: 8px; } </style> </head> <body><table>';
        s += createHeader();
        s += createdRows;
        s += '</table></body> </html>';
        return s;
    }
    
    private static string createRows()
    {
        string rowData = '';
        
        for(HeatMapData hmData : mapOfAccountwithHeatMap.values())
        {
            rowData += '<tr>';
            rowData += '<td>'+hmData.AccountName+'</td>';
            rowData += '<td>'+hmData.clientStatus+'</td>';
            rowData += '<td>'+hmData.coverage+'</td>';
            rowData += '<td>'+hmData.mostRecentInteraction+'</td>';
            for(Product2 product : lstProducts)
            {
                sObject tempObj;
                if(hmData.mapOfProdAndActivities != null){
                    tempObj = hmData.mapOfProdAndActivities.get(product.Name);              
                }
                system.debug('tempObj--------->>>'+tempObj);
                if(tempObj != null){
                    //User u =  (User)tempObj.get('CreatedBy');
                    //string personName = u.LastName + ', ' + u.FirstName; 
                    DateTime dt = (DateTime)tempObj.get('LastModifiedDate'); 
                    //rowData += '<td '+ colorCode(dt) +'>'+ personName + 'on '+ tempObj.get('LastModifiedDate')+'</td>';
                    rowData += '<td '+ colorCode(dt) +'>'+ tempObj.get('LastModifiedDate')+'</td>';
                }
                else
                {
                    rowData += '<td></td>';
                }
                
            }
            rowData += '</tr>';
        }
        
        return rowData;
    }

    private static string createHeader()
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
    
    private static string colorCode(datetime dt)
    {
        Integer numberDaysDue = date.today().daysBetween(dt.date());
        
        if(numberDaysDue <= 120)        
            return 'style = "background-color: green;"';
        else if(numberDaysDue > 180)
            return 'style = "background-color: red;"';
        else
            return '';  
    }
}