/**************************************************************************************************
 * Name           : GS_RecordTypeUtility
 * Object         : RecordType
 * Requirement    :
 * Target         : To invoke method on Recordtype
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-06-12
 **************************************************************************************************/
public class GS_RecordTypeUtility {

    // Get RecordType by recordTypeName and sObjectName
    public static RecordType getRecordType(String recordTypeName, String sObjectName) {
        RecordType rt = [SELECT Id
                                 , DeveloperName
                                 , SobjectType
                                 , IsActive
                                 FROM RecordType
                                 WHERE SobjectType = : sObjectName
                                 AND DeveloperName = : recordTypeName
                                 And IsActive = true];
        return rt;
    }

    // Get all Recordtypes by an object
    // Return Map<String, Id> Key is RecordType Name and Id is recordtype id
    public static Map<String, Id> getRecordTypeNamesWithId(String sObjectName) {

        Map<String, Id> mapRTNamesWithId = new Map<String, Id>();

        for(Recordtype rt : [SELECT Id
                                     ,Name
                                     ,DeveloperName
                                     ,SobjectType
                                     ,IsActive
                             FROM RecordType
                             WHERE SobjectType = : sObjectName
                             And IsActive = true]) {
            mapRTNamesWithId.put(rt.Name, rt.Id);
        }

        return mapRTNamesWithId;
    }
}