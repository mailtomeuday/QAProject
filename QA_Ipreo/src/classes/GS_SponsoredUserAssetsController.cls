/**************************************************************************************************
 * Name           : GS_SponsoredUserAssetsController
 * Object         : Asset
 * Requirement    :
 * Target         : 
 * Refer classes  :
 * Author         : Matthew Sun (matthew.sun@pwc.com)
 * Create Date    : 2016-03-03
 * Modify History :
 **************************************************************************************************/
public class GS_SponsoredUserAssetsController{

    private Id assetId {get; set;}
    public List<User_Asset__c> userAsset {get;set;}

    public GS_SponsoredUserAssetsController(ApexPages.StandardController controller) {
        assetId = controller.getId();
        querySponsoredUserAssets();
    }

    public PageReference queryAllUserAssets(){
        queryUserAsset(false);
        return null;
    }

    public PageReference querySponsoredUserAssets(){
        queryUserAsset(true);
        return null;
    }
    
    public void queryUserAsset(Boolean isSponsoredUserAsset){
        String queryStr = 'SELECT Asset__r.Name, User__r.Account.Name, User__r.LastName, User__r.FirstName, Role__c, Active__c FROM User_Asset__c WHERE Asset__c = \''
                            + assetId + '\'';
        if(isSponsoredUserAsset){
            queryStr += ' AND Is_Sponsored_User__c = true';
        }
        System.debug('*************Start query************');
        System.debug(queryStr);

        userAsset = Database.query(queryStr);
    }

}