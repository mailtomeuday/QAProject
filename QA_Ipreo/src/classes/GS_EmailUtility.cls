/**************************************************************************************************
 * Name           : GS_EmailUtility
 * Object         :
 * Requirement    : STY-00095
 * Target         : A utility class to send emails
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-08-18
 * Modify History :
 **************************************************************************************************/
public class GS_EmailUtility {
    public static List<Messaging.SendEmailResult> Send(List<String> lstToAddresses, String subject, String plainTextBody, String htmlBody) {
        System.debug(LoggingLevel.INFO, '*** lstToAddresses: ' + lstToAddresses);
        if (!lstToAddresses.isEmpty()) {
            List<Messaging.SingleEmailMessage> lstMsg = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            msg.setToAddresses(lstToAddresses);
            msg.setSubject(subject);
            msg.setPlainTextBody(plainTextBody);
            msg.setHtmlBody(htmlBody);
            msg.setSaveAsActivity(false);
            lstMsg.add(msg);
            List<Messaging.SendEmailResult> results =
                Messaging.sendEmail(lstMsg);
            System.debug(LoggingLevel.INFO, '*** results: ' + results);
            return results;
        } else {
            return new List<Messaging.SendEmailResult>();
        }
    }
	
	public static List<Messaging.SendEmailResult> Send(List<String> lstToAddresses, String subject, String plainTextBody, String htmlBody, Messaging.EmailFileAttachment exlAttc){
        System.debug(LoggingLevel.INFO, '*** lstToAddresses: ' + lstToAddresses);
        if (!lstToAddresses.isEmpty()) {
            List<Messaging.SingleEmailMessage> lstMsg = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            msg.setToAddresses(lstToAddresses);
            msg.setSubject(subject);
            msg.setPlainTextBody(plainTextBody);
            msg.setHtmlBody(htmlBody);
            msg.setSaveAsActivity(false);
            msg.setFileAttachments(new Messaging.EmailFileAttachment[]{exlAttc});
            lstMsg.add(msg);
            List<Messaging.SendEmailResult> results =
                Messaging.sendEmail(lstMsg);
            System.debug(LoggingLevel.INFO, '*** results: ' + results);
            return results;
        } else {
            return new List<Messaging.SendEmailResult>();
        }
    } 
	
    public static List<Messaging.SendEmailResult> Send(Id systemUserId, String subject, String plainTextBody) {
        System.debug(LoggingLevel.INFO, '*** systemUserId: ' + systemUserId);
        if (systemUserId != NULL) {
            List<Messaging.SingleEmailMessage> lstMsg = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            msg.setTargetObjectId(systemUserId);
            msg.setSubject(subject);
            msg.setPlainTextBody(plainTextBody);
            msg.setSaveAsActivity(false);
            lstMsg.add(msg);
            List<Messaging.SendEmailResult> results =
                Messaging.sendEmail(lstMsg);
            System.debug(LoggingLevel.INFO, '*** results: ' + results);
            return results;
        } else {
            return new List<Messaging.SendEmailResult>();
        }
    }

    // Populate SOQL by mergefield from email template
    // Populate SOQL and return objec name with SOQL. But the SOQL is without where Clause
    public static Map<String, String> populateSOQLs(List<GS_EmailUtility.MergeFieldObject> lstMergeFieldObject, Id whatId, Id activityId, Id whoId, Id accountId) {

        Map<String, String> mapSoql = new Map<String, String>();

        for (GS_EmailUtility.MergeFieldObject tempMergeFieldObject : lstMergeFieldObject) {
            String tempSOQL = '';
            String strSelects = '';

            for (GS_EmailUtility.ObjWithField tempField : tempMergeFieldObject.objWithFields) {

                strSelects += tempField.fieldName + ',';
            }

            if (strSelects.endsWith(',')) {
                strSelects = strSelects.substring(0, strSelects.lastIndexOf(','));
            }

            tempSOQL = 'SELECT ' + strSelects + ' FROM ' + tempMergeFieldObject.objectName;

            if (tempMergeFieldObject.objectName != 'Account' && tempMergeFieldObject.objectName != 'Task' && tempMergeFieldObject.objectName != 'Event' && tempMergeFieldObject.objectName != 'Contact' && tempMergeFieldObject.objectName != 'Lead') {
                if( whatId != null){
                    tempSOQL += ' WHERE Id = ' + '\'' + whatId + '\'';
                } else {
                    tempSOQL = '';
                }
            } else if (tempMergeFieldObject.objectName == 'Task' || tempMergeFieldObject.objectName == 'Event') {
                if( activityId != null){
                    tempSOQL += ' WHERE Id = ' + '\'' + activityId + '\'';
                } else {
                    tempSOQL = '';
                }
            }else if (tempMergeFieldObject.objectName == 'Account') {
                if( accountId != null){
                    tempSOQL += ' WHERE Id = ' + '\'' + accountId + '\'';
                } else {
                    tempSOQL = '';
                }
            }else if (tempMergeFieldObject.objectName == 'Contact' || tempMergeFieldObject.objectName == 'Lead') {
                if( whoId != null){
                    tempSOQL += ' WHERE Id = ' + '\'' + whoId + '\'';
                } else {
                    tempSOQL = '';
                }
            }
            if(tempSOQL != ''){
                mapSoql.put(tempMergeFieldObject.objectName, tempSOQL);
            }
            System.debug(LoggingLevel.INFO, '*** mapSoql: ' + mapSoql);
        }
        return mapSoql;
    }
    
