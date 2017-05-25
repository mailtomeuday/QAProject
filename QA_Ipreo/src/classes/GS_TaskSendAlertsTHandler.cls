/**************************************************************************************************
 * Name           : GS_TaskSendAlertsTHandler
 * Object         : Task
 * Requirement    : STY-00095
 * Target         : After a task has been created or updated, if the task has specified alert groups,
 *                  send alerts to the specified groups.
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-08-06
 * Modify History : Handled additional Email Alert when Lead is Converted.
 **************************************************************************************************/
public class GS_TaskSendAlertsTHandler implements GS_Triggers.Handler {

    private Map<Id, Id> mapTaskIdWhatId = new Map<Id, Id>();
    private Map<Id, Id> mapTaskIdAccId = new Map<Id, Id>();
    private Map<Id, Id> mapTaskIdWhoId = new Map<Id, Id>();
    // Key is taskid, value is email addresses of alert groups.
    private Map<Id, List<String>> mapTaskIdWithRecEmailAddress = new Map<Id, List<Id>>();

    public void handle() {
            
   
        // check unique tasks.
        List<Task> lstTargetTask = new List<Task>();

        // IF RecurrenceActivityId != null,
        // THEN send out alert if RecurrenceActivityId == Id
        //Handling additional email alert on Lead Convertion
        for (Task tempTask : (List<Task>)Trigger.new) { 
            if(Trigger.isUpdate){
                Task oldTask = (Task)Trigger.oldMap.get(tempTask.id);
                System.debug('tempTask.WhoId__c---'+tempTask.WhoId__c);
                System.debug('oldTask.WhoId__c---'+oldTask.WhoId__c);
                if(tempTask.WhoId__c != oldTask.WhoId__c && tempTask.WhoId__c == '003' && oldTask.WhoId__c == '00Q'){
                    continue;
                }
            }
            if (tempTask.Send_Alert__c == 'Yes') {
                if (tempTask.RecurrenceActivityId != NULL) {
                    lstTargetTask.add(tempTask);
                } else if (tempTask.RecurrenceActivityId == NULL) {
                    lstTargetTask.add(tempTask);
                }
            }
        }

        System.debug(LoggingLevel.INFO, '*** lstTargetTask: ' + lstTargetTask);

        try {
            if (lstTargetTask.size() > 0) {
                sendEmail(lstTargetTask);
                setFinishedEmailAlert(lstTargetTask);
            }
        }
         catch (Exception ex) {
            System.debug(LoggingLevel.INFO, '*** ex.getMessage(): ' + ex.getMessage());
            System.debug(LoggingLevel.INFO, '*** ex.getCause(): ' + ex.getCause());
            System.debug(LoggingLevel.INFO, '*** ex.getLineNumber(): ' + ex.getLineNumber());
            Trigger.new[0].addError('Error sending alert email.  Please contact your administrator.');
        }
    }

