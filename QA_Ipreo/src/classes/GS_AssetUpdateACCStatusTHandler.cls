/**************************************************************************************************
 * Name           : GS_AssetUpdateACCStatusTHandler
 * Object         : Asset/Account
 * Requirement    : STY-00012
 * Target         : When Asset status is changed, sum the count of active Asset of the account.
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-06-01
 * Modify History :
 **************************************************************************************************/
public class GS_AssetUpdateACCStatusTHandler implements GS_Triggers.Handler {
	public void handle() {

		List<Account> listOriginAccount;
		List<Id> listAccountIds;
		List<Account> listTargetAccount;

		listOriginAccount = new List<Account>();
		listAccountIds = new List<Id>();
		listTargetAccount = new List<Account>();

		if (Trigger.isUpdate) {
			for (Id tempAssetId : Trigger.newMap.keySet()) {
				if (((Asset)Trigger.newMap.get(tempAssetId)).Status != ((Asset)Trigger.oldMap.get(tempAssetId)).Status
				||	 ((Asset)Trigger.newMap.get(tempAssetId)).AccountId != ((Asset)Trigger.oldMap.get(tempAssetId)).AccountId) {
					listAccountIds.add(((Asset)Trigger.newMap.get(tempAssetId)).AccountId);
					if (((Asset)Trigger.newMap.get(tempAssetId)).AccountId != ((Asset)Trigger.oldMap.get(tempAssetId)).AccountId) 
							listAccountIds.add(((Asset)Trigger.oldMap.get(tempAssetId)).AccountId);	
					}
				}
				/*if (((Asset)Trigger.newMap.get(tempAssetId)).AccountId != ((Asset)Trigger.oldMap.get(tempAssetId)).AccountId) {
					listAccountIds.add(((Asset)Trigger.newMap.get(tempAssetId)).AccountId);
					listAccountIds.add(((Asset)Trigger.oldMap.get(tempAssetId)).AccountId);
				}
			}*/
		} else if (Trigger.isInsert || Trigger.isUndelete) {
			for (Id tempAssetId : Trigger.newMap.keySet()) {
				listAccountIds.add(((Asset)Trigger.newMap.get(tempAssetId)).AccountId);
			}
		} else if ( Trigger.isDelete) {
			for (Id tempAssetId : Trigger.oldMap.keySet()) {
				listAccountIds.add(((Asset)Trigger.oldMap.get(tempAssetId)).AccountId);
			}
		}

		System.debug(LoggingLevel.INFO, '*** listAccountIds: ' + listAccountIds);

		if (listAccountIds.size() > 0) {

			//listOriginAccount = GS_AccountDMLHandler.getAssetsWithAccount(listAccountIds);
			//map<Id, String> accountIdProdBundleMap = GS_CommonUtility.getAccountProductBundle(listAccountIds);
			listOriginAccount = GS_AccountDMLHandler.getAssetsWorkOrdersByAccount(listAccountIds);
			map<Id, String> accountIdProdBundleMap = GS_CommonUtility.getAccountProductBundle(listAccountIds,listOriginAccount);
			
			Integer activeAssetNum = 0;
			for (Account tempAccount : listOriginAccount) {
				for (Asset tempAsset : tempAccount.Assets) {
					if (tempAsset.Status == 'Active') {
						activeAssetNum ++ ;
					}
				}
				listTargetAccount.add(new Account(Id = tempAccount.Id, No_of_Active_Assets__c = activeAssetNum, No_of_All_Assets__c = tempAccount.Assets.size(), Product_Bundle__c = accountIdProdBundleMap.get(tempAccount.Id)));
				activeAssetNum = 0;
			}

			Update listTargetAccount;
		}
	}
}