        // Populate SOQL by mergefield from email template
    // Populate SOQL and return objec name with SOQL. But the SOQL is without where Clause
    public static Set<String> populateSOQLs(List<GS_EmailUtility.MergeFieldObject> lstMergeFieldObject, String FromObject) {

		String tempSOQL = '';
		
		Set<String> selectList = new Set<String>();
        for (GS_EmailUtility.MergeFieldObject tempMergeFieldObject : lstMergeFieldObject) {
            for (GS_EmailUtility.ObjWithField tempField : tempMergeFieldObject.objWithFields) {
            	
            	String strSelects = '';
				if(tempMergeFieldObject.objectName == FromObject)
				{
					strSelects = tempField.fieldName;
				}
				else
				{
            		strSelects = tempMergeFieldObject.objectName + '.' + tempField.fieldName;
				}
				/* Link is not field on Object, So replacing with Id to avoid query exception*/
				strSelects = strSelects.replace('Link','Id');
				selectList.add(strSelects);
            }
        }
        /*if (strSelects.endsWith(',')) {
                strSelects = strSelects.substring(0, strSelects.lastIndexOf(','));
            }
        tempSOQL = 'SELECT ' + strSelects + ' FROM ' + FromObject + ' '+WhereClause;
        System.debug(LoggingLevel.INFO, '*** tempSOQL: ' + tempSOQL);*/
        return selectList;
    }
	
	public static String buildQuery(Set<String> selectList, String FromObject, String WhereClause){
		String tempSOQL = '';
		String strSelects = '';
   		for(String str : selectList) {
				strSelects += str + ',';
		}
		if (strSelects.endsWith(',')) {
                strSelects = strSelects.substring(0, strSelects.lastIndexOf(','));
            }
        tempSOQL = 'SELECT ' + strSelects + ' FROM ' + FromObject + ' '+WhereClause;
        System.debug(LoggingLevel.INFO, '*** tempSOQL: ' + tempSOQL);
        return tempSOQL;
	}    


    // return map, map's key is task or event id
    public static Map<Id, Map<String, String>> replaceEmailTemplate(Map<Id, List<GS_EmailUtility.MergeFieldObject>> mapMergeFieldObject, EmailTemplate emailHtmlTemplate) {

        // Key is task or event id
        Map<Id, Map<String, String>> mapHtmlTemplateWithId = new Map<Id, Map<String, String>>();

        for (Id tempId : mapMergeFieldObject.keySet()) {
            String populatedHtmlTemplate = emailHtmlTemplate.HtmlValue.remove('<![CDATA[').remove(']]>');
            String populatedTextTemplate = emailHtmlTemplate.Body;
            String populatedSubject = emailHtmlTemplate.Subject;

            // two kinds of template, html and plain text.
            Map<String, String> mapDealtEmailTemplate = new Map<String, String>();
            for (GS_EmailUtility.MergeFieldObject tempObj : mapMergeFieldObject.get(tempId)) {
                for (GS_EmailUtility.ObjWithField tempField : tempObj.objWithFields) {
                    String strMergeField = '';
                    strMergeField = '{!' + tempField.objectName + '.' + tempField.mergeFieldName + '}';
                    if (strMergeField != NULL && tempField.fieldValue != NULL) {
                        populatedTextTemplate = populatedTextTemplate.replace(strMergeField, tempField.fieldValue);
                        populatedSubject = populatedSubject.replace(strMergeField, tempField.fieldValue);
                    }
                }
            }

            // Replace unicode with html
            for (GS_EmailUtility.MergeFieldObject tempObj : mapMergeFieldObject.get(tempId)) {
                for (GS_EmailUtility.ObjWithField tempObjField : tempObj.objWithFields) {
                    String strMergeField = '';
                    strMergeField = '{!' + tempObjField.objectName + '.' + tempObjField.mergeFieldName + '}';
                    //prototype
                    if (tempObjField.fieldValue.escapeUnicode().contains('\\r\\n') || tempObjField.fieldValue.escapeUnicode().contains('\\n') ) {
                        tempObjField.fieldValue = tempObjField.fieldValue.escapeUnicode().replace('\\r\\n', '<br>').replace('\\n', '<br>');
                        tempObjField.fieldValue = tempObjField.fieldValue.unescapeUnicode();
                    }

                    if (strMergeField != NULL && tempObjField.fieldValue != NULL) {
                        populatedHtmlTemplate = populatedHtmlTemplate.replace(strMergeField, tempObjField.fieldValue);
                    }
                }
            }

            mapDealtEmailTemplate.put('Html', populatedHtmlTemplate);
            mapDealtEmailTemplate.put('Text', populatedTextTemplate);
            mapDealtEmailTemplate.put('Subject', populatedSubject);
            mapHtmlTemplateWithId.put(tempId, mapDealtEmailTemplate);
        }

        System.debug(LoggingLevel.INFO, '*** mapHtmlTemplateWithId: ' + mapHtmlTemplateWithId);

        return mapHtmlTemplateWithId;
    }