    private void sendEmail(List<Task> lstTargetTask) {

        // Define the email template
        String emailTemplateName;

        // Value of merge fields. Id is task id.
        Map<Id, List<GS_EmailUtility.MergeFieldObject>> mapMergeFieldObject = new Map<Id, List<GS_EmailUtility.MergeFieldObject>>();

        // Value of soqls, Id is task id, every task has several soqls of different objects.
        Map<Id, Map<String, String>> mapAllObjectSoql = new Map<Id, Map<String, String>>();

        // Value of objects, Id is task id
        Map<Id, Map<String, List<SObject>>> mapObj = new Map<Id, Map<String, List<SObject>>>();

        // Value of EmailTemplate, Id is task id
        Map<Id, Map<String, String>> mapDealtEmailTemplate = new Map<Id, Map<String, String>>();

        // Get email template by specified email template and replace merge fields by actual value.
        // The reason why using the Trigger.New[0] is we only consider the general process of creating one activity, not data uploading.
            if(Trigger.New[0].get('WhoId') != NULL) {
                // if the who is a lead
                if(String.valueOf(Trigger.New[0].get('WhoId')).startsWith('00Q') && Trigger.New[0].get('WhatId') == NULL) {
                    emailTemplateName = 'Alert Standard Task Lead';
                }else {
                    emailTemplateName = 'Alert Standard Task';
                } 
            }else {
                emailTemplateName = 'Alert Standard Task';
            }

        EmailTemplate taskEmailTemplate = GS_EmailTemplateDMLHandler.getEmailTemplateByName(emailTemplateName);


        // Since the tasks may assign to multiple persons but the content is as same,
        // So the email should be sent once. If there is a senario that alerts should be sent out by data uploading of activities. This code
        // should be enhanced in to for loop.
        if (lstTargetTask.size() > 0) {
            System.debug(LoggingLevel.INFO, '*** lstTargetTask[0].WhatId: ' + lstTargetTask[0].WhatId);
            mapTaskIdWhatId.put(lstTargetTask[0].Id, lstTargetTask[0].WhatId);
            mapTaskIdAccId.put(lstTargetTask[0].Id, lstTargetTask[0].AccountId);
            mapTaskIdWhoId.put(lstTargetTask[0].Id, lstTargetTask[0].WhoId);
            mapMergeFieldObject.put(lstTargetTask[0].Id, GS_EmailUtility.getObjWithFieldsFromString(taskEmailTemplate.HtmlValue + taskEmailTemplate.Body + taskEmailTemplate.Subject));
        }

        for (Id tempId : mapMergeFieldObject.keySet()) {
            mapAllObjectSoql.put(tempId, GS_EmailUtility.populateSOQLs(mapMergeFieldObject.get(tempId), mapTaskIdWhatId.get(tempId), tempId, mapTaskIdWhoId.get(tempId), mapTaskIdAccId.get(tempId)));
        }

        System.debug('*** mapAllObjectSoql: ' + mapAllObjectSoql);

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
        System.debug(LoggingLevel.INFO, '*** mapObj: ' + mapObj);

        for (Id tempTaskId : mapMergeFieldObject.keySet()) {
            for (GS_EmailUtility.MergeFieldObject tempMergeFieldObject : mapMergeFieldObject.get(tempTaskId)) {
                for (GS_EmailUtility.ObjWithField tempObjField : tempMergeFieldObject.objWithFields) {

                    // For some relationship fields
                    if (tempObjField.fieldName.Split('\\.').size() > 1) {
                        if(mapObj.get(tempTaskId).get(tempObjField.objectName) != NULL){
                            if (mapObj.get(tempTaskId).get(tempObjField.objectName)[0].getSObject(tempObjField.fieldName.Split('\\.')[0]) != NULL) {
                                if (mapObj.get(tempTaskId).get(tempObjField.objectName)[0].getSObject(tempObjField.fieldName.Split('\\.')[0]).get(tempObjField.fieldName.Split('\\.')[1]) != NULL) {
                                    tempObjField.fieldValue = String.valueOf(mapObj.get(tempTaskId).get(tempObjField.objectName)[0].getSObject(tempObjField.fieldName.Split('\\.')[0]).get(tempObjField.fieldName.Split('\\.')[1]));
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
                        if(mapObj.get(tempTaskId).get(tempObjField.objectName) != NULL){
                            if(mapObj.get(tempTaskId).get(tempObjField.objectName).size() > 0){
                                if (mapObj.get(tempTaskId).get(tempObjField.objectName)[0].get(tempObjField.fieldName) != NULL) {
                                    tempObjField.fieldValue = String.valueOf(mapObj.get(tempTaskId).get(tempObjField.objectName)[0].get(tempObjField.fieldName));
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

        setTaskEmailReceivers(mapTaskIdWhatId.keySet());
        // Get populated email template
        mapDealtEmailTemplate = GS_EmailUtility.replaceEmailTemplate(mapMergeFieldObject, taskEmailTemplate);

        for (Id taskId : Trigger.newMap.keySet()) {
            if(mapTaskIdWithRecEmailAddress.get(taskId) != NULL){
                GS_EmailUtility.Send(mapTaskIdWithRecEmailAddress.get(taskId), mapDealtEmailTemplate.get(taskId).get('Subject'), mapDealtEmailTemplate.get(taskId).get('Text'), mapDealtEmailTemplate.get(taskId).get('Html'));
            }
        }
    }

    // Set Email Receivers
    private void setTaskEmailReceivers(Set<Id> lstTaskId) {

        // Key is task id, value is corresponding task.
        Map<Id, Task> mapTask = new Map<Id, Task>();

        // Key is task id, value is accountid. On these tasks, if account team members are seleceted, they should be get value from what object
        Map<Id, Id> mapTaskIdWithAccIds = new Map<Id, Id>();

        // Task id without accountids. On these tasks, account team member can be directly found out.
        Set<Id> stTaskIdWithoutAccIds = new Set<Id>();

        // Check if the task need to be sent to account team.
        Set<Id> stCheckAccId = new Set<Id>();

        // Key is task id, value is alert groups. Used to check the tasks' alert groups
        Map<Id, List<String>> mapTaskIdWithAlertGroups = new Map<Id, List<String>>();

        // Key is task id, value is individuals. Used to check the tasks' alert groups
        Map<Id, List<String>> mapTaskIdWithIndividuals = new Map<Id, List<String>>();

        // Get all errors when locate alert groups.
        Map<Id, List<String>> mapAlertGroupErrorMsg = new Map<Id, List<String>>();

        // Get all errors when locate individuals.
        Map<Id, List<String>> mapIndividualsErrorMsg = new Map<Id, List<String>>();

        // When two tasks are created at the same time on the standard UI, the account of them are the one.
        List<AccountTeamMember> lstAccTeamMem = new List<AccountTeamMember>();

        mapTask = (Map<Id, Task>)Trigger.newMap;

        // Assign mapTaskIdWithAlertGroups and mapTaskIdWithIndividuals to check if there's invalid option.
        for (Id tempTaskId : lstTaskId) {
            if (mapTask.get(tempTaskId).Alert_Coverage_Groups__c != NULL) {
                mapTaskIdWithAlertGroups.put(tempTaskId, mapTask.get(tempTaskId).Alert_Coverage_Groups__c.Split(';'));
                if (mapTask.get(tempTaskId).Alert_Coverage_Groups__c.Contains('Account Team')) {
                    stCheckAccId.add(tempTaskId);
                    if (mapTask.get(tempTaskId).AccountId != NULL) {
                        mapTaskIdWithAccIds.put(tempTaskId, mapTask.get(tempTaskId).AccountId);
                    } else {
                        stTaskIdWithoutAccIds.add(tempTaskId);
                    }
                }
            }

            if (mapTask.get(tempTaskId).Alert_Individual_Users__c != NULL) {
                mapTaskIdWithIndividuals.put(tempTaskId, mapTask.get(tempTaskId).Alert_Individual_Users__c.Split(';'));
            }
        }

        System.debug(LoggingLevel.INFO, '*** mapTaskIdWithAlertGroups: ' + mapTaskIdWithAlertGroups);
        System.debug(LoggingLevel.INFO, '*** mapTaskIdWithIndividuals: ' + mapTaskIdWithIndividuals);


        // Deal with Account team
        //=================================================================================================

        // Get all what object's account id
        Set<Id> stIdRelateToWO = new Set<Id>();
        Set<Id> stIdRelateToAsset = new Set<Id>();
        Set<Id> stIdRelateToCon = new Set<Id>();

        for (Id tempTaskId : stTaskIdWithoutAccIds) {
            if (GS_CommonUtility.isObjectAndIdCorresponding('Work_Order__c', mapTask.get(tempTaskId).WhatId)) {
                stIdRelateToWO.add(mapTask.get(tempTaskId).WhatId);
            } else if (GS_CommonUtility.isObjectAndIdCorresponding('Asset', mapTask.get(tempTaskId).WhatId)) {
                stIdRelateToAsset.add(mapTask.get(tempTaskId).WhatId);
            } else if (GS_CommonUtility.isObjectAndIdCorresponding('Contract__c', mapTask.get(tempTaskId).WhatId)) {
                stIdRelateToCon.add(mapTask.get(tempTaskId).WhatId);
            }
        }

        for(Work_Order__c tempWo : [SELECT Id, Account__c FROM Work_Order__c WHERE Id = : stIdRelateToWO ]) {
            for (Id tempTaskId : stTaskIdWithoutAccIds) {
                if(mapTask.get(tempTaskId).WhatId == tempWo.Id) {
                    mapTaskIdWithAccIds.put(tempTaskId, tempWo.Account__c);
                }
            }
        }

        for(Asset tempAsset : [SELECT Id, AccountId FROM Asset WHERE Id = : stIdRelateToAsset ]) {
            for (Id tempTaskId : stTaskIdWithoutAccIds) {
                if(mapTask.get(tempTaskId).WhatId == tempAsset.Id) {
                    mapTaskIdWithAccIds.put(tempTaskId, tempAsset.AccountId);
                }
            }
        }

        for(Contract__c tempCon : [SELECT Id, Account__c FROM Contract__c WHERE Id = : stIdRelateToCon ]) {
            for (Id tempTaskId : stTaskIdWithoutAccIds) {
                if(mapTask.get(tempTaskId).WhatId == tempCon.Id) {
                    mapTaskIdWithAccIds.put(tempTaskId, tempCon.Account__c);
                }
            }
        }

        // Loop task ids which required account id, if the no account id found for a task, throw error.

        for (Id sendToAccTeamTaskId : stCheckAccId) {
            if (!mapTaskIdWithAccIds.containsKey(sendToAccTeamTaskId)) {
                if (mapAlertGroupErrorMsg.containsKey(sendToAccTeamTaskId)) {
                    mapAlertGroupErrorMsg.get(sendToAccTeamTaskId).add(System.label.Msg_Locate_Account_Error + '\n');
                } else {
                    mapAlertGroupErrorMsg.put(sendToAccTeamTaskId, new List<String> {System.label.Msg_Locate_Account_Error});
                }
            }
        }

        if (!mapTaskIdWithAccIds.isEmpty()) {
            lstAccTeamMem = GS_AccountDMLHandler.getAccTeamMemsByAccIds(mapTaskIdWithAccIds.values());
        }

        for (AccountTeamMember tempTeamMember : lstAccTeamMem) {
            for (Id tempTaskId : mapTaskIdWithAccIds.keySet()) {
                if (mapTaskIdWithAccIds.get(tempTaskId) == tempTeamMember.AccountId) {
                    if (mapTaskIdWithRecEmailAddress.containsKey(tempTaskId)) {
                        mapTaskIdWithRecEmailAddress.get(tempTaskId).add(tempTeamMember.User.Email);
                    } else {
                        mapTaskIdWithRecEmailAddress.put(tempTaskId, new List<String> {tempTeamMember.User.Email});
                    }
                }
            }
        }

        for (Id tempTaskId : mapTaskIdWithAccIds.keySet()) {
            if(mapTaskIdWithRecEmailAddress.get(tempTaskId) == NULL) {
                if (mapAlertGroupErrorMsg.containsKey(tempTaskId)) {
                    mapAlertGroupErrorMsg.get(tempTaskId).add(System.label.Msg_No_Member_on_Account_Team + '\n');
                } else {
                    mapAlertGroupErrorMsg.put(tempTaskId, new List<String> {System.label.Msg_No_Member_on_Account_Team});
                }
            }
        }


        // Deal with alert groups
        //=================================================================================================

        // Key is Group name, value is email address.
        Map<String, String> mapAlertGroupEmailAddress = new Map<String, String>();

        for (Id tempTaskId : mapTaskIdWithAlertGroups.keySet()) {
            for (String alertGroupName : mapTaskIdWithAlertGroups.get(tempTaskId)) {
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

        System.debug(LoggingLevel.INFO, '*** mapAlertGroupEmailAddress: ' + mapAlertGroupEmailAddress);


        // Add alert group user id to the return value and validate if there's a group can not be found.
        for (Id tempTaskId : mapTaskIdWithAlertGroups.keySet()) {
            for (String alertGroupName : mapTaskIdWithAlertGroups.get(tempTaskId)) {
                if (mapAlertGroupEmailAddress.containsKey(alertGroupName)) {
                    if (String.isNotBlank(mapAlertGroupEmailAddress.get(alertGroupName))) {
                        if (mapTaskIdWithRecEmailAddress.containsKey(tempTaskId)) {
                            mapTaskIdWithRecEmailAddress.get(tempTaskId).add(mapAlertGroupEmailAddress.get(alertGroupName));
                        } else {
                            mapTaskIdWithRecEmailAddress.put(tempTaskId, new List<String> {mapAlertGroupEmailAddress.get(alertGroupName)});
                        }
                    } else {
                        if (mapAlertGroupErrorMsg.containsKey(tempTaskId)) {
                            mapAlertGroupErrorMsg.get(tempTaskId).add(System.label.Msg_Cannot_Locate_an_Alert_Group_Head + ' ' + alertGroupName + System.label.Msg_Cannot_Locate_an_Alert_Group_Foot);
                        } else {
                            mapAlertGroupErrorMsg.put(tempTaskId, new List<String> {System.label.Msg_Cannot_Locate_an_Alert_Group_Head + ' ' + alertGroupName + System.label.Msg_Cannot_Locate_an_Alert_Group_Foot});
                        }
                    }
                }
            }
        }



        // Deal with selected individuals and select their emails to add these emails to the addresses.
        //=================================================================================================
        Set<String> selectedUsersName = new Set<String>();

        // Key is User Name, this field is used to check the emails of the selected user on these tasks.
        Map<String, User> mapSelectedUsers = new Map<String, User>();

        for(Id tskId : mapTask.keySet()) {
            if(mapTask.get(tskId).Alert_Individual_Users__c != '' && mapTask.get(tskId).Alert_Individual_Users__c != NULL) {
                for(String strUserName : mapTask.get(tskId).Alert_Individual_Users__c.split(';')) {
                    selectedUsersName.add(strUserName);
                }
            }
        }

        for(User selectedUser : GS_UserDMLHandler.getUsersByNames(selectedUsersName)) {
            mapSelectedUsers.put(selectedUser.Name, selectedUser);
        }

        System.debug(LoggingLevel.INFO, '*** mapSelectedUsers: ' + mapSelectedUsers);

        // Validate if there's a user can not be found. 
        for (Id tempTaskId : mapTaskIdWithIndividuals.keySet()) {
            for (String individualName : mapTaskIdWithIndividuals.get(tempTaskId)) {
                if (mapSelectedUsers.containsKey(individualName)) {
                    if (mapSelectedUsers.get(individualName) != NULL) {
                        if (mapTaskIdWithRecEmailAddress.containsKey(tempTaskId)) {
                            mapTaskIdWithRecEmailAddress.get(tempTaskId).add(mapSelectedUsers.get(individualName).Email);
                        } else {
                            mapTaskIdWithRecEmailAddress.put(tempTaskId, new List<String> {mapSelectedUsers.get(individualName).Email});
                        }
                    } else {
                        if (mapIndividualsErrorMsg.containsKey(tempTaskId)) {
                            mapIndividualsErrorMsg.get(tempTaskId).add(System.label.Msg_Cannot_Locate_an_Individual_Head + ' ' + individualName + System.label.Msg_Cannot_Locate_an_Individual_Foot);
                        } else {
                            mapIndividualsErrorMsg.put(tempTaskId, new List<String> {System.label.Msg_Cannot_Locate_an_Individual_Head + ' ' + individualName + System.label.Msg_Cannot_Locate_an_Individual_Foot});
                        }
                    }
                } else {
                    if (mapIndividualsErrorMsg.containsKey(tempTaskId)) {
                        mapIndividualsErrorMsg.get(tempTaskId).add(System.label.Msg_Cannot_Locate_an_Individual_Head + ' ' + individualName + System.label.Msg_Cannot_Locate_an_Individual_Foot);
                    } else {
                        mapIndividualsErrorMsg.put(tempTaskId, new List<String> {System.label.Msg_Cannot_Locate_an_Individual_Head + ' ' + individualName + System.label.Msg_Cannot_Locate_an_Individual_Foot});
                    }
                }
            }
        }

        System.debug(LoggingLevel.INFO, '*** mapTaskIdWithRecEmailAddress: ' + mapTaskIdWithRecEmailAddress);
        System.debug(LoggingLevel.INFO, '*** mapIndividualsErrorMsg: ' + mapIndividualsErrorMsg);
        System.debug(LoggingLevel.INFO, '*** mapAlertGroupErrorMsg: ' + mapAlertGroupErrorMsg);

        for (Id taskId : mapIndividualsErrorMsg.keySet()) {
            mapTask.get(taskId).Alert_Individual_Users__c.addError(String.join(mapIndividualsErrorMsg.get(taskId), ' '));
        }

        for (Id taskId : mapAlertGroupErrorMsg.keySet()) {
            mapTask.get(taskId).Alert_Coverage_Groups__c.addError(String.join(mapAlertGroupErrorMsg.get(taskId), ' '));
        }

    }

    private void setFinishedEmailAlert(List<Task> lstTask) {
        List<Id> targetTaskId = new List<Id>();
        List<Task> lstTargetTask = new List<Task>();
        for (Task tempTask : lstTask) {
            targetTaskId.add(tempTask.Id);
        }
       
    }
}