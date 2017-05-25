/**************************************************************************************************
 * Name           : GS_AccountStatsTHandler
 * Object         : Account
 * Requirement    : 
 * Target         : To update No_Of_XXX on fields on Account during Account merge.
 * Refer classes  :
 * Author         : Uday Bikkumalla
 * Create Date    : 2016-08-25
 * Modify History : Ambadas Joshi, Added code to fix duplicate asset creation issue during CWV process(SPS-1509). 
 **************************************************************************************************/
public class GS_AccountStatsTHandler implements GS_Triggers.Handler {
	List<ID> accountIds;
	List<Account> listOriginAccount;
	List<Account> listTargetAccount;
	
	public void handle() {
	accountIds = new List<ID>();
	  if(Trigger.isUpdate && Trigger.isAfter){
       		accountIds.addAll(Trigger.newMap.keySet());
	   		updateAssetStats(accountIds);
    	}
	}
	
	/*Update fields on Account during merge process */
	public void updateAssetStats(List<ID> accountIds){
		/*SPS-1509*/
		String strSeprator = '_';
		String strAccId = '';
		String strProId = '';
		String strRegion = '';
		list<Asset> lstUpdateAsset = new list<Asset>();
		
		listTargetAccount = new List<Account>();
		if(accountIds.size()> 0){
			listOriginAccount = GS_AccountDMLHandler.getAssetsWorkOrdersByAccount(accountIds);
			Integer activeAssetNum = 0;
			Integer activeWONumber = 0;
			/*map<Id, String> accountIdProdBundleMap = GS_CommonUtility.getAccountProductBundle(accountIds);*/
			map<Id, String> accountIdProdBundleMap = GS_CommonUtility.getAccountProductBundle(accountIds,listOriginAccount);
			for (Account tempAccount : listOriginAccount) {
				for (Asset tempAsset : tempAccount.Assets) {
					if (tempAsset.Status == 'Active') {
						activeAssetNum ++ ;
					}
					
					/*SPS-1509*/
					strAccId = tempAsset.AccountId != NULL ? String.valueOf(tempAsset.AccountId) : '';
					strProId = tempAsset.Product2Id != NULL ? String.valueOf(tempAsset.Product2Id) : '';
					strRegion = tempAsset.Product_Region__c != NULL ? String.valueOf(tempAsset.Product_Region__c) : '';
					string tempAssetKey = strAccId + strSeprator + strProId + strSeprator + strRegion;
					
					if(tempAssetKey != tempAsset.AccountProductRegionKey__c){
						tempAsset.AccountProductRegionKey__c = tempAssetKey;
						lstUpdateAsset.add(tempAsset);
					}
				}
				for(Work_Order__c tempWO : tempAccount.Work_Orders__r) {
                    if(tempWO.Active__c == true) {
                        activeWONumber ++ ;
                    }
                }	
				if(tempAccount.Assets.size() != ((Account)Trigger.newMap.get(tempAccount.id)).No_of_All_Assets__c 
				|| tempAccount.Work_Orders__r.size() != ((Account)Trigger.newMap.get(tempAccount.id)).No_of_All_Work_Orders__c){
            	  		listTargetAccount.add(new Account(Id = tempAccount.Id, No_of_Active_Assets__c = activeAssetNum, No_of_All_Assets__c = tempAccount.Assets.size(), No_of_Active_Work_Orders__c = activeWONumber, No_of_All_Work_Orders__c = tempAccount.Work_Orders__r.size(), Product_Bundle__c = accountIdProdBundleMap.get(tempAccount.Id)));
            	  }
				activeAssetNum = 0;
				activeWONumber = 0;				
			}
		} 
		if(listTargetAccount.size() > 0){
			try{
				update listTargetAccount;
			}
			catch(System.DmlException ex){
				throw ex;
			}
		}
		
		/*SPS-1509*/
		if(lstUpdateAsset.size() > 0){
			try{
				update lstUpdateAsset;
			}
			catch(System.DmlException ex){
				throw ex;
			}
		}
	}
}