/**************************************************************************************************
 * Name           : GS_LeadGetDataFromEDD
 * Object         : Lead
 * Requirement    : 
 * Target         : Get new Lead data from EDD
 * Refer classes  :
 * Author         : Katherine Chen
 * Create Date    : 2016-04-05
 * Modify History :
 **************************************************************************************************/
public class GS_LeadGetDataFromEDD {

    public EDDEntity.EDDEntityStruct getCreateLeadsData()     
    {
		HTTPResponse res = GS_EDDDataCallOutUtility.getResponseFromEDD('salesforce@ipreo','Fourier2016','https://davos.app.ipreo.com/public/rest/api/Internal/Salesforce/CurrentLeadsV2.svc/?$format=json');         
		EDDEntity.EDDEntityStruct EDDEntityobj =(EDDEntity.EDDEntityStruct)JSON.deserialize(res.getBody(),EDDEntity.EDDEntityStruct.class);         
		return EDDEntityobj;     
	} 
}