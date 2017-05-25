global class GS_UpdateYearDependentOppFieldsScheduler implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        //call the batch class to be scheduled
        GS_UpdateYearDependentOppFieldsBatch batch = new GS_UpdateYearDependentOppFieldsBatch();
       
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(batch, 200);
    }

}