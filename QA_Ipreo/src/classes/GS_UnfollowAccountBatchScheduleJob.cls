/**************************************************************************************************
 * Name           : GS_UnfollowAccountBatchScheduleJob
 * Object         : Account
 * Requirement    : RQ-265
 * Target         : Unfollow Account when a member was removed from account team, but not for users with a Sales Profile.
 * Refer classes  : 
 * Author         : Terry Nong
 * Create Date    : 2015-12-02
 * Modify History :
 **************************************************************************************************/
global class GS_UnfollowAccountBatchScheduleJob implements Schedulable {

    global void execute(SchedulableContext sc) {
        String query  = ' Select Id, Name, (Select AccountId, UserId From AccountTeamMembers) From Account ' ;
        GS_UnfollowAccountBatchJob batchJob = new GS_UnfollowAccountBatchJob(query);
        Database.executeBatch(batchJob, Integer.valueOf(System.Label.Batch_Size));
    }
}