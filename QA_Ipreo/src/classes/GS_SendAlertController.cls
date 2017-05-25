/**************************************************************************************************
* Name           : GS_SendAlertController
* Object         : CampaignMember
* Requirement    : STY-00095
* Target         : A utility class to send email on CampaignMember Status Change. Used this class in Process builder to send emails to Sales Rep
* Refer classes  :
* Author         : Uday Bikkumalla (Uday_Bikkumalla@epam.com)
* Create Date    : 2016-11-30
* Modify History :
**************************************************************************************************/
public class GS_SendAlertController {
    
    @InvocableMethod(label='Send Alert to Sales Reps' description='Alerts Sales Rep when Campaign Member Status changes to Clicked')
    public static void sendEmail(List<ID> ids) {
        List<String> Statues = new List<String>();
        
        //New instance of a single email message
        Map<Id, List<GS_EmailUtility.MergeFieldObject>> mapMergeFieldObject = new Map<Id, List<GS_EmailUtility.MergeFieldObject>>();
        Map<Id, Map<String, String>> mapDealtEmailTemplate = new Map<Id, Map<String, String>>();
        EmailTemplate eventEmailTemplate = [select id,Body,Subject,HtmlValue,name from EmailTemplate where DeveloperName = 'Notify_User_on_Campaign_Member_Status_Change' limit 1];
        eventEmailTemplate.HtmlValue = 'test';
        if(eventEmailTemplate == null)
            return;
        List<GS_EmailUtility.MergeFieldObject> lstMergeFieldObjs = GS_EmailUtility.getObjWithFieldsFromString(eventEmailTemplate.HtmlValue + eventEmailTemplate.Body + eventEmailTemplate.Subject);
        
        /* Adding Select fields to get Sales Rep (Primary & Secondary) */ 
        Set<String> selectFields = GS_EmailUtility.populateSOQLs(lstMergeFieldObjs,'CampaignMember');
        selectFields.add('contact.Account.Primary_Sales_Rep__c');
        selectFields.add('contact.Account.Primary_Sales_Rep__r.Id');
        selectFields.add('contact.Account.Primary_Sales_Rep__r.Name');
        selectFields.add('contact.Account.Secondary_Sales_Rep__c');
        selectFields.add('contact.Account.Secondary_Sales_Rep__r.Id');
        selectFields.add('contact.Account.Secondary_Sales_Rep__r.Name');
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        String soql = GS_EmailUtility.buildQuery(selectFields,'CampaignMember', 'Where id in : ids');
        for(CampaignMember campaignMember: Database.query(soql))
        {
            // Who you are sending the email to
            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
            ID recipient = null;
            String recipientName = null;            
            if(String.isNotBlank(campaignMember.contact.Account.Primary_Sales_Rep__c))
            {
                recipient = campaignMember.contact.Account.Primary_Sales_Rep__r.Id;
                recipientName = campaignMember.contact.Account.Primary_Sales_Rep__r.Name;
            }
            else if(String.isNotBlank(campaignMember.contact.Account.Secondary_Sales_Rep__c))
            {
                recipient = campaignMember.contact.Account.Secondary_Sales_Rep__r.Id;
                recipientName = campaignMember.contact.Account.Secondary_Sales_Rep__r.Name;
            }
            else continue;               
            
            for (GS_EmailUtility.MergeFieldObject tempMergeFieldObject : lstMergeFieldObjs) {
                for (GS_EmailUtility.ObjWithField tempObjField : tempMergeFieldObject.objWithFields) {
                    System.debug(tempObjField.fieldName);
                    tempObjField.fieldValue = '';
                    if(tempObjField.objectName == 'CampaignMember')
                    {
                        if(tempObjField.fieldName != 'Link'){
                            System.debug(campaignMember.get(tempObjField.fieldName));
                            tempObjField.fieldValue = String.valueOf(campaignMember.get(tempObjField.fieldName));
                        }    
                        if(tempObjField.fieldName == 'Link'){     
                            tempObjField.fieldValue = URL.getSalesforceBaseUrl().toExternalForm() + '/' +campaignMember.get('id');
                        }
                    }  
                    if(tempObjField.fieldName == 'Name' && tempObjField.objectName == 'User'){     
                        tempObjField.fieldValue =  recipientName;
                    }
                    if(tempObjField.objectName != 'CampaignMember'){
                        if(tempObjField.fieldName == 'Link'){
                            tempObjField.fieldValue = URL.getSalesforceBaseUrl().toExternalForm() + '/' +String.valueOf(campaignMember.getSObject(tempObjField.objectName).get('Id'));
                            continue;
                        }
                        if(campaignMember.getSObject(tempObjField.objectName) != null && campaignMember.getSObject(tempObjField.objectName).get(tempObjField.fieldName) != null)
                        {
                            tempObjField.fieldValue = String.valueOf(campaignMember.getSObject(tempObjField.objectName).get(tempObjField.fieldName));
                        }	
                        
                    }    
                }
            }
            mapMergeFieldObject.put(campaignMember.id,lstMergeFieldObjs);
            mapDealtEmailTemplate = GS_EmailUtility.replaceEmailTemplate(mapMergeFieldObject, eventEmailTemplate);
            System.debug(mapDealtEmailTemplate);
            String content = (mapDealtEmailTemplate.get(campaignMember.id)).get('Text');
            String Subject= (mapDealtEmailTemplate.get(campaignMember.id)).get('Subject');
            
            
            // The email template ID used for the email
            mail.setTemplateId(eventEmailTemplate.id);
            mail.setPlainTextBody(content);
            mail.setSubject(Subject);
            mail.setTargetObjectId(recipient);
            mail.setBccSender(false);
            mail.setSaveAsActivity(false);  
            
            mails.add(mail);
        }
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(mails);
    }
    
}