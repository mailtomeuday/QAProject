/**************************************************************************************************
 * Name           : GS_TaskAssignValueTHandler
 * Object         : Task
 * Requirement    : 
 * Target         : Assign value to task's field when created and updated
 * Refer classes  : 
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-11-03
 * Modify History :
 **************************************************************************************************/
public class GS_TaskAssignValueTHandler implements GS_Triggers.Handler{
    
    public Map<Id, Task> mapNewTask = new Map<Id, Task>();
    public Map<Id, Task> mapOldTask = new Map<Id, Task>();
	
    public void handle() {
        if(Trigger.isUpdate) {
            mapNewTask = (Map<Id, Task>)Trigger.newMap;
            mapOldTask = (Map<Id, Task>)Trigger.oldMap;
            assignDueDate();
            assignRelatedTo();
            setSendAlert();
			GS_ActivityUtil.setActivityProducts(Trigger.new);
            createOrUpdateProductInterest();
        } else if (Trigger.isInsert) {
            mapNewTask = (Map<Id, Task>)Trigger.newMap;
            assignDueDate();
            assignRelatedTo();
            setTaskTypeAndPluginFlag();
            setSendAlert();
            GS_ActivityUtil.setActivityProducts(Trigger.new);
            createOrUpdateProductInterest();
        }
    }
    
    private void createOrUpdateProductInterest(){
		list<Product_Interest__c> ProdInterestList = GS_ActivityUtil.setProductInterest(Trigger.new);
		
		if(ProdInterestList != null && ProdInterestList.size() > 0){
			try{
				database.upsert(ProdInterestList);
			}	
			catch(Exception ex){
				//throw ex;
				processException(ex);
			}
        }
    }

    // If task is closed, due date equals today.
    private void assignDueDate () {
        if(Trigger.isUpdate && Trigger.isBefore){
            for(Id taskId : mapNewTask.keySet()) {
                if(mapNewTask.get(taskId).Status == 'Closed' && mapOldTask.get(taskId).Status != 'Closed') {
                    mapNewTask.get(taskId).ActivityDate = Date.today();
                }
            }
        } else if(Trigger.isInsert && Trigger.isBefore) {
            for(Task tsk : (List<Task>)Trigger.new) {
                if(tsk.Status == 'Closed') {
                    tsk.ActivityDate = Date.today();
                }
            }
        }
    }

    // If task is created and contact is selected but without related to , just assign the contact's account to the relate to field.
    private void assignRelatedTo() {

        System.debug(LoggingLevel.INFO, '*** GS_TaskAssignValueTHandler.assignRelatedTo is executed.');
        System.debug(LoggingLevel.INFO, '*** GS_TaskAssignValueTHandler New Task: ' + Trigger.new);

        if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore) {

            Set<Id> conIds = new Set<Id>();
            // Key is Contact Id, Value is Account Id. 
            Map<Id, Id> mapConAcc = new Map<Id, Id>();

            for(Task tsk : (List<Task>)Trigger.new) {
                if(tsk.WhoId != NULL && tsk.WhatId == NULL){
                    if(String.valueOf(tsk.WhoId).startsWith(GS_GlobalVariables.CONTACTPREFIX)) {
                        conIds.add(tsk.WhoId);
                    }
                }
            }

            System.debug(LoggingLevel.INFO, '*** GS_TaskAssignValueTHandler.conIds: ' + conIds);

            for(Contact con : GS_ContactDmlHandler.getContactsByConIds(conIds)) {
                mapConAcc.put(con.Id, con.AccountId);
            }

            System.debug(LoggingLevel.INFO, '*** GS_TaskAssignValueTHandler mapConAcc: ' + mapConAcc);

            for(Task tsk : (List<Task>)Trigger.new) {
                System.debug(LoggingLevel.INFO, '*** GS_TaskAssignValueTHandler tsk.Id: ' + tsk.Id);
                System.debug(LoggingLevel.INFO, '*** GS_TaskAssignValueTHandler tsk.WhoId: ' + tsk.WhoId);
                System.debug(LoggingLevel.INFO, '*** GS_TaskAssignValueTHandler before assign tsk.WhatId: ' + tsk.WhatId);
                if(tsk.WhoId != NULL && tsk.WhatId == NULL){
                    if(String.valueOf(tsk.WhoId).startsWith(GS_GlobalVariables.CONTACTPREFIX) && mapConAcc.get(tsk.WhoId) != NULL) {
                        tsk.WhatId = mapConAcc.get(tsk.WhoId);
                    }
                }
                System.debug(LoggingLevel.INFO, '*** GS_TaskAssignValueTHandler after assign tsk.WhatId: ' + tsk.WhatId);
            }
        }
    }
    private void setSendAlert() {

   for (Task tempTask : (List<Task>)Trigger.new) {
   
       //Workflow rule (Set Activity Type) and its associated field update was deactivated and introduced the same functionality using the below code.
       //And also introducing the Alert sent date based on the Send alert picklistvalue.
       if(Trigger.isInsert && Trigger.isBefore){
           tempTask.Activity_Type__c = tempTask.Type  ;
                if(tempTask.Send_Alert__c == 'No'){
                   tempTask.Alert_Sent_Date__c = null;
               }
                else if(tempTask.Send_Alert__c == 'Yes'){
                    tempTask.Alert_Sent_Date__c = Datetime.now();
                }
        }
           
  
       //before update forcing send alert flag field value to 'yes' when send alert is 'yes' so that alert message condition can work.
       //Workflow rule (Set Activity Type) and its associated field update was deactivated and introduced the same functionality using the below code.
       //And also introducing the Alert sent date based on the Send alert picklist value.
        else if(Trigger.isUpdate && Trigger.isBefore){
           tempTask.Activity_Type__c = tempTask.Type  ; 
                if(tempTask.Send_Alert__c == 'Yes'){
                  tempTask.Alert_Sent_Date__c = Datetime.now();                  
                  }        
         }
      
        }
    }
    
    /* Set Activity Type and Created From Plugin Flags for tasks created using Salesforce Outlook */
	private void setTaskTypeAndPluginFlag()
	{
		if(Trigger.isInsert && Trigger.isBefore) {
            for(Task tsk : (List<Task>)Trigger.new) {            	
                if(tsk.Type == 'Email') {
                    tsk.Created_From_Plugin__c = true;                    
                    tsk.Type = 'Email (Client – Incoming/Outgoing)';                    
                }
            }
		}      
	}    
	
	public void processException(Exception ex){
        String errorMessage = '';
        if(ex.getTypeName() == 'System.DmlException'){
            Set<String> errorMessages = new Set<String>();
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                errorMessages.add(ex.getDmlMessage(i));
            }               
            Integer i = 0;          
            for(String message: errorMessages){
                    errorMessage += message+(i == errorMessages.size()-1 ? '' : '<br/>');
                    i = i+1;
            }
        }
        else{
            errorMessage = 'Internal System Error.';    
        }
        if(!Test.isRunningTest()){
	        for(sObject objTask : Trigger.new){
        		objTask.addError(errorMessage, false);
            }   
        }
    }
}