/**************************************************************************************************
 * Name           : GS_EventSendAlertsTHandler
 * Object         : Event
 * Requirement    : STY-00095
 * Target         : After a event has been created or updated, if the event has specified alert groups,
 *                  send alerts to the specified groups.
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-08-06
 * Modify History : Handled additional Email Alert when Lead is Converted.
 **************************************************************************************************/
public class GS_EventSendAlertsTHandler implements GS_Triggers.Handler {

    private Map<Id, Id> mapEventIdWhatId = new Map<Id, Id>();
    private Map<Id, Id> mapEventIdAccId = new Map<Id, Id>();
    private Map<Id, Id> mapEventIdWhoId = new Map<Id, Id>();
    
    // Key is eventid, value is email addresses of alert groups.
    private Map<Id, List<String>> mapEventIdWithRecEmailAddress = new Map<Id, List<Id>>();

    public void handle() {

        // check unique events.
        List<Event> lstTargetEvent = new List<Event>();
        

        // IF RecurrenceActivityId != null,
        // THEN send out alert if RecurrenceActivityId == Id
        //Handled additional Email Alert when Lead is Converted.
        for (Event tempEvent : (List<Event>)Trigger.new) {
            if(Trigger.isUpdate){
                Event oldEvent = (Event)Trigger.oldMap.get(tempEvent.id);
                System.debug('tempEvent.WhoId__c---'+tempEvent.WhoId__c);
                System.debug('oldEvent.WhoId__c---'+oldEvent.WhoId__c);
                if(tempEvent.WhoId__c != oldEvent.WhoId__c && tempEvent.WhoId__c == '003' && oldEvent.WhoId__c == '00Q'){
                    continue;
                }
            }
      
            if (tempEvent.Send_Alert__c == 'Yes') {
                if (tempEvent.RecurrenceActivityId != NULL && tempEvent.RecurrenceActivityId == tempEvent.Id) {
                    lstTargetEvent.add(tempEvent);
                } else if (tempEvent.RecurrenceActivityId == NULL) {
                    lstTargetEvent.add(tempEvent);
                }
            }
      }
 
        System.debug(LoggingLevel.INFO, '*** lstTargetEvent: ' + lstTargetEvent);

        try {
            if (lstTargetEvent.size() > 0) {
                sendEmail(lstTargetEvent);
                setFinishedEmailAlert(lstTargetEvent);
            }
        }
         catch (Exception ex) {
            System.debug(LoggingLevel.INFO, '*** ex.getMessage(): ' + ex.getMessage());
            Trigger.new[0].addError('Error sending alert email.  Please contact your administrator.');
        }
    }

