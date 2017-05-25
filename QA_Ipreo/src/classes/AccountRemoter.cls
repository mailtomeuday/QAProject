global with sharing class AccountRemoter {

    public String accountName { get; set; }
    public static List<CampaignMember> account { get; set; }
    public AccountRemoter() { } // empty constructor
    
    @RemoteAction
    global static List<CampaignMember> getAccount(String accountName) {
        account = [SELECT Id from CampaignMember];
        return account;
    }
}