/**************************************************************************************************
 * Name           : GS_TestEmailAlertOnTask
 * Object         : 
 * Requirement    : 
 * Target         : Test Task Trigger for email alert 
 * Refer classes  : 
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-10-19
 * Modify History :
 **************************************************************************************************/
@isTest
private class GS_TestEmailAlertOnTask {

    static testMethod void taskEmailAlert() 
    {

        User testUser = GS_TestDataCreator.createUser('Operations User', 'OperationsUser@test.com', 'APAC');
        
        AccountTeamMember accTeamMember = new AccountTeamMember();
        Alert_Groups__c testAlertGroup = new Alert_Groups__c();

        System.runAs(testUser)
        {

            Account testAccount = GS_TestDataCreator.createAccount('TestAccount');
            Contact testContact = GS_TestDataCreator.createContact('testA', testAccount);

            testAlertGroup.Name = 'CorpIR-TEST';
            testAlertGroup.Group_Name__c = 'CorpIR - GMI';
            testAlertGroup.Group_Email__c = 'alert.group@test.com';
            insert testAlertGroup;

            accTeamMember.UserId = testUser.Id;
            accTeamMember.AccountId = testAccount.Id;

            insert accTeamMember;

            Task testTask1 = GS_TestDataCreator.createTask(testUser,testContact,false);
            Task testTask2 = GS_TestDataCreator.createTask(testUser,testContact,true);
            Task testTask3 = GS_TestDataCreator.createTask(testUser,testContact,true);
            Task testTask4 = GS_TestDataCreator.createTask(testUser,testContact,true);
            Task testTask5 = GS_TestDataCreator.createTask(testUser,testContact,false);
            Task testTask6 = GS_TestDataCreator.createTask(testUser,testContact,false);

            testTask1.Send_Alert__c = 'Yes';
            testTask1.Alert_Coverage_Groups__c = testAlertGroup.Group_Name__c;
            insert testTask1;

            testTask2.Type = 'Call (Voicemail)';
            update testTask2;

            testTask4.Send_Alert__c = 'Yes';
            testTask4.Status = 'Closed';
            testTask4.Alert_Coverage_Groups__c = testAlertGroup.Group_Name__c;
            update testTask4;
            
            testTask5.Send_Alert__c = 'Yes';
            testTask5.Status = 'Closed';
            testTask5.Alert_Coverage_Groups__c = testAlertGroup.Group_Name__c;
            insert testTask5;
            
           // testTask6.Send_Alert__c = 'Yes';
            testTask6.Type = 'Email';
            testTask6.Status = 'Closed';
            testTask6.Alert_Coverage_Groups__c = testAlertGroup.Group_Name__c;
            insert testTask6;
       

            List<Task> lstTaskResult = [select Id, Send_Alert__c, Alert_Sent_Date__c,Type from Task where Id =:testTask1.Id ];
            if(lstTaskResult.size() > 0)
            {
                System.assertEquals('Yes', lstTaskResult[0].Send_Alert__c);
                System.assertEquals(Date.today(), lstTaskResult[0].Alert_Sent_Date__c.date());
            }
            List<Task> lstTaskResult2 = [select Id, Send_Alert__c, Alert_Sent_Date__c,Type from Task where Id =:testTask2.Id ];
            if(lstTaskResult2.size() > 0)
            {
                System.assertEquals('No', lstTaskResult2[0].Send_Alert__c);
                System.assertEquals(null, lstTaskResult2[0].Alert_Sent_Date__c);
            }
            List<Task> lstTaskResult3 = [select Id, Send_Alert__c, Alert_Sent_Date__c,Type from Task where Id =:testTask3.Id ];
            if(lstTaskResult3.size() > 0)
            {
                System.assertEquals('No', lstTaskResult3[0].Send_Alert__c);
                System.assertEquals(null, lstTaskResult3[0].Alert_Sent_Date__c);
            }
            List<Task> lstTaskResult4 = [select Id, Send_Alert__c, Alert_Sent_Date__c,Type from Task where Id =:testTask4.Id ];
            if(lstTaskResult4.size() > 0)
            {
                System.assertEquals('Yes', lstTaskResult4[0].Send_Alert__c);
                System.assertEquals(Date.today(), lstTaskResult4[0].Alert_Sent_Date__c.date());                
            }
            
            /* Author:Uday, Made following changes to use TaskDMLHandler to improve coverage */
            List<Id> lstTasks = new List<Id>();
            lstTasks.add(testTask5.Id);
            //List<Task> lstTaskResult5 = [select Id, Status, Send_Alert__c, Alert_Sent_Date__c,Type from Task where Id =:testTask5.Id ];
            List<Task> lstTaskResult5 = GS_TaskDMLHandler.getTasksByIds(lstTasks);
            if(lstTaskResult5.size() > 0)
            {
                System.assertEquals('Yes', lstTaskResult5[0].Send_Alert__c);
                System.assertEquals('Closed', lstTaskResult5[0].Status);
                System.assertEquals(Date.today(), lstTaskResult5[0].Alert_Sent_Date__c.date());
            }  
            List<Task> lstTaskResult6 = [select Id, Send_Alert__c, Alert_Sent_Date__c,Type,Created_From_Plugin__c from Task where Id =:testTask6.Id ];
            if(lstTaskResult6.size() > 0){          
	            System.assertEquals('Email (Client – Incoming/Outgoing)', lstTaskResult6[0].Type);
	            System.assertEquals(true, lstTaskResult6[0].Created_From_Plugin__c);	            
        	}     
        }
    }    
}