    private void sendEmail(List<Event> lstTargetEvent) {
    

        // Define the email template
        String emailTemplateName;

        // Value of merge fields. Id is event id.
        Map<Id, List<GS_EmailUtility.MergeFieldObject>> mapMergeFieldObject = new Map<Id, List<GS_EmailUtility.MergeFieldObject>>();

        // Value of soqls, Id is event id, every event has several soqls of different objects.
        Map<Id, Map<String, String>> mapAllObjectSoql = new Map<Id, Map<String, String>>();

        // Value of objects, Id is event id
        Map<Id, Map<String, List<SObject>>> mapObj = new Map<Id, Map<String, List<SObject>>>();

        // Value of EmailTemplate, Id is event id
        Map<Id, Map<String, String>> mapDealtEmailTemplate = new Map<Id, Map<String, String>>();


        // Get email template by specified email template and replace merge fields by actual value.
        // The reason why using the Trigger.New[0] is we only consider the general process of creating one activity, not data uploading.
        if(Trigger.New[0].get('WhoId') != NULL) {
            // if the who is a lead
            if(String.valueOf(Trigger.New[0].get('WhoId')).startsWith('00Q') && Trigger.New[0].get('WhatId') == NULL) {
                emailTemplateName = 'Alert Standard Event Lead';
            }else {
                emailTemplateName = 'Alert Standard Event';
            }
        } else {
            emailTemplateName = 'Alert Standard Event';
        }

        EmailTemplate eventEmailTemplate = GS_EmailTemplateDMLHandler.getEmailTemplateByName(emailTemplateName);


        // Since the events may assign to multiple persons but the content is as same,
        // So the email should be sent once.
        if (lstTargetEvent.size() > 0) {
            System.debug(LoggingLevel.INFO, '*** lstTargetEvent[0].WhatId: ' + lstTargetEvent[0].WhatId);
            mapEventIdWhatId.put(lstTargetEvent[0].Id, lstTargetEvent[0].WhatId);
            mapEventIdAccId.put(lstTargetEvent[0].Id, lstTargetEvent[0].AccountId);
            mapEventIdWhoId.put(lstTargetEvent[0].Id, lstTargetEvent[0].WhoId);
            mapMergeFieldObject.put(lstTargetEvent[0].Id, GS_EmailUtility.getObjWithFieldsFromString(eventEmailTemplate.HtmlValue + eventEmailTemplate.Body + eventEmailTemplate.Subject));
        }

        for (Id tempId : mapMergeFieldObject.keySet()) {
            mapAllObjectSoql.put(tempId, GS_EmailUtility.populateSOQLs(mapMergeFieldObject.get(tempId), mapEventIdWhatId.get(tempId), tempId, mapEventIdWhoId.get(tempId), mapEventIdAccId.get(tempId)));
        }


        // Different Objects need to be queried
        for (Id tempId : mapAllObjectSoql.keySet()) {
            Map<String, List<SObject>> tempObjMap = new Map<String, List<SObject>>();
            for (String tempObjectName : mapAllObjectSoql.get(tempId).keySet()) {
                if(String.isNotBlank((mapAllObjectSoql.get(tempId)).get(tempObjectName))) {
                    tempObjMap.put(tempObjectName, Database.query((mapAllObjectSoql.get(tempId)).get(tempObjectName)));
                }
            }
            mapObj.put(tempId, tempObjMap);
        }

        for (Id tempEventId : mapMergeFieldObject.keySet()) {
            for (GS_EmailUtility.MergeFieldObject tempMergeFieldObject : mapMergeFieldObject.get(tempEventId)) {
                for (GS_EmailUtility.ObjWithField tempObjField : tempMergeFieldObject.objWithFields) {

                    // For some relationship fields
                    if (tempObjField.fieldName.Split('\\.').size() > 1) {
                        if(mapObj.get(tempEventId).get(tempObjField.objectName) != NULL){
                            if (mapObj.get(tempEventId).get(tempObjField.objectName)[0].getSObject(tempObjField.fieldName.Split('\\.')[0]) != NULL) {
                                if (mapObj.get(tempEventId).get(tempObjField.objectName)[0].getSObject(tempObjField.fieldName.Split('\\.')[0]).get(tempObjField.fieldName.Split('\\.')[1]) != NULL) {
                                    tempObjField.fieldValue = String.valueOf(mapObj.get(tempEventId).get(tempObjField.objectName)[0].getSObject(tempObjField.fieldName.Split('\\.')[0]).get(tempObjField.fieldName.Split('\\.')[1]));
                                } else {
                                    tempObjField.fieldValue = '';
                                }
                            } else {
                                tempObjField.fieldValue = '';
                            }
                        } else {
                                tempObjField.fieldValue = '';
                        }
                    } else {
                        if(mapObj.get(tempEventId).get(tempObjField.objectName) != NULL){
                            if(mapObj.get(tempEventId).get(tempObjField.objectName).size() > 0){
                                if (mapObj.get(tempEventId).get(tempObjField.objectName)[0].get(tempObjField.fieldName) != NULL) {
                                    tempObjField.fieldValue = String.valueOf(mapObj.get(tempEventId).get(tempObjField.objectName)[0].get(tempObjField.fieldName));
                                } else {
                                    tempObjField.fieldValue = '';
                                }
                            } else {
                                tempObjField.fieldValue = '';
                            }
                        } else {
                                tempObjField.fieldValue = '';
                        }
                    }
                }
            }
        }

        setEventEmailReceivers(mapEventIdWhatId.keySet());
        // Get populated email template
        mapDealtEmailTemplate = GS_EmailUtility.replaceEmailTemplate(mapMergeFieldObject, eventEmailTemplate);

        for (Id eventId : Trigger.newMap.keySet()) {
            if(mapEventIdWithRecEmailAddress.get(eventId) != NULL){
                GS_EmailUtility.Send(mapEventIdWithRecEmailAddress.get(eventId), mapDealtEmailTemplate.get(eventId).get('Subject'), mapDealtEmailTemplate.get(eventId).get('Text'), mapDealtEmailTemplate.get(eventId).get('Html'));
            }
        }
    }

