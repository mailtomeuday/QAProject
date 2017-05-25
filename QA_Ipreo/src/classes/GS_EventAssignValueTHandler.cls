/**************************************************************************************************
 * Name           : GS_EventAssignValueTHandler
 * Object         : Event
 * Requirement    :
 * Target         : Assign value to Event's field when created and updated
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-12-01
 * Modify History :
 **************************************************************************************************/
public class GS_EventAssignValueTHandler implements GS_Triggers.Handler {

    public Map<Id, Event> mapNewEvent = new Map<Id, Event>();
    public Map<Id, Event> mapOldEvent = new Map<Id, Event>();

    public void handle() {
        if (Trigger.isInsert) {
            mapNewEvent = (Map<Id, Event>)Trigger.newMap;
            assignRelatedTo();
            setSendAlert();
            GS_ActivityUtil.setActivityProducts(Trigger.new);
			createOrUpdateProductInterest();
        } else if (Trigger.isUpdate) {
            mapNewEvent = (Map<Id, Event>)Trigger.newMap;
            assignRelatedTo();
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

    // If event is created and contact is selected but without related to , just assign the contact's account to the relate to field.
    private void assignRelatedTo() {

        if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore) {

            Set<Id> conIds = new Set<Id>();
            // Key is Contact Id, Value is Account Id.
            Map<Id, Id> mapConAcc = new Map<Id, Id>();

            for (Event evt : (List<Event>)Trigger.new) {
                if (evt.WhoId != NULL && evt.WhatId == NULL){
                    if (String.valueOf(evt.WhoId).startsWith(GS_GlobalVariables.CONTACTPREFIX)) {
                        conIds.add(evt.WhoId);
                    }
                }
            }

            for (Contact con : GS_ContactDmlHandler.getContactsByConIds(conIds)) {
                mapConAcc.put(con.Id, con.AccountId);
            }

            for (Event evt : (List<Event>)Trigger.new) {
                if(evt.WhoId != NULL && evt.WhatId == NULL){
                    if(String.valueOf(evt.WhoId).startsWith(GS_GlobalVariables.CONTACTPREFIX) && mapConAcc.get(evt.WhoId) != NULL) {
                        evt.WhatId = mapConAcc.get(evt.WhoId);
                    }
                }
            }
        }
    }
    private void setSendAlert() {

     for (Event tempEvent : (List<Event>)Trigger.new) {
   
       //Workflow rule (Set Activity Type) and its associated field update was deactivated and introduced the same functionality using the below code.
       //And also introducing the Alert sent date based on the Send alert picklist value.
       if(Trigger.isInsert && Trigger.isBefore){
           tempEvent.Activity_Type__c = tempEvent.Type  ;
                if(tempEvent.Send_Alert__c == 'No'){
                   tempEvent.Alert_Sent_Date__c = null;
               }
                else if(tempEvent.Send_Alert__c == 'Yes'){
                    tempEvent.Alert_Sent_Date__c = Datetime.now();
                }
        }

       //before update forcing send alert flag field value to 'yes' when send alert is 'yes' so that alert message condition can work.
       //Workflow rule (Set Activity Type) and its associated field update was deactivated and introduced the same functionality using the below code.
       //And also introducing the Alert sent date based on the Send alert picklist value.
        else if(Trigger.isUpdate && Trigger.isBefore){
           tempEvent.Activity_Type__c = tempEvent.Type  ; 
                if(tempEvent.Send_Alert__c == 'Yes'){
                  tempEvent.Alert_Sent_Date__c = Datetime.now();                  
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