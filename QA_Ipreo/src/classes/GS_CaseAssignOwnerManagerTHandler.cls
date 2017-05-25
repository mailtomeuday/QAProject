/**************************************************************************************************
 * Name           : GS_CaseAssignOwnerManagerTHandler
 * Object         : Case
 * Requirement    : 
 * Target         : Assign owner's manager to the case, then we can email the manager for the sla process by workflow
 * Refer classes  :
 * Author         : Matthew
 * Create Date    : 2016/3/30
 * Modify History :
 **************************************************************************************************/
public class GS_CaseAssignOwnerManagerTHandler implements GS_Triggers.Handler {
    public void handle(){
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
            Set<Id> setCaseOwner = new Set<Id>();
            Map<Id, Id> mapCaseMgr = new Map<Id, Id>();
            for(Case c : (List<Case>)Trigger.New){
                //If case owner is user
                if(String.valueOf(c.OwnerId).indexOf('005') == 0){
                    if(!setCaseOwner.contains(c.OwnerId)){
                        setCaseOwner.add(c.OwnerId);
                    }
                }
            }
            
            if(setCaseOwner.size() >0){
                List<User> userList = [SELECT Id, ManagerId FROM User WHERE Id IN :setCaseOwner];
                for(User usr : userList){
                    mapCaseMgr.put(usr.Id, usr.ManagerId);
                }
            }
            
            if(mapCaseMgr.keySet().size() > 0){
                for(Case c: (List<Case>)Trigger.New){
                    if(mapCaseMgr.get(c.OwnerId) != null){
                        c.Case_Owner_Manager__c = mapCaseMgr.get(c.OwnerId);
                    }
                }
            }
            
        }
    }
    
}