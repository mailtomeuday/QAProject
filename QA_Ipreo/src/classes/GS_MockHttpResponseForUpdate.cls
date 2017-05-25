/**************************************************************************************************
 * Name           : GS_MockHttpResponseForUpdate
 * Object         : 
 * Requirement    : 
 * Target         : TestClass 
 * Refer classes  :
 * Author         : Katherine Chen
 * Create Date    : 2016-04-12
 * Modify History :
 **************************************************************************************************/
@isTest
global class GS_MockHttpResponseForUpdate implements HttpCalloutMock
{
    global HTTPResponse respond(HTTPRequest req) {
	    // Optionally, only send a mock response for a specific endpoint
	    // and method.
	    System.debug('***  Request Endpoint: '+req.getEndpoint());
	    System.assertEquals('https://davos.app.ipreo.com/public/rest/api/internal/salesforce/UpdateLeadsV2.svc/?$format=json&IssueId=[1111123,1111124,1111125,1111126]', req.getEndpoint());
	    System.assertEquals('GET', req.getMethod());
	    
	    // Create a fake response
	    HttpResponse res = new HttpResponse();
	    res.setHeader('Content-Type', 'application/json');
	    res.setBody('{"Deal":[{"amended_file_dt":"/Date(1451451600000-0500)/","announcement_dt":null,"deal_status_desc":"Postponed","expected_dt_report":"/Date(1451451600000-0500)/","init_file_dt":"/Date(1406865600000-0400)/","issue_id":1111123,"issue_nm":"Thyrocare Technologies Limited","price_dt":null,"withdrawn_postponed_dt":"/Date(1454648400000-0500)/"},{"amended_file_dt":"/Date(1439352000000-0400)/","announcement_dt":null,"deal_status_desc":"Filed","expected_dt_report":null,"init_file_dt":"/Date(1411099200000-0400)/","issue_id":1111124,"issue_nm":"Exagen Diagnostics, Inc.","price_dt":null,"withdrawn_postponed_dt":null},{"amended_file_dt":"/Date(1450069200000-0500)/","announcement_dt":null,"deal_status_desc":"OthersAAAAAAAAAAAAAAAAAAAA","expected_dt_report":null,"init_file_dt":"/Date(1412136000000-0400)/","issue_id":1111125,"issue_nm":"Sutherland Asset Management Corp.","price_dt":null,"withdrawn_postponed_dt":"/Date(1421298000000-0500)/"},{"amended_file_dt":"/Date(1440648000000-0400)/","announcement_dt":null,"deal_status_desc":"Filed","expected_dt_report":null,"init_file_dt":"/Date(1414123200000-0400)/","issue_id":1111126,"issue_nm":"CEBA Midstream, LP","price_dt":null,"withdrawn_postponed_dt":null}],"Deal_count":null}');
	    res.setStatusCode(200);
	    return res;
    }
}