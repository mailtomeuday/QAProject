/**************************************************************************************************
 * Name           : GS_MileStoneDMLHandler
 * Object         : MileStone
 * Requirement    : 
 * Target         : DML on Asset
 * Refer classes  :
 * Author         : Xiao Yang (yang.xiao@cnsdc01.pwc.com)
 * Create Date    : 2015-07-06
 * Modify History :
 **************************************************************************************************/
public class GS_MileStoneDMLHandler {
    
    // Get CaseMileStone records by its name and case id
    public static List<CaseMileStone> getCaseMileStoneByNameAndCaseId(Set<Id> stCaseId, List<String> mileStoneNames) {
    	return [SELECT  Id
    				   ,IsViolated
					   ,TargetResponseInMins
					   ,BusinessHoursId
					   ,TargetDate
					   ,ElapsedTimeInHrs
					   ,TargetResponseInDays
					   ,IsCompleted
					   ,TargetResponseInHrs
					   ,CompletionDate
					   ,ElapsedTimeInMins
					   ,CaseId
					   ,Case.IsClosed
					   ,StartDate
					   ,MilestoneTypeId
					   ,ElapsedTimeInDays
					   ,TimeSinceTargetInMins
					   ,MilestoneType.Name
    			FROM CaseMileStone
    			WHERE CaseId =: stCaseId
    			AND MilestoneType.Name =: mileStoneNames
    			AND IsCompleted = false];
    }

    // Assign completion time to case milestones to complete them
    public static List<Database.SaveResult> closeFstResponse (List<CaseMileStone> resolvedCaseMileStones) {

        List<CaseMileStone> lstTargetCaseMileStone = new List<CaseMileStone>();

        for(CaseMileStone tempMileStone : resolvedCaseMileStones) {
            if(!tempMileStone.Case.IsClosed){
                tempMileStone.CompletionDate = Datetime.now();
                lstTargetCaseMileStone.add(tempMileStone);
            }
        }

        return Database.update(lstTargetCaseMileStone);
    }



    // Satisfy the ownership case milestone currently
    public static List<Database.SaveResult> satisfyMilestone (List<CaseMileStone> resolvedCaseMileStones) {

        List<CaseMileStone> lstTargetCaseMileStone = new List<CaseMileStone>();

        for(CaseMileStone tempMileStone : resolvedCaseMileStones) {
            if(!tempMileStone.Case.IsClosed){
                tempMileStone.CompletionDate = Datetime.now();
                lstTargetCaseMileStone.add(tempMileStone);
            }
        }

        return Database.update(lstTargetCaseMileStone);
    }

    // Reset Case milestone start date
    public static List<Database.SaveResult> setStartDate (List<CaseMileStone> resolvedCaseMileStones) {

        List<CaseMileStone> lstTargetCaseMileStone = new List<CaseMileStone>();

        for(CaseMileStone tempMileStone : resolvedCaseMileStones) {
            if(!tempMileStone.Case.IsClosed){
                tempMileStone.StartDate = Datetime.now();
                lstTargetCaseMileStone.add(tempMileStone);
            }
        }
        return Database.update(lstTargetCaseMileStone);
    }
}