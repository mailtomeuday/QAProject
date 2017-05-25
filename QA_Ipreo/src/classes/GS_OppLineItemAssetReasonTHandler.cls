/**************************************************************************************************
 * Name           : GS_OppLineItemAssetReasonTHandler
 * Object         : OpportunityLineItem/Asset
 * Requirement    : 
 * Target         : Update RAG Reason when asset is changed on Opportunity Product
 * Refer classes  : 
 * Author         : Uday Bikkumalla
 * Create Date    : 2016-08-03
 * Modify History :
 **************************************************************************************************/
public class GS_OppLineItemAssetReasonTHandler implements GS_Triggers.Handler{
 public void handle(){
 }
   /* public void handle(){
        List<OpportunityLineItem> lstOppProducts = new List<OpportunityLineItem>();
        Set<Id> assetIds = new Set<Id>();
        if(Trigger.isUpdate){
             for (Id tempId : Trigger.newMap.keySet()){                
                if(((OpportunityLineItem)Trigger.oldMap.get(tempId)).Asset__c != ((OpportunityLineItem)Trigger.newMap.get(tempId)).Asset__c){
                    System.debug('In side Update');
                    lstOppProducts.add(((OpportunityLineItem)Trigger.newMap.get(tempId)));
                    assetIds.add(((OpportunityLineItem)Trigger.newMap.get(tempId)).Asset__c);
                }
            }
            updateOppProductReason(assetIds, lstOppProducts);
        }
    }
    private void updateOppProductReason(Set<Id> assetIds, List<OpportunityLineItem> lstOppProducts){
        System.debug('Updating products'+assetIds);
        Map<Id,Asset> mapAssets = new Map<Id, Asset>([Select id, Reason_for_RAG_Status__c from Asset where id in : assetIds ]);
        for(OpportunityLineItem oli : lstOppProducts){
            if(oli.Asset__c != null && mapAssets.get(oli.Asset__c) != null){
                System.debug('inside update --'+oli.Asset__c);
                System.debug('inside update -ref-'+mapAssets.get(oli.Asset__c));
                System.debug('Updating products inside for'+mapAssets.get(oli.Asset__c).Reason_for_RAG_Status__c);
                oli.Reason_for_RAG_Status__c = mapAssets.get(oli.Asset__c).Reason_for_RAG_Status__c;}
            else
                oli.Reason_for_RAG_Status__c = '';            
        }
       /* try{
            update lstOppProducts;
        }
        catch(System.DmlException ex){
            throw ex;
        }
    }  
     */ 
}