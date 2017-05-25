/*
    This batch class is used for populating the Primary & secondary AMs and Sales Reps on Account. 
    The reason for writing batch class is because triggers & validation rules are not supported on 
    Account Team Member object.
    
    If there are multiple people with same Primary / Secondary roles then need to match region 
    if region matches then that team member needs to be considered or else need to consider 
    last added team member.  
*/
/*
Revision History:
#Author:Uday Bikkumlla
#Jira : SPS-1989 -  Track "Team Lead GMI Analyst" on Account
 
*/
global with sharing class GS_PopulateRolesOnAccountBatch implements Database.Batchable<sObject>  
{

    set<string> rolesSet = new set<string>{
                                            'Primary Account Manager',
                                            'Secondary Account Manager',
                                            'Primary Sales Rep', 
                                            'Secondary Sales Rep',
                                            'Team Lead GMI Analyst'
                                          };
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        string accountTeamMemberFields = 'User.Region__c, UserId, TeamMemberRole, LastModifiedDate';
        string accountFields = 'Primary_Account_Manager__c, Secondary_Account_Manager__c,'+
                                ' Primary_Sales_Rep__c, Secondary_Sales_Rep__c, Team_Lead_GMI_Analyst__c,Region__c';
        
        string roleClause = 'TeamMemberRole in: rolesSet';
        
        string query = 'Select {0}, (select {1} from AccountTeamMembers where {2}) from Account';
        
        list<string> fillers = new list<String>{accountFields, accountTeamMemberFields, roleClause};
        
        query = String.format(query, fillers);
               
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) 
    {
        list<account> accUpdateList = new list<account>();
        
        for(Account acc : scope)
        {
            boolean isAccUpdated = false;
            
            list<AccountTeamMember> tempAtmList = acc.AccountTeamMembers;
            
            if(tempAtmList != null && tempAtmList.size() > 0)
        	{
                map<string, AccountTeamMember> mapAllRoleToAtm = new map<string, AccountTeamMember>();
                
                for(AccountTeamMember atm : tempAtmList)
                {
                    AccountTeamMember primaryAccMgrAtm = mapAllRoleToAtm.get('Primary Account Manager');
                    AccountTeamMember secondaryAccMgrAtm = mapAllRoleToAtm.get('Secondary Account Manager');
                    AccountTeamMember primarySalesRepAtm = mapAllRoleToAtm.get('Primary Sales Rep');
                    AccountTeamMember secondarySalesRepAtm = mapAllRoleToAtm.get('Secondary Sales Rep');
                    AccountTeamMember teamLeadAnalystAtm = mapAllRoleToAtm.get('Team Lead GMI Analyst');
                    
                    if(atm.TeamMemberRole.equalsIgnoreCase('Primary Account Manager'))
                    {
                        mapAllRoleToAtm.put('Primary Account Manager', populateAllRolesWithATM(atm, primaryAccMgrAtm, acc)); 
                    }
                    
                    if(atm.TeamMemberRole.equalsIgnoreCase('Secondary Account Manager'))
                    {
                        mapAllRoleToAtm.put('Secondary Account Manager', populateAllRolesWithATM(atm, secondaryAccMgrAtm, acc)); 
                    }
                    
                    if(atm.TeamMemberRole.equalsIgnoreCase('Primary Sales Rep'))
                    {
                        mapAllRoleToAtm.put('Primary Sales Rep', populateAllRolesWithATM(atm, primarySalesRepAtm, acc)); 
                    }
                    
                    if(atm.TeamMemberRole.equalsIgnoreCase('Secondary Sales Rep'))
                    {
                        mapAllRoleToAtm.put('Secondary Sales Rep', populateAllRolesWithATM(atm, secondarySalesRepAtm, acc)); 
                    }
                    
                    /* SPS-1989: Put Team Lead GMI Analyst to Map */
                    if(atm.TeamMemberRole.equalsIgnoreCase('Team Lead GMI Analyst'))
                    {
                        mapAllRoleToAtm.put('Team Lead GMI Analyst', populateAllRolesWithATM(atm, teamLeadAnalystAtm, acc)); 
                    }
                }
                
                if(mapAllRoleToAtm.get('Primary Account Manager') != null){ 
                    if(acc.Primary_Account_Manager__c != mapAllRoleToAtm.get('Primary Account Manager').UserId){
                        acc.Primary_Account_Manager__c = mapAllRoleToAtm.get('Primary Account Manager').UserId;
                        isAccUpdated = true;
                    }
                }
                else{
                    if(acc.Primary_Account_Manager__c != null){
                        acc.Primary_Account_Manager__c = null;
                        isAccUpdated = true;
                    }
                }
                
                if(mapAllRoleToAtm.get('Secondary Account Manager') != null){ 
                    if(acc.Secondary_Account_Manager__c != mapAllRoleToAtm.get('Secondary Account Manager').UserId){
                        acc.Secondary_Account_Manager__c = mapAllRoleToAtm.get('Secondary Account Manager').UserId;
                        isAccUpdated = true;
                    }
                }
                else{
                    if(acc.Secondary_Account_Manager__c != null){
                        acc.Secondary_Account_Manager__c = null;
                        isAccUpdated = true;
                    }
                }
                
                if(mapAllRoleToAtm.get('Primary Sales Rep') != null){ 
                    if(acc.Primary_Sales_Rep__c != mapAllRoleToAtm.get('Primary Sales Rep').UserId){
                        acc.Primary_Sales_Rep__c = mapAllRoleToAtm.get('Primary Sales Rep').UserId;
                        isAccUpdated = true;
                    }
                }
                else{
                    if(acc.Primary_Sales_Rep__c != null){
                        acc.Primary_Sales_Rep__c = null;
                        isAccUpdated = true;
                    }
                }
                
                if(mapAllRoleToAtm.get('Secondary Sales Rep') != null){ 
                    if(acc.Secondary_Sales_Rep__c != mapAllRoleToAtm.get('Secondary Sales Rep').UserId){
                        acc.Secondary_Sales_Rep__c = mapAllRoleToAtm.get('Secondary Sales Rep').UserId;
                        isAccUpdated = true;
                    }
                }
                else{
                    if(acc.Secondary_Sales_Rep__c != null){
                        acc.Secondary_Sales_Rep__c = null;
                        isAccUpdated = true;
                    }
                }
                
                /* SPS-1989: Get the Team Lead GMI Analyst from Map and assign to GMI Analyst field on Account  */
                if(mapAllRoleToAtm.get('Team Lead GMI Analyst') != null){ 
                    if(acc.Team_Lead_GMI_Analyst__c != mapAllRoleToAtm.get('Team Lead GMI Analyst').UserId){
                        acc.Team_Lead_GMI_Analyst__c = mapAllRoleToAtm.get('Team Lead GMI Analyst').UserId;
                        isAccUpdated = true;
                    }
                }
                else{
                    if(acc.Team_Lead_GMI_Analyst__c != null){
                        acc.Team_Lead_GMI_Analyst__c = null;
                        isAccUpdated = true;
                    }
                }
            
	            if(isAccUpdated){
	                accUpdateList.add(acc);
	            } 
        	}
            else
            {
                if(acc.Primary_Account_Manager__c != null){
                    acc.Primary_Account_Manager__c = null;
                    isAccUpdated = true;
                }
                if(acc.Secondary_Account_Manager__c != null){
                    acc.Secondary_Account_Manager__c = null;
                    isAccUpdated = true;
                }
                if(acc.Primary_Sales_Rep__c != null){
                    acc.Primary_Sales_Rep__c = null;
                    isAccUpdated = true;
                }
                if(acc.Secondary_Sales_Rep__c != null){
                    acc.Secondary_Sales_Rep__c = null;
                    isAccUpdated = true;
                }
                if(acc.Team_Lead_GMI_Analyst__c != null){
                    acc.Team_Lead_GMI_Analyst__c = null;
                    isAccUpdated = true;
                }                
                
                if(isAccUpdated){
                    accUpdateList.add(acc);
                }   
            }
            
        }
        
        if(accUpdateList.size() > 0){
            database.update(accUpdateList);
        }
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        //TBD
    }
    
    /* To check whether region on user and account are matching. 
       Since they have different picklist values we are trying to best guess the match. 
       For example we are assuming NA = North America; EMEA = Europe / Middle East / Africa */
    private boolean IsRegionMatching(string userRegion, string accRegion)
    {
        if(string.isBlank(userRegion) || string.isBlank(accRegion))
            return false;
        if(userRegion == accRegion) 
            return true;
        if(userRegion.equalsIgnoreCase('NA') && accRegion.equalsIgnoreCase('North America'))
            return true;
        if(userRegion.equalsIgnoreCase('LATAM') && accRegion.equalsIgnoreCase('North America'))
            return true;    
        if(userRegion.equalsIgnoreCase('JAPAN') && accRegion.equalsIgnoreCase('Asia'))
            return true;    
        if(userRegion.equalsIgnoreCase('EMEA') && (accRegion.equalsIgnoreCase('Europe') 
                || accRegion.equalsIgnoreCase('Middle East') || accRegion.equalsIgnoreCase('Africa')))  
            return true;
        if(userRegion.equalsIgnoreCase('APAC') && (accRegion.equalsIgnoreCase('Asia') 
                || accRegion.equalsIgnoreCase('Pacific')))  
            return true;
        if(userRegion != accRegion) 
            return false;           
        return false;   
    }
    
    /*  If there are multiple people with same Primary / Secondary roles then need to match region 
        if region matches then that team member needs to be considered or else need to consider 
        last added team member. 
    */
    private AccountTeamMember populateAllRolesWithATM(AccountTeamMember newAtm, AccountTeamMember currentAtm, Account accRec)
    {
        if(currentAtm == null){
            return newAtm;
        }                       
        else
        {
            if(IsRegionMatching(newAtm.User.Region__c, accRec.Region__c)) 
            {
                if(!IsRegionMatching(currentAtm.User.Region__c, accRec.Region__c) || 
                        newAtm.LastModifiedDate > currentAtm.LastModifiedDate)
                    return newAtm;
                return currentAtm;
                
            }
            else
            {
                if(IsRegionMatching(currentAtm.User.Region__c, accRec.Region__c) ||
                        currentAtm.LastModifiedDate > newAtm.LastModifiedDate)
                    return currentAtm;
                return newAtm;
            }
        }
        
        return null;
    }
}