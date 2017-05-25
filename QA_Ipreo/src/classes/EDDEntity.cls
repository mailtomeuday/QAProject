/**************************************************************************************************
 * Name           : EDDEntity
 * Object         : 
 * Requirement    : 
 * Target         : 
 * Refer classes  :
 * Author         : Katherine Chen
 * Create Date    : 2016-04-05
 * Modify History :
 **************************************************************************************************/
global class EDDEntity
{
	global class EDDEntityStruct 
    {
		private String Company2_count;
		private List<Company> Company2;
		public List<EDDLead> 	Leads;
		private String Leads_count;
	}

	global class EDDUpdateLeads
	{
		public List<EDDDeal> Deal;
		public String Deal_count;
	}

	global class EDDDeal 
	{
		public Integer issue_id;
		public String issue_nm;
		public String amended_file_dt;
		public String init_file_dt;
		public String withdrawn_postponed_dt;
		public String price_dt;
		public String expected_dt_report;
		public String announcement_dt;
		public String deal_status_desc;
		public String status_dt;
		public String bookrunners_parentCode;
		public String allmanagers_parentCode;
	}

	global class Company
	{
		String investor_name;
		String country;
		String province;
		String region;
		String city;
		String institution_sub_type;
		String investor_id;
		String institution_type; 
	}

	global class EDDLead
	{
		public Integer warehouse_id;
		public String issuer_nm;
		public String symbol;
		public String exchange_nm;
		public String industry_macro_nm;
		public String industry_mid_nm;
		public String industry_nm;
		public String street_nm;
		public String street_nm3;
		public String province_nm;
		public String zip_cd;
		public String country_nm;
		public String phone_no;
		public String url;
		public String deal_status_desc;
		public String expected_dt;
		public Integer issue_id;
		public String status_dt;
		public String init_file_dt;
		public String amended_file_dt;
		public String Deal_bookrunners_parentCode;
		public String Deal_allmanagers_parentCode;
	}

	global class errorMassage
	{
		public Integer 	warehouse_id;
		public String 	lastName;
		public String 	errorMass;
	}
}