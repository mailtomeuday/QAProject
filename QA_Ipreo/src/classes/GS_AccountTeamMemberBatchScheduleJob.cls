/**************************************************************************************************
 * Name           : GS_AccountTeamMemberBatchScheduleJob
 * Object         : AccountTeamMember
 * Requirement    : RQ-266
 * Target         : Trigger to add Account coverage members to automatically follow an Account record, but not for users with a Sales Profile.
 * Refer classes  : 
 * Author         : Terry Nong
 * Create Date    : 2015-11-23
 * Modify History :
 **************************************************************************************************/
global class GS_AccountTeamMemberBatchScheduleJob implements Schedulable {

    global void execute(SchedulableContext sc) {
        String query = ' Select Id, UserId, AccountId From AccountTeamMember Where User.Profile.Name != \'Sales User\'';
        GS_AccountTeamMemberBatchJob batchJob = new GS_AccountTeamMemberBatchJob(query);
        Database.executeBatch(batchJob, Integer.valueOf(System.Label.Batch_Size));
    }
}