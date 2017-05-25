// This class is used to reset specified users' password, please delete this class after on live
global class ResetPassWord implements Database.Batchable<SObject>, Database.Stateful {

    public String query;
    public List<Id> ids;
    
    global ResetPassWord() {
        this.query = 'SELECT Id FROM User WHERE isActive = TRUE AND ResetPassword__c = TRUE';
    }

    global ResetPassWord(List<Id> userIds) {
        this.ids = userIds;
        this.query = 'SELECT Id FROM User WHERE isActive = TRUE AND Id =: ids';
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<SObject> scope) {
        if(scope.size() < 150) {
            for(User tempUser : (list<User>)scope) {
                System.debug(LoggingLevel.INFO, '*** tempUser.Id: ' + tempUser.Id);
                System.resetPassword(tempUser.Id, TRUE);
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
    }
}