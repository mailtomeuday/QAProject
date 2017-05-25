global with sharing class GS_MergeHeatMapScheduler implements Schedulable
{
	private set<ID> setOfJobIds;
	private string schJobName;
	private string region;
	private integer numFiles;
	private string selectedRoles;
	private list<string> lstProducts;
	private integer marketCap;
	
	global GS_MergeHeatMapScheduler(set<ID> jobIdSet, string jobName, string selectedRegion, integer numFilesGen, string strRolesSelected, list<string> lstProductNames, integer marketCapVal)
	{
		setOfJobIds = jobIdSet;
		schJobName = jobName;
		region = selectedRegion;
		numFiles = numFilesGen;
		selectedRoles = strRolesSelected;
		lstProducts = lstProductNames;
		marketCap = marketCapVal;
	}
	
	global void execute(SchedulableContext SC) 
	{
		Folder heatMapFolder = [select Id from Folder where Name = 'Heat Map Reports'];
        list<Document> lstAtt = [Select Id,FolderId, Name,body,ContentType From Document where FolderId =:heatMapFolder.Id and CreatedById =: UserInfo.getUserId() and Name like:'HEAT_MAP_PARTIAL_FILE_%'];
        
        system.debug('lstAtt.size() ==== '+ lstAtt.size());
        system.debug('numFiles ==== '+ numFiles);
		if(allJobsCompleted() && lstAtt.size() == numFiles)
		{
			MergeReports(lstAtt, heatMapFolder.Id);
		}
		else
		{
			abortJob(schJobName);
			Datetime sysTime = System.now().addSeconds( 30 );      
        	String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
			System.schedule(schJobName, chronExpression, new GS_MergeHeatMapScheduler(setOfJobIds, schJobName, region, numFiles, selectedRoles, lstProducts, marketCap));
        
		}
		return;	
	}
	
	private boolean allJobsCompleted()
	{
		List<AsyncApexJob> jobs = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors
									FROM AsyncApexJob WHERE ID in: setOfJobIds];
		for(AsyncApexJob job : jobs)
		{
			if(job.status != 'Completed')
				return false;
		}					
		
		return true;		
	}
	
	public void MergeReports(list<Document> lstPartialFiles, Id FolderId)
    {
        string tempContent = '';
        for(Document att : lstPartialFiles)
        {
            tempContent += att.body.toString();          
        }
        GS_HeatMapController_JU hmc = new GS_HeatMapController_JU();
        hmc.lstProducts = lstProducts;
        if(marketCap != null)
        {
        	hmc.isCorporateHM = true;
        }
        else
        {
        	hmc.isCorporateHM = false;
        }
        string reportType = hmc.isCorporateHM ? 'Corporate Sales' : 'GMG Sales';
        string finalFileName = 'Heat Map '+ reportType + ' ' +(region != null ? (region + '_') : '_') +Datetime.now().format('dd-MMM-yy hh:mm:ss a')+'.xls';
        Document doc = new Document();
        string tempRegion = region != null ? region : 'All Regions';
        Blob test = Blob.valueOf(hmc.createTable(tempContent, selectedRoles, tempRegion, marketCap));
        doc.FolderId = FolderId;
        doc.Name = finalFileName;
        doc.contenttype = 'EXCEL';
        doc.type = 'xls';
        doc.Body = test;
        insert doc;
        
        //--send mail
        
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();

        blob csvBlob = test;
        csvAttc.setFileName(finalFileName);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> {'ambadas_morkhandikar@epam.com'};
        String subject ='Heat Map Report_'+ (region != null ? (region + '_') : '') + Datetime.now().format();
        email.setSubject(subject);
        email.setTargetObjectID(UserInfo.getUserID());
        email.saveAsActivity = false;
        email.setToAddresses(toAddresses);
        email.setPlainTextBody(subject);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        
        //delete the partial files created as part of this report generation
        database.delete(lstPartialFiles);
        return ;
    }
    
    public void abortJob(string jobName)
    {
    	list<CronJobDetail> lstCronJobDetail = [SELECT Id FROM CronJobDetail WHERE Name=:jobName];
    	if(lstCronJobDetail != null && lstCronJobDetail.size() > 0){
	    	Id detailId = lstCronJobDetail[0].Id;
			if (detailId != null) {
				list<CronTrigger> lstCronTrigger = [SELECT Id from CronTrigger WHERE CronJobDetailId = :detailId];
				if(lstCronTrigger != null && lstCronTrigger.size() > 0){
					Id jobId = lstCronTrigger[0].Id;
					System.abortJob(jobId);
				}
			}
    	}
    }
}