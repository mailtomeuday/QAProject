public class GS_HeatMapController_UB {
    
    public list<Product2> lstProducts {get;set;}
    //public list<HeatMapData> lstHeatMapData {get;set;}
    //public string jsonString {get;set;}
    public map<string, HeatMapData> mapOfAccountwithHeatMap {get;set;} 
    //public map<string, list<string>> mapAccountIDCoverage;
    
    public class HeatMapData{
        
        public HeatMapData(String accName, String Status, String coverage, String MostIntDate,list<Product2> lstProducts){
        	System.debug('Heap Size in HeatMapData Constructor'+Limits.getHeapSize());
           // lstProducts = [select id,name from Product2 order by Name];
            if(lstProducts != null && lstProducts.size()> 0){
            	accountRow = '<tr><td>'+accName+'</td><td>'+Status+'</td><td>'+coverage+'</td><td>'+MostIntDate+'</td>';
                for(Product2 prd: lstProducts){
                    accountRow += prepareTDCell(prd.Name,null,null);
                }      
                accountRow = accountRow+'</tr>';         
            }
           // System.debug('Account Row at line 18 '+accountRow);
        }
        
        public string AccountName {get;set;}
        public string clientStatus {get;set;}
        public string coverage {get;set;}
        public string mostRecentInteraction {get;set;}
        public string accountRow{get;set;}
        //public map<string, sObject> mapOfProdAndActivities {get;set;}
        private String prepareTDCell(String productName,String Color, String cellValue){
            String colorValue = '';
            String cell = '';
            if(String.isNotBlank(Color)){
                colorValue = '--'+Color+'--';
            }
            if(String.isNotBlank(cellValue)){
                cell = cellValue;
            }       
            String tdCell = '<td>'+'<'+productName+'>'+colorValue +cell+'</'+productName+'>'+'</td>';
           // System.debug('--'+tdCell);
            return tdCell;
        }
    } 
    
    public void prepareHeatMapData(map<Id, Account> mapAccount){
        mapOfAccountwithHeatMap = new map<string, HeatMapData>();        
        lstProducts = [select id,name from Product2 order by Name];
        list<AccountTeamMember> lstAccountTeamMember = [select Id, AccountId, User.FirstName, User.LastName from AccountTeamMember where AccountId in: (mapAccount.keyset())];
        
        /*mapAccountIDCoverage = new map<string, list<string>>();
        
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
                        
        }*/
        
        /*for(Account acc : mapAccount.values())
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
        }*/
    }
    
    public void populateHeatMapData(list<sObject> lstActivities, map<Id, Account> mapAccount)
    {
        map<string, map<string,sObject>> mapOfAccountProdAndActivities = new map<string, map<string,sObject>>();
        System.debug('Heap Size in populateHeatMapData'+Limits.getHeapSize());
        for(sObject activity : lstActivities)
        {
            HeatMapData objHeatMap = mapOfAccountwithHeatMap.get((string)activity.get('AccountId'));
            if(objHeatMap == null){
                
                Account acc = mapAccount.get((string)activity.get('AccountId'));
               /* objHeatMap.AccountName = acc.Name;
                objHeatMap.clientStatus = acc.Status__c;
                objHeatMap.coverage = '';*/
                objHeatMap = new HeatMapData(acc.Name, acc.Status__c, '','',lstProducts);
               /* list<string> lstCoverage = mapAccountIDCoverage.get(acc.Id);
                if(lstCoverage != null){ 
                    for(string s: lstCoverage)
                    {
                        objHeatMap.coverage += s + ';'; 
                    }
            }*/

            mapOfAccountwithHeatMap.put(acc.Id,objHeatMap);     
                
            }
            
           /* if(objHeatMap.mapOfProdAndActivities == null)
            {
                objHeatMap.mapOfProdAndActivities = new map<string,sObject>();
            }*/
            
            DateTime tempActivityDate;
            DateTime tempMostRecentActivityDate;
            
            tempMostRecentActivityDate =  (DateTime)activity.get('LastModifiedDate');
            
            if(activity.get('Products__c') != null && string.valueOf(activity.get('Products__c')).contains(';'))
            {
                list<string> productList =  string.valueOf(activity.get('Products__c')).split(';');
                
                for(string prod : productList)
                {
                 /* if(objHeatMap.mapOfProdAndActivities.containsKey(prod))
                    {
                        tempActivityDate = (DateTime)objHeatMap.mapOfProdAndActivities.get(prod).get('LastModifiedDate');
                        
                        if(tempMostRecentActivityDate > tempActivityDate)
                        {
                        
                            objHeatMap.mapOfProdAndActivities.put(prod, activity);     
                            System.debug(prod);                     
                            Integer startIndex = objHeatMap.accountRow.indexOf('<'+prod+'>');
                            Integer endIndex = objHeatMap.accountRow.indexOf('</'+prod+'>')+(prod.length()-1);
                            System.debug(startIndex);
                            System.debug(endIndex);
                            if(startIndex == -1 || endIndex == -1 )
                                continue;
                            String colorValue = colorCodeValue(tempMostRecentActivityDate);
                            String toBeReplaced = prepareTDCell(prod,colorValue,tempMostRecentActivityDate.format());
                            System.debug( 'row---'+objHeatMap.accountRow);
                            String temp = objHeatMap.accountRow.substring(startIndex, endIndex);
                            System.debug('Before'+objHeatMap.accountRow);
                            objHeatMap.accountRow = objHeatMap.accountRow.replace(temp,toBeReplaced);
                            System.debug('After'+objHeatMap.accountRow);
                        }
                    }
                    else
                    {
                        objHeatMap.mapOfProdAndActivities.put(prod, activity);
                    }*/
                    		Integer startIndex = objHeatMap.accountRow.indexOf('<td><'+prod+'>');
                            Integer endIndex = objHeatMap.accountRow.indexOf('</'+prod+'></td>');
                            //System.debug(startIndex);
                            //System.debug(endIndex);
                            if(startIndex == -1 || endIndex == -1 )
                                continue;
                            String colorValue = colorCodeValue(tempMostRecentActivityDate);
                            String toBeReplaced = prepareTDCell(prod,colorValue,tempMostRecentActivityDate.format());
                            
                            //System.debug( 'row---'+objHeatMap.accountRow);
                            String temp = objHeatMap.accountRow.substring(startIndex, endIndex+(prod.length()+8));
                            //System.debug('Before'+objHeatMap.accountRow);
                            //System.debug('toBeReplaced'+toBeReplaced);
                            //System.debug('temp variable'+temp);
                            objHeatMap.accountRow = objHeatMap.accountRow.replace(temp,toBeReplaced);
                            //System.debug('After'+objHeatMap.accountRow);
                }
            }
            else if(activity.get('Products__c') != null)
            {
                string prod = string.valueOf(activity.get('Products__c'));
                
                /*if(objHeatMap.mapOfProdAndActivities.containsKey(prod))
                {
                    tempActivityDate = (DateTime)objHeatMap.mapOfProdAndActivities.get(prod).get('LastModifiedDate');
                    
                    if(tempMostRecentActivityDate > tempActivityDate)
                    {
                        objHeatMap.mapOfProdAndActivities.put(prod, activity);
                    }
                }*/ //System.debug('Product is '+prod);
                            Integer startIndex = objHeatMap.accountRow.indexOf('<td><'+prod+'>');
                            Integer endIndex = objHeatMap.accountRow.indexOf('</'+prod+'></td>');
                           // System.debug(startIndex);
                            //System.debug(endIndex);
                            if(startIndex == -1 || endIndex == -1 )
                                continue;
                            String colorValue = colorCodeValue(tempMostRecentActivityDate);
                            String toBeReplaced = prepareTDCell(prod,colorValue,tempMostRecentActivityDate.format());
                            //System.debug( 'row---'+objHeatMap.accountRow);
                            String temp = objHeatMap.accountRow.substring(startIndex, endIndex+(prod.length()+8));
                           // System.debug('Before'+objHeatMap.accountRow);
                            objHeatMap.accountRow = objHeatMap.accountRow.replace(temp,toBeReplaced);
                           //System.debug('After'+objHeatMap.accountRow);
            }
            
        }
    }
    
    public  void createAttachment(string createdRows)
    {
        //createdRows = createRows();
        //lstProducts = [select id,name from Product2 order by Name limit 30];
        Account acc = [select id from Account where name =: 'Test Account Joshi 1'];
        Attachment att = new Attachment();
        System.debug('Before Preparing Blob - Heap Size in create Attachment'+Limits.getHeapSize());
         System.debug('Account values Size'+mapOfAccountwithHeatMap.values().size());
        //Blob test = Blob.valueOf(createTable(createdRows));
        Blob test = Blob.valueOf('test');
        System.debug('After Preparing Blob - Heap Size in create Attachment'+Limits.getHeapSize());
        att.ParentId = acc.Id;
        att.Name = 'Heat Map_'+ Datetime.now().format()+'.xls';
        att.contenttype = 'EXCEL';
        att.Body = test;
        insert att;
    }
    
    private  string createTable(string createdRows)
    {
        string s = '<html> <head> <style> table { font-family: arial, sans-serif; border-collapse: collapse; width: 100%; }td, th { border: 1px solid #dddddd; text-align: left;padding: 8px; } </style> </head> <body><table>';
        s += createHeader();
        //s += createdRows;
        System.debug('Account values Size'+mapOfAccountwithHeatMap.values().size());
         System.debug('Heap Size in Create Table at Starting ..'+Limits.getHeapSize());
        Integer i =0;
        for(HeatMapData hmData : mapOfAccountwithHeatMap.values()){
        s += hmData.accountRow;
        System.debug('Heap Size in Create Table'+Limits.getHeapSize());
        i = i+1;
        if(i==1500)
        break;
        }
        s += '</table></body> </html>';
        return s;
    }
    
    private  string createRows()
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
               /* if(hmData.mapOfProdAndActivities != null){
                    tempObj = hmData.mapOfProdAndActivities.get(product.Name);              
                }
               // system.debug('tempObj--------->>>'+tempObj);
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
                }*/
                
            }
            rowData += '</tr>';
        }
        
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
    
    private String prepareTDCell(String productName,String Color, String cellValue){
        String colorValue = '';
        String cell = '';
        if(String.isNotBlank(Color)){
            colorValue = '--'+Color+'--';
        }
        if(String.isNotBlank(cellValue)){
            cell = cellValue;
        } 
        if(productName == null){
        	productName = '';
        }      
        String tdCell = '<td>'+'<'+productName+'>'+colorValue +cell+'</'+productName+'>'+'</td>';
        //System.debug('--'+tdCell);
        return tdCell;
    }
    private  string colorCode(datetime dt)
    {
        Integer numberDaysDue = date.today().daysBetween(dt.date());
        
        if(numberDaysDue <= 120)        
            return 'style = "background-color: green;"';
        else if(numberDaysDue > 180)
            return 'style = "background-color: red;"';
        else
            return '';  
    }
    private  string colorCodeValue(datetime dt)
    {
        Integer numberDaysDue = date.today().daysBetween(dt.date());
        
        if(numberDaysDue <= 120)        
            return 'green';
        else if(numberDaysDue > 180)
            return 'red';
        else
            return '';  
    }    
}