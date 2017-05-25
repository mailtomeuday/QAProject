/**************************************************************************************************
 * Name           : GS_ActivityUtil
 * Objects        : Event, Task
 * Requirement    :
 * Target         : Util class, contains methods common to Task and Event
 * Refer classes  : GS_TaskAssignValueTHandler, GS_EventAssignValueTHandler
 * Authors        : Uday Bikkumalla (uday_bikkumalla@epam.com), Joshi (ambadas_morkhandikar@epam.com)
 * Create Date    : 2017-03-17
 * Modify History : 28-Apr-17: Joshi added hotfix for SPS-1993 
 **************************************************************************************************/
 
public class GS_ActivityUtil 
{
	/*
		Purpose		: Get set of Products from semicolon seperated product names.
		Method		: getProductSetFromString	
		@Parameter  : [String - productsText]
		Return Type	: [Set<String> - Set of Products]
	*/
	public static Set<String> getProductSetFromString(String productsText)
	{
		system.debug('In GS_ActivityUtil.getProductSetFromString:: productsText ===>>>' + productsText);
		Set<String> products = new Set<String>();
		if(String.isNotBlank(productsText))
		{
        	products = new Set<String>(productsText.split(';'));
		}
		system.debug('In GS_ActivityUtil.getProductSetFromString:: products ===>>>' + products);
		return products;
	}	
	
	/*
		Purpose		: Get semicolon seperated product names from set of products.
		Method		: getProductStringFromSet	
		@Parameter  : [Set<String> products]
		Return Type	: [String - semicolon seperated product Names]
	*/
	public static String getProductStringFromSet(Set<String> products)
	{
		system.debug('In GS_ActivityUtil.getProductStringFromSet:: products ===>>>' + products);
		String productsText = '';
		if(products != null && !products.isEmpty())
		{
			for(string product : products){
        		productsText += product + ';';
			}
		}
		system.debug('In GS_ActivityUtil.getProductStringFromSet:: productsText ===>>>' + productsText);
		return productsText.length() > 1 ? productsText.left(productsText.length() - 1) : productsText;
	}
	
	/*
		Purpose		: Get Products based on Opportunity.
		Method		: getProductsTextForActivity	
		@Parameter 1: [SObject - Task/Event]
		@Parameter 2: [Opportunity - Opp object]
		@Parameter 3: [Set<String> - Set of Products for activity]
		Return Type	: [String - Products Text]
	*/
	public static String getProductsTextForActivity(SObject obj, Opportunity opp, Set<String> tskProducts)
	{
		String autoProductsText = (String)obj.get('Products__c');
		for(OpportunityLineItem oppLineItem : opp.OpportunityLineItems)
		{
			if(!tskProducts.contains(oppLineItem.product2.name))
			{
				if(String.isBlank(autoProductsText))
				{
					autoProductsText = oppLineItem.product2.name;
					continue;
				}
					autoProductsText =  autoProductsText + ';' + oppLineItem.product2.name;
			}
			System.debug('autoProductsText---->'+autoProductsText);
		}
		return autoProductsText;
	}
	
	/*
	Purpose		: Get Products based on Opportunity.
	Method		: getProductsTextForActivity	
	@Parameter 1: [SObject - Task/Event]
	@Parameter 2: [Case - CaseObj object]
	@Parameter 3: [Set<String> - Set of Products for activity]
	@Parameter 4: [Set<String> - Task/Event PickList values]
	Return Type	: [String - Products Text]
*/
	public static String getProductsTextForActivity(SObject obj, Case caseObj, Set<String> tskProducts, Set<String> activityPickListValues)
	{
		String autoProductsText = (String)obj.get('Products__c');
		String caseProductsText = (String)caseObj.get('Product__c');
		Set<String> caseProducts = getProductSetFromString(caseProductsText);
		for(String productName : caseProducts)
		{
			if(!tskProducts.contains(productName) && activityPickListValues.contains(productName))
			{
				if(String.isBlank(autoProductsText))
				{
					autoProductsText = productName;
					continue;
				}
					autoProductsText =  autoProductsText + ';' + productName;
			}
			System.debug('autoProductsText---->'+autoProductsText);
		}
		return autoProductsText;
	}	
	
