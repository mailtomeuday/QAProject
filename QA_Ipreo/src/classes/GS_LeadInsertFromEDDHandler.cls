/**************************************************************************************************
 * Name           : GS_LeadInsertFromEDDHandler
 * Object         : Lead
 * Requirement    : 
 * Target         : Insert data which are got from EDD into Lead
 * Refer classes  :
 * Author         : Katherine Chen
 * Create Date    : 2016-04-05
 * Modify History :
 **************************************************************************************************/
public class GS_LeadInsertFromEDDHandler {

	public List<EDDEntity.errorMassage> insertLeadsData(list<EDDEntity.EDDLead> EDDEntityobj)
	{
		List<lead> getNewLeadList = new List<lead>();
		List<EDDEntity.errorMassage> errorMassageList = new List<EDDEntity.errorMassage>();
		Integer total = 0;
		Integer shoudInsertCount = 0;
		Integer convertSuccCount = 0;
		Integer insertErrorCount = 0;

		for(EDDEntity.EDDLead le : EDDEntityobj)
		{
			total ++;
			Lead newlead = new Lead();
			if(le.warehouse_id != null && String.valueOf(le.warehouse_id) !='0' )
			{
				List<lead> getExistLead = new List<lead>();
				getExistLead = [select Id , Name from Lead where Ipreo_BDSF_1_10__BDCompanyId__c = :(Decimal)le.warehouse_id];
				if(getExistLead.size() == 0)
				{
					shoudInsertCount ++;
					try
					{
						if (le.street_nm == null) le.street_nm = '';
						if (le.street_nm3 == null) le.street_nm3 = '';
						
						newlead.Ipreo_BDSF_1_10__BDCompanyId__c = (Decimal)le.warehouse_id;
						newlead.LastName = le.issuer_nm;
						newlead.Ticker__c = le.symbol;
						newlead.Exchange__c = le.exchange_nm;
						newlead.Industry = le.industry_macro_nm;
						newlead.Mid_Industry__c = le.industry_mid_nm;
						newlead.Micro_Industry__c = le.industry_nm;
						newlead.Street = le.street_nm + ' ' + le.street_nm3;
						newlead.State = le.province_nm;
						newlead.PostalCode = le.zip_cd;
						newlead.Country = le.country_nm;
						newlead.Phone = le.phone_no;
						newlead.Website = le.url;
						newlead.Deal_Status__c = le.deal_status_desc;
						newlead.Estimated_IPO_Date__c = le.expected_dt == null ? null: GS_LeadsUpdateFromEDDHandler.getDateFromJSON(le.expected_dt);
						newlead.Company = le.issuer_nm;
						newlead.CurrencyIsoCode = 'USD';
						newlead.Status = 'New';
						newlead.Issue_Id__c = (Decimal)le.issue_id;
						newlead.Status_Date__c = le.status_dt == null ? null: GS_LeadsUpdateFromEDDHandler.getDateFromJSON(le.status_dt);
						newlead.LeadSource = 'EDD';
						newlead.Amended_File_Date__c = le.amended_file_dt == null ? null: GS_LeadsUpdateFromEDDHandler.getDateFromJSON(le.amended_file_dt);
						newlead.Initial_File_Date__c = le.init_file_dt == null ? null: GS_LeadsUpdateFromEDDHandler.getDateFromJSON(le.init_file_dt);
						newlead.Bookrunners__c = le.Deal_bookrunners_parentCode;
						newlead.All_Managers__c = le.Deal_allmanagers_parentCode;
						newlead.Vertical__c = 'Corporate';

						getNewLeadList.add(newlead);
						convertSuccCount ++;
					}catch(Exception de)
					{
						EDDEntity.errorMassage em = new EDDEntity.errorMassage();
						em.warehouse_id = le.warehouse_id;
						em.lastName = le.issuer_nm;
						em.errorMass = de.getMessage();
						errorMassageList.add(em);
					}finally
					{
						continue;
					}
				}else
				{
					continue;
				}
			}else
			{
				EDDEntity.errorMassage em = new EDDEntity.errorMassage();
				em.warehouse_id = le.warehouse_id;
				em.lastName = le.issuer_nm;
				em.errorMass = 'Field warehouse_id is null.';
				errorMassageList.add(em);
			}
		}
			
		Database.Saveresult[] saveResult;
		saveResult = Database.insert(getNewLeadList, false);
		for(Integer i = 0; i<getNewLeadList.size(); i++)
		{
			Database.SaveResult s = saveResult[i];
			if(!s.isSuccess())
			{
				insertErrorCount ++;
				EDDEntity.errorMassage em = new EDDEntity.errorMassage();
				em.warehouse_id = Integer.valueOf(getNewLeadList[i].Ipreo_BDSF_1_10__BDCompanyId__c );
				em.lastName = getNewLeadList[i].LastName;
				em.errorMass = String.valueOf(s.getErrors()[0]);
				errorMassageList.add(em);
			}
			
		}

		System.debug('*** Total Count: ' + total );
		System.debug('*** Count of need to be inserted: ' + shoudInsertCount );
		System.debug('*** Count of converted successfully: ' + convertSuccCount );
		System.debug('*** Count of inserted successfully: ' + (convertSuccCount-insertErrorCount) );
		System.debug('*** errorMassageList: ' + errorMassageList );

		return errorMassageList;
	}
}