    private void setEventEmailReceivers(Set<Id> lstEventId) {

        // Key is event id, value is accountid
        Map<Id, Id> mapEventIdWithAccIds = new Map<Id, Id>();
        // Event id without accountids
        Set<Id> stEventIdWithoutAccIds = new Set<Id>();

        // Check if the event need to be sent to account team.
        Set<Id> stCheckAccId = new Set<Id>();

        // Key is event id, value is corresponding event.
        Map<Id, Event> mapEvent = new Map<Id, Event>();
        mapEvent = (Map<Id, Event>)Trigger.newMap;

        // Key is event id, value is alert groups
        Map<Id, List<String>> mapEventIdWithAlertGroups = new Map<Id, List<String>>();

        // Key is event id, value is individuals. Used to check the events' alert groups
        Map<Id, List<String>> mapEventIdWithIndividuals = new Map<Id, List<String>>();

        // Get all errors when locate alert groups.
        Map<Id, List<String>> mapAlertGroupErrorMsg = new Map<Id, List<String>>();

        // Get all errors when locate individuals.
        Map<Id, List<String>> mapIndividualsErrorMsg = new Map<Id, List<String>>();

        List<AccountTeamMember> lstAccTeamMem = new List<AccountTeamMember>();

        for (Id tempEventId : lstEventId) {
            if (mapEvent.get(tempEventId).Alert_Coverage_Groups__c != NULL) {
                mapEventIdWithAlertGroups.put(tempEventId, mapEvent.get(tempEventId).Alert_Coverage_Groups__c.Split(';'));
                if (mapEvent.get(tempEventId).Alert_Coverage_Groups__c.Contains('Account Team')) {
                    stCheckAccId.add(tempEventId);
                    if (mapEvent.get(tempEventId).AccountId != NULL) {
                        mapEventIdWithAccIds.put(tempEventId, mapEvent.get(tempEventId).AccountId);
                    } else {
                        stEventIdWithoutAccIds.add(tempEventId);
                    }
                }
            }

            if (mapEvent.get(tempEventId).Alert_Individual_Users__c != NULL) {
                mapEventIdWithIndividuals.put(tempEventId, mapEvent.get(tempEventId).Alert_Individual_Users__c.Split(';'));
            }
        }


        // Deal with Account team
        //=================================================================================================

        // Get all what object's account id
        Set<Id> stIdRelateToWO = new Set<Id>();
        Set<Id> stIdRelateToAsset = new Set<Id>();
        Set<Id> stIdRelateToCon = new Set<Id>();

        for (Id tempEventId : stEventIdWithoutAccIds) {
            if (GS_CommonUtility.isObjectAndIdCorresponding('Work_Order__c', mapEvent.get(tempEventId).WhatId)) {
                stIdRelateToWO.add(mapEvent.get(tempEventId).WhatId);
            } else if (GS_CommonUtility.isObjectAndIdCorresponding('Asset', mapEvent.get(tempEventId).WhatId)) {
                stIdRelateToAsset.add(mapEvent.get(tempEventId).WhatId);
            } else if (GS_CommonUtility.isObjectAndIdCorresponding('Contract__c', mapEvent.get(tempEventId).WhatId)) {
                stIdRelateToCon.add(mapEvent.get(tempEventId).WhatId);
            }
        }

        for(Work_Order__c tempWo : [SELECT Id, Account__c FROM Work_Order__c WHERE Id = : stIdRelateToWO ]) {
            for (Id tempEventId : stEventIdWithoutAccIds) {
                if(mapEvent.get(tempEventId).WhatId == tempWo.Id) {
                    mapEventIdWithAccIds.put(tempEventId, tempWo.Account__c);
                }
            }
        }

        for(Asset tempAsset : [SELECT Id, AccountId FROM Asset WHERE Id = : stIdRelateToAsset ]) {
            for (Id tempEventId : stEventIdWithoutAccIds) {
                if(mapEvent.get(tempEventId).WhatId == tempAsset.Id) {
                    mapEventIdWithAccIds.put(tempEventId, tempAsset.AccountId);
                }
            }
        }

        for(Contract__c tempCon : [SELECT Id, Account__c FROM Contract__c WHERE Id = : stIdRelateToCon ]) {
            for (Id tempEventId : stEventIdWithoutAccIds) {
                if(mapEvent.get(tempEventId).WhatId == tempCon.Id) {
                    mapEventIdWithAccIds.put(tempEventId, tempCon.Account__c);
                }
            }
        }

        // Loop event ids which required account id, if the no account id found for a event, throw error.

        for (Id sendToAccTeamEventId : stCheckAccId) {
            if (!mapEventIdWithAccIds.containsKey(sendToAccTeamEventId)) {
                if (mapAlertGroupErrorMsg.containsKey(sendToAccTeamEventId)) {
                    mapAlertGroupErrorMsg.get(sendToAccTeamEventId).add(System.label.Msg_Locate_Account_Error + '\n');
                } else {
                    mapAlertGroupErrorMsg.put(sendToAccTeamEventId, new List<String> {System.label.Msg_Locate_Account_Error});
                }
            }
        }

        if (!mapEventIdWithAccIds.isEmpty()) {
            lstAccTeamMem = GS_AccountDMLHandler.getAccTeamMemsByAccIds(mapEventIdWithAccIds.values());
        }

        for (AccountTeamMember tempTeamMember : lstAccTeamMem) {
            for (Id tempEventId : mapEventIdWithAccIds.keySet()) {
                if (mapEventIdWithAccIds.get(tempEventId) == tempTeamMember.AccountId) {
                    if (mapEventIdWithRecEmailAddress.containsKey(tempEventId)) {
                        mapEventIdWithRecEmailAddress.get(tempEventId).add(tempTeamMember.User.Email);
                    } else {
                        mapEventIdWithRecEmailAddress.put(tempEventId, new List<String> {tempTeamMember.User.Email});
                    }
                }
            }
        }

        for (Id tempEventId : mapEventIdWithAccIds.keySet()) {
            if(mapEventIdWithRecEmailAddress.get(tempEventId) == NULL) {
                if (mapAlertGroupErrorMsg.containsKey(tempEventId)) {
                    mapAlertGroupErrorMsg.get(tempEventId).add(System.label.Msg_No_Member_on_Account_Team + '\n');
                } else {
                    mapAlertGroupErrorMsg.put(tempEventId, new List<String> {System.label.Msg_No_Member_on_Account_Team});
                }
            }
        }


        // Deal with alert groups
        //=================================================================================================

        // Key is Group name, value is email address.
        Map<String, String> mapAlertGroupEmailAddress = new Map<String, String>();

        for (Id tempEventId : mapEventIdWithAlertGroups.keySet()) {
            for (String alertGroupName : mapEventIdWithAlertGroups.get(tempEventId)) {
                if (!mapAlertGroupEmailAddress.containsKey(alertGroupName)) {
                    if (alertGroupName != 'Account Team') {
                        mapAlertGroupEmailAddress.put(alertGroupName, '');
                    }
                }
            }
        }

        // Get email addresses by alert groups
        if (!mapAlertGroupEmailAddress.isEmpty()) {
            for (Alert_Groups__c tempGroup : GS_CustomSettingDMLHandler.getAlertGroupsByNames(mapAlertGroupEmailAddress.keySet())) {
                mapAlertGroupEmailAddress.put(tempGroup.Group_Name__c, tempGroup.Group_Email__c);
            }
        }

        // Add alert group user id to the return value and validate if there's a group can not be found.
        for (Id tempEventId : mapEventIdWithAlertGroups.keySet()) {
            for (String alertGroupName : mapEventIdWithAlertGroups.get(tempEventId)) {
                if (mapAlertGroupEmailAddress.containsKey(alertGroupName)) {
                    if (String.isNotBlank(mapAlertGroupEmailAddress.get(alertGroupName))) {
                        if (mapEventIdWithRecEmailAddress.containsKey(tempEventId)) {
                            mapEventIdWithRecEmailAddress.get(tempEventId).add(mapAlertGroupEmailAddress.get(alertGroupName));
                        } else {
                            mapEventIdWithRecEmailAddress.put(tempEventId, new List<String> {mapAlertGroupEmailAddress.get(alertGroupName)});
                        }
                    } else {
                        if (mapAlertGroupErrorMsg.containsKey(tempEventId)) {
                            mapAlertGroupErrorMsg.get(tempEventId).add(System.label.Msg_Cannot_Locate_an_Alert_Group_Head + ' ' + alertGroupName + System.label.Msg_Cannot_Locate_an_Alert_Group_Foot);
                        } else {
                            mapAlertGroupErrorMsg.put(tempEventId, new List<String> {System.label.Msg_Cannot_Locate_an_Alert_Group_Head + ' ' + alertGroupName + System.label.Msg_Cannot_Locate_an_Alert_Group_Foot});
                        }
                    }
                }
            }
        }



        // Deal with selected individuals and select their emails to add these emails to the addresses.
        //=================================================================================================
        Set<String> selectedUsersName = new Set<String>();

        // Key is User Name, this field is used to check the emails of the selected user on these events.
        Map<String, User> mapSelectedUsers = new Map<String, User>();

        for(Id tskId : mapEvent.keySet()) {
            if(mapEvent.get(tskId).Alert_Individual_Users__c != '' && mapEvent.get(tskId).Alert_Individual_Users__c != NULL) {
                for(String strUserName : mapEvent.get(tskId).Alert_Individual_Users__c.split(';')) {
                    selectedUsersName.add(strUserName);
                }
            }
        }

        for(User selectedUser : GS_UserDMLHandler.getUsersByNames(selectedUsersName)) {
            mapSelectedUsers.put(selectedUser.Name, selectedUser);
        }

        System.debug(LoggingLevel.INFO, '*** mapSelectedUsers: ' + mapSelectedUsers);

        // Validate if there's a user can not be found. 
        for (Id tempEventId : mapEventIdWithIndividuals.keySet()) {
            for (String individualName : mapEventIdWithIndividuals.get(tempEventId)) {
                if (mapSelectedUsers.containsKey(individualName)) {
                    if (mapSelectedUsers.get(individualName) != NULL) {
                        if (mapEventIdWithRecEmailAddress.containsKey(tempEventId)) {
                            mapEventIdWithRecEmailAddress.get(tempEventId).add(mapSelectedUsers.get(individualName).Email);
                        } else {
                            mapEventIdWithRecEmailAddress.put(tempEventId, new List<String> {mapSelectedUsers.get(individualName).Email});
                        }
                    } else {
                        if (mapIndividualsErrorMsg.containsKey(tempEventId)) {
                            mapIndividualsErrorMsg.get(tempEventId).add(System.label.Msg_Cannot_Locate_an_Individual_Head + ' ' + individualName + System.label.Msg_Cannot_Locate_an_Individual_Foot);
                        } else {
                            mapIndividualsErrorMsg.put(tempEventId, new List<String> {System.label.Msg_Cannot_Locate_an_Individual_Head + ' ' + individualName + System.label.Msg_Cannot_Locate_an_Individual_Foot});
                        }
                    }
                } else {
                    if (mapIndividualsErrorMsg.containsKey(tempEventId)) {
                        mapIndividualsErrorMsg.get(tempEventId).add(System.label.Msg_Cannot_Locate_an_Individual_Head + ' ' + individualName + System.label.Msg_Cannot_Locate_an_Individual_Foot);
                    } else {
                        mapIndividualsErrorMsg.put(tempEventId, new List<String> {System.label.Msg_Cannot_Locate_an_Individual_Head + ' ' + individualName + System.label.Msg_Cannot_Locate_an_Individual_Foot});
                    }
                }
            }
        }

        for (Id eventId : mapIndividualsErrorMsg.keySet()) {
            mapEvent.get(eventId).Alert_Individual_Users__c.addError(String.join(mapIndividualsErrorMsg.get(eventId), ' '));
        }
        

        for (Id eventId : mapAlertGroupErrorMsg.keySet()) {
            mapEvent.get(eventId).Alert_Coverage_Groups__c.addError(String.join(mapAlertGroupErrorMsg.get(eventId), ' '), false);
        }

    }

    private void setFinishedEmailAlert(List<Event> lstEvent) {
        List<Id> targetEventId = new List<Id>();
        List<Event> lstTargetEvent = new List<Event>();
        for (Event tempEvent : lstEvent) {
            targetEventId.add(tempEvent.Id);
        }
      
      
    }
    
      
}