	/*
		Purpose		: Get Products picklist value on activity(Task/Event)
		Method		: setActivityProducts	
		@Parameter 1: [List<Sobject> - lstActivities]
		Return Type	: [Void]
	*/
	public static void setActivityProducts(List<Sobject> lstActivities)
	{
		Set<Id> oppIds = new Set<Id>();
		Set<Id> caseIds = new Set<Id>();
		Set<String> activityPickListValues = new Set<String>();
		Schema.DescribeSObjectResult dsr = Schema.getGlobalDescribe().get('Task').getDescribe();
		Schema.DescribeFieldResult dfr = dsr.fields.getMap().get('Products__c').getDescribe();
		for(Schema.PicklistEntry pe : dfr.getPicklistValues()) 
		{
			activityPickListValues.add(pe.getLabel());
		}
		for(Sobject obj : lstActivities) 
		{  
			if(String.isNotBlank((String)obj.get('whatId')) && (((String)obj.get('whatId__c')) == '006' || ((String)obj.get('whatId__c')) == '500'))
			{
				if(((String)obj.get('whatId__c')) == '006')
				{
					oppIds.add((ID)obj.get('whatId'));
				}
				if(((String)obj.get('whatId__c')) == '500')
				{
					caseIds.add((ID)obj.get('whatId'));
				}	
			}
		}
		Map<Id, Opportunity> mapOpp = new Map<Id,Opportunity>(GS_OpportunityDMLHandler.getOpportunitiesWithLineItemsById(oppIds));
		Map<Id, Case> mapCases = new Map<Id,Case>(GS_CaseDMLHandler.getCasesByIds(caseIds));
		for(Sobject activityObj : lstActivities)
		{
			Opportunity opp = mapOpp.get((ID)activityObj.get('whatId'));
			Case caseObj = mapCases.get((ID)activityObj.get('whatId'));
			
			/*Get the Products selected on Products. Applicable only on Update*/
			Set<String> evtProducts = getProductSetFromString((String)activityObj.get('Products__c'));
			if(activityObj == null || (opp == null && caseObj == null))
			{
				continue;
			}			
			String productsText = '';
			if(((String)activityObj.get('whatId__c')) == '006')
			{
				productsText = getProductsTextForActivity(activityObj, opp, evtProducts);				
			}
			if(((String)activityObj.get('whatId__c')) == '500')
			{
				productsText = getProductsTextForActivity(activityObj, caseObj, evtProducts, activityPickListValues);				
			}
			if(Trigger.isInsert && String.isBlank((String)activityObj.get('Products__c')))
			{
				activityObj.put('Products__c', productsText);
			}
			if(Trigger.isUpdate	&&	String.isBlank((String)activityObj.get('Products__c')))
			{
				activityObj.put('Products__c', productsText);
			}
		}
	} 
	
