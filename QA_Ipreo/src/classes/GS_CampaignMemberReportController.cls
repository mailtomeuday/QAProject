public class GS_CampaignMemberReportController {
    
    public class CampaignMemberWrapper{
        public CampaignMember campaignMember{get;set;}
        public Contact contact{get;set;}
        public String company{get;set;}
        public String primarySalesRep{get;set;}
        public String secondarySalesRep{get;set;}
        public Task activity{get;set;}
        
        public CampaignMemberWrapper(CampaignMember camMember, Contact contact){
            this.campaignMember = camMember;
            Contact contactTemp = new Contact();
            contactTemp.Id = contact.id;
            contactTemp.FirstName = contact.FirstName;
            contactTemp.LastName = contact.LastName;
            contactTemp.Phone = contact.Phone;
            contactTemp.Email = contact.Email;
            contactTemp.mailingCity = contact.mailingCity;
            contactTemp.mailingState = contact.mailingState;
            company = contact.Account.Name;
            primarySalesRep = (String.isBlank(contact.Account.Primary_Sales_Rep__r.name) ? '' : contact.Account.Primary_Sales_Rep__r.name);
            secondarySalesRep = (String.isBlank(contact.Account.Secondary_Sales_Rep__r.name) ? '' : contact.Account.Secondary_Sales_Rep__r.name);
            this.contact = contactTemp;
            this.activity = null;
            if(contact.Tasks.size() > 0)
                for(Task task : contact.Tasks){
                    if(task.createdDate >= camMember.lastModifiedDate){
                        this.activity = task;
                        break;
                    }
                }
        }
    }
    public String accountFilter {get;set;}
    public String[] Status {get;set;}
    public List<CampaignMemberWrapper> lstBindings{get;set;}
    public Integer totalRecords{get;set;}
    public CampaignMemberWrapper wrapper{get;set;}
    public boolean disableButton{get;set;}
    public CampaignMember campWrapper{get;set;}
    private final Integer ROWS_LIMIT = 15000; 
    public GS_CampaignMemberReportController()
    {
        campWrapper = new CampaignMember(); 
        accountFilter = '1';
        disableButton = false;
        totalRecords = 0;
    } 
    
    public List<SelectOption> getAccountFilterOptions()
    {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('1','All Campaigns')); 
        options.add(new SelectOption('2','All Active Campaigns')); 
        options.add(new SelectOption('3','Select a Specific Campaign')); 
        return options; 
    }
    
    public List<SelectOption> getStatusOptions(){
        List<SelectOption> options = new List<SelectOption>(); 
        Schema.DescribeSobjectResult dsr = Schema.getGlobalDescribe().get('CampaignMember').getDescribe();
        Schema.DescribeFieldResult dfr = dsr.fields.getMap().get('Status').getDescribe();
        options.add(new SelectOption('-','--None--')); 
        for(Schema.PicklistEntry pe : dfr.getPicklistValues())
        {
            options.add(new SelectOption(pe.getValue(), pe.getLabel()));
        }
        return options;
    }
    
    public PageReference doSearch() {            
        List<CampaignMemberWrapper> campaignMems = new List<CampaignMemberWrapper>();
        Set<Id> contactIds = new Set<Id>();
        String soql = buildQuery();
        DateTime minDateTime;
        Boolean isFirst = true;
        try{
            List<CampaignMember> campaignMembers = (List<CampaignMember>)Database.query(soql);
            if(!validatePageParameters())
            {
                return null;
            }
            totalRecords = Database.countQuery(buildCountQuery());
            if(totalRecords == ROWS_LIMIT)
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Please narrow your search as the report cannot be created with these many campaign member records.');
                ApexPages.addMessage(myMsg);
                return null;
            }
            if(totalRecords == 0)
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, 'No Results found');
                ApexPages.addMessage(myMsg);
                return null;
            }
            if(totalRecords > 0)
            {
                GS_CampaignMemberReportBatch batch = new GS_CampaignMemberReportBatch(soql,Status);
                Database.executeBatch(batch,200);
                disableButton = true;
                string message = ''; 
                message = 'Report will contain '+totalRecords+' Records. You will receive an email with the report at: '+UserInfo.getUserEmail()+' once the report is generated.';
                System.debug(message);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, message);
                ApexPages.addMessage(myMsg);
                return null;
            }       
        }
        catch(System.Exception ex){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Error Generating Requested Report');
            ApexPages.addMessage(myMsg);
        }     
        return null;
    }
    
    public PageReference navigateToBack(){
        PageReference pf = new PageReference('/701');
        pf.setRedirect(true);
        return pf;
    }
    
    public static String processBatch(List<CampaignMember> campaignMembers) {            
        String rowData;
        List<CampaignMemberWrapper> campaignMems = new List<CampaignMemberWrapper>();
        Set<Id> contactIds = new Set<Id>();
        DateTime minDateTime;
        Boolean isFirst = true;
        String profile = 'Sales User';
        try{
            for(CampaignMember camMember: campaignMembers){
                contactIds.add(camMember.contactId);
                if(isFirst){
                    minDateTime = camMember.lastModifiedDate;
                    isFirst = false;
                }
            }
            Map<Id, Contact> contactsMap = new Map<Id,Contact>([Select id, FirstName, LastName, Email, Phone, mailingCity, mailingState, Account.Name, Account.Primary_Sales_Rep__r.name, Account.Secondary_Sales_Rep__r.name,  (Select id, CreatedDate, Subject, Type, Status, CreatedBy.Name, Owner.Name, Description from Tasks where createdDate >=: minDateTime and Owner.Profile.Name =: profile order by createdDate) from Contact where id in: contactIds]);
            for(CampaignMember camMember: campaignMembers){
                Contact contact = contactsMap.get(camMember.contactId);
                if(contact != null){
                    campaignMems.add(new CampaignMemberWrapper(camMember, contact));
                }    
            }
            rowData = createRowData(campaignMems);
        }
        catch(System.Exception ex){
            throw ex;
        }     
        return rowData;
    }
    
    private String buildQuery() {
        String soql = 'Select id,contactId,CampaignId, Campaign.Name,Status, LastModifiedDate,HasResponded from CampaignMember where ContactId != null';
        if(accountFilter == '2'){
            soql += ' AND Campaign.IsActive = true';        
        }
        if(accountFilter == '3'){
            if(campWrapper.Campaign__c != null){
                soql += ' AND CampaignId = \'' + campWrapper.Campaign__c + '\'';
            }       
        }
        
        if(Status != null && Status.size() > 0){
            soql += ' AND Status in: Status';
        }
        soql += ' Order by LastModifiedDate';
        if (!test.isRunningTest()){
        	soql += ' limit '+ROWS_LIMIT;
        }        	
        System.debug(soql);
        return soql;
    }
    
    private String buildCountQuery() {
        String soql = 'Select count() from CampaignMember where ContactId != null';
        if(accountFilter == '2'){
            soql += ' AND Campaign.IsActive = true';        
        }
        if(accountFilter == '3'){
            if(campWrapper.Campaign__c != null){
                soql += ' AND CampaignId = \'' + campWrapper.Campaign__c + '\'';
            }
        }
        
        if(Status != null && Status.size() > 0){
            soql += ' AND Status in: Status';
        }
        soql += ' Limit '+ROWS_LIMIT;
        System.debug(soql);
        return soql;
    }
    
    public PageReference AbortOperation()
    {
        List<AsyncApexJob> jobs = [SELECT Id, ApexClass.Name,Status FROM AsyncApexJob where Status in ('Holding','Queued','Preparing','Processing') and ApexClass.Name = 'GS_CampaignMemberReportBatch' and createdById =: UserInfo.getUserID()];
        for(AsyncApexJob job : jobs)
        {
            System.abortJob(job.Id);
        }
        //abort scheduled job
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'Operation has been aborted.');
        ApexPages.addMessage(myMsg);
        disableButton = false;
        return null;
    }
    
    public PageReference resetFilters()
    {
    	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'Filters updated to defaults');
        ApexPages.addMessage(myMsg);
        disableButton = false;
        return null;
    }
    
    public boolean validatePageParameters(){
        if(accountFilter == '3' && campWrapper.campaign__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Please select campaign');
            ApexPages.addMessage(myMsg);
            return false;
        }
        return true;
    }
    public static string createRowData(List<CampaignMemberWrapper> campaignMemberWrappers){                   
        String rowData = '';
        for(CampaignMemberWrapper wrapper : campaignMemberWrappers){
            rowData += '<tr>';
            rowData += '<td><a href="'+URL.getSalesforceBaseUrl().toExternalForm() +
                '/' + wrapper.campaignMember.CampaignId+'">'+wrapper.campaignMember.Campaign.Name+'</a></td>';     
            rowData += '<td><a href="'+URL.getSalesforceBaseUrl().toExternalForm() +
                '/' + wrapper.Contact.id+'">'+wrapper.Contact.FirstName+'</a></td>';
            rowData += '<td><a href="'+URL.getSalesforceBaseUrl().toExternalForm() +
                '/' + wrapper.Contact.id+'">'+wrapper.Contact.LastName+'</a></td>';
            rowData += '<td>'+wrapper.company+'</td>';
            rowData += '<td>'+wrapper.primarySalesRep +'</td>';
            rowData += '<td>'+wrapper.secondarySalesRep +'</td>';                          
            rowData += '<td>'+((wrapper.campaignMember.Status == NULL || wrapper.campaignMember.Status == '') ? ''  : wrapper.campaignMember.Status) +'</td>';                                  
            rowData += '<td>'+((wrapper.campaignMember.LastModifiedDate == NULL ) ? ''  : string.valueOf(wrapper.campaignMember.LastModifiedDate)) +'</td>';
            //rowData += '<td>'+wrapper.campaignMember.HasResponded +'</td>';
            rowData += '<td>'+(String.isBlank(wrapper.Contact.Phone) ? '' : wrapper.Contact.Phone) +'</td>';
            rowData += '<td>'+(String.isBlank(wrapper.Contact.Email) ? '' : wrapper.Contact.Email) +'</td>';    
            rowData += '<td>'+(String.isBlank(wrapper.Contact.mailingCity) ? '' : wrapper.Contact.mailingCity) +'</td>';
            rowData += '<td>'+(String.isBlank(wrapper.Contact.mailingState) ? '' : wrapper.Contact.mailingState) +'</td>';
            rowData += '<td>'+((wrapper.Activity.CreatedDate == NULL ) ? ''  : string.valueOf(wrapper.Activity.CreatedDate)) +'</td>';
            rowData += '<td>'+(String.isBlank(wrapper.Activity.Type) ? '' : wrapper.Activity.Type) +'</td>';
            rowData += '<td>'+(String.isBlank(wrapper.Activity.Subject) ? '' : wrapper.Activity.Subject) +'</td>';
            rowData += '<td>'+(String.isBlank(wrapper.Activity.Status) ? '' : wrapper.Activity.Status) +'</td>';
            rowData += '<td>'+(String.isBlank(wrapper.Activity.CreatedBy.Name) ? '' : wrapper.Activity.CreatedBy.Name) +'</td>';
            rowData += '<td>'+(String.isBlank(wrapper.Activity.Owner.Name) ? '' : wrapper.Activity.Owner.Name) +'</td>';
            rowData += '<td>'+(String.isBlank(wrapper.Activity.Description) ? '' : (wrapper.Activity.Description.left(255)))+'</td>';
            rowData += '</tr>';
        }
        return rowData;
    }
    
    public static string createTable(string createdRows)
    {
        string s = '<html> <head> <style> table { font-family: arial, sans-serif; border-collapse: collapse; width: 100%; }td, th { border: 1px solid #dddddd; text-align: left;padding: 8px; } </style> </head> <body><table>';
        s += createHeader();
        s += createdRows;
        s += '</table></body> </html>';
        return s;
    }
    
    public static string createHeader()
    {
        string headerString = '';       
        headerString += '<tr><th>Campaign Name</th><th>First Name</th><th>Last Name</th><th>Company</th><th>Primary Sales Rep</th><th>Secondary Sales Rep</th><th>Campaign Member Status</th><th>Member Status Update Date</th><th>Phone</th><th>Email</th><th>City</th><th>State</th><th>Activity Date</th><th>Activity Type</th><th>Subject</th><th>Activity Status</th><th>Activity Created By</th><th>Activity Owner</th><th>Detailed Notes and Next Steps</th></tr>';      
        return headerString;
    }
    
    public static void createAndSendReport(String rows)
    {
        string finalFileName = 'Campaign Member Report '+Datetime.now().format('dd-MMM-yy hh:mm:ss a')+'.xls';
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        Blob test = Blob.valueOf(GS_CampaignMemberReportController.createTable(rows));
        blob csvBlob = test;
        csvAttc.setFileName(finalFileName);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        //String[] toAddresses = new list<string> {'uday_bikkumalla@epam.com'};
        String subject ='Campaign Member Report_'+ Datetime.now().format();
        email.setSubject(subject);
        email.setTargetObjectID(UserInfo.getUserID());
        email.saveAsActivity = false;
        //email.setToAddresses(toAddresses);
        email.setPlainTextBody(subject);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    } 
}