	public static void sendEmailOnError(string header, String failureReasons, String subject, String plainTextBody, String htmlBody, string attachFileName, list<string> toAddresses){
		Messaging.EmailFileAttachment exlAttc;
	    if(String.isNotEmpty(failureReasons))
	    {
	    	failureReasons = header + failureReasons+'</table>';
	        exlAttc = new Messaging.EmailFileAttachment();
	        blob exlBlob = Blob.valueOf(failureReasons);
	        string exlname = attachFileName;
	        exlAttc.setFileName(exlname);
	        exlAttc.setBody(exlBlob);
	    }
        
    	if(toAddresses == null || toAddresses.size() == 0){
    		toAddresses.add('salesforce_support@ipreo.com');
    	}  
    	
    	send(toAddresses, subject, plainTextBody, htmlBody, exlAttc);
	}
	
    public static List<GS_EmailUtility.MergeFieldObject> getObjWithFieldsFromString (String emailContent) {

        Map<String, GS_EmailUtility.ObjWithField> mapFields = new Map<String, GS_EmailUtility.ObjWithField>();
        // Key is object name.
        Map<String, GS_EmailUtility.MergeFieldObject> mapMergeFieldObject = new Map<String, GS_EmailUtility.MergeFieldObject>();

        // Regex pattern, get all object.field from email template.
        Pattern patGetField = Pattern.compile('\\{!([a-zA-Z\\d\\._]*)?\\}');

        Matcher matEmailHtmlBody = patGetField.matcher(emailContent);
        while (matEmailHtmlBody.find()) {
            if (matEmailHtmlBody.group(1).Contains('.')) {

                // No relationship field can be merged in email template, so it should be two strings.
                // The if is used to avoid exception list out of bound.
                if (matEmailHtmlBody.group(1).Split('\\.').size() == 2) {
                    String strObjectName = '';
                    String strFieldName = '';
                    String strMergeFieldName = '';
                    GS_EmailUtility.ObjWithField tempObjField;
                    GS_EmailUtility.MergeFieldObject tempMergeFieldObject;

                    strObjectName = matEmailHtmlBody.group(1).Split('\\.')[0];
                    strFieldName = matEmailHtmlBody.group(1).Split('\\.')[1];
                    strMergeFieldName = matEmailHtmlBody.group(1).Split('\\.')[1];

                    if (GS_CommonUtility.getNameFieldByRelationMergeField(strObjectName, strFieldName) != '') {
                        strFieldName = GS_CommonUtility.getNameFieldByRelationMergeField(strObjectName, strFieldName);
                    }

                    tempObjField = new GS_EmailUtility.ObjWithField(strObjectName, strFieldName, strMergeFieldName);

                    tempMergeFieldObject = new GS_EmailUtility.MergeFieldObject();
                    tempMergeFieldObject.objWithFields = new List<GS_EmailUtility.ObjWithField>();

                    if (!mapFields.containsKey(tempObjField.key)) {
                        mapFields.put(tempObjField.key, tempObjField);
                        if (!mapMergeFieldObject.containsKey(strObjectName)) {
                            tempMergeFieldObject.objectName = tempObjField.ObjectName;
                            tempMergeFieldObject.objWithFields.add(tempObjField);
                            mapMergeFieldObject.put(strObjectName, tempMergeFieldObject);
                        } else {
                            mapMergeFieldObject.get(strObjectName).objWithFields.add(tempObjField);
                        }
                    }
                }
            }
        }

        return mapMergeFieldObject.values();
    }

    // All object's merge fields of a template.
    public class MergeFieldObject {
        public String objectName;
        public List<ObjWithField> objWithFields;
    }

    // One object's merge fields of a template.
    public class ObjWithField {

        public String key;
        public String objectName;
        public String fieldName;
        public String mergeFieldName;
        public String fieldValue;

        public ObjWithField(String inputObjectName, String inputFieldName, String inputMergeFieldName) {
            this.objectName = inputObjectName;
            this.fieldName = inputFieldName;
            this.mergeFieldName = inputMergeFieldName;
            this.key = inputObjectName + '_' + inputFieldName;
        }
    }
}