	/*
		Purpose		: Set Product Interest records based on list of activity(Task/Event)
		Method		: setProductInterest	
		@Parameter 1: [List<Sobject> - listNewActivity]
		Return Type	: [list<Product_Interest__c>]
	*/	
	public static list<Product_Interest__c> setProductInterest(list<sObject> listNewActivity){
		map<Id, sObject> mapActivity = new map<Id, sObject>();
		list<Product_Interest__c> ProdInterestList = new list<Product_Interest__c>();
		set<Product_Interest__c> ProdInterestSet = new set<Product_Interest__c>();
		string strAllActivityProducts = '';
		
		if(listNewActivity != null && listNewActivity.size() > 0){
			for(sObject newActivity : listNewActivity){
				if(newActivity.get('whoId__c') == '003'){
					mapActivity.put((Id)newActivity.get('Id'), newActivity);
				}
			}
		}
		
		system.debug('mapActivity=========='+mapActivity);
		set<Id> setContactId = new set<Id>();
		
		for(Id ActivityId : mapActivity.keySet()){
			sObject objActivity = mapActivity.get(ActivityId);
			setContactId.add((Id)objActivity.get('whoId'));
			if(objActivity.get('Products__c') != null){
				strAllActivityProducts = strAllActivityProducts + ';' + objActivity.get('Products__c');
			}			
		}
		
		map<Id, Product2>  ActivityMapIDProduct = getProductsMapFromActivity(strAllActivityProducts);
		
		if(ActivityMapIDProduct == null || ActivityMapIDProduct.isEmpty()){
			return null;
		}
		
		list<contact> lstContact = [select id, (select id, Comments__c, Product__r.Name, Level_of_Interest__c,
													Contact__c, Date_First_Expressed__c,Date_Most_Recently_Expressed__c 
														from Product_Interest__r) from Contact 
															where Id in: setContactId];	
		
		map<Id, map<string, Product_Interest__c>> mapOfMapProdNameInterest = new map<Id, map<string, Product_Interest__c>>();	
		
		for(contact con : lstContact){
			map<string, Product_Interest__c> tempMap = mapOfMapProdNameInterest.get(con.Id);
			if(tempMap == null){
				tempMap = new map<string, Product_Interest__c>();
			}
			for(Product_Interest__c prodInterest : con.Product_Interest__r){
				tempMap.put(prodInterest.Product__r.Name, prodInterest);
			}
			
			mapOfMapProdNameInterest.put(con.Id, tempMap);
		}													
																													
		for(Id ActivityId : mapActivity.keyset()){
			System.debug('--->'+ActivityId);
			sObject objActivity = mapActivity.get(ActivityId);
			System.debug('--->'+objActivity);
			map<string, Product_Interest__c> mapProductNameInterest = mapOfMapProdNameInterest.get((Id)objActivity.get('whoId'));
			
			ActivityMapIDProduct = getProductsMapFromActivity((string)objActivity.get('Products__c')); 
			
			if(ActivityMapIDProduct == null || ActivityMapIDProduct.isEmpty()){
				continue;
			}
			
			for(Product2 ActivityProduct : ActivityMapIDProduct.values()){
				Product_Interest__c tempObj = mapProductNameInterest.get(ActivityProduct.Name);
				if(tempObj != null){
					tempObj.Date_Most_Recently_Expressed__c = date.today();
					ProdInterestSet.add(tempObj);
				}
				else{
					tempObj = new Product_Interest__c();
					tempObj.Product__c = ActivityProduct.Id;
					tempObj.Contact__c = (Id)objActivity.get('whoId');
					tempObj.Level_of_Interest__c = 'Medium';
					tempObj.Date_First_Expressed__c = date.today();
					tempObj.Date_Most_Recently_Expressed__c = date.today();
					ProdInterestSet.add(tempObj);
				}
			}
		}
		
		ProdInterestList.addAll(ProdInterestSet);
		return ProdInterestList;
	}
	
	/*
		Purpose		: Get map of ProductId to Product record based on on ';'  
					  seperated input string of Product Names
		Method		: getProductsMapFromActivity	
		@Parameter 1: [String - productsText]
		Return Type	: [map<Id, Product2>]
	*/
	private static map<Id, Product2> getProductsMapFromActivity(String productsText){
		map<Id, Product2> mapIdProduct;
		if(!String.isEmpty(productsText)){
			mapIdProduct = new map<Id, Product2> ();
			Set<String> products = new Set<String>();
			if(String.isNotBlank(productsText)){
				products = new Set<String>(productsText.split(';'));
			}
			mapIdProduct = new map<Id, Product2> ([select id, Name from Product2 where Name in: products]);
		}
		return mapIdProduct;
	}
    
    /*
		Purpose		: Get map of ProductName to Product record (to get product vertical) based on productId Set
		Method		: getMapProductNameVertical	
		@Parameter 1: [set<Id> productIdSet]
		Return Type	: [map<Id, Product2>]
	*/
    public static map<Id, product2> getMapProductNameVertical(set<Id> productIdSet){
    	system.debug('In GS_ActivityUtil.getMapProductNameVertical:: productIdSet ===>>>' + productIdSet);
    	map<Id, product2> mapProductNameVertical;
    	if(productIdSet != null && !productIdSet.isEmpty()){
    		mapProductNameVertical = new map<Id, product2>();
	    	list<product2> lstProduct = [select Id, Name, Vertical__c from Product2 where Id in: productIdSet];
	    	for(Product2 product : lstProduct){
	    		mapProductNameVertical.put(product.Id, product);
	    	}
    	}
    	system.debug('In GS_ActivityUtil.getMapProductNameVertical:: mapProductNameVertical ===>>>' + mapProductNameVertical);
    	return mapProductNameVertical;
    }
}