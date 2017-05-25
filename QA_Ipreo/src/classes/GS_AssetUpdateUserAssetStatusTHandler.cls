/**************************************************************************************************
 * Name           : GS_AssetUpdateUserAssetStatusTHandler
 * Object         : Asset / User Asset
 * Requirement    : STY-00030
 * Target         : When Asset status is changed, FOR EACH associated User Asset, IF Asset.Status == "Active", THEN Active Asset = checked, ELSE unchecked
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-06-07
 * Modify History :UB: Implementd future method if UserAssets>2500
 **************************************************************************************************/
public class GS_AssetUpdateUserAssetStatusTHandler implements GS_Triggers.Handler {
    public void handle() {

    	Set<Id> setAssetIds = new Set<Id>();
    	List<Asset> lstAsset = new List<Asset>();
    	List<User_Asset__c> lstTargetUserAssets = new List<User_Asset__c>();

    	if(Trigger.isUpdate){
    		for(Id tempAssetId : Trigger.newMap.keySet()) {
    			if(((Map<Id, Asset>)Trigger.newMap).get(tempAssetId).Status != ((Map<Id, Asset>)Trigger.oldMap).get(tempAssetId).Status) {
    				setAssetIds.add(tempAssetId);
    			}
    		}
    	}

    	if(setAssetIds.size() > 0) {
    		lstAsset = GS_AssetDMLHandler.getAssetsWithUserAssetsByIds(setAssetIds);
    		for(Asset tempAsset : lstAsset) {
    			for (User_Asset__c tempUserAsset : tempAsset.User_Assets__r) {
    				tempUserAsset.Active__c = tempAsset.Status;
    				lstTargetUserAssets.add(tempUserAsset);
    			}
    		}
    	}
    	if(lstTargetUserAssets.size() > 2500){
    		updateUserAssets(setAssetIds);
    		return;
    	}

    	try{
    		update lstTargetUserAssets;
    	} catch(DmlException ex) {
    		for (Integer i = 0; i < ex.getNumDml(); i++) {
    			((Map<Id, Asset>)Trigger.newMap).get(lstTargetUserAssets.get(ex.getDmlIndex(i)).Asset__c).addError(ex.getDmlMessage(i));
		        System.debug(LoggingLevel.INFO, '*** ex.getDmlMessage(' + i + '): ' + ex.getDmlMessage(i));
	    	}
    	}
    }
    
    @future
    public static void updateUserAssets(Set<ID> setAssetIds){
    	List<User_Asset__c> lstTargetUserAssets = new List<User_Asset__c>();
    	List<Asset> lstAsset = new List<Asset>(); 
        if(setAssetIds.size() > 0) {
    		lstAsset = GS_AssetDMLHandler.getAssetsWithUserAssetsByIds(setAssetIds);
    		for(Asset tempAsset : lstAsset) {
    			for (User_Asset__c tempUserAsset : tempAsset.User_Assets__r) {
    				tempUserAsset.Active__c = tempAsset.Status;
    				lstTargetUserAssets.add(tempUserAsset);
    			}
    		}
    	}
        Database.SaveResult[] arrResult = Database.Update(lstTargetUserAssets, false);
        String failureReasons = '';
        for(integer i = 0; i < arrResult.size(); i++){
            If(!arrResult[i].isSuccess()){
                string recordErrors = '';
                for(Database.Error err: arrResult[i].getErrors()){
                    recordErrors += err.getmessage()+';';
                } 
                failureReasons +=  '<tr> <td>'+lstTargetUserAssets[i].Id+'</td> <td>Failed</td> <td>Error:'+recordErrors+'</td> </tr>';    
            }
        }
        if(String.isNotEmpty(failureReasons)){
			sendEmailOnError(failureReasons);        	
        }    	
    }
    
    public static void sendEmailOnError(String failureReasons){
	    Messaging.EmailFileAttachment exlAttc;
	    if(String.isNotEmpty(failureReasons))
	    {
	    	string header = '<table style="font-size:100%" border="2" cellpadding="5" border="2" cellspacing="0"><tr><td><b>Record Id</b></td> <td><b>Status</b></td> <td><b>Message</b></td></tr>';
	    	failureReasons = header + failureReasons+'</table>';
	        exlAttc = new Messaging.EmailFileAttachment();
	        blob exlBlob = Blob.valueOf(failureReasons);
	        string exlname = 'User Asset Update Failed Results.xls';
	        exlAttc.setFileName(exlname);
	        exlAttc.setBody(exlBlob);
	    }
        list<string> toAddresses = new list<string>();

		User_List_Data_Update_Notifications__c notifSetting = GS_CustomSettingDMLHandler.getCustomSetting('UserAssetUpdateFailureNotification');
    	if(notifSetting != null && notifSetting.Email_Addresses__c != null ){
        	toAddresses = ((string)notifSetting.Email_Addresses__c).split(',');
    	}
    	if(toAddresses.size() == 0){
    		toAddresses.add('salesforce_support@ipreo.com');
    	}     
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(toAddresses); 
        email.setSubject('Action Required: User Asset Update Failed');
        string textBody = 'Alert: Failed to update user assets in future method \n';
    	textBody += '\n The attached file contains failure reason(s) for the records that failed.';
        textBody += '\n\n Note: Apex Class: "GS_AssetUpdateUserAssetStatusTHandlers"';
        email.setPlainTextBody(textBody);
    	email.setFileAttachments(new Messaging.EmailFileAttachment[]{exlAttc});

        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
}