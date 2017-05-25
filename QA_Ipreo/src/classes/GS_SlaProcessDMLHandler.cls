/**************************************************************************************************
 * Name           : GS_SlaProcessDMLHandler
 * Object         : SlaProcess
 * Requirement    : 
 * Target         : DML on SlaProcess
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-07-23
 * Modify History :
 **************************************************************************************************/
public class GS_SlaProcessDMLHandler {
    
    // Get SlaProcess by Name
    public static Slaprocess getSlaprocessByName (String processName) {
    	List<SlaProcess> lstProcesses = new List<SlaProcess>();
    	lstProcesses = [SELECT Id
    						  ,NameNorm
    						  ,Description
    						  ,IsActive
    						  ,BusinessHoursId
    						  ,Name
    					FROM Slaprocess
    					WHERE Name =: processName
                        AND IsVersionDefault = TRUE
                        AND IsActive = TRUE
                        limit 1];
    	if(!lstProcesses.isEmpty()) {
    		return lstProcesses[0];
    	} else{
    		return new SlaProcess();
    	}
    }

    // Get standard Slaprocess ----- Standard OLA
    public static Slaprocess getStandardSLA() {
    	return getSlaprocessByName(GS_GlobalVariables.STANDARDOLA);
    }
}