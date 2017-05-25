/**************************************************************************************************
 * Name           : GS_AssetUpdateOppProdReasonTHandler
 * Object         : Asset/Opp Product
 * Requirement    : SPS-1082
 * Target         : When Asset RAG Reason status is changed, update the reason on all associated opportunites
 * Refer classes  :
 * Author         : Uday Bikkumalla
 * Create Date    : 2015-08-03
 * Modify History :
 **************************************************************************************************/
public class GS_AssetUpdateOppProdReasonTHandler implements GS_Triggers.Handler {
public void handle() {
}
   /* public void handle() {
        List<OpportunityLineItem> lstOppProducts;
        List<Asset> lstAssets = new List<Asset>();
        if(Trigger.isUpdate){
            for (Id tempAssetId : Trigger.newMap.keySet()) {
                if (((Asset)Trigger.newMap.get(tempAssetId)).Reason_for_RAG_Status__c != ((Asset)Trigger.oldMap.get(tempAssetId)).Reason_for_RAG_Status__c) {
                    lstAssets.add(((Asset)Trigger.newMap.get(tempAssetId)));
                }
            }            
        }
        else if(Trigger.isDelete){
            for (Id tempAssetId : Trigger.oldMap.keySet()) {
                lstAssets.add(((Asset)Trigger.oldMap.get(tempAssetId)));
            }
        }
        else if(Trigger.isUnDelete ){
            for (Id tempAssetId : Trigger.newMap.keySet()) {
                lstAssets.add(((Asset)Trigger.newMap.get(tempAssetId)));
            }
        }        
        updateOppProducts(lstAssets);
    }
    private void updateOppProducts(List<Asset> assets){
        List<OpportunityLineItem> lstOppProducts = new List<OpportunityLineItem>();
        //lstOppProducts = GS_OppLineItemDMLHandler.getLineItemsByAssets(assets);
        for(OpportunityLineItem oli : GS_OppLineItemDMLHandler.getLineItemsByAssets(assets)){
            if(!Trigger.isDelete)
                oli.Reason_for_RAG_Status__c = oli.Asset__r.Reason_for_RAG_Status__c;
            else 
                oli.Reason_for_RAG_Status__c = '';
            lstOppProducts.add(oli);
        }
        try{
            update lstOppProducts;
        }
        catch(System.DmlException ex){
            throw ex;
        }
    }*/
}