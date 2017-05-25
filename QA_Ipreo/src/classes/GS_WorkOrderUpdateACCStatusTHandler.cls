/**************************************************************************************************
 * Name           : GS_WorkOrderUpdateACCStatusTHandler
 * Object         : Work_Order__c/Account
 * Requirement    : STY-00012
 * Target         : When Work Order status is changed, sum the count of active Work Orders of the account.
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-06-01
 * Modify History : STY-380
 *                 Notify Account team on Work Order closure
 **************************************************************************************************/
public class GS_WorkOrderUpdateACCStatusTHandler implements GS_Triggers.Handler {
    public void handle() {

        List<Account> listOriginAccount;
        List<Id> listAccountIds;
        List<Account> listTargetAccount;

        listOriginAccount = new List<Account>();
        listAccountIds = new List<Id>();
        listTargetAccount = new List<Account>();

        List<Account> accountSet = new List<Account>();
        Set<Id> woIdsSet = new Set<Id>();
        if(Trigger.isupdate) {
            System.debug(LoggingLevel.INFO, '*** GS_WorkOrderUpdateACCStatusTHandler is executed. Action is update ');
            for (Id tempWOId : Trigger.newMap.keySet()) {
                Work_Order__c wo = (Work_Order__c)Trigger.newMap.get(tempWOId);
                Work_Order__c oldWO = (Work_Order__c)Trigger.oldMap.get(tempWOId);
                if (wo.Active__c != oldWO.Active__c || wo.Account__c != oldWO.Account__c) {
                    listAccountIds.add(((Work_Order__c)Trigger.newMap.get(tempWOId)).Account__c);
                    if(wo.Account__c != oldWO.Account__c)
                        listAccountIds.add(((Work_Order__c)Trigger.oldMap.get(tempWOId)).Account__c);
                }
                if(wo.Status__c != oldWO.Status__c && wo.Status__c.containsIgnoreCase('Closed') && wo.Account__c != null) {
                    woIdsSet.add(wo.Id);
                }
            }
            //Add by terry 2015-12-02, update copy order information to account
            for(Work_Order__c wo : [Select Id, Opportunity__r.Name, Sales_Rep__r.Email From Work_Order__c Where Id In: woIdsSet]) {
                Work_Order__c tmpWO = (Work_Order__c)Trigger.newMap.get(wo.Id);
                String TrackingNumber = String.valueOf(Math.random());
                if(TrackingNumber.length() > 20) {
                    TrackingNumber = TrackingNumber.substring(0, 20);
                }else {
                    TrackingNumber = TrackingNumber.substring(0, TrackingNumber.length());
                }
                Account a = new Account(
                    Id = tmpWO.Account__c, 
                    Tracking_Number__c = TrackingNumber,
                    Work_Order_Detail_Link__c = URL.getSalesforceBaseUrl().toExternalForm() + '/' + wo.Id,
                    Work_Order_Name__c = tmpWO.Name,
                    Work_Order_Number__c = tmpWO.Work_Order_Number__c,
                    Work_Order_Status__c = tmpWO.Status__c,
                    Opportunity_Name__c = wo.Opportunity__r.Name,
                    Sales_Rep_Email__c = wo.Sales_Rep__r.Email
                );
                accountSet.add(a);
            }
        } else if(Trigger.isInsert || Trigger.isUndelete) {
            System.debug(LoggingLevel.INFO, '*** GS_WorkOrderUpdateACCStatusTHandler is executed. Action is isInsert or undelete ');
            for (Id tempWOId : Trigger.newMap.keySet()) {
                listAccountIds.add(((Work_Order__c)Trigger.newMap.get(tempWOId)).Account__c);
            }
        } else if( Trigger.isDelete) {
            System.debug(LoggingLevel.INFO, '*** GS_WorkOrderUpdateACCStatusTHandler is executed. Action is isUndelete or isDelete ');
            for (Id tempWOId : Trigger.oldMap.keySet()) {
                listAccountIds.add(((Work_Order__c)Trigger.oldMap.get(tempWOId)).Account__c);
            }
        }

        if (listAccountIds.size() > 0) {
            //listOriginAccount = GS_AccountDMLHandler.getWorkOrdersWithAccount(listAccountIds);
            //map<Id, String> accountIdProdBundleMap = GS_CommonUtility.getAccountProductBundle(listAccountIds);
            listOriginAccount = GS_AccountDMLHandler.getAssetsWorkOrdersByAccount(listAccountIds);
            map<Id, String> accountIdProdBundleMap = GS_CommonUtility.getAccountProductBundle(listAccountIds, listOriginAccount);
            Integer activeWONumber = 0;
            for (Account tempAccount : listOriginAccount) {
                System.debug(LoggingLevel.INFO, '*** tempAccount: ' + tempAccount);
                System.debug(LoggingLevel.INFO, '*** tempAccount.Work_Orders__r.size(): ' + tempAccount.Work_Orders__r.size());
                for(Work_Order__c tempWO : tempAccount.Work_Orders__r) {
                    if(tempWO.Active__c == true) {
                        activeWONumber ++ ;
                    }
                }
                listTargetAccount.add(new Account(Id = tempAccount.Id, No_of_Active_Work_Orders__c = activeWONumber, No_of_All_Work_Orders__c = tempAccount.Work_Orders__r.size(), Product_Bundle__c = accountIdProdBundleMap.get(tempAccount.Id)));
                activeWONumber = 0;
            }

            Update listTargetAccount;
        }
        if(accountSet.size() > 0) update accountSet;
    }
    
}