global class GS_WorkOrderUpdateStatusBatch implements Database.Batchable<sObject>, Database.Stateful {
    public String query;
    String strSaveErrResult = '';
    global GS_WorkOrderUpdateStatusBatch() {
        this.query = 'SELECT Id, Active__c, Auto_Populated_Active_Status__c FROM Work_Order__c WHERE Active_Need_to_Be_Updated__c = true Limit 9999';
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Sobject> scope) {

        List<Work_Order__c> listTargetWO;
        listTargetWO = new List<Work_Order__c>();

        for(Work_Order__c tempWO : (List<Work_Order__c>)scope) {
            tempWO.Active__c = tempWO.Auto_Populated_Active_Status__c;
            listTargetWO.add(tempWO);
        }

        List<Database.SaveResult> saveResults = Database.update(listTargetWO, false);
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
            GS_EmailUtility.Send(UserInfo.getUserId(), 'Account Status Calucation Exception on Work Order ' + String.valueOf(Datetime.now()), strSaveErrResult);
        }

        Database.executeBatch(new GS_LicenseUpdateStatusBatch(), 200);
    }
}