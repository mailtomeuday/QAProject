global class GS_LicenseUpdateStatusBatch implements Database.Batchable<sObject> {
    public String query;
    String strSaveErrResult = '';
    
    global GS_LicenseUpdateStatusBatch() {
    	this.query = 'SELECT Id,Status__c,Auto_Populated_Active_Status__c FROM Asset_License__c WHERE Active_Need_to_Be_Updated__c = true Limit 9999';
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
    	return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Sobject> scope) {

		List<Asset_License__c> listTargetLicense;
		listTargetLicense = new List<Asset_License__c>();

		for(Asset_License__c tempLicense : (List<Asset_License__c>)scope) {
			tempLicense.Status__c = tempLicense.Auto_Populated_Active_Status__c ? 'Active' : 'Inactive';
			listTargetLicense.add(tempLicense);
		}
		List<Database.SaveResult> saveResults = Database.update(listTargetLicense, false);
        for(Database.SaveResult res : saveResults) {
            if(!res.isSuccess()) {
                for(Database.Error err : res.getErrors()) {
                    strSaveErrResult += err.getFields() + ': ' + err.getMessage() + '\n';
                }
            }
        }
    }

    global void finish(Database.BatchableContext BC) {

        if(String.isNotBlank(strSaveErrResult)) {
            GS_EmailUtility.Send(UserInfo.getUserId(), 'Account Status Calucation Exception on License ' + String.valueOf(Datetime.now()), strSaveErrResult);
        }

    }
}