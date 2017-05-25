/**************************************************************************************************
 * Name           : GS_PermissionSetQueueController
 * Object         : PermissionSetAssignment,GroupMember
 * Requirement    : SPS-915
 * Target         : To generate the Permission set assignments and Queue members
 * Refer classes  :
 * Author         : Uday Kumar (uday_bikkumalla@epam.com)
 * Create Date    : 2016-06-09
 * Modify History :
 **************************************************************************************************/

public with sharing class GS_PermissionSetQueueController {

	public String report='PermissionSet';
	public String getReport() {
        return report;
    }
 			
    public void setReport(String report) {
        this.report = report;
    }
 	public List<PermissionSetAssignment> psa{get; set;}
 	public List<GroupMember> grpMembers{get; set;}
 	public List<QueueMemberWrapper> queueMembers{get; set;}
 	public Set<Id> setUserIds = new Set<Id>();
 	Map<Id, User> mapUser = new Map<Id, User>();
    public GS_PermissionSetQueueController()
    {
    psa = new List<PermissionSetAssignment>();
       for (PermissionSetAssignment u : [SELECT Assignee.FirstName,Assignee.LastName,Assignee.Name,Assignee.UserRole.name,Assignee.IsActive, PermissionSet.Label
	FROM PermissionSetAssignment WHERE PermissionSet.IsOwnedByProfile = false and Assignee.IsActive=true ORDER BY AssigneeId, PermissionSetId])
       {       
           psa.add(u);
       }
    }
    /* get the queue members and get User details corresponding to memmbers */
    public pagereference getQueueMembers(){
    	grpMembers = new List<GroupMember>();
    	queueMembers = new List<QueueMemberWrapper>();
    	User tempUser;
    	try{
	    	for (GroupMember u : [SELECT GroupId,Group.Name,Group.Type, UserOrGroupId FROM GroupMember where Group.Type='Queue' ORDER BY UserOrGroupId, GroupId])
	       {       
	           setUserIds.add(u.UserOrGroupId);
	           grpMembers.add(u);
	       }
			if(setUserIds.size() > 0) {
					mapUser = new Map<Id, User>(GS_UserDMLHandler.getUsersByIds(setUserIds));
				}
			for(GroupMember gm: grpMembers){
				System.debug(mapUser.get(gm.UserOrGroupId));
				tempUser = mapUser.get(gm.UserOrGroupId);
				if(tempUser.isActive){
					queueMembers.add(new QueueMemberWrapper(tempUser, gm));
				}	
			}
    	}
    	catch(Exception ex){
    		throw ex;
    	}	   	       
       	return null;
    }
    /* Export the results based on the select options */
	public pagereference exportToExcel(){	
		PageReference pf;
		try{
			if(report == 'PermissionSet'){	
				pf = new PageReference('/apex/GS_PermissionSetReport');
				pf.setRedirect(false);
			}
			if(report == 'QueueMember'){	
				pf = new PageReference('/apex/GS_QueueMembersReport');
				pf.setRedirect(false);			
			}
		}
		catch(Exception ex){
			throw ex;
		}						
		return pf;			
	}

	public class QueueMemberWrapper{
		public User u{get;set;}
		public GroupMember groupMember{get;set;}
		public QueueMemberWrapper(User us, GroupMember gpm){
			this.u=us;
			this.groupMember=gpm;
		}
	}
}