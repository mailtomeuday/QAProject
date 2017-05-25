/**************************************************************************************************
 * Name           : GS_CustomSettingDMLHandler
 * Object         : Custom Settings
 * Requirement    : 
 * Target         : DML on Custom Settings
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-09-24
 * Modify History :
 **************************************************************************************************/
public with sharing class GS_CustomSettingDMLHandler {
    
    // Get Alert Groups by names
    public static List<Alert_Groups__c> getAlertGroupsByNames(Set<String> groupNames) {
        return [SELECT Group_Email__c
                      ,Group_Name__c
                FROM Alert_Groups__c
                WHERE Group_Name__c =: groupNames];
    }
    
    public static List<Products_For_Corporate_Heat_Map__c> getProductsForHeatMap()
    {
        return Products_For_Corporate_Heat_Map__c.getAll().values();
    }
    
    public static User_List_Data_Update_Notifications__c getCustomSetting(string settingName)
    {
        User_List_Data_Update_Notifications__c notifSetting = User_List_Data_Update_Notifications__c.getValues(settingName);
        
        return notifSetting;
    }
    
    public static Heat_Map_Cleanup_Duration_Criteria__c getHeatMapCustomSetting(string settingName)
    {
        Heat_Map_Cleanup_Duration_Criteria__c heatMapSetting = Heat_Map_Cleanup_Duration_Criteria__c.getValues(settingName);
        system.debug('heatMapSetting---->>'+heatMapSetting);
        return heatMapSetting;
    }
}