/**************************************************************************************************
 * Name           : GS_MockHttpResponseGenerator
 * Object         : 
 * Requirement    : 
 * Target         : TestClass 
 * Refer classes  :
 * Author         : Katherine Chen
 * Create Date    : 2016-04-06
 * Modify History :
 **************************************************************************************************/
@isTest
global class GS_MockHttpResponseGenerator implements HttpCalloutMock
{
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
	    // Optionally, only send a mock response for a specific endpoint
	    // and method.
	    System.assertEquals('https://davos.app.ipreo.com/public/rest/api/Internal/Salesforce/CurrentLeads.svc/?$format=json', req.getEndpoint());
	    System.assertEquals('GET', req.getMethod());
	    
	    // Create a fake response
	    HttpResponse res = new HttpResponse();
	    res.setHeader('Content-Type', 'application/json');
	    res.setBody('{"Company2":[{"city":"Shanghai","country":"India","institution_sub_type":null,"institution_type":"Corporate","investor_id":"000001","investor_name":"Cochin Minerals and Rutile Limited","province":"Shanghai","region":"Asia"}],"Company2_count":1,"Leads":[{"country_nm":"India","deal_status_desc":"Filed","exchange_nm":"Bombay Stock Exchange","expected_dt":null,"industry_macro_nm":"Industrials","industry_mid_nm":"Materials and Construction","industry_nm":"Heavy Construction","issue_id":"000011","issuer_nm":"Cochin Shipyard Ltd.","phone_no":"91-484-237-0897","province_nm":null,"status_dt":"04/04/2016","street_nm":null,"street_nm3":null,"symbol":"*COCSH.IN","url":"http://cochinshipyard.com","warehouse_id":100001,"zip_cd":"210012"},{"country_nm":"India","deal_status_desc":"Filed","exchange_nm":"Bombay Stock Exchange","expected_dt":null,"industry_macro_nm":"Industrials","industry_mid_nm":"Materials and Construction","industry_nm":"Heavy Construction","issue_id":"000012","issuer_nm":"Cochin Shipyard Ltd.","phone_no":"91-484-237-0897","province_nm":null,"status_dt":"04/04/2016","street_nm":null,"street_nm3":null,"symbol":"*COCSH.IN","url":"http://cochinshipyard.com","warehouse_id":100002,"zip_cd":"210012"},{"country_nm":"China","deal_status_desc":"Filed","exchange_nm":"Hong Kong Stock Exchange","expected_dt":null,"industry_macro_nm":"Healthcare","industry_mid_nm":"Biotechnology and Pharmaceuticals","industry_nm":"Pharmaceuticals","issue_id":"154324","issuer_nm":"WuXi PharmaTech (Cayman) Inc.","phone_no":"86-21-5046-1111","province_nm":null,"status_dt":"10/04/2016","street_nm":"288 Fute Zhong Rd.","street_nm3":null,"symbol":"*WUXPH.HK","url":"www.pharmatechs.com","warehouse_id":0,"zip_cd":"200131"},{"country_nm":"China","deal_status_desc":"Filed","exchange_nm":"Hong Kong Stock Exchange","expected_dt":"w/k of 10/04/2016","industry_macro_nm":"Basic Materials","industry_mid_nm":"Metals and Mining","industry_nm":"Other Non-Ferrous Metals","issue_id":"154827","issuer_nm":"China Kingstone Mining Holdings Limited","phone_no":"+86-862-38336127","province_nm":null,"status_dt":"10/04/2016","street_nm":"288 Shicheng Road","street_nm3":"Sichuan Province","symbol":"1380.HK","url":"www.kingstonemining.com","warehouse_id":1000123,"zip_cd":null},{"country_nm":"South Korea","deal_status_desc":"Expected","exchange_nm":"Korea Stock Exchange","expected_dt":"10/04/2016","industry_macro_nm":"Consumer Goods","industry_mid_nm":"Food, Beverage, and Tobacco","industry_nm":"Processed and Packaged Foods","issue_id":"41469","issuer_nm":"Haitai Confectionery & Foods Co., Ltd.","phone_no":"82-2-709-7766","province_nm":null,"status_dt":"10/04/2016","street_nm":"3, Hangang-daero 72-gil, Yongsan-gu","street_nm3":null,"symbol":"101530.KS","url":"www.ht.co.kr","warehouse_id":1010231,"zip_cd":"10101129"}],"Leads_count":5}');
	    res.setStatusCode(200);
	    return res;
    }
}