/**************************************************************************************************
 * Name           : GS_ProductInterestUpdateContactTHandler
 * Objects        : Product Interest(Product_Interest__c)
 * Requirement    :
 * Target         : Update Contact product information fields with unique product interest products
 * Refer classes  : 
 * Author         : Joshi (ambadas_morkhandikar@epam.com)
 * Create Date    : 2017-03-17
 * Modify History :
 **************************************************************************************************/
 
public class GS_ProductInterestUpdateContactTHandler implements GS_Triggers.Handler
{
    private map<Id, list<Product_Interest__c>> mapContactIDProdInt = new map<Id, list<Product_Interest__c>>();
    set<Id> producIdSet = new set<Id>();
    	
    public void handle() {
    	
    	if (Trigger.isInsert || Trigger.isUpdate) {
    		Map<Id, Product_Interest__c> mapNewProdInterest = (Map<Id, Product_Interest__c>)Trigger.newMap;
    		
    		for(Id prodIntId : mapNewProdInterest.keyset()){
    			Product_Interest__c objProdInt = mapNewProdInterest.get(prodIntId);
    			producIdSet.add(objProdInt.Product__c);
    			Id contactId = objProdInt.Contact__c;
    			list<Product_Interest__c> lstTempProdInt = mapContactIDProdInt.get(contactId);
    			
    			if(lstTempProdInt == null){
    				lstTempProdInt = new list<Product_Interest__c>();
    			}
    			
				lstTempProdInt.add(objProdInt);
    			
    			mapContactIDProdInt.put(contactId, lstTempProdInt);
			}
			
			system.debug('In handle::mapContactIDProdInt ===>>>' + mapContactIDProdInt);
    		updateContactProducInfo();
    	}
    	
    }
    
    private void updateContactProducInfo(){
    	
		if(mapContactIDProdInt.size() > 0){
			list<Contact> contactListUpdate = new list<Contact>();
			list<Contact> contactList = GS_ContactDmlHandler.getContactsByConIds(mapContactIDProdInt.keyset());
			map<Id, product2> mapProductNameVertical = GS_ActivityUtil.getMapProductNameVertical(producIdSet);
			set<string> setGMGProds;
			set<string> setCorpProds;
			set<string> setPCSProds;
			
			for(Contact objContact : contactList){
				
				setGMGProds = new set<string>();
			 	setCorpProds= new set<string>();
				setPCSProds = new set<string>();
			
				if(!String.isEmpty(objContact.GMG_Activity_Products__c)){
					setGMGProds = GS_ActivityUtil.getProductSetFromString(objContact.GMG_Activity_Products__c);
				}	
				
				if(!String.isEmpty(objContact.Corporate_Activity_Products__c)){
					setCorpProds = GS_ActivityUtil.getProductSetFromString(objContact.Corporate_Activity_Products__c);
				}			
				
				if(!String.isEmpty(objContact.PCS_Activity_Products__c)){
					setPCSProds = GS_ActivityUtil.getProductSetFromString(objContact.PCS_Activity_Products__c);
				}
				
				for(Product_Interest__c objProdInt : mapContactIDProdInt.get(objContact.Id)){
					system.debug('In updateContactProducInfo::Vertical ===>>>' + mapProductNameVertical.get(objProdInt.Product__c).Vertical__c);
					if(mapProductNameVertical.get(objProdInt.Product__c).Vertical__c == 'GMG'){
						setGMGProds.add(mapProductNameVertical.get(objProdInt.Product__c).Name);
					}
					else if(mapProductNameVertical.get(objProdInt.Product__c).Vertical__c == 'Corporate'){
						setCorpProds.add(mapProductNameVertical.get(objProdInt.Product__c).Name);
					}
					else if(mapProductNameVertical.get(objProdInt.Product__c).Vertical__c == 'PCS'){
						setPCSProds.add(mapProductNameVertical.get(objProdInt.Product__c).Name);
					}
				}
				
				system.debug('In updateContactProducInfo::setGMGProds ===>>>' + setGMGProds);
				system.debug('In updateContactProducInfo::setCorpProds ===>>>' + setCorpProds);
				system.debug('In updateContactProducInfo::setPCSProds ===>>>' + setPCSProds);
				
				if(!setGMGProds.isEmpty())
					objContact.GMG_Activity_Products__c = GS_ActivityUtil.getProductStringFromSet(setGMGProds);
				if(!setCorpProds.isEmpty())
					objContact.Corporate_Activity_Products__c = GS_ActivityUtil.getProductStringFromSet(setCorpProds);
				if(!setPCSProds.isEmpty())
					objContact.PCS_Activity_Products__c = GS_ActivityUtil.getProductStringFromSet(setPCSProds);
				
				system.debug('In updateContactProducInfo::objContact ===>>>' + objContact);
							
				contactListUpdate.add(objContact);
			}				
			
			try{
				system.debug('In updateContactProducInfo::contactListUpdate ===>>>' + contactListUpdate);
				if(contactListUpdate.size() > 0){
					database.update(contactListUpdate);
				}
			}
			catch(Exception ex){
				//throw ex;
				processException(ex);
			}				 	
		}
    }
    
    public void processException(Exception ex){
        String errorMessage = '';
        if(ex.getTypeName() == 'System.DmlException'){
            Set<String> errorMessages = new Set<String>();
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                errorMessages.add(ex.getDmlMessage(i));
            }               
            Integer i = 0;          
            for(String message: errorMessages){
                    errorMessage += message+(i == errorMessages.size()-1 ? '' : '<br/>');
                    i = i+1;
            }
        }
        else{
            errorMessage = 'Internal System Error.';    
        }
        if(!Test.isRunningTest()){
	        for(ID recId : Trigger.newMap.keySet()){
        		Product_Interest__c objProdInterest = (Product_Interest__c)Trigger.newMap.get(recId);
                objProdInterest.addError('Errors while saving related records: '+errorMessage+'<br/>Please contact your System administrator.<br/>',false);
            }   
        }
    }
    
}