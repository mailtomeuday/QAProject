/**************************************************************************************************
 * Name           : GS_EDDDataCallOutUtility
 * Object         : 
 * Requirement    : 
 * Target         : Call data from EDD
 * Refer classes  :
 * Author         : Katherine Chen
 * Create Date    : 2016-04-06
 * Modify History :
 **************************************************************************************************/
public class GS_EDDDataCallOutUtility 
{
	public static HTTPResponse getResponseFromEDD(String username, String password, String endpoint) 
	{
		HttpRequest req = new HttpRequest();
		Http http = new Http();

		Blob headerValue = Blob.valueOf(username +':' +password);
		String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

		req.setMethod('GET');
		req.setEndpoint(endpoint);
		req.setHeader('Authorization', authorizationHeader);
		req.setTimeout(120000);

		HTTPResponse res = http.send(req);
		return res;
	}
}