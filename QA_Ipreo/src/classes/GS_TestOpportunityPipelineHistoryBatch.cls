@isTest(SeeAllData=true)
private class GS_TestOpportunityPipelineHistoryBatch {

    static testMethod void OpportunityPipelineHistorySchedule() {
        GS_OpportunityPipelineHistoryBatch m = new GS_OpportunityPipelineHistoryBatch();
    	
    	Test.startTest();
		String sch = '0 30 11 * * ?';
		String jobID = system.schedule('Opportunity Pipeline History Test', sch, m);
		System.debug(jobID);
		Test.stopTest();
    }
    
}