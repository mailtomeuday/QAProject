/**************************************************************************************************
 * Name           : GS_MassUpdateCases
 * Objects        : Case
 * Requirement    : SPS-1103: Mass update cases
 * Target         : To provide an ability to perform mass update on cases.
 * Refer classes  : 
 * Author         : Joshi (ambadas_morkhandikar@epam.com)
 * Create Date    : 2017-04-03
 * Modify History :
 **************************************************************************************************/

public class GS_MassUpdateCases {

    ApexPages.StandardSetController setCon;
    
    public GS_MassUpdateCases(ApexPages.StandardSetController controller) {
        setCon = controller;
    }
    
    public integer getRecordsSize() {
        return setCon.getSelected().size();
    }
}