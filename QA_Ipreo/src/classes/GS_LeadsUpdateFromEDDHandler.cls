/**************************************************************************************************
 * Name           : GS_LeadsGetAll
 * Object         : Lead
 * Requirement    : 
 * Target         : 
 * Refer classes  : Get all Leads data
 * Author         : Katherine Chen
 * Create Date    : 2016-04-11
 * Modify History : 
 **************************************************************************************************/
public class GS_LeadsUpdateFromEDDHandler {
	public List<Lead> getAllLeads()
	{
		List<Lead> lstLead = [select Name, Ipreo_BDSF_1_10__BDCompanyId__c,Issue_id__c, 
								LastName,Ticker__c,Deal_Status__c,Estimated_IPO_Date__c
							  from Lead 
							  where Issue_id__c != null];

		System.debug('*** Lead Count-->' + lstLead.size()); 
		return lstLead;
	}
 
	public List<EDDEntity.errorMassage> updateLeads(List<Lead> lstLead)
	{
		System.debug('*** GS_LeadsUpdateFromEDDHandler.updateLeads begin.');
		String endpoint = 'https://davos.app.ipreo.com/public/rest/api/internal/salesforce/UpdateLeadsV2.svc/?$format=json&IssueId=';
		String lstIssueId = '';
		List<Lead> lstUpdateLeads = new List<Lead>();
		List<Account> lstUpdateAccs = new List<Account>();
		Set<Id> setUpdateLeadIds = new Set<Id>();
		List<EDDEntity.errorMassage> errorMassageList = new List<EDDEntity.errorMassage>();
		Integer shouldUpdateCount = 0;
		Integer updateSuccCount = 0;
		Integer errorCount = 0;
		Integer updateErrorCount = 0;

		if(lstLead.size() > 0)
		{
			// The webservice can only deal with max 50 records per callout
			Integer j = lstLead.size() > 50 ? 50 : lstLead.size();
			for (Integer i = 0; i < j; i++)
			{
				if(lstLead[i].Issue_id__c != null)
				{
					lstIssueId += lstLead[i].Issue_id__c + ',';
				}
			}
			lstIssueId = lstIssueId.removeEnd(',');
			endpoint = endpoint + '[' + lstIssueId + ']';
			System.debug('*** Update Endpoint: ' + endpoint);

			if(lstIssueId == '')
			{
				return errorMassageList;
			}

			HTTPResponse res = GS_EDDDataCallOutUtility.getResponseFromEDD('salesforce@ipreo','Fourier2016',endpoint);
			EDDEntity.EDDUpdateLeads EDDEntityobj =(EDDEntity.EDDUpdateLeads)JSON.deserialize(res.getBody(),EDDEntity.EDDUpdateLeads.class); 

			for(EDDEntity.EDDDeal d : EDDEntityobj.Deal)
			{
				System.debug('d.issue_id:' + d.issue_id);
				shouldUpdateCount ++ ;
				try
				{
					List<Lead> updatelead = [select LastName,Amended_File_Date__c,Initial_File_Date__c,Withdrawn_Postponed_Date__c,Price_Date__c,Estimated_IPO_Date__c,Announcement_Date__c,Deal_Status__c,Ipreo_BDSF_1_10__BDCompanyId__c,Issue_id__c, Ticker__c, ConvertedAccountId, ConvertedAccount.Name, ConvertedAccount.Expected_Date__c, ConvertedAccount.Vertical__c, ConvertedAccount.TickerSymbol from Lead where Issue_id__c = : d.issue_id];
					
					if(updatelead.size() >0) {
						if (updatelead[0].ConvertedAccountId == null) {
							updatelead[0].LastName = d.issue_nm;
							updatelead[0].Amended_File_Date__c = d.amended_file_dt == null ? null: getDateFromJSON(d.amended_file_dt);
							updatelead[0].Initial_File_Date__c = d.init_file_dt == null ? null: getDateFromJSON(d.init_file_dt);
							updatelead[0].Withdrawn_Postponed_Date__c = d.withdrawn_postponed_dt == null ? null: getDateFromJSON(d.withdrawn_postponed_dt);
							updatelead[0].Price_Date__c = d.price_dt == null ? null: getDateFromJSON(d.price_dt);
							updatelead[0].Estimated_IPO_Date__c = d.expected_dt_report == null ? null: getDateFromJSON(d.expected_dt_report);
							updatelead[0].Announcement_Date__c = d.announcement_dt == null ? null: getDateFromJSON(d.announcement_dt);
							updatelead[0].Deal_Status__c = d.deal_status_desc;
							updatelead[0].Status_Date__c = d.status_dt == null ? null: getDateFromJSON(d.status_dt);
							updatelead[0].Bookrunners__c = d.bookrunners_parentCode;
							updatelead[0].All_Managers__c = d.allmanagers_parentCode;
						
							//Let's check if the list already contains this Lead.  The service is returning multiple records for at least one Issue Id as of 2016-05-04.
							if (!setUpdateLeadIds.contains(updatelead[0].Id)) {
								setUpdateLeadIds.add(updatelead[0].Id);
								lstUpdateLeads.add(updatelead[0]);
								updateSuccCount ++;
							}
						}
						else {
							updatelead[0].ConvertedAccount.Deal_Status__c = d.deal_status_desc;
							updatelead[0].ConvertedAccount.Status_Date__c = d.status_dt == null ? null: getDateFromJSON(d.status_dt);
							updatelead[0].ConvertedAccount.Expected_Date__c = d.expected_dt_report == null ? null: getDateFromJSON(d.expected_dt_report);
							updatelead[0].ConvertedAccount.Price_Date__c = d.price_dt == null ? null: getDateFromJSON(d.price_dt);
							updatelead[0].ConvertedAccount.Initial_File_Date__c = d.init_file_dt == null ? null: getDateFromJSON(d.init_file_dt);
							updatelead[0].ConvertedAccount.Withdrawn_Postponed_Date__c = d.withdrawn_postponed_dt == null ? null: getDateFromJSON(d.withdrawn_postponed_dt);
							updatelead[0].ConvertedAccount.Bookrunners__c = d.bookrunners_parentCode;
							updatelead[0].ConvertedAccount.All_Managers__c = d.allmanagers_parentCode;
							
							if (updatelead[0].ConvertedAccount.Vertical__c == null)
								updatelead[0].ConvertedAccount.Vertical__c = 'Corporate';
								
							if (updatelead[0].ConvertedAccount.TickerSymbol == null && updatelead[0].Ticker__c != null)
								updatelead[0].ConvertedAccount.TickerSymbol = updatelead[0].Ticker__c;
							
							lstUpdateAccs.add(updatelead[0].ConvertedAccount);
						}
					}
				}catch(Exception de)
				{
					errorCount ++;
					EDDEntity.errorMassage em = new EDDEntity.errorMassage();
					em.warehouse_id = d.issue_id;
					em.lastName = d.issue_nm;
					em.errorMass = de.getMessage();
					errorMassageList.add(em);
				}finally
				{
					continue;
				}
			}

			Database.UpsertResult[] updateResult;
			Database.SaveResult[] saveResultAccs;
			
			try
			{
				updateResult = Database.upsert(lstUpdateLeads, Lead.Issue_id__c, false);
			}catch(Exception de)
			{
				errorCount ++;
				EDDEntity.errorMassage em = new EDDEntity.errorMassage();
				em.warehouse_id = null;
				em.lastName = 'Endpoint: ' + endpoint;
				em.errorMass = de.getMessage();
				errorMassageList.add(em)
				;
				return errorMassageList;
			}

			for(Integer i = 0; i<lstUpdateLeads.size(); i++)
			{
				Database.UpsertResult s = updateResult[i];
				if(!s.isSuccess())
				{
					errorCount ++ ;
					updateErrorCount ++;
					EDDEntity.errorMassage em = new EDDEntity.errorMassage();
					em.warehouse_id = Integer.valueOf(lstUpdateLeads[i].Issue_id__c );
					em.lastName = lstUpdateLeads[i].LastName;
					em.errorMass = String.valueOf(s.getErrors()[0]);
					errorMassageList.add(em);
				}	
			} 
			
			saveResultAccs = Database.update(lstUpdateAccs, false);
		}

		System.debug('*** Count of should be updated: ' + shouldUpdateCount );
		System.debug('*** Count of error: ' + errorCount );
		System.debug('*** Count of updated successfully: ' + (updateSuccCount-updateErrorCount) );

		String temp = '';
		temp += 'Leads Update From EDD';
		temp += 'Equity Deals Database';

		return errorMassageList;       
	}

	public static Date getDateFromJSON(String dJson)
	{
		System.debug('****  ' + dJson);
		/*if(dJson.contains('(') && dJson.contains(')') && dJson.contains('-'))
		{
			String longtime = dJson.substringBetween('(', '-');
			String timeZone = dJson.substringBetween('-', ')');

			Long lTime = Long.valueOf(longtime) + Integer.valueOf(timeZone) * 60 * 60 * 1000;
			DateTime dt = DateTime.newInstance(lTime);

			return dt.dateGmt();
		}*/
		if(dJson.contains('(') && dJson.contains(')'))
		{
			String longtime = dJson.contains('-') ? dJson.substringBetween('(', '-') : dJson.substringBetween('(', ')');
			
			Long lTime = Long.valueOf(longtime);
			DateTime dt = DateTime.newInstance(lTime);

			return dt.dateGmt();
		}
		else
		{
			return null;
		}
	}

}