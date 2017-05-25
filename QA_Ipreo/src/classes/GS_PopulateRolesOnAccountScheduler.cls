/*
    This class is used to schedule the GS_PopulateRolesOnAccountBatch class to run every 10 minutes. 
*/

global with sharing class GS_PopulateRolesOnAccountScheduler implements Schedulable
{
    Id jobid;
      
    global GS_PopulateRolesOnAccountScheduler(Id currentJobId)
    {
        jobid = currentJobId;
    }   
    
    global void execute(SchedulableContext SC)
    {   
        if(jobid == null || IsJobComplete())
        { 
            GS_PopulateRolesOnAccountBatch batch = new GS_PopulateRolesOnAccountBatch();
            jobid = database.executeBatch(batch, 2000);
            
            if(Test.isRunningTest())
            {
                IsJobComplete();
            }
        
        }
        
        Datetime sysTime = System.now().addMinutes(10);
        //Datetime lastRunTime = Datetime.now();    
        Datetime lastRunTime = null;    
        String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        String strJobName = 'Populate_RolesOn_Account_Job_' + DateTime.Now();
        
        GS_PopulateRolesOnAccountScheduler  objPopulateRolesOnAccountScheduler = new GS_PopulateRolesOnAccountScheduler(jobid);
        
        System.schedule(strJobName, chronExpression, objPopulateRolesOnAccountScheduler);
        
    }
    
    /* Checks whether previously scheduled batch Job has been completed */
    private boolean IsJobComplete()
    {
        for(AsyncApexJob job : [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: jobid])
        {
            if(job.status != 'Completed')
                return false;
        }                   
        
        return true;            
    }
    
    
}