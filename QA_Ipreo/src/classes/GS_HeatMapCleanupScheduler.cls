global class GS_HeatMapCleanupScheduler implements Schedulable
{
	global void execute(SchedulableContext SC) 
	{
		GS_HeatmapCleanupBatch batch = new GS_HeatmapCleanupBatch();
		database.executeBatch(batch